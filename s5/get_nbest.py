#!/usr/bin/python3
import sys
from collections import defaultdict

sentence = []
prev_file = ''
isNew = True
for line in sys.stdin:
    tline = line.strip().split(' ')
    if(len(tline) == 1 and len(tline[0])> 10):
        line = line.strip().split('\t')
    else:
        line = tline
    
    if(len(line) == 1):
        if(len(line[0].split('-')) == 1):
            pass
        else:            
            file_name = line[0].split('-')[0]
            if(file_name != prev_file):
                if(len(sentence) > 0):
                    print(' '.join(sentence)+'\n')
                print(file_name)
                prev_file=file_name
                sentence = []

            else:
                print(' '.join(sentence))
                sentence = [] 
    else:
        word = line[2]
        sentence.append(word)
print()
