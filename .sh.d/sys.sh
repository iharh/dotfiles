# system
alias off='systemctl poweroff'
alias rst='systemctl reboot'
alias jcb='sudo journalctl -b'
alias pingg='ping -c 4 8.8.4.4'
# %N - for nanoseconds
alias mydate='date +"%Y%m%d%H%M%S"'

alias myps='ps afux > ~/ps-$(mydate).txt'
alias psmem='ps -e -o rss=,args= | sort -b -k1,1n'
alias psmem10='ps -e -o rss=,args= | sort -b -k1,1n | tail -10'
alias pscpu='ps -e -o pcpu,cpu,nice,state,cputime,args | sort -k1 -nr'
alias pscpu10='ps -e -o pcpu,cpu,nice,state,cputime,args | sort -k1 -nr | head -10'
# sort options
# -k   ???
# -nr  numerical reverse

#alias ping='ping -c4'
#alias mkdir='mkdir -pv'
dls () {
    ls -l | grep "^d" | awk '{ print $9 }' | tr -d "/"
}

du1 () {
    sudo du -hxcd 1 | sort --human-numeric-sort
}

#aur
alias upu='yay -Syu' #alias upu='yaourt -Syu --aur'
alias pacccl='paccache -rvk3'

#dd
alias dd-sdb='sudo dd bs=4M of=/dev/sdb status=progress oflag=sync' #if=<name>.iso
