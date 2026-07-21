# Read by every zsh invocation, including non-interactive remote commands
# (`ssh host cmd` reads .zshenv, never .zprofile/.zshrc). This is the one place
# zsh guarantees .profile env is present; .zprofile/.zshrc keep a guarded
# re-source as a belt-and-suspenders for `zsh -f` / NO_RCS. fish inherits it.
[[ -z "$__PROFILE_SOURCED" && -f "$HOME/.profile" ]] && source "$HOME/.profile"
