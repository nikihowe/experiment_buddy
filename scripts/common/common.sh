#! /bin/bash

set -e

# Module system
function log() {
    echo -e "\e[32m\"[DEPLOY LOG] $*\"\e[0m"
}

function pull_experiment() {
  GIT_URL=$1
  HASH_COMMIT=$2
  FOLDER=$3
  log "downloading source code from $GIT_URL to $FOLDER"
  git clone -q "$GIT_URL" "$FOLDER"/
  cd "$FOLDER" || exit
  git checkout "$HASH_COMMIT"
  log "pwd is now $(pwd)"
}

function load_git_folder() {
  SCRIPT=$(realpath $0)
  GIT_URL=$1
  HASH_COMMIT=$2

  log "script realpath: $SCRIPT"
  SCRIPTS_FOLDER=$(dirname "$SCRIPT")
  log "scripts home: $SCRIPTS_FOLDER"

  log "cd $HOME/experiments/"
  mkdir -p "$HOME"/experiments/
  cd "$HOME"/experiments/

  EXPERIMENT_FOLDER=$(mktemp -p . -d)
  pull_experiment $GIT_URL $HASH_COMMIT $EXPERIMENT_FOLDER
}

function set_up_venv() {
  VENV_NAME=$1

  if ! source $HOME/venv/bin/activate; then
    log "Setting up venv @ $HOME/venv..."
    python3 -m virtualenv $HOME/"venv"
    source $HOME/venv/bin/activate
  fi

  log "Using shared venv @ $HOME/venv"

  python3 -m pip -q install --upgrade pip

  python3 -m pip install -q -e git+https://github.com/ministry-of-silly-code/experiment_buddy#egg=experiment_buddy --exists-action w

  python3 -m pip -q install -r "requirements.txt" --exists-action w
}
