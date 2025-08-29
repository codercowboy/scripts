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

alias vlc_play_folder='/Applications/VLC.app/Contents/MacOS/VLC ${@}'

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
    local COMMAND="${1}"        
    COMMAND="tell application \"Terminal\" to do script \"${1}\" in selected tab of the front window"
    # echo "Command is: \"${COMMAND}\""
    osascript -e 'tell application "Terminal" to activate'
    osascript -e "${COMMAND}"
}
export -f terminal_tab_execute

function thin_local_snapshots {
	tmutil deletelocalsnapshots /	
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

#!/bin/bash

# ramdisk references: 
#   https://superuser.com/questions/456803/create-ram-disk-mount-to-specific-folder-in-osx
#   https://superuser.com/questions/1480144/creating-a-ram-disk-on-macos

# example usage: 'create_ramdisk 2048 RAMDISK4' - this creates a 2GB RAM disk in /Volumes/RAMDISK4

# arg 1 is size in MB
# arg 2 is name of volume
function create_ramdisk {
	local RAMFS_SIZE_MB="${1}"
	local RAMDISK_VOLUME="${2}"
	if [ -z "${RAMFS_SIZE_MB}" -o -z "${RAMDISK_VOLUME}" ]; then
		echo "USAGE: create_ramdisk [Disk Size in MB] [Volume Name]"
		return 1
	fi

	echo "Creating ${RAMFS_SIZE_MB}MB ramdisk in /Volumes/${RAMDISK_VOLUME}"

	local RAMFS_SIZE_SECTORS=$((${RAMFS_SIZE_MB}*1024*1024/512)) # a sector is 512 bytes
	local RAMFS_DEV_DIR=`hdiutil attach -nomount ram://${RAMFS_SIZE_SECTORS}`

	echo "RAM Disk dev dir is: ${RAMFS_DEV_DIR}"
	echo "If something goes wrong, see if the Ram Disk is still mounted with 'hdiutil info'"
	echo "If it's still mounted, unmount it with 'hdiutil eject ${RAMFS_DEV_DIR}'"

	echo "Now creating APFS volume '/Volumes/${RAMDISK_VOLUME}'"
	diskutil apfs create ${RAMFS_DEV_DIR} "${RAMDISK_VOLUME}"

	if [ ! -e "/Volumes/${RAMDISK_VOLUME}" ]; then
		echo "ERROR: the disk wasn't mounted?"
		echo "It's expected to be '/Volumes/${RAMDISK_VOLUME}', but isn't there."
		echo "If something went wrong, see if the RAM Disk is still mounted with 'hdiutil info'"
		echo "If it's still mounted, unmount it with 'hdiutil eject ${RAMFS_DEV_DIR}'"
		return 1
	fi

	echo "Now disabling spotlight indexing on volume"
	touch "/Volumes/${RAMDISK_VOLUME}/.metadata_never_index"

	echo "If file system was succesfully created, it's accessible at /Volumes/${RAMDISK_VOLUME}"
	echo "Eject it in finder, or with 'diskutil eject /Volumes/${RAMDISK_VOLUME}'"

	return 0
}
export -f create_ramdisk