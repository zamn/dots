have() {
    which $1 2>&1 >/dev/null
    return `echo $?`
}

export -f have

rlpsql() {
    rlwrap --always-readline -N psql "$@"
    return
}
export -f rlpsql

# Needed to have gitlab creds persisted
export PERLLIB=/Library/Developer/CommandLineTools/usr/share/git-core/perl:$PERLLIB

alias firefox="open -a /Applications/Firefox.app"

if [[ -f ~/.homebrew.bash ]]
then
    source ~/.homebrew.bash
fi

[[ -r "/usr/local/etc/profile.d/bash_completion.sh" ]] && . "/usr/local/etc/profile.d/bash_completion.sh"

if [[ -d /usr/local/etc/bash_completion.d/ ]]
then
    for f in /usr/local/etc/bash_completion.d/*; do
        . $f 2>/dev/null
    done
fi

alias kitty='/Applications/kitty.app/Contents/MacOS/kitty'

export NVM_DIR="$HOME/.nvm"

export NVM_DIR="$HOME/.nvm"
  [ -s "/opt/homebrew/opt/nvm/nvm.sh" ] && . "/opt/homebrew/opt/nvm/nvm.sh"  # This loads nvm
  [ -s "/opt/homebrew/opt/nvm/etc/bash_completion.d/nvm" ] && . "/opt/homebrew/opt/nvm/etc/bash_completion.d/nvm"  # This loads nvm bash_completion

export GPG_TTY=$(tty)

export LANG=en_US.UTF-8
export LC_ALL=en_US.UTF-8
unset LC_COLLATE
unset LC_CTYPE
unset LC_MESSAGES
unset LC_MONETARY
unset LC_NUMERIC
unset LC_TIME

if [[ -n "$TMUX" ]]
then
    export DISPLAY="$(tmux show-env | sed -n 's/^DISPLAY=//p')"
fi

export PATH="/usr/local/opt/libpq/bin:$PATH"

alias ls="ls -GF"

alias fix_keychain="security -v unlock-keychain ~/Library/Keychains/login.keychain-db"
eval "$(/opt/homebrew/bin/brew shellenv)"
