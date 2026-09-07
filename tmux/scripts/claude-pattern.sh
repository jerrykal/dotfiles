# Sourced by claude-pane.sh and claude-picker.sh: sets $pattern, a regex matching a
# pane_current_command that is claude.
# macOS reports claude's executable as its version number (e.g. "2.1.206").
pattern='^claude$'
if [[ "$(uname)" == "Darwin" ]]; then
  pattern='^(claude|[0-9]+\.[0-9]+\.[0-9]+)$'
fi
