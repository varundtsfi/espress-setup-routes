#!/usr/bin/env bash

# set -x

function validate_branch_name() {
	local branch_name="$1"
	task_ids_in_branch="PC|ID"
	valid_branch_name_regex="^(remotes\/origin\/)?(development|main)$|(^(remotes\/origin\/)?feature|bugfix|enhancement|hotfix|feat|fix|refactor|chore|perf|docs|style)\/(($task_ids_in_branch)-[[:digit:]]+\/)([a-z0-9]-?)+[a-z0-9]$|(release\/v[12].[0-9]+.[0-9]+)$"
	is_valid_branch_name=$(echo "$branch_name" | grep -oE "$valid_branch_name_regex")

	if [[ -n $is_valid_branch_name ]]; then
		echo "Branch name [$branch_name] is valid"
	else
		echo "ERROR: Branch name [$branch_name] is not valid"
		exit 1
	fi
}

function get_local_branchname() {
	local current_branch
	current_branch=$(git rev-parse --abbrev-ref HEAD)
	echo "$current_branch"

}

function validate_commit_msg_task_id() {
	local commit_file=$1
	commit_msg=$(cat "$commit_file")
	current_branch=$(git rev-parse --abbrev-ref HEAD)

	task_names="JIRA-ID|TASK-ID"
	task_ids="PC|ID"

	local valid_branch_name_regex="^(remotes\/origin\/)?(development|main)$|(^(remotes\/origin\/)?feature|bugfix|enhancement|hotfix|feat|fix|refactor|chore|perf|docs|style)\/(${task_ids})-[[:digit:]]+\/([a-z0-9]-?)+[a-z0-9]$|(release\/v[12].[0-9]+.[0-9]+)$"
	local whitelisted_branch_name_regex="^(remotes\/origin\/)?(development|main)|(remotes\/origin\/)?(release\/v[12].[0-9]+.[0-9]+)$"

	task_id_regex="(${task_ids})-[[:digit:]]+"

	task_id_in_current_branch_name=$(echo "$current_branch" | grep -oE "$task_id_regex")

	task_id_in_commit_message=$(echo "$commit_msg" | grep -E "(${task_names}):" | grep -oE "$task_id_regex" | tail -1)

	merge_commits_regex="Merge pull request|Merge|pull|Merge branch|Merge branch.*development"
	is_merge_commit=$(echo "$commit_msg" | grep -oiE "$merge_commits_regex")

	if [[ $current_branch =~ $valid_branch_name_regex ]]; then

		if [ -n "$is_merge_commit" ]; then
			echo "Its a Merge commit skipping: skipping checks for TASK-ID in commit message"
		elif [ -n "$task_id_in_commit_message" ]; then
			if [[ $current_branch =~ $whitelisted_branch_name_regex ]]; then
				echo "Whitelisted branches [main,development,release/v*] : skipping checks for TASK-ID in branch"
			elif [ "$task_id_in_commit_message" != "$task_id_in_current_branch_name" ]; then
				echo "ERROR : your commit message TASK_ID=$task_id_in_commit_message  is not equal to current branch TASK_ID=$task_id_in_current_branch_name"
				exit 1
			fi
		else
			echo "ERROR: Your commit message does not contain TASK-ID of the format ${task_names}: ${task_ids}-[[:digit:]]+"
			exit 1
		fi
	fi
}
