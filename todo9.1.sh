#!/bin/bash

if [ ${#} != 1 ] 
then
	echo "Invalid Arguments!"
	exit 30
fi

if [ ! -f ${1} ] 
then
	echo "File not found!"
	exit 31
fi

IFS_SAVE=${IFS}
IFS=,

totallines=0
linecounter=0
blankcounter=0
commentcounter=0
invalidlines=0

while read fname mname lname gname
do
	if [ -z $fname ]
	then
		let ++blankcounter
		let ++totallines
		continue
	fi
	if [ ${fname:0:1} = '#' ]
	then
		let ++commentcounter
		let ++totallines
		continue
	fi
	if [ -z $mname ] || [ -z $lname ] || [ -z $gname ]
	then
		let ++totallines
		let ++invalidlines
		continue
	fi
	#if [ -z $lname ]
	#then
		#let ++totallines
		#let ++invalidlines
		#continue
	#fi
	#if [ -z $gname ]
	#then
		#let ++totallines
		#let ++invalidlines
		#continue
	#fi
	let ++totallines
	let ++linecounter
done < $1
IFS=${IFS_SAVE}

echo "Blank lines:   $blankcounter"
echo "Comment lines: $commentcounter"
echo "Invalid lines: $invalidlines"
echo "Text  lines:   $linecounter"
echo "Total lines:   $totallines"


