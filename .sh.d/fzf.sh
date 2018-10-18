# CTRL-R - paste from clipboard
# CTRL-T - paste a file name
# ALT-C  - cd into a selected dir
[[ -f /etc/profile.d/fzf.zsh ]] && . /etc/profile.d/fzf.zsh

# fe [FUZZY PATTERN] - Open the selected file with the default editor
#   - Bypass fuzzy finder if there's only one match (--select-1)
#   - Exit if there's no match (--exit-0)
fe() {
  IFS='
'
  local declare files=($(fzf-tmux --query="$1" --select-1 --exit-0))
  [[ -n "$files" ]] && ${EDITOR:-vim} "${files[@]}"
  unset IFS
}

# fd - cd to selected directory
#fd() {
#    local dir
#    dir=$(find ${1:-*} -path '*/\.*' -prune \
#        -o -type d -print 2> /dev/null | fzf +m) &&
#    cd "$dir"
#}

#ag --nobreak --nonumbers --noheading getModelTemplates | fzf
