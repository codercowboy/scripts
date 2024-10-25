#!/bin/bash

# provides centralized method to show help stuff for myself
# example of setting up ENV_HELP_FNS is in lib_git.sh

function help_list() {
	if [ -z "${ENV_HELP_FNS}" ]; then
		echo "No help functions are defined in ENV_HELP_FNS"
		exit 0
	fi

	# Split using IFS and read into an array
	IFS=';' read -r -a functionList <<< "$ENV_HELP_FNS"
	for fn in "${functionList[@]}"; do
		if [ -z "${fn}" ]; then
			continue
		fi
		echo 
		echo "###### Help command '${fn}' ######"
		echo 
    	eval "${fn}"
    	echo 
	done
}
export help_list;

echo "For reminders of my env setup, run 'help_list'"
