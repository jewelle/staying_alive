/*
Jack the Maker for CUF (Jose de Mello Saude) @ Web Summit
CPR Game Machine
October 2018
*/

boolean sequenceStarted = false; // detect whether the sequence & game have started
PFont myFont; // variable to load font
int fontSize = 32; // change this to change font size in the whole project
// make 31 PImages variables to hold the jpg files for the pages
PImage[] pages = new PImage[28];
int startingTime;
int currentTime;
int pageNum = 0;
int pageTurn = 3; // time spent on each slide (in seconds)


void setup(){  
  //size(200, 100); // delete if full screen
  fullScreen(); // uncomment this for the full screen game on touch pad
  background(255);
  //noCursor(); // uncomment this to hide the cursor for the full screen game
  myFont = createFont("Effra", fontSize);
  textFont(myFont);
  textSize(fontSize); 
  
  // load and resize images to screen
  // make sure theyre scaled. can make 1 variable 0
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
        startingTime = second(); // establish a time on which to base the slideshow
        pageNum = 1;
        //delay(pageTurn*100); // slight delay from when they click the screen? maybe delete?
        image(pages[pageNum], 0, 0);
       }
      else if (sequenceStarted == false){ // draw start screen
        image(pages[0], 0, 0);
      }
      else if (sequenceStarted == true){
        if (pageNum >= pages.length){
          sequenceStarted = false;
          pageNum = 0;
        }
        image(pages[pageNum], 0, 0);
        currentTime = second();
        println(currentTime - startingTime);
        if (currentTime - startingTime == pageTurn){ // problematic when seconds become 0. how to do this in millis?
        pageNum++;
        startingTime = startingTime + pageTurn;
        }
      }
}
