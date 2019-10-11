#gen-purpose
alias ls='ls --group-directories-first --time-style=+"%d.%m.%Y %H:%M" --color=auto -F'
alias ll='ls -l --group-directories-first --time-style=+"%d.%m.%Y %H:%M" --color=auto -F'
alias la='ls -la --group-directories-first --time-style=+"%d.%m.%Y %H:%M" --color=auto -F'
alias grep='grep --color=tty -d skip'
alias cp="cp -i"                          # confirm before overwriting something
alias df='df -h'                          # human-readable sizes

#alias free='free -m'                      # show sizes in MB
#alias np='nano PKGBUILD'

alias off='poweroff'
alias rst='reboot'
alias out='openbox --exit'
alias upu='sudo pacman -Syu'
alias ydl='youtube-dl'

#qbittorrent stuff
alias qbenable='sudo systemctl enable qbittorrent'
alias qbdisable='sudo systemctl disable qbittorrent'
alias qbstatus='sudo systemctl status qbittorrent'
alias qbstop='sudo systemctl stop qbittorrent'
alias qbstart='sudo systemctl start qbittorrent'
alias qbrst='sudo systemctl restart qbittorrent'
alias qbsvccfg='sudo vim /usr/lib/systemd/system/qbittorrent.service'

#soft
alias mgit='/data/wrk/multigit/mgit'
alias mga='/data/wrk/multigit/mgit --all'


#home stuff
alias permm='sudo chgrp -R users /data/media/ && sudo chmod -R g+rwx /data/media/'
#alias bdi='/usr/bin/cp .config/pcmanfm/default/desktop-items-0.conf Documents/'
#alias rdi='/usr/bin/cp Documents/desktop-items-0.conf .config/pcmanfm/default/'

alias wrk-vpn='nmcli c up EpamVPN'
alias wrk-rem='remmina -c ~/.remmina/epbygomw0024t4.remmina'
alias wrk-rdp='xfreerdp +clipboard /u:Ihar_Hancharenka@epam.com /v:epbygomw0024t4.gomel.epam.com'

alias wrk='nmcli c up EpamVPN && remmina -c ~/.remmina/epbygomw0024t4.remmina'

#wrk
alias vpn-clb='sudo openvpn --config /data/wrk/ovpn/clb.ovpn'

#epam
alias mcli='/usr/bin/java -jar /data/wrk/maestro-cli/lib/maestro-cli-full.jar'

#inet
alias pingg='ping -c 4 google.com'
