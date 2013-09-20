#!/bin/bash

function logOutput {
    echo -n `date '+%Y-%m-%d-%H-%M-%S'` >> "$logFile"
    echo " $1" >> "$logFile"
}

echo "Starting evaluation..."

testFolder="tests-`date '+%Y-%m-%d-%H-%M-%S'`"
logFile="test-subject-log-`date '+%Y-%m-%d-%H-%M-%S'`"
read -p "Enter group number for test subject: " currentGroup

groupCutoff=7

logOutput "Creating test result folder...."
cp -r tests/ "$testFolder"
logOutput "Done! Folder named: $testFolder"

logOutput "User is in group: $currentGroup"


for TEST in {4..16}
do
    echo "Test number currently running: $TEST.sml"
    logOutput "Running test: $TEST.sml"
    gedit "$testFolder/test-$TEST.sml" &>/dev/null &

    while true
    do
	read -sp "Press ENTER to check test solution "
	echo -e "\nChecking..."
	logOutput "User sent the following program for testing: "
	cat "$testFolder/test-$TEST.sml" >> "$logFile"

	# (Crudely) check for syntax errors using skalpel
	syntaxTest=`skalpel $testFolder/test-$TEST.sml 2>/dev/null | grep "Parsing problem"`
	if [ "$syntaxTest" != "" ]
	then
	    logOutput "Syntax error detected and reported to user."
	    skalpel "$testFolder/test-$TEST.sml"
	else
	    # no syntax error ocurred, proceed
	    mltonCompilation=`mlton "$testFolder/test-$TEST.sml" 2>&1`
	    skalpelRun=`skalpel "$testFolder/test-$TEST.sml" 2>&1`

	    if [ "$mltonCompilation" != "" ]
	    then
		if [ "$currentGroup" == "A" ]
		then
		    if [ "$TEST" -lt 7 ]
		    then
			logOutput "Type error detected and reported to user using Skalpel."
			echo -e "$skalpelRun"
		    else
			logOutput "Type error detected and reported to user using MLton."
			echo -e "$mltonCompilation"
		    fi
		elif [ "$currentGroup" == "B" ]
		then
		    if [ "$TEST" -lt 7 ]
		    then
			logOutput "Type error detected and reported to user using MLton."
			echo -e "$mltonCompilation"
		    else
			logOutput "Type error detected and reported to user using Skalpel."
			echo -e "$skalpelRun"
		    fi
		else
		    echo "Unknown group number! Please inform test invigilator."
		    logOutput "Critical error! Test subject is in unknown group."
		    exit 1
		fi
	    else
		runTests=`./$testFolder/test-$TEST 2>&1`
		if [ "$runTests" != "complete" ]
		then
		    logOutput "Incorrect output from user function(s) detected and reported to user."
		    echo -e "$runTests"
		else
		    logOutput "Test completed."
		    echo "Test $TEST completed!"
		    break
		fi
	    fi
	fi

	echo -e "\n\n************************************************************"
	echo -e     "************************************************************"
	echo -e     "************************************************************\n\n"

    done
done

logOutput "All tests have been completed."
echo "All tests have been completed!"
