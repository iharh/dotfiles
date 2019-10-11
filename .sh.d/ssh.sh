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
