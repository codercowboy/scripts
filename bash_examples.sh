#!/bin/bash

# Great resources for learning bash:
#
# Bash Guide For Beginners: https://tldp.org/LDP/Bash-Beginners-Guide/html/
# Advanced Bash Scripting Guide: https://tldp.org/LDP/abs/html/


echo "[*** Argument Basics ***]"
# First, some example of playing with arguments passed into a script
#
# Note that the variables ${#}, ${@}, and ${1} .. ${2} etc are special variables to access
# arguments passed to your script on the command line
#
# example: > bash_examples a b c
#
# in this example the number of arguments (${#}) will be 3
# argument #1 ${1} will be 'a', arg #2 ${2} will be 'b', arg #3 will be 'c', and #4 and onward will be nothing
# argument #0 ${0} is always the name and path to your script from the current working directory 
# all arguments are accessible in the @ ${@} argument, in this example ${@} will be "a b c"
# note there's also a ${*} that is very similar but sometimes different to ${@}
# details on ${*}: https://tldp.org/LDP/abs/html/internalvariables.html#ARGLIST
# 
# another good resource on bash arguments: https://www.computerhope.com/unix/bash/shift.htm

# a popular way to test if any arguments were passed into your script
if [ ${#} -eq 0 ]; then
	echo "Usage: bash_examples.sh [some arguments]"
	exit 1 # exiting with a number other than zero means an error occurred
fi

echo "Number of arguments: ${#}"
echo "Argument #0 (this script): ${0}"
# note here that an arg list like 'a b c "d e f"' with the 'd e f' in quotes as a fourth argument will
# simply print out as 'a b c d e f'
echo "All Arguments (@ variable): ${@}" 
echo "Argument #1: ${1}"

echo ""
echo "[*** Examining Arguments Further ***]"
# some notes about bash 'if' blocks: 
# - reference: https://tldp.org/LDP/Bash-Beginners-Guide/html/chap_07.html
# - Be careful to put space between the '[' and ']' and the args between them
# - note that an if and elif need '; then' after them, but 'else' does not
# - to see what can be between the '[ ]' brackets, look at 'man test' in your terminal
#   if statements with this format imply 'test' is executed with the arguments in the bracket
#   for example here we are basically executing 'test ${#} -eq 0'
if [ ${#} -eq 0 ]; then # if number of arguments is zero
	echo "There aren't any arguments, won't loop. To see us loop, pass more arguments into the script."	
elif [ ${#} -eq 1 ]; then # if number of arguments is one
	echo "There is only one argument, won't loop. To see us loop, pass more arguments into the script."
else # all other cases (number of arguments is not zero or one)
	echo "Iterating through all arguments now."
	echo ""
	COUNTER=1
	FOUND_HELLO_ARGUMENT="false"
	while [ ${#} -ne 0 ]; do # while there are still arguments, execute this loop
		echo "Argument #${COUNTER}: ${1}"
		echo "Argument #${COUNTER} (with quotes around it): \"${1}\""
		
		# some examples of working with an argument
		CURRENT_ARG="${1}"
		if [ -z "${CURRENT_ARG}" ]; then # if the current arg is empty
			echo "The current argument is empty."
		elif [ "hello" = "${CURRENT_ARG}" ]; then
			echo "The current argument is the word 'hello'."
			FOUND_HELLO_ARGUMENT="true"
		else
			echo "The current argument is not empty, and it's not the word 'hello'."
		fi

		echo "Current Argument 0: ${0}"
		echo "Current Argument 1: ${1}"
		echo "Current Argument 2: ${2}"
		echo "Current remaining argument count: ${#}"
		echo "Remaining arguments (@ variable): ${@}"

		# increment our counter, more info: https://tldp.org/LDP/abs/html/arithexp.html		
		COUNTER=$((COUNTER+1))
		
		echo "Shifting arguments..."
		# 'shift' removes the first argument from the list of arguments passed into the shell
		# be careful because this is destructive, you can lose arguments forever if you didn't save
		# them before shifting (as far as i know..)
		shift 
		echo "Looping"
		echo ""
	done
	echo "Finished iterating through all of the arguments."
	echo "Final argument count: ${#}"
	echo "Final argument 0: ${0}"
	echo "Final argument 1: ${1}"
	echo "Final '@' variable value: ${@}"
	if [ "true" = "${FOUND_HELLO_ARGUMENT}" ]; then
		echo "We *found* an argument that said 'hello'."
	else
		echo "We *did not find* an argument that said 'hello'."
	fi
fi

# note that using 'getopts' is also a popular way to process arguments to a bash script
# https://tldp.org/LDP/abs/html/abs-guide.html#EX33

# another alternative is to use a 'for' loop (without shifts) rather than a 'while' loop with shifts
# to iterate over arguments

echo ""
echo "[*** Loops ***]"

# loop reference: https://tldp.org/LDP/Bash-Beginners-Guide/html/chap_09.html
# note that there are other types of loops such as 'until' that aren't shown in my examples here
# but those are document in the reference above

echo "+++ Loop Example: while"
COUNTER=1
while [ ${COUNTER} -ne 3 ]; do
	echo "While loop counter is now ${COUNTER}"
	# increment our counter, more info: https://tldp.org/LDP/abs/html/arithexp.html		
	COUNTER=$((COUNTER+1))
	echo "End of loop step"
done
echo "Ended while loop"
echo ""

echo "+++ Loop example: for [not for in]"
# bash has the typical for syntax you see in other languages, note the '((' and '))' around the statement
for (( i = 0; i < 5; i++ )); do
	echo "For [not for in] current value of 'i' variable: ${i}"
	echo "End of loop step"
done
echo "Ended for [not for in] loop"
echo ""

echo "+++ Loop example: for in (simple version)"
ITEMS="a b c d"
for ITEM in ${ITEMS}; do
	echo "For loop current item: ${ITEM}"
	echo "Looping..."	
done
echo "Ended for in (simple version) loop"
echo ""

echo "+++ Loop example: for in (multiline version 1 - without quotes)"
echo ""
# variables can have multiple lines in them
MULTILINE_VARIABLE="line 1
line 2
line 3"

echo "Multiline variable: ${MULTILINE_VARIABLE}"
echo ""
# this iterates weirdly in a "for" because it'll split out each piece
# of the variable with any space or newline between it
# it'll consider "line" then "1" then "line" then "2"
echo "Starting for loop for multiline variable (without quotes)"
for ITEM in ${MULTILINE_VARIABLE}; do #note we lack quotes around ${MULTILINE_VARIABLE}
	echo "For loop current item: ${ITEM}"
	echo "End of loop step"	
done
echo "Ended for in (multiline version 2) loop"
echo ""

echo "+++ Loop example: for in (multiline version 3 - with quotes around the variable in the for statement)"

echo "Multiline variable: ${MULTILINE_VARIABLE}"
echo ""
echo "Starting for loop for multiline variable that's in quotes"
for ITEM in "${MULTILINE_VARIABLE}"; do # here we have quotes around the multiline variable
	echo "For loop current item: ${ITEM}"
	echo "End of loop step"
done
echo "Ended for (multiline version 3) loop"
echo ""

echo "+++ Loop example: for in (multiline version 4 - using IFS variable)"

echo "Multiline variable: ${MULTILINE_VARIABLE}"
echo ""

# if we want our for loop to consider each line of a variable as an item
# there's a special variable called IFS that tells any for loop how to consider
# breaking up the variable, when we change IFS, we can make the loop
# consider each line rather than any part of the variable seperated by white space

# IMPORTANT!: it's very important to hold onto the current IFS value before we change it, so
# we can set it back to what it usually is after we are done
OLD_IFS="${IFS}"

# this set's the for loop to split on new lines ...
IFS=$'\n'

echo "Starting for loop after setting IFS to newline"
for ITEM in ${MULTILINE_VARIABLE}; do # here we have quotes around the multiline variable
	echo "For loop current item: ${ITEM}"
	echo "End of loop step"
done
echo "Ended for in (multiline version 4) loop"
echo ""

# IMPORTANT!: don't forget to set IFS back to what it was before!
IFS="${OLD_IFS}"

# other fun / weird builtin variables like IFS: https://tldp.org/LDP/abs/html/internalvariables.html


echo ""
echo "[*** Arrays ***]"
# arrays reference: https://tldp.org/LDP/abs/html/arrays.html

# a simple way to build an array:
SIMPLE_ARRAY[0]="Thing A"
SIMPLE_ARRAY[1]="Thing B"
SIMPLE_ARRAY[2]="Thing C"
echo "SIMPLE_ARRAY Item 1: ${SIMPLE_ARRAY[0]}, 2: ${SIMPLE_ARRAY[1]}, 3: ${SIMPLE_ARRAY[2]}"
echo "SIMPLE_ARRAY All items together with '@' syntax: ${SIMPLE_ARRAY[@]}"
echo "SIMPLE_ARRAY item count: ${#SIMPLE_ARRAY[@]}"
echo ""

# there's a fun syntax to build an array on one line
SINGLE_LINE_ARRAY=("Thing D" "Thing E" "Thing F")
echo "SINGLE_LINE_ARRAY Item 1: ${SINGLE_LINE_ARRAY[0]}, 2: ${SINGLE_LINE_ARRAY[1]}, 3: ${SINGLE_LINE_ARRAY[2]}"
echo "SINGLE_LINE_ARRAY All items together with '@' syntax: ${SINGLE_LINE_ARRAY[@]}"
echo "SINGLE_LINE_ARRAY item count: ${#SINGLE_LINE_ARRAY[@]}"
echo ""


# arrays dont have to just have strings in them
MIXED_ARRAY[0]="A string"
MIXED_ARRAY[1]=12
MIXED_ARRAY[2]="A string after the number 12 in the array."
echo "MIXED_ARRAY Item 1: ${MIXED_ARRAY[0]}, 2: ${MIXED_ARRAY[1]}, 3: ${MIXED_ARRAY[2]}"
echo "MIXED_ARRAY All items together with '@' syntax: ${MIXED_ARRAY[@]}"
echo "MIXED_ARRAY item count: ${#MIXED_ARRAY[@]}"
echo ""


# we can iterate over arrays
echo "starting for loop iterating over SIMPLE_ARRAY"
ITEM_COUNT=${#SIMPLE_ARRAY[@]}
for (( i = 0; i < ${ITEM_COUNT}; i++ )); do
	echo "SIMPLE_ARRAY item #${i} is '${SIMPLE_ARRAY[i]}'"
	echo "end of loop step"
done
echo "finished for loop"
echo ""

# we could also build arrays with loops
for (( i = 0; i < 4; i++ )); do
	LOOP_BUILT_ARRAY[${i}]="Loop Built Item #$((i+1))" 
	# note the $((i+1)) in the line above to make the items not start at "0" like the loop does
done
echo "LOOP_BUILT_ARRAY Item 1: ${LOOP_BUILT_ARRAY[0]}, 2: ${LOOP_BUILT_ARRAY[1]}, 3: ${LOOP_BUILT_ARRAY[2]}"
echo "LOOP_BUILT_ARRAY All items together with '@' syntax: ${LOOP_BUILT_ARRAY[@]}"
echo "LOOP_BUILT_ARRAY item count: ${#LOOP_BUILT_ARRAY[@]}"
echo ""


echo ""
echo "[*** Capturing Output From Commands ***]"

# when we us backticks like so `ls -alh`, that means execute "ls -alh", which is the same
# as just having a bash script line that says "ls -alh" (without quotes), but, the back ticks
# can do special things, like put the output of a command into a variable

echo "The current directory is `pwd -P`"
echo "Files in the current directory:"
ls -alh
echo "A count of files in the current directory: `ls -alh | wc -l`"
echo ""

# let's put the output of "ls -alh" into a variable
LS_OUTPUT="`ls -alh`"
echo "LIST_OF_FILES: ${LS_OUTPUT}"
echo ""

# let's iterate through the each line of LS_OUTPUT
echo "for loop looking through lines in LS_OUTPUT"
OLD_IFS="${IFS}"
IFS=$'\n'
for LINE in ${LS_OUTPUT}; do
	echo "Current line: ${LINE}"
	echo "end of loop step"
done
IFS="${OLD_IFS}" # IMPORTANT!: don't forget to set IFS back to what it was before the loop!
echo "end of loop"

# let's iterate through the actual file names, using `find .` in the for statement itself rateher than a variable
echo "for loop listing files in `pwd -P`"
OLD_IFS="${IFS}"
IFS=$'\n'

for FILE in `find .`; do
	echo "Current file: ${FILE}"
	echo "end of loop step"
done
IFS="${OLD_IFS}" # IMPORTANT!: don't forget to set IFS back to what it was before the loop!
echo "end of loop"



