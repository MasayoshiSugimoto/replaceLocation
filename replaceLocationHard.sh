#!/bin/sh

################################################################################
# Functions
################################################################################

replaceInnerLocation() {
	local inputFile=$1
	local startLine=$2
	local endLine=$3
	#count lines, remove trailing spaces and take the first field
	local lineNumber=$(wc -l $inputFile | sed -E 's/^ +//g' | cut -f1 -d' ')

	if [ $startLine -gt 0 ]
	then
		head -n$startLine $inputFile
		echo 'SetHandler weblogic-handler'
		echo 'ErrorPage https://externet.ac-creteil.fr/maintenance/'
	fi
	tail -n$(( $lineNumber + 1 - $endLine )) $inputFile
}

getGreppedLineNumber() {
	local line=$1
	echo $line | cut -f1 -d:
}

################################################################################
# User parameters
################################################################################
file=$1
shift
urls=$@

################################################################################
# Script
################################################################################

tmpDir=/tmp/deleteLocation.$$
mkdir -p $tmpDir

resultFile=$file
for url in $urls
do
	#Get list of location tags with their line numbers
	grep -En '<Location.*>|</Location>' $resultFile > $tmpDir/locationTags
	#In the locationTags file, a location start tag will be followed by its end tag
	grepResultFile=$tmpDir/grepResult
	grep -A1 "$url" $tmpDir/locationTags > $grepResultFile

	startLine=0
	while read -r line
	do
		if [ $startLine -eq 0  ]
		then
			startLine=$(getGreppedLineNumber $line)
		else
			endLine=$(getGreppedLineNumber $line)	
			tmpFile=$resultFile
			#create new result file
			fileIndex=$(( $fileIndex + 1 ))	
			resultFile=$tmpDir/resultFile.$fileIndex
			replaceInnerLocation $tmpFile $startLine $endLine > $resultFile
		fi
	done < $grepResultFile
done

cat $resultFile
