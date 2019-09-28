int MOST_RECENT = 20;

int level2 = -1;
float alpha1 = 75;
float fillAlpha2 = 50;
float lineThick1 = 1.5;
float orbLine = 1;
float orbLineAlpha = 125;
float orbPoint = 2.5;
float orbFillAlpha = 60;
boolean allLabels = true;

PVector arcOrig = new PVector(-50, 0, 0);
PVector home = new PVector(0, 0, 0);
float sphereD = 10;
float sphereCount = 0;
float SIZE_OF_DOTS = 13;

Entity found = null;
float foundDist = 0;
int foundIndex = -1;
int oldFoundIndex = -1;
int GRAB_LO = 30;
int GRAB_HI = 60;
int grab_area = GRAB_LO;

// used for xfading between the two levels
float xfade1 = 1.0;
float xfade2 = 0.0;
float pulse = 0;

// used for hovering over dots with the cursor
boolean cursorOverDot = false;
int overDotPos = 0;

// used for when to be able to select a dot
int SELECTION = 100;

// maximum thickness of line reflecting connections among projects
float LEVEL2CAP = 4.0;

boolean firstRunThrough = true;

/**
 * Draws the Orb
 */
void orbArc() 
{
  if (firstRunThrough)
  {
    firstRunThrough = false;
    int count = 0;
    int runs = 0;
    for (int i = tableTotal - 1; i >= 0; i--)
    {
      runs++;
      if (!isPerson[i])
      {
        count++;
      }
      if (count == MOST_RECENT)
        break;
    } 
    MOST_RECENT = runs;
  }
  
  noStroke();
  if (fistRegistered > 10)
    pulse += 1;
  else 
    pulse = 0;
    
  fill(340, 200, 50, orbFillAlpha+int(pulse*0.1));
  
  if (getMillis() > 5250 && sphereD < 99) {
    float sphereNorm = norm(sphereCount, 0, 101);
    float spherePow = pow(sphereNorm, 4);
    spherePow*=10;
    sphereCount+=.5;
    sphereD += spherePow;
  }
  
  hint(DISABLE_DEPTH_MASK);
  sphere(sphereD);
  hint(ENABLE_DEPTH_MASK);
  
  if (afterStart)
  {
    this.drawOuterCircle();
  }

  noFill();
  isNearDot = 0;

  found = null;
  foundDist = 0;
  foundIndex = -1;
  
  if(level2 > -1 && xfade2 < 1.0)
  {
    xfade2 += 0.05;
    if (xfade1 > 0.2)
      xfade1 -= 0.05;
  }
  else if (level2 == -1 && xfade2 > 0.0)
  {
    xfade2 -= 0.05;
    if (xfade1 < 1.0)
      xfade1 += 0.05;
  }
  cursorOverDot = false;
  ArrayList<Integer> drawingOrderLevelOne = new ArrayList<Integer>();
  ArrayList<Integer> closenessOrderLevelOne = new ArrayList<Integer>();
  
  int start = 0; //Math.max(tableTotal - MOST_RECENT, 0); //this draws everything now
 
  for (int i = start; i < tableTotal; i++)
  {
    float[] camPos = cam.getPosition();
    float distToCam = dist(entity[i].vec.x, entity[i].vec.y, entity[i].vec.z, camPos[0], camPos[1], camPos[2]);
    int closeness = (int) (HYP - distToCam);
    boolean found = false;
    for (int j = 0; j < drawingOrderLevelOne.size(); j++)
    {
      if (closeness < closenessOrderLevelOne.get(j))
      {
        drawingOrderLevelOne.add(j, i);
        closenessOrderLevelOne.add(j, closeness); 
        found = true;
        break;
      }           
    }       
    if (!found)
    {
      drawingOrderLevelOne.add(i);
      closenessOrderLevelOne.add(closeness); 
    }
  }
  
  ArrayList<Integer> drawingOrderLevelTwo = new ArrayList<Integer>();
  if (level2 != -1)
  {
    ArrayList<Integer> drawingOrder = new ArrayList<Integer>();
    ArrayList<Integer> closenessOrder = new ArrayList<Integer>();
    drawingOrderLevelTwo.add(-10);
    drawingOrder.add(level2);
    float[] camPos = cam.getPosition();
    float distToCam = dist(entity[level2].vec.x, entity[level2].vec.y, entity[level2].vec.z, camPos[0], camPos[1], camPos[2]);
    int closeness = (int) (HYP - distToCam);
    closenessOrder.add(closeness);
    for (int q = 0; q < simTotal; q++)
    {
      if (similarIndex[level2][q] > -1)
      {        
        int index = similarIndex[level2][q];
        camPos = cam.getPosition();
        distToCam = dist(entity[index].vec.x, entity[index].vec.y, entity[index].vec.z, camPos[0], camPos[1], camPos[2]);
        closeness = (int) (HYP - distToCam);
        int count = 0;
        boolean found = false;
        for (int j = 0; j < drawingOrder.size(); j++)
        {
          if (closeness < closenessOrder.get(j))
          {
            drawingOrder.add(j, index);
            closenessOrder.add(j, closeness); 
            drawingOrderLevelTwo.add(j, q);
            found = true;
            break;
          }           
        }       
        if (!found)
        {
          drawingOrder.add(index);
          closenessOrder.add(closeness); 
          drawingOrderLevelTwo.add(q);
        }
      }
    }     
  }
  
  this.dots(start, drawingOrderLevelOne, drawingOrderLevelTwo);
  this.arcs(start, drawingOrderLevelOne, drawingOrderLevelTwo);
  this.labels(start, drawingOrderLevelOne, drawingOrderLevelTwo);

  if (lightBox) {
    select = false;
  }
    
  // reset grab area if nothing found
  if (found == null)
  {
    grab_area = GRAB_LO;
  }
  else if (found != null && pointerMode == true && SELECTED_ORB == false)
  {  
    overDot(foundIndex);
    pushMatrix();
    Entity target = found;
      
    // move to the specificed dot to draw the selection  
    translate(target.vec.x, target.vec.y, target.vec.z);
    rotateX(xyzRot[0]);
    rotateY(xyzRot[1]);
    rotateZ(xyzRot[2]);
    
    // Distance to the point
    float[] camPos = cam.getPosition();
    float distToCam = dist(target.vec.x, target.vec.y, target.vec.z, camPos[0], camPos[1], camPos[2]);
    int diff = (int) (distToCam - HYP);
    
    // color
    stroke(35, 0, 100, 100);
    noFill();
    strokeWeight((int)Math.abs(5 + 12 * (-diff/HYP)));
    
    // draw loading arc
    arc(0, 0, 6.5, 6.5, (float) (0-Math.PI/2), (float) (-Math.PI/2 + (confirm * Math.PI * 2 / (CONFIRMATION_AMOUNT*0.95))));
    
    popMatrix();
  }
  if (cursorOverDot && !lightBox)
    overDot(overDotPos);  
}


void arcs(int start, ArrayList<Integer> order, ArrayList<Integer> order2)
{
  // iterate through all the elements
  for (int i = start; i < tableTotal; i++)
  {
    int j = i;
    //If its a person and all labels are showing, do not draw on main screen
    if (isPerson[j] && allLabels)
      continue;
      
    //Level 1 Connection (home screen)
    //Will run after the start up sequence
    if (afterStart && level2 == -1) 
    {
      if (shouldVis(i) == 1)
      {
        this.drawLevelOneArcs(j);
      }
    }
  }
  for (int j = 0; j < tableTotal; j++)
  {
    // level 2 connection (second level) if a dot has been selected
    if (level2 == j)
    {
      this.drawLevelTwoArcs(j, order2);
      this.drawPeopleArcs(j);
    }
  }
}

void dots(int start, ArrayList<Integer> order, ArrayList<Integer> order2)
{
  // iterate through all the elements
  for (int i = start; i < tableTotal; i++)
  {
    int j = order.get(i - start);

    // if its a person and all labels are showing, do not draw on main screen
    if (isPerson[j] && allLabels)
        continue;
      
    // level 1 connection (home screen) will run after the start up sequence
    if (afterStart && level2 == -1) 
    {
      if (shouldVis(j) == 1)
      {
        this.drawLevelOneDots(j);
      }
    } 
  }
  for (int j = 0; j < tableTotal; j++)
  {
    if (level2 == j)
    {
      this.drawLevelTwoDots(j, order2);
      this.drawPeopleDots();
    }
  }
}

void labels(int start, ArrayList<Integer> order, ArrayList<Integer> order2)
{
  //Iterate through all the elements
  for (int i = start; i < tableTotal; i++)
  {      
    int j = order.get(i - start);
    //If its a person and all labels are showing, do not draw on main screen
    if (isPerson[j] && allLabels)
      continue;
      
    //Level 1 Connection (home screen)
    //Will run after the start up sequence
    if (afterStart && level2 == -1) 
    {
      if (shouldVis(j) == 1)
      {
        this.drawLevelOneLabels(j);
      }
    }       
  }
  
  for (int j = 0; j < tableTotal; j++)
  {      
    if (level2 == j)
    {
      this.drawLevelTwoLabels(j, order2);
      this.drawPeopleLabels();
    }
  }
}

void drawLevelOneArcs(int i)
{
  hint(ENABLE_DEPTH_TEST); 
  //custom function for setting the color of the arcs based on their studio affiliation.
  arcColor(i, alpha1*xfade1);  
  stroke(220, (alpha1+10)*xfade1);
  strokeWeight(lineThick1);
  bezier(entity[i].vec2.x, entity[i].vec2.y, entity[i].vec2.z, entity[i].vec2.x/5, entity[i].vec2.y/5, entity[i].vec2.z/5, arcOrig.x, arcOrig.y, arcOrig.z, 0, 0, 0);  
  hint(DISABLE_DEPTH_TEST); 
}

/**
 * This will draw all of the level one arcs (home screen)
 */
void drawLevelOneDots(int i) {
  // the distance to the dot
  float[] camPos = cam.getPosition();
  float distToCam = dist(entity[i].vec.x, entity[i].vec.y, entity[i].vec.z, camPos[0], camPos[1], camPos[2]);
  int closeness = (int) (HYP - distToCam);
  hint(ENABLE_DEPTH_TEST); 
  if (allLabels)
  {
    strokeWeight(SIZE_OF_DOTS);   
    stroke(195, 69, 76, (int) (closeness * xfade1 * (1 - standby_xfade)));
    point(entity[i].vec.x, entity[i].vec.y, entity[i].vec.z);
    entity[i].burstIn = 110;
  }  
  hint(DISABLE_DEPTH_TEST); 
  
  // distance from the mouse to the dot
  float distCursor = dist(mouseX, mouseY, entity[i].sX, entity[i].sY);
            
  // distance from the finger to the dot
  float distPointer = dist(pointerX, pointerY, entity[i].sX, entity[i].sY);  
            
  boolean cursorIsClose = false;
  boolean pointerIsClose = false;
  boolean dotIsNearFront = closeness > SELECTION;
            
  if (distCursor < 15)
    cursorIsClose = true;
  if (distPointer < grab_area)
    pointerIsClose = true;      
  
  // if mouseOver the blue dot, draw an ellipse around it
  if ( (cursorIsClose || pointerIsClose) && allLabels && dotIsNearFront) {
    grab_area = GRAB_HI;
    if (found == null)
    {
      found = entity[i];
      foundDist = distPointer;
      foundIndex = i;
    }
    else 
    {
      if (distPointer < foundDist)
      {
        found = entity[i];
        foundDist = distPointer;
        foundIndex = i;
      }
    }
    addNewPointX(entity[i].sX);
    addNewPointZ(entity[i].sY);
    isNearDot++;
  }
  
  // if we are using the mouse and hovering over a dot
  if (cursorIsClose && allLabels && dotIsNearFront) 
  {
     cursorOverDot = true;
     overDotPos = i;
  }

  // if you select a blue dot, set level2 to that selected index number
  // dim the level one arc fill and line thickness  //Dprintln("pointerIsClose=" + pointerIsClose + " clicked=" + clicked() + " select=" + select + " allLabels=" + allLabels + " dotIsNearFront=" + dotIsNearFront);
  if (((cursorIsClose && mousePressed) || (pointerIsClose && clicked())) && select && allLabels && dotIsNearFront)
  {
    playClickDot();
    level2 = i;
    lightBoxID = i;
    lineThick1 = .65;
    aniMag = 0;
    Ani.to(this, 2.5, "aniMag", 1);
    TIME = 30;
    SELECTED_ORB = true;   
    xfade2 = 0.0;
  }
}

void drawLevelOneLabels(int i)
{
  if (allLabels && !lightBox && afterStart)
  {
    orbLabels(i, 10); 
  }  
}


/**
 * Draws the outer circle of the orb
 */ 
private void drawOuterCircle()
{  
  pushMatrix();
  rotateX(xyzRot[0]);
  rotateY(xyzRot[1]);
  rotateZ(xyzRot[2]);
  stroke(220, 255-(pulse*4));
  strokeWeight(1);
  noFill();
  hint(ENABLE_DEPTH_TEST);
  ellipse(0, 0, ORB_SIZE, ORB_SIZE);
  hint(DISABLE_DEPTH_TEST);
  popMatrix(); 
}

private void drawLevelTwoArcs(int i, ArrayList<Integer> order)
{
  // re-orient the orientation of the main project arc to align with the selected project
  /* arcOrig = PVector.sub(entity[i].vec, home);
  arcOrig.normalize();
  arcOrig.mult(50);*/
  
  allLabels = false;
  // draws the 10 similiar projects
  for (int k = 0; k < simTotal; k++) {
    int j = k;
    hint(ENABLE_DEPTH_TEST);
    if (similarIndex[i][j] < 0)
      break;
    //mapping and log scale on the similarWeight values
    float fillWeightMag = map(similarWeight[i][j], minWeight, maxWeight, 10, 125); //013586044
    float lineWeightMag = norm(similarWeight[i][j], minWeight, maxWeight); //.75, 10
    //lineWeightMag = pow(lineWeightMag, 3);
    lineWeightMag = map(similarWeight[i][j], minWeight, maxWeight, .5, 12);
    entity[level2].burstIn = 110;
    fill(195, 69, 76, fillWeightMag*xfade2);
    
    float lineWeightColor = map(similarWeight[i][j], minWeight, maxWeight, 0.5, 3);
    stroke(195, 69, (int)(76 * lineWeightColor), 220*xfade2);
    
    lineWeightMag = Math.min(lineWeightMag, LEVEL2CAP);
    strokeWeight(lineWeightMag);
    
    bezier(entity[i].vec2.x, entity[i].vec2.y, entity[i].vec2.z, entity[i].vec2.x/5, entity[i].vec2.y/5, entity[i].vec2.z/5, 
    entity[similarIndex [i] [j]].vec2.x/15, entity[similarIndex [i] [j]].vec2.y/15, entity[similarIndex [i] [j]].vec2.z/15, 
    entity[similarIndex [i] [j]].vec2.x, entity[similarIndex [i] [j]].vec2.y, entity[similarIndex [i] [j]].vec2.z);
    hint(DISABLE_DEPTH_TEST);
  }
}

private void drawLevelTwoDots(int i, ArrayList<Integer> order)
{  
  // re-orient the orientation of the main project arc to align with the selected project
  hint(ENABLE_DEPTH_TEST);

  float[] camPos = cam.getPosition();
  float distToCam = dist(entity[i].vec2.x, entity[i].vec2.y, entity[i].vec2.z, camPos[0], camPos[1], camPos[2]);
  int closeness = (int) (HYP - distToCam);
  //Draw the point for the selected dot
  strokeWeight(SIZE_OF_DOTS);
  if (!isPerson[i])
  {
    stroke(195, 69, 76, closeness * xfade2 * (1 - standby_xfade));
  }
  else
  {
    stroke(30, 75, 60, (closeness) *xfade2 * (1 - standby_xfade));
  }
  point(entity[i].vec.x, entity[i].vec.y, entity[i].vec.z);
  hint(DISABLE_DEPTH_TEST);
  allLabels = false;
  
  // draws the 10 similiar projects
  for (int j = 0; j < order.size(); j++)
  {
    if (order.get(j) < 0)
      continue; 
      
    int index = similarIndex[i][order.get(j)];
    if (index == -1)
      break;
    
    hint(ENABLE_DEPTH_TEST);

    // how close each dot is to the camera
    camPos = cam.getPosition();
    distToCam = dist(entity[index].vec2.x, entity[index].vec2.y, entity[index].vec2.z, camPos[0], camPos[1], camPos[2]);
    closeness = (int) (HYP - distToCam);

    strokeWeight(SIZE_OF_DOTS);
    stroke(195, 69, 76, (int) (closeness * xfade2 * (1 - standby_xfade)));
    point(entity[index].vec.x, entity[index].vec.y, entity[index].vec.z);
    hint(DISABLE_DEPTH_TEST);
    
    // distance from the mouse to the dot
    float distCursor = dist(mouseX, mouseY, entity[index].sX, entity[index].sY);
    
    // distance from the finger to the dot
    float distPointer = dist(pointerX, pointerY, entity[index].sX, entity[index].sY);          

    boolean cursorIsClose = false;
    boolean pointerIsClose = false;
    boolean dotIsNearFront = closeness > SELECTION;
    
    if (distCursor < 15)
      cursorIsClose = true;
    if (distPointer < grab_area)
      pointerIsClose = true;

    // if the cursor or pointer are near a dot
    if ( (cursorIsClose || pointerIsClose) && dotIsNearFront) 
    {
      grab_area = GRAB_HI;
      if (found == null)
      {
        found = entity[index];
        foundDist = distPointer;
        foundIndex = index;
      }
      else 
      {
        if (distPointer < foundDist)
        {
          found = entity[index];
          foundDist = distPointer; 
          foundIndex = index;
        }
      }
                
      addNewPointX(entity[index].sX);
      addNewPointZ(entity[index].sY);
      isNearDot++;
    }
    
    // if the cursor is hovering over a dot
    if (cursorIsClose && dotIsNearFront)
    {
      cursorOverDot = true;
      overDotPos = index; 
    }

    // click one of the similar 10 projects and set it as the new dot to look at
    if ( ((cursorIsClose && mousePressed) || (pointerIsClose && clicked())) && select && dotIsNearFront)
    {
      playClickDot();
      level2 = index;
      lightBoxID = index;
      entity[index].burstIn = 100;
      lineThick1 = .65;
      aniMag = 0;
      Ani.to(this, 2.5, "aniMag", 1);
      TIME = 30;
      Ani.to(this, 2, "TIME", -1);
      SELECTED_ORB = true;
      xfade2 = 0.0;
    } 
  }
}

private void drawLevelTwoLabels(int i, ArrayList<Integer> order)
{
  for (int j = 0; j< order.size() ; j++) {  
    int index = order.get(j);
    if (index == -10)
      orbLabels(i, 10);   
    else   
    {
      if (similarIndex[i][index] != -1)
        orbLabels(similarIndex[i] [index], 120);
    }
  }   
}

private void drawPeopleArcs(int i)
{
  for (int k = 0; k < peopleTotal; k++)
  {  
    if (peopleProj_Index[k] == level2)
    {  
      if (flaggedParticipant[k])
      {
        Integer projNum = peopleToProject.get(k);

        float[] camPos = cam.getPosition();
        float distToCam = dist(entity[projNum].vec.x, entity[projNum].vec2.y, entity[projNum].vec2.z, camPos[0], camPos[1], camPos[2]);
        int diff = (int) (distToCam - HYP);
        int closeness = Math.abs(diff);
        float distCursor = dist(mouseX, mouseY, entity[projNum].sX, entity[projNum].sY); 
        float distPointer = dist(pointerX, pointerY, entity[projNum].sX, entity[projNum].sY);   
          
        boolean cursorIsClose = false;
        boolean pointerIsClose = false;
        boolean dotIsNearFront = closeness > SELECTION;
            
        if (distCursor < 15)
          cursorIsClose = true;
        if (distPointer < grab_area)
          pointerIsClose = true;  
      
        if ((cursorIsClose || pointerIsClose) && dotIsNearFront)
        {
          grab_area = GRAB_HI;
          if (found == null)
          {
            found = entity[projNum];
            foundDist = distPointer;
            foundIndex = projNum;
          }
          else 
          {
            if (distPointer < foundDist)
            {
              found = entity[projNum];
              foundDist = distPointer;
              foundIndex = projNum;
            }
          }
          if (cursorIsClose && dotIsNearFront)
          {
            cursorOverDot = true;
            overDotPos = projNum;
          }
          addNewPointX(entity[projNum].sX);
          addNewPointZ(entity[projNum].sY);
          isNearDot++;
        }
       
        if ( ((cursorIsClose && mousePressed) || (pointerIsClose && clicked())) && select && dotIsNearFront)
        {
          playClickDot();
          level2 = projNum;
          lightBoxID = projNum;
          lineThick1 = .65;
          aniMag = 0;
          Ani.to(this, 2.5, "aniMag", 1);
          TIME = 30;
          SELECTED_ORB = true;
          xfade2 = 0.0;
        }
        
        stroke(30, 75, 110, (0 - diff) *xfade2);
        strokeWeight(LEVEL2CAP);
        hint(ENABLE_DEPTH_TEST);
        bezier(entity[level2].vec2.x, entity[level2].vec2.y, entity[level2].vec2.z, entity[level2].vec2.x/5, entity[level2].vec2.y/5, entity[level2].vec2.z/5, 
        entity[projNum].vec2.x/15, entity[projNum].vec2.y/15, entity[projNum].vec2.z/15, 
        entity[projNum].vec2.x, entity[projNum].vec2.y, entity[projNum].vec2.z);
        hint(DISABLE_DEPTH_TEST);
      }
      else
      {
        float[] camPos = cam.getPosition();
        float distToCam = dist(entity[indivPeople_Index[k]+100].vec.x, entity[indivPeople_Index[k]+100].vec2.y, entity[indivPeople_Index[k]+100].vec2.z, camPos[0], camPos[1], camPos[2]);
        int diff = (int) (distToCam - HYP);
        int closeness = Math.abs(diff);
        fill(51, 22, 60, 35*xfade2);
        strokeWeight(1.25);
        stroke(51, 22, 60, closeness*xfade2);
        hint(ENABLE_DEPTH_TEST);
        bezier(entity[level2].vec2.x, entity[level2].vec2.y, entity[level2].vec2.z, entity[level2].vec2.x/5, entity[level2].vec2.y/5, entity[level2].vec2.z/5, 
        entity[indivPeople_Index[k]+100].vec2.x/15, entity[indivPeople_Index[k]+100].vec2.y/15, entity[indivPeople_Index[k]+100].vec2.z/15, 
        entity[indivPeople_Index[k]+100].vec2.x, entity[indivPeople_Index[k]+100].vec2.y, entity[indivPeople_Index[k]+100].vec2.z);
        hint(DISABLE_DEPTH_TEST);
        strokeWeight(SIZE_OF_DOTS);
      }
    }
  } 
}

private void drawPeopleDots()
{
  for (int k = 0; k < peopleTotal; k++)
  {
    if (peopleProj_Index[k] == level2)
    {    
      if (flaggedParticipant[k])
      {
        Integer projNum = peopleToProject.get(k);

        float[] camPos = cam.getPosition();
        float distToCam = dist(entity[projNum].vec.x, entity[projNum].vec2.y, entity[projNum].vec2.z, camPos[0], camPos[1], camPos[2]);
        int closeness = (int) (HYP - distToCam);
         
        float distCursor = dist(mouseX, mouseY, entity[projNum].sX, entity[projNum].sY);
        float distPointer = dist(pointerX, pointerY, entity[projNum].sX, entity[projNum].sY);   
          
        boolean cursorIsClose = false;
        boolean pointerIsClose = false;
        boolean dotIsNearFront = closeness > SELECTION;
                    
        if (distCursor < 15)
          cursorIsClose = true;
        if (distPointer < grab_area)
          pointerIsClose = true;  
      
        if ((cursorIsClose || pointerIsClose) && dotIsNearFront)
        {
          grab_area = GRAB_HI;
          if (found == null)
          {
            found = entity[projNum];
            foundDist = distPointer;
            foundIndex = projNum;
          }
          else 
          {
            if (distPointer < foundDist)
            {
              found = entity[projNum];
              foundDist = distPointer;
              foundIndex = projNum;
            }
          }
          if (cursorIsClose && dotIsNearFront)
          {
            cursorOverDot = true;
            overDotPos = projNum;
          }
          addNewPointX(entity[projNum].sX);
          addNewPointZ(entity[projNum].sY);
          isNearDot++;
        }
       
        if ( ((cursorIsClose && mousePressed) || (pointerIsClose && clicked())) && select && dotIsNearFront)
        {
          playClickDot();
          level2 = projNum;
          lightBoxID = projNum;
          lineThick1 = .65;
          aniMag = 0;
          Ani.to(this, 2.5, "aniMag", 1);
          TIME = 30;
          SELECTED_ORB = true;
          xfade2 = 0.0;
        }   
        hint(ENABLE_DEPTH_TEST);
        stroke(30, 75, 60, closeness * xfade2 * (1 - standby_xfade));
        strokeWeight(SIZE_OF_DOTS);
        point(entity[projNum].vec.x, entity[projNum].vec.y, entity[projNum].vec.z);
        hint(DISABLE_DEPTH_TEST);
      }
      else
      {
        hint(ENABLE_DEPTH_TEST);
        float[] camPos = cam.getPosition();
        float distToCam = dist(entity[indivPeople_Index[k]+100].vec.x, entity[indivPeople_Index[k]+100].vec2.y, entity[indivPeople_Index[k]+100].vec2.z, camPos[0], camPos[1], camPos[2]);
        int diff = (int) (distToCam - HYP);
        int closeness = Math.abs(diff);
        fill(51, 22, 60, 35 * xfade2 * (1 - standby_xfade));
        stroke(51, 22, 60, closeness * xfade2 * (1 - standby_xfade));
        strokeWeight(SIZE_OF_DOTS);
        point(entity[indivPeople_Index[k]+100].vec.x, entity[indivPeople_Index[k]+100].vec.y, entity[indivPeople_Index[k]+100].vec.z);
        hint(DISABLE_DEPTH_TEST);
      }
    } 
  }
}

private void drawPeopleLabels()
{
  for (int k = 0; k < peopleTotal; k++)
  {
    if (peopleProj_Index[k] == level2)
    {  
      if (flaggedParticipant[k])
      {
         Integer projNum = peopleToProject.get(k);
         orbLabels(projNum, 10);
      }
      else
      {
        float[] camPos = cam.getPosition();
        float distToCam = dist(entity[indivPeople_Index[k]+100].vec.x, entity[indivPeople_Index[k]+100].vec2.y, entity[indivPeople_Index[k]+100].vec2.z, camPos[0], camPos[1], camPos[2]);
        int diff = (int) (distToCam - HYP);
        int closeness = Math.abs(diff);
        peopleLabels(indivPeople_Index[k], indiv_Participants[k], closeness*xfade2);
      }
    } 
  }
}


/**
 * Custom function for drawing the labels
 * Int parameter sets the project iteration on the orb
 */
void orbLabels(int i, int j) {
  hint(ENABLE_DEPTH_TEST);
  float[] camPos = cam.getPosition();
  float distToCam = dist(entity[i].vec.x, entity[i].vec.y, entity[i].vec.z, camPos[0], camPos[1], camPos[2]);
  pushMatrix();
  translate(entity[i].vec2.x, entity[i].vec2.y, entity[i].vec2.z);
  rotateX(xyzRot[0]);
  rotateY(xyzRot[1]);
  rotateZ(xyzRot[2]);
  colorMode(RGB);
  rectMode(RADIUS);
  noStroke();
  int opac = (int) (j - ((float)distToCam - HYP));
  if (opac > 0)
  {
    fill(0, opac * (1 - standby_xfade));    
    textSize(4);    
    beginShape();
    vertex(-textWidth(shortName[i])/2+1, -4);
    vertex(textWidth(shortName[i])/2-1, -4);
    bezierVertex(textWidth(shortName[i])/2-1, -4, textWidth(shortName[i])/2+1.5, -4, textWidth(shortName[i])/2+1.5, -1);
    bezierVertex(textWidth(shortName[i])/2+1.5, -1, textWidth(shortName[i])/2+1.5, 1.5, textWidth(shortName[i])/2-1, 1.5);
    vertex(textWidth(shortName[i])/2+1, 1.5);
    vertex(-textWidth(shortName[i])/2+1, 1.5);
    bezierVertex(-textWidth(shortName[i])/2+1, 1.5, -textWidth(shortName[i])/2-1.5, 1.5, -textWidth(shortName[i])/2-1.5, -1);
    bezierVertex(-textWidth(shortName[i])/2-1.5, -1, -textWidth(shortName[i])/2-1.5, -4, -textWidth(shortName[i])/2+1, -4);
    endShape();
  }  
  hint(DISABLE_DEPTH_TEST);
  colorMode(HSB);
  noStroke();
  textAlign(CENTER);
  textLeading(1);
  textSize(4);  
  fill(255, opac * (1 - standby_xfade));
  translate(0, 0, 0.1);
  text(shortName[i], 0, 0);
  popMatrix();
}

/**
 * Draws the labels for the people
 * The first is the location in space to draw it
 * The second is the actual name
 */
private void peopleLabels(int i, String name, float opacity) {
  hint(ENABLE_DEPTH_TEST);
  
  pushMatrix();
  translate(entity[i+100].vec2.x, entity[i+100].vec2.y, entity[i+100].vec2.z);
  rotateX(xyzRot[0]);
  rotateY(xyzRot[1]);
  rotateZ(xyzRot[2]);

  float[] camPos = cam.getPosition();
  float distToCam = dist(entity[i].vec.x, entity[i].vec.y, entity[i].vec.z, camPos[0], camPos[1], camPos[2]);

  colorMode(RGB);
  rectMode(RADIUS);
  noStroke();
  float opac = opacity;
  if (opac > 0)
  {
    fill(0, opac * (1 - standby_xfade));
    textSize(4);
    
    beginShape();
    vertex(-textWidth(name)/2+1, -4);
    vertex(textWidth(name)/2-1, -4);
    bezierVertex(textWidth(name)/2-1, -4, textWidth(name)/2+1.5, -4, textWidth(name)/2+1.5, -1);
    bezierVertex(textWidth(name)/2+1.5, -1, textWidth(name)/2+1.5, 1.5, textWidth(name)/2-1, 1.5);
    vertex(textWidth(name)/2+1, 1.5);
    vertex(-textWidth(name)/2+1, 1.5);
    bezierVertex(-textWidth(name)/2+1, 1.5, -textWidth(name)/2-1.5, 1.5, -textWidth(name)/2-1.5, -1);
    bezierVertex(-textWidth(name)/2-1.5, -1, -textWidth(name)/2-1.5, -4, -textWidth(name)/2+1, -4);
    endShape();
  }

  hint(DISABLE_DEPTH_TEST);
  colorMode(HSB);
  noStroke();
  textAlign(CENTER);
  textSize(4);
  fill(255, opac * (1 - standby_xfade));
  translate(0, 0, 0.1);
  text(name, 0, 0);  
  popMatrix();
}


//mouseOver function...draws a ellipse around the blue dots
private void overDot(int i)
{
  pushMatrix();
  translate(entity[i].vec.x, entity[i].vec.y, entity[i].vec.z);
  rotateX(xyzRot[0]);
  rotateY(xyzRot[1]);
  rotateZ(xyzRot[2]);
  noFill();
  stroke(255);
  strokeWeight(1);
  ellipse(0, 0, 10, 10);
  popMatrix();
}


//assigns slightly different colors for the rcs
//based on their studio affiliation
private void arcColor(int i, float alpha1) {

  colorMode(HSB, 360, 100, 100);
  //println(projType[i]);
  if (projType[i].equals("Water")) {
    //fill(340, 100, 50, alpha1);//Ideas Studio
    fill(207, 100, 58, alpha1);
  }

  else if (projType[i].equals("Air")) {
    //fill(350, 100, 50, alpha1); //Image Studio
    fill(207, 62, 100, alpha1);
  }

  else if (projType[i].equals("Land")) {
    //fill(0, 100, 50, alpha1); //Impact
    fill(123, 100, 52, alpha1);
  }

  else if (projType[i].equals("Cybersecurity")) {
    fill(10, 100, 50, alpha1);
  }
  
  else {
    fill(63, 40, 80, alpha1); //Mixed projects
  }
  
  //if (studioName[i].equals("Implement")) {
  //  fill(20, 100, 50, alpha1);//Implement
  //}
  //colorMode(RGB, 255);
}


// determines whether to display the project
private int shouldVis(int i) {

  if (projectFilter == 0)
  {
    return 1;
  }
  
  else if (projType[i].equals("Water"))
  {
    if (projectFilter == 1)
    {
      return 1;
    }
  }

  else if (projType[i].equals("Air"))
  {
    if (projectFilter == 2)
    {
      return 1;
    }
  }

  else if (projType[i].equals("Land"))
  {
    if (projectFilter == 3)
    {
      return 1;
    }
  }

  else if (projType[i].equals("Cybersecurity"))
  {
    if (projectFilter == 4)
    {
      return 1;
    }
  }
  
  else if (projectFilter == 5) {
    return 1;
  }
  
  return 0;
  
}

