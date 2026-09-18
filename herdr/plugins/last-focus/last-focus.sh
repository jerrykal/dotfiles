#!/usr/bin/env bash
#
# last-focus — herdr plugin
#
#   last-focus.sh record      event hook for pane/tab/workspace.focused
#   last-focus.sh pane        focus the previous pane of the current tab
#   last-focus.sh tab         focus the previous tab of the current workspace
#   last-focus.sh workspace   focus the previous workspace
#
# Each scope keeps a two-line history file (current, previous) in the plugin
# state dir: `workspace` for workspaces, `tab.<workspace_id>` for tabs,
# `pane.<tab_id>` for panes.
#
# herdr cannot focus a pane by id, so `pane` walks there with directional focus
# moves. While walking, `pane.jump` (target, epoch) tells `record` to skip the
# panes passed through.
#
# Requires `jq`.

set -euo pipefail

herdr="${HERDR_BIN_PATH:-herdr}"
state="${HERDR_PLUGIN_STATE_DIR:?}"

# push FILE ID — make ID the current entry, demoting the old current.
push() {
  local cur=""
  [ -f "$1" ] && cur="$(sed -n 1p "$1")"
  [ "$cur" = "$2" ] || printf '%s\n%s\n' "$2" "$cur" > "$1"
}

# last FILE CURRENT — the most recent entry that is not CURRENT.
last() {
  [ ! -f "$1" ] || { grep -vxF -- "$2" "$1" || true; } | sed -n 1p
}

# route FROM TO — directions leading from pane FROM to pane TO (BFS over neighbors).
route() {
  local queue="$1:" seen=" $1 " item pane path dir next
  while [ -n "$queue" ]; do
    item="${queue%%$'\n'*}"
    queue="${queue#"$item"}"; queue="${queue#$'\n'}"
    pane="${item%:*}" path="${item##*:}"
    for dir in left down up right; do
      next="$("$herdr" pane neighbor --pane "$pane" --direction "$dir" \
        | jq -r '.result.neighbor.neighbor_pane_id // empty')"
      [ -n "$next" ] || continue
      case "$seen" in *" $next "*) continue ;; esac
      [ "$next" != "$2" ] || { echo "$path $dir"; return; }
      seen="$seen$next "
      queue="$queue${queue:+$'\n'}$next:$path $dir"
    done
  done
  return 1
}

case "${1:?usage: last-focus.sh <record|pane|tab|workspace>}" in
  record)
    data="$(jq -c '.data // .' <<<"$HERDR_PLUGIN_EVENT_JSON")"
    ws="$(jq -r '.workspace_id' <<<"$data")"
    case "$(jq -r '.type' <<<"$data")" in
      workspace_focused) push "$state/workspace" "$ws" ;;
      pane_focused)
        pane="$(jq -r '.pane_id' <<<"$data")"
        if [ -f "$state/pane.jump" ]; then
          { read -r target; read -r at; } < "$state/pane.jump"
          [ "$pane" != "$target" ] || rm -f "$state/pane.jump"
          [ $(($(date +%s) - at)) -gt 2 ] || exit 0
        fi
        tab="$("$herdr" pane get "$pane" | jq -r '.result.pane.tab_id')"
        push "$state/pane.$tab" "$pane"
        ;;
      tab_focused) push "$state/tab.$ws" "$(jq -r '.tab_id' <<<"$data")" ;;
    esac
    ;;
  pane)
    file="$state/pane.${HERDR_TAB_ID:?}"
    target="$(last "$file" "${HERDR_PANE_ID:?}")"
    [ -n "$target" ] || exit 0
    path="$(route "$HERDR_PANE_ID" "$target")"
    printf '%s\n%s\n' "$target" "$(date +%s)" > "$state/pane.jump"
    printf '%s\n%s\n' "$target" "$HERDR_PANE_ID" > "$file"
    for dir in $path; do
      "$herdr" pane focus --direction "$dir" --current >/dev/null
    done
    ;;
  tab)
    target="$(last "$state/tab.${HERDR_WORKSPACE_ID:?}" "${HERDR_TAB_ID:?}")"
    [ -z "$target" ] || exec "$herdr" tab focus "$target"
    ;;
  workspace)
    target="$(last "$state/workspace" "${HERDR_WORKSPACE_ID:?}")"
    [ -z "$target" ] || exec "$herdr" workspace focus "$target"
    ;;
esac
