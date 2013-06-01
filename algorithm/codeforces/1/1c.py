#!/usr/bin/env python
# -*- coding: utf-8 -*-

"""
http://codeforces.com/problemset/problem/1/C

C. Ancient Berland Circus
time limit per test
2 seconds
memory limit per test
64 megabytes
input
standard input
output
standard output

Nowadays all circuses in Berland have a round arena with diameter 13 meters, but in the past things were different.

In Ancient Berland arenas in circuses were shaped as a regular (equiangular) polygon, the size and the number of angles could vary from one circus to another. In each corner of the arena there was a special pillar, and the rope strung between the pillars marked the arena edges.

Recently the scientists from Berland have discovered the remains of the ancient circus arena. They found only three pillars, the others were destroyed by the time.

You are given the coordinates of these three pillars. Find out what is the smallest area that the arena could have.
Input

The input file consists of three lines, each of them contains a pair of numbers –– coordinates of the pillar. Any coordinate doesn't exceed 1000 by absolute value, and is given with at most six digits after decimal point.
Output

Output the smallest possible area of the ancient arena. This number should be accurate to at least 6 digits after the decimal point. It's guaranteed that the number of angles in the optimal polygon is not larger than 100.
Sample test(s)
Input

0.000000 0.000000
1.000000 1.000000
0.000000 1.000000

Output

1.00000000

"""

import math

class Point(object):
    def __init__(self, x, y):
        self.x = x*1.0
        self.y = y*1.0

    def GetDistance(self, p2):
        dx = self.x - p2.x
        dy = self.y - p2.y
        return math.sqrt(dx*dx+dy*dy)

    def __str__(self):
        return '['+str(self.x)+','+str(self.y)+']'

class LineEquation(object):
    def __init__(self, p1, p2):
        self.type = 0 # 0: general form, 1: vertical line, 2: horizontal line
        self.p1 = p1
        self.p2 = p2
        if p1.x == p2.x:
            self.type = 1 # vertial
            self.x = p1.x
        elif p1.y == p2.y:
            self.type = 2 # horizontal
            self.y = p1.y
        else:
            self.type = 0
            self.slope = (p2.y-p1.y)/(p2.x-p1.x)
            self.intercept = p2.y-self.slope*p2.x
            #print "%f %f   %f %f   %f %f"%(p1.x, p1.y, p2.x, p2.y, self.slope, self.intercept)

    def GetMidperpendicular(self):
        result = None
        mid_x = (self.p1.x+self.p2.x)/2
        mid_y = (self.p1.y+self.p2.y)/2
        if self.type == 1:
            result = LineEquation(Point(0, mid_y), Point(1, mid_y))
        elif self.type == 2:
            result = LineEquation(Point(mid_x, 0), Point(mid_x, 1))
        else:
            slope = -1/self.slope
            result = LineEquation(Point(mid_x, mid_y), Point(mid_x-1, mid_y-slope))
        return result

    def GetCrossPoint(self, line):
        x = 0
        y = 0
        if (self.type == 1 and line.type == 1) \
            or (self.type == 2 and line.type == 2) \
            or (self.type == 0 and line.type == 0 and (self.slope - line.slope < 0.0000001)):
                return None
        if self.type == 1:
            x = self.x
            y = line.slope*x+line.intercept
        elif line.type == 1:
            return line.GetCrossPoint(self)
        elif self.type == 2:
            y = self.y
            x = (y-line.intercept)/line.slope
        elif line.type == 2:
            return line.GetCrossPoint(self)
        else:
            x = (line.intercept-self.intercept)/(self.slope-line.slope)
            y = line.slope*x+line.intercept
        return Point(x,y)

    def __str__(self):
        if self.type == 0:
            return 'y=' + str(self.slope) + '*x+' + str(self.intercept)
        elif self.type == 1:
            return 'x=' + str(self.x)
        else:
            return 'y=' + str(self.y)

def get_area_with_herons_formula(a, b, c):
    p = (a+b+c)/2
    s = math.sqrt(p*(p-a)*(p-b)*(p-c))
    return s

def get_radius(a, b, c, s):
    return a*b*c/(4*s)

def get_radian_of_triangle_with_low_of_cosines(a, b, c):
    r1 = math.acos((b**2+c**2-a**2)/(2*b*c))
    r2 = math.acos((c**2+a**2-b**2)/(2*c*a))
    r3 = math.acos((a**2+b**2-c**2)/(2*b*a))
    return r1, r2, r3

def get_gcd(a, b):
    if b < math.pi/100:
        return a
    return get_gcd(b, math.fmod(a, b))

if __name__ == "__main__":

    coords = raw_input().split()
    p1 = Point(float(coords[0]), float(coords[1]))
    coords = raw_input().split()
    p2 = Point(float(coords[0]), float(coords[1]))
    coords = raw_input().split()
    p3 = Point(float(coords[0]), float(coords[1]))

    a = p1.GetDistance(p2)
    b = p2.GetDistance(p3)
    c = p3.GetDistance(p1)
    s = get_area_with_herons_formula(a, b, c)
    r = get_radius(a, b, c, s)
    r1, r2, r3 = get_radian_of_triangle_with_low_of_cosines(a, b, c)
    r = a/2.0/math.sin(r1)
    rgcd = 2.0*get_gcd(r1, get_gcd(r2, r3))
    result = r*r*math.sin(rgcd)/2*(2*math.pi/rgcd)
    print ("%.6f"%result)
