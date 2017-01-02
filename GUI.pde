boolean close = false;
boolean lightBox = false;
int lightBoxID = 0;
boolean select = true;
float arcMag = 100;
float opacity = 0;
int mouseClicks = 0;
float mouseTime = 0;
int namesLeft = 17;
int namesApart = 18;
int namesBottom = 0;


float HOR_IMG_DIV = 3;
float VERT_IMG_DIV = 2;

// 1 = water
// 2 = land
// 3 = air
// 4 = cybersecurity
// 5 = mixed
// 6 = all
int projectFilter = 0;

/**
 * Draws the GUI
 */
void drawGUI()
{  
  cam.beginHUD();
  drawNames();

  // if the person has selected an information label
  if (lightBox)
  { 
    // gui_Drawput in sound queues
    if(!playFlyIn)
    {
      if (lightBoxX < width)
        playFlyInFromLeft();
      else
        playFlyInFromRight();
      playFlyIn = true;
    }
    
    Ani.to(this, 1, "lightBoxX", width, Ani.EXPO_OUT);    
    rectMode(CORNER);
    fill(0, opacity - 40);
    stroke(255, opacity - 40);
    strokeWeight(1);    
    rect(-5, 75, width + 10, height - 150);
    rectMode(CORNER);
    lightBox_Info(lightBoxID);
  }
  
  if (close == true)
  {
    lightBox = false;
    select = true;
  }

  if (!lightBox && swipeAway) 
  {
    playFlyIn = false;
    // if it has a video, stop the video
    if (videoLoad[lightBoxID]) {
      vids[lightBoxID].stop();
    }
    
    // if the swipe is left
    if (swipeAwayLeft)
    {
      if (!playFlyOut)
        playSwipeAwayLeft();
      Ani motion = Ani.to(this, 1.5, "lightBoxX", (-3 * width));
      //print("LEFT:" + lightBoxX + " " + (-3 * width) + "\n");
      if(lightBoxX <= (-2 * width))
      {
        motion.end();
        swipeAway = false;
        playFlyOut = false;
        return;
      }
    }
    // if the swipe is right
    else
    {
       if (!playFlyOut)
         playSwipeAwayRight();
       Ani motion = Ani.to(this, 1.5, "lightBoxX", (6 * width));
       //print("RIGHT:" + lightBoxX + " " + (6 * width) + "\n");
       if (lightBoxX >= (2 * width))
       {       
         motion.end();   
         swipeAway = false;
         playFlyOut = false;
         return;
        }
    }
    rectMode(CORNER);
    fill(0, opacity - 40);
    stroke(255, opacity - 40);
    strokeWeight(1);    
    rect(-5, 75, width + 10, height - 150);
    lightBox_Info(lightBoxID);
    
    close = false;
  }
  cam.endHUD();
}

/**
 * Stuff that should always be in the lightbox if a project is selected
 */
void lightBox_Info(int i) 
{
  colorMode(RGB);
  
  if (swipeAway)
  {
    Ani.to(this, 1.5, "opacity", 0);
  }
  else
  {
    Ani.to(this, 1.5, "opacity", 240);
  }
  fill(255, opacity);
  noStroke();
  rectMode(CORNER);
  textAlign(CENTER, TOP); 
  textSize(40);
  text(projType[i] + " -- " + projTitle[i], lightBoxX/ 2, (height/2) - 285);
  textSize(24);
  boolean displayInfo = true;
  if (isPerson[i])
  {
    displayInfo = false;
  }
  
  if (displayInfo)
  {
    String participants = projPeople[i];
    if (!participants.contains("None Listed"))
    {
      text("Participants",  lightBoxX / 2, (height/2)-235);
      
      textAlign(CENTER, CENTER);
      text(participants, -1 * (width - lightBoxX - 20), (height/2) - 225, width - 40, 50);
    }
  }
  
  // under project title line vertical line between project title and media/details space
  if(imageLoad[i])
  {
    // IMAGE SIZE CALCULATION NEEDS TO BE MORE INTELLIGENT THAN THIS
    int iWidth = images[i].width;
    int iHeight = images[i].height;
    int realWidth = 0;
    int realHeight = 0;
    if (iHeight > iWidth) {
      realHeight = (int)(height/VERT_IMG_DIV);
      realWidth = (int)((float)realHeight / (float)iHeight * (float)iWidth);
      if (realWidth > (width/HOR_IMG_DIV)) {
        realHeight = (int)((float)(width/HOR_IMG_DIV) / (float)realWidth * (float)realHeight);
        realWidth = (int)(width/HOR_IMG_DIV);
      }
      //realWidth = Math.max(iWidth, MIN_IMG_SIZE);
      //realHeight = realWidth/iWidth * iHeight;
    } else {
      realWidth = (int)(width/HOR_IMG_DIV);
      realHeight = (int)((float)realWidth / (float)iWidth * (float)iHeight);
      if (realHeight > (height/VERT_IMG_DIV)) {
        realWidth = (int)((float)(height/VERT_IMG_DIV) / (float)realHeight * (float)realWidth);
        realHeight = (int)(height/VERT_IMG_DIV);
      }
      //println(iWidth + "x" + iHeight + " " + realWidth + "x" + realHeight);
    }
    //int realWidth = Math.min(iWidth, MIN_IMG_SIZE);
    //int realHeight = Math.min(iHeight, MIN_IMG_SIZE);
    image(images[i], lightBoxX/2 - 75 - realWidth, (height/2)-160, realWidth, realHeight);
    textSize(20);
    textAlign(LEFT);
    //if (projDescrip[i].length() > 500)
    //  textSize(15);
    text(projDescrip[i],  lightBoxX/2 - 40, (height/2) - 160, (width/2.7) , height/2 + 160);
  }
  else if (videoLoad[i]) 
  { 
    int vWidth = vids[i].width;
    int vHeight = vids[i].height;
    int realWidth = Math.min(vWidth, 640);
    int realHeight = Math.min(vHeight, 360);
    image(vids[i], lightBoxX/2 - realWidth - 30, (height/2)-160, realWidth, realHeight);
    if (lightBox && lightBoxX >= width - 10)
      vids[i].play();        
    textSize(20);
    textAlign(LEFT);
    text(projDescrip[i],  lightBoxX/2 + 30, (height/2) - 160, (width/2.7), (height/2 + 85));
  }    
  else
  {
    textSize(20);
    textAlign(CENTER);
    if (displayInfo)
      text("Project Description:",  lightBoxX/4, (height/2) - 160, (width/2), 320);
    textAlign(LEFT);
    text(projDescrip[i],  lightBoxX/4, (height/2) - 160 + 36, (int)Math.floor((width/2) + 1) , 320);
    
  }
  colorMode(HSB);  
}

// changing all of the styles when the Home screen is loaded
void selectHome()
{
  studioSelect = 0;
  level2 = -1;
  Ani.to(this, 2, "Alpha1", 50);
  lineThick1 = 1.5;
  orbLine = .35; // .2 is base
  orbLineAlpha = 75;// 25 is base
  orbPoint = .5;
  Ani.to(this, 2, "orbFillAlpha", 25);
  playReturnHome();
  allLabels = true;
}


void keyPressed()
{
  STANDBY_TIMER = -1;
  INVITE_TIMER = -1;
  if (key == 'h' && level2 > -1)
  {
    selectHome();
  }
  if (key == 'l')
  {
    lightBox = true;
  } 
  if (key == 'c')
  {
    lightBox = false;
  }
  // kinect debug
  /*if (key == 'q' && getMillis() > 13000)
  {
    bodyClose = !bodyClose;
    kinect_debug = true;
    if (!bodyClose)
    {
      STANDBY_TIMER = getMillis() - STANDBY_TIMEOUT;
    }
  }*/
  
  // filtering projects
  if (key == '1')
  {
    projectFilter = 1;
  }
  else if (key == '2')
  {
    projectFilter = 2;    
  }
  else if (key == '3')
  {
    projectFilter = 3;
  }
  else if (key == '4')
  {
    projectFilter = 4;
  }
  else if (key == '5')
  {
    projectFilter = 5;
  }
  else if (key == '`')
  {
    projectFilter = 0;
  }
}

void mouseDragged() {
  select = false;
}

void mouseReleased() {
  select = true;
}

void mouseMoved() {
  STANDBY_TIMER = -1;
  INVITE_TIMER = -1; 
}

void mousePressed()
{
  mouseClicks++;
  STANDBY_TIMER = -1;
  INVITE_TIMER = -1;
  if (standby == 2)
  {
    standby_override = true;
    standby = 3;
  }
  //print("CLICK: " + mouseClicks + " " + dist(mouseX, mouseY, width/2, height/2) + " " + allLabels);
  if (lightBox)
  {
    lightBox = false;
    swipeAway = true;
    swipeAwayLeft = !swipeAwayLeft;
    mouseClicks = 0;
  } 
  else if (mouseClicks == 2 && getMillis() - mouseTime < 250)
  {
    mouseClicks = 0;
    float distCursor = dist(mouseX, mouseY, width/2, height/2);
    if (distCursor >= 350 && !allLabels)
    {
      selectHome();    
    }
  }
  if (mouseClicks == 1)
  {
    mouseTime = getMillis();
  }
  else if (mouseClicks > 2)
  {
    mouseClicks = 0;
  }
}

void drawNames()
{
  rectMode(CORNER);
  fill(0);
  noStroke();
  fill(255);
  stroke(255);
  textSize(16);
  textAlign(LEFT);
  textLeading(1);
  text("Dane Webster | Ivica Ico Bukvic | Cody Cahoon | Bin He", namesLeft, height - namesBottom - 1 * namesApart);
}
