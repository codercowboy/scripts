#!/bin/bash

########################################################################
#
# maillog.sh - a script to mail a log to yourself using ssmpt
#
#   written by Jason Baker (jason@onejasonforsale.com)
#   on github: https://github.com/codercowboy/scripts
#   more info: http://www.codercowboy.com
#
########################################################################
#
# UPDATES:
#
# 200x/xx/xx
#  - Initial version
#
########################################################################
#
# To use this, you'll need to change the email info in the script by the 
# "change these!" comment below. 
#
# You'll also need to install and setup ssmtp on your system.
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

#TODO: change these! 
EMAIL_ADDRESS="your@emailaddress.com"
EMAIL_ACCOUNT_NAME="youraccountname"
EMAIL_ACCOUNT_PASSWORD="youraccountpassword"

if test "$1" = "--help" -o -z "$1"
then
	echo "Usage: maillog [file] [optional subject]"
	echo " where [file] is the log to email"
else
	echo "[Mail Log] (file: $1 )"
	
	fromline="From: ${EMAIL_ADDRESS}"
	toline="To: ${EMAIL_ADDRESS}"
	subjectline="Subject: Mailing $1"
	if test ! -z $2
	then
		subjectline="$2"
	fi
		
	(echo -e "$toline\n$fromline\n$subjectline\n\n\n"; cat "$1") | ssmtp -au${EMAIL_ACCOUNT_NAME} -ap${EMAIL_ACCOUNT_PASSWORD} ${EMAIL_ADDRESS}
fi
