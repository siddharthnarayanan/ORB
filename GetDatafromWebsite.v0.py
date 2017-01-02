"""
    Using urlib2 to retrieve data from website
    Problems with running embedded javascript - not fixed!
    Use version 1
"""


import urllib2, csv
from bs4 import BeautifulSoup

downloaded_data  = urllib2.urlopen('http://search.vt.edu/query?q="Dane%20Webster"')
csv_data = csv.reader(downloaded_data)


#for row in csv_data:
#   print row
request = urllib2.Request('http://search.vt.edu/query?q="Dane%20Webster"')
response = urllib2.urlopen(request)
soup = BeautifulSoup(response)
print soup.prettify()

#for link in soup.find_all('a'):
#   print (link.get('href'))