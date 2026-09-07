# tools

Home-grown Go tools. Each `tools/<name>/` holds a Go module plus a `<name>`
shim that `mise.toml` links into `~/.local/bin`. The shim builds the module
into `~/.cache/<name>/` on first run and again whenever a source file changes,
so there is no separate build step: edit, run, done.

## pf

SSH port-forward manager. `pf` opens the TUI; the CLI form is for scripting.

```sh
pf                          # TUI
pf devbox 5432              # localhost:5432 -> devbox:5432
pf devbox 8080 3000         # localhost:8080 -> devbox:3000
pf list | close <id> | restart <id> | logs <id>
```

Each tunnel is a detached `pf _supervise <id>` process running `ssh -N`; it
reconnects with backoff and keeps `~/.local/state/pf/<id>.json` current.
Tunnels outlive the TUI. `PF_SSH_ARGS` adds options to every ssh call
(e.g. `-F ~/alt/config`).
