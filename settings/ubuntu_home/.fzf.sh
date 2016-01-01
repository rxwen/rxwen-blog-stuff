
# fgit-log - git commit browser (enter for show, ctrl-d for diff)
fgit-log() {
  local out shas sha q k
  while out=$(
      git log --graph --color=always \
          --format="%C(auto)%h%d %s %C(black)%C(bold)%cr" "$@" |
      fzf --ansi --multi --no-sort --reverse --query="$q" \
          --print-query --expect=ctrl-d); do
    q=$(head -1 <<< "$out")
    k=$(head -2 <<< "$out" | tail -1)
    shas=$(sed '1,2d;s/^[^a-z0-9]*//;/^$/d' <<< "$out" | awk '{print $1}')
    [ -z "$shas" ] && continue
    if [ "$k" = ctrl-d ]; then
      git diff --color=always $shas | less -R
    else
      for sha in $shas; do
        git show --color=always $sha | less -R
      done
    fi
  done
}

# fgit-reflog - checkout git reflog
fgit-reflog() {
    local reflogs sha
    reflogs=$(git reflog) &&
        sha=$(echo "$reflogs" | fzf --tac +s +m -e) &&
        git checkout $(echo "$sha" | sed "s/ .*//")
}

# fgit-branch - checkout git branch (including remote branches)
fgit-branch() {
    local branches branch
    branches=$(git branch --all | grep -v HEAD) &&
        branch=$(echo "$branches" |
    fzf -d $(( 2 + $(wc -l <<< "$branches") )) +m) &&
        git checkout $(echo "$branch" | sed "s/.* //" | sed "s#remotes/[^/]*/##")
}

# fgit-switch - checkout git
fgit-tag() {
    local tags target
    tags=$(
    git tag | awk '{print "\x1b[31;1mtag\x1b[m\t" $1}') || return
    target=$(
    (echo "$tags"; echo "$branches") |
    fzf --no-hscroll --ansi +m -d "\t" -n 2) || return
    git checkout $(echo "$target" | awk '{print $2}')
}

# fgit-show - git commit browser
fgit-show() {
    git log --graph --color=always \
        --format="%C(auto)%h%d %s %C(black)%C(bold)%cr" "$@" |
    fzf --ansi --no-sort --reverse --tiebreak=index --bind=ctrl-s:toggle-sort \
        --bind "ctrl-m:execute:
    (grep -o '[a-f0-9]\{7\}' | head -1 |
    xargs -I % sh -c 'git show --color=always % | less -R') << 'FZF-EOF'
    {}
    FZF-EOF"
}

# fgit-stash - easier way to deal with stashes
# type fstash to get a list of your stashes
# enter shows you the contents of the stash
# ctrl-d shows a diff of the stash against your current HEAD
# ctrl-b checks the stash out as a branch, for easier merging
fgit-stash() {
    local out q k sha
    while out=$(
        git stash list --pretty="%C(yellow)%h %>(14)%Cgreen%cr %C(blue)%gs" |
        fzf --ansi --no-sort --query="$q" --print-query \
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

# Modified version where you can press
#   - CTRL-O to open with `open` command,
#   - CTRL-E or Enter key to open with the $EDITOR
fo() {
    local out file key
    out=$(fzf --query="$1" --exit-0 --expect=ctrl-o,ctrl-e)
    key=$(head -1 <<< "$out")
    file=$(head -2 <<< "$out" | tail -1)
    if [ -n "$file" ]; then
        [ "$key" = ctrl-o ] && open "$file" || ${EDITOR:-vim} "$file"
    fi
}

# fs [FUZZY PATTERN] - Select selected tmux session
#   - Bypass fuzzy finder if there's only one match (--select-1)
#   - Exit if there's no match (--exit-0)
fs() {
    local session
    session=$(tmux list-sessions -F "#{session_name}" | \
        fzf --query="$1" --select-1 --exit-0) &&
        tmux switch-client -t "$session"
}

# ftpane - switch pane
ftpane () {
    local panes current_window target target_window target_pane
    panes=$(tmux list-panes -s -F '#I:#P - #{pane_current_path} #{pane_current_command}')
    current_window=$(tmux display-message  -p '#I')

    target=$(echo "$panes" | fzf-tmux) || return

    target_window=$(echo $target | awk 'BEGIN{FS=":|-"} {print$1}')
    target_pane=$(echo $target | awk 'BEGIN{FS=":|-"} {print$2}' | cut -c 1)

    if [[ $current_window -eq $target_window ]]; then
        tmux select-pane -t ${target_window}.${target_pane}
    else
        tmux select-pane -t ${target_window}.${target_pane} &&
            tmux select-window -t $target_window
    fi
}

