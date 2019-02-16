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

SERVER_RSYNC_TARGET_DIR=${MY_USER}@${MY_SERVER}:/external/backup/laptop_backup

LOCAL_RSYNC_TARGET_DIR=${MY_USER_HOME}/Documents/laptop_backup
mkdir -p ${LOCAL_RSYNC_TARGET_DIR}

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
	
	my_rsync ${RSYNC_ARGS} "${LOCAL_RSYNC_TARGET_DIR}/" "${TARGET_DIR}/backup/"

	echo "backing up stuff to move to server"
	md5tool.sh CREATE "${MY_USER_HOME}/Documents/move_to_server/"
	my_rsync ${RSYNC_ARGS} "${MY_USER_HOME}/Documents/move_to_server/" "${TARGET_DIR}/move_to_server/"
			
	md5tool.sh CREATE "${MY_USER_HOME}/Pictures/"
	my_rsync ${RSYNC_ARGS} "${MY_USER_HOME}/Pictures" "${TARGET_DIR}/Pictures/"		

	md5tool.sh CREATE "${MY_USER_HOME}/Movies"
	my_rsync ${RSYNC_ARGS} "${MY_USER_HOME}/Movies/" "${TARGET_DIR}/Movies/"			

	md5tool.sh CREATE "${MY_USER_HOME}/Dropbox"
	my_rsync ${RSYNC_ARGS} "${MY_USER_HOME}/Dropbox/" "${TARGET_DIR}/Dropbox/"			

	md5tool.sh CREATE "${MY_USER_HOME}/VirtualBox VMs/win98"
	my_rsync ${RSYNC_ARGS} "${MY_USER_HOME}/VirtualBox VMs/win98/" "${TARGET_DIR}/win98vm/"		

	md5tool.sh CREATE "/Applications/Wine"
	my_rsync ${RSYNC_ARGS} "/Applications/Wine" "${TARGET_DIR}/wine/"	

	date > "${TARGET_DIR}/backupdate.txt"	
}

if test ${FLAG_BACKUP_USB} = "true"; then
	echo "[Starting USB Backup Step.]"
	USB_DEST=""
	if [ -e /Volumes/USBBLUE3TB ]; then
	  USB_DEST=/Volumes/USBBLUE3TB		  
	elif [ -e /Volumes/USBRED4TB ]; then
	  USB_DEST=/Volumes/USBRED4TB
	elif [ -e /Volumes/USBBLK4TB ]; then
	  USB_DEST=/Volumes/USBBLK4TB
	elif [ -e /Volumes/USB2TBSSD ]; then
	  USB_DEST=/Volumes/USB2TBSSD
	elif [ -e /Volumes/USB128GB ]; then
	  USB_DEST=/Volumes/USB128GB
	fi		

	if [ "${USB_DEST}" != "" ]; then
		echo "Backing up to ${USB_DEST}"
		echo "Continue? ('YES' to continue)"
		read ANSWER

		if [ "${ANSWER}" != "YES" ]; then
			echo "Skipping backup to USB, you did not answer 'YES', you said: ${ANSWER}"
			exit 1
		fi
	else
		echo "Skipping backup to USB, could not find valid USB target to backup to."
		exit 1
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
	rm -Rvf ${LOCAL_RSYNC_TARGET_DIR}/misc
	mkdir -p ${LOCAL_RSYNC_TARGET_DIR}/misc
	cp ${MY_USER_HOME}/.bash_profile ${LOCAL_RSYNC_TARGET_DIR}/misc/
	cp -r ${MY_USER_HOME}/.ssh ${LOCAL_RSYNC_TARGET_DIR}/misc/
	cp -r ${MY_USER_HOME}/.vnc ${LOCAL_RSYNC_TARGET_DIR}/misc/
	cp -r ${MY_USER_HOME}/.subversion ${LOCAL_RSYNC_TARGET_DIR}/misc/
	cp /etc/hosts ${LOCAL_RSYNC_TARGET_DIR}/misc/
	cp ${MY_USER_HOME}/.m2/settings.xml ${LOCAL_RSYNC_TARGET_DIR}/misc/maven.settings.xml
	cp /etc/profile ${LOCAL_RSYNC_TARGET_DIR}/misc/
	cp /etc/paths ${LOCAL_RSYNC_TARGET_DIR}/misc/
	cp ${MY_USER_HOME}/setupenv.sh ${LOCAL_RSYNC_TARGET_DIR}/misc/
	cp ${MY_USER_HOME}/.gitconfig ${LOCAL_RSYNC_TARGET_DIR}/misc/
	cp ${MY_USER_HOME}/.gitignore_global ${LOCAL_RSYNC_TARGET_DIR}/misc/
	rm ${LOCAL_RSYNC_TARGET_DIR}/misc/automator_services.zip
	zip -r ${LOCAL_RSYNC_TARGET_DIR}/misc/automator_services.zip "${MY_USER_HOME}/Library/Services/"
	date > ${LOCAL_RSYNC_TARGET_DIR}/backupdate.txt

	echo "backing up code"
	my_rsync "${MY_USER_HOME}/Documents/code/" "${LOCAL_RSYNC_TARGET_DIR}/code/"

	echo "backing up thunderbird"
	my_rsync "${MY_USER_HOME}/Library/Thunderbird/" "${LOCAL_RSYNC_TARGET_DIR}/Thunderbird/"

	echo "backing up downloads"
	my_rsync "${MY_USER_HOME}/Downloads/" "${LOCAL_RSYNC_TARGET_DIR}/Downloads/"

	echo "backing up mail"
	my_rsync "${MY_USER_HOME}/Library/Mail/" "${LOCAL_RSYNC_TARGET_DIR}/Mail/"

	echo "backing up messages"
	my_rsync "${MY_USER_HOME}/Library/Messages/" "${LOCAL_RSYNC_TARGET_DIR}/Messages/"

	echo "backing up minecraft"
	mkdir -p "${LOCAL_RSYNC_TARGET_DIR}/Minecraft"
	my_rsync "${MY_USER_HOME}/Library/Application Support/minecraft/screenshots/" "${LOCAL_RSYNC_TARGET_DIR}/Minecraft/screenshots/"
	my_rsync "${MY_USER_HOME}/Library/Application Support/minecraft/saves/" "${LOCAL_RSYNC_TARGET_DIR}/Minecraft/saves/"	

	echo "Backing up fonts"
	cp -r ${MY_USER_HOME}/Library/Fonts ${LOCAL_RSYNC_TARGET_DIR}/

	echo "Backing Up Voice Memos"
	cp -r "${MY_USER_HOME}/Music/iTunes/iTunes Media/Voice Memos" ${LOCAL_RSYNC_TARGET_DIR}/

	echo "backing up terraria"
	my_rsync "${MY_USER_HOME}/Library/Application Support/Terraria/Worlds/" "${LOCAL_RSYNC_TARGET_DIR}/Terraria/"

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
	echo "[Starting USB Backup Step.]"
	echo "Backing up to USB drive: ${USB_DEST}"

	USB_BACKUP_DIR="${USB_DEST}/laptop_backup"
	mkdir -p "${USB_BACKUP_DIR}"

	run_backup_job "${USB_BACKUP_DIR}" ""
	
	md5tool.sh CHECKALL "${USB_BACKUP_DIR}/"
	echo "[Finished USB Backup Step.]"
else 
	echo "Skipping backup to usb step."
fi #end usb backup section

echo "fixing permissions"
chmod -R 700 ${LOCAL_RSYNC_TARGET_DIR}
chown -R ${MY_USER} ${LOCAL_RSYNC_TARGET_DIR}

echo "backup size: `du -h -d 0 ${LOCAL_RSYNC_TARGET_DIR}`"
echo "hd status: `df -h | grep disk1 | awk '{print $4;}'`"
echo "finished in ${SECONDS} seconds"

exit 0