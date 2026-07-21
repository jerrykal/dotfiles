# Ensure .profile env is present even in non-login shells, including
# non-interactive remote commands (`ssh host cmd` sources .bashrc but not
# .profile). Must run before the interactive gate below. fish inherits it.
[[ -z "$__PROFILE_SOURCED" && -f "$HOME/.profile" ]] && source "$HOME/.profile"

# If not running interactively, don't do anything further
case $- in
*i*) ;;
*) return ;;
esac

# Launch fish in interactive session
if [[ -z "$SKIP_FISH" ]] && command -v fish >/dev/null 2>&1; then
  exec fish
fi
