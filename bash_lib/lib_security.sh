#!/bin/bash

if [ "`type -t ssh_setup_passwordless`" = "function" ]; then
	echo "Skipping import functions from lib_security.sh, they're already sourced in this shell"
	return 0
fi

#################
# SSH SHORTCUTS #
#################

# local port 2121 point to screen share on server
# local port 5901 is proxy for internet thru server
alias ssh_my_server='ssh -L 2121:localhost:5900 -D 5901 ${MY_USER}@${MY_SERVER}'

# open osx's screenshare via terminal
alias screenshare_my_server_ssh='open vnc://localhost:2121'
alias screenshare_my_server_local='open vnc://${MY_SERVER_NAME}._rfb._tcp.local'

# from: http://www.linuxproblem.org/art_9.html
function ssh_setup_passwordless { 
    if [ "${1}" = "" ]; then
        echo "USAGE: ssh_setup_passwordless user@host"
        return
    fi

    echo "Setting up passwordless ssh on ${1}"

	# create the key
    if [ ! -e ~/.ssh/id_rsa ]; then
        echo "generating rsa key: ~/.ssh/id_rsa"
        ssh-keygen -t rsa -q -N "" -f ~/.ssh/id_rsa
    else
        echo "rsa key for ssh already exists: ~/.ssh/id_rsa"
    fi

	HOST_PUBLIC_KEY=`cat ~/.ssh/id_rsa.pub`

	REMOTE_COMMAND="mkdir -p ~/.ssh;
		chmod 700 ~/.ssh; 
		echo \"${HOST_PUBLIC_KEY}\" >> ~/.ssh/authorized_keys;
		chmod 644 ~/.ssh/authorized_keys;"

	echo "Enter your password for the remote host, we need this to copy your public key to the remote host with ssh."

	ssh "${1}" "$REMOTE_COMMAND"

	echo "Passwordless setup is complete. You should now be able to verify the passwordless login with: ssh ${1}"
}
export -f ssh_setup_passwordless

###################
# MacOS VPN STUFF #
###################

if [ "${VPN_NAME}" = "" ]; then
	export VPN_NAME="VPN (thin)"
fi

function vpn_connect {
	echo "[CONNECTING TO VPN: ${VPN_NAME}]"
	
	local VPN_STATUS=`networksetup -showpppoestatus "${VPN_NAME}"`
	if [ "connected" = "${VPN_STATUS}" ]; then
		echo "VPN is already connected"
		return 0
	fi	

	networksetup -connectpppoeservice "${VPN_NAME}"
	sleep 10
	
	local VPN_STATUS=`networksetup -showpppoestatus "${VPN_NAME}"`
	if [ "connected" != "${VPN_STATUS}" ]; then
		echo "ERROR: VPN didn't connect, status is: ${VPN_STATUS}"
		return 1
	fi

	return 0
}

function vpn_disconnect {
	echo "[DISCONNECTING FROM VPN: ${VPN_NAME}]"
	local VPN_STATUS=`networksetup -showpppoestatus "${VPN_NAME}"`
	if [ "disconnected" = "${VPN_STATUS}" ]; then
		echo "VPN is already disconnected"
		return 0
	fi
	
	networksetup -disconnectpppoeservice "${VPN_NAME}"
	sleep 10
	
	local VPN_STATUS=`networksetup -showpppoestatus "${VPN_NAME}"`
	if [ "disconnected" != "${VPN_STATUS}" ]; then
		echo "ERROR: VPN didn't disconnect, status is: ${VPN_STATUS}"
		return 1
	fi

	return 0
}