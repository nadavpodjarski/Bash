#!/bin/bash

# This is a decompress archives script for 4 options unzip,gunzip,bunzip,uncompress 
# To add more decompress options, need to check how the file command returns the type of the wanted method and add a case for it. 


### VARIABLES
isRecursive=false
isVerbose=false
successCounter=0
failuresCounter=0
userInputArray=
userInputArrayLength=


### FUNCTIONS

## Handle matching case
caseHandler() {

    if $1 "$2" ; then successHandler "$2" ; else  echo "$2 decompressed failed" ; fi

}

# Handle details when match method and success decompress  
successHandler() {
     
   let successCounter++

    if $isVerbose ; then echo "unpacking $1 ..." ; fi 

}

# Handle details when not matching any method
failuresHandler() {

    let failuresCounter++

    if $isVerbose ; then echo "ignoring $1"; fi

} 

# Handle directory match
directoryHandler(){

    if $isRecursive ; then

        while IFS= read -r -d '' FILE; do
            "$1" "$FILE"
        done < <(find . -mindepth 2 -type f -name '*' -print0) 

    else 

        while IFS= read -r -d '' FILE; do
           "$1" "$FILE"
        done < <(find . -mindepth 2 -maxdepth 2 -type f -name '*' -print0) 
    
    fi
}



# Receive a file or direcotry and run a case statement to check for the correct method to apply or non
goUnpack(){
    
    local fileName="$1"
    local fileType=`file -b "$fileName"`
    case "$fileType" in 

        ## If there is a match, the  decompress maethod  will be passed as an argument $1 and the filename as $2 to case hanlder function

        gzip*)

           caseHandler "gunzip -f -k" "$fileName"
            
        ;;

        bzip2*)

           caseHandler "bunzip2 -f -k" "$fileName"

        ;;
        
        Zip*)

           caseHandler "unzip -o -q" "$fileName" 
            
        ;;

        compress"'"d*)
            
            if [[ ! "$fileName" = *.gz ]] ; then mv "$fileName" "$fileName.gz" ; fi   

            caseHandler "gunzip -f -k" "$fileName"

        ;;
        
        directory)   

            directoryHandler goUnpack

        ;;
        *)
            failuresHandler "$fileName"  
        ;; 

    esac
   
}

### MAIN
# Create an array from user input and check for switches regardless position
# Loop until all parameters are used up
while [ "$1" != "" ]; do

    userInputArray=("${userInputArray[@]}" "$1")

    if [[ "$1" =~ ^-r$ ]]; then isRecursive=true; fi

    if [[ "$1" =~ ^-v$ ]]; then isVerbose=true; fi

    shift

done 

userInputArrayLength=${#userInputArray[@]}

for (( i=1 ; i < $userInputArrayLength ; i++)); do

    if [[ -f ${userInputArray[i]} || -d  ${userInputArray[i]} ]]; then
        
        goUnpack "${userInputArray[i]}"

    elif [[ ! "${userInputArray[i]}" =~ -v|-r ]]; then

         echo  "${userInputArray[i]} - file or directory does not exist"   

    fi

done

echo "Decompressed $successCounter archives(s)"

exit $failuresCounter 










