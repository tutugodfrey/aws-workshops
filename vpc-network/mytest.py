def getString(s):
    # Write your code here
    c1 = ''
    c2 = ''
    listofneutral = ['x', 'y', 'z']
    netral = 'x'
    if len(s) > 1:
        c1 = s[0]
    for i in range(len(s) - 1):
      if c2 != '':
        continue
      elif c1 != s[i+1]:
         c2 = s[i+1]
    for i in range(len(listofneutral)):
      if s.find(netral) != -1:
        netral = listofneutral[i]

    s = s.replace(c1, netral)
    s = s.replace(c2, c1)
    s = s.replace(netral, c2)

    print(netral, c1, c2)
    print(s)


getString('HHHlloBB')


#!/bin/python3

import math
import os
import random
import re
import sys


#
# Complete the 'getString' function below.
#
# The function is expected to return a STRING.
# The function accepts STRING s as parameter.
#

def getString(s):
    # Write your code here
    c1 = ''
    c2 = ''
    listofneutral = ['x', 'y', 'z']
    neutral = 'x'
    if (len(s) > 1):
        c1 = s[0]
    for i in range(len(s) - 1):
        if c2 != '':
            continue
        elif c1 != s[i+i]:
            c2 = s[i+1]
    for i in range(len(listofneutral)):
        if s.find(neutral) != -1:
            neutral = listofneutral[i]
    s = s.replace(c1, neutral)
    s = s.replace(c2, c1)
    s = s.replace(neutral, c2)
