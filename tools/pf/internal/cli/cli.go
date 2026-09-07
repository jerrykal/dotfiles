// Package cli wires the cobra command tree: `pf` alone opens the TUI, the
// positional form creates a tunnel, and subcommands cover scripting.
package cli

import (
	"context"
	"errors"
	"fmt"
	"os"
	"strconv"
	"strings"
	"time"

	"github.com/charmbracelet/x/ansi"
	"github.com/charmbracelet/x/term"
	"github.com/spf13/cobra"

	"github.com/jerrykal/dotfiles/tools/pf/internal/tunnel"
	"github.com/jerrykal/dotfiles/tools/pf/internal/ui"
)

// Version is stamped by the build; falls back to VCS info at runtime.
var Version = "dev"

var (
	out  = ui.NewPrinter(os.Stdout)
	errp = ui.NewPrinter(os.Stderr)
)

// Fail prints an error the way the rest of the CLI prints status lines.
func Fail(err error) { fmt.Fprintln(os.Stderr, errp.Failure(err.Error())) }

// New builds the root command.
func New() *cobra.Command {
	var store *tunnel.Store

	root := &cobra.Command{
		Use:   "pf [host local-port [remote-port]]",
		Short: "Manage SSH local port forwards",
		Long: `pf keeps SSH port forwards alive in the background and shows them in a TUI.

  pf                       open the TUI
  pf devbox 5432           forward localhost:5432 -> devbox:5432
  pf devbox 8080 3000      forward localhost:8080 -> devbox:3000
  pf edit 2 --local 8081   move tunnel 2 to localhost:8081

A tunnel whose first connection fails is kept as "failed" so its log can be
read with pf logs; pf restart retries it and pf close drops it.`,
		Args:          cobra.MaximumNArgs(3),
		SilenceUsage:  true,
		SilenceErrors: true,
		Version:       Version,
		PersistentPreRunE: func(cmd *cobra.Command, args []string) error {
			var err error
			store, err = tunnel.DefaultStore()
			return err
		},
		RunE: func(cmd *cobra.Command, args []string) error {
			if len(args) == 0 {
				return ui.Run(store)
			}
			if len(args) == 1 {
				return errors.New("usage: pf <host> <local-port> [remote-port]")
			}
			local, err := parsePort(args[1])
			if err != nil {
				return err
			}
			remote := local
			if len(args) == 3 {
				if remote, err = parsePort(args[2]); err != nil {
					return err
				}
			}
			stop := spin("connecting to " + args[0])
			t, err := store.Start(context.Background(), args[0], local, remote)
			stop()
			if err != nil {
				return keptFailure(t, err)
			}
			fmt.Println(out.Success(fmt.Sprintf("Created tunnel %s  %s", out.Bold(strconv.Itoa(t.ID)), route(t))))
			return nil
		},
		ValidArgsFunction: func(cmd *cobra.Command, args []string, toComplete string) ([]string, cobra.ShellCompDirective) {
			if len(args) == 0 {
				return tunnel.SSHHosts(), cobra.ShellCompDirectiveNoFileComp
			}
			return nil, cobra.ShellCompDirectiveNoFileComp
		},
	}
	root.CompletionOptions.HiddenDefaultCmd = true

	root.AddCommand(
		&cobra.Command{
			Use:   "ui",
			Short: "Open the TUI (same as running pf with no arguments)",
			Args:  cobra.NoArgs,
			RunE:  func(cmd *cobra.Command, args []string) error { return ui.Run(store) },
		},
		&cobra.Command{
			Use:   "list",
			Short: "List tunnels",
			Args:  cobra.NoArgs,
			RunE:  func(cmd *cobra.Command, args []string) error { return printList(store) },
		},
		&cobra.Command{
			Use:               "close <id>...",
			Short:             "Close one or more tunnels",
			Args:              cobra.MinimumNArgs(1),
			ValidArgsFunction: completeIDs(&store),
			RunE: func(cmd *cobra.Command, args []string) error {
				for _, a := range args {
					id, err := strconv.Atoi(a)
					if err != nil {
						return fmt.Errorf("invalid id %q", a)
					}
					if err := store.Close(id); err != nil {
						return err
					}
					fmt.Println(out.Success(fmt.Sprintf("Closed tunnel %s", out.Bold(strconv.Itoa(id)))))
				}
				return nil
			},
		},
		&cobra.Command{
			Use:               "restart <id>",
			Short:             "Drop and re-establish a tunnel's ssh session, or retry a failed one",
			Args:              cobra.ExactArgs(1),
			ValidArgsFunction: completeIDs(&store),
			RunE: func(cmd *cobra.Command, args []string) error {
				id, err := strconv.Atoi(args[0])
				if err != nil {
					return fmt.Errorf("invalid id %q", args[0])
				}
				cur, err := store.Load(id)
				if err != nil {
					return err
				}
				if cur.State == tunnel.StateFailed {
					stop := spin("connecting to " + cur.Host)
					t, err := store.Retry(context.Background(), id)
					stop()
					if err != nil {
						return keptFailure(t, err)
					}
					fmt.Println(out.Success(fmt.Sprintf("Connected tunnel %s  %s", out.Bold(strconv.Itoa(t.ID)), route(t))))
					return nil
				}
				if err := store.Restart(id); err != nil {
					return err
				}
				fmt.Println(out.Notice(fmt.Sprintf("Restarting tunnel %s", out.Bold(strconv.Itoa(id)))))
				return nil
			},
		},
		editCmd(&store),
		logsCmd(&store),
		&cobra.Command{
			Use:    "_supervise <id>",
			Hidden: true,
			Args:   cobra.ExactArgs(1),
			RunE: func(cmd *cobra.Command, args []string) error {
				id, err := strconv.Atoi(args[0])
				if err != nil {
					return err
				}
				// A failed first attempt is recorded in the state file and
				// log by Supervise itself; printing it again would only
				// litter the log (stderr is the log file).
				_ = store.Supervise(id)
				return nil
			},
		},
	)
	return root
}

func editCmd(store **tunnel.Store) *cobra.Command {
	var (
		host          string
		local, remote int
	)
	c := &cobra.Command{
		Use:   "edit <id>",
		Short: "Change a tunnel's host or ports (re-establishes its ssh session)",
		Long: `edit tears down the tunnel's ssh session and brings it back up under the same
id with the new settings. Unspecified values are kept. If the new settings
fail to connect, the previous ones are restored.`,
		Args:              cobra.ExactArgs(1),
		ValidArgsFunction: completeIDs(store),
		RunE: func(cmd *cobra.Command, args []string) error {
			id, err := strconv.Atoi(args[0])
			if err != nil {
				return fmt.Errorf("invalid id %q", args[0])
			}
			cur, err := (*store).Load(id)
			if err != nil {
				return err
			}
			f := cmd.Flags()
			if !f.Changed("host") && !f.Changed("local") && !f.Changed("remote") {
				return errors.New("nothing to change: pass --host, --local and/or --remote")
			}
			if !f.Changed("host") {
				host = cur.Host
			}
			if !f.Changed("local") {
				local = cur.LocalPort
			}
			if !f.Changed("remote") {
				remote = cur.RemotePort
			}
			stop := spin("reconnecting to " + host)
			t, err := (*store).Edit(context.Background(), id, host, local, remote)
			stop()
			if errors.Is(err, tunnel.ErrUnchanged) {
				fmt.Println(out.Notice(fmt.Sprintf("Tunnel %s unchanged  %s", out.Bold(strconv.Itoa(id)), route(t))))
				return nil
			}
			if err != nil {
				return keptFailure(t, err)
			}
			fmt.Println(out.Success(fmt.Sprintf("Updated tunnel %s  %s", out.Bold(strconv.Itoa(t.ID)), route(t))))
			return nil
		},
	}
	c.Flags().StringVar(&host, "host", "", "new ssh host or alias")
	c.Flags().IntVarP(&local, "local", "l", 0, "new local port")
	c.Flags().IntVarP(&remote, "remote", "r", 0, "new remote port")
	_ = c.RegisterFlagCompletionFunc("host", func(*cobra.Command, []string, string) ([]string, cobra.ShellCompDirective) {
		return tunnel.SSHHosts(), cobra.ShellCompDirectiveNoFileComp
	})
	return c
}

// keptFailure wraps a launch error with where the failed entry can be found.
func keptFailure(t tunnel.Tunnel, err error) error {
	if t.State != tunnel.StateFailed {
		return err
	}
	return fmt.Errorf("%w; kept as failed tunnel %d (pf logs %d · pf restart %d · pf close %d)", err, t.ID, t.ID, t.ID, t.ID)
}

func logsCmd(store **tunnel.Store) *cobra.Command {
	var n int
	c := &cobra.Command{
		Use:               "logs <id>",
		Short:             "Print a tunnel's recent log lines",
		Args:              cobra.ExactArgs(1),
		ValidArgsFunction: completeIDs(store),
		RunE: func(cmd *cobra.Command, args []string) error {
			id, err := strconv.Atoi(args[0])
			if err != nil {
				return fmt.Errorf("invalid id %q", args[0])
			}
			if _, err := (*store).Load(id); err != nil {
				return err
			}
			lines := (*store).TailLog(id, n)
			if len(lines) == 0 {
				fmt.Println(out.Muted("(no log lines yet)"))
			}
			for _, l := range lines {
				fmt.Println(out.LogLine(l))
			}
			return nil
		},
	}
	c.Flags().IntVarP(&n, "lines", "n", 50, "number of lines")
	return c
}

func completeIDs(store **tunnel.Store) func(*cobra.Command, []string, string) ([]string, cobra.ShellCompDirective) {
	return func(cmd *cobra.Command, args []string, toComplete string) ([]string, cobra.ShellCompDirective) {
		s, err := tunnel.DefaultStore()
		if err != nil {
			return nil, cobra.ShellCompDirectiveError
		}
		ts, _ := s.List()
		var out []string
		for _, t := range ts {
			out = append(out, fmt.Sprintf("%d\t%s -> %s (%s)", t.ID, t.LocalAddr(), t.RemoteAddr(), t.State))
		}
		return out, cobra.ShellCompDirectiveNoFileComp
	}
}

func printList(store *tunnel.Store) error {
	ts, err := store.List()
	if err != nil {
		return err
	}
	ts = store.Prune(ts)
	if len(ts) == 0 {
		fmt.Println(out.Muted("No tunnels.") + "  " + out.Subtle("Create one with ") + out.Key("pf <host> <port>") + out.Subtle(" or open the TUI with ") + out.Key("pf") + out.Subtle("."))
		return nil
	}
	width := 100
	if w, _, err := term.GetSize(os.Stdout.Fd()); err == nil && w > 0 {
		width = w
	}
	idW, hostW := 2, 4
	for _, t := range ts {
		idW = max(idW, len(strconv.Itoa(t.ID)))
		hostW = max(hostW, len(t.Host))
	}
	hostW = min(hostW, 32)
	// "  " glyph " " id "  " host "  " ports(14) "  " state(12) "  " info
	infoW := max(8, width-(2+1+1+idW+2+hostW+2+14+2+12+2))

	pad := func(s string, w int) string {
		return ansi.Truncate(s, w, "…") + strings.Repeat(" ", max(0, w-ansi.StringWidth(ansi.Truncate(s, w, "…"))))
	}
	fmt.Println("    " + out.Muted(pad("ID", idW)+"  "+pad("HOST", hostW)+"  "+pad("LOCAL → REMOTE", 14)+"  "+pad("STATE", 12)+"  INFO"))
	for _, t := range ts {
		var info string
		switch t.State {
		case tunnel.StateConnected:
			info = out.Subtle("up " + ui.Duration(t.Age()))
		case tunnel.StateReconnecting:
			e := fmt.Sprintf("retry %d", t.Reconnects)
			if t.Error != "" {
				e += " · " + t.Error
			}
			info = out.Subtle(ansi.Truncate(e, infoW, "…"))
		case tunnel.StateFailed:
			info = out.State(t.State, ansi.Truncate(t.Error, infoW, "…"))
		default:
			info = out.Muted("…")
		}
		fmt.Println("  " + out.StateGlyph(t.State) + " " + out.Text(pad(strconv.Itoa(t.ID), idW)) + "  " +
			out.Bold(pad(t.Host, hostW)) + "  " + out.Ports(t.LocalPort, t.RemotePort) + "  " +
			out.State(t.State, pad(string(t.State), 12)) + "  " + info)
	}
	return nil
}

func route(t tunnel.Tunnel) string {
	return out.Text(fmt.Sprintf("localhost:%d", t.LocalPort)) + out.Muted(" → ") + out.Text(t.RemoteAddr())
}

// spin shows a spinner on stderr while a slow step runs, when stderr is a
// terminal. The returned func clears it.
func spin(msg string) func() {
	if !term.IsTerminal(os.Stderr.Fd()) {
		return func() {}
	}
	done := make(chan struct{})
	finished := make(chan struct{})
	go func() {
		defer close(finished)
		for i := 0; ; i++ {
			select {
			case <-done:
				fmt.Fprint(os.Stderr, "\r\033[K")
				return
			case <-time.After(80 * time.Millisecond):
				fmt.Fprint(os.Stderr, "\r"+errp.Spin(i, msg+"…"))
			}
		}
	}()
	return func() { close(done); <-finished }
}

func parsePort(s string) (int, error) {
	p, err := strconv.Atoi(s)
	if err != nil || !tunnel.ValidPort(p) {
		return 0, fmt.Errorf("invalid port %q", s)
	}
	return p, nil
}
