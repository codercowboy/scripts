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
echo "[System Backup for $TODAY]"

TARGET_PATH="/external/backup/new/server_backup"
mkdir -p "${TARGET_PATH}"

echo "[Cleaning out old backup]"
find "${TARGET_PATH}" -maxdepth 1 -mindepth 1 -print0 | xargs -0 rm -rf

echo "[Copying System Files]"
SYSTEM_PATH="${TARGET_PATH}/system files"
mkdir -p "${SYSTEM_PATH}"
cp /etc/paths "${SYSTEM_PATH}/" # this holds the path variable for all users
cp /etc/profile "${SYSTEM_PATH}/" # this runs for all users when they login for terminal
cp /etc/bashrc "${SYSTEM_PATH}/"
MY_USER_HOME=/Users/${MY_USER}
cp ${MY_USER_HOME}/.bash_profile "${SYSTEM_PATH}/"
cp -r ${MY_USER_HOME}/.ssh "${SYSTEM_PATH}/"
cp /etc/hosts "${SYSTEM_PATH}/"
cp ${MY_USER_HOME}/setupenv.sh "${SYSTEM_PATH}/"

echo "[Backing up SVN]"

SVN_BACKUP_DIR="/${TARGET_PATH}/svnbackup"
rm -Rf "${SVN_BACKUP_DIR}"
mkdir -p "${SVN_BACKUP_DIR}"

function backup_repository() {
	REPO_NAME=`basename ${1}`
	echo "BACKING UP REPOSITORY: ${REPO_NAME}"
	TARGET_DIRECTORY="${SVN_BACKUP_DIR}/${REPO_NAME}"
	svnadmin hotcopy "${1}" "${TARGET_DIRECTORY}" 
}

backup_repository /external/misc/svn/repo
backup_repository /external/misc/svn/oldrepo

ZIP_FILE="${TARGET_PATH}/svnbackup-`date +"%Y%m%d %H%M%S"`.zip"
zip -q -r "${ZIP_FILE}" "${SVN_BACKUP_DIR}"

rm -Rf "${SVN_BACKUP_DIR}"

echo "[Copying Scripts]"
mkdir -p "${TARGET_PATH}/scripts"
my_rsync /scripts/ "${TARGET_PATH}/scripts/"

echo "[Making checksum file for backup]"
md5tool.sh CREATE "${TARGET_PATH}"

echo "[Resetting permissions]"
chmod -R 755 /scripts
chown -R root /scripts
chgrp -R wheel /scripts

chmod -R 777 /external/misc/svn

chmod -R 700 /external/backup
chown -R jason /external/backup

echo "[End System Backup - completed in ${SECONDS} seconds]"
