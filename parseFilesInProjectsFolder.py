__author__ = 'Bin He'

"""
The following requirement is the same as the OrbDataManagementAndMining.py file
Required project folder format:
    #
    Each project in a folder
    #
    Each project is named in format of p+project index for example
    p12
    #
    The text file with the same name as the folder
    contains detailed information of the project. For example
    p12
    #
    If has video, the video name will be in format of
    video_12
    #
    If has image, the image name will be in format of
    image_12

"""

import os


def parseProjectsFolders(projectsPath,processedDataFolder, masterProjectFilePath, dataImageFolderInProcessing, dataVideoFolderInProcessing):


    if not os.path.isdir(projectsPath):
        os.mkdir(projectsPath)
        print(projectsPath + " created")

    if not os.path.isdir(processedDataFolder):
        os.mkdir(processedDataFolder)
        print(processedDataFolder + " created")

    if not os.path.isdir(dataImageFolderInProcessing):
        os.mkdir(dataImageFolderInProcessing)

    if not os.path.isdir(dataVideoFolderInProcessing):
        os.mkdir(dataVideoFolderInProcessing)






    # allProjects is a tuple with all the project folder path
    # x[0] gets the first layer of subdirectory path
    allProjects = [x[0] for x in os.walk(projectsPath) if x[0] != projectsPath]

    print(len(allProjects))
    print type(allProjects)
    print(allProjects)


    projDataRowDict = {} # the dict store text rows for projects before write to text file





    # Loop through all the projects
    maxProjIndex = 0;
    for aProj in allProjects:
        # print(aProj)
        projIndex = os.path.basename(aProj)
        projIndex = int(projIndex[1:])

        if(projIndex > maxProjIndex):
            maxProjIndex = projIndex

        print(projIndex)

        # process the current project folder
        for afile in os.listdir(aProj):
            afilePath = os.path.join(aProj,afile)
            print afilePath
            if afile.endswith(".txt"):
                # print afile

                with open(afilePath) as fp:
                     print("afilePath = " + str(afilePath));
                     curline = fp.readline()
                     curline = fp.readline()

                     if  "\n" != curline[-1]:
                         print("Not end with newline--------------------------------")
                         curline += "\n"

                     print("Current project index ==" + str(projIndex))

                     projDataRowDict[projIndex] = curline




            if afile.endswith(".jpg"):

                theOrignalFile = os.path.join(aProj,afile)

                copyToAs = os.path.join(dataImageFolderInProcessing,afile)

                os.system ("copy %s %s" % (theOrignalFile, copyToAs))

                print afile


            if afile.endswith(".mov"):

                theOrignalFile = os.path.join(aProj,afile)

                copyToAs = os.path.join(dataVideoFolderInProcessing,afile)

                os.system ("copy %s %s" % (theOrignalFile, copyToAs))


                print afile
    # End of loop through all the projects


    # over write file if already exist
    masterProjectFile = open(masterProjectFilePath, 'w+')



    headerLine = ("Project_Index	Project Title	Short Name	Studio	Participants	Type	No_of_Photos	No_of_Videos	Video_Load	Tags	Full Description	Date\n")
    masterProjectFile.writelines(headerLine)

    for projIndex in range(0,int(maxProjIndex)+1):
        print("Printing project #" + str(projIndex))
        
        masterProjectFile.writelines(projDataRowDict[projIndex])


    masterProjectFile.close()