# Dotfiles — managed with GNU Stow. Run `just` to see recipes.
#
# Each top-level dir is a Stow "package" whose tree mirrors into $HOME.
# Stow runs from this dir, so its default target is the parent — exactly $HOME.

# All packages, in link order. Add new package dirs here.
packages := "atuin bat bin claude eza fish git lazygit mise nvim ruff sesh shell tmux"

# Packages whose config dir also accumulates runtime/generated files — fisher
# plugins, TPM plugins, nvim plugin/spell/, live ~/.claude state. These are
# stowed with --no-folding so the directory stays REAL and those files never
# land in the repo. Everything else folds normally (one symlink per package).
nofold := "claude fish nvim tmux"

_default:
    @just --list --unsorted

# Symlink packages into $HOME (default: all). e.g. `just link nvim tmux`
link *pkgs=packages:
    @just _apply "" "{{pkgs}}"

# Re-link after renaming/removing tracked files (default: all)
relink *pkgs=packages:
    @just _apply "--restow" "{{pkgs}}"

# Remove symlinks for packages (default: all)
unlink *pkgs=packages:
    @just _apply "--delete" "{{pkgs}}"

# Dry-run — show what would change without touching anything (default: all)
check *pkgs=packages:
    @just _apply "--no" "{{pkgs}}"

# Adopt existing $HOME files into the repo, then symlink back (migration aid)
adopt *pkgs=packages:
    @just _apply "--adopt" "{{pkgs}}"

# Remove dead symlinks pointing into this repo (default: scan $HOME). e.g. `just prune ~/.config`
prune dir='':
    @just _prune "" "{{dir}}"

# Dry-run prune — list dead symlinks without deleting (default: scan $HOME)
prune-check dir='':
    @just _prune "--no" "{{dir}}"

# List user skills installed in ~/.claude that aren't tracked in the repo yet
new-skills:
    #!/usr/bin/env bash
    set -euo pipefail
    for d in "$HOME"/.claude/skills/*/; do
      name=$(basename "$d")
      [ -e "claude/.claude/skills/$name" ] && continue   # already tracked
      [ -L "${d%/}" ] && continue                        # upstream symlink (e.g. skill-creator)
      [ -f "$d/SKILL.md" ] || continue                   # only real skills
      echo "$name"
    done

# Move a newly-installed user skill into the repo, then symlink it back
adopt-skill name:
    #!/usr/bin/env bash
    set -euo pipefail
    src="$HOME/.claude/skills/{{name}}"
    dst="claude/.claude/skills/{{name}}"
    [ -e "$dst" ] && { echo "already tracked: $dst"; exit 1; }
    [ -d "$src" ] || { echo "no such skill: $src"; exit 1; }
    mv "$src" "$dst"
    just relink claude
    echo "Adopted {{name}} — review then: git add $dst && git commit"

# Print this machine's Syncthing device ID (for pairing remotes)
sync-id:
    @syncthing device-id 2>/dev/null || echo "syncthing not installed/configured yet"

# Sync Homebrew packages from Brewfile
deps:
    brew bundle install

# First-time setup: Homebrew + Brewfile, then link everything
install: deps link

# internal: run `stow <action>` over each package, adding --no-folding for the
# packages listed in `nofold`. Folding (the stow default) is used otherwise.
_apply action pkgs:
    #!/usr/bin/env bash
    set -euo pipefail
    for p in {{pkgs}}; do
      fold=""
      case " {{nofold}} " in *" $p "*) fold="--no-folding" ;; esac
      stow --verbose {{action}} $fold "$p"
    done

# internal: find broken symlinks under <dir> (default $HOME) that point into this
# repo; delete them by default, or just list them (dry run) when mode=--no.
_prune mode dir:
    #!/usr/bin/env bash
    set -euo pipefail
    root="{{dir}}"; root="${root:-$HOME}"; root="${root%/}"
    repo=$(basename "$PWD")
    dead=()
    while IFS= read -r -d '' link; do
      tgt=$(readlink "$link")
      case "$tgt" in "$repo"/*|*/"$repo"/*) ;; *) continue ;; esac  # only our links
      [ -e "$link" ] || dead+=("$link")                            # target gone -> dead
    done < <(find "$root" \
        \( -name .git -o -name node_modules -o -name .cache \) -prune -o \
        -type l -print0 2>/dev/null)
    if [ ${#dead[@]} -eq 0 ]; then echo "✓ no dead links into $repo"; exit 0; fi
    printf '  %s\n' "${dead[@]}"
    if [ "{{mode}}" = "--no" ]; then
      echo "${#dead[@]} dead link(s) — run \`just prune\` to remove (empty parent dirs pruned too)"
      exit 0
    fi
    rm -- "${dead[@]}"
    # climb from each link's parent, rmdir'ing dirs that are now empty — rmdir
    # only deletes empties, so it self-limits; never past the scan root or $HOME.
    dirs=0
    for link in "${dead[@]}"; do
      d="${link%/*}"
      while [ "$d" != "$root" ] && [ "$d" != "$HOME" ] && [ "$d" != "/" ]; do
        rmdir "$d" 2>/dev/null || break
        dirs=$((dirs + 1)); d="${d%/*}"
      done
    done
    msg="removed ${#dead[@]} dead link(s)"
    [ "$dirs" -gt 0 ] && msg="$msg + $dirs empty dir(s)"
    echo "$msg"
