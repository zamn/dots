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
        fzf-tmux -d $(( 2 + $(wc -l <<< "$branches") )) +m) &&
        git checkout $(echo "$branch" | sed "s/.* //" | sed "s#remotes/[^/]*/##")
    }

search() {
    search_file=`ag --column --color --color-line-number "49;32" --color-match "1;49;91" --color-path "49;95" --pager="fzf --ansi --exit-0 --delimiter=: --preview-window=up --preview 'bat --color=always --line-range {2}: {1}'" --no-break --no-heading -Q "$1"`
    if [[ ! -z "$search_file" ]]
    then
        line=`echo $search_file | awk '{print $1}'`
        line_number=`echo $search_file | awk -F: '{print $2}'`
        match_column=`echo $search_file | awk -F: '{print $3}'`
        file_name=`echo $search_file | awk -F: '{print $1}'`

        nvim -c "/$1" "+call cursor($line_number, $match_column)" "$file_name" && search $1
    fi
}

# Select a running docker container to stop
function dr() {
  local cid
  cid=$(docker ps | sed 1d | fzf -q "$1" | awk '{print $1}')

  [ -n "$cid" ] && docker-compose restart "$cid"
}

#lpass show -c --password $(lpass ls  | fzf | awk '{print $(NF)}' | sed 's/\]//g')

export -f fshow
export -f fbr
export -f dr
export -f search
