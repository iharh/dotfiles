if cat /etc/*release | grep ^NAME | grep -q Ubuntu; then
    alias fd='fdfind'
fi

fif () {
    #rg --files -g "*$@*"
    fd "$@"
}

fifh () {
    #rg --hidden --files -g "*$@*"
    fd --hidden "$@"
}

# using ripgrep combined with preview
# find-in-file - usage: fif <searchTerm>
fifc() {
  if [ ! "$#" -gt 0 ]; then echo "Need a string to search for!"; return 1; fi
  rg --files-with-matches --no-messages "$1" | fzf --preview "highlight -O ansi -l {} 2> /dev/null | rg --colors 'match:bg:yellow' --ignore-case --pretty --context 10 '$1' || rg --ignore-case --pretty --context 10 '$1' {}"
}
