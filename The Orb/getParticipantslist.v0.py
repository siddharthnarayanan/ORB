import csv
import re

# open the text file and read the file in line by line separated by tabs
with open("ProjectsList.txt", "rU") as f:
    reader=csv.reader(f, delimiter="\t")
    d = list(reader)[1:] # store contents in a 2D array of rows and columns

participants= dict()
pindex=0

#print the results to the output file
outputfile = open("participantslist.txt", "wb")
anotherfile = open("participantslist1.txt", "wb")
projectindex=0

# for all the rows, tokenize each column's contents baring in mind the punctuation
for i in range(0, len(d)):
    count=0
    af=""
    for p  in re.split(', |:|;',d[i][4]):
            temp=" ".join(p.split())
            if not participants.has_key(temp):
                participants[temp]=pindex
                pindex=pindex+1
            output= str(projectindex)
            output+="\t"+ temp + str('\t') + str(participants[temp]) + "\n"
            outputfile.write(output)
            af+=output
            count=count+1
    projectindex=projectindex+1
    anotherfile.write(str(count)+"\n"+af)
# close participants file
outputfile.close()
anotherfile.close()
