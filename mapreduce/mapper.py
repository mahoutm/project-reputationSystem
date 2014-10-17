#!/usr/local/bin/python2.7
# -*- coding: utf-8 -*-

import psycopg2
import MeCab as mc
import re
import sys

def read_input(file):
    for line in file:
        yield line

def main():
    m = mc.Tagger('-d /usr/local/lib/mecab/dic/mecab-ko-dic')
    data = read_input(sys.stdin)
    for line in data:
        dic = m.parse(line)
        num = 0
        wordcount = {}
        for line in dic.splitlines():
                stack = line.split('\t')
                if len(stack) < 2 : continue
                word = stack[0]; opt = stack[1] ; num += 1
                if bool(re.match('NN.+',opt)):
                        if word not in wordcount:
                                wordcount[word] = 1
                        else:
                                wordcount[word] += 1

    	for word in wordcount:
		if len(word) > 3 :
    	        	print (word+"\t"+str(wordcount[word]))

if __name__ == "__main__":
    main()

