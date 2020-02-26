#!/bin/bash

# Note: `workspaceFolder` is the folder that contains the Dockerfile
#       The name is inherited from VSCode meaning.
#       See vscode-user-settings.json.example

docker build -t ednutting/jekyll-ghcup:dev $workspaceFolder
