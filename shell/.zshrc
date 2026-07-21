# If not running interactively, don't do anything
[[ -o interactive ]] || return

# Ghostty quick terminal → global scratchpad
if [[ -n "$GHOSTTY_QUICK_TERMINAL" ]] && command -v nvim >/dev/null 2>&1; then
  exec nvim \
    -c 'autocmd ColorScheme * hi Normal guibg=NONE | hi NormalNC guibg=NONE | hi EndOfBuffer guibg=NONE' \
    -c 'doautocmd ColorScheme' \
    -c 'autocmd FocusLost * silent! update' \
    -c 'set laststatus=0 noruler' \
    ~/.scratchpad.md
fi

# Ensure .profile env is present even in non-login shells (fish inherits it)
[[ -z "$__PROFILE_SOURCED" && -f "$HOME/.profile" ]] && source "$HOME/.profile"

# Launch fish in interactive session
if [[ -z "$SKIP_FISH" ]] && command -v fish >/dev/null 2>&1; then
  exec fish
fi
