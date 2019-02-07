#!/bin/bash

# TODO
# Compile the grammar before testing
# Error checking to make sure test files both exist
# Error checking to make sure the grammar complies and ANTLR4 is in the class path

# NOTE: The class path must be valid to work. If it isn't already set, please update it in this file before running
# Add the default ANTLR4 location to the class path just in case
export CLASSPATH=".:/usr/local/lib/antlr-4.7.1-complete.jar:$CLASSPATH"

# Default values for testing files
top_test_directory=$'../test/'
input_file_suffix=$'-input.bc'
#float-aware.py script
float_aware=$'./float-aware.py'
# expected output (generated from bc -l)
expected=$'expected.txt'
# actual output from simple-bc
actual=$'actual.txt'
# the parse tree created by simple-bc
tree=$'tree.txt'
# any errors from simple-bc
errors=$'errors.txt'
# the diff file comparing the outputs of actual and expected
diff_command=$'python3 ./float-aware.py'
diff=$'diff.floataware.txt'

# Reference (non-functioning) code for running and compiling the code
# antlr4=(java -Xmx500M -cp "/usr/local/lib/antlr-4.7.1-complete.jar:$CLASSPATH" org.antlr.v4.Tool)
# grun=java -Xmx500M -cp "/usr/local/lib/antlr-4.7.1-complete.jar:$CLASSPATH" org.antlr.v4.gui.TestRig
# grun="$(java -Xmx500M -cp $CLASSPATH org.antlr.v4.gui.TestRig)"

# The will output if the files failed or passed
diffFiles() {
	if $diff_command $1 $2 > $3
	then
			echo "Pass: " $1
	else
			echo "Fail: " $1
	fi
}

# Go through all the files in the test directory that match the input suffix
for file in $top_test_directory*$input_file_suffix
do
	test_dir="$top_test_directory$(basename -s $input_file_suffix $file)"
	mkdir -p $test_dir
	# run the test file through bc, make output the expected
	bc -l < $file > "${test_dir}/$expected"	
	# running the generated + compiled parser on each test file
	java -Xmx500M -cp $CLASSPATH org.antlr.v4.gui.TestRig SimpleBC exprList -tree $file > "${test_dir}/temp" 2> "${test_dir}/$errors"
	
	# separating the tree from the main expression
	head -n-1 "${test_dir}/temp" > "${test_dir}/${actual}"
	tail -n 1 "${test_dir}/temp" > "${test_dir}/${tree}"
	rm "${test_dir}/temp"

	# Compare the input files output with the output file
	diffFiles "${test_dir}/${actual}" "${test_dir}/$expected" "${test_dir}/${diff}"
done