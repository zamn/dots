export DISPLAY=:0.0

source /usr/share/bash-completion/bash_completion
source /usr/share/nvm/init-nvm.sh

has_keychain=`which keychain >/dev/null; echo $?`
if [[ "$has_keychain" -eq 0 ]]
then
    WORK_GPG_KEY=$(grep "signingkey" ~/work/.gitconfig | awk -F= '{print $2}')
    CODE_GPG_KEY=$(grep "signingkey" ~/code/.gitconfig | awk -F= '{print $2}')
    echo $WORK_GPG_KEY $CODE_GPG_KEY
    eval `keychain -q --eval --nogui -Q --gpg2 --eval id_rsa --agents ssh,gpg $WORK_GPG_KEY $CODE_GPG_KEY`
fi

export PATH=$PATH:/usr/bin/core_perl:~/.bin
# Save and reload the history after each command finishes
export PROMPT_COMMAND="history -a; history -c; history -r; $PROMPT_COMMAND"

mm_vpn() {
    if [[ "$1" = "d" ]]
    then
        ssh mac /opt/cisco/anyconnect/bin/vpn disconnect
    else
        ssh mac /opt/cisco/anyconnect/bin/vpn connect "$VPN"
    fi
}

export -f mm_vpn

# Probably should go in login shell, but yolo
xmodmap ~/.Xmodmap
