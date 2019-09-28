import peasy.*;
import processing.video.*;
import de.looksgood.ani.*;
import com.leapmotion.leap.Controller;
import com.leapmotion.leap.Frame;
import com.leapmotion.leap.Hand;
import com.leapmotion.leap.Gesture;
import com.leapmotion.leap.HandList;
import com.leapmotion.leap.Vector;
import com.leapmotion.leap.Finger;
import com.leapmotion.leap.FingerList;
import com.leapmotion.leap.processing.LeapMotion;
import java.lang.Math;
import beads.*;

/**
 * Kinect Library
 */
//import org.openkinect.freenect.*;
//import org.openkinect.processing.*;

// the kinect stuff is happening in another class
//KinectTracker tracker;
//Kinect kinect;
float kinect_h_delta = 0;           // stores delta data for the one depth layer
float[] lastNKinectX;               // keeps history of last N deltas for an average
float kinectXSpeed = 0;             // actual calculated speed (factors in slowdown)

// pulsating invite hand
int INVITE_TIMER = -1;              // in ms, -1 disabled, used to trigger invite mode
int INVITE_TIMEOUT = 30000;          // how long before invite should appaear after no body has been detected
float invite_flicker = 0;           // used to make invite hand pulsate
int invite_ani_state = 0;           // 0=off
                                    // 1=fading invite to max (can be either from 0 or 2)
                                    // 2=fading back to a bit above 0
Ani inviteAni;                      // used for animation 

// determines whether we are in standby mode
int standby = 0;                    // 0=off
                                    // 1=animating into standby
                                    // 2=standby
                                    // 3=animating out of standby
int STANDBY_TIMER = -1;             // in ms, -1 disabled, used to trigger standby mode
int STANDBY_TIMEOUT = 600000;       // in ms, amount of time needed to transpire before system goes into standby
boolean bodyClose = false;          // is there a body close to the leap motion?
boolean inStandbyPosition = false;  // have we entered in the standbyposition (includes transition going in)
float standby_xfade = 0;            // value 0-1 (used globally to adjust other objects' visibility)
boolean kinect_debug = false;       // used for 'q' debug timeout option to force standby animation
boolean standby_override = false;   // used for forcing exiting out of standby using a mouse click
int WELCOME_TIMER = -1;             // used to mark time of the last issued welcome
int WELCOME_TIMEOUT = 30000;        // what is the minimum timespan for the welcome to repeat
                                    // happens only when kinect delta exceeds minimum threshold
float KINECT_MIN_THRESHOLD = 0.5;   // minimum delta threshold


/**
 * TODO:
 * check for regressions
 */

/**
 * These are used for the GUI
 */
PImage vt;
PImage rotateOrbImage;
PImage swipeAwayImage;
PImage selectFingerImage;
PImage closeFistImage;
PImage inviteImage;
float imageFlicker1 = 0;
int increment1 = 1;
float prevFlickerTime1 = 0;
float imageFlicker2 = 0;
float increment2 = 0;
float prevFlickerTime2 = 0;
int MAX_FLICKER = 180;
int MIN_FLICKER = 80;
int FLICKER_TIME = 60;
/**
 * These are used for the sound inputs
 */
AudioContext ac;

SamplePlayer BACKGROUND;
float BACKGROUND_MAX_LOUDNESS = 0.15;
SamplePlayer STARTUP_ICAT;
SamplePlayer FOCUS_DOT_ARCS;
SamplePlayer SELECT_DOT_ARCS;
SamplePlayer LIGHTBOX_FLY_IN_LEFT;
SamplePlayer LIGHTBOX_FLY_IN_RIGHT;
SamplePlayer LIGHTBOX_FLY_OUT_LEFT;
SamplePlayer LIGHTBOX_FLY_OUT_RIGHT;
SamplePlayer FOCUS_RETURN_HOME;
SamplePlayer RETURN_HOME;
SamplePlayer SHOW_HAND;
SamplePlayer WELCOME;
SamplePlayer ENTER_STANDBY;
SamplePlayer EXIT_STANDBY;

Gain BACKGROUND_GAIN; 
Gain STARTUP_ICAT_GAIN;
Gain FOCUS_DOT_ARCS_GAIN;
Gain SELECT_DOT_ARCS_GAIN;
Gain LIGHTBOX_FLY_IN_LEFT_GAIN;
Gain LIGHTBOX_FLY_IN_RIGHT_GAIN;
Gain LIGHTBOX_FLY_OUT_LEFT_GAIN;
Gain LIGHTBOX_FLY_OUT_RIGHT_GAIN;
Gain FOCUS_RETURN_HOME_GAIN;
Gain RETURN_HOME_GAIN;
Gain SHOW_HAND_GAIN;
Gain WELCOME_GAIN;
Gain ENTER_STANDBY_GAIN;
Gain EXIT_STANDBY_GAIN;

Envelope BACKGROUND_GAINVALUE;
Envelope STARTUP_ICAT_GAINVALUE;
Envelope FOCUS_DOT_ARCS_GAINVALUE;
Envelope SELECT_DOT_ARCS_GAINVALUE;
Envelope LIGHTBOX_FLY_IN_LEFT_GAINVALUE;
Envelope LIGHTBOX_FLY_IN_RIGHT_GAINVALUE;
Envelope LIGHTBOX_FLY_OUT_LEFT_GAINVALUE;
Envelope LIGHTBOX_FLY_OUT_RIGHT_GAINVALUE;
Envelope FOCUS_RETURN_HOME_GAINVALUE;
Envelope RETURN_HOME_GAINVALUE;
Envelope SHOW_HAND_GAINVALUE;
Envelope WELCOME_GAINVALUE;
Envelope ENTER_STANDBY_GAINVALUE;
Envelope EXIT_STANDBY_GAINVALUE;

boolean playSelectHomeSound = false;

PeasyCam cam;

Movie[] vids;
PImage[] images;
Entity [] entity;

boolean fadeIn = false;
float lightBoxX = -width;

float zoom = 500;
int total = 750;

// how far will the project tips stick out of the sphere
float spikeOut = 15;

float tumbleY = 0;
float tumbleZ = 0;
float zFactor = 0;
float zExp = 0;
int timeStart = 0;

PVector loc2;
PFont font;

// global vector reflecting current orb orientation
// to ensure labels maintain proper orientation
float [] xyzRot;

boolean gotRotation = false;

/**
 * These are used for the ICAT logo at the beginning
 */
float sqX1, sqY1, sqX2, sqY2;
float radOff = 0;
float alphaT = 255;
float lScale = 1.25;
int blackAlpha = 255;

/**
 * These are used for the Leap Motion
 */
LeapMotion leap;
boolean pointerMode = false;
float SIZE_OF_POINTER = 0;
float confirm = 0;
Vector oldPosition = null;
Vector overDotPosition = null;
PImage pan;

float oldZSpeed = 0;
float oldXSpeed = 0;
float pointerX = 0;
float pointerY = 0;
int fingerRegistry = 0;
int fistRegistered = 0;
int isNearDot = 0;
boolean firstTime = true;
boolean swipeAway = false;
boolean swipeAwayLeft = false;

float[] lastNHandX;
float[] lastNHandZ;

float[] lastNPointerX;
float[] lastNPointerZ; 

Hand hand;
HandList hands;
FingerList fingers;

/**
 * These are constants used throughout
 */
int X_WIDTH = 200;
int Z_WIDTH = 200;
int LOW_SPEED_CAP = 0;
int HIGH_SPEED_CAP = 10000;
float SLOWDOWN_FACTOR = 100;
float DELTA = 0.97;
int CONFIRMATION_AMOUNT = 40;
int FIST_CALIBRATE = 50;
int INDEX_CALIBRATE = 10;
int POINTER_COUNT = 15;
int HAND_COUNT = 10;
int KINECT_COUNT = 5;
int SPIN_BUFFER = 50;
int ORB_SIZE = 230;
double HYP = 0;
int TIME = 0;
int DELAY_SWIPEAWAY = 20;
boolean SELECTED_ORB = false;
boolean allClosed = false;
boolean playFlyIn = false;
boolean playFlyOut = false;
boolean afterStart = false;
boolean icat_startup_sound_played = false;
boolean DEV_MODE = false;

void setup() {
  HYP = Math.hypot(ORB_SIZE, 250);
  
  // set window to full screen size
  size(displayWidth, displayHeight, P3D);
  //size(1280, 720, P3D);   //720p
  //size(1280, 1024, P3D);  //SXGA
  //size(1024, 768, P3D);   //iPAD
  
  ambientLight(255,255,255,0,0,0);
  colorMode(HSB, 360, 100, 100);
  smooth(4);
  frameRate(60);

  Ani.init(this);
  Ani.overwrite();

  cam = new PeasyCam(this, zoom);
  cam.setMinimumDistance(2);
  perspective(radians(60), float(width)/float(height), .1, 6000);

  font = loadFont("fonts/ArialMT-96.vlw");
  // failed tests
  //textMode(SHAPE);
  //font = createFont("Arial", 12, true);
  //font = createFont("Arial-BoldMT-48.vlw", 23);
  //textFont(font, 23);

  // load the Entity class... the white points and line on the ORB
  randomSeed(100);
  entity = new Entity[total];
  for (int i = 0; i<total; i++) {
    entity[i] = new Entity(orbLine, orbLineAlpha, orbPoint);
  }

  // custom function for loading all of the data
  loadData();

  // load all of the Movies for the lightBox 
  vids = new Movie[tableTotal];   //tableTotal
  for (int i = 0; i < tableTotal; i++)
  {
    if (videoLoad[i]) 
    {
      vids[i] = new Movie(this, "videos/video_" + i + ".mp4");
      vids[i].stop();
    }
  }
  
  images = new PImage[tableTotal];
  for (int i = 0; i < tableTotal; i++)
  {
    if (imageLoad[i]) 
    {
      images[i] = loadImage("images/image_" + i + ".jpg");
      imageLoad[i] = images[i] != null;
    }
  }
  // add another bezierDetail() with a higher value to the simliar project bezier arcs if this is set low.
  bezierDetail(16);
  
  vt = loadImage("images/VT_tagLine.png");
  rotateOrbImage = loadImage("images/hand_pan.png");
  swipeAwayImage = loadImage("images/hand_swipe.png");
  selectFingerImage = loadImage("images/hand_select.png");
  closeFistImage = loadImage("images/hand_close.png");
  inviteImage = loadImage("images/hand_approach.png");

  // set up kinect
  //kinect = new Kinect(this);
  //tracker = new KinectTracker();
  lastNKinectX = new float[KINECT_COUNT];

  cam.setResetOnDoubleClick(false);
  lastNHandX = new float[HAND_COUNT];
  lastNHandZ = new float[HAND_COUNT];
  
  lastNPointerX = new float[POINTER_COUNT];
  lastNPointerZ = new float[POINTER_COUNT];
  leap = new LeapMotion(this);   
  hand = null;  
  ellipseMode(CENTER);  
  colorMode(HSB);

  // audio setup
  ac = new AudioContext();
  try {
    STARTUP_ICAT = new SamplePlayer(ac, new Sample(sketchPath("") + "data/sounds/intro.wav"));
    STARTUP_ICAT.setKillOnEnd(false);
    BACKGROUND = new SamplePlayer(ac, new Sample(sketchPath("") + "data/sounds/background-001.wav"));
    BACKGROUND.setKillOnEnd(false);
    FOCUS_DOT_ARCS = new SamplePlayer(ac, new Sample(sketchPath("") + "data/sounds/dot_focus3.wav"));
    FOCUS_DOT_ARCS.setKillOnEnd(false);
    SELECT_DOT_ARCS = new SamplePlayer(ac, new Sample(sketchPath("") + "data/sounds/select.wav"));
    SELECT_DOT_ARCS.setKillOnEnd(false);
    LIGHTBOX_FLY_IN_LEFT = new SamplePlayer(ac, new Sample(sketchPath("") + "data/sounds/left-center2.wav"));
    LIGHTBOX_FLY_IN_LEFT.setKillOnEnd(false);
    LIGHTBOX_FLY_IN_RIGHT = new SamplePlayer(ac, new Sample(sketchPath("") + "data/sounds/right-center2.wav"));
    LIGHTBOX_FLY_IN_RIGHT.setKillOnEnd(false);
    LIGHTBOX_FLY_OUT_LEFT= new SamplePlayer(ac, new Sample(sketchPath("") + "data/sounds/center-left.wav"));
    LIGHTBOX_FLY_OUT_LEFT.setKillOnEnd(false);
    LIGHTBOX_FLY_OUT_RIGHT = new SamplePlayer(ac, new Sample(sketchPath("") + "data/sounds/center-right.wav"));
    LIGHTBOX_FLY_OUT_RIGHT.setKillOnEnd(false);
    FOCUS_RETURN_HOME = new SamplePlayer(ac, new Sample(sketchPath("") + "data/sounds/dot_focus3.wav"));
    FOCUS_RETURN_HOME.setKillOnEnd(false);
    RETURN_HOME = new SamplePlayer(ac, new Sample(sketchPath("") + "data/sounds/return2.wav"));
    RETURN_HOME.setKillOnEnd(false);
    SHOW_HAND = new SamplePlayer(ac, new Sample(sketchPath("") + "data/sounds/big_hand.wav"));
    SHOW_HAND.setKillOnEnd(false);
    WELCOME = new SamplePlayer(ac, new Sample(sketchPath("") + "data/sounds/welcome.wav"));
    WELCOME.setKillOnEnd(false);
    ENTER_STANDBY = new SamplePlayer(ac, new Sample(sketchPath("") + "data/sounds/zoom_standby.wav"));
    ENTER_STANDBY.setKillOnEnd(false);
    EXIT_STANDBY = new SamplePlayer(ac, new Sample(sketchPath("") + "data/sounds/exit_standby.wav"));
    EXIT_STANDBY.setKillOnEnd(false);
  }
  catch(Exception e)
  {
    e.printStackTrace();
    println("Exception while atempting to load sample!");
  }

  // creates envelopes for individual sound gains
  BACKGROUND_GAINVALUE = new Envelope(ac, 0.0);   
  STARTUP_ICAT_GAINVALUE = new Envelope(ac, 0.0);
  FOCUS_DOT_ARCS_GAINVALUE = new Envelope(ac, 0.0);
  SELECT_DOT_ARCS_GAINVALUE = new Envelope(ac, 0.0);
  LIGHTBOX_FLY_IN_LEFT_GAINVALUE = new Envelope(ac, 0.0);
  LIGHTBOX_FLY_IN_RIGHT_GAINVALUE = new Envelope(ac, 0.0);
  LIGHTBOX_FLY_OUT_LEFT_GAINVALUE = new Envelope(ac, 0.0);
  LIGHTBOX_FLY_OUT_RIGHT_GAINVALUE = new Envelope(ac, 0.0);
  FOCUS_RETURN_HOME_GAINVALUE = new Envelope(ac, 0.0);
  RETURN_HOME_GAINVALUE = new Envelope(ac, 0.0);
  SHOW_HAND_GAINVALUE = new Envelope(ac, 0.0);
  WELCOME_GAINVALUE = new Envelope(ac, 0.0);
  ENTER_STANDBY_GAINVALUE = new Envelope(ac, 0.0);
  EXIT_STANDBY_GAINVALUE = new Envelope(ac, 0.0);
  
  // creates the gain, the number of inputs and outputs, the glide associated with
  BACKGROUND_GAIN = new Gain(ac, 1, BACKGROUND_GAINVALUE);
  STARTUP_ICAT_GAIN = new Gain(ac, 1, STARTUP_ICAT_GAINVALUE);
  FOCUS_DOT_ARCS_GAIN = new Gain(ac, 1, FOCUS_DOT_ARCS_GAINVALUE);
  SELECT_DOT_ARCS_GAIN = new Gain(ac, 1, SELECT_DOT_ARCS_GAINVALUE);
  LIGHTBOX_FLY_IN_LEFT_GAIN = new Gain(ac, 1, LIGHTBOX_FLY_IN_LEFT_GAINVALUE);
  LIGHTBOX_FLY_IN_RIGHT_GAIN = new Gain(ac, 1, LIGHTBOX_FLY_IN_RIGHT_GAINVALUE);
  LIGHTBOX_FLY_OUT_LEFT_GAIN = new Gain(ac, 1, LIGHTBOX_FLY_OUT_LEFT_GAINVALUE);
  LIGHTBOX_FLY_OUT_RIGHT_GAIN = new Gain(ac, 1, LIGHTBOX_FLY_OUT_RIGHT_GAINVALUE);
  FOCUS_RETURN_HOME_GAIN = new Gain(ac, 1, FOCUS_RETURN_HOME_GAINVALUE);
  RETURN_HOME_GAIN = new Gain(ac, 1, RETURN_HOME_GAINVALUE);
  SHOW_HAND_GAIN = new Gain(ac, 1, SHOW_HAND_GAINVALUE);
  WELCOME_GAIN = new Gain(ac, 1, WELCOME_GAINVALUE);
  ENTER_STANDBY_GAIN = new Gain(ac, 1, ENTER_STANDBY_GAINVALUE);
  EXIT_STANDBY_GAIN = new Gain(ac, 1, EXIT_STANDBY_GAINVALUE);
  
  // connects gains to the sample players
  BACKGROUND_GAIN.addInput(BACKGROUND);
  STARTUP_ICAT_GAIN.addInput(STARTUP_ICAT);                  
  FOCUS_DOT_ARCS_GAIN.addInput(FOCUS_DOT_ARCS);  
  SELECT_DOT_ARCS_GAIN.addInput(SELECT_DOT_ARCS);                  
  LIGHTBOX_FLY_IN_LEFT_GAIN.addInput(LIGHTBOX_FLY_IN_LEFT);                  
  LIGHTBOX_FLY_IN_RIGHT_GAIN.addInput(LIGHTBOX_FLY_IN_RIGHT);                  
  LIGHTBOX_FLY_OUT_LEFT_GAIN.addInput(LIGHTBOX_FLY_OUT_LEFT);                  
  LIGHTBOX_FLY_OUT_RIGHT_GAIN.addInput(LIGHTBOX_FLY_OUT_RIGHT);                  
  FOCUS_RETURN_HOME_GAIN.addInput(FOCUS_RETURN_HOME); 
  RETURN_HOME_GAIN.addInput(RETURN_HOME);          
  SHOW_HAND_GAIN.addInput(SHOW_HAND);
  WELCOME_GAIN.addInput(WELCOME);
  ENTER_STANDBY_GAIN.addInput(ENTER_STANDBY);
  EXIT_STANDBY_GAIN.addInput(EXIT_STANDBY);

  ac.out.addInput(BACKGROUND_GAIN);   
  ac.out.addInput(STARTUP_ICAT_GAIN); 
  ac.out.addInput(FOCUS_DOT_ARCS_GAIN); 
  ac.out.addInput(SELECT_DOT_ARCS_GAIN); 
  ac.out.addInput(LIGHTBOX_FLY_IN_LEFT_GAIN); 
  ac.out.addInput(LIGHTBOX_FLY_IN_RIGHT_GAIN); 
  ac.out.addInput(LIGHTBOX_FLY_OUT_LEFT_GAIN); 
  ac.out.addInput(LIGHTBOX_FLY_OUT_RIGHT_GAIN); 
  ac.out.addInput(FOCUS_RETURN_HOME_GAIN);
  ac.out.addInput(RETURN_HOME_GAIN);
  ac.out.addInput(SHOW_HAND_GAIN);
  ac.out.addInput(WELCOME_GAIN);
  ac.out.addInput(ENTER_STANDBY_GAIN);
  ac.out.addInput(EXIT_STANDBY_GAIN);
  
  ac.start();
}

int curMillis = -10000;

int getMillis()
{
  if (curMillis == -10000)
  {
    curMillis = millis();
  }
  return (millis() - curMillis);
}

void draw() {
  // hide mouse cursor
  //noCursor();
  //print(curMillis+"\n");
  if (getMillis() - mouseTime > 250 && mouseClicks > 0)
  {
    mouseClicks = 0;
  }
  
  // play intro sound
  if (!icat_startup_sound_played && getMillis() >= 2300)
  {
    icat_startup_sound_played = true;
    STARTUP_ICAT.setToLoopStart();
    STARTUP_ICAT.start();
    STARTUP_ICAT_GAINVALUE.addSegment(1, 5);
    //STARTUP_ICAT_GAINVALUE.addSegment(1, 11950);
    //STARTUP_ICAT_GAINVALUE.addSegment(0, 3000);
  }
  
  // delay of opening light box after clicking dot
  if (TIME < 0 && SELECTED_ORB)
  {
     lightBox = true; 
     SELECTED_ORB = false;
     pointerMode = false;
     TIME = -DELAY_SWIPEAWAY;
  }
  else if (TIME >= 0)
    TIME--;
  else if (TIME != 0)
    TIME++;
  
  background(0);
  
  // adjust aniMag (amount of extrusion of related projects on level2?) based on similarity
  magSlide(); 

  // get the camera rotations every frame to pass along to all of the labels and such that need to be oriented towards the camera
  xyzRot = cam.getRotations();

  // when the orb "blows up", showing all the data points
  if (firstTime && getMillis() > 11000)
  {
    selectHome();
    playSelectHomeSound = true;
    afterStart = true;
    zoom = 250;
    firstTime = false;
    cam.lookAt(0, 0, 0, zoom, 1500);

    Envelope speedControl = new Envelope(ac, 1);
    BACKGROUND.setRate(speedControl);
    speedControl.addSegment(0, 0);
    speedControl.addSegment(0, 2000);
    speedControl.addSegment(1, 0);
    BACKGROUND.setLoopType(SamplePlayer.LoopType.LOOP_FORWARDS);
    BACKGROUND.setToLoopStart();
    BACKGROUND.start();
    BACKGROUND_GAINVALUE.addSegment(0, 2000);
    BACKGROUND_GAINVALUE.addSegment(BACKGROUND_MAX_LOUDNESS, 5000);
  }
  
  // ugly bug fix when the orb randomly zooms really close (bug in peasycam?)
  if (getMillis() > 13000 && standby_xfade == 0)
  {
     cam.lookAt(0, 0, 0, zoom);     
  }

  // slowly rotate the sphere, when no hand is present, no light box
  if (!pointerMode && Math.abs(oldZSpeed) < 100 && Math.abs(oldXSpeed) < 100 && TIME < 0)
  {
    cam.rotateY(radians(.0175));
    cam.rotateX(radians(.025));
  }
  
  // turn off the depth test and draw the ORB
  hint(ENABLE_DEPTH_TEST);
  
  // loop thru the Entity class to draw all of the points and connecting distance lines
  for (int i = 0; i<total; i++) {
    entity[i].display(orbLine, orbLineAlpha, orbPoint);
  }
  hint(DISABLE_DEPTH_TEST);
  
  // custom function for all of the Orb drawing
  orbArc();
  // enable the depth test after all of the orb stuff has been drawn...helps with all of the arcs
  
  //custom function just for the ICAT Logo at the beginning
  if (frameCount < 400)
    this.drawIcatLogo();

  //custom function for all of the GUI
  drawGUI();

  cam.beginHUD();
  image(vt, width-165.5, height-63, 148.5, 48);
  if (getMillis() > 13000)
  {    
    if (!lightBox)
    { 
      if (getMillis() > prevFlickerTime1)
      {
        prevFlickerTime1 += FLICKER_TIME;
        prevFlickerTime2 = prevFlickerTime1;

        if (imageFlicker1 <= MAX_FLICKER)
        {
          increment1 = 10; 
        }
        else
        {
          increment1 = 0;
        }
        imageFlicker1 += increment1; 
        if (imageFlicker2 > 0)
        {
           imageFlicker2 -= 30;
        }
        if (imageFlicker2 < 0)
        {
          imageFlicker2 = 0;
        }
      }
    }
    else
    {
      if (getMillis() > prevFlickerTime2)
      {
        prevFlickerTime2 += FLICKER_TIME;
        prevFlickerTime1 = prevFlickerTime2;

        if (imageFlicker2 <= MAX_FLICKER)
        {
          increment2 = 10; 
        }
        else
        {
          increment2 = 0;
        }
        imageFlicker2 += increment2;    
      }
      if (imageFlicker1 > 0)
      {
        imageFlicker1 -= 30; 
      }
      if (imageFlicker1 < 0)
      {
        imageFlicker1 = 0;
      }
    }
    tint(255, imageFlicker1 * (1 - standby_xfade));
    image(rotateOrbImage, 7, 55); 
    image(selectFingerImage, 7, 231);
    if (level2 != -1)
    {
      image(closeFistImage, 7, 331);
    }
    tint(255, imageFlicker2 * (1 - standby_xfade));
    image(swipeAwayImage, 7, 90); 
  }
  
  // this handles invite hand that pops up following the timeout
  if (!bodyClose && getMillis() > 13000)
  {
    if (INVITE_TIMER == -1)
    {
      //println("reset timer");
      INVITE_TIMER = getMillis();
      invite_ani_state = 0;
      invite_flicker = 0;
    }
    else if (getMillis() - INVITE_TIMER > INVITE_TIMEOUT + (INVITE_TIMEOUT * 3 * (hasLightBox() ? 1 : 0)) )
    {
      if (invite_ani_state == 0)
      {
        invite_ani_state = 1;
        inviteAni = new Ani(this, 2, "invite_flicker", 100, Ani.SINE_IN_OUT, "onEnd:updateInviteAni");
        SHOW_HAND.setToLoopStart();
        SHOW_HAND.start();
        SHOW_HAND_GAINVALUE.addSegment(1, 5);
      }
      tint(255, invite_flicker);
      image(inviteImage, displayWidth/2 - inviteImage.width/2, displayHeight/2 - inviteImage.height/2); 
    }
  }
  else
  {
    if (INVITE_TIMER > 0)
    {
      if (invite_flicker > 0)
      {
        inviteAni.pause();
        inviteAni = new Ani(this, 0.5, "invite_flicker", 0, Ani.SINE_IN_OUT, "onEnd:updateInviteAni");
      }
      invite_ani_state = 0;
      INVITE_TIMER = -1;  
    }
    if (invite_flicker > 0)
    {
      tint(255, invite_flicker);
      image(inviteImage, displayWidth/2 - inviteImage.width/2, displayHeight/2 - inviteImage.height/2);
    }
  }
  
  noTint();
  cam.endHUD();

  // draws the pointer on screen
  updatePointer();
  
  // timer for the standby mode
  if (!bodyClose && standby == 0)
  {
    if (STANDBY_TIMER == -1)
    {
      STANDBY_TIMER = getMillis();
    }
    if (getMillis() - STANDBY_TIMER >= STANDBY_TIMEOUT)
    {
      standby = 1;
    }
  }
  else if ((bodyClose || standby_override) && standby > 0)
  {
    STANDBY_TIMER = -1;
    standby = 3;
  }
  
  // standby animation
  if ((bodyClose || standby_override) && getMillis() > 13000)
  {
    STANDBY_TIMER = -1;
    if (standby == 3)
    {
      if (standby_xfade > 0 && inStandbyPosition)
      {
        Ani.to(this, 0.5, "standby_xfade", 0, Ani.SINE_IN_OUT);
        Ani.to(this, 0.5, "orbFillAlpha", 25, Ani.SINE_IN_OUT);
        Ani.to(this, 0.5, "spikeOut", 15, Ani.SINE_IN_OUT);
        // we do this here to prevent reentry to this part of the code on every frame
        inStandbyPosition = false;
        playExitStandby();
      }
      if (standby_xfade == 0)
      {
        standby_override = false;
        standby = 0;
      }
      cam.lookAt(0, 0, 0, zoom - standby_xfade * 50, 0);
    }
  }
  
  if (!bodyClose && getMillis() > 13000)
  {
    if (standby == 1)
    {
      if (lightBox)
      {
        lightBox = false;
        swipeAway = true;
        select = true;
        swipeAwayLeft = !swipeAwayLeft;
      }
      if (!allLabels) selectHome();
      if (standby_xfade == 0)
      {
        Ani.to(this, 5, "standby_xfade", 1, Ani.SINE_IN_OUT);
        Ani.to(this, 5, "orbFillAlpha", 60, Ani.SINE_IN_OUT);
        Ani.to(this, 5, "spikeOut", 0, Ani.SINE_IN_OUT);
        inStandbyPosition = true;
        playEnterStandby();
      }
      if (standby_xfade == 1)
      {
        standby = 2;
      }
      cam.lookAt(0, 0, 0, zoom - standby_xfade * 50, 0);
    }
  }
  
  // read and process kinect data
  //tracker.track();
  //kinect_h_delta = tracker.getHLerpedDelta(1);
  kinectRotateLeftAndRight();
  
  // DEBUG:
  //println("standby=" + standby + " standby_xfade=" + standby_xfade + " STANDBY_TIMER=" + STANDBY_TIMER + " bodyClose=" + bodyClose);
  //float[] dbglookat = cam.getLookAt(); 
  //println("cam info: " + cam.getDistance() + " " + dbglookat[0] + " "  + dbglookat[1] + " "  + dbglookat[2] + " "); 
}

// used to update invite hand animation
void updateInviteAni()
{
  //println("updateInviteAni " + invite_ani_state + " " + invite_flicker);
  if (invite_ani_state == 1)
  {
    inviteAni = new Ani(this, 2, "invite_flicker", 20, Ani.SINE_IN_OUT, "onEnd:updateInviteAni");
    invite_ani_state = 2;
  }
  else if (invite_ani_state == 2)
  {
    inviteAni = new Ani(this, 2, "invite_flicker", 100, Ani.SINE_IN_OUT, "onEnd:updateInviteAni");
    invite_ani_state = 1;
  }
}


void movieEvent(Movie m)
{
  m.read();
}

void addNewPointX(float point)
{
  for (int i = lastNPointerX.length - 1; i > 0; i--)
  {
    lastNPointerX[i] = lastNPointerX[i - 1];
  } 
  lastNPointerX[0] = point;
}

void addNewPointZ(float point)
{
  for (int i = lastNPointerZ.length - 1; i > 0; i--)
  {
    lastNPointerZ[i] = lastNPointerZ[i - 1];
  } 
  lastNPointerZ[0] = point;
}

void addNewHandX(float point)
{
  for (int i = lastNHandX.length - 1; i > 0; i--)
  {
    lastNHandX[i] = lastNHandX[i - 1];
  } 
  lastNHandX[0] = point;
}

void addNewHandZ(float point)
{
  for (int i = lastNHandZ.length - 1; i > 0; i--)
  {
    lastNHandZ[i] = lastNHandZ[i - 1];
  } 
  lastNHandZ[0] = point;
}

void addNewKinectX(float point)
{
  for (int i = lastNKinectX.length - 1; i > 0; i--)
  {
    lastNKinectX[i] = lastNKinectX[i - 1];
  } 
  lastNKinectX[0] = point;
}

/**
 * Checks for if it is pointer mode, and displays the pointer
 */
void updatePointer()
{
  if (pointerMode && (!hands.isEmpty() && hand != null))
  {
    //gets the location of the finger, but uses the palm since its easier to track
    Vector position = hand.palmPosition();
    
    //scales the x and y to fit based on the width and height
    float xPos = position.getX();
    // use this for Z axis
    //float zPos = position.getZ();
    // use this for Y axis
    float zPos = 20 - (position.getY() - 250)/1.75;
    
    // map the x coordinate to fit to the screen
    float mX = 2 * ((displayWidth) * X_WIDTH) / (2 * (float)Math.pow(X_WIDTH, 2));    
    float bX = (displayWidth) /2;
    float x = (xPos * mX) + bX;
    if (x < SIZE_OF_POINTER) x = SIZE_OF_POINTER;
    if (x > displayWidth - SIZE_OF_POINTER) x = displayWidth - SIZE_OF_POINTER;
    
    // map the z coordinate to fit to the screen
    float mZ = 3 * ((displayHeight) * Z_WIDTH) / (2 * (float)Math.pow(Z_WIDTH, 2));    
    float bZ = (displayHeight) / 3.5;
    float z = (zPos * mZ) + bZ;
    if (z < SIZE_OF_POINTER) z = SIZE_OF_POINTER;
    if (z > displayHeight - SIZE_OF_POINTER) z = displayHeight - SIZE_OF_POINTER;
   
    if (fingerRegistry == INDEX_CALIBRATE+1)
    {
      for(int i = 0; i < POINTER_COUNT; i++)
      {
        addNewPointX(x);
        addNewPointZ(z);
      }
      fingerRegistry++;
    }
    else
    {
      addNewPointX(x);
      addNewPointZ(z);
    }
    
    pointerX = avg(lastNPointerX);
    pointerY = avg(lastNPointerZ);
    
    scaleAndDrawPointer();     
    
    //if a new location has been chosen
    if (oldPosition == null)
    {
      oldPosition = position;
      FOCUS_DOT_ARCS_GAINVALUE.addSegment(0, 5);
    }
    
    // if the pointer is in the same location
    // oldFoundIndex is used to check for accidental leaps from
    // one nearby dot to another
    else if (distance(oldPosition.getX(), position.getX(), oldPosition.getY(), position.getY()) <= 15.0 && isNearDot > 0)
    {
        if (oldFoundIndex != foundIndex && !delaySpin() && !hasLightBox())
        {
          oldFoundIndex = foundIndex;
          confirm = 0;
          FOCUS_DOT_ARCS.setToLoopStart();
          FOCUS_DOT_ARCS_GAINVALUE.addSegment(1.5, 5);
          FOCUS_DOT_ARCS.start();
        }
        else
        {
          confirm += 1;
        }
        if (confirm > CONFIRMATION_AMOUNT)
          confirm = CONFIRMATION_AMOUNT;
    }
    
    // if the finger has moved to a new place
    else
    {
      confirm = 0;      
      oldPosition = null;
      oldFoundIndex = -1;
      FOCUS_DOT_ARCS_GAINVALUE.addSegment(0, 5);
    }       
  }  
  else
  {
    confirm = 0;
    oldPosition = null;
    oldFoundIndex = -1;
    FOCUS_DOT_ARCS_GAINVALUE.addSegment(0, 5);
  }
}

/**
 * Scales the pointer and draws it to the screen
 */
void scaleAndDrawPointer()
{
  if (found == null && SELECTED_ORB == false)
  {
    cam.beginHUD();
    scalePointer();
    colorMode(RGB);
    translate(pointerX, pointerY);  
    fill(127, 40);  
    ellipseMode(CENTER);  
    stroke(255, 170);
    strokeWeight(1);
    ellipse(0, 0, SIZE_OF_POINTER, SIZE_OF_POINTER);
    cam.endHUD();  
    colorMode(HSB);
  }
}

/**
 * Scales the size of the pointer, based on the distance from the center of the sphere/orb
 */
void scalePointer()
{
  float size = (float) Math.sqrt(Math.pow( (pointerX - width/2), 2) + Math.pow( (pointerY - height/2), 2));
  SIZE_OF_POINTER = ((size * -0.0177777778) + 40);
  //println(SIZE_OF_POINTER + " " + size);  
}

/**
 * Called when the controller is initialized
 */
void onInit(final Controller controller)
{
  controller.enableGesture(Gesture.Type.TYPE_CIRCLE);
  controller.enableGesture(Gesture.Type.TYPE_KEY_TAP);
  controller.enableGesture(Gesture.Type.TYPE_SCREEN_TAP);
  controller.enableGesture(Gesture.Type.TYPE_SWIPE);
  // enable background policy
  controller.setPolicyFlags(Controller.PolicyFlag.POLICY_BACKGROUND_FRAMES);
}

int oldTime = 0;
boolean readRotationLastFrame = false;

/**
 * Called on every new frame
 */
void onFrame(final Controller controller)
{
  if (getMillis()-oldTime == 0)
    return;
  oldTime = getMillis();
  Frame frame = controller.frame();  
  hands = frame.hands(); 
  fingers = frame.fingers();  
  pointerMode = false;

  if (hands.isEmpty() && !kinect_debug)
  {
    bodyClose = false;
  }
  if (hands.count() > 0 && (!kinect_debug || standby_xfade > 0))
  {
    bodyClose = true;
    kinect_debug = false;
  }

  if(!lightBox)
  {  
    // if no hands are present (and kinect is not capturing any delta)
    if (kinect_h_delta == 0 && (hands.isEmpty() || Math.abs(hands.get(0).palmPosition().getZ()) > Z_WIDTH || Math.abs(hands.get(0).palmPosition().getX()) > X_WIDTH))
    {
      stopFocusReturnHome();
      fistRegistered = 0;
      readRotationLastFrame = false;
      if (oldZSpeed != 0)
      {
        if (Math.abs(oldZSpeed) < 0.01)
        {
          oldZSpeed = 0;  
        }
        oldZSpeed *= DELTA;
        cam.rotateX(radians(oldZSpeed/SLOWDOWN_FACTOR));        
      }     
      if (oldXSpeed != 0)
      {        
        if (Math.abs(oldXSpeed) < 0.01)
        {
          oldXSpeed = 0;  
        }
        oldXSpeed *= DELTA;
        cam.rotateY(radians(oldXSpeed/SLOWDOWN_FACTOR));        
      }
    }
    
    // if one hand is detected
    else if (hands.count() == 1)
    {
      hand =  hands.get(0);
      boolean indexOut = isIndexFingerExtended();
      allClosed = isFistClosed();
       
      // if fist is closed
      if(allClosed)
      {
        // do not register finger
        fingerRegistry = 0;

        // if fist has been active for FIST_CALIBRATE number of frames, then return to home orb
        if (fistRegistered > FIST_CALIBRATE)
        {
          FOCUS_RETURN_HOME_GAINVALUE.addSegment(1.5, 495);
          FOCUS_RETURN_HOME_GAINVALUE.addSegment(0, 5);
          selectHome();   
          fistRegistered = 0;
        }
        // otherwise add to fist counter
        else if (level2 != -1 && !delaySpin() && !hasLightBox())
        {
          if (fistRegistered == 0)
          {
            FOCUS_RETURN_HOME.setToLoopStart();
            FOCUS_RETURN_HOME.start();
            FOCUS_RETURN_HOME_GAINVALUE.addSegment(1.5, 5); 
          }
          fistRegistered++;
        }
      }
       
      // if the index finger is not out
      else if(!indexOut)
      {
        rotateUpAndDown();
        rotateLeftAndRight(); 
        pointerMode = false;
        fingerRegistry = 0;
        if (fistRegistered > 0)
        {
          stopFocusReturnHome();
          fistRegistered = 0;
        }
        readRotationLastFrame = true;
      }
       
      // if the index finger is pointing
      else if (indexOut)
      {
        if (fistRegistered > 0)
        {
          stopFocusReturnHome();
          fistRegistered = 0;
        }
        if (fingerRegistry > INDEX_CALIBRATE)
        {
           pointerMode = true;
        }    
        else
        {  
          rotateUpAndDown();
          rotateLeftAndRight();
          fingerRegistry++;
          readRotationLastFrame = true;
        }
      }  
       
      // fist is not closed
      else
      {
        fingerRegistry = 0;
        if (fistRegistered > 0)
        {
          stopFocusReturnHome();
          fistRegistered = 0;
        }
      }
    }
    
    // no hands or more than one hand
    else
    {
      stopFocusReturnHome();
      fistRegistered = 0;
    }
  }
  else
  {    
    swipeAway();    
  }
}

/**
 * Swipes away the light Box
 */
void swipeAway()
{
  if (!hands.isEmpty() && lightBox)
  {
    hand = hands.get(0);
    Vector speed = hand.palmVelocity();
    float xSpeed = speed.getX();
    if (TIME == 0 && Math.abs(xSpeed) >= 500 && Math.abs(hand.palmPosition().getX()) <= X_WIDTH)
    {      
      lightBox = false;
      select = true;
      SPIN_BUFFER = 50;
      swipeAway = true;
      if (xSpeed < 0)
        swipeAwayLeft = true;
      else
        swipeAwayLeft = false;
    }  
  }
}

/**
 * Rotates the sphere/orb left and right based on the kinect-captured delta
 */
void kinectRotateLeftAndRight()
{
  if (!bodyClose && getMillis() > 13000)
  {
    if (WELCOME_TIMER == -1)
    {
      WELCOME_TIMER = getMillis();
    }
    if (abs(kinect_h_delta) > KINECT_MIN_THRESHOLD)
    {
      addNewKinectX(kinect_h_delta);
      kinectXSpeed = avg(lastNKinectX);
      if (getMillis() > WELCOME_TIMEOUT + WELCOME_TIMER)
      {
        playWelcome();
        WELCOME_TIMER = getMillis();
      }
    }
    else
    {
      addNewKinectX(0);
    }
    kinectXSpeed *= DELTA;
    //println("kinectRotateLeftAndRight " + kinect_h_delta + " " + kinectXSpeed);
    cam.rotateY(radians(kinectXSpeed/10));
  }
  else
  {
    WELCOME_TIMER = getMillis();
    if (WELCOME.getPosition() > 0 && WELCOME.getPosition() < 5000)
    {
      WELCOME_GAINVALUE.addSegment(0, 5);
    }
  }
}

/**
 * Rotates the sphere/orb up and down based on the angle of your hand
 */
void rotateUpAndDown()
{    
  if (!delaySpin() && !hasLightBox())
  {
    Vector speed = hand.palmVelocity();
    float zSpeed = speed.getZ();
    if (Math.abs(zSpeed) >= LOW_SPEED_CAP && Math.abs(hand.palmPosition().getZ()) <= Z_WIDTH && Math.abs(zSpeed) < HIGH_SPEED_CAP)
    {
      if (!readRotationLastFrame)
      {
        for (int i=0; i < HAND_COUNT; i++)
          addNewHandZ(zSpeed);
      }
      else
        addNewHandZ(zSpeed);
      oldZSpeed = avg(lastNHandZ);
      //println("rotateUpAndDown" + radians(oldZSpeed/SLOWDOWN_FACTOR));
      cam.rotateX(radians(oldZSpeed/SLOWDOWN_FACTOR));
    }    
  }
}

/**
 * Rotates the sphere/orb left and right based on the position relative to the LeapMotion
 */
void rotateLeftAndRight()
{
  if (!delaySpin() && !hasLightBox())
  {
    Vector speed = hand.palmVelocity();
    float xSpeed = speed.getX();
    if (Math.abs(xSpeed) >= LOW_SPEED_CAP && Math.abs(hand.palmPosition().getX()) <= X_WIDTH && Math.abs(xSpeed) < HIGH_SPEED_CAP)
    {
      oldXSpeed = -1 * xSpeed;
      if (!readRotationLastFrame)
      {
        for (int i=0; i < HAND_COUNT; i++)
          addNewHandX(oldXSpeed);
      }
      else
        addNewHandX(oldXSpeed);
      oldXSpeed = avg(lastNHandX);
      //println("rotateLeftAndRight" + radians(oldXSpeed/SLOWDOWN_FACTOR));
      cam.rotateY(radians(oldXSpeed/SLOWDOWN_FACTOR));
    }
  }
}

/**
 * Checks to make sure only the index finger is extended
 */
boolean isIndexFingerExtended()
{
  int count = 0;
  for (Finger finger : fingers)
  {
    if (finger.type().toString().equals("TYPE_INDEX") && finger.isExtended())
    {
      count--;        
    }    
    else if (!finger.isExtended()) 
    {    
      count++;
    } 
  }
  return count >= 2;  
}

boolean isFistClosed()
{
  int count = 0;
  for (Finger finger : fingers)
  {
    // we ignore the thumb due to leap motion's inconsistent detection of the thumb
    if (!finger.isExtended() || finger.type().toString().equals("TYPE_THUMB"))
      count++;    
  }
  return count == fingers.count();  
}

boolean delaySpin()
{
  if (SPIN_BUFFER == 0)
  {
    return false;
  } 
  else
  {
    SPIN_BUFFER--;
    return true;
  }
}

/**
 * Distance formula
 */ 
float distance(float x1, float x2, float y1, float y2)
{
  float diff = (float) Math.sqrt(Math.pow( (x1 - x2), 2) + Math.pow( (y1 - y2), 2));
  return diff;  
}

boolean clicked()
{
  return confirm >= CONFIRMATION_AMOUNT;
}


float avg(float[] data)
{
  float total = 0;
  float amount = 0;
  for (Float fl : data)
  {
    total += fl;
    amount++;
  }  
  return total/amount; 
}

boolean hasLightBox()
{
  return (SELECTED_ORB || lightBox);
}

void stop()
{
  super.stop();
}

void drawIcatLogo()
{
  pushMatrix();
  translate(0, 0, 0);
  scale(1.35);
  stroke(240, alphaT);
  strokeWeight(2);
  noFill();
  rectMode(CORNER);
  radOff=15;
  rect(radOff/2, radOff/2, -100, -100, 0, 0, radOff/2, 0);
  rect(-radOff/2, -radOff/2, 60, 60, radOff/2, 0, 0, 0);
  textFont(font, 8);
  fill(180, alphaT);
  textAlign(LEFT);
  text("Institute for Creativity, Arts, and Technology", -85+(radOff/2), -85+(radOff/2), 50, 200);
  popMatrix();
  // after 4.5 seconds, fade away
  if (getMillis() > 4500) {
    alphaT += -2;
  }        
}

void playClickDot()
{
  if (!SELECTED_ORB)
  {
    FOCUS_DOT_ARCS_GAINVALUE.addSegment(0, 5);
    SELECT_DOT_ARCS.setToLoopStart();
    SELECT_DOT_ARCS_GAINVALUE.addSegment(1, 5);
    SELECT_DOT_ARCS.start();
  }
}

void playReturnHome()
{
  if (playSelectHomeSound)
  {
    RETURN_HOME.setToLoopStart();
    RETURN_HOME.start();
    RETURN_HOME_GAINVALUE.addSegment(1, 5);
  }
}

void stopFocusReturnHome()
{
  if (FOCUS_RETURN_HOME_GAINVALUE.getCurrentValue() > 0)
  {
    FOCUS_RETURN_HOME_GAINVALUE.setValue(FOCUS_RETURN_HOME_GAINVALUE.getCurrentValue());
    FOCUS_RETURN_HOME_GAINVALUE.addSegment(0, 5);
  }
}

void playFlyInFromLeft()
{
  LIGHTBOX_FLY_IN_LEFT.setToLoopStart();
  LIGHTBOX_FLY_IN_LEFT.start();
  LIGHTBOX_FLY_IN_LEFT_GAINVALUE.addSegment(0.5, 250);
  BACKGROUND_GAINVALUE.addSegment(0, 250);
}

void playFlyInFromRight()
{
  LIGHTBOX_FLY_IN_RIGHT.setToLoopStart();
  LIGHTBOX_FLY_IN_RIGHT.start();
  LIGHTBOX_FLY_IN_RIGHT_GAINVALUE.addSegment(0.5, 250);
  BACKGROUND_GAINVALUE.addSegment(0, 250);
}

void playSwipeAwayLeft()
{
  LIGHTBOX_FLY_OUT_LEFT.setToLoopStart();
  LIGHTBOX_FLY_OUT_LEFT.start();
  LIGHTBOX_FLY_OUT_LEFT_GAINVALUE.addSegment(1, 5);
  playFlyOut = true;
  BACKGROUND_GAINVALUE.addSegment(BACKGROUND_MAX_LOUDNESS, 5000);
}

void playSwipeAwayRight()
{
  LIGHTBOX_FLY_OUT_RIGHT.setToLoopStart();
  LIGHTBOX_FLY_OUT_RIGHT.start();
  LIGHTBOX_FLY_OUT_RIGHT_GAINVALUE.addSegment(1, 5);
  playFlyOut = true;
  BACKGROUND_GAINVALUE.addSegment(BACKGROUND_MAX_LOUDNESS, 5000);
}

void playWelcome()
{
  Envelope welcomeSpeedControl = new Envelope(ac, 1);
  WELCOME.setRate(welcomeSpeedControl);
  welcomeSpeedControl.addSegment(0, 0);
  welcomeSpeedControl.addSegment(0, 1000);
  welcomeSpeedControl.addSegment(1, 0);
  WELCOME.setToLoopStart();
  WELCOME.start();
  WELCOME_GAINVALUE.addSegment(0.5, 5);  
}

void playEnterStandby()
{
  ENTER_STANDBY.setToLoopStart();
  ENTER_STANDBY.start();
  ENTER_STANDBY_GAINVALUE.addSegment(1, 5);
  BACKGROUND_GAINVALUE.addSegment(0, 2000);
}

void playExitStandby()
{
  EXIT_STANDBY.setToLoopStart();
  EXIT_STANDBY.start();
  EXIT_STANDBY_GAINVALUE.addSegment(1, 5);
  BACKGROUND_GAINVALUE.addSegment(BACKGROUND_MAX_LOUDNESS, 5000);
}

