#!/bin/bash

if [ "`type -t terminal_open_tab`" = "function" ]; then
	echo "Skipping import functions from lib_macos.sh, they're already sourced in this shell"
	return 0
fi

######################
# VARIOUS OSX TRICKS #
######################

# handy secret trick to emulate a command+k terminal clear which clears scrollback buffer
alias cls='printf "\33c\e[3J"'

# unlock osx "locked files" (whatever that is)
alias unlock_files='sudo chflags nouchg ${1}/*'

# auto open sublime text to the given directory or file.
# can't get this to work as an alias, oh well.
function stext { /Applications/Sublime\ Text.app/Contents/SharedSupport/bin/subl "${@}"; } 
export -f stext

# from: https://stackoverflow.com/a/7177891
# opens a new tab in terminal
function terminal_open_tab {
    osascript -e 'tell application "Terminal" to activate' \
        -e 'tell application "System Events" to tell process "Terminal" to keystroke "t" using command down'
}
export -f terminal_open_tab

function terminal_tab_execute {
    COMMAND="${1}"        
    COMMAND="tell application \"Terminal\" to do script \"${1}\" in selected tab of the front window"
    # echo "Command is: \"${COMMAND}\""
    osascript -e 'tell application "Terminal" to activate'
    osascript -e "${COMMAND}"
}
export -f terminal_tab_execute

function thin_local_snapshots {
	echo "Looking for local time machine backups to remove."
	REMOVAL_COUNT=0
	for SNAPSHOT in `tmutil listlocalsnapshots / | grep -v "Snapshots for disk"`; do
		SNAPSHOT_DATE=`echo "${SNAPSHOT}" | sed 's/com.apple.TimeMachine.//' | sed 's/.local//'`
		echo "Removing snapshot '${SNAPSHOT}', date: ${SNAPSHOT_DATE}"
		tmutil deletelocalsnapshots ${SNAPSHOT_DATE}
		REMOVAL_COUNT=$((REMOVAL_COUNT+1))
	done
	echo "Finished removing time machine backups, removed ${REMOVAL_COUNT} backups."
}
export -f thin_local_snapshots

function clean_dot_files {
	if [ -z "${1}" ]; then
		echo "USAGE: clean_dot_files [directory]"
		return;
	fi
	echo "Removing ._* files"
	find "${1}" -type f -name "._*" -exec rm -rv {} \;
	echo "Removing .DS_Store files"
	find "${1}" -type f -name ".DS_Store" -exec rm -rv {} \;
}
export -f clean_dot_files