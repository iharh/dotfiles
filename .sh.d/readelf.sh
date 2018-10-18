check-foundation () {
    readelf -Ws "/data/wrk/clb/fx/fx/fx/$1/target/linux-x64/lib$1.so" | grep NOTYPE | grep foundation
}
