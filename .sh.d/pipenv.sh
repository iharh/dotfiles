#export WORKON_HOME="/home/iharh/.venvs"
export PIPENV_VENV_IN_PROJECT=1

dvc () {
    (. $WRK_PRJ_DIR/py/dvc/.venv/bin/activate && $WRK_PRJ_DIR/py/dvc/.venv/bin/dvc "$@")
}

