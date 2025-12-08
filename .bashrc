# If not running interactively, don't do anything
case $- in
*i*) ;;
*) return ;;
esac

# Launch fish in interactive session
if [[ -z "$SKIP_FISH" ]] && command -v fish >/dev/null 2>&1; then
  shopt -q login_shell && LOGIN_OPTION='--login' || LOGIN_OPTION=''
  exec fish $LOGIN_OPTION
fi
