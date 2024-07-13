#!/bin/bash

########################################################################
#
# laptopbackup.sh - my personal laptop backup script
#
#   written by Jason Baker (jason@onejasonforsale.com)
#   on github: https://github.com/codercowboy/scripts
#   more info: http://www.codercowboy.com
#
########################################################################
#
# UPDATES:
#
# 2017/05/02
#  - Initial version
#
########################################################################
#
# Copyright (c) 2012, Coder Cowboy, LLC. All rights reserved.
# 
# Redistribution and use in source and binary forms, with or without
# modification, are permitted provided that the following conditions are met:
# 1. Redistributions of source code must retain the above copyright notice, this
# list of conditions and the following disclaimer.
# 2. Redistributions in binary form must reproduce the above copyright notice,
# this list of conditions and the following disclaimer in the documentation
# and/or other materials provided with the distribution.
#  
# THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS" AND
# ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED
# WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE
# DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT OWNER OR CONTRIBUTORS BE LIABLE FOR
# ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES
# (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES;
# LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND
# ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT
# (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS
# SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
#  
# The views and conclusions contained in the software and documentation are those
# of the authors and should not be interpreted as representing official policies,
# either expressed or implied.
#
########################################################################

if [ "" = "`env | grep MY_USER`" ]; then
	echo "ERROR: MY_USER system var isn't set."
	exit 1
fi

if [ "" = "`env | grep MY_SERVER`" ]; then
	echo "ERROR: MY_SERVER system var isn't set."
	exit 1
fi

MY_USER_HOME=/Users/${MY_USER}

SERVER_RSYNC_TARGET_DIR="${MY_USER}@${MY_SERVER}:/external/Backup/Laptop Backup"
LOCAL_BACKUP_DIR="${MY_USER_HOME}/Documents/Backup"
LOCAL_RSYNC_TARGET_DIR="${LOCAL_BACKUP_DIR}/Laptop Backup"
LOCAL_MUSIC_FOLDER="${MY_USER_HOME}/Documents/not time machine/Music"
mkdir -p "${LOCAL_RSYNC_TARGET_DIR}"

FLAG_BACKUP_LOCAL="false"
FLAG_BACKUP_CLEAN="false"
FLAG_BACKUP_REMOTE="false"
FLAG_BACKUP_USB="false"

if [ "${1}" = "LOCAL_ONLY" ]; then
	FLAG_BACKUP_LOCAL="true"
	FLAG_BACKUP_CLEAN="true"
elif [ "${1}" = "REMOTE_ONLY" ]; then
	FLAG_BACKUP_REMOTE="true"
elif [ "${1}" = "USB_ONLY" ]; then
	FLAG_BACKUP_USB="true"
elif [ "${1}" = "FULL" ]; then
	FLAG_BACKUP_CLEAN="true"
	FLAG_BACKUP_LOCAL="true"
	FLAG_BACKUP_REMOTE="true"
elif [ "${1}" = "USB" ]; then
	FLAG_BACKUP_CLEAN="true"
	FLAG_BACKUP_LOCAL="true"
	FLAG_BACKUP_USB="true"
elif [ "${1}" = "CLEAN" ]; then
	FLAG_BACKUP_CLEAN="true"
else 
	echo
	echo "USAGE: laptopbackup.sh [MODE]"
	echo "  MODE OPTIONS: FULL, USB, USB_ONLY, LOCAL_ONLY, REMOTE_ONLY"
	echo
	echo "  FULL - LOCAL_ONLY + remote backup"
	echo "  LOCAL_ONLY - CLEAN + backup locally only"
	echo "  USB - LOCAL_ONLY + USB"
	echo "  REMOTE_ONLY - backup from pre-existing local backup to remote, don't backup to local first"
	echo "  USB_ONLY - backup from pre-existing local backup to usb, don't backup to local first"
	echo "  CLEAN - clean out maven targets"
	echo
	exit 1
fi

function my_rsync() {
	rsync -vrthW --del --stats --progress --chmod=u=rwx "${@}"
}

#make for's argument seperator newline only
IFS=$'\n'

function run_backup_job() {
	TARGET_DIR="${1}"
	RSYNC_ARGS="${2}"

	echo "Backing up to: ${TARGET_DIR}"
	mkdir -p "${TARGET_DIR}"
	
	my_rsync ${RSYNC_ARGS} "${LOCAL_BACKUP_DIR}/" "${TARGET_DIR}/backup/"

	md5tool.sh CREATE "${MY_USER_HOME}/Pictures/"
	my_rsync ${RSYNC_ARGS} "${MY_USER_HOME}/Pictures/" "${TARGET_DIR}/Pictures/"		

	md5tool.sh CREATE "${MY_USER_HOME}/Music/GarageBand/"
	my_rsync ${RSYNC_ARGS} "${MY_USER_HOME}/Music/GarageBand/" "${TARGET_DIR}/GarageBand/"		

	md5tool.sh CREATE "${MY_USER_HOME}/Movies"
	my_rsync ${RSYNC_ARGS} "${MY_USER_HOME}/Movies/" "${TARGET_DIR}/Movies/"			

	md5tool.sh CREATE "${MY_USER_HOME}/Dropbox"
	my_rsync ${RSYNC_ARGS} "${MY_USER_HOME}/Dropbox/" "${TARGET_DIR}/Dropbox/"			

	md5tool.sh CREATE "${MY_USER_HOME}/Documents/win98vm"
	my_rsync ${RSYNC_ARGS} "${MY_USER_HOME}/Documents/win98vm/" "${TARGET_DIR}/win98vm/"		

	md5tool.sh CREATE "${MY_USER_HOME}/Library/Application Support/MobileSync"
	my_rsync ${RSYNC_ARGS} "${MY_USER_HOME}/Library/Application Support/MobileSync/" "${TARGET_DIR}/MobileSync/"

	#md5tool.sh CREATE "/Applications/Wine"
	#my_rsync ${RSYNC_ARGS} "/Applications/Wine" "${TARGET_DIR}/wine/"			
}

# arg 1 is target drive
function backup_music() {
	TARGET_MUSIC_FOLDER=""

	if [ ! -e "${LOCAL_MUSIC_FOLDER}" ]; then
		echo "Not backing up music, can't find expected local music dir: ${LOCAL_MUSIC_FOLDER}"
		return
	fi

	if [ -e "${1}/Music" ]; then
		TARGET_MUSIC_FOLDER="${1}/Music"
	elif [ -e "${1}/Garbage/Music" ]; then
		TARGET_MUSIC_FOLDER="${1}/Garbage/Music"
	else
		echo "Not backing up music, can't find target music folder."
		return
	fi

	echo "[Backing up music]"
	echo "  Source music Dir: ${LOCAL_MUSIC_FOLDER}"
	echo "  Target music dir: ${TARGET_MUSIC_FOLDER}"	

	my_rsync "${LOCAL_MUSIC_FOLDER}/" "${TARGET_MUSIC_FOLDER}/"
	echo "[Finished Backing up music]"
}

if test ${FLAG_BACKUP_USB} = "true"; then
	echo "[Starting USB Backup Step.]"
	USB_DEST=""
	for FILE in `find /Volumes -name "USB*" -maxdepth 1`; do
		echo "Back up to ${FILE}? ('YES' to select, enter to skip)"
		echo -n "> "
		read ANSWER
		if [ "${ANSWER}" = "YES" ]; then
			USB_DEST="${FILE}"			
			break
		fi
		echo "Skipping this drive. You did not answer 'YES', you said: ${ANSWER}"
	done		

	if [ "${USB_DEST}" = "" ]; then
		echo "Skipping backup to USB, could not find valid USB target to backup to."
		exit 1
	else
		echo "Backing up to ${USB_DEST}"
	fi
fi #end usb dest selection section

# arg 1 is file
function remove_file() {
	if [ -e "${1}" ]; then
		echo "Removing file: ${1}"
		rm -Rf "${1}"
	fi
}

if [ "${FLAG_BACKUP_CLEAN}" = "true" ]; then
	echo "[Starting Clean Backup Step.]"

	for FILE in `find ${CODE} -type d -name target`; do
		echo "Removing: ${FILE}"
		rm -Rf "${FILE}"		
	done

	for FILE in `find ${CODE} -type d -name node_modules -d 3`; do
		echo "Removing: ${FILE}"
		rm -Rf "${FILE}"
	done

	remove_file "${CONSOLE_HOME}/webapp-parent/webapp-itests/data.old"
	remove_file "${CONSOLE_HOME}/webapp-parent/webapp-itests/data/log"
	remove_file "${CONSOLE_HOME}/webapp-parent/webapp-itests/data/hyte/v4/cfg/b"
	remove_file "${CONSOLE_HOME}/webapp-parent/webapp-itests/data/hyte/v4/sched"
	remove_file "${CONSOLE_HOME}/webapp-parent/webapp-itests/data/hyte/v4/msg"
	remove_file "${CONSOLE_HOME}/webapp-parent/webapp-itests/etc.old"
	
	echo "[Finished Clean Backup Step.]"
fi

if [ "${FLAG_BACKUP_LOCAL}" = "true" ]; then
	echo "[Starting Local Backup Step.]"

	echo "backing up misc"
	mkdir -p "${LOCAL_RSYNC_TARGET_DIR}/System/"
	MISC_FOLDER="${LOCAL_RSYNC_TARGET_DIR}/System/misc"
	rm -Rvf ${MISC_FOLDER}
	mkdir -p ${MISC_FOLDER}

	cp /etc/hosts ${MISC_FOLDER}/
	cp /etc/profile ${MISC_FOLDER}/
	cp /etc/paths ${MISC_FOLDER}/
	cp ${MY_USER_HOME}/.bash_profile ${MISC_FOLDER}/
	cp ${MY_USER_HOME}/.bash_logout ${MISC_FOLDER}/
	cp ${MY_USER_HOME}/setupenv.sh ${MISC_FOLDER}/
	cp ${MY_USER_HOME}/.gitconfig ${MISC_FOLDER}/
	cp -r ${CODE}/tools/git ${MISC_FOLDER}/
	cp -r ${MY_USER_HOME}/.ssh ${MISC_FOLDER}/
	cp -r ${MY_USER_HOME}/.vnc ${MISC_FOLDER}/
	cp -r ${MY_USER_HOME}/.subversion ${MISC_FOLDER}/
	cp -r ${MY_USER_HOME}/.config/filezilla ${MISC_FOLDER}/	
	cp ${MY_USER_HOME}/.m2/settings.xml ${MISC_FOLDER}/maven.settings.xml
	
	mkdir -p ${MISC_FOLDER}/sublimetext
	cp -r "${MY_USER_HOME}/Library/Application Support/Sublime Text 3/Packages/User" "${MISC_FOLDER}/sublimetext"
	rm ${MISC_FOLDER}/automator_services.zip
	zip -r ${MISC_FOLDER}/automator_services.zip "${MY_USER_HOME}/Library/Services/"
	brew leaves > ${MISC_FOLDER}/brewlist.txt
	defaults read /Library/Preferences/com.apple.TimeMachine SkipPaths > ${MISC_FOLDER}/timemachine_excludes.txt
	find /Applications -maxdepth 1 | sort > "${MISC_FOLDER}/apps.txt"
	date > "${LOCAL_RSYNC_TARGET_DIR}/backupdate.txt"

	echo "backing up code"
	my_rsync "${MY_USER_HOME}/Documents/code" "${LOCAL_RSYNC_TARGET_DIR}/"

	echo "backing up system stuff (thunderbird, mail, messages, voice memos, fonts)"
	mkdir -p "${LOCAL_RSYNC_TARGET_DIR}/System/"
	my_rsync "${MY_USER_HOME}/Library/Thunderbird" "${LOCAL_RSYNC_TARGET_DIR}/System/"
	my_rsync "${MY_USER_HOME}/Library/Mail" "${LOCAL_RSYNC_TARGET_DIR}/System/"
	my_rsync "${MY_USER_HOME}/Library/Messages" "${LOCAL_RSYNC_TARGET_DIR}/System/"
	mkdir -p "${LOCAL_RSYNC_TARGET_DIR}/voicememos/"
	my_rsync "${MY_USER_HOME}/Library/Application Support/com.apple.voicememos/" "${LOCAL_RSYNC_TARGET_DIR}/System/voicememos/"	
	my_rsync "${MY_USER_HOME}/Library/Fonts" "${LOCAL_RSYNC_TARGET_DIR}/System/"
	
	echo "backing up downloads"
	my_rsync "${MY_USER_HOME}/Downloads" "${LOCAL_RSYNC_TARGET_DIR}/"

	echo "backing up games (minecraft, terraria, factorio)"
	mkdir -p "${LOCAL_RSYNC_TARGET_DIR}/Games/"
	mkdir -p "${LOCAL_RSYNC_TARGET_DIR}/Games/Minecraft"
	my_rsync "${MY_USER_HOME}/Library/Application Support/minecraft/screenshots/" "${LOCAL_RSYNC_TARGET_DIR}/Games/Minecraft/screenshots/"
	my_rsync "${MY_USER_HOME}/Library/Application Support/minecraft/saves/" "${LOCAL_RSYNC_TARGET_DIR}/Games/Minecraft/saves/"	
	my_rsync "${MY_USER_HOME}/Library/Application Support/Terraria" "${LOCAL_RSYNC_TARGET_DIR}/Games/"
	my_rsync "${MY_USER_HOME}/Library/Application Support/factorio" "${LOCAL_RSYNC_TARGET_DIR}/Games/"

	echo "Creating md5 in ${LOCAL_RSYNC_TARGET_DIR}"
	md5tool.sh CREATE "${LOCAL_RSYNC_TARGET_DIR}"
	echo "[Finished Local Backup Step.]"
else
	echo "Skipping local backup step."
fi #end local backup section

if  [ "${FLAG_BACKUP_REMOTE}" = "true" ]; then
	echo "[Starting Remote Backup Step.]"
	run_backup_job "${SERVER_RSYNC_TARGET_DIR}" "-e ssh"
	echo "[Finished Remote Backup Step.]"
else 
	echo "Skipping rsync to remote step."
fi #end blunx backup section

if [ "${FLAG_BACKUP_USB}" = "true" ]; then
	HOSTNAME=`hostname -s`
	USB_BACKUP_DIR="${USB_DEST}/Laptop Backup/${HOSTNAME}"
	echo "[Starting USB Backup Step.]"
	echo "Backing up to USB drive: ${USB_BACKUP_DIR}"

	mkdir -p "${USB_BACKUP_DIR}"

	run_backup_job "${USB_BACKUP_DIR}" ""

	backup_music "${USB_DEST}"
	
	md5tool.sh CHECKALL "${USB_BACKUP_DIR}/"
	echo "[Finished USB Backup Step.]"
else 
	echo "Skipping backup to usb step."
fi #end usb backup section

echo "fixing permissions"
chmod -R 700 "${LOCAL_RSYNC_TARGET_DIR}"
chown -R ${MY_USER} "${LOCAL_RSYNC_TARGET_DIR}"

echo "backup size: `du -h -d 0 '${LOCAL_RSYNC_TARGET_DIR}'`"
echo "hd status: `df -H / | grep -v Capacity | awk '{print $4;}'`"
echo "finished in ${SECONDS} seconds at `date`"

exit 0