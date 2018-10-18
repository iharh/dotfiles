# local
scp-to-t1 () {
    rsync -aPvzl -e ssh /data/wrk/transfer/ "iharh@epbygomw0024t1:/home/iharh/transfer/"
}
scp-from-t1 () {
    rm -rf ~/transfer/*
    rsync -aPvzl -e ssh "iharh@epbygomw0024t1:/home/iharh/transfer/" ~/transfer/
}
scp-to-t1-vag () {
    rsync -aPvzl -e ssh /data/wrk/transfer/ "vagrant@epbygomw0024t1:/home/vagrant/transfer/"
}

# clb
alias ssh-pd='ssh ihar.hancharenka@platform-dev.cbmain.clarabridge.com'
alias ssh-pdj='ssh jenkins@platform-dev.cbmain.clarabridge.com'
alias ssh-pdr='ssh root@platform-dev.cbmain.clarabridge.com'
scp-to-pdj () {
    scp "$@" jenkins@platform-dev:/home/jenkins
}
scp-from-pdj-rpt () {
    rm -rf ~/transfer/*
    rsync -aPvzl -e ssh "jenkins@platform-dev:/home/jenkins/jenkins-node/cb-cps-linux-nightly/target/reports" ~/transfer/
}

alias ssh-cbh='ssh hudson@cb03lx-build.cbmain.clarabridge.com'

alias ssh-eur1='ssh ihar.hancharenka@d9-s19-leka01.clarabridge.net'
alias ssh-eur2='ssh ihar.hancharenka@d10-s19-leka01.clarabridge.net'
alias ssh-cps1='ssh ihar.hancharenka@d9-s11-lcps01.clarabridge.net'
alias ssh-cps2='ssh ihar.hancharenka@d9-s11-lcps02.clarabridge.net'
alias ssh-tps1='ssh ihar.hancharenka@d9-s33-ltps01.clarabridge.net'
alias ssh-tps2='ssh ihar.hancharenka@d10-s33-ltps01.clarabridge.net'
scp-from-cps1 () {
    rm -rf ~/transfer/*
    #rsync -aPvzl -e ssh "ihar.hancharenka@d9-s11-lcps01.clarabridge.net:/home/ihar.hancharenka/transfer/" ~/transfer/
    scp ihar.hancharenka@d9-s11-lcps01.clarabridge.net:/home/ihar.hancharenka/transfer/* /home/iharh/transfer
}
scp-to-cps1 () {
    scp /home/iharh/transfer/* ihar.hancharenka@d9-s11-lcps01.clarabridge.net:/home/ihar.hancharenka/transfer/
}

alias ssh-ld1='ssh ihar.hancharenka@d5-d06-ldev01.clarabridge.net'
scp-from-ld1 () {
    rm -rf ~/transfer/*
    rsync -aPvzl -e ssh "ihar.hancharenka@d5-d06-ldev01.clarabridge.net:/home/ihar.hancharenka/transfer/" ~/transfer/
}
scp-to-ld1 () {
    rsync -aPvzl -e ssh ~/transfer/ "ihar.hancharenka@d5-d06-ldev01.clarabridge.net:/home/ihar.hancharenka/transfer/"
}

alias ssh-platb='ssh ihar.hancharenka@plat-build.clarabridge.net'
scp-from-platb () {
    rm -rf ~/transfer/*
    rsync -aPvzl -e ssh "ihar.hancharenka@plat-build.clarabridge.net:/home/ihar.hancharenka/transfer/" ~/transfer/
}

alias ssh-rr13='ssh ihar.hancharenka@roadrunner13.clarabridge.net'
alias ssh-rr14='ssh ihar.hancharenka@roadrunner14.clarabridge.net'

# epam
#alias on-epam='sudo pon epam'
#alias off-epam='sudo poff epam'

alias ssh-t1='ssh iharh@epbygomw0024t1'
alias ssh-t2-vag='ssh vagrant@epbygomw0024t2'

alias ssh-epam-i='ssh ihar_hancharenka@epam.com@ECSD001004F7.epam.com'
alias ssh-epam-j='ssh jenkins@ECSD001004F7.epam.com'
alias ssh-epam-m='ssh msa@ECSD001004F7.epam.com'

scp-to-epam-j () {
    rsync -aPvzl -e ssh /data/wrk/transfer/ "jenkins@ECSD001004F7:/home/jenkins/transfer/"
}

# vbox
alias ssh-k1='ssh vagrant@192.168.235.61'
alias ssh-k2='ssh vagrant@192.168.235.62'
alias ssh-k3='ssh vagrant@192.168.235.63'
alias ssh-k4='ssh vagrant@192.168.235.64'
alias ssh-k9='ssh vagrant@192.168.235.69'
