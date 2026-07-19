---
name: exp-dispatch
description: Dispatch long-running ML workloads (training, benchmarks, sweeps, data preprocessing) into tmux windows and monitor them. Use when about to start a long-running ML job — dispatch by default instead of running it in Bash — or when the user asks to check on their runs.
user-invocable: false
---

# exp-dispatch

Run long ML jobs in tmux panes the user can watch while you monitor from outside. Two invariants govern everything below: a run's canonical identity is its **pane ID** (`%N`), and its **status file** is the source of truth for completion.

Scope: ML workloads only — training, benchmarks, sweeps, data preprocessing. Quick scripts and tests stay in plain Bash.

## Dispatch

1. **Target session** — the session you're attached to; else the first attached one (`tmux list-clients -F '#{session_name}'`); else create one.
2. **Group or new window** — runs from the same sweep/config family share one window as panes, capped at 4; the 5th starts window `<name>-2`. Unrelated runs get their own window; when unsure, new window.
3. **Name** — window names are coarse: lowercase, dash-separated, 2–3 tokens, ≤~20 chars (`train-resnet`, `sweep-lr`); `-2` on collision. The pane title carries the detailed identity (`lr1e-3-seed0`). The run id — `<window>`, or `<window>--<pane-title>` when grouped — names the files in `~/.cache/exp-dispatch/`.
4. **Env** — create panes with `-c <project-dir>`; prefer self-contained runner commands (`uv run …`), else explicit venv activation inside the command. Verify the env story before dispatching. The wrapper below runs under POSIX `sh` (tmux's command shell).
5. **Create the pane** — clear any stale status for a reused run id, wrap the command so the pane survives the run (exit banner, status file, then a live interactive shell with full scrollback), and capture the pane ID:

   ```sh
   mkdir -p ~/.cache/exp-dispatch && rm -f ~/.cache/exp-dispatch/<run>.status
   wrap='<cmd>; st=$?; printf "\n── exp-dispatch: exit %s ──\n" "$st"; echo "$st" > ~/.cache/exp-dispatch/<run>.status; exec "${SHELL:-sh}"'
   pane=$(tmux new-window -t <session> -n <name> -c <dir> -P -F '#{pane_id}' "$wrap")
   ```

   Grouped run — split the existing window instead:

   ```sh
   pane=$(tmux split-window -t <window> -c <dir> -P -F '#{pane_id}' "$wrap")
   tmux select-layout -t <window> tiled
   tmux set -w -t <window> pane-border-status top
   ```

6. **Tag, title, log, meta**:

   ```sh
   tmux set -p -t "$pane" @exp-dispatch <run>
   tmux select-pane -t "$pane" -T '<pane-title>'
   tmux pipe-pane -o -t "$pane" 'cat >> ~/.cache/exp-dispatch/<run>.log'  # keeps the tty, so tqdm/rich render normally
   printf 'pane=%s\ncmd=%s\nstart=%s\n' "$pane" '<cmd>' "$(date -Iseconds)" > ~/.cache/exp-dispatch/<run>.meta
   ```

7. **Watcher** — best-effort background completion watch via Bash `run_in_background`: `while [ ! -f ~/.cache/exp-dispatch/<run>.status ]; do sleep 60; done; cat <run>.status`. For multi-hour runs the session may end first; a later session resumes from status files + `capture-pane`.

Address panes only by `$pane` (`%N`), never `window.pane` indexes — the user may then freely `break-pane`, `join-pane`, and rename without breaking monitoring; mention that this is safe if they reorganize.

## Check on runs

"What's running?" overview:

```sh
tmux list-panes -a -f '#{@exp-dispatch}' -F '#{pane_id} #{@exp-dispatch} #{window_name} #{pane_title}'
```

Cross-reference with `~/.cache/exp-dispatch/*.status`; report per run: name, running / finished (exit code), one-line progress.

- Progress peek: `tmux capture-pane -p -t "$pane" | tail`. A shell prompt in the pane means the wrapper finished, not that the run succeeded — the status file has the exit code.
- Idle anomaly peeks: occasionally scan captured output for NaN losses, CUDA OOM, stalled progress.

## Remote runs

Use `ssh host '<cmd>'` as the command inside the pane — everything above is unchanged. Caveat to surface: a dropped ssh kills the remote job unless the user's remote setup handles it.

## Lifecycle

Experiment windows belong to the user: leave them alive even after success. On an explicit cleanup request, kill exit-0 windows and ask about failed ones. Cache files stay untouched except the stale-status removal at re-dispatch.
