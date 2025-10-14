#!/bin/bash

# Bash sets the BASH environment variable, so if it is not set, then we
# are running in a different shell, so manually run ourselves in BASH.
if [ -z "${BASH:-}" ]; then
	exec bash "$0" "$@"
fi

printf "\nValidating commits message\n\n"
git fetch &>/dev/null
current_branch="$(git branch --show-current)"
no_of_commits_to_validate="$(git rev-list --left-right --count origin/development..."$current_branch" | grep -oE '[[:digit:]]+' | tail -1)"
commits_to_validate="$(git rev-list --left-right --pretty=oneline origin/development..."$current_branch")"

printf "current branch: %s\n\nno_of_commits_to_validate: %s\n\ncommits info :\n%s\n\n" "$current_branch" "$no_of_commits_to_validate" "$commits_to_validate"

npx commitlint --from=HEAD~"$no_of_commits_to_validate" --config commitlint.config.cjs
