#!/bin/bash

if [ "`type -t claude_start_docker`" = "function" ]; then
	echo "Skipping import functions from lib_claude.sh, they're already sourced in this shell"
	return 0
fi

################
# CLAUDE STUFF #
################

# as of june 2026, the official claude code dmg weirdly puts claude here:
export PATH=${PATH}:~/.local/bin

function claude_start_docker {
	echo "Entering docker container, to run claude: claude daemon start --dangerously-skip-permissions"
	echo "Reference for claude-pod: https://github.com/trekhleb/claude-pod"
	echo ""
	alias claude_run_here='${TOOLS}/claude-pod/claude-pod'
}
export -f claude_start_docker

function claude_start_vm {
	echo "Running VM for claude"
	echo "Expanding maxfilesperproc to 262144"
	sudo sysctl -w kern.maxfilesperproc=262144 kern.maxfiles=1048576
	ulimit -n 262144
	local TMP_VM_NAME="${CLAUDE_VM_NAME:-tahoe100}"	
	local VM_DIRS="\"--dir=code:${CODE}:ro\""
	local VM_DIRS="${VM_DIRS} \"--dir=claude:${CODE}/claude\""
	local VM_CMD="tart run ${VM_DIRS} \"${TMP_VM_NAME}\""
	echo "VM CMD: ${VM_CMD}"
	eval ${VM_CMD}
}
export -f claude_start_vm

# arg 1 is name of the claude code session (example "NBA JAM Hacks")
function claude_run_here {
	if [ -z "${1}" ]; then
		echo "USAGE: claude_run_here [remote session name]"
		echo "  remote session name: string name of remote session"
		return 1
	fi	

	local TMP_PROJECT_SETTINGS_JSON=".claude/settings.local.json"
	if [ ! -e "${TMP_PROJECT_SETTINGS_JSON}" ]; then
		echo "Creating ${TMP_PROJECT_SETTINGS_JSON}"
		mkdir -p ".claude"
		echo "{\"a\" : 5}" > "${TMP_PROJECT_SETTINGS_JSON}" 
	fi
	echo "before: ${TMP_PROJECT_SETTINGS_JSON}"
	cat "${TMP_PROJECT_SETTINGS_JSON}"
	echo "pausing"
	read

	echo "Editing allowed dirs in ${TMP_PROJECT_SETTINGS_JSON}"
	local TMP_PROJECT_HOME="`pwd -P`"
	jq --arg cwd "${TMP_PROJECT_HOME}" --arg parent_dir "${TMP_PROJECT_HOME}/.." ' 
		.sandbox.filesystem.allowRead  = [$cwd, $parent_dir] |
    	.sandbox.filesystem.allowWrite = [$cwd, $parent_dir]' "${TMP_PROJECT_SETTINGS_JSON}" > "${TMP_PROJECT_SETTINGS_JSON}.tmp"
    mv "${TMP_PROJECT_SETTINGS_JSON}.tmp" "${TMP_PROJECT_SETTINGS_JSON}"

    echo "${TMP_PROJECT_SETTINGS_JSON}:"
    cat "${TMP_PROJECT_SETTINGS_JSON}"

    echo "Press keys to continue"
    read

	local CLAUDE_SESSION_NAME="${1:-"code session"}"
	# inside a tart VM, this is the ip of your host
	export VM_HOST_ADDR=192.168.64.1	
	local TMP_CLAUDE_OPTS="${TMP_CLAUDE_OPTS} --remote-control \"${CLAUDE_SESSION_NAME}\""
	local TMP_CLAUDE_OPTS="${TMP_CLAUDE_OPTS} --add-dir .."
	local TMP_CLAUDE_OPTS="${TMP_CLAUDE_OPTS} --settings \"${MY_SCRIPTS_HOME}/claude/claude-settings.json\""
	local TMP_CLAUDE_CMD="claude ${TMP_CLAUDE_OPTS}"
	echo "Claude cmd: ${TMP_CLAUDE_CMD}"

	echo "Press key to continue"
    read

	eval ${TMP_CLAUDE_CMD}
}
export -f claude_run_here