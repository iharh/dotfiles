export RUSTUP_HOME=/data/wrk/.rustup
export CARGO_HOME=/data/wrk/.cargo
source $CARGO_HOME/env

upu-rust () {
    rustup update
}
