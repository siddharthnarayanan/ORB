from django import forms

class ProjectForm(forms.Form):
    Project_Title = forms.CharField(label='Project_Title', max_length = 100)
    Short_Name = forms.CharField(label='Short_Name', max_length = 100)
    Studio = forms.CharField(label='Studio', max_length = 100)
    Type = forms.CharField(label='Type', max_length = 100)
    Tags = forms.CharField(label='Tags', max_length = 100)
    Full_Description = forms.CharField(label='Full_Description', max_length = 100)
    
    # File_Upload = forms.FileField(label='File_Upload')

  