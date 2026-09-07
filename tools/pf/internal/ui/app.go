// Package ui is the Bubble Tea front end: a list of tunnels with a detail and
// log pane, an inline form for new and edited tunnels, and single-key actions.
package ui

import (
	"context"
	"errors"
	"fmt"
	"strings"
	"time"

	"github.com/charmbracelet/bubbles/spinner"
	"github.com/charmbracelet/bubbles/textinput"
	"github.com/charmbracelet/bubbles/viewport"
	tea "github.com/charmbracelet/bubbletea"
	"github.com/charmbracelet/lipgloss"
	"github.com/charmbracelet/x/ansi"

	"github.com/jerrykal/dotfiles/tools/pf/internal/tunnel"
)

const (
	refreshEvery = time.Second
	logLines     = 500
	wideMin      = 96
	flashFor     = 4 * time.Second
)

type mode int

const (
	modeList mode = iota
	modeForm
	modeConfirm
	modeLogs
	modeHelp
)

type (
	tickMsg    time.Time
	refreshMsg struct {
		tunnels []tunnel.Tunnel
		logs    []string
		forID   int
	}
	startedMsg struct {
		t    tunnel.Tunnel
		err  error
		verb string // "Created", "Updated", "Connected"
	}
	actionMsg struct {
		text string
		err  error
	}
	clearFlashMsg struct{ at time.Time }
)

type model struct {
	store   *tunnel.Store
	tunnels []tunnel.Tunnel
	visible []int // indices into tunnels after filtering
	cursor  int   // index into visible
	selID   int
	pending int // id of a tunnel being started in the background; selected once it appears
	logs    []string

	width, height int
	mode          mode
	filter        textinput.Model
	filtering     bool
	form          formModel
	spinner       spinner.Model
	logView       viewport.Model
	confirmID     int

	flash    string
	flashErr bool
	flashAt  time.Time
}

// Run starts the TUI and blocks until it exits.
func Run(store *tunnel.Store) error {
	m := model{store: store, spinner: newSpinner(), filter: newFilter(), logView: newLogView()}
	_, err := tea.NewProgram(m, tea.WithAltScreen()).Run()
	return err
}

func newSpinner() spinner.Model {
	sp := spinner.New(spinner.WithSpinner(spinner.MiniDot))
	sp.Style = sWarn
	return sp
}

func newFilter() textinput.Model {
	f := textinput.New()
	f.Prompt = "/"
	f.PromptStyle = sKey
	f.Placeholder = "filter"
	return f
}

func newLogView() viewport.Model { return viewport.New(0, 0) }

func (m model) Init() tea.Cmd {
	return tea.Batch(m.refresh(), tick(), m.spinner.Tick)
}

func tick() tea.Cmd {
	return tea.Tick(refreshEvery, func(t time.Time) tea.Msg { return tickMsg(t) })
}

func (m model) refresh() tea.Cmd {
	store, id := m.store, m.selID
	return func() tea.Msg {
		ts, _ := store.List()
		ts = store.Prune(ts)
		var logs []string
		if id != 0 {
			logs = store.TailLog(id, logLines)
		}
		return refreshMsg{tunnels: ts, logs: logs, forID: id}
	}
}

func (m model) selected() (tunnel.Tunnel, bool) {
	if len(m.visible) == 0 || m.cursor >= len(m.visible) {
		return tunnel.Tunnel{}, false
	}
	return m.tunnels[m.visible[m.cursor]], true
}

func (m *model) applyFilter() {
	q := strings.ToLower(strings.TrimSpace(m.filter.Value()))
	m.visible = m.visible[:0]
	for i, t := range m.tunnels {
		hay := strings.ToLower(fmt.Sprintf("%s %d %d %s", t.Host, t.LocalPort, t.RemotePort, t.State))
		if q == "" || strings.Contains(hay, q) {
			m.visible = append(m.visible, i)
		}
	}
	// Keep the same tunnel selected across refreshes where possible.
	m.cursor = 0
	for i, idx := range m.visible {
		if m.tunnels[idx].ID == m.selID {
			m.cursor = i
			break
		}
	}
	if len(m.visible) > 0 {
		m.selID = m.tunnels[m.visible[m.cursor]].ID
	} else {
		m.selID = 0
	}
}

func (m *model) move(delta int) {
	if len(m.visible) == 0 {
		return
	}
	m.cursor = (m.cursor + delta + len(m.visible)) % len(m.visible)
	m.selID = m.tunnels[m.visible[m.cursor]].ID
	m.logs = nil
}

func (m *model) setFlash(text string, isErr bool) tea.Cmd {
	m.flash, m.flashErr, m.flashAt = text, isErr, time.Now()
	at := m.flashAt
	return tea.Tick(flashFor, func(time.Time) tea.Msg { return clearFlashMsg{at: at} })
}

func (m *model) layout() {
	h := m.height - 2
	if m.wide() {
		m.logView.Width = m.width - m.listWidth() - 2
	} else {
		m.logView.Width = m.width - 2
	}
	m.logView.Height = max(1, h-2)
}

func (m model) wide() bool { return m.width >= wideMin }

func (m model) listWidth() int {
	if !m.wide() {
		return m.width
	}
	return max(52, m.width*11/20)
}

func (m model) Update(msg tea.Msg) (tea.Model, tea.Cmd) {
	switch msg := msg.(type) {
	case tea.WindowSizeMsg:
		m.width, m.height = msg.Width, msg.Height
		m.layout()
		return m, nil

	case tickMsg:
		return m, tea.Batch(m.refresh(), tick())

	case refreshMsg:
		m.tunnels = msg.tunnels
		if m.pending != 0 {
			for _, t := range m.tunnels {
				if t.ID == m.pending {
					m.selID, m.pending = t.ID, 0
					break
				}
			}
		}
		m.applyFilter()
		if msg.forID == m.selID {
			m.logs = msg.logs
			if m.mode == modeLogs {
				atBottom := m.logView.AtBottom()
				m.logView.SetContent(strings.Join(m.logs, "\n"))
				if atBottom {
					m.logView.GotoBottom()
				}
			}
		}
		return m, nil

	case spinner.TickMsg:
		var cmd tea.Cmd
		m.spinner, cmd = m.spinner.Update(msg)
		return m, cmd

	case startedMsg:
		m.pending = 0
		if msg.t.ID != 0 {
			m.selID = msg.t.ID
		}
		switch {
		case errors.Is(msg.err, tunnel.ErrUnchanged):
			return m, nil
		case msg.err != nil:
			return m, tea.Batch(m.refresh(), m.setFlash(msg.err.Error(), true))
		}
		return m, tea.Batch(m.refresh(), m.setFlash(fmt.Sprintf("%s tunnel %d: %s → %s", msg.verb, msg.t.ID, msg.t.LocalAddr(), msg.t.RemoteAddr()), false))

	case actionMsg:
		if msg.err != nil {
			return m, tea.Batch(m.refresh(), m.setFlash(msg.err.Error(), true))
		}
		return m, tea.Batch(m.refresh(), m.setFlash(msg.text, false))

	case clearFlashMsg:
		if msg.at.Equal(m.flashAt) {
			m.flash = ""
		}
		return m, nil

	case tea.KeyMsg:
		return m.handleKey(msg)
	}
	return m, nil
}

func (m model) handleKey(msg tea.KeyMsg) (tea.Model, tea.Cmd) {
	if msg.String() == "ctrl+c" {
		return m, tea.Quit
	}
	switch m.mode {
	case modeForm:
		cmd, submit, cancel := m.form.update(msg)
		switch {
		case cancel:
			m.mode = modeList
			return m, nil
		case submit:
			host, local, remote, err := m.form.values()
			if err != nil {
				m.form.err = err.Error()
				return m, nil
			}
			// Connect in the background: the list shows the tunnel as
			// "connecting" meanwhile and the outcome arrives as a flash.
			m.mode = modeList
			store, editID := m.store, m.form.editID
			var start tea.Cmd
			if editID != 0 {
				m.pending = editID
				start = func() tea.Msg {
					t, err := store.Edit(context.Background(), editID, host, local, remote)
					return startedMsg{t: t, err: err, verb: "Updated"}
				}
			} else {
				m.pending = store.NextID()
				start = func() tea.Msg {
					t, err := store.Start(context.Background(), host, local, remote)
					return startedMsg{t: t, err: err, verb: "Created"}
				}
			}
			return m, tea.Batch(start, m.refresh(), m.setFlash("Connecting to "+host+"…", false))
		}
		return m, cmd

	case modeConfirm:
		m.mode = modeList
		switch msg.String() {
		case "y", "Y", "enter":
			id, store := m.confirmID, m.store
			return m, func() tea.Msg {
				if err := store.Close(id); err != nil {
					return actionMsg{err: err}
				}
				return actionMsg{text: fmt.Sprintf("Closed tunnel %d", id)}
			}
		}
		return m, nil

	case modeLogs:
		switch msg.String() {
		case "q", "esc", "enter", "l":
			m.mode = modeList
			return m, nil
		}
		var cmd tea.Cmd
		m.logView, cmd = m.logView.Update(msg)
		return m, cmd

	case modeHelp:
		m.mode = modeList
		return m, nil
	}

	// modeList
	if m.filtering {
		switch msg.String() {
		case "esc":
			m.filter.SetValue("")
			m.filtering = false
			m.filter.Blur()
			m.applyFilter()
			return m, nil
		case "enter":
			m.filtering = false
			m.filter.Blur()
			return m, nil
		}
		var cmd tea.Cmd
		m.filter, cmd = m.filter.Update(msg)
		m.applyFilter()
		return m, cmd
	}

	switch msg.String() {
	case "q":
		return m, tea.Quit
	case "j", "down":
		m.move(1)
		return m, m.refresh()
	case "k", "up":
		m.move(-1)
		return m, m.refresh()
	case "g", "home":
		m.move(-m.cursor)
		return m, m.refresh()
	case "G", "end":
		m.move(len(m.visible) - 1 - m.cursor)
		return m, m.refresh()
	case "n", "a":
		m.form = newForm()
		m.mode = modeForm
		return m, textinput.Blink
	case "e":
		if t, ok := m.selected(); ok {
			m.form = editForm(t)
			m.mode = modeForm
			return m, textinput.Blink
		}
		return m, nil
	case "x", "d", "delete", "backspace":
		if t, ok := m.selected(); ok {
			m.confirmID = t.ID
			m.mode = modeConfirm
		}
		return m, nil
	case "r":
		if t, ok := m.selected(); ok {
			id, store := t.ID, m.store
			if t.State == tunnel.StateFailed {
				m.pending = id
				return m, tea.Batch(func() tea.Msg {
					t, err := store.Retry(context.Background(), id)
					return startedMsg{t: t, err: err, verb: "Connected"}
				}, m.refresh(), m.setFlash("Connecting to "+t.Host+"…", false))
			}
			return m, func() tea.Msg {
				if err := store.Restart(id); err != nil {
					return actionMsg{err: err}
				}
				return actionMsg{text: fmt.Sprintf("Restarting tunnel %d", id)}
			}
		}
		return m, nil
	case "y":
		if t, ok := m.selected(); ok {
			addr := fmt.Sprintf("localhost:%d", t.LocalPort)
			if err := copyToClipboard(addr); err != nil {
				return m, m.setFlash(err.Error(), true)
			}
			return m, m.setFlash("Copied "+addr, false)
		}
		return m, nil
	case "enter", "l":
		if _, ok := m.selected(); ok {
			m.mode = modeLogs
			m.layout()
			m.logView.SetContent(strings.Join(m.logs, "\n"))
			m.logView.GotoBottom()
		}
		return m, nil
	case "/":
		m.filtering = true
		return m, m.filter.Focus()
	case "esc":
		if m.filter.Value() != "" {
			m.filter.SetValue("")
			m.applyFilter()
		}
		return m, nil
	case "?":
		m.mode = modeHelp
		return m, nil
	}
	return m, nil
}

// ---------------------------------------------------------------- rendering

func (m model) View() string {
	if m.width == 0 {
		return ""
	}
	bodyH := m.height - 2
	var body string
	switch {
	case m.mode == modeHelp:
		body = pane("help", m.helpView(), m.width, bodyH, true)
	case !m.wide():
		switch m.mode {
		case modeForm:
			body = pane(m.form.title(), m.form.view(m.width-2), m.width, bodyH, true)
		case modeLogs:
			body = pane(m.detailTitle(), m.logView.View(), m.width, bodyH, true)
		default:
			body = pane("tunnels", m.listView(m.width-2, bodyH-2), m.width, bodyH, true)
		}
	default:
		lw := m.listWidth()
		dw := m.width - lw
		left := pane("tunnels", m.listView(lw-2, bodyH-2), lw, bodyH, m.mode == modeList || m.mode == modeConfirm)
		var right string
		switch m.mode {
		case modeForm:
			right = pane(m.form.title(), m.form.view(dw-2), dw, bodyH, true)
		case modeLogs:
			right = pane(m.detailTitle()+" · log", m.logView.View(), dw, bodyH, true)
		default:
			right = pane(m.detailTitle(), m.detailView(dw-2, bodyH-2), dw, bodyH, false)
		}
		body = lipgloss.JoinHorizontal(lipgloss.Top, left, right)
	}
	return m.headerView() + "\n" + body + "\n" + m.footerView()
}

func (m model) headerView() string {
	var up, down, failed int
	for _, t := range m.tunnels {
		switch t.State {
		case tunnel.StateConnected:
			up++
		case tunnel.StateFailed:
			failed++
		default:
			down++
		}
	}
	left := sTitle.Render("pf") + "  " + sSubtle.Render("ssh port forwards")
	var parts []string
	if up > 0 {
		parts = append(parts, sGood.Render(fmt.Sprintf("● %d up", up)))
	}
	if down > 0 {
		parts = append(parts, sWarn.Render(fmt.Sprintf("◐ %d down", down)))
	}
	if failed > 0 {
		parts = append(parts, sBad.Render(fmt.Sprintf("○ %d failed", failed)))
	}
	if len(parts) == 0 {
		parts = append(parts, sMuted.Render("no tunnels"))
	}
	right := strings.Join(parts, sMuted.Render("  "))
	gap := m.width - 2 - lipgloss.Width(left) - lipgloss.Width(right)
	return sHeader.Render(left + strings.Repeat(" ", max(1, gap)) + right)
}

func (m model) footerView() string {
	var s string
	switch {
	case m.mode == modeConfirm:
		var t tunnel.Tunnel
		for _, c := range m.tunnels {
			if c.ID == m.confirmID {
				t = c
			}
		}
		s = sWarn.Render(fmt.Sprintf("Close tunnel %d (%s → %s)? ", m.confirmID, t.LocalAddr(), t.RemoteAddr())) + hint("y", "yes") + "  " + hint("n", "no")
	case m.filtering:
		s = m.filter.View() + "  " + sMuted.Render("enter apply · esc clear")
	case m.flash != "":
		if m.flashErr {
			s = sFlashEr.Render("✗ " + m.flash)
		} else {
			s = sFlash.Render("✓ " + m.flash)
		}
	case m.mode == modeForm:
		verb := "create"
		if m.form.editID != 0 {
			verb = "save"
		}
		s = strings.Join([]string{hint("tab", "next"), hint("ctrl+s", verb), hint("esc", "cancel")}, "  ")
	case m.mode == modeLogs:
		s = strings.Join([]string{hint("j/k", "scroll"), hint("g/G", "top/bottom"), hint("esc", "back")}, "  ")
	default:
		s = strings.Join([]string{
			hint("n", "new"), hint("e", "edit"), hint("x", "close"), hint("r", "restart"), hint("↵", "log"),
			hint("y", "copy"), hint("/", "filter"), hint("?", "help"), hint("q", "quit"),
		}, "  ")
		if m.filter.Value() != "" {
			s += "   " + sInfo.Render("filter: "+m.filter.Value())
		}
	}
	return sFooter.Render(fit(s, m.width-2))
}

func hint(key, label string) string { return sKey.Render(key) + " " + sMuted.Render(label) }

func (m model) stateGlyph(t tunnel.Tunnel) string {
	switch t.State {
	case tunnel.StateConnected:
		return sGood.Render("●")
	case tunnel.StateConnecting, tunnel.StateReconnecting:
		return m.spinner.View()
	default:
		return sBad.Render("○")
	}
}

func stateStyle(s tunnel.State) lipgloss.Style {
	switch s {
	case tunnel.StateConnected:
		return sGood
	case tunnel.StateConnecting, tunnel.StateReconnecting:
		return sWarn
	default:
		return sBad
	}
}

func (m model) listView(w, h int) string {
	if len(m.tunnels) == 0 {
		msg := sMuted.Render("No tunnels yet.") + "\n\n" + sMuted.Render("Press ") + sKey.Render("n") + sMuted.Render(" to create one.")
		return lipgloss.Place(w, h, lipgloss.Center, lipgloss.Center, msg)
	}
	if len(m.visible) == 0 {
		return lipgloss.Place(w, h, lipgloss.Center, lipgloss.Center, sMuted.Render("Nothing matches the filter."))
	}
	// Columns: " " glyph " " host " " local " → " remote "  " state "  " extra
	const fixed = 1 + 1 + 1 + 1 + 5 + 3 + 5 + 2 + 12 + 2
	hostW := 0
	for _, i := range m.visible {
		hostW = max(hostW, len(m.tunnels[i].Host))
	}
	hostW = min(max(hostW, 8), max(8, w-fixed-12))
	extraW := max(0, w-fixed-hostW)

	// Scroll window so the cursor stays visible.
	start := 0
	if m.cursor >= h {
		start = m.cursor - h + 1
	}
	var lines []string
	for row := start; row < len(m.visible) && row < start+h; row++ {
		t := m.tunnels[m.visible[row]]
		sel := row == m.cursor
		bg := func(st lipgloss.Style) lipgloss.Style {
			if sel {
				return st.Background(cSelect)
			}
			return st
		}
		plain := bg(sText)
		host := bg(sText).Render(fit(t.Host, hostW))
		if sel {
			host = bg(sBold).Render(fit(t.Host, hostW))
		}
		ports := plain.Render(fmt.Sprintf("%5d", t.LocalPort)) + bg(sMuted).Render(" → ") + plain.Render(fmt.Sprintf("%-5d", t.RemotePort))
		state := bg(stateStyle(t.State)).Render(fit(string(t.State), 12))
		var extra string
		switch t.State {
		case tunnel.StateConnected:
			extra = bg(sSubtle).Render(fit("up "+Duration(t.Age()), extraW))
		case tunnel.StateReconnecting:
			e := fmt.Sprintf("retry %d", t.Reconnects)
			if t.Error != "" {
				e += " · " + t.Error
			}
			extra = bg(sWarn).Render(fit(e, extraW))
		case tunnel.StateFailed:
			extra = bg(sBad).Render(fit(t.Error, extraW))
		default:
			extra = bg(sMuted).Render(fit("…", extraW))
		}
		glyph := m.stateGlyph(t)
		if sel {
			glyph = bg(stateStyle(t.State)).Render(ansi.Strip(glyph))
		}
		lines = append(lines, plain.Render(" ")+glyph+plain.Render(" ")+host+plain.Render(" ")+ports+plain.Render("  ")+state+plain.Render("  ")+extra)
	}
	return strings.Join(lines, "\n")
}

func (m model) detailTitle() string {
	t, ok := m.selected()
	if !ok {
		return "detail"
	}
	return fmt.Sprintf("%s :%d", t.Host, t.LocalPort)
}

func (m model) detailView(w, h int) string {
	t, ok := m.selected()
	if !ok {
		return lipgloss.Place(w, h, lipgloss.Center, lipgloss.Center, sMuted.Render("Select a tunnel to see details."))
	}
	kv := func(k, v string) string { return " " + sLabel.Render(k) + v }
	stateLine := m.stateGlyph(t) + " " + stateStyle(t.State).Render(string(t.State))
	switch t.State {
	case tunnel.StateConnected:
		stateLine += sMuted.Render("  for " + Duration(t.Age()))
	case tunnel.StateReconnecting:
		stateLine += sMuted.Render("  since " + Duration(t.Age()) + " ago")
	case tunnel.StateFailed:
		stateLine += sMuted.Render("  ") + sKey.Render("r") + sMuted.Render(" retry · ") + sKey.Render("e") + sMuted.Render(" edit · ") + sKey.Render("x") + sMuted.Render(" close")
	}
	lines := []string{
		" " + sBold.Render(t.Host),
		" " + sMuted.Render(fmt.Sprintf("localhost:%d → %s:%d", t.LocalPort, t.Host, t.RemotePort)),
		"",
		kv("state", stateLine),
		kv("local", sText.Render(t.LocalAddr())),
		kv("remote", sText.Render(fmt.Sprintf("127.0.0.1:%d on %s", t.RemotePort, t.Host))),
		kv("reconnects", sText.Render(fmt.Sprintf("%d", t.Reconnects))),
	}
	if t.Error != "" {
		lines = append(lines, kv("last error", sWarn.Render(t.Error)))
	}
	if t.PID != 0 {
		pid := sText.Render(fmt.Sprintf("%d", t.PID))
		if t.SSHPID != 0 {
			pid += sMuted.Render(fmt.Sprintf("  ssh %d", t.SSHPID))
		}
		lines = append(lines, kv("pid", pid))
	}
	lines = append(lines,
		kv("created", sText.Render(t.Created.Format("2006-01-02 15:04"))),
		"",
		" "+sMuted.Render("log ")+sMuted.Render(strings.Repeat("─", max(0, w-6))),
	)
	room := h - len(lines)
	logs := m.logs
	if len(logs) > room {
		logs = logs[len(logs)-max(0, room):]
	}
	for _, l := range logs {
		lines = append(lines, " "+styleLog(l))
	}
	return strings.Join(lines, "\n")
}

// styleLog dims the timestamp and colors pf's own status lines.
func styleLog(l string) string {
	if len(l) > 9 && l[8] == ' ' {
		ts, rest := l[:8], l[9:]
		if strings.HasPrefix(rest, "pf: ") {
			return sMuted.Render(ts) + " " + sInfo.Render(rest)
		}
		return sMuted.Render(ts) + " " + sSubtle.Render(rest)
	}
	return l
}

func (m model) helpView() string {
	rows := [][2]string{
		{"j / k, ↑ / ↓", "move selection"},
		{"g / G", "first / last tunnel"},
		{"n", "new tunnel"},
		{"e", "edit selected tunnel's host or ports (reconnects)"},
		{"x / d", "close selected tunnel (asks first)"},
		{"r", "restart selected tunnel's ssh session, or retry a failed one"},
		{"enter / l", "full-screen log for selected tunnel"},
		{"y", "copy localhost:<port> to clipboard"},
		{"/", "filter by host, port or state"},
		{"esc", "clear filter"},
		{"?", "this help"},
		{"q", "quit (tunnels keep running)"},
	}
	var b strings.Builder
	b.WriteString(" " + sBold.Render("Keys") + "\n\n")
	for _, r := range rows {
		b.WriteString(" " + sKey.Render(fit(r[0], 16)) + sText.Render(r[1]) + "\n")
	}
	b.WriteString("\n " + sMuted.Render("Tunnels are supervised by detached `pf _supervise` processes and survive quitting the TUI."))
	b.WriteString("\n " + sMuted.Render("A tunnel whose first connection fails stays listed as failed, with its log, until closed, retried or edited."))
	b.WriteString("\n " + sMuted.Render("State dir: "+m.store.Dir))
	b.WriteString("\n\n " + sMuted.Render("press any key to go back"))
	return b.String()
}
