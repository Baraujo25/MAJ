#!/bin/bash

# Enviroment variables
# RELEASE_VERSION=2.5
# PLUGIN_ARTIFACT_NAME='jmeter-bzm-correlation-recorder'
# PLUGIN_REPOSITORY_NAME='CorrelationRecorder'

# Constants -> modify abstracta & baraujo25
FORKED_REPO_URL="https://github.com/Baraujo25/jmeter-plugins.git"
UPSTREAM_REPO_URL="https://github.com/Abstracta/jmeter-plugins.git"
FORKED_REPO_SSH="git@github.com:Baraujo25/jmeter-plugins.git"
UPSTREAM_REPO_SSH="git@github.com:Abstracta/jmeter-plugins.git"
REPO_DIR="jmeter-plugins"
FILE_PATH="site/dat/repo/blazemeter.json"
FORKED_REPO_USER="Baraujo25"
UPSTREAM_REPO_USER="Abstracta"
BRANCH_NAME=$(echo "$PLUGIN_ARTIFACT_NAME-v$RELEASE_VERSION")
NEW_VERSION_OBJECT=$(bash .github/build_release_json.sh $RELEASE_VERSION $PLUGIN_ARTIFACT_NAME $PLUGIN_REPOSITORY_NAME)


# Functions
init_git() {
    echo " Create the .ssh directory and set permissions"
    mkdir -p ~/.ssh
    chmod 700 ~/.ssh

    # Dynamically fetch and add GitHub to known hosts
    ssh-keyscan github.com >> ~/.ssh/known_hosts
    chmod 644 ~/.ssh/known_hosts
    git config --global user.email "jaraujo@perforce.com"
    git config --global user.name "Baraujo25"
}

clone_and_init_repo() {
    cd ..
    git clone $FORKED_REPO_URL
    cd $REPO_DIR
}

set_git_remotes() {
    git remote set-url origin $FORKED_REPO_SSH
    git remote add upstream $UPSTREAM_REPO_SSH
}

create_branch() {
    git checkout -b $BRANCH_NAME
}

update_branch_from_upstream() {
    git fetch upstream
    git merge upstream/master --allow-unrelated-histories || git merge --abort
}

update_json_file() {
    jq --argjson newVersion "$NEW_VERSION_OBJECT" \
        'map(if .id == "bzm-siebel" then .versions += $newVersion else . end)' \
        $FILE_PATH > tmp.json
    mv tmp.json $FILE_PATH
}

commit_and_push_changes() {
    git add $FILE_PATH
    git commit -m "Update blazemeter.json with new version"
    echo "push to origin"
    git push -u origin $BRANCH_NAME
}

create_pull_request() {
    echo "$GH_TOKEN" | gh auth login --with-token
    gh pr create --title "Automated PR from GitHub Actions" --body "This is an automated PR created by GitHub Actions." --head $FORKED_REPO_USER:$BRANCH_NAME --base master --repo $UPSTREAM_REPO_USER/$REPO_DIR

    # curl -X POST -H "Authorization: token $GH_TOKEN" \
    #   -H "Accept: application/vnd.github.v3+json" \
    #   "https://api.github.com/repos/$UPSTREAM_REPO_USER/$REPO_DIR/pulls" \
    #   -d '{
    #     "title": "Automated PR from GitHub Actions",
    #     "body": "This is an automated PR created by GitHub Actions.",
    #     "head": '$FORKED_REPO_USER:$BRANCH_NAME',
    #     "base": "master"
    #   }'

}


init_git
echo "Cloning repo"
clone_and_init_repo
echo "Setting git remotes"
set_git_remotes
echo "Creating branch"
create_branch
echo "Update branch from upstream"
update_branch_from_upstream
echo "Update file"
update_json_file
echo "Commit and push"
commit_and_push_changes
echo "create PR"
create_pull_request
