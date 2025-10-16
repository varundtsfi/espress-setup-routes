#!/bin/bash

# Bash sets the BASH environment variable, so if it is not set, then we
# are running in a different shell, so manually run ourselves in BASH.
if [ -z "${BASH:-}" ]; then
	exec bash "$0" "$@"
fi

. "$(dirname "$0")/helper.sh"

# validate task id in commit message

current_commit_msg_file="$1"
validate_commit_msg_task_id "$current_commit_msg_file" || exit 1
