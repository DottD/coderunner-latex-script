#!/bin/bash
# This is a CodeRunner compile script. Compile scripts are used to compile
# code before being run using the run command specified in CodeRunner
# preferences. This script is invoked with the following properties:
#
# Current directory:	The directory of the source file being run
#
# Arguments $1-$n:		User-defined compile flags	
#
# Environment:			$CR_FILENAME	Filename of the source file being run
#						$CR_ENCODING	Encoding code of the source file
#						$CR_TMPDIR		Path of CodeRunner's temporary directory
#
# This script should have the following return values:
# 
# Exit status:			0 on success (CodeRunner will continue and execute run command)
#
# Output (stdout):		On success, one line of text which can be accessed
#						using the $compiler variable in the run command
#
# Output (stderr):		Anything outputted here will be displayed in
#						the CodeRunner console

# run rubber on the file specified by the 1st compiler flag of source file (the arg can contain relative path)
PATH="$PATH:/usr/texbin:/Library/TeX/texbin:/Library/TeX/Distributions/Programs/texbin"
# Set up output folder
outdir=".cache"
# Check if the user has specified a file to be run
if [ -z "$1" ]
then
	CR_PATH=$CR_FILENAME
else
	CR_PATH=$(realpath $(realpath $(dirname $CR_FILENAME))/$1)
fi
# Compute basename
name=$(basename "$CR_PATH")
name=${name%.*}
if [ $? -ne 0 ]; then # exit on error
	# Send compilation log to stderr
	>& 2 echo "$name"
	exit 1
fi
# Create a log file
logfile="$PWD/$outdir/${name}_overall.log"
# Compile with pdflatex
# Send stderr to $message and stdout to log file
message=$(latexmk -outdir=$outdir -pdf -cd -time "$CR_PATH" 2>1)
status=$?
# Outputs message to log file
echo "$message" > "$logfile"
# Print messages to console or show the generated PDF
if [ $status -ne 0 ]; then # halt on error
	# Send compilation log to stderr
	echo "$message" >& 2
	exit 1
else
	# Send PDF file path to console
	echo "$PWD/$outdir/$name.pdf" >& 1
	exit 0
fi