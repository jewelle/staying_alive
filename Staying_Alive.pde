/*
Jack the Maker for CUF (Jose de Mello Saude) @ Web Summit
CPR Game Machine
October 2018
*/

// WAV or AIF are recommended file formats for the SoundFile library when using Raspberry Pi.
  
import processing.sound.*;
SoundFile file;

boolean sequenceStarted = false; // detect whether the sequence & game have started
boolean gameStarted = false;
PFont myFont; // variable to load font
int fontSize = 32; // change this to change font size in the whole project
PImage[] pages = new PImage[28]; // make 28 PImages variables to hold the jpg files for the pages
int startingTime;
int currentTime;
int pageNum = 0;
int pageTurn = 500; // time spent on each slide (in milliseconds)
int gifRate = 500; // this is going to be complicated to indicate which files are gif files. maybe should make 2 types of files and loop them separately.


void setup(){ 
  println(pages.length);
  //Sound s = new Sound(this); // uncomment these for use with pi
  //s.outputDevice(1); // uncomment these for use with pi
  file = new SoundFile(this, "stayinalive.wav");
  
  frameRate(10); // can be changed
  size(200, 100); // delete if full screen
  //fullScreen(); // uncomment this for the full screen game on touch pad
  //noCursor(); // uncomment this to hide the cursor for the full screen game
  background(255);
  
  // font things for writing score to screen
  /*myFont = createFont("Effra", fontSize);
  textFont(myFont);
  textSize(fontSize); 
  */
    
  // load and resize images to screen
  // make sure theyre scaled. can make one of the variables 0 for scaling
  for (int i = 0; i < pages.length; i++){
    pages[i] = loadImage("pg"+i+".jpg");
    pages[i].resize(width, height); // sizes the images to the screen width and height.
  }
  image(pages[0], 0, 0); // display the first screen on startup
}

void draw (){
  background(255); // to refresh when drawing to the screen every frame
      
      // If someone touches the screen to start
      if (mousePressed == true & sequenceStarted == false){ // start sequence
        sequenceStarted = true;
        startingTime = millis(); // establish a time on which to base the slideshow
        pageNum = 1; // turn the page
        //delay(pageTurn*100); // slight delay from when they click the screen? maybe delete?
        image(pages[pageNum], 0, 0);
       }
       
      // Waiting screen (this will be animated too)
      else if (sequenceStarted == false){ 
        image(pages[0], 0, 0); // draw start screen
      }
      
      // Cycling through display sequence after someone has pressed to start
      else if (sequenceStarted == true && gameStarted == false){
        image(pages[pageNum], 0, 0);
        currentTime = millis();
        if (currentTime - startingTime > pageTurn){
          pageNum++;
          startingTime = startingTime + pageTurn;
          if (pageNum >= 16){ // if the entry sequence has finished
            file.play(); // start playing stayin alive
            gameStarted = true;
          }
        }
      }
      
      // Playing game
      else if (gameStarted == true){
        //change screen according to how they're playing
        image(pages[17], 0, 0); // currently just displaying happy face
        if (file.isPlaying() == false){ // if file has stopped playing, stop game *go to scoring sequence
            sequenceStarted = false;
            gameStarted = false;
            pageNum = 0;
        }
      }
}
