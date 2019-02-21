# ~/.bashrc: executed by bash(1) for non-login shells.
# see /usr/share/doc/bash/examples/startup-files (in the package bash-doc)
# for examples

# If not running interactively, don't do anything
case $- in
  *i*) ;;
  *) return;;
esac

# don't put duplicate lines or lines starting with space in the history.
# See bash(1) for more options
HISTCONTROL=ignoreboth

# append to the history file, don't overwrite it
shopt -s histappend

# for setting history length see HISTSIZE and HISTFILESIZE in bash(1)
HISTSIZE=1000
HISTFILESIZE=2000

# check the window size after each command and, if necessary,
# update the values of LINES and COLUMNS.
shopt -s checkwinsize

# If set, the pattern "**" used in a pathname expansion context will
# match all files and zero or more directories and subdirectories.
#shopt -s globstar


# Allow me to do !(file_I_want_to_skip)
shopt -s extglob

# make less more friendly for non-text input files, see lesspipe(1)
[ -x /usr/bin/lesspipe ] && eval "$(SHELL=/bin/sh lesspipe)"

# allow less to display some color
export LESS='-R'

# colored GCC warnings and errors
export GCC_COLORS='error=01;31:warning=01;35:note=01;36:caret=01;32:locus=01:quote=01'

# disable vim ctrl+s freeze terminal
stty -ixon

export TERM=xterm-256color
eval `keychain --nogui --eval --agents ssh,gpg --inherit any id_rsa 1DA873783B64AB1F`

PS1='\[\033[01;32m\]\u@\h\[\033[00m\]:\[\033[01;34m\]\w\[\033[00m\]\$ '

# enable color support of ls and also add handy aliases
if [ -x /usr/bin/dircolors ]; then
  test -r ~/.dircolors && eval "$(dircolors -b ~/.dircolors)" || eval "$(dircolors -b)"
  alias ls='ls --color=auto'

  alias grep='grep --color=auto'
  alias fgrep='fgrep --color=auto'
  alias egrep='egrep --color=auto'
fi

# some more ls aliases
alias ll='ls -alF'
alias la='ls -A'
alias l='ls -CF'

alias ag='ag --color-line-number "49;32" --color-match "1;49;91" --color-path "49;95"'
alias stripSlash="sed 's/[\]//g'"
alias node='env NODE_NO_READLINE=1 rlwrap node'
alias nodejs=node
export MOSH_ESCAPE_KEY=~
alias prettyxml='xmllint --format -'

# Use neovim for all teh things.. for now
alias vim=nvim

# Get all bash completions
if [[ -f /usr/share/bash-completion/completions/* ]]
then
  for f in /usr/share/bash-completion/completions/*; do
    source $f
  done
fi

set -o vi
export PATH=/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin:/usr/games:/usr/local/games:/usr/local/go/bin:/usr/local/go/bin
export GOPATH=$HOME/code/go
export GOROOT='/usr/lib/go'
export GOBIN=$GOPATH/bin

export PATH=$PATH:$GOROOT/bin:$GOBIN
export PATH=$PATH:/mnt/c/Windows/System32
export PATH=$PATH:./node_modules/.bin
export PATH=$PATH:$HOME/.local/bin
export EDITOR=vim
bind -m vi-insert "\C-l":clear-screen

export NVM_DIR="$HOME/.nvm"
[ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"  # This loads nvm
[ -s "$NVM_DIR/bash_completion" ] && \. "$NVM_DIR/bash_completion"  # This loads nvm bash_completion

[ -f ~/.fzf.bash ] && source ~/.fzf.bash
