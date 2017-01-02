"""
    Build graph and plot graph (cluster)
"""

import re
import csv
import networkx as nx
import matplotlib.pyplot as plt

# load all the projects and their descriptions
with open("ProjectsList.txt", "rU") as f:
    reader=csv.reader(f, delimiter="\t")
    p = list(reader)[1:] # store contents in a 2D array of rows and columns

#build the graph
projects=dict()
for i in range(0, len(p)):
    e=list()
    e.append(p[i][1])
    for j in re.split(',|:|;',p[i][9]):
        e.append(j)
    projects[i]=e


# initalize the graph
graph=nx.Graph()

# open the participants1 text file and read the file in line by line separated by tabs
with open("participantslist1.txt", "rU") as f:
    reader=csv.reader(f, delimiter="\t")
    d = list(reader)[1:] # store contents in a 2D array of rows and columns


fileindex=0
i=0
while fileindex < len(d):
    count=int(d[fileindex][0])
    for j in range (1, count+1):
        graph.add_node(d[fileindex+j][1])
    for j in range (1, count+1):
        for k in range (j, count+1):
            if j!=k:
                graph.add_edge(d[fileindex+j][1],d[fileindex+k][1])
                i=int(d[fileindex+j][0])
                graph[d[fileindex+j][1]][d[fileindex+k][1]]['project']=projects[i]
    fileindex=fileindex+count+1
print graph

nx.draw(graph, with_labels=False)
nx.draw_random(graph)
nx.draw_circular(graph)
nx.draw_spectral(graph)
plt.show()




