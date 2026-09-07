package ui

import (
	"fmt"
	"os/exec"
	"runtime"
	"strings"
	"time"

	"github.com/charmbracelet/lipgloss"
	"github.com/charmbracelet/x/ansi"
)

// Rosé Pine palette (main for dark terminals, dawn for light).
// https://rosepinetheme.com/palette
func rp(dark, light string) lipgloss.AdaptiveColor {
	return lipgloss.AdaptiveColor{Dark: dark, Light: light}
}

var (
	rpText     = rp("#e0def4", "#575279")
	rpSubtle   = rp("#908caa", "#797593")
	rpMuted    = rp("#6e6a86", "#9893a5")
	rpLove     = rp("#eb6f92", "#b4637a")
	rpGold     = rp("#f6c177", "#ea9d34")
	rpRose     = rp("#ebbcba", "#d7827e")
	rpPine     = rp("#31748f", "#286983")
	rpFoam     = rp("#9ccfd8", "#56949f")
	rpIris     = rp("#c4a7e7", "#907aa9")
	rpHighMed  = rp("#403d52", "#dfdad9")
	rpHighHigh = rp("#524f67", "#cecacd")
	rpOverlay  = rp("#26233a", "#f2e9e1")
)

var (
	cAccent  = rpIris
	cGood    = rpFoam
	cWarn    = rpGold
	cBad     = rpLove
	cInfo    = rpPine
	cMuted   = rpMuted
	cSubtle  = rpSubtle
	cText    = rpText
	cSelect  = rpHighMed
	cBorder  = rpHighHigh
	cBorderF = rpIris
	cKey     = rpRose
)

var (
	sTitle   = lipgloss.NewStyle().Bold(true).Foreground(cAccent)
	sMuted   = lipgloss.NewStyle().Foreground(cMuted)
	sSubtle  = lipgloss.NewStyle().Foreground(cSubtle)
	sText    = lipgloss.NewStyle().Foreground(cText)
	sBold    = lipgloss.NewStyle().Bold(true).Foreground(cText)
	sKey     = lipgloss.NewStyle().Foreground(cKey).Bold(true)
	sGood    = lipgloss.NewStyle().Foreground(cGood)
	sWarn    = lipgloss.NewStyle().Foreground(cWarn)
	sBad     = lipgloss.NewStyle().Foreground(cBad)
	sInfo    = lipgloss.NewStyle().Foreground(cInfo)
	sLabel   = lipgloss.NewStyle().Foreground(cSubtle).Width(12)
	sFlash   = lipgloss.NewStyle().Foreground(cGood)
	sFlashEr = lipgloss.NewStyle().Foreground(cBad).Bold(true)
	sHeader  = lipgloss.NewStyle().Padding(0, 1)
	sFooter  = lipgloss.NewStyle().Padding(0, 1)
)

// pane draws a rounded box with a title embedded in the top border.
func pane(title, content string, w, h int, focused bool) string {
	if w < 4 || h < 2 {
		return ""
	}
	border := lipgloss.NewStyle().Foreground(cBorder)
	if focused {
		border = border.Foreground(cBorderF)
	}
	inner := w - 2
	label := ""
	if title != "" {
		label = " " + title + " "
		label = ansi.Truncate(label, inner-2, "…")
	}
	styledLabel := label
	if focused {
		styledLabel = sTitle.Render(label)
	} else {
		styledLabel = sBold.Render(label)
	}
	top := border.Render("╭─") + styledLabel + border.Render(strings.Repeat("─", max(0, inner-1-lipgloss.Width(label)))+"╮")
	bottom := border.Render("╰" + strings.Repeat("─", inner) + "╯")

	lines := strings.Split(content, "\n")
	bodyH := h - 2
	if len(lines) > bodyH {
		lines = lines[:bodyH]
	}
	for len(lines) < bodyH {
		lines = append(lines, "")
	}
	var b strings.Builder
	b.WriteString(top)
	b.WriteByte('\n')
	side := border.Render("│")
	for _, l := range lines {
		b.WriteString(side)
		b.WriteString(fit(l, inner))
		b.WriteString(side)
		b.WriteByte('\n')
	}
	b.WriteString(bottom)
	return b.String()
}

// fit truncates or pads a styled line to exactly w cells.
func fit(s string, w int) string {
	s = ansi.Truncate(s, w, "…")
	if pad := w - lipgloss.Width(s); pad > 0 {
		s += strings.Repeat(" ", pad)
	}
	return s
}

// Duration renders a compact human duration such as "2h14m".
func Duration(d time.Duration) string {
	switch {
	case d < 0:
		return "0s"
	case d < time.Minute:
		return fmt.Sprintf("%ds", int(d.Seconds()))
	case d < time.Hour:
		return fmt.Sprintf("%dm", int(d.Minutes()))
	case d < 24*time.Hour:
		return fmt.Sprintf("%dh%02dm", int(d.Hours()), int(d.Minutes())%60)
	default:
		return fmt.Sprintf("%dd%dh", int(d.Hours())/24, int(d.Hours())%24)
	}
}

func copyToClipboard(text string) error {
	var candidates [][]string
	if runtime.GOOS == "darwin" {
		candidates = [][]string{{"pbcopy"}}
	} else {
		candidates = [][]string{{"wl-copy"}, {"xclip", "-selection", "clipboard"}, {"xsel", "--clipboard", "--input"}}
	}
	for _, c := range candidates {
		if _, err := exec.LookPath(c[0]); err != nil {
			continue
		}
		cmd := exec.Command(c[0], c[1:]...)
		cmd.Stdin = strings.NewReader(text)
		return cmd.Run()
	}
	return fmt.Errorf("no clipboard tool found")
}
