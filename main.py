#!/usr/bin/env python3
"""
This script parses a file with the following format ID date-time string1 string2 string3
"""

__author__ = "Cristian Garcia"
__version__ = "0.1.0"
__license__ = "MIT"

import argparse
import sys
import re

regex = r"^([0-9]+)\s+([0-9]{4}\-[0-1][1-9]-[0-3][0-9]-[0-2][0-9]:[0-6][0-9]:[0-6][0-9])\s+(\"[^\"]*\"|\w+)\s+(\"[^\"]*\"|\w+)\s+(\"[\w]*\"|\w+)$"

def main(fileToParse):
    total_lines = 0
    ok_lines = list()
    for line in open(fileToParse):
        reg = re.search(regex, line, re.MULTILINE)
        if reg:
            ok_lines.append(reg.groups())
            total_lines += 1 
        else:
            total_lines += 1
    print(f"The file contains {total_lines} lines")
    lines = input("Give me a comma separated list of ids: ")
    output_list=list() 
    for ok in ok_lines: 
        for id in lines.split(','):
            if id == ok[0]:
                output_list.append(ok)
    for item in sorted(output_list):
        print (item[0],item[3])
if __name__ == "__main__":
    main(sys.argv[1])
