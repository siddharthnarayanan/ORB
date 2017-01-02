"""
    Crawler to retrieve data from website using selenium
"""
import csv
import re
import urllib
from selenium import webdriver
from selenium.webdriver.common.keys import Keys
from bs4 import BeautifulSoup

# open the text file and read the file in line by line separated by tabs
with open("participantsindex.txt", "rU") as f:
    reader=csv.reader(f, delimiter="\t")
    d = list(reader)[1:] # store contents in a 2D array of rows and columns

# for all the rows, find the names of participants to search for
#for i in range(0, len(d)):
    i=0
    #get the top hit url
    query_args={'q':d[i][1]}
    query=urllib.urlencode(query_args)
    browser = webdriver.Firefox()
    browser.get('http://search.vt.edu/query?'+query)
    elem=browser.page_source
    soup = BeautifulSoup(elem)
    soup.prettify().encode('utf-8')
    link= soup.find('a', {"class":"gs-title"})
    gotolink=link['href']
    browser.close()
    
    #go to the top url and extract the information on that page
    browser = webdriver.Firefox()
    browser.get(gotolink)
    elem=browser.page_source
    soup = BeautifulSoup(elem)
    soup.prettify().encode('utf-8')
    text=(soup.get_text()).encode('utf-8')
    handler=open("outputfromsoup.txt","w")
    handler.write(text)
    handler.close()
    browser.close()

#elem = browser.find_element_by_name('p')  # Find the search box
#elem.send_keys('Dane Webster' + Keys.RETURN)

#browser.quit()
# use regular expression to find the words bio etc