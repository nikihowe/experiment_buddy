#!/usr/bin/env bash
set -e
BUDDY_CURRENT_TESTING_BRANCH=$(git rev-parse --abbrev-ref HEAD)

function update_repo() {
  sleep 1
  git add -A
  git commit -m "Testing changes" && git push --force && git reset --soft HEAD~1
}

function set_example_repo() {
  ### This should create an `examples` testing branch that uses
  ### the currently developed branch... If you have more elegant solutions, you are welcome to inquire
  rm -rf examples
}

function run_on_cluster() {
  docker run -v ~/.ssh:/root/.ssh --rm -i \
             -e WANDB_API_KEY=$WANDB_API_KEY \
             -e GIT_MAIL=$(git config user.email) \
             -e GIT_NAME=$(git config user.name) \
             -e BUDDY_CURRENT_TESTING_BRANCH="$BUDDY_CURRENT_TESTING_BRANCH" \
             -v $(pwd)/test_scripts/test_flow.sh:/test_flow.sh \
             -e ON_CLUSTER=1 \
             -u root:$(id -u $USER) $(docker build -f ./Dockerfile-flow -q .) \
             /test_flow.sh
}

clear
update_repo .
set_example_repo
run_on_cluster
