export DISPLAY=:0.0

source /usr/share/bash-completion/bash_completion
source /usr/share/nvm/init-nvm.sh

export PATH=$PATH:/usr/bin/core_perl:~/.bin
# Save and reload the history after each command finishes
export PROMPT_COMMAND="history -a; history -c; history -r; $PROMPT_COMMAND"

# Probably should go in login shell, but yolo
xmodmap ~/.Xmodmap
