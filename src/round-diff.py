#!/usr/bin/env python3
'''Usage:
round-diff.py [actual] [expected] 
'''
import sys
from itertools import zip_longest

if len(sys.argv) < 3:
    print(__doc__)
    exit(1)

#getting the filenames
actual_filename = sys.argv[1]
expected_filename = sys.argv[2]

exit_status = 0

with open(actual_filename) as actual, open(expected_filename) as expected:
    # filter for non-empty strings
    not_empty = lambda x: len(x) > 0
    # read the handle, split on newline, and get a list of floats
    get_list = lambda x: list(map(float, filter(not_empty, (x.read().split("\n")))))
    try:
        actual = get_list(actual)
        expected = get_list(expected)
    except:
        # abort due to inability to parse some lines
        print("(aborted)")
        exit(2)

    # iterate over each pair
    for act, exp in zip_longest(actual, expected):
        # output the pair
        output = "%s\t%s" % (act, exp)
        # if they don't match, we'll return an error and note it in the output
        if type(act) is not float or type(exp) is not float or round(act,6) != round(exp, 6):
            exit_status = 1
            output += "\t<----"
        print(output)

exit(exit_status)
