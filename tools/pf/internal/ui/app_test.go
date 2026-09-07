package ui

import (
	"strings"
	"testing"
	"time"

	tea "github.com/charmbracelet/bubbletea"
	"github.com/charmbracelet/lipgloss"

	"github.com/jerrykal/dotfiles/tools/pf/internal/tunnel"
)

func fixture(t *testing.T) model {
	t.Helper()
	store := &tunnel.Store{Dir: t.TempDir()}
	now := time.Now()
	m := model{store: store, logView: newLogView()}
	m.filter = newFilter()
	m.spinner = newSpinner()
	m.tunnels = []tunnel.Tunnel{
		{ID: 1, Host: "devbox", LocalPort: 5432, RemotePort: 5432, State: tunnel.StateConnected, Since: now.Add(-2 * time.Hour), Created: now},
		{ID: 2, Host: "a-very-long-hostname-that-needs-truncating.example.com", LocalPort: 8080, RemotePort: 3000, State: tunnel.StateReconnecting, Reconnects: 3, Error: "ssh: connect to host 10.0.0.1 port 22: Connection refused", Since: now, Created: now},
		{ID: 3, Host: "staging", LocalPort: 6379, RemotePort: 6379, State: tunnel.StateConnecting, Since: now, Created: now},
	}
	m.logs = []string{"14:02:10 pf: connecting to devbox", "14:02:11 pf: connected: 127.0.0.1:5432 -> devbox:5432", "14:02:12 debug1: some ssh noise"}
	m.applyFilter()
	return m
}

func assertShape(t *testing.T, name, view string, w, h int) {
	t.Helper()
	lines := strings.Split(view, "\n")
	if len(lines) != h {
		t.Errorf("%s: got %d lines, want %d", name, len(lines), h)
	}
	for i, l := range lines {
		if got := lipgloss.Width(l); got > w {
			t.Errorf("%s: line %d is %d wide, want <= %d: %q", name, i, got, w, l)
		}
	}
}

func TestViewShapes(t *testing.T) {
	for _, size := range [][2]int{{140, 40}, {100, 24}, {80, 20}, {60, 12}} {
		w, h := size[0], size[1]
		m := fixture(t)
		m.width, m.height = w, h
		m.layout()
		for _, mode := range []mode{modeList, modeForm, modeConfirm, modeLogs, modeHelp} {
			m.mode = mode
			if mode == modeForm {
				m.form = newForm()
			}
			if mode == modeLogs {
				m.logView.SetContent(strings.Join(m.logs, "\n"))
			}
			assertShape(t, strings.Join([]string{"mode", string(rune('0' + mode)), "size", string(rune('0' + w/10))}, "-"), m.View(), w, h)
		}
	}
}

func TestEmptyAndFilter(t *testing.T) {
	m := fixture(t)
	m.width, m.height = 120, 30
	m.layout()
	m.filter.SetValue("staging")
	m.applyFilter()
	if len(m.visible) != 1 || m.tunnels[m.visible[0]].ID != 3 {
		t.Fatalf("filter: visible=%v", m.visible)
	}
	assertShape(t, "filtered", m.View(), 120, 30)

	m.tunnels = nil
	m.applyFilter()
	if !strings.Contains(m.View(), "No tunnels yet") {
		t.Error("empty state text missing")
	}
	assertShape(t, "empty", m.View(), 120, 30)
}

func TestKeysDoNotPanic(t *testing.T) {
	m := fixture(t)
	m.width, m.height = 120, 30
	m.layout()
	var cur tea.Model = m
	for _, k := range []string{"j", "k", "G", "g", "n", "esc", "x", "n", "/", "d", "esc", "?", "q", "enter", "esc", "r", "y"} {
		var key tea.KeyMsg
		switch k {
		case "esc":
			key = tea.KeyMsg{Type: tea.KeyEsc}
		case "enter":
			key = tea.KeyMsg{Type: tea.KeyEnter}
		default:
			key = tea.KeyMsg{Type: tea.KeyRunes, Runes: []rune(k)}
		}
		cur, _ = cur.Update(key)
		cur.View()
	}
}
