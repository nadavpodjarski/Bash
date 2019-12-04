#!/bin/bash

### This is a monitoring processes script

### VARIABLES
timeout=1
i=0
psUser=-e
userName=
counter=
exeName=
processCounter=0
userId=

### MAIN
# Loop until all parameters are used up
while [ "$1" != "" ]; do
 
    if [[ "$1" =~ ^-t$ ]]; then timeout="$2" ; fi
    
    if [[ "$1" =~ ^-u$ ]]; then userName="$2"; fi

    if [[ "$1" =~ ^-c$ ]]; then counter="$2"; fi

    exeName=$1

    shift

done 

## If user name is empty then ps -e is default if not than it check if exist and apply ps -u user name 
if [ ! $userName = "" ] ; then

    userId=`id -u $userName`

    if [ $userId ]; then

        psUser="-u $userName"

        echo "Pingin $exeName for user $userName"

    else

        echo "User does not exist"
        exit;

    fi

else

    echo "Pingin $exeName for any user"

fi

## If counter is null the while loop is infinte if not it will loop a -c given times and -t timeout
while [[ ! $counter || $i < $counter ]]; do

    processCounter=`ps $psUser | grep -w $exeName | wc -l`

    echo "$exeName: $processCounter instance(s) ..."

    sleep $timeout;

    i=$(($i+1))

done