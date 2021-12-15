export DISPLAY=:0.0

source /usr/share/bash-completion/bash_completion
source /usr/share/nvm/init-nvm.sh

export PATH=$PATH:/usr/bin/core_perl:~/.bin
# Save and reload the history after each command finishes
export PROMPT_COMMAND="history -a; history -c; history -r; $PROMPT_COMMAND"

mm_vpn() {
    if [[ "$1" = "d" ]]
    then
        ssh -o ServerAliveInterval=2 -o ServerAliveCountMax=1 mac /opt/cisco/anyconnect/bin/vpn disconnect
    else
        ssh -o ServerAliveInterval=2 -o ServerAliveCountMax=1 mac /opt/cisco/anyconnect/bin/vpn connect "$VPN"
    fi

}

export -f mm_vpn

# Probably should go in login shell, but yolo
xmodmap ~/.Xmodmap
