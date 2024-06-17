#!/bin/bash

# Arguments
TAG="$1"
PLUGIN_REPOSITORY_NAME="$2"
# Functions
get_release_id() {
    curl -s -H "Authorization: token $GH_TOKEN" "https://api.github.com/repos/Blazemeter/$PLUGIN_REPOSITORY_NAME/releases/tags/$TAG" | jq -r '.id'
}

get_artifact_urls() {
    gh release view -R Blazemeter/$PLUGIN_REPOSITORY_NAME $TAG --json assets -q '.assets.[].url'
}

# Main
#release_id=$(get_release_id)
get_artifact_urls
