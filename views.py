from django.shortcuts import render

from django.http import HttpResponse
from django.http import HttpResponseRedirect

from django.conf import settings
import urllib2
import urlparse

# from django.views.decorators.csrf import csrf_protect
# from django.core.context_processors import csrf

# from django.middleware import csrf


from django.template.response import TemplateResponse

from django.template import RequestContext

from forms import ProjectForm
import os

from django.shortcuts import redirect


# from django import forms

# from .models import Post

HOME_DIR = os.path.dirname(os.path.dirname(__file__))
projectDir = os.path.join(HOME_DIR, "dataManagementMiningBin\\projects"),

print("\n-----------------------------")
print(projectDir)

# Create your views here.
def index(request):


	# my_cols = ["Project_Index", "Project Title", "Short Name", "Studio", "Participants", "Type", "No_of_Photos", "No_of_Videos", "Video_Load", "Tags", "Full Description", "Date", "Project_index_1", "Similarity_1", "Project_index_2", "Similarity_2", "Project_index_3", "Similarity_3", "Project_index_4", "Similarity_4", "Project_index_5", "Similarity_5", "Project_index_6", "Similarity_6", "Project_index_7", "Similarity_7", "Project_index_8", "Similarity_8", "Project_index_9", "Similarity_9", "Project_index_10", "Similarity_10"]
	my_cols = ["Project_Index", "Project_Title", "Short_Name", "Studio", "Participants", "Type", "No_of_Photos", "No_of_Videos", "Video_Load", "Tags", "Full_Description", "Date", "Project_index_1", "Similarity_1", "Project_index_2", "Similarity_2", "Project_index_3", "Similarity_3", "Project_index_4", "Similarity_4", "Project_index_5", "Similarity_5", "Project_index_6", "Similarity_6", "Project_index_7", "Similarity_7", "Project_index_8", "Similarity_8", "Project_index_9", "Similarity_9", "Project_index_10", "Similarity_10"]

	c = RequestContext(request, {
	 'active_tag': 'home', 'BASE_URL':settings.BASE_URL
	})

	# c.update(csrf(request))

	# context = {}
	# return render(request, 'home/index.html')

	# context = { 'active_tag': 'home', 'BASE_URL':settings.BASE_URL}  // Can not 
	# print(context['BASE_URL'])
	return TemplateResponse(request, 'home/index.html', c)


def handle_uploaded_file(f, savePath):
	destination = open(savePath, 'wb+')
	for chunk in f.chunks():
		destination.write(chunk)
	destination.close()

# def handle_uploaded_file(f, savePath):
# 	with open(savePath, 'wb+') as destination:
# 		for chunk in f.chunks():
# 			destination.write(chunk)



def inputdata(request):

	if request.method == 'POST': # If the form has been submitted...

		# aform = ProjectForm(request.POST, request.FILES)
		aform =request.POST

		uploadedFile = request.FILES['File_Upload']

		print("type of uploadedFile: ")
		print(type(uploadedFile))

		# print(type(aform))
		# print(aform)

		Project_Title = aform['Project_Title']
		Short_Name = aform['Short_Name']
		Studio = aform['Studio']
		Participants = aform['Participants']
		# Type = aform['Type']
		Type = "News"

		Tags = aform['Tags']
		Full_Description = aform['Full_Description']

		# MediaUrl = aform['MediaUrl']



		if not os.path.exists(projectDir[0]):
			os.makedirs(projectDir[0])

		findNextName  = False
		nextProjectFolder = ""
		nextProjIndex = 0;
		pIndex = 0;
		projectFolders = os.listdir(projectDir[0])
		# projectFolders = dict(projectFolders)

		while ((not findNextName) and pIndex <= len(projectFolders)):

			pname = "p" + str(pIndex)
			# print(pname)

			if pname in projectFolders:
				pIndex = pIndex + 1
			else:
				nextProjectFolder = pname
				nextProjIndex = pIndex
				findNextName = True


		print(nextProjectFolder)
		newProj = os.path.join(projectDir[0], nextProjectFolder)
		newTxt = os.path.join(newProj, pname + ".txt")

		# mediaUrl = os.path.join(newProj, pname + ".Url")


		if not os.path.exists(newProj[0]):
			os.makedirs(newProj)
		
		projHeader = "Project_Index	Project Title	Short Name	Studio	Participants	Type	No_of_Photos	No_of_Videos	Video_Load	Tags	Full Description	Date\n"
		projContent = str(nextProjIndex) + "\t" + Project_Title + "\t" + Short_Name + "\t" + Studio + "\t" + Participants + "\t" + Type + "\t" + '1' + "\t" + '0' + "\t" + '0' + "\t" + Tags + "\t" + Full_Description + "\t" + 'NA'

		with open(newTxt, "w") as newTxtFile:
			newTxtFile.write(projHeader)
			newTxtFile.write(projContent)


		# with open(mediaUrl, "w") as MediaUrlFile:
		# 	MediaUrlFile.write(MediaUrl)
		

		imgName = "image_" + str(pIndex) + ".jpg"
		imgFilePath = os.path.join(newProj, imgName)
		# try:
		# 	imgData = urllib2.urlopen(MediaUrl).read()

		# 	output = open(imgFilePath, 'wb')

		# 	output.write(imgData)
		# 	output.close()
		# except Exception, e:
		# 	print str(e)
		# 	# pass

		# handle_uploaded_file(request.FILES['file'], newImg)

		handle_uploaded_file(request.FILES['File_Upload'], imgFilePath)


		# return redirect('index')
		return HttpResponse('New project added. Please click the "go back" button of your web browser')
		# form = ContactForm(request.POST) # A form bound to the POST data

		# return HttpResponseRedirect('/thanks/') # Redirect after POST

	else:
		
		return HttpResponse("not a valid form")



def manageAndMine(request):
	from dataManagementMiningBin import OrbDataManagementAndMining



	return HttpResponse('New Mining finished. Please click the "Go Back" button of your web browser')

	# return redirect('index')




