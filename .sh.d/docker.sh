# docker
alias on-doc='sudo systemctl start docker'
off-doc () {
    sudo systemctl stop docker.socket
    sudo systemctl stop docker
}
alias cfg-doc='sudo vim /etc/systemd/system/docker.service'

alias doc-ps='docker ps -a'
alias doc-log='docker logs'
alias doc-img='docker images'
alias doc-rmc='docker rm -v $(docker ps -aqf status=exited && docker ps -aqf status=dead)'
alias doc-rmd='docker rmi $(docker images -q -f "dangling=true")'
alias doc-rmv='docker volume rm $(docker molume ls -q -f "dangling=true")'
alias doc-pru='docker system prune'

# docker-compose
alias dco='docker-compose'
alias dco-rm='docker-compose stop && docker-compose rm'

dco-inst () {
    sudo -i curl -L https://github.com/docker/compose/releases/download/1.16.1/docker-compose-`uname -s`-`uname -m` -o /usr/local/bin/docker-compose
    sudo chmod +x /usr/local/bin/docker-compose
}
