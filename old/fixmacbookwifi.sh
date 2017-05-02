#!/bin/bash

########################################################################
#
# fixmacbookwifi.sh - Auto power cycle bluetooth when wifi connectivity times out.
#
#   written by Jason Baker (jason@onejasonforsale.com)
#   on github: https://github.com/codercowboy/scripts
#   more info: http://www.codercowboy.com
#
########################################################################
#
# UPDATES:
#
# 2015/08/26
#  - Initial verison.
#
########################################################################
#
# Copyright (c) 2015, Coder Cowboy, LLC. All rights reserved.
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

# To use the script, save it to your OSX computer somewhere (like Desktop), then open terminal and run it like this:
# 
#	(you only have to do this next step once, it makes the script runnable)
# 	> cd ~/Desktop && chmod +x fixmacbookwifi.sh
#
# 	(10 here is the number of seconds to check connectivity, and www.google.com is the internet (or lan) host to check)
# 	> cd ~/Desktop && ./fixmacbookwifi.sh 10 www.google.com


SLEEP_SECONDS=${1}
HOST=${2}

function print_usage {
	echo "USAGE: fixmacbookwifi.sh SLEEP_SECONDS HOST"
	echo ""
	echo "ARGUMENTS:"
	echo "   SLEEP_SECONDS - the number of seconds to wait between connectivity checks."
	echo "   HOST - the host (server) to check for connectivity, such as www.google.com, or the name of a computer on your local computer."
	echo ""
	echo "${1}"
	echo ""
	exit 1
}

if test -z "${SLEEP_SECONDS}"
then
	print_usage	"Error: Please provide SLEEP_SECONDS, so we know how long to wait before connectivity tests."
fi

if test -z "${HOST}"
then 
	print_usage "Error: Please provide HOST, so we have a server to check for connectivity."
fi

if test "" = "`which blueutil`"
then
	echo "Error, to use this script you need to install blueutil (a tool that turns bluetooth on/off on OSX)."
	echo ""
	echo "First, install homebrew, if you haven't already, homebrew is awesome: http://brew.sh/"
	echo ""
	echo "Homebrew is a 'package manager', that is, it's a tool to easily install common open source tools."
	echo ""
	echo "Then, install blueutil, like this: brew install blueutil"
	echo ""
	exit 1
fi

echo "Having OSX Wifi connectivity problems? Consider following instructions from this thread:"
echo ""
echo "http://apple.stackexchange.com/questions/118780/wifi-doesnt-work-unless-i-turn-it-off-then-on-again"
echo ""
echo "If that doesn't work, and you use a bluetooth device (such as a mouse or keyboard), try turning bluetooth off and on, and see if your internet"
echo "connection immediately picks back up."
echo ""
echo "If toggling bluetooth on/off works for you, this script will help turn bluetooth off/on automatically by "
echo "detecting when internet connectivity goes down."
echo ""
echo "Turning bluetooth on/off is non-ideal. If you can switch to a 5ghz band wifi router connection instead of 2.4ghz, that may help instead of using this script."
echo ""
echo "Note: Your bluetooth devices will be inoperative for a moment while bluetooth turns off and back on."
echo ""

echo "OK, Checking ${HOST} every ${SLEEP_SECONDS} seconds for connectivity. (quit by pressing ctrl+c)"
echo ""

echo "If you'd like to check connectivity to ${HOST} yourself, run this command: ping -c 1 ${HOST}"
echo ""

while true
do
	# try to ping the host, redirect stderr to stdout with "2>&1" because we need to capture "unknown host" output from stderr
	PING_OUTPUT=`ping -c 3 ${HOST} 2>&1`
	# extract the first "1.542" out of example output: round-trip min/avg/max/stddev = 1.542/1.542/1.542/0.000 ms
	PING_TIME_ELAPSED=`echo ${PING_OUTPUT} | grep round-trip | sed 's/.*= //' | sed 's/\/.*//'`
	# extract the "0" from example output: "1 packets transmitted, 0 packets received, 100.0% packet loss" 
	PING_PACKETS_RECEIVED=`echo ${PING_OUTPUT} | grep "packets received" | sed 's/.*transmitted, //' | sed 's/ packets.*//'`
	PING_UNKNOWN_HOST_LINE=`echo ${PING_OUTPUT} | grep "cannot resolve"`
	echo "Ping time: ${PING_TIME_ELAPSED}ms, packets received (should be more than 0): ${PING_PACKETS_RECEIVED}, (quit by pressing ctrl+c)"	
	# if zero out of three ping packets made it back, or we have an "unknown host" error, reset bluetooth
	if test "0" = "${PING_PACKETS_RECEIVED}" -o ! -z "${PING_UNKNOWN_HOST_LINE}"
	then
		echo "Detected offline, turning bluetooth off and on."
		# bluetooth commands from: http://apple.stackexchange.com/questions/47503/how-to-control-bluetooth-wireless-radio-from-the-command-line

		# turn bluetooth off:
		blueutil power 0		
		# turn bluetooth on:
		blueutil power 1
	fi
	sleep ${SLEEP_SECONDS}
	
done