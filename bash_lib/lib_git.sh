#!/bin/bash

if [ "`type -t stage_git_file_fn`" = "function" ]; then
	echo "Skipping definition of git library functions from lib_git.sh, they're already sourced in this shell"
	return 0
fi

if [ "${VPN_NAME}" = "" ]; then
	export VPN_NAME="VPN (thin)"
fi

function vpn_connect {
	echo "[CONNECTING TO VPN: ${VPN_NAME}]"
	
	local VPN_STATUS=`networksetup -showpppoestatus "${VPN_NAME}"`
	if [ "connected" = "${VPN_STATUS}" ]; then
		echo "VPN is already connected"
		return 0
	fi	

	networksetup -connectpppoeservice "${VPN_NAME}"
	sleep 10
	
	local VPN_STATUS=`networksetup -showpppoestatus "${VPN_NAME}"`
	if [ "connected" != "${VPN_STATUS}" ]; then
		echo "ERROR: VPN didn't connect, status is: ${VPN_STATUS}"
		return 1
	fi

	return 0
}

function vpn_disconnect {
	echo "[DISCONNECTING FROM VPN: ${VPN_NAME}]"
	local VPN_STATUS=`networksetup -showpppoestatus "${VPN_NAME}"`
	if [ "disconnected" = "${VPN_STATUS}" ]; then
		echo "VPN is already disconnected"
		return 0
	fi
	
	networksetup -disconnectpppoeservice "${VPN_NAME}"
	sleep 10
	
	local VPN_STATUS=`networksetup -showpppoestatus "${VPN_NAME}"`
	if [ "disconnected" != "${VPN_STATUS}" ]; then
		echo "ERROR: VPN didn't disconnect, status is: ${VPN_STATUS}"
		return 1
	fi

	return 0
}

# make git log output human readable
alias gitlog='git log --pretty=format:"%h - %an, %ar : %s"'

alias git_pull_force_overwrite='git reset --hard @{upstream}'
alias git_log_for_merge="git log --date-order --reverse --no-merges --abbrev-commit --date=short --format=\"%h - %s [%cn :: %cI]%n%n%b\" ${@}"
alias git_get_branch="git branch --show-current"
alias git_list_remote_branches="git branch -r"

# arg 1 = mode, one of 'console', 'portal', 'docs'
# arg 2 = file to stage
function stage_git_file() {
	if [ "console" = "${1}" ]; then
		COMMIT_DIR="${CODE}/hyte/commit/console-commit"
		SOURCE_DIR="${CODE}/hyte/console-active"
	elif [ "portal" = "${1}" ]; then
		COMMIT_DIR="${CODE}/hyte/commit/portal-commit"
		SOURCE_DIR="${CODE}/hyte/portal-active"
	elif [ "docs" = "${1}" ]; then
		COMMIT_DIR="${CODE}/hyte/commit/docs-commit"
		SOURCE_DIR="${CODE}/hyte/docs-active"
	else
		echo "USAGE: stage_git_file [MODE] [FILE]"
		echo ""
		echo "MODE options: console, portal, docs"
		return 1
	fi	

	FILE="${2}"
	if [ ! -e "${COMMIT_DIR}" ]; then
		echo "Error, commit dir '${COMMIT_DIR}' does not exist."
		return 1
	elif [ ! -e "${SOURCE_DIR}" ]; then
		echo "Error, source dir '${SOURCE_DIR}' does not exist."
		return 1
	elif [ "" = "${FILE}" ]; then
		echo "Error, no file specified."
		return 1
	fi

	# if a file has a $ in it (like wicket html files), replace those with '?'
	FILE="${FILE/$/?}"

	PARENT_DIR=`dirname "${FILE}"`

	if [ ! -d "${COMMIT_DIR}/${PARENT_DIR}" ]; then
		echo "Creating parent dir: ${COMMIT_DIR}/${PARENT_DIR}"
		mkdir -p "${COMMIT_DIR}/${PARENT_DIR}"
	fi

	if [ -d "${SOURCE_DIR}/${FILE}" ]; then
		echo "Now copying dir: ${FILE}"
		TARGET_DIR=`dirname "${COMMIT_DIR}/${FILE}"`
		echo "TARGET_DIR: ${TARGET_DIR}"
		SOURCE_FILE=`basename "${FILE}"`
		SOURCE=`dirname "${SOURCE_DIR}/${FILE}"`
		SOURCE="${SOURCE}/${SOURCE_FILE}"
		echo "SOURCE: ${SOURCE}"
		cp -r "${SOURCE}" "${TARGET_DIR}"			
	else
		echo "Now copying file: ${FILE}"
		FILE=`basename "${FILE}"`
		cd "${SOURCE_DIR}/${PARENT_DIR}" && cp ${FILE} "${COMMIT_DIR}/${PARENT_DIR}/"
	fi

	return 0
}
export -f stage_git_file

# arg 1 = mode, one of 'console', 'portal', 'docs'
function stage_commit_files() {
	if [ "console" = "${1}" ]; then
		COMMIT_DIR="${CODE}/hyte/commit/console-commit"
		SOURCE_DIR="${CODE}/hyte/console-active"
	elif [ "portal" = "${1}" ]; then
		COMMIT_DIR="${CODE}/hyte/commit/portal-commit"
		SOURCE_DIR="${CODE}/hyte/portal-active"
	elif [ "docs" = "${1}" ]; then
		COMMIT_DIR="${CODE}/hyte/commit/docs-commit"
		SOURCE_DIR="${CODE}/hyte/docs-active"
	else
		echo "USAGE: stage_commit_files [MODE]"
		echo ""
		echo "MODE options: console, portal, docs"
		return 1
	fi	

	OLD_PWD=`pwd -P`

	if [ ! -e "${COMMIT_DIR}" ]; then
		echo "Error, commit dir '${COMMIT_DIR}' does not exist."
		return 1
	elif [ ! -e "${SOURCE_DIR}" ]; then
		echo "Error, source dir '${SOURCE_DIR}' does not exist."
		return 1
	fi

	#make for's argument seperator newline only
	oIFS=${IFS}
	IFS=$'\n'

	echo "Staging files from source dir to commit dir"

	cd "${SOURCE_DIR}" && git add *

	FILES=`cd "${SOURCE_DIR}" && git status -s`
	for STATUS_LINE in ${FILES}; do		
		FILE=`echo "${STATUS_LINE}" | sed 's/...//'`
		GIT_OPERATION=`echo ${STATUS_LINE} | sed 's/\(.\).*/\1/'`
		if [ "${GIT_OPERATION}" = "D" ]; then
			echo "Now removing file or dir: ${FILE}"
			FILE="${COMMIT_DIR}/${FILE}"
			# if a file has a $ in it (like wicket html files), replace those with '?'
			FILE="${FILE/$/?}"			
			rm -Rf "${FILE}"
		elif [ "${GIT_OPERATION}" = "RM" -o "${GIT_OPERATION}" = "R" ]; then
			ORIGINAL_FILE=`echo "${FILE}" | sed 's/.->.*//'`
			# if a file has a $ in it (like wicket html files), replace those with '?'
			ORIGINAL_FILE="${ORIGINAL_FILE/$/?}"			
			NEW_FILE=`echo "${FILE}" | sed 's/.*->.//'`
			echo "Now moving file or dir: ${ORIGINAL_FILE} -> ${NEW_FILE}"
			git mv "${COMMIT_DIR}/${ORIGINAL_FILE}" "${COMMIT_DIR}/${NEW_FILE}"
			stage_git_file "${1}" "${NEW_FILE}"
		elif [ "${GIT_OPERATION}" = "A" ]; then
			stage_git_file "${1}" "${FILE}"
		elif [ "${GIT_OPERATION}" = "M" ]; then
			stage_git_file "${1}" "${FILE}"
		else
			echo "Unsupported git operation '${GIT_OPERATION}', line: ${STATUS_LINE}"
			return 1
		fi			
	done
	IFS=${oIFS}
	cd "${OLD_PWD}"

	return 0
}
export -f stage_commit_files

# arg 1 = mode, one of 'console', 'portal', 'docs'
function prep_commit {	
	if [ "console" = "${1}" ]; then
		COMMIT_DIR="${CODE}/hyte/commit/console-commit"
		CLEAN_DIR="${CODE}/hyte/commit/clean/console"
		SOURCE_DIR="${CODE}/hyte/console-active"
	elif [ "portal" = "${1}" ]; then
		COMMIT_DIR="${CODE}/hyte/commit/portal-commit"
		CLEAN_DIR="${CODE}/hyte/commit/clean/portal"
		SOURCE_DIR="${CODE}/hyte/portal-active"
	elif [ "docs" = "${1}" ]; then
		COMMIT_DIR="${CODE}/hyte/commit/docs-commit"
		CLEAN_DIR="${CODE}/hyte/commit/clean/docs"
		SOURCE_DIR="${CODE}/hyte/docs-active"
	else
		echo "USAGE: prep_commit [MODE]"
		echo ""
		echo "MODE options: console, portal, docs"
		return 1
	fi	
	
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

	if [ ! -e "${CLEAN_DIR}" ]; then
		echo "Error, clean dir '${CLEAN_DIR}' does not exist."
		return 1
	elif [ ! -e "${SOURCE_DIR}" ]; then
		echo "Error, source dir '${SOURCE_DIR}' does not exist."
		return 1
	fi

	echo "[UPDATING GIT REPO]"
	vpn_connect
	if [ "${?}" = "1" ]; then
		echo "ERROR: couldn't connect VPN"
		return 1
	fi

	sleep 10
	
	cd "${CLEAN_DIR}" && git fetch --all --prune
	cd "${CLEAN_DIR}" && git checkout main && git add * && git stash && git_pull_force_overwrite 

	echo "Creating commit dir: ${COMMIT_DIR}"
	cp -r "${CLEAN_DIR}" "${COMMIT_DIR}"

	TMP_BRANCH=`cd "${SOURCE_DIR}" && git branch --show-current`
	if [ -z "${TMP_BRANCH}" ]; then
		TMP_BRANCH="main"
	fi
	echo "Checking out branch: ${TMP_BRANCH}"
	cd "${COMMIT_DIR}" && git checkout "${TMP_BRANCH}"

	stage_commit_files "${1}"
	
	echo "Opening sourcetree for ${COMMIT_DIR}"
	echo "WARNING: don't forget to create a branch ie 'git checkout -b hc-22'"

	cd "${COMMIT_DIR}"

	stree "${COMMIT_DIR}"

	return 0
}
export -f prep_commit

function git_backup {
	if [ "" = "${1}" ]; then
		echo "USAGE: git_backup [directory] [backup name (optional)]"
		echo ""
		echo "If backup name is not specified, the git project's current branch will be used as the backup name."
		return 1
	elif [ ! -d "${1}" ]; then
		echo "Error, dir '${1}' does not exist."
		return 1
	fi

	BACKUP_NAME="${2}"

	if [ -z "${BACKUP_NAME}" ]; then
		TMP_BRANCH=`cd "${1}" && git branch --show-current`
		if [ -z "${TMP_BRANCH}" ]; then
			echo "Could not determine git branch for ${1}, and backup name arg not provided"
			return
		fi

		echo "Backup name will be branch: ${TMP_BRANCH}"
		echo ""
		BACKUP_NAME="${TMP_BRANCH}"
	fi

	mkdir -p "${HYTE_BACKUP_DIR}"

	FOLDER_NAME=`basename "${1}"`
	FILE_DATE=`date "+%Y%m%d.%H%M%S"`
	ZIP_NAME="${FOLDER_NAME}.${BACKUP_NAME}.${FILE_DATE}.zip"

	echo "[Backing up: ${1} to ${HYTE_BACKUP_DIR}/${ZIP_NAME}]"
	
	echo "[Cleaning code]"
	for FILE in `find ${1} -type d -name target`; do
		echo "Removing: ${FILE}"
		rm -Rf "${FILE}"		
	done

	echo "[Zipping]"
	zip -r "${HYTE_BACKUP_DIR}/${ZIP_NAME}" "${1}"
	
	echo "[Finished. Backed up to ${HYTE_BACKUP_DIR}/${ZIP_NAME}]"

	return 0
}
export -f git_backup

# arg 1 - directory to work in
function git_update {
	if [ "" = "${1}" ]; then
		echo "USAGE: git_update [directory]"
		return 1
	elif [ ! -d "${1}" ]; then
		echo "Directory does not exist: ${1}" 
		return 1
	fi

	local GIT_HOME="${1}"

	echo "[UPDATING GIT REPO]"
	vpn_connect
	if [ "${?}" = "1" ]; then
		echo "ERROR: couldn't connect VPN"
		return 1
	fi

	sleep 10

	cd "${GIT_HOME}"
	git fetch --all --prune

	echo "Adding and stashing files"
	git add *
	git stash

	echo "Pulling with force overwrite"
	git_pull_force_overwrite

	echo "Popping stashed files"
	git stash pop

	return 0
}

# arg 1 = branch to remove
function git_remove_remote_branch {
	BRANCH_TO_REMOVE="${1}"
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

function git_show_remote_url {
	git ls-remote --get-url origin
}