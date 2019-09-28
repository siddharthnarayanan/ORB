import csv
import re

# open the text file and read the file in line by line separated by tabs
with open("ProjectsList.txt", "rU") as f:
    reader=csv.reader(f, delimiter="\t")
    d = list(reader)[1:] # store contents in a 2D array of rows and columns

participants= dict()
# for all the rows, tokenize each column's contents baring in mind the punctuation
for i in range(0, len(d)):
    for p  in re.split(', |:|;',d[i][4]):
        if participants.has_key(p.strip()):
            participants[p].append(i)
        else:
            participants[p.strip()]=[]
            participants[p.strip()].append(i)

#print participants

#print the results to the output file
outputfile = open("participantsindex.txt", "wb")
index=0
for i in participants.keys():
    output= str(index)
    output+="\t"+ str(i) + str('\t') + str(participants[i]) + "\n"
    outputfile.write(output)
    index=index + 1
outputfile.close()
