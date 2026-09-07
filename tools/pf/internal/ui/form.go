package ui

import (
	"fmt"
	"strconv"
	"strings"

	"github.com/charmbracelet/bubbles/textinput"
	tea "github.com/charmbracelet/bubbletea"
	"github.com/charmbracelet/lipgloss"

	"github.com/jerrykal/dotfiles/tools/pf/internal/tunnel"
)

// formModel is the "new tunnel" editor.
type formModel struct {
	inputs [3]textinput.Model // host, local port, remote port
	focus  int
	err    string
	busy   bool
}

const (
	fHost = iota
	fLocal
	fRemote
)

func newForm() formModel {
	var f formModel
	for i := range f.inputs {
		in := textinput.New()
		in.Prompt = ""
		in.Cursor.Style = lipgloss.NewStyle().Foreground(cAccent)
		in.PromptStyle = sMuted
		in.TextStyle = sText
		in.PlaceholderStyle = sMuted
		in.CompletionStyle = sMuted
		f.inputs[i] = in
	}
	f.inputs[fHost].Placeholder = "ssh host or alias"
	f.inputs[fHost].ShowSuggestions = true
	f.inputs[fHost].SetSuggestions(tunnel.SSHHosts())
	f.inputs[fHost].CharLimit = 128
	f.inputs[fHost].Width = 32
	for _, i := range []int{fLocal, fRemote} {
		f.inputs[i].CharLimit = 5
		f.inputs[i].Width = 16
	}
	f.inputs[fLocal].Placeholder = "1-65535"
	f.inputs[fRemote].Placeholder = "same as local"
	f.setFocus(fHost)
	return f
}

func (f *formModel) setFocus(i int) tea.Cmd {
	f.focus = i
	var cmd tea.Cmd
	for j := range f.inputs {
		if j == i {
			cmd = f.inputs[j].Focus()
		} else {
			f.inputs[j].Blur()
		}
	}
	return cmd
}

// values validates the form and returns host, local, remote.
func (f *formModel) values() (string, int, int, error) {
	host := strings.TrimSpace(f.inputs[fHost].Value())
	if host == "" {
		return "", 0, 0, fmt.Errorf("host is required")
	}
	local, err := strconv.Atoi(strings.TrimSpace(f.inputs[fLocal].Value()))
	if err != nil || !tunnel.ValidPort(local) {
		return "", 0, 0, fmt.Errorf("local port must be 1-65535")
	}
	remote := local
	if v := strings.TrimSpace(f.inputs[fRemote].Value()); v != "" {
		if remote, err = strconv.Atoi(v); err != nil || !tunnel.ValidPort(remote) {
			return "", 0, 0, fmt.Errorf("remote port must be 1-65535")
		}
	}
	return host, local, remote, nil
}

// update handles a key while the form is open. submit is true when the user
// asked to create the tunnel; cancel when they backed out.
func (f *formModel) update(msg tea.Msg) (cmd tea.Cmd, submit, cancel bool) {
	if f.busy {
		return nil, false, false
	}
	if k, ok := msg.(tea.KeyMsg); ok {
		switch k.String() {
		case "esc":
			return nil, false, true
		case "ctrl+s":
			return nil, true, false
		case "enter":
			if f.focus == fRemote || (f.focus == fLocal && f.inputs[fLocal].Value() != "") {
				return nil, true, false
			}
			return f.setFocus(f.focus + 1), false, false
		case "tab", "down":
			if f.focus == fHost && k.String() == "tab" && f.inputs[fHost].CurrentSuggestion() != "" &&
				f.inputs[fHost].CurrentSuggestion() != f.inputs[fHost].Value() {
				break // let the input accept the suggestion
			}
			if f.focus == fHost && k.String() == "down" && len(f.inputs[fHost].AvailableSuggestions()) > 1 {
				break
			}
			return f.setFocus((f.focus + 1) % len(f.inputs)), false, false
		case "shift+tab", "up":
			if f.focus == fHost && k.String() == "up" && len(f.inputs[fHost].AvailableSuggestions()) > 1 {
				break
			}
			return f.setFocus((f.focus + len(f.inputs) - 1) % len(f.inputs)), false, false
		}
	}
	f.inputs[f.focus], cmd = f.inputs[f.focus].Update(msg)
	f.err = ""
	return cmd, false, false
}

func (f *formModel) view(spin string, w int) string {
	label := func(i int, text string) string {
		st := sLabel
		if i == f.focus {
			st = st.Foreground(cAccent).Bold(true)
		}
		return st.Render(text)
	}
	var b strings.Builder
	b.WriteString(" " + sBold.Render("New tunnel") + "\n\n")
	b.WriteString(" " + label(fHost, "host") + f.inputs[fHost].View() + "\n")
	b.WriteString(" " + label(fLocal, "local port") + f.inputs[fLocal].View() + "\n")
	b.WriteString(" " + label(fRemote, "remote port") + f.inputs[fRemote].View() + "\n\n")
	switch {
	case f.busy:
		b.WriteString(" " + sWarn.Render(spin+" connecting to "+strings.TrimSpace(f.inputs[fHost].Value())+"…") + "\n")
	case f.err != "":
		b.WriteString(lipgloss.NewStyle().Foreground(cBad).PaddingLeft(1).Width(max(10, w-1)).Render(f.err) + "\n")
	default:
		if hint := f.inputs[fHost].CurrentSuggestion(); f.focus == fHost && hint != "" && hint != f.inputs[fHost].Value() {
			b.WriteString(" " + sMuted.Render("tab to complete "+hint) + "\n")
		} else {
			b.WriteString("\n")
		}
	}
	b.WriteString("\n " + sMuted.Render("enter/tab next · ctrl+s create · esc cancel"))
	return b.String()
}
