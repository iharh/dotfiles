fif () {
    #rg --files -g "*$@*"
    fd "$@"
}

fifh () {
    #rg --hidden --files -g "*$@*"
    fd --hidden "$@"
}
