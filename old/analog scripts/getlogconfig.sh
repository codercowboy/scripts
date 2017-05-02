#!/bin/bash

#make for's argument seperator newline only 
IFS=$'\n' 

if test -z "${1}"
then
    echo "USAGE: getlogconfig.sh [operation] [path]"
    echo ""
    echo "OPERATIONS"
    echo "  find-sites"
    echo "  find-years"
    exit 0
fi

if test  "${1}" = "find-sites"
then
    SITES=`ls "${2}"`
    for SITE in ${SITES}
    do
      echo ${SITE}
    done
    exit 0
fi

if test "${1}" = "find-years"
then
    FILES=`find "${2}" -type f`
    for FILE in ${FILES}
    do
      YEAR=`echo "${FILE}" |  sed 's/.*\.\([0-9]*\)\-.*/\1/'`
      YEARS="${YEAR}\n${YEARS}"
    done

    echo -n -e ${YEARS} | uniq

    exit 0
fi

echo "Unsupported operation: ${1}"