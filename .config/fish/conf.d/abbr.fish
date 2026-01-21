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
    abbr vi nvim
    abbr vim nvim
else
    abbr vi vim
end

# tmux
abbr -a t tmux
abbr -a tt tmux attach \|\| tmux
abbr -a ta tmux attach

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
abbr -a gC git checkout
abbr -a gr git reset
abbr -a gco git checkout
abbr -a gb git branch
abbr -a gbd git branch -d

# Lazygit
type -q lazygit; and abbr -a lg lazygit

# python
abbr -a py python
abbr -a pipl pip list
abbr -a pipi pip install
abbr -a pipir pip install -r requirements.txt
abbr -a pipsh pip show
abbr -a pipsr pip search
abbr -a pipfr pip freeze
abbr -a --set-cursor tsb tensorboard --logdir=%

# docker
if type -q docker
    abbr -a d docker
    abbr -a dps docker ps
    abbr -a dpsa docker ps -a
    abbr -a dil docker images
    abbr -a de docker exec it
    abbr -a dstop docker stop
    abbr -a drm docker rm
    abbr -a drmi docker rmi
    abbr -a dlogs docker logs -f
    abbr -a dcleanc docker rm $(docker ps -a -q)
    abbr -a dcleani docker rmi $(docker images -q)
    abbr -a dprune docker system prune
end

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

# opencode
if type -q opencode
    abbr -a oc opencode
end
