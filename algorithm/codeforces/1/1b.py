#!/usr/bin/env python
# -*- coding: utf-8 -*-

"""
http://codeforces.com/problemset/problem/1/B

B. Spreadsheets
time limit per test
10 seconds
memory limit per test
64 megabytes
input
standard input
output
standard output

In the popular spreadsheets systems (for example, in Excel) the following numeration of columns is used. The first column has number A, the second — number B, etc. till column 26 that is marked by Z. Then there are two-letter numbers: column 27 has number AA, 28 — AB, column 52 is marked by AZ. After ZZ there follow three-letter numbers, etc.

The rows are marked by integer numbers starting with 1. The cell name is the concatenation of the column and the row numbers. For example, BC23 is the name for the cell that is in column 55, row 23.

Sometimes another numeration system is used: RXCY, where X and Y are integer numbers, showing the column and the row numbers respectfully. For instance, R23C55 is the cell from the previous example.

Your task is to write a program that reads the given sequence of cell coordinates and produce each item written according to the rules of another numeration system.
Input

The first line of the input contains integer number n (1 ≤ n ≤ 105), the number of coordinates in the test. Then there follow n lines, each of them contains coordinates. All the coordinates are correct, there are no cells with the column and/or the row numbers larger than 106 .
Output

Write n lines, each line should contain a cell coordinates in the other numeration system.
Sample test(s)
Input

2
R23C55
BC23

Output

BC23
R23C55
"""

def convert_to_type1(s):
    i = 1
    while s[i] != 'C':
        i += 1
    row = 0
    row = s[1:i]
    col = int(s[i+1:])

    col_result = ""
    while col != 0:
        if col%26 == 0:
            col_result = 'Z'+col_result
            col -= 26
        else:
            col_result = chr(ord('A')+col%26-1)+col_result
        col = col/26
    return col_result+row

def convert_to_type2(s):
    row = 0
    col = 0

    i = 0
    while s[i].isalpha():
        i+=1
    col = s[:i]
    row = s[i:]

    col_result = 0
    j = 0
    while j<i:
        col_result = col_result*26
        col_result += ord(col[j])-ord('A')+1
        j += 1
    return "R%sC%s"%(row, col_result)

def determine_type(s):
    end_of_alpha = 0
    while s[end_of_alpha].isalpha():
        end_of_alpha += 1
    while end_of_alpha < len(s):
        if s[end_of_alpha].isalpha():
            return 2
        end_of_alpha += 1
    return 1

def convert(s):
    if 1 == determine_type(s):
        return convert_to_type2(s)
    else:
        return convert_to_type1(s)

num_of_rows = int(raw_input())
i = 0
result = []
while i < num_of_rows:
    s = raw_input()
    result.append(convert(s))
    i += 1

for l in result:
    print l
#convert("A12")
#convert("Z12")
#convert("AA12")
#convert("BC12")
#convert("R27C34")
#convert("R1C34")
#convert("R26C34")
#convert("R55C34")
