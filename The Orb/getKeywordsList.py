import csv
import re


def generate_keywords_list(ProjectsList, keywordsListFile):
    # open the text file and read the file in line by line separated by tabs
    with open(ProjectsList, "rU") as f:
        reader = csv.reader(f, delimiter="\t")
        d = list(reader)[1:]  # store contents in a 2D array of rows and columns

    keywords = dict()
    # for all the rows, tokenize each column's contents bearing in mind the punctuation
    for i in range(0, len(d)):
        for p in re.split(',|:|;', d[i][9]):
            if keywords.has_key(p):
                keywords[p].append(i)
            else:
                keywords[p] = []
                keywords[p].append(i)

    # print keywords

    # print the results to the output file
    output_file = open(keywordsListFile, "wb")
    index = 0
    for i in keywords.keys():
        output = str(index)
        output += "\t" + str(i) + str('\t') + str(keywords[i]) + "\n"
        output_file.write(output)
        index += 1
    output_file.close()
