#!/bin/bash

########################################################################
#
# bankcsvparse.sh - converts BOA CSV downloads into legible text.
#
#   written by Jason Baker (jason@onejasonforsale.com)
#   on github: https://github.com/codercowboy/scripts
#   more info: http://www.codercowboy.com
#
########################################################################
#
# UPDATES:
# 
# 2017/06/06
# - Initial Version
#
########################################################################
#
# Copyright (c) 2017, Coder Cowboy, LLC. All rights reserved.
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

if test -z "$1"; then
	echo "usage: bankcsvparse.sh [directory]"
	exit 1
fi

#make for's argument seperator newline only
IFS=$'\n'

for FILE in `find "${1}" -type f | grep ".csv"`; do
	echo "file: ${FILE}"
	for LINE in `cat "${1}/${FILE}"`; do
		# echo "${LINE}"
		# example: 05/01/2017,24692167119000174108660,"Amazon.com AMZN.COM/BILLWA","AMZN.COM/BILL WA ",-25.43
		LINE=`echo "${LINE}" | sed 's/\/2017[^"]*"/ /'`
		# example: 05/01 Amazon.com AMZN.COM/BILLWA","AMZN.COM/BILL WA ",-25.43
		LINE=`echo "${LINE}" | sed 's/".*,/ : /'`
		# example: 05/01 Amazon.com AMZN.COM/BILLWA : -25.43

		# these are known replacements
		LINE=`echo "${LINE}" | sed 's/ .*Amazon[^:]*/ Amazon /'`
		LINE=`echo "${LINE}" | sed 's/ .*AMAZON[^:]*/ Amazon /'`
		LINE=`echo "${LINE}" | sed 's/ .*TXTAG[^:]*/ TXTAG /'`
		LINE=`echo "${LINE}" | sed 's/ .*ITUNES[^:]*/ ITUNES /'`
		LINE=`echo "${LINE}" | sed 's/ .*THUNDERCLOUD[^:]*/ THUNDERCLOUD /'`
		LINE=`echo "${LINE}" | sed 's/ .*HEB[^:]*/ HEB /'`

		LINE=`echo "${LINE}" | sed 's/ ARLINGTON TX//'`
		LINE=`echo "${LINE}" | sed 's/ ROUND ROCK TX//'`
		LINE=`echo "${LINE}" | sed 's/ Round Rock TX//'`
		LINE=`echo "${LINE}" | sed 's/ AUSTIN TX//'`
		LINE=`echo "${LINE}" | sed 's/ Austin TX//'`
		echo "${LINE}"

	done	

done