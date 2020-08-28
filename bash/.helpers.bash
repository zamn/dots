alias glNoGraph='git log --color=always --format="%C(auto)%h%d %s %C(black)%C(bold)%cr% C(auto)%an" "$@"'
_gitLogLineToHash="echo {} | grep -o '[a-f0-9]\{7\}' | head -1"
_viewGitLogLine="$_gitLogLineToHash | xargs -I % sh -c 'git show --color=always % | diff-so-fancy'"

# fshow - git commit browser w/ preview
fshow() {
    glNoGraph |
        fzf --no-sort --reverse --tiebreak=index --no-multi \
            --ansi --preview="$_viewGitLogLine" \
                --header "enter to view, alt-y to copy hash" \
                --bind "enter:execute:$_viewGitLogLine   | less -R" \
                --bind "alt-y:execute:$_gitLogLineToHash | xclip -select clipboard"
}

_viewGitStash="git stash show --color=always -p {1}"
fstash() {
  local out q k sha
  while out=$(
    git stash list --pretty="%C(yellow)%h %>(14)%Cgreen%cr %C(blue)%gs" |
    fzf --ansi --preview="$_viewGitStash" --no-sort --query="$q" --print-query \
        --expect=ctrl-d,ctrl-b);
  do
    mapfile -t out <<< "$out"
    q="${out[0]}"
    k="${out[1]}"
    sha="${out[-1]}"
    sha="${sha%% *}"
    [[ -z "$sha" ]] && continue
    if [[ "$k" == 'ctrl-d' ]]; then
      git diff $sha
    elif [[ "$k" == 'ctrl-b' ]]; then
      git stash branch "stash-$sha" $sha
      break;
    else
      git stash show -p $sha
    fi
  done
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

_openGitBlame="$_gitLogLineToHash | xargs -I % sh -c 'xdg-open \"$(git remote get-url origin | sed 's/\.git$//g' | sed 's/:/\//g' | sed 's/git\@/https\:\/\//g')/commit/%\"'"

fblame() {
    f=$1
    shift
    csha=""
    { git log --color=always --pretty=format:%H -- "$f"; echo; } | {
        while read hash; do
            res=$(git blame --color-by-age -L"/$1/",+1 $hash -- "$f" 2>/dev/null | sed 's/^//')
            # my attempt to color.. TODO
            #res=$(git --no-pager blame -L"/$1/",+1 $hash -- $f | awk '{print $1}' | xargs git --no-pager log -1 --pretty=format:"%C(auto)%h%d %s %C(black)%C(bold)%cr% C(auto)%an" --date=relative)
            sha=${res%% (*}
            if [[ "${res}" != "" && "${csha}" != "${sha}" ]]; then
                #echo "${hash}" # i dont actually need this - looks like it just points to parent commit
                echo "${res}"
                csha="${sha}"
            fi
        done
    } | fzf --no-sort --no-multi \
            --ansi --preview="$_viewGitLogLine" \
                --header "enter to view, alt-y to copy hash" \
                --bind "enter:execute:$_viewGitLogLine   | less -R" \
                --bind "alt-y:execute:$_gitLogLineToHash | xclip -select clipboard" \
                --bind "alt-o:execute:$_openGitBlame"
}

search() {
    if [[ -n "$QUERY" ]]
    then
        pager="fzf -q $QUERY --print-query --ansi --exit-0 --delimiter=: --preview-window=up:70% --preview 'bat --color=always --line-range {2}: {1}'"
    else
        pager="fzf --print-query --ansi --exit-0 --delimiter=: --preview-window=up:70% --preview 'bat --color=always --line-range {2}: {1}'"
    fi
    words=$@
    search_file=`ag --hidden --ignore-dir .git --column --color --color-line-number "49;32" --color-match "1;49;91" --color-path "49;95" --pager="$pager" --no-break --no-heading -Q "$words"`
    query=$(echo "$search_file" | head -1)
    search_result=$(echo "$search_file" | tail -1)
    if [[ ! -z "$search_file" ]]
    then
        line=`echo $search_result | awk '{print $1}'`
        line_number=`echo $search_result | awk -F: '{print $2}'`
        match_column=`echo $search_result | awk -F: '{print $3}'`
        file_name=`echo $search_result | awk -F: '{print $1}'`

        nvim -c "/$words" "+call cursor($line_number, $match_column)" "$file_name" \
            && QUERY="$query" search $words
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

msearch() {
    words=$@
    search_file=`ag --column --color --color-line-number "49;32" --color-match "1;49;91" --color-path "49;95" --pager="fzf -m --ansi --exit-0 --delimiter=: --preview-window=up:70% --preview 'bat --color=always --line-range {2}: {1}'" --no-break --no-heading -Q "$words"`
    if [[ ! -z "$search_file" ]]
    then
        file_name=`echo $search_file | awk -F: '{print $1}'`

        nvim -O -c "/$words" "$file_name" && search $words
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
