#!/bin/bash

if [ "" = "${1}" ]; then
	echo "USAGE: finish_cherry_pick.sh COMMIT_SUMMARY"
	echo ""
	echo "  COMMIT_SUMMARY example:"
	echo "    47b549a72d - [#596] HYTE API ACI updates [Jason Baker :: 2023-11-20T16:06:31-08:00]"
	exit 1
fi

function wait_for_user() {
	local RESPONSE="n"
	while [ "y" != "${RESPONSE}" ]; do
		echo "Continue? [y to continue, ctrl+c to stop]"
		read RESPONSE
	done
}

COMMIT_HASH=`echo "${1}" | sed 's/\(.*\) - \(.*\)/\1/'`
COMMIT_MSG=`echo "${1}" | sed 's/\(.*\)\[.*::.*/\1/' | sed 's/.* - //'`


echo "[Commit Info (from input arg)]"
echo "HASH: ${COMMIT_HASH}"
echo "MESSAGE: ${COMMIT_MSG}"
echo ""

wait_for_user

# start cherry pick + print status

echo "[Cherry picking]"
echo ""
git cherry-pick -x "${COMMIT_HASH}"
echo ""

CURRENT_STATUS=`git status`

echo "[Current status]"
echo "${CURRENT_STATUS}"
echo ""

# wait for user merge if necessary

IS_MERGE_NECESSARY=`echo "${CURRENT_STATUS}" | grep "fix conflicts and run"`
if [ "" != "${IS_MERGE_NECESSARY}" ]; then
	echo "Merge is necessary, opening files in sublime text"
	FILES_TO_MERGE=`echo "${CURRENT_STATUS}" | sed '1,/to mark resolution/d' | sed 's/.*: *//'`
	#Set the field separator to new line
	IFS=$'\n'
	for FILE in ${FILES_TO_MERGE}; do
		stext "${FILE}"
	done
	echo "Cherry pick requires merge."
	echo ""
	echo "Finish merges + adding files to git index, then:"
	echo "To abort: git cherry-pick --abort"
	echo "To finish: git cherry-pick --continue"
	echo ""
	wait_for_user

	# check to see if user really has finished cherry picking

	IS_CHERRY_PICK_FINISHED=`git status | grep "git cherry-pick --abort"`
	while [ "" != "${IS_CHERRY_PICK_FINISHED}" ]; do
		echo "Cherry pick does not appear to be done."
		echo ""
		echo "Finish merges + adding files to git index, then:"
		echo "To abort: git cherry-pick --abort"
		echo "To finish: git cherry-pick --continue"
		echo ""
		wait_for_user
		IS_CHERRY_PICK_FINISHED=`git status | grep "git cherry-pick --abort"`
		echo "[Current status]"
		git status
		echo ""
	done
fi

echo ""
echo "Cherry pick appears to be finished, continuing"
echo ""

# amend commit msg

echo ""
echo "[Amending commit message]"
echo ""

MESSAGE_TEMPLATE_FILE="/tmp/git-commit-msg.txt"
if [ -e "${MESSAGE_TEMPLATE_FILE}" ]; then
	rm "${MESSAGE_TEMPLATE_FILE}"
fi
echo "[#146] Merge ${COMMIT_MSG}

Merge from 5.6.x to main.

Original commit:

    ${1}" >> "${MESSAGE_TEMPLATE_FILE}"

CHERRY_PICK_INFO=`git log -n 1 | grep "cherry picked from"`
if [ "" != "${CHERRY_PICK_INFO}" ]; then
	echo "" >> "${MESSAGE_TEMPLATE_FILE}"
	echo "${CHERRY_PICK_INFO}" >> "${MESSAGE_TEMPLATE_FILE}"
fi

git commit --amend -F "${MESSAGE_TEMPLATE_FILE}" -n

echo ""
echo "[Current commit message]"
git log -n 1
echo ""

# push to origin

CURRENT_BRANCH=`git branch --show-current`
PUSH_COMMAND="git push origin ${CURRENT_BRANCH}"
echo "Push command: ${PUSH_COMMAND}"
wait_for_user
eval "${PUSH_COMMAND}"


echo "Done"