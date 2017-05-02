#!/bin/bash

########################################################################
#
# osxrotatelogs.sh - archive a gzipped timestamped version of logs
#
#   written by Jason Baker (jason@onejasonforsale.com)
#   on github: https://github.com/codercowboy/scripts
#   more info: http://www.codercowboy.com
#
########################################################################
#
# UPDATES:
#
# 2007/11/16
#  - initial version
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

function print_usage()
{
    echo "osxrotatelogs.sh archives gzipped timestamped logs on OS X machines"
    echo
    echo "USAGE"
    echo "  osxrotatelogs.sh LOGS_PATH ARCHIVE_PATH"
    echo
    echo "NOTES"
    echo "  LOGS_PATH    - the path to your logs directory i.e. /var/log"
    echo
    echo "  ARCHIVE_PATH - the path to archive logs in."
    echo "                 i.e. /Users/jason/Desktop/archivedlogs"
    echo
    echo "EXIT STATUS"
    echo "  0 - success"
    echo "  1 - errors occurred"
    echo
    echo
    echo "  ERROR: $1"
    echo
    exit 1
} 

if test -z "$1" -o -z "$2"
then
    print_usage "Invalid number of arguments specified."
fi

if test ! -d "$1"
then
    print_usage "Logs path is not a directory: $1"
fi

if test ! -d "$2"
then
    print_usage "Archive path is not a directory: $2"
fi

if test ! -w "$2"
then
    print_usage "Archive path is not writable: $2"
fi 

echo "[osxrotatelogs.sh]"
echo " logs directory: $1"
echo " archive directory: $2"

LOG_FILES=`find "$1" -name "*.0.gz"`

# now LOG_FILES contains a list of the log files we want to timestamp and save.

# each entry in LOG_FILES is seperated by a newline character
# the following line makes bash's for opererator seperate entries by newline
#     rather than by space
IFS=$'\n' 

for LOG_FILE in $LOG_FILES
do
    echo " processing: $LOG_FILE" 

    # the file in $LOG_FILE is going to be something like /blah/blah/logfile.0.gz
    # we need to:
    #   1) unzip the gz
    #   2) copy the logfile to a renamed dated log file such as logfile.2007-11-16
    #   3) rezip the gz for the logfile.0.gz (this will delete logfile.0)
    #   4) gzip the logfile.2007-11-16 into logfile.2007-11-16.gz 
    #        (this will delete the logfile.2007-11-16)
    #   5) copy the logfile.2007-11.16 to wherever the user specied


    #example $LOG_FILE /blah/blah/logfile.0.gz
    BASE_DIR=`dirname "$LOG_FILE"` 
    # $BASE_DIR is now '/blah/blah'
    
    BASE_FILENAME=`basename "$LOG_FILE" "0.gz"` 
    # $BASE_FILENAME is now 'logfile.'
    
    FILE_MODIFIED_TIME=`stat -f "%m" "$LOG_FILE"`
    FILES_DATE=`date -r $FILE_MODIFIED_TIME +"%Y-%m-%d"` 
    # $FILES_DATE is something like '2007-11-16'
    
    UNCOMPRESSED_FILE="$BASE_DIR/${BASE_FILENAME}0"
    # $UNCOMPRESSED_FILE is now like '/blah/blah/logfile.0'
    
    NEW_FILE="$BASE_DIR/$BASE_FILENAME$FILES_DATE" 
    # $NEW_FILE is now like '/blah/blah/logfile.2007-11-16'
    
    echo "   unzipping $LOG_FILE"
    gunzip -f "$LOG_FILE"
    
    echo "   copying log file to $NEW_FILE"
    cp "$UNCOMPRESSED_FILE" "$NEW_FILE"
    
    echo "   rezipping $UNCOMPRESSED_FILE"
    gzip -f "$UNCOMPRESSED_FILE"
    
    echo "   zipping $NEW_FILE"
    gzip -f "$NEW_FILE"
    
    echo "   copying $NEW_FILE.gz to $2"
    cp "$NEW_FILE.gz" "$2"
done

exit $exitcode