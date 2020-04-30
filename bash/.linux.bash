export DISPLAY=:0.0

source /usr/share/bash-completion/bash_completion
source /usr/share/nvm/init-nvm.sh

has_keychain=`which keychain >/dev/null; echo $?`
if [[ "$has_keychain" -eq 0 ]]
then
    WORK_GPG_KEY=$(grep "signingkey" ~/work/.gitconfig | awk -F= '{print $2}')
    CODE_GPG_KEY=$(grep "signingkey" ~/code/.gitconfig | awk -F= '{print $2}')
    eval `keychain -q --eval --nogui -Q --gpg2 --agents ssh,gpg $WORK_GPG_KEY $CODE_GPG_KEY`
fi

export PATH=$PATH:/usr/bin/core_perl:~/.bin
