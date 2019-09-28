""""
    Read in the projects and calculate the similarities
"""

import nltk
from nltk.stem.snowball import SnowballStemmer
from nltk.stem import WordNetLemmatizer
from nltk.corpus import wordnet
from nltk.tokenize import WordPunctTokenizer
from sklearn.feature_extraction.text import TfidfVectorizer
from operator import itemgetter
import unidecode
import numpy as np
import csv


# ---------------- Function to convert the position of a variable in sentence ---------------#
def get_wordnet_pos(treebank_tag):
    
    if treebank_tag.startswith('J'):
        return wordnet.ADJ
    elif treebank_tag.startswith('V'):
        return wordnet.VERB
    elif treebank_tag.startswith('N'):
        return wordnet.NOUN
    elif treebank_tag.startswith('R'):
        return wordnet.ADV
    else:
        return 'n'

# ---------------- Function to calculate the cosine similarity ---------------#
def cos(v1, v2):
    return np.dot(v1, v2) / (np.sqrt(np.dot(v1, v1)) * np.sqrt(np.dot(v2, v2)))


# open the text file and read the file in line by line separated by tabs
with open("ProjectsList.txt", "rU") as f:
    reader=csv.reader(f, delimiter="\t")
    d = list(reader)[1:] # store contents in a 2D array of rows and columns



# create new instance of the lemmatizer using WordNetLemmatizer
stemmer=SnowballStemmer("english")

# create a new instance of the vectorizer
vectorizer = TfidfVectorizer()

# read in the stopwords from the text file make sure they're in lowercase!
stopwords = set([line.strip().lower() for line in open('stopwords.txt')])

# an array of all the documents after lemmatization
documents=[]

# for all the rows, tokenize each column's contents bearing in mind the punctuation
for i in range(0, len(d)):
    bagofwords=""
    for j in range(0, len(d[i])):
        d[i][j] = WordPunctTokenizer().tokenize(d[i][j])
        #[w.lower() for w in d[i][j].split() if w.lower() not in stopwords]
        
        # for each tokenized word find it's position in the sentence
        for w, pos in nltk.pos_tag(d[i][j]):
            if w.lower() not in stopwords: # if it's a stopword convert it to lower case
                # d[i][j]= lemmatizer.lemmatize(w.lower(),pos=get_wordnet_pos(pos))  # lemmatize it
                # add stemmed word from j to the "bag of words"
                bagofwords= bagofwords + " " + stemmer.stem(unidecode.unidecode(w.lower())) # remove any non-unicode values
    documents.append(bagofwords)

# Use the vectorizer to calculate the occurences of the terms
vector = vectorizer.fit_transform(documents)#using WordNGramAnalyzer
all_similarities=dict() # create a dictionary of all the similarities
index_i=0 # counter to keep track of the project_id
for i in vector.toarray():
    index_j=0 #counter to keep track of the matched project_ids
    for j in vector.toarray():
        if index_i is not index_j:
            if not all_similarities.has_key(index_i):
                all_similarities[index_i]=[]
            all_similarities[index_i].append((index_j,cos(i,j)))
            index_j=index_j+1
        else:
            index_j=index_j+1
    index_i=index_i+1

# sort the cosine similarities for each project
for i in all_similarities.keys():
    all_similarities[i].sort(key=lambda tup: tup[1], reverse=True )

# read file so we can add the similarties to it
Original_file=[]
with open("ProjectsList.txt", "rU") as f:
    reader=csv.reader(f, delimiter="\t")
    Original_file = list(reader)

index=0
NumberOfSimilarities=10

# open output file
f = open("ProjectsListwithSimilarities.txt", "w")

output="\t".join(Original_file[0])
# create file header and write it to the file
for x in range(1,NumberOfSimilarities+1):
    output+="\t Project_index_"+str(x) + "\t Similarity_"+str(x)
output+="\n"
f.write(output)

# add the cosine similarities to the file
for index in range(1,len(Original_file)):
    output="\t".join(Original_file[index])
    for x in range(0,NumberOfSimilarities):
        output+= "\t"+str(all_similarities[index-1][x][0]) + "\t" + str(all_similarities[index-1][x][1])
    output+="\n"
    f.write(output)

f.close()
#print all_similarities
