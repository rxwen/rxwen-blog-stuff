#!/usr/bin/env python
# -*- coding: utf-8 -*-

"""

http://codeforces.com/problemset/problem/1/A

A. Theatre Square
time limit per test2 seconds
memory limit per test64 megabytes
inputstandard input
outputstandard output
Theatre Square in the capital city of Berland has a rectangular shape with the size n × m meters. On the occasion of the city's anniversary, a decision was taken to pave the Square with square granite flagstones. Each flagstone is of the size a × a.

What is the least number of flagstones needed to pave the Square? It's allowed to cover the surface larger than the Theatre Square, but the Square has to be covered. It's not allowed to break the flagstones. The sides of flagstones should be parallel to the sides of the Square.

Input
The input contains three positive integer numbers in the first line: n,  m and a (1 ≤  n, m, a ≤ 109).

Output
Write the needed number of flagstones.

Sample test(s)
input
6 6 4
output
4

"""

import math

s = raw_input()

(w,h,e)=s.split()
w = int(w)
h = int(h)
e = int(e)

#print w, h, e

x = int(math.ceil(1.0*w/e))
y = int(math.ceil(1.0*h/e))

print x*y
