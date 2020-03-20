# fshow - git commit browser
fshow() {
    git log --graph --color=always \
        --format="%C(auto)%h%d %s %C(black)%C(bold)%cr" "$@" |
        fzf --ansi --no-sort --reverse --tiebreak=index --bind=ctrl-s:toggle-sort \
        --bind "ctrl-m:execute:
            (grep -o '[a-f0-9]\{7\}' | head -1 |
                xargs -I % sh -c 'git show --color=always % | less -R') << 'FZF-EOF'
                            {}
                            FZF-EOF"
                        }

# fbr - checkout git branch (including remote branches), sorted by most recent commit, limit last 100 branches
fbr() {
    local branches branch
    branches=$(git for-each-ref --count=100 --sort=-committerdate refs/heads/ --format="%(refname:short)") &&
        branch=$(echo "$branches" |
        fzf -d $(( 2 + $(wc -l <<< "$branches") )) +m) &&
        git checkout $(echo "$branch" | sed "s/.* //" | sed "s#remotes/[^/]*/##")
    }

# Make this a function to checkout remote branch
frbr() {
    remote_branch=`git b -r | fzf | awk '{print $1}'`
    if [[ ! -z "$remote_branch" ]]
    then
        git checkout $(echo $remote_branch | sed 's/origin\///g')
    fi
}

search() {
    words=$@
    search_file=`ag --hidden --ignore-dir .git --column --color --color-line-number "49;32" --color-match "1;49;91" --color-path "49;95" --pager="fzf --ansi --exit-0 --delimiter=: --preview-window=up:70% --preview 'bat --color=always --line-range {2}: {1}'" --no-break --no-heading -Q "$words"`
    if [[ ! -z "$search_file" ]]
    then
        line=`echo $search_file | awk '{print $1}'`
        line_number=`echo $search_file | awk -F: '{print $2}'`
        match_column=`echo $search_file | awk -F: '{print $3}'`
        file_name=`echo $search_file | awk -F: '{print $1}'`

        nvim -c "/$words" "+call cursor($line_number, $match_column)" "$file_name" && search $words
    fi
}

wsearch() {
    words=$@
    search_file=`ag -u --column --color --color-line-number "49;32" --color-match "1;49;91" --color-path "49;95" --pager="fzf --ansi --exit-0 --delimiter=: --preview-window=up:70% --preview 'bat --color=always --line-range {2}: {1}'" --no-break --no-heading -Q "$words"`
    if [[ ! -z "$search_file" ]]
    then
        line=`echo $search_file | awk '{print $1}'`
        line_number=`echo $search_file | awk -F: '{print $2}'`
        match_column=`echo $search_file | awk -F: '{print $3}'`
        file_name=`echo $search_file | awk -F: '{print $1}'`

        nvim -c "/$words" "+call cursor($line_number, $match_column)" "$file_name" && search $words
    fi
}

vfzf() {
    if [[ ! -z "$1" ]]
    then
        if [[ ! -z "$2" ]]
        then
            if [[ "$2" -eq "dist" ]]
            then
                find_files=`find -E . -type f -iregex ".*(dist-server|dist)\/+.*${1}.*" -not -path '*/node_modules/*' -not -path '*/.git/*' `
                echo $find_files
                files=`echo -e "$find_files" | fzf -m -1`
            fi
        else
            find_files=`find . -type f -iregex ".*${1}.*" -not -path '*/node_modules/*' -not -path '*/.git/*' -not -path '*/dist/*' -not -path '*/dist-server/*' `
            files=`echo -e "$find_files" | fzf -m -1`
        fi
    else
        files=`fzf -m`
    fi

    if [[ ! -z "${files// /\\ }" ]]
    then
        file_count=`echo "$find_files" | wc -l`
        eval vim -O ${files// /\\ }
        if [[ $file_count -gt 1 ]]
        then
            vfzf $1 $2
        fi
    fi
}

printLog() {
    jq '. | .msg |= split("\n") | .err.stack |= split("\n")'
}

# Select a running docker container to stop
dr() {
    local cid
    cid=$(docker ps | sed 1d | fzf -q "$1" | awk '{print $1}')

    [ -n "$cid" ] && docker-compose restart "$cid"
}

dc() {
    compose_file="docker-compose.yml"
    echo "docker-compose $@"
}

#lpass show -c --password $(lpass ls  | fzf | awk '{print $(NF)}' | sed 's/\]//g')

export -f dc
export -f printLog
export -f fshow
export -f vfzf
export -f fbr
export -f frbr
export -f dr
export -f search
