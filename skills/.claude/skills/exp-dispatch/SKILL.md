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
3. **Name** — window names are coarse: lowercase, dash-separated, 2–3 tokens, ≤~20 chars (`train-resnet`, `sweep-lr`); `-2` on collision. Every pane gets a title carrying the detailed identity (`lr1e-3-seed0`) — solo runs too, so a later `join-pane` or grouping never leaves an unlabeled run. The run id — `<window>`, or `<window>--<pane-title>` when grouped — names the files in `~/.cache/exp-dispatch/`. The window name ends in a status suffix (no space) — `*` running, `!` at least one failure, bare name when all runs exit 0: dispatch sets `*`; the bundled `finish.sh` re-aggregates it and rings the terminal bell as each run exits.
4. **Env** — create panes with `-c <project-dir>`; prefer self-contained runner commands (`uv run …`), else explicit venv activation inside the command. Verify the env story before dispatching. The command line below is typed into the pane's interactive shell — phrase it in that shell's syntax (last exit status is `$?` in POSIX shells/zsh, `$status` in fish).
5. **Create the pane** — clear any stale status for a reused run id, create the pane as a plain interactive shell (no command argument — the command is typed in via `send-keys` in step 6, so it sits in scrollback and the user can scroll up to see what ran), and capture the pane ID. `-d` keeps the user's view where it is — never dispatch without it:

   ```sh
   mkdir -p ~/.cache/exp-dispatch && rm -f ~/.cache/exp-dispatch/<run>.status
   pane=$(tmux new-window -d -t <session> -n '<name>*' -c <dir> -P -F '#{pane_id}')
   tmux set -w -t "$pane" pane-border-status top
   ```

   Grouped run — split the existing window instead, targeting it by a sibling run's pane ID (window names mutate as symbols flip — never target by name):

   ```sh
   pane=$(tmux split-window -d -t "$sibling" -c <dir> -P -F '#{pane_id}')
   tmux select-layout -t "$sibling" tiled
   tmux rename-window -t "$sibling" '<name>*'  # window may sit settled (bare/!); the new run flips it back
   ```

6. **Log, tag, title, meta — then launch** — all in the same Bash call as pane creation. Pipe-pane attaches before the command is sent, so the log captures the run from the typed command line onward. The command carries its exit epilogue via `finish.sh` (banner, status file, window symbol, bell); when it exits the pane drops back to the shell prompt, scrollback intact:

   ```sh
   tmux pipe-pane -o -t "$pane" 'cat >> ~/.cache/exp-dispatch/<run>.log'  # keeps the tty, so tqdm/rich render normally
   tmux set -p -t "$pane" @exp-dispatch <run>
   tmux select-pane -t "$pane" -T '<pane-title>'
   printf 'pane=%s\ncmd=%s\nstart=%s\n' "$pane" '<cmd>' "$(date -Iseconds)" > ~/.cache/exp-dispatch/<run>.meta
   tmux send-keys -t "$pane" -l '<cmd>; sh ~/.claude/skills/exp-dispatch/finish.sh <run> $?'  # $status in fish
   tmux send-keys -t "$pane" Enter
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

## Follow-ups

After a run finishes, its pane is a live shell sitting in the run's cwd — run follow-up commands there (when the next step needs it, or on request) rather than in a fresh Bash session:

```sh
tmux send-keys -t "$pane" -l '<cmd>'; tmux send-keys -t "$pane" Enter
tmux capture-pane -p -t "$pane" | tail   # read the result; pipe-pane still appends it to the log
```

- Gate on `<run>.status` existing — before that, send-keys types into the running job's stdin.
- The pane shell is the user's interactive shell, whatever that is: keep commands shell-portable, or wrap in `sh -c '…'`.
- A follow-up that is itself a long run (retrain, next sweep stage) is a new dispatch, not send-keys.

## Remote runs

Use `ssh host '<cmd>'` as the command inside the pane — everything above is unchanged. Caveat to surface: a dropped ssh kills the remote job unless the user's remote setup handles it.

## Lifecycle

Experiment windows belong to the user: leave them alive even after success. On an explicit cleanup request, kill exit-0 windows and ask about failed ones. Cache files stay untouched except the stale-status removal at re-dispatch.
