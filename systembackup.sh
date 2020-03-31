#!/bin/bash

########################################################################
#
# systembackup.sh - my personal system files backup script
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

function my_rsync() {
	rsync -vrthW --del --stats --progress --chmod=u=rwx "${@}"
}

TODAY=$(date +%m%d%y)
TARGET_PATH="/external/backup/server_backup"
TARGET_MISC_PATH="${TARGET_PATH}/misc"
SVN_BACKUP_TMP_PATH="${TARGET_MISC_PATH}/svnbackup-tmp"
MY_USER_HOME=/Users/${MY_USER}
SVN_ZIP_FILE="${TARGET_MISC_PATH}/svnbackup-`date +"%Y%m%d %H%M%S"`.zip"

echo "[System Backup for $TODAY]"

mkdir -p "${TARGET_PATH}"

echo "[Cleaning out old backup]"
rm -Rf "${TARGET_MISC_PATH}"

echo "[Copying System Files]"

mkdir -p "${TARGET_MISC_PATH}"
cp /etc/paths "${TARGET_MISC_PATH}/" # this holds the path variable for all users
cp /etc/profile "${TARGET_MISC_PATH}/" # this runs for all users when they login for terminal
cp /etc/bashrc "${TARGET_MISC_PATH}/"
cp ${MY_USER_HOME}/.bash_profile "${TARGET_MISC_PATH}/"
cp -r ${MY_USER_HOME}/.ssh "${TARGET_MISC_PATH}/"
cp /etc/hosts "${TARGET_MISC_PATH}/"
cp ${MY_USER_HOME}/setupenv.sh "${TARGET_MISC_PATH}/"
my_rsync /external/misc/scripts "${TARGET_MISC_PATH}/"
brew list -l > ${TARGET_MISC_PATH}/brewlist.txt
find /Applications -d 1 | sort > "${TARGET_MISC_PATH}/apps.txt"
date > ${TARGET_MISC_PATH}/backupdate.txt

echo "[Backing up SVN]"

function backup_repository() {
	REPO_NAME=`basename ${1}`
	echo "BACKING UP REPOSITORY: ${REPO_NAME}"
	TARGET_DIRECTORY="${SVN_BACKUP_TMP_PATH}/${REPO_NAME}"
	svnadmin hotcopy "${1}" "${TARGET_DIRECTORY}" 
}

mkdir -p "${SVN_BACKUP_TMP_PATH}"
backup_repository /external/misc/svn/repo
backup_repository /external/misc/svn/oldrepo
zip -q -r "${ZIP_FILE}" "${SVN_BACKUP_TMP_PATH}"
rm -Rf "${SVN_BACKUP_TMP_PATH}"

md5tool.sh CREATE "${TARGET_MISC_PATH}"

echo "[Copying Pictures]"
md5tool.sh CREATE "${MY_USER_HOME}/Pictures"
my_rsync "${MY_USER_HOME}/Pictures" "${TARGET_PATH}/"

echo "[Copying iPhone Backups]"
md5tool.sh CREATE "${MY_USER_HOME}/MobileSync"
my_rsync "${MY_USER_HOME}/Library/Application Support/MobileSync" "${TARGET_PATH}/"

echo "[Resetting permissions]"
chmod -R 755 /scripts
chown -R root /scripts
chgrp -R wheel /scripts

chmod -R 777 /external/misc/svn

chmod -R 700 /external/backup
chown -R jason /external/backup

echo "${TODAY}" >> "${TARGET_PATH}/backupdates.txt"

echo "[End System Backup - completed in ${SECONDS} seconds]"
