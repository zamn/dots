export NPM_TOKEN="171637df-8444-4890-85e7-981282aefcdb"
export DISPLAY=:0.0

source /usr/share/bash-completion/bash_completion
source /usr/share/nvm/init-nvm.sh

has_keychain=`which keychain >/dev/null; echo $?`
if [[ "$has_keychain" -eq 0 ]]
then
    eval `keychain -q --eval --nogui -Q --gpg2 --agents ssh,gpg id_rsa D3B8C24A953236FC494D32AF1E01FFA32EF916E0`
fi

export PATH=$PATH:/usr/bin/core_perl:~/.bin
