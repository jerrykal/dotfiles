#!/usr/bin/env bash
#
# herdr-picker — herdr plugin
#
#   herdr-picker.sh            fzf picker (the `picker` pane entrypoint)
#   herdr-picker.sh <query>    no picker: connect to the first matching row
#   herdr-picker.sh --open     action: open the picker in a popup
#   herdr-picker.sh --record   event hook for workspace.focused
#
# --list, --preview KEY, --close KEY... and --status are used by fzf bindings.
#
# Rows are the open workspaces, most recently focused first and the current
# one last, then the closed worktrees of the current repo, then zoxide directories not listed
# already; rows that are not open yet are dimmed. Each row is
# "<key>\t<display>": the key is a workspace id or an absolute directory, and
# only the display is shown and matched.
#
# herdr keeps no focus history, so `record` maintains one in the plugin state
# dir: `mru` lists workspace ids, most recent first.
#
# Requires `fzf`, `jq` and `zoxide`; previews directories with `eza` if present.

set -uo pipefail

herdr="${HERDR_BIN_PATH:-herdr}"
state="${HERDR_PLUGIN_STATE_DIR:-${XDG_STATE_HOME:-$HOME/.local/state}/herdr/plugins/herdr-picker}"
mru="$state/mru"
self="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd -P)/$(basename "${BASH_SOURCE[0]}")"

# The two headless entrypoints come first: they need neither jq nor the
# re-exec below, and `--record` runs on every workspace switch.
case "${1:-}" in
  --record)
    re='"workspace_id":[[:space:]]*"([^"]+)"'
    [[ "${HERDR_PLUGIN_EVENT_JSON:-}" =~ $re ]] || exit 0
    ws="${BASH_REMATCH[1]}"
    mkdir -p "$state"
    { echo "$ws"; [ ! -f "$mru" ] || grep -vxF -- "$ws" "$mru"; } > "$mru.$$"
    mv "$mru.$$" "$mru"
    exit 0
    ;;
  --open)
    # Actions have no tty; the picker runs in a plugin pane instead.
    exec "$herdr" plugin pane open --plugin "${HERDR_PLUGIN_ID:-herdr-picker}" \
      --entrypoint picker --placement popup --width 80% --height 70% --focus
    ;;
esac

# The herdr server may only have mise shims on PATH, and every shim call
# re-resolves the whole toolset. Re-exec under `mise exec` so fzf/jq/zoxide are
# real binaries; fzf's --list/--preview children inherit the resolved PATH.
# Resolving from $HOME keeps the caller's project config, and any tools it
# would install, out of it; nothing below depends on the working directory.
if [ -z "${__HERDR_PICKER_MISE:-}" ] && command -v mise >/dev/null 2>&1; then
  __HERDR_PICKER_MISE=1 exec mise -C "$HOME" exec -- bash "$self" "$@"
fi

workspace_icon=$'\033[34m\xee\xaf\x88\033[39m'
worktree_icon=$'\033[35m\xee\x9c\xa5\033[39m'
dir_icon=$'\033[36m\xef\x84\x94\033[39m'
header='enter open · ctrl-r rename / open with label · ctrl-x close'

fail() {
  printf '\033[31m%s\033[0m\n' "$1" >&2
  [ ! -t 2 ] || sleep 2
  exit 1
}

# run ARGS... — run a herdr command, failing with its error message.
run() {
  local err
  err="$("$herdr" "$@" 2>&1 >/dev/null)" && return
  fail "$(jq -r '.error.message // .' <<<"$err" 2>/dev/null || printf '%s' "$err")"
}

snapshot() {
  "$herdr" api snapshot | jq -c '.result.snapshot'
}

# The snapshot list_targets took for the running picker, else a fresh one.
cached_snapshot() {
  if [ -s "${HERDR_PICKER_CACHE:-}" ]; then cat "$HERDR_PICKER_CACHE"; else snapshot; fi
}

# Where --close leaves its failures for --status.
errors="${HERDR_PICKER_CACHE:+$HERDR_PICKER_CACHE.err}"
errors="${errors:-/dev/null}"

# A workspace's directory: its checkout, else the cwd of its first pane.
jq_cwd='def cwd($s): .workspace_id as $id
  | .worktree.checkout_path // ([$s.panes[] | select(.workspace_id == $id) | .cwd] | first) // "";'

list_targets() {
  local snap
  snap="$(snapshot)" || return
  [ -z "${HERDR_PICKER_CACHE:-}" ] || printf '%s\n' "$snap" > "$HERDR_PICKER_CACHE"

  # Drop closed workspaces from the history.
  if [ -f "$mru" ]; then
    jq -r '.workspaces[].workspace_id' <<<"$snap" | grep -xFf - "$mru" > "$mru.$$"
    mv "$mru.$$" "$mru"
  fi

  jq -r --rawfile mru "$([ -f "$mru" ] && echo "$mru" || echo /dev/null)" \
    --arg home "$HOME" --arg icon "$workspace_icon" --arg wticon "$worktree_icon" "$jq_cwd"'
    def tilde: if . == $home or startswith($home + "/") then "~" + .[($home | length):] else . end;
    ($mru | split("\n")) as $order | . as $s
    | .workspaces
    | sort_by([.workspace_id == $s.focused_workspace_id,
               (.workspace_id as $id | $order | index($id)) // 1e9, .number])[]
    | (if .worktree.is_linked_worktree then "\($wticon) \(.worktree.repo_name) › \(.label)"
       else "\($icon) \(.label)" end) as $name
    | "\(.workspace_id)\t\($name)  \u001b[2m\(cwd($s) | tilde)\u001b[0m"
  ' <<<"$snap"

  # Worktrees of the current workspace's repo that have no workspace yet. The
  # repo is found through the workspace directory: a new workspace has no
  # `worktree` yet.
  local root worktrees
  root="$(jq -r "$jq_cwd"'. as $s
    | .workspaces[] | select(.workspace_id == $s.focused_workspace_id) | cwd($s)' <<<"$snap")"
  worktrees="$([ -z "$root" ] || "$herdr" worktree list --cwd "$root" 2>/dev/null |
    jq -r --arg home "$HOME" --arg icon "$worktree_icon" '
      def tilde: if . == $home or startswith($home + "/") then "~" + .[($home | length):] else . end;
      .result | .source.repo_name as $repo | .worktrees[]
      | select(.open_workspace_id == null and (.is_bare or .is_prunable | not))
      | "\(.path)\t\($icon) \u001b[2m\($repo) › \(.branch // "detached")  \(.path | tilde)\u001b[0m"')"
  [ -z "$worktrees" ] || printf '%s\n' "$worktrees"

  # zoxide keeps directories as they were typed and herdr reports physical
  # paths, so rows are keyed and deduplicated by physical path but keep
  # zoxide's spelling. Directories that no longer exist drop out.
  zoxide query -l 2>/dev/null |
    while IFS= read -r dir; do
      ! cd -P -- "$dir" 2>/dev/null || printf '%s\t%s\n' "$PWD" "$dir"
    done |
    awk -F '\t' 'NR == FNR { listed[$0]; next } !($1 in listed) && !seen[$1]++' \
      <(echo; jq -r "$jq_cwd"'. as $s | .workspaces[] | cwd($s)' <<<"$snap"; cut -f1 <<<"$worktrees") - |
    while IFS=$'\t' read -r dir name; do
      case "$name" in "$HOME" | "$HOME"/*) name="~${name#"$HOME"}" ;; esac
      printf '%s\t%s \033[2m%s\033[0m\n' "$dir" "$dir_icon" "$name" 2>/dev/null || break
    done
  # The list is fzf's input: a stage above that matched nothing is no failure.
  return 0
}

# connect KEY [LABEL] — focus a workspace, or open a directory as one. Without
# LABEL a directory that is already open is focused rather than opened again.
# A workspace outside a git checkout is only known by its first pane's cwd, so
# it stops matching its directory once that pane has moved elsewhere.
connect() {
  local key="$1" label="${2:-}" existing root branch
  case "$key" in
    /*) ;;
    *) run workspace focus "$key"; return ;;
  esac
  [ -d "$key" ] || fail "not a directory: $key"
  key="$(cd -P -- "$key" && pwd)"
  if [ -z "$label" ]; then
    existing="$(snapshot | jq -r --arg d "$key" "$jq_cwd"'
      . as $s | [.workspaces[] | select(cwd($s) == $d) | .workspace_id] | first // empty')"
    if [ -n "$existing" ]; then
      run workspace focus "$existing"
      return
    fi
  fi
  # A linked worktree of a repo that is open joins that repo's workspace group,
  # labelled by its branch.
  { IFS= read -r root; IFS= read -r branch; } < <("$herdr" worktree list --cwd "$key" 2>/dev/null |
    jq -r --arg d "$key" '
      .result | select(.source.source_workspace_id != null) | .source.repo_root as $root
      | first(.worktrees[] | select(.path == $d and .is_linked_worktree)) | $root, .branch // ""
    ' 2>/dev/null)
  if [ -n "${root:-}" ]; then
    run worktree open --cwd "$root" --path "$key" --label "${label:-${branch:-$(basename "$key")}}" --focus
  else
    run workspace create --cwd "$key" --label "${label:-$(basename "$key")}" --focus
  fi
}

# close KEY... — close workspaces, the current one last. Failures (such as a
# worktree group that needs confirmation) are left for --status to show.
close() {
  local current id err ids=() last=()
  current="$(cached_snapshot | jq -r '.focused_workspace_id // empty')"
  : > "$errors"
  for id in "$@"; do
    case "$id" in
      /*) ;;
      "$current") last=("$id") ;;
      *) ids+=("$id") ;;
    esac
  done
  for id in ${ids[@]+"${ids[@]}"} ${last[@]+"${last[@]}"}; do
    err="$("$herdr" workspace close "$id" 2>&1 >/dev/null)" ||
      printf '%s: %s\n' "$id" "$(jq -r '.error.message // .' <<<"$err" 2>/dev/null || printf '%s' "$err")" \
        >> "$errors"
  done
}

status() {
  printf '%s\n' "$header"
  [ ! -s "$errors" ] || printf '\033[31m%s\033[0m\n' "$(cat "$errors")"
}

preview() {
  local pane
  case "$1" in
    /*)
      if command -v eza >/dev/null 2>&1; then
        eza --all -1 --group-directories-first --color=always "$1"
      else
        ls -A "$1"
      fi
      ;;
    *)
      pane="$(cached_snapshot | jq -r --arg id "$1" '
        (.workspaces[] | select(.workspace_id == $id) | .active_tab_id) as $tab
        | .layouts[] | select(.tab_id == $tab) | .focused_pane_id')"
      [ -z "$pane" ] || "$herdr" pane read "$pane" --source visible --format ansi
      ;;
  esac
}

# prompt_label INITIAL TITLE — an empty fzf as a one-line input. Esc cancels.
prompt_label() {
  local query status
  query="$(fzf --print-query --query "$1" --prompt "$2: " --no-info --pointer '' \
    --bind 'ctrl-u:clear-query' "${chrome[@]}" </dev/null)"
  status=$?
  [ "$status" -ne 130 ] || return 1
  printf '%s\n' "$query"
}

case "${1:-}" in
  --list) list_targets; exit 0 ;;
  --preview) preview "$2"; exit 0 ;;
  --close) shift; close "$@"; exit 0 ;;
  --status) status; exit 0 ;;
  '') ;;
  *)
    target="$(list_targets | fzf --filter="$*" --no-sort --ansi \
      --delimiter '\t' --nth 2 --accept-nth 1 | head -1)"
    [ -z "$target" ] || connect "$target"
    exit 0
    ;;
esac

# A popup already has herdr's frame and title; elsewhere fzf draws its own.
if [ -n "${HERDR_PLUGIN_ENTRYPOINT_ID:-}" ]; then
  chrome=(--border=none)
else
  chrome=(--border=rounded --border-label ' Workspaces ')
fi

HERDR_PICKER_CACHE="$(mktemp "${TMPDIR:-/tmp}/herdr-picker.XXXXXX")"
export HERDR_PICKER_CACHE
errors="$HERDR_PICKER_CACHE.err"
trap 'rm -f "$HERDR_PICKER_CACHE" "$errors"' EXIT

# fzf runs bindings through $SHELL; the environment carries the script path
# past whatever quoting that shell uses.
export HERDR_PICKER_SELF="$self"

selection="$(
  list_targets | fzf --multi --no-sort --ansi --prompt '> ' "${chrome[@]}" \
    --delimiter '\t' --with-nth 2 --accept-nth 1 \
    --header "$header" --expect=ctrl-r \
    --bind 'ctrl-x:execute-silent(bash "$HERDR_PICKER_SELF" --close {+1})+reload(bash "$HERDR_PICKER_SELF" --list)+transform-header(bash "$HERDR_PICKER_SELF" --status)' \
    --preview-window 'right:55%' \
    --preview 'bash "$HERDR_PICKER_SELF" --preview {1}'
)" || exit 0

key="$(sed -n 1p <<<"$selection")"
target="$(sed -n 2p <<<"$selection")"
[ -n "$target" ] || exit 0

if [ "$key" = ctrl-r ]; then
  case "$target" in
    /*)
      label="$(prompt_label "$(basename "$target")" 'new workspace')" || exit 0
      [ -z "$label" ] || connect "$target" "$label"
      ;;
    *)
      old="$(cached_snapshot | jq -r --arg id "$target" '.workspaces[] | select(.workspace_id == $id) | .label')"
      label="$(prompt_label "$old" 'rename workspace')" || exit 0
      [ -z "$label" ] || [ "$label" = "$old" ] || run workspace rename "$target" -- "$label"
      ;;
  esac
else
  connect "$target"
fi
