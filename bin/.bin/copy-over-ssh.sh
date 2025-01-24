#!/bin/bash

cmd="pbcopy"
host_arch=$(uname)
#if over ssh

# curr_connection=$(w -ih | tail -1 | awk '{print $2}')

echo $SSH_CONNECTION
# Local
if [[ -z $SSH_CONNECTION ]]
then
    cmd="pbcopy"
elif [[ -n "$TMUX" ]]
then
    export DISPLAY="$(tmux show-env | sed -n 's/^DISPLAY=//p')"
    cmd="xclip -select clipboard"
elif [[ "$host_arch" -eq "Linux" ]]
then
    cmd="xclip -select clipboard"
fi

if [[ $# -ge 1 ]]; then
    input="$*"
else
    input=$(cat)
fi

echo $cmd
echo -n "$input" | eval $cmd
