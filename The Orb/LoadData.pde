import java.util.Map;

Table table;
Table peopleTable;

TableRow rowIterate;
TableRow rowIteratePeople;

HashMap<Integer, Integer> peopleToProject;

int tableTotal;
int peopleTotal;
int simTotal = 10;
int studioSelect = -1;

String[] shortName;
String[] studioName;
String[] projTitle;
String[] projDescrip;
String[] projPeople;
String[] projType;

boolean[] videoLoad;
boolean[] imageLoad;
boolean[] flaggedParticipant;
boolean[] isPerson;

int[][] similarIndex;
float[][] similarWeight;
float[][] similarWeightMag;

int[] peopleProj_Index;
int[] indivPeople_Index;
String[] indiv_Participants; 

float maxWeight = 1.0; // originally 0.630097611
float minWeight = 0.0; // originally 0.026698905
float aniMag = 0;

/**
 * Loads all the data to display on the orb
 */
void loadData() {
  
  //println("A");

  //table = loadTable("ProjectsListwithSimilaritiesWithPeople.txt", "header, tsv");
  table = loadTable("ProjectsListwithSimilarities.txt", "header, tsv");
  peopleTable = loadTable("participantsList.txt", "header, tsv");

  //println("B");

  tableTotal = table.getRowCount();
  peopleTotal = peopleTable.getRowCount();
  
  //println("C");
  
  // initialize all the data structures
  peopleToProject = new HashMap<Integer, Integer>();
  shortName = new String[tableTotal];
  studioName = new String[tableTotal];
  videoLoad = new boolean[tableTotal];
  imageLoad = new boolean[tableTotal];
  projTitle = new String[tableTotal];
  projDescrip = new String[tableTotal];
  projPeople = new String[tableTotal];
  projType = new String[tableTotal];
  isPerson = new boolean[tableTotal];
  similarIndex = new int [tableTotal] [simTotal];
  similarWeight = new float[tableTotal] [simTotal];
  similarWeightMag = new float[tableTotal] [simTotal];
  peopleProj_Index = new int[peopleTotal];
  indiv_Participants = new String[peopleTotal];
  indivPeople_Index = new int[peopleTotal];
  flaggedParticipant = new boolean[peopleTotal];
  
  for (int i = 0; i<tableTotal; i++) 
  {
    rowIterate =  table.getRow(i);   
    shortName[i] = rowIterate.getString("Short Name");
    studioName[i] = rowIterate.getString("Studio");
    projType[i] = rowIterate.getString("Type");
    //println("type: " + projType[i]);
    isPerson[i] = studioName[i].toLowerCase().equals("people");
    videoLoad[i] = rowIterate.getInt("Video_Load") == 1;
    imageLoad[i] = rowIterate.getInt("No_of_Photos") > 0;
    projTitle[i] = rowIterate.getString("Project Title");
    projDescrip[i] = rowIterate.getString("Full Description");
    projPeople[i] = rowIterate.getString("Participants");
    
    // gets all the similar projects
    for (int j = 1; j < 11; j++)
    {
      int similiarElementIndex = rowIterate.getInt(" Project_index_" + j);
      float similiarElementWeight = rowIterate.getFloat(" Similarity_" + j);
      if (similiarElementIndex == -1)
        break;
    }
    
    // gets all the similar weights
    for (int j = 0; j<simTotal; j++) 
    {
      similarIndex [i] [j] = rowIterate.getInt(" Project_index_" + (j+1));
      similarWeight [i] [j] = rowIterate.getFloat(" Similarity_" + (j+1));
      similarWeightMag [i][j] = map(similarWeight[i][j], minWeight, maxWeight, 40, 100);
    }
  }
  
  // gets all the people for each project
  for (int i = 0; i < peopleTotal; i++) {
    rowIteratePeople = peopleTable.getRow(i);
    if (!rowIteratePeople.getString("Indiv_Participants").contains("None Listed")) {
      peopleProj_Index[i] = rowIteratePeople.getInt("peopleProj_Index");
      indiv_Participants[i] = rowIteratePeople.getString("Indiv_Participants");
      indivPeople_Index[i] = rowIteratePeople.getInt("indivPeople_Index"); //this refers to the unigue ID for the Point in space for that individual
    }
    else
    {
      // if this entry has no people listed
      peopleProj_Index[i] = -1;
      indiv_Participants[i] = "Null";
      indivPeople_Index[i] = -1;
    }
  }
  
  // flags participants that are a project
  // this will allow the project to be displayed
  // instead of the person label
  for (int i = 0; i < peopleTotal; i++)
  {
    for (int j = 0; j < tableTotal; j++)
    {
      String split[] = indiv_Participants[i].split(" ");
      int number = split.length;
      String compare = indiv_Participants[i];
      if (number == 3)
        compare = split[0] + " " + split[2];
      if (shortName[j].equals(compare) || shortName[j].equals(indiv_Participants[i]))
      {
        peopleToProject.put(i, j);
        flaggedParticipant[i] = true;
        break;
      }
    } 
  }
}

void magSlide () {
  for (int i = 0; i<tableTotal; i++) {
    for (int j = 0; j<10; j++) {
      similarWeightMag [i][j] = map(similarWeight[i][j], 0.026698905, 0.630097611, 60*aniMag, 100*aniMag);
    }
  }
}

