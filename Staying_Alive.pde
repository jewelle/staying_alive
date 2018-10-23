/*
Jack the Maker for CUF (Jose de Mello Saude) @ Web Summit
CPR Game Machine
October 2018
*/

boolean firstDone, secondDone, thirdDone = false; // 
PFont myFont; // variable to load font
int fontSize = 32; // change this to change font size in the whole project


void setup(){  
  size(200, 100); // delete if full screen
  //fullScreen(); // uncomment this for the full screen game on touch pad
  background(255);
  //noCursor(); // uncomment this to hide the cursor for the full screen game
  myFont = createFont("Effra", fontSize);
  textFont(myFont);
  textSize(fontSize);
}

void draw (){
      if (mousePressed == true & firstDone == false & secondDone == false & thirdDone == false){
        fill(0);
        text ("PAGE 1", width/2, height/2);
        firstDone = true;
        delay (100);
      }
      else if (mousePressed == true & firstDone == true & secondDone == false & thirdDone == false){
        background(255);
        text ("PAGE 2", width/2, height/2);
        secondDone = true;
        delay (100);
      }
      else if (mousePressed == true & secondDone == true & thirdDone == false){
        background(255);
        text ("PAGE 3", width/2, height/2);
        thirdDone = true;
        delay (100);
      }
      else if (mousePressed == true & thirdDone == true){
        background(255);
        text ("START GAME", width/2, height/2);
        delay (100);
      }
}
