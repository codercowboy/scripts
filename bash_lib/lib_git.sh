#!/bin/bash

if [ "`type -t stage_git_file_fn`" = "function" ]; then
	echo "Skipping definition of git library functions from lib_git.sh, they're already sourced in this shell"
	return 0
fi

export GIT_COMMIT_SCRATCH_DIR="${HOME}/Documents/code/git-scratch"
export GIT_COMMIT_PARENT_DIR="${GIT_COMMIT_SCRATCH_DIR}/commit"
export GIT_CLEAN_CHECKOUT_PARENT_DIR="${GIT_COMMIT_SCRATCH_DIR}/clean"

function git_help() {
	echo "Shortcuts"
	echo "  gitlog - show git log in pretty format"
	echo "  git_pull_force_overwrite - hard update current branch from remote, discarding current work"
	echo "  git_get_branch - shows current branch"
	echo "  git_list_remote_branches - list remote branches"
	echo "  git_config_verify - verify config"
	echo "  git_show_remotes - show remotes"
	echo "  git_show_remote_url - show remote url (assumes single remote)"
	echo
	echo "Tips:"
	echo "  Rebase to root: git rebase -i --root"
	echo "  Fetching from root: git fetch --all --prune"
	echo 
	echo "To see this again: 'git_help', this is all defined in lib_git.sh"
	echo
}
export -f git_help

export ENV_HELP_FNS="${ENV_HELP_FNS};git_help"

# make git log output human readable
alias gitlog='git log --pretty=format:"%h - %an, %ar : %s"'

alias git_pull_force_overwrite='git reset --hard @{upstream}'
alias git_log_for_merge="git log --date-order --reverse --no-merges --abbrev-commit --date=short --format=\"%h - %s [%cn :: %cI]%n%n%b\" ${@}"
alias git_get_branch="git branch --show-current"
alias git_list_remote_branches="git branch -r"
alias git_config_verify="git config -l"
alias git_show_remotes="git remote -v"
alias git_show_remote_url="git ls-remote --get-url"

# arg 1 = source dir to stage from
# arg 2 = file to stage
function git_stage_commit_file() {
	if [ -z "${1}" -o -z "${2}" ]; then
		echo "USAGE: git_stage_commit_file [SOURCE_DIR] [FILE_TO_STAGE]"
		return 1
	fi

	local SOURCE_DIR="${1}"
	local FILE_TO_STAGE="${2}"	
	if [ ! -d "${SOURCE_DIR}" ]; then
		echo "ERROR: Cannot stage file, source dir doesn't exist: ${SOURCE_DIR}"
		return 1
	elif [ ! -e "${SOURCE_DIR}/${FILE_TO_STAGE}" ]; then
		echo "ERROR: Cannot stage file, file to stage doesnt exist: ${FILE_TO_STAGE}"
		return 1
	fi

	local SOURCE_DIR_BASENAME="$(cd "${SOURCE_DIR}" && basename `pwd -P`)"
	local COMMIT_DIR="${GIT_COMMIT_PARENT_DIR}/${SOURCE_DIR_BASENAME}-commit"

	# if a file has a $ in it (like wicket html files), replace those with '?'
	FILE_TO_STAGE="${FILE_TO_STAGE/$/?}"

	local FILE_PARENT_DIR=`dirname "${FILE_TO_STAGE}"`
	if [ ! -d "${COMMIT_DIR}/${FILE_PARENT_DIR}" ]; then
		echo "Creating parent commit dir: ${COMMIT_DIR}/${FILE_PARENT_DIR}"
		mkdir -p "${COMMIT_DIR}/${FILE_PARENT_DIR}"
	fi

	if [ -d "${SOURCE_DIR}/${FILE_TO_STAGE}" ]; then
		echo "Now copying dir: ${FILE_TO_STAGE}"
		local TARGET_DIR=`dirname "${COMMIT_DIR}/${FILE_TO_STAGE}"`
		echo "TARGET_DIR: ${TARGET_DIR}"
		local SOURCE_FILE=`basename "${FILE_TO_STAGE}"`
		local SOURCE=`dirname "${SOURCE_DIR}/${FILE_TO_STAGE}"`
		SOURCE="${SOURCE}/${SOURCE_FILE}"
		echo "SOURCE: ${SOURCE}"
		cp -r "${SOURCE}" "${TARGET_DIR}"			
	else
		echo "Now copying file: ${FILE_TO_STAGE}"
		FILE_TO_STAGE=`basename "${FILE_TO_STAGE}"`
		(cd "${SOURCE_DIR}/${FILE_PARENT_DIR}" && cp ${FILE} "${COMMIT_DIR}/${PARENT_DIR}/")
	fi

	return 0
}
export -f git_stage_commit_file

# arg 1 = source dir to stage from
function git_stage_commit_files() {
	if [ -z "${1}" ]; then
		echo "USAGE: git_stage_commit_files [SOURCE_DIR]"
		return
	fi

	local SOURCE_DIR="${1}"
	if [ ! -d "${SOURCE_DIR}" ]; then
		echo "ERROR: Cannot stage commit files, source dir doesn't exist: ${SOURCE_DIR}"
		return
	fi

	local SOURCE_DIR_BASENAME="$(cd "${SOURCE_DIR}" && basename `pwd -P`)"
	local COMMIT_DIR="${GIT_COMMIT_PARENT_DIR}/${SOURCE_DIR_BASENAME}-commit"

	local OLD_PWD=`pwd -P`

	if [ ! -d "${COMMIT_DIR}" ]; then
		echo "Creating commit dir: ${COMMIT_DIR}"
		mkdir -p "${COMMIT_DIR}"
	fi

	#make for's argument seperator newline only
	local oIFS=${IFS}
	IFS=$'\n'

	echo "Staging files from ${SOURCE_DIR} to ${COMMIT_DIR}"

	(cd "${SOURCE_DIR}" && git add *)

	FILES=`cd "${SOURCE_DIR}" && git status -s`
	for STATUS_LINE in ${FILES}; do		
		local FILE=`echo "${STATUS_LINE}" | sed 's/...//'`
		local GIT_OPERATION=`echo ${STATUS_LINE} | sed 's/\(.\).*/\1/'`
		if [ "${GIT_OPERATION}" = "D" ]; then
			echo "Now removing file or dir: ${FILE}"
			FILE="${COMMIT_DIR}/${FILE}"
			# if a file has a $ in it (like wicket html files), replace those with '?'
			FILE="${FILE/$/?}"			
			rm -Rf "${FILE}"
		elif [ "${GIT_OPERATION}" = "RM" -o "${GIT_OPERATION}" = "R" ]; then
			local ORIGINAL_FILE=`echo "${FILE}" | sed 's/.->.*//'`
			# if a file has a $ in it (like wicket html files), replace those with '?'
			ORIGINAL_FILE="${ORIGINAL_FILE/$/?}"			
			local NEW_FILE=`echo "${FILE}" | sed 's/.*->.//'`
			echo "Now moving file or dir: ${ORIGINAL_FILE} -> ${NEW_FILE}"
			git mv "${COMMIT_DIR}/${ORIGINAL_FILE}" "${COMMIT_DIR}/${NEW_FILE}"
			stage_git_file "${SOURCE_DIR}" "${NEW_FILE}"
		elif [ "${GIT_OPERATION}" = "A" ]; then
			stage_git_file "${SOURCE_DIR}" "${FILE}"
		elif [ "${GIT_OPERATION}" = "M" ]; then
			stage_git_file "${SOURCE_DIR}" "${FILE}"
		else
			echo "Unsupported git operation '${GIT_OPERATION}', line: ${STATUS_LINE}"
			return 1
		fi			
	done
	IFS=${oIFS}

	return 0
}
export -f git_stage_commit_files

# arg 1 = source dir to stage from
function git_create_clean_repo {
	if [ -z "${1}" ]; then
		echo "USAGE: git_prep_commit [SOURCE_DIR]"
		return
	fi

	local SOURCE_DIR="${1}"
	if [ ! -d "${SOURCE_DIR}" ]; then
		echo "ERROR: Cannot create clean repo, source dir doesn't exist: ${SOURCE_DIR}"
		return
	fi

	local SOURCE_DIR_BASENAME="$(cd "${SOURCE_DIR}" && basename `pwd -P`)"
	local CLEAN_DIR="${GIT_CLEAN_CHECKOUT_PARENT_DIR}/${SOURCE_DIR_BASENAME}-clean"

	echo "Clean repo checkout dir: ${CLEAN_DIR}"

	if [ ! -d "${CLEAN_DIR}" ]; then
		echo "Creating ${CLEAN_DIR}"
		mkdir -p "${CLEAN_DIR}"

		local REMOTE_REPO="$(cd "${SOURCE_DIR}" && git ls-remote --get-url)"
		echo "Cloning git repo from ${REMOTE_REPO}"
		git clone "${REMOTE_REPO}" "${CLEAN_DIR}}"
		if [ "${?}" != "0" ]; then
			echo "ERROR: Could not clone repo from ${REMOTE_REPO}"
			return 1
		fi
	fi

	echo "Updating from git repo"
	(cd "${CLEAN_DIR}" && git fetch --all --prune)

	return 0
}
export -f git_create_clean_repo

# arg 1 = source dir to stage from
function git_prep_commit {	
	if [ -z "${1}" ]; then
		echo "USAGE: git_prep_commit [SOURCE_DIR]"
		return
	fi

	local SOURCE_DIR="${1}"
	if [ ! -d "${SOURCE_DIR}" ]; then
		echo "ERROR: Cannot stage file, source dir doesn't exist: ${SOURCE_DIR}"
		return
	fi

	local SOURCE_DIR_BASENAME="$(cd "${SOURCE_DIR}" && basename `pwd -P`)"
	local COMMIT_DIR="${GIT_COMMIT_PARENT_DIR}/${SOURCE_DIR_BASENAME}-commit"
	local CLEAN_DIR="${GIT_CLEAN_CHECKOUT_PARENT_DIR}/${SOURCE_DIR_BASENAME}-clean"
	
	if [ -e "${COMMIT_DIR}" ]; then
		echo "Remove commit dir ${COMMIT_DIR}? ('YES' to select, enter to skip)"
		echo -n "> "
		read ANSWER
		if [ "${ANSWER}" = "YES" ]; then
			echo "Removing commit dir: ${COMMIT_DIR}"
			rm -Rf "${COMMIT_DIR}"
		else
			echo "Error, commit dir '${COMMIT_DIR}' already exists."
			return 1
		fi
	fi

	git_create_clean_repo "${SOURCE_DIR}"
	if [ ! -e "${CLEAN_DIR}" ]; then
		echo "Error, clean repo '${CLEAN_DIR}' does not exist."
		return 1
	fi	

	echo "Creating commit dir: ${COMMIT_DIR}"
	cp -r "${CLEAN_DIR}" "${COMMIT_DIR}"

	local TMP_BRANCH=`cd "${SOURCE_DIR}" && git branch --show-current`
	if [ -z "${TMP_BRANCH}" ]; then
		local TMP_BRANCH="main"
	fi
	echo "Checking out branch on commit dir: ${TMP_BRANCH}"
	cd "${COMMIT_DIR}" && git checkout "${TMP_BRANCH}"
	cd "${COMMIT_DIR}" && git add * && git stash && git_pull_force_overwrite 

	stage_commit_files "${1}"
	
	echo "Opening sourcetree for ${COMMIT_DIR}"
	echo "WARNING: don't forget to create a branch ie 'git checkout -b my-branch'"

	cd "${COMMIT_DIR}"

	stree "${COMMIT_DIR}"

	return 0
}
export -f git_prep_commit

# arg 1 = branch to remove
function git_remove_remote_branch {
	local BRANCH_TO_REMOVE="${1}"
	if [ "" = "${BRANCH_TO_REMOVE}" ]; then
		echo "USAGE: git_remove_remote_branch [branch]"
		return 1
	fi

	echo "Remove remote branch ${BRANCH_TO_REMOVE}? ('YES' to select, enter to skip)"
	echo -n "> "
	read ANSWER
	if [ "${ANSWER}" != "YES" ]; then
		echo "Not removing remote branch. (you didn't type 'YES')"
		return 1
	fi

	echo "Removing remote branch: ${BRANCH_TO_REMOVE}"
	git push origin --delete "${BRANCH_TO_REMOVE}"
	return ${?}
}
export -f git_remove_remote_branch
