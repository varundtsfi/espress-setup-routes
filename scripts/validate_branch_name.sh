#!/bin/bash

# Bash sets the BASH environment variable, so if it is not set, then we
# are running in a different shell, so manually run ourselves in BASH.
if [ -z "${BASH:-}" ]; then
	exec bash "$0" "$@"
fi

. "$(dirname "$0")/helper.sh"

# validate branch name

if [[ -z $1 ]]; then
	current_branch="$(get_local_branchname)"
else
	current_branch=$1
fi
validate_branch_name "$current_branch" || exit 1
