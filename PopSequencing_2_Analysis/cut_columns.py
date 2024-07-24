import numpy as np
import sys
import csv

## what are the variables:
### -- inFile: is the path and filename of the file from which we want to cut the columns 
### -- col: a list of columns we want to cut, starting at 1 (we will take care of python starting at 0 later)
### -- out: path and name of the sample that these columns correspond to

#### col and out are taken from a separate file in the case of mpileups and pileups 

CutFile = sys.argv[1]
col = sys.argv[2]
columns = np.array(list(map(int, col.split(","))))
out = sys.argv[3] 

print ("This sis the filename:", CutFile)
print ("These are the columns:", columns)


f=open(CutFile,"r")
lines=f.readlines()
result=[]
for x in lines:
    result.append(np.array(x.split(' '))[columns-1])
f.close()

outArray = np.stack(result)

with open(out, 'w') as f:
    csv.writer(f, delimiter=' ').writerows(outArray)
