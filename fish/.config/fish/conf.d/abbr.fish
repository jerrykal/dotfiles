abbr -a lsl ls -l
abbr -a ls1 ls -1
abbr -a lsa ls -a
abbr -a lsal ls -al

abbr -a rmr rm -r
abbr -a rmrf rm -rf

abbr -a rs rsync -avh

abbr -a o open

# vim
if type -q nvim
    abbr v nvim
    abbr vi nvim
else
    abbr v vim
    abbr vi vim
end

# git
abbr -a g git
abbr -a gi git init
abbr -a ga git add
abbr -a gaa git add --all
abbr -a gc git commit -v
abbr -a gcm git commit -m
abbr -a gst git status
abbr -a gss git status -s
abbr -a gl git log
abbr -a glo git log --oneline
abbr -a gd git diff
abbr -a gds git diff --staged
abbr -a gls git ls-files
abbr -a gp git push
abbr -a grm git rm
abbr -a gr git reset
abbr -a gco git checkout
abbr -a gb git branch
abbr -a gbd git branch -d

# Lazygit
type -q lazygit; and abbr -a lg lazygit

# uv
if type -q uv
    abbr -a uvi uv init
    abbr -a uva uv add
    abbr -a uvs uv sync
    abbr -a uvl uv lock
    abbr -a uvr uv run
    abbr -a av source .venv/bin/activate.fish
    abbr -a da deactivate
end

# claude-code
if type -q claude
    abbr -a c claude
    abbr -a ca claude agents
end

# modem-dev/hunk
if type -q hunk
    abbr -a hd hunk diff
    abbr -a hds hunk diff --staged
end
