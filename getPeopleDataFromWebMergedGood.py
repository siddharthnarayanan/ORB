"""


"""
import os.path
from os.path import basename

import urllib2, csv
import urlparse
from bs4 import BeautifulSoup
import time
import pandas as pd
import re
import nltk

import shutil



def getPeopleDataFromTheWeb(allPeopleInfoFolder, personAsProjectFolder, participantsIndex, ProjectsListwithSimilarities, ProjectsListwithSimilaritiesInProcessing):





    if not os.path.isdir(allPeopleInfoFolder):
        os.mkdir(allPeopleInfoFolder)

    shutil.copy2(ProjectsListwithSimilarities, ProjectsListwithSimilaritiesInProcessing)

    personalNameBioImageForAllWeb = {}
    peopleAsProject4AllTempDict = {}
    peopleAsProject4OutputText = {}

    personToProjectDict = {}

    webPeopleToOrbPeopleIndexDict = {}

    webPersonIndexToPretendIndex = {}

    personIndexToFullNameInProcessing = {}



    downloaded_data  = urllib2.urlopen('http://www.icat.vt.edu/people')
    csv_data = csv.reader(downloaded_data)

    #for row in csv_data:
    #   print row
    request = urllib2.Request('http://www.icat.vt.edu/people')
    response = urllib2.urlopen(request)
    soup = BeautifulSoup(response)


    # print soup.prettify()

    print ("--------------------------------------------------------")

    ###########################################################################
    # This for loop is just     Staff and  Senior Fellows with ICAT.
    allNames = soup.findAll(attrs={"class":"views-field views-field-name"})

    # print(allNames)


    print ("--------------------------------------------------------")

    personalPageSoups = []



    for aTag in allNames:
        aLink = aTag.findChildren()[0]
        aLink = aLink.get('href')
        fullLink = 'http://www.icat.vt.edu' + aLink
        print (fullLink)

        personalPageRequest = urllib2.Request(fullLink)
        personalPageResponse = urllib2.urlopen(personalPageRequest)
        personalSoup = BeautifulSoup(personalPageResponse)

        personalPageSoups.append(personalSoup)

        time.sleep(0.1)

    # Got all the personal soups
    # now loop through each person and save their information.
    for i in range(0,len(personalPageSoups)):
        # print(personalPageSoups[i])

        personName = personalPageSoups[i].find('h1', attrs={'id':'page-title'})
        personName = personName.contents[0]

        personBio = personalPageSoups[i].find('div', attrs={'class':'field field-name-field-bio field-type-text-long field-label-above'})
        personBio = personBio.find('div', attrs={'class':'field-items'})
        personBio = personBio.find('div', attrs={'class':'field-item even'})



        if personBio.p is not None:
                personBio = personBio.p.text
                # allText = personBio.findAll(text=True, recursive=False)
                # personBio = allText
        else:
            personBio = 'NA'


        personImg = personalPageSoups[i].find('div', attrs={'class':'user-picture'})
        personImg = personImg.find('img')
        personImg = personImg.get('src')

        print(personName)
        print(personBio)
        print(personImg)

        personalNameBioImageForAllWeb[i] = [personName, personBio, personImg]
        print ("--------------------------------------------------------\n")




    ##########################################################################
    # The above are just     Staff and  Senior Fellows with ICAT.
    # The following are trying to parse Faculty Affiliate
    # allAffiNames = soup.findAll('div', attrs={"class":"views-field views-field-field-last-name-s-"})
    #
    # print("allAffiNames")
    # print(allAffiNames)
    # print ("--------------------------------------------------------")
    #
    # personalPageAffiSoups = []
    #
    # for aTag in allAffiNames:
    #     aLink = aTag.findChildren()[0]
    #     #####Todo check the affili page html
    #     aLink = aLink.get('href')
    #     fullLink = 'http://www.icat.vt.edu' + aLink
    #     print (fullLink)
    #
    #     personalPageRequest = urllib2.Request(fullLink)
    #     personalPageResponse = urllib2.urlopen(personalPageRequest)
    #     personalAffiSoup = BeautifulSoup(personalPageResponse)
    #
    #     personalPageAffiSoups.append(personalAffiSoup)
    #
    #     time.sleep(0.1)


    # for i in range(0,len(personalPageAffiSoups)):
    #     #print(personalPageAffiSoups[i])
    #
    #     # personName = personalPageAffiSoups[i].find('h1', attrs={'id':'page-title'})
    #
    #     personName = personName.contents
    #
    #     personBio = personalPageAffiSoups[i].find('div', attrs={'class':'field field-name-field-bio field-type-text-long field-label-above'})
    #     personBio = personBio.find('div', attrs={'class':'field-items'})
    #     personBio = personBio.find('div', attrs={'class':'field-item even'})\
    #
    #     try:
    #         personBio = personBio.p.text
    #
    #
    #         # try:
    #         #     personBio = personBio.contents
    #         # except NameError:
    #         #     personBio = 'NA'
    #
    #     except NameError:
    #         personBio = 'NA'
    #
    #
    #     # if (personBio.p.contents == NULL):
    #     #     personBio = 'NA'
    #     # else:
    #     #     personBio = personBio.p.contents
    #
    #     personImg = personalPageAffiSoups[i].find('div', attrs={'class':'user-picture'})
    #     personImg = personImg.find('img')
    #     personImg = personImg.get('src')
    #
    #     print(personName)
    #
    #     print(personBio)
    #
    #
    #     print(personImg)
    #
    #
    #     personalNameBioImageForAllWeb[i + len(personalNameBioImageForAllWeb)] = (personName, personBio, imgName)
    #
    #
    #
    #     print ("--------------------------------------------------------" + '\n\n\n')
    #     print ("--------------------------------------------------------")





    ######################################################################################################
    #start     createPeopleAsProject at personAsProjectFolder
    ######################################################################################################

    # -------Start buiding person index dicts-------------------------------
    participIndex = pd.read_table(participantsIndex)
    # print(peopleIndex)
    # print (participIndex.iloc[0,2])

    print (re.split('\D+', participIndex.iloc[0,2]))


    # fullNameToPersonIndex = {}

    for curPersonIndex in range (0,len(participIndex)):
        personToProjectDict[curPersonIndex+1] = re.split('\D+', participIndex.iloc[curPersonIndex,2])[1:-1]
        personIndexToFullNameInProcessing[curPersonIndex+1] = participIndex.iloc[curPersonIndex,1]
    print(personToProjectDict)
    print("personIndexToFullNameInProcessing Dict:::: ", personIndexToFullNameInProcessing)

    #---------End of buiding person index dicts---------------------------------




    my_cols = ["Project_Index", "Project Title", "Short Name", "Studio", "Participants", "Type", "No_of_Photos", "No_of_Videos", "Video_Load", "Tags", "Full Description", "Date", "Project_index_1", "Similarity_1", "Project_index_2", "Similarity_2", "Project_index_3", "Similarity_3", "Project_index_4", "Similarity_4", "Project_index_5", "Similarity_5", "Project_index_6", "Similarity_6", "Project_index_7", "Similarity_7", "Project_index_8", "Similarity_8", "Project_index_9", "Similarity_9", "Project_index_10", "Similarity_10"]
    # realProjects = pd.read_table(ProjectsListwithSimilarities, names = my_cols, header=True, engine='python')
    realProjects = pd.read_table(ProjectsListwithSimilarities, names = my_cols, header=True)


    # print(realProjects)
    numberOfRealProjects = realProjects['Project_Index'].max()

    print("Number of Real Projects\t" + str(numberOfRealProjects + 1))
    curPersonAsProjectIndex = numberOfRealProjects +1

    curPersonIndexInWebData = 0

    for aP in range(0, len(personalNameBioImageForAllWeb)):
        headerLine = ("Project_Index	Project Title	Short Name	Studio	Participants	Type	No_of_Photos	No_of_Videos	Video_Load	Tags	Full Description	Date\n")



        #-------------Match back from people name on the web to people index in processing--
        # curWebPersonToProcessingPersonDict = {}

        # personalNameBioImageForAllWeb
        # personIndexToFullNameInProcessing

        curWebPersonName = personalNameBioImageForAllWeb[curPersonIndexInWebData][0]
        # print(curWebPersonName + "\n")

        minMatchDist = 100
        minMatch = []
        for curOrbPersonIndex, curOrbPersonName in personIndexToFullNameInProcessing.items():

            curOrbPersonName =curOrbPersonName.encode('utf-8')
            curPairDist = nltk.metrics.edit_distance(curWebPersonName, curOrbPersonName)

            if (curPairDist <0.1) and (curPairDist< minMatchDist):
                minMatchDist = curPairDist
                minMatch = [curPersonIndexInWebData,curWebPersonName,curOrbPersonIndex,curOrbPersonName]
                aPersonPretendingAsAProject = str(curPersonAsProjectIndex) + "\t" + curPersonName.encode('utf-8')  + "\t" + curPersonName.encode('utf-8')  +"\t"+ "people"+"\t"+ "Person name" + "\t" +	"Person" + "\t"+"1\t0\t0\t" + "People\t" + curPersonBio.encode('utf-8') + "\tNone Listed\t" + "ProjectIndex1\t" +"similarity1"

        if minMatchDist < 0.5:
            print (minMatchDist, minMatch)
            webPeopleToOrbPeopleIndexDict[minMatch[0]] = minMatch[2]
            webPersonIndexToPretendIndex[minMatch[0]] = str(curPersonAsProjectIndex)

        #-------------End match back from people name on the web to people index in processing--



        # Then replace peopleNameAsFolder Name with index
        # curPersonIndex = personalNameBioImageForAllWeb[curPersonIndexInWebData][0]
        # curPersonBio = personalNameBioImageForAllWeb[curPersonIndexInWebData][1]

        curPersonName = personalNameBioImageForAllWeb[curPersonIndexInWebData][0]
        curPersonBio = personalNameBioImageForAllWeb[curPersonIndexInWebData][1]
        curPersonImage = personalNameBioImageForAllWeb[curPersonIndexInWebData][2]

        #Remove all white spaces, new lines and tabs
        curPersonBio = ' '.join(curPersonBio.split())



        # curPersonAsProjectFolder = os.path.join(personAsProjectFolder, curPersonIndex)

        print("curPersonAsProjectIndex\t", curPersonAsProjectIndex)
        
        curPersonAsProjectFolder = os.path.join(personAsProjectFolder, str(curPersonAsProjectIndex))


        if not os.path.isdir(curPersonAsProjectFolder):
            os.makedirs(curPersonAsProjectFolder)

        curPersonAsProjectText  = os.path.join(curPersonAsProjectFolder, str(curPersonAsProjectIndex) + ".txt")
        curPersonAsProjectImage = os.path.join(curPersonAsProjectFolder, str(curPersonAsProjectIndex) + ".jpg")


        #aPersonPretendingAsAProject = str(curPersonAsProjectIndex) + "\t" + curPersonName.encode('utf-8')  + "\t" + curPersonName.encode('utf-8')  +"\t"+ "people"+"\t"+ "Person name" + "\t" +	"Person" + "\t"+"1\t0\t0\t" + "People\t" + curPersonBio.encode('utf-8') + "\tNone Listed\t" + "ProjectIndex1\t" +"similarity1"
        #aPersonPretendingAsAProject = str(curPersonAsProjectIndex) + "\t" + curPersonName.encode('utf-8')  + "\t" + curPersonName.encode('utf-8')  +"\t"+ "people"+"\t"+ "Person name" + "\t" +	"Person" + "\t"+"1\t0\t0\t" + "People\t" + curPersonBio.encode('utf-8') + "\tNone Listedx"


        # # write each project into it's own folder and it's own text file
        # with open(curPersonAsProjectText, "w+") as outTxtFile:
        #     outTxtFile.write(headerLine)
        #     outTxtFile.write(aPersonPretendingAsAProject)
        #
        # peopleAsProject4AllTempDict[curPersonIndexInWebData] = aPersonPretendingAsAProject


        try:
            imgData = urllib2.urlopen(curPersonImage).read()

            # imgName = basename(urlparse.urlsplit(curPersonImage)[2])
            imgName = "image_" + str(curPersonAsProjectIndex) + ".jpg"

            output = open(os.path.join(allPeopleInfoFolder, imgName),'wb')

            output.write(imgData)
            output.close()
        except Exception, e:
            print str(e)
            # pass


        curPersonIndexInWebData = curPersonIndexInWebData + 1
        curPersonAsProjectIndex = numberOfRealProjects + 1 + curPersonIndexInWebData


    ########################################################################################
    # Start to output files
    #---- Start to construct peopleAsProject -----






    print("\npersonalNameBioImageForAllWeb")
    print(personalNameBioImageForAllWeb)
    print("------\n")


    print("\nwebPeopleToOrbPeopleIndexDict:")
    print(webPeopleToOrbPeopleIndexDict)

    for webIndex, orbIndex in webPeopleToOrbPeopleIndexDict.iteritems():
        print(webIndex,personalNameBioImageForAllWeb[webIndex][0], orbIndex, personIndexToFullNameInProcessing[orbIndex])


    # aPersonPretendAsPPart1 = str(curPersonAsProjectIndex) + "\t" + curPersonName.encode('utf-8')  + "\t" + curPersonName.encode('utf-8')  +"\t"+ "people"+"\t"+ "Person name" + "\t" +	"Person" + "\t"+"1\t0\t0\t" + "People\t" + curPersonBio.encode('utf-8') + "\tNone Listedx" + "\tProjectIndex1" +"\tsimilarity1"



    print("\nStart loop through the webPeopleToOrbPeopleIndexDict to build peopleAsProject4OutputText dict:\n")
    for webPerson, orbPerson in webPeopleToOrbPeopleIndexDict.iteritems():

        # print()
        curPretendPIndex = webPersonIndexToPretendIndex[webPerson]

        curPersonNameP = personIndexToFullNameInProcessing[orbPerson]

        curPersonBio   = personalNameBioImageForAllWeb[webPerson][1]
        curPersonBio = ' '.join(curPersonBio.split())



        # loop through the personToProjectDict
        aListOfAllProjectOfThePersion = personToProjectDict[orbPerson]
        print("\naListOfAllProjectOfThePersion")
        print(aListOfAllProjectOfThePersion)
        totalProjectCurPersonHave = len(aListOfAllProjectOfThePersion)
        needEmptyProjects = 10 - totalProjectCurPersonHave

        aPersonPretendAsP10Default = ""
        for aOrbProjectIndex in aListOfAllProjectOfThePersion:
            aPersonPretendAsP10Default = aPersonPretendAsP10Default + "\t" + aOrbProjectIndex + "\t1"

        for defaultP in range(0, needEmptyProjects):
            aPersonPretendAsP10Default = aPersonPretendAsP10Default + "\t-1\t0"

        aPersonPretendAsP = str(curPretendPIndex) + "\t" + curPersonNameP.encode('utf-8') + "\t" + curPersonNameP.encode('utf-8') + "\t" + "people"+"\t" + curPersonNameP.encode('utf-8') + "\t" + "Person" + "\t"+"1\t0\t0\t" + "People\t" + curPersonBio.encode('utf-8') + "\tNone Listed"
        aPersonPretendAsP = aPersonPretendAsP + aPersonPretendAsP10Default
        # peopleAsProject4AllTempDict[curPersonIndexInWebData] = aPersonPretendingAsAProject

        # print(webPerson, curPretendPIndex, aPersonPretendAsP)
        print(webPerson,personalNameBioImageForAllWeb[webPerson][0], orbPerson, personIndexToFullNameInProcessing[orbPerson])
        print(aPersonPretendAsP)

        peopleAsProject4OutputText[curPretendPIndex] = aPersonPretendAsP



    print( "\n-----Here is just before looping through the peopleAsProject4OutputText-----"  )

    with open(ProjectsListwithSimilaritiesInProcessing, "a") as outTxtFinalProcessingFile:
    # with open(ProjectsListwithSimilarities, "a") as outTxtFinalProcessingFile:
        outTxtFinalProcessingFile.write("\n")

        isFirst = True

        for pretendIndex, pretendPData in peopleAsProject4OutputText.iteritems():
            if isFirst is True:
                outTxtFinalProcessingFile.write(pretendPData)
                isFirst = False
            else:
                outTxtFinalProcessingFile.write("\n")
                outTxtFinalProcessingFile.write(pretendPData)









#############################################
# # Testing the methods. Need to be comment out.

rootPath = os.path.dirname(os.path.realpath(__file__))

allPeopleInfoFolder = os.path.join(rootPath, "dataFromWeb")
personAsProjectFolder = os.path.join(rootPath, "personAsProject")
ProjectsListwithSimilaritiesFolder = os.path.join(rootPath,"temp")
ProjectsListwithSimilarities = os.path.join(ProjectsListwithSimilaritiesFolder,"ProjectsListwithSimilarities.txt")

ProjectsListwithSimilaritiesInProcessing = os.path.join(ProjectsListwithSimilaritiesFolder,"ProjectsListwithSimilaritiesInProcessing.txt")

participantsIndex = os.path.join(ProjectsListwithSimilaritiesFolder,"participantsIndex.txt")

getPeopleDataFromTheWeb(allPeopleInfoFolder, personAsProjectFolder,participantsIndex, ProjectsListwithSimilarities, ProjectsListwithSimilaritiesInProcessing)



############################################
