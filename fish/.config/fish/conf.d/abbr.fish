abbr -a lsl ls -l
abbr -a ls1 ls -1
abbr -a lsa ls -a
abbr -a lsal ls -al

abbr -a rmr rm -r
abbr -a rmrf rm -rf

abbr -a rs rsync -avh

# vim
abbr vi nvim
abbr vim nvim

# tmux
abbr -a t tmux
abbr -a ta tmux attach

# vscode
abbr -a co code

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

# homebrew
abbr -a bi brew install
abbr -a bu brew uninstall
abbr -a buz brew uninstall --zap
abbr -a bl brew list
abbr -a bup brew update
abbr -a bupg brew upgrade

# Lazygit
abbr -a lg lazygit

# conda
abbr -a ca conda activate
abbr -a cda conda deactivate
abbr -a ci conda install
abbr -a ccr conda create
abbr -a ce conda env
abbr -a cee conda env export
abbr -a cec conda env create
abbr -a cer conda env remove
abbr -a cel conda env list
abbr -a cl conda list
abbr -a cr conda remove
abbr -a clc condalocal

# python
abbr -a py python
abbr -a pipl pip list
abbr -a pipi pip install
abbr -a pipir pip install -r requirements.txt
abbr -a pipsh pip show
abbr -a pipsr pip search
abbr -a pipfr pip freeze
abbr -a jl jupyter-lab
abbr -a --set-cursor tsb tensorboard --logdir=%

# mutagen
abbr -a msc mutagen sync create
abbr -a msl mutagen sync list
abbr -a msll mutagen sync list --long
abbr -a msm mutagen sync monitor
abbr -a msf mutagen sync flush
abbr -a msp mutagen sync pause
abbr -a mspa mutagen sync pause --all
abbr -a msr mutagen sync resume
abbr -a msra mutagen sync resume --all
abbr -a msrs mutagen sync reset
abbr -a mst mutagen sync terminate
