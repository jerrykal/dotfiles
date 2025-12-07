# Do nothing on non-interactive session
case $- in
*i*) ;;
*) return ;;
esac

# Launch fish in interactive session
[ -t 1 ] && [ -z "$SKIP_FISH" ] && command -v fish >/dev/null 2>&1 && exec fish
