
"""
Required project folder format:
    #
    Each project in a folder
    #
    Each project is named in format of p+project index for example
    p12/
    #
    The text file with the same name as the folder
    contains detailed information of the project. For example
    p12.txt
            (for file p12, headerLine = ("Project_Index	Project Title	Short Name	Studio	Participants	Type	No_of_Photos	No_of_Videos	Video_Load	Tags	Full Description	Date\n"))

    #
    If has video, the video name will be in format of
    video_12.mov
    #
    If has image, the image name will be in format of
    image_12.jpg

    ----------------------------------------------------------------------------

    Python version: 2.7.6

    ----------------------------------------------------------------------------
    output:
    'participantsIndex.txt' file have the mapping from people to projects

"""




import os

import warnings
warnings.filterwarnings("ignore")

#Get the path of the current file
from binmodules.parseFilesInProjectsFolder import parseProjectsFolders
from binmodules.getParticipantsIndex import generateParticipantsIndex
from binmodules.getKeywordsList import generate_keywords_list
from binmodules.getParticipantsList import generateParticipantsList
from binmodules.CalculateSimilarity import generateProjectsListwithSimilarities

# from binmodules.getPeopleDataFromWeb import getPeopleDataFromTheWeb

rootPath = os.path.dirname(os.path.realpath(__file__))
processedDataPath = os.path.join(rootPath, "processedData")


# the following folders are for processing
rootPathOfProcessing = os.path.abspath(os.path.join(rootPath,".."))
dataFolderInProcessing = os.path.join(rootPathOfProcessing,"data")
dataImageFolderInProcessing = os.path.join(dataFolderInProcessing,"images")
dataVideoFolderInProcessing = os.path.join(dataFolderInProcessing,"videos")

if not os.path.isdir(dataFolderInProcessing):
    os.mkdir(dataFolderInProcessing)




#--------Parsing all the folders for project -------------------------------------
#
ProjectsListMasterFile = os.path.join(processedDataPath, "ProjectsList.txt")

projectsPath = os.path.join(rootPath, "projects")
allProjectsInOneFolderPath = os.path.join(rootPath, "allProjectsInOne")

parseProjectsFolders(projectsPath, processedDataPath, ProjectsListMasterFile,dataImageFolderInProcessing, dataVideoFolderInProcessing)



#--------getKeywordsList------------------------------------------------------------
#
keywordsListFile = os.path.join(processedDataPath, "keywordslist.txt")

generate_keywords_list(ProjectsListMasterFile, keywordsListFile)



#--------getParticipantsIndex-------------------------------------------------------
#
participantsIndexOutputFile = os.path.join(processedDataPath,"participantsIndex.txt")

generateParticipantsIndex(ProjectsListMasterFile, participantsIndexOutputFile)


#--------getParticipantsList---------------------------------------------------------
#
participantsListFile= os.path.join(processedDataPath, "participantsList.txt")
participantsList1File= os.path.join(processedDataPath, "participantsList1.txt")
participantslistFileInProcessingDataFolder = os.path.join(dataFolderInProcessing,"participantsList.txt")

generateParticipantsList(ProjectsListMasterFile, participantsListFile, participantsList1File)


#--------CalculateSimilarity---------------------------------------------------------
#
stopwordsFile = os.path.join(rootPath, "binmodules","stopwords.txt")
ProjectsListwithSimilaritiesFile = os.path.join(processedDataPath,"ProjectsListwithSimilarities.txt")
projectsListwithSimilaritiesFileInProcessingDataFolder = os.path.join(dataFolderInProcessing,"ProjectsListwithSimilarities.txt")

generateProjectsListwithSimilarities(ProjectsListMasterFile, stopwordsFile, ProjectsListwithSimilaritiesFile)


#--------get people information from the web and create people as project----------------------------------
#
peopleInfoOutPutFolder = os.path.join(rootPath, "peopleInfo")
personAsProjectFolder = os.path.join(rootPath,"peopleAsProjects")
ProjectsListwithSimilaritiesWithPeople = os.path.join(dataFolderInProcessing,"ProjectsListwithSimilaritiesWithPeople.txt")
orbPeopleIndexToPretendProjectIndex = os.path.join(dataFolderInProcessing, "orbPeopleIndexToPretendProjectIndex.txt")

# getPeopleDataFromTheWeb(peopleInfoOutPutFolder, personAsProjectFolder, participantsIndexOutputFile, ProjectsListwithSimilaritiesFile, ProjectsListwithSimilaritiesWithPeople, dataImageFolderInProcessing, orbPeopleIndexToPretendProjectIndex)


#
#
#
###############################################################################################
# after finish generating the two key files for processing, copy them to processing data folder

os.system ("copy %s %s" % (ProjectsListwithSimilaritiesFile, projectsListwithSimilaritiesFileInProcessingDataFolder))
os.system ("copy %s %s" % (participantsListFile,participantslistFileInProcessingDataFolder))
os.system ("copy %s %s" % (ProjectsListwithSimilaritiesWithPeople, participantslistFileInProcessingDataFolder))