have() {
    which $1 2>&1 >/dev/null
    return `echo $?`
}

export -f have

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

[ -s "/usr/local/opt/nvm/nvm.sh" ] && . "/usr/local/opt/nvm/nvm.sh"  # This loads nvm
[ -s "/usr/local/opt/nvm/etc/bash_completion" ] && . "/usr/local/opt/nvm/etc/bash_completion"  # This loads nvm bash_completion

export GPG_TTY=$(tty)
