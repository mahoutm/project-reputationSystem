#!/usr/local/bin/python2.7
# -*- coding: utf-8 -*-

from itertools import groupby
from operator import itemgetter
import sys

def read_mapper_output(file):
    for line in file:
        yield line.strip().split('\t')

def main():
    # input comes from STDIN (standard input)
    data = read_mapper_output(sys.stdin)
    
    wordcount={}
    for word, group in groupby(data, itemgetter(0)):
        try:
            group_list= list(group)
            count = sum(int(count) for word, count in group_list)
	    if word not in wordcount:
	        wordcount[word] = count
	    else:
	        wordcount[word] += count

        except ValueError:
            # count was not a number, so silently discard this item
            pass
    
    for word in wordcount:
	print (word+"\t:"+str(wordcount[word]))

if __name__ == "__main__":
    main()
