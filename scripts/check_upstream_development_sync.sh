#!/bin/bash

# Bash sets the BASH environment variable, so if it is not set, then we
# are running in a different shell, so manually run ourselves in BASH.
if [ -z "${BASH:-}" ]; then
	exec bash "$0" "$@"
fi

git fetch
git rev-list --left-right --count origin/development..."$(git branch --show-current)" | awk '{print "Behind origin/development by "$1" commits - Ahead of origin/development by "$2" commits"}'
