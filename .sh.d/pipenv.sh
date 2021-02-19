#export WORKON_HOME="/home/iharh/.venvs"
export PIPENV_VENV_IN_PROJECT=1

prj-activate() {
    local PRJ_NAME="${1// }"
    shift
    if [[ -z $PRJ_NAME ]]; then
        echo "PRJ_NAME is EMPTY - skip activation"
    else
        (. $WRK_PRJ_DIR/py/$PRJ_NAME/.venv/bin/activate && $WRK_PRJ_DIR/py/$PRJ_NAME/.venv/bin/$PRJ_NAME "$@")
    fi
}

dvc () {
    prj-activate dvc "$@"
}

youtube-dl () {
    prj-activate youtube-dl "$@"
}
