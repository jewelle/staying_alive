/*
Jack the Maker for CUF (Jose de Mello Saude) @ Web Summit
CPR Game Machine
October 2018
*/

// "WAV, AIF/AIFF, MP3. MP3 decoding can be very slow on ARM processors (Android/Raspberry Pi), we generally recommend you use lossless WAV or AIF files."
  
import processing.sound.*;
SoundFile file;

boolean sequenceStarted = false; // detect whether the sequence & game have started
PFont myFont; // variable to load font
int fontSize = 32; // change this to change font size in the whole project
PImage[] pages = new PImage[28]; // make 31 PImages variables to hold the jpg files for the pages
int startingTime;
int currentTime;
int pageNum = 0;
int pageTurn = 3000; // time spent on each slide (in milliseconds)
int gifRate = 500; // this is going to be complicated to indicate which files are gif files. maybe should make 2 types of files and loop them separately.

void setup(){  
  frameRate(10); // can be changed
  //size(200, 100); // delete if full screen
  fullScreen(); // uncomment this for the full screen game on touch pad
  //noCursor(); // uncomment this to hide the cursor for the full screen game
  background(255);
  myFont = createFont("Effra", fontSize);
  textFont(myFont);
  textSize(fontSize); 
  file = new SoundFile(this, "stayinalive.wav");
  
  // load and resize images to screen
  // make sure theyre scaled. can make one of the variables 0 for scaling
  for (int i = 0; i < pages.length; i++){
    pages[i] = loadImage("pg"+i+".jpg");
    pages[i].resize(width, height); // sizes the images to the screen width and height.
  }
  image(pages[0], 0, 0); // display the first screen on startup
}

void draw (){
  background(255);
      if (mousePressed == true & sequenceStarted == false){ // start sequence
        sequenceStarted = true;
        startingTime = millis(); // establish a time on which to base the slideshow
        pageNum = 1;
        //delay(pageTurn*100); // slight delay from when they click the screen? maybe delete?
        image(pages[pageNum], 0, 0);
       }
      else if (sequenceStarted == false){ // draw start screen
        image(pages[0], 0, 0);
      }
      else if (sequenceStarted == true){
         // check whether file is playing. if not playing, play - file.play();
        if (pageNum >= pages.length){
          sequenceStarted = false;
          pageNum = 0;
        }
        image(pages[pageNum], 0, 0);
        currentTime = millis();
        println(currentTime - startingTime);
        if (currentTime - startingTime > pageTurn){
        pageNum++;
        startingTime = startingTime + pageTurn;
        }
      }
}

// maybe make a separate function to play the music once a certain file has been reached.
