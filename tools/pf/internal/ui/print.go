package ui

import (
	"fmt"
	"io"
	"strings"

	"github.com/charmbracelet/lipgloss"

	"github.com/jerrykal/dotfiles/tools/pf/internal/tunnel"
)

// Printer styles plain CLI output with the same palette as the TUI. Colors
// are dropped automatically when w is not a terminal.
type Printer struct{ r *lipgloss.Renderer }

// NewPrinter returns a Printer bound to w.
func NewPrinter(w io.Writer) *Printer { return &Printer{r: lipgloss.NewRenderer(w)} }

func (p *Printer) fg(c lipgloss.TerminalColor) lipgloss.Style { return p.r.NewStyle().Foreground(c) }

func (p *Printer) Text(s string) string   { return p.fg(cText).Render(s) }
func (p *Printer) Bold(s string) string   { return p.fg(cText).Bold(true).Render(s) }
func (p *Printer) Subtle(s string) string { return p.fg(cSubtle).Render(s) }
func (p *Printer) Muted(s string) string  { return p.fg(cMuted).Render(s) }
func (p *Printer) Key(s string) string    { return p.fg(cKey).Bold(true).Render(s) }
func (p *Printer) Accent(s string) string { return p.fg(cAccent).Bold(true).Render(s) }

// Success, Failure and Notice are one-line status messages.
func (p *Printer) Success(s string) string { return p.fg(cGood).Render("✓ ") + p.Text(s) }
func (p *Printer) Failure(s string) string { return p.fg(cBad).Render("✗ ") + p.fg(cBad).Render(s) }
func (p *Printer) Notice(s string) string  { return p.fg(cWarn).Render("◐ ") + p.Text(s) }

// StateGlyph is the static counterpart of the TUI's status marker.
func (p *Printer) StateGlyph(s tunnel.State) string {
	switch s {
	case tunnel.StateConnected:
		return p.fg(cGood).Render("●")
	case tunnel.StateConnecting, tunnel.StateReconnecting:
		return p.fg(cWarn).Render("◐")
	default:
		return p.fg(cBad).Render("○")
	}
}

// State renders text (normally the state name, possibly padded) in the
// state's color.
func (p *Printer) State(s tunnel.State, text string) string {
	switch s {
	case tunnel.StateConnected:
		return p.fg(cGood).Render(text)
	case tunnel.StateConnecting, tunnel.StateReconnecting:
		return p.fg(cWarn).Render(text)
	default:
		return p.fg(cBad).Render(text)
	}
}

// Ports renders "local → remote".
func (p *Printer) Ports(local, remote int) string {
	return p.Text(fmt.Sprintf("%5d", local)) + p.Muted(" → ") + p.Text(fmt.Sprintf("%-6d", remote))
}

// LogLine dims the timestamp and colors pf's own lines, like the TUI log pane.
func (p *Printer) LogLine(l string) string {
	if len(l) > 9 && l[8] == ' ' {
		ts, rest := l[:8], l[9:]
		if strings.HasPrefix(rest, "pf: ") {
			return p.Muted(ts) + " " + p.fg(cInfo).Render(rest)
		}
		return p.Muted(ts) + " " + p.Subtle(rest)
	}
	return l
}

// Frames for a simple CLI spinner.
var SpinnerFrames = []string{"⠋", "⠙", "⠹", "⠸", "⠼", "⠴", "⠦", "⠧", "⠇", "⠏"}

// Spin renders one spinner frame with a message.
func (p *Printer) Spin(i int, msg string) string {
	return p.fg(cWarn).Render(SpinnerFrames[i%len(SpinnerFrames)]) + " " + p.Subtle(msg)
}
