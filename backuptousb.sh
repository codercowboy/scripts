#!/bin/bash

########################################################################
#
# backuptousb.sh - personal backup to external drive script
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

if [ -e /Volumes/USB2TBSLIMENC ]; then
  DEST=/Volumes/USB2TBSLIMENC
elif [ -e /Volumes/USBBLUE3TB ]; then
  DEST=/Volumes/USBBLUE3TB
elif [ -e /Volumes/USB2TBENC ]; then
  DEST=/Volumes/USB2TBENC
elif [ -e /Volumes/USB2TBENCRED ]; then
  DEST=/Volumes/USB2TBENCRED
elif [ -e /Volumes/USBBLK4TB ]; then
  DEST=/Volumes/USBBLK4TB
elif [ -e /Volumes/USBRED4TB ]; then
  DEST=/Volumes/USBRED4TB
else
  echo "Could not find usb drive to backup to, quitting.."
  exit 1
fi

echo "Backing up to ${DEST}"
echo "Continue? (enter to continue, ctrl+c to quit)"
read

#arg1 = source, #arg2 = target name
function backup_folder () {
  echo "[Backing up ${2}]"
  mkdir -p "${DEST}/${2}"
  my_rsync "${1}/" "${DEST}/${2}/"
  echo "[Fixing permissions for ${2}]"
  chmod -R 777 "${DEST}/${2}"
  chown -R jason "${DEST}/${2}"
  echo "[Finished backing up $2]"
}

backup_folder "/external/backup" "backup"

echo "[Checking md5 sums]"
md5tool.sh CHECKALL ${DEST}/backup

echo "Appending date to ${DEST}/backupdates.txt"

date >> ${DEST}/backupdates.txt

FREE_SPACE=`df -h | grep ${DEST} | awk '{print $4;}'`
echo "Destination stats after backup: ${DEST} (${FREE_SPACE} free)"
echo "Usage:"
du -h -d 1 ${DEST} 

