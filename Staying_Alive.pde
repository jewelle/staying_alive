/*
Jack the Maker for CUF (Jose de Mello Saude) @ Web Summit
CPR Game Machine
October 2018
*/

// WAV or AIF are recommended file formats for the SoundFile library when using Raspberry Pi.

import processing.sound.*;
SoundFile file;
import cc.arduino.*;
import org.firmata.*;
import processing.serial.*;

Table table;
Arduino arduino; // change to pi for final sketch
boolean sequenceStarted = false; // detect whether the sequence & game have started
boolean gameStarted = false;
boolean showRanking = false;
boolean showScore = false;
PFont myFont; // variable to load font
int fontSize = 25; // change this to change font size in the whole project
PImage[] pages = new PImage[28]; // make 28 PImages variables to hold the jpg files for the pages. change for number of pages.
int pageNum = 0;
int pageTurn = 500; // time spent on each slide (in milliseconds)
int scorePageTurn = 4000; // time spent on each slide (in milliseconds)
int gifRate = 500; // this is going to be complicated to indicate which files are gif files. maybe should make 2 types of files and loop them separately.
int startingTime, currentTime, pressedtime, nowtime, scoreStartingTime, scoreCurrentTime;
int beatSwitchState, lastBeatSwitchState, pressureSwitchState, lastPressureSwitchState, bpmlowerlimit, bpmupperlimit, score, ranking, playerNum, displayface;
int bpm = 576; // song bpm. Heart Association recommended BPM between 500-600
int margin = 30; // change this between about 25 - 100 to make it more or less difficult
int beatSwitch = 12; // pin for beat switch (top one)
int pressureSwitch = 13; // pin for pressure switch (lower one)

void setup(){ 
  table = loadTable("data/scores.csv", "header"); //loads the master score file on start up
  //eraseScores(); // use this to create a clean file (hopefully just for testing)
  table.setColumnType("score", Table.INT); // sets the scores as integers so they are parsed correctly when ordering the table.
  println(Arduino.list()); // change to pi for final sketch
  arduino = new Arduino(this, "/dev/cu.usbmodem14101", 57600); // change to pi for final sketch
  arduino.pinMode(beatSwitch, Arduino.INPUT_PULLUP); // change to pi for final sketch
  arduino.pinMode(pressureSwitch, Arduino.INPUT_PULLUP); // change to pi for final sketch
  bpmlowerlimit = bpm-margin;
  bpmupperlimit = bpm+margin;
  score = 0;

  //Sound s = new Sound(this); // uncomment these for use with pi
  //s.outputDevice(1); // uncomment these for use with pi
  file = new SoundFile(this, "stayinalive.wav");
  
  frameRate(10); // can be changed
  //size(470, 280); // delete if full screen
  fullScreen(); // uncomment this for the full screen game on touch pad
  //noCursor(); // uncomment this to hide the cursor for the full screen game
  background(255);
  
  // font things for writing score to screen
  myFont = createFont("Effra", fontSize);
  textFont(myFont);
  textSize(fontSize); 
   
  // load and resize images to screen
  // make sure theyre scaled. can make one of the variables 0 for scaling
  for (int i = 0; i < pages.length; i++){
    pages[i] = loadImage("pg"+i+".jpg");
    pages[i].resize(width, height); // sizes the images to the screen width and height.
  }
  image(pages[0], 0, 0); // display the first screen on startup
}

void draw (){
  background(0); // to refresh when drawing to the screen every frame
  checkShowScore();
  // If someone touches the screen to start
  if (mousePressed == true & sequenceStarted == false){ // start sequence
    startSequence();
  }     
  // Waiting screen (this will be animated too)
  else if (sequenceStarted == false && showScore == false){ 
    image(pages[0], 0, 0); // draw start screen
  } 
  // Cycling through display sequence after someone has pressed to start
  else if (sequenceStarted == true && gameStarted == false && showRanking == false && showScore == false){
    continueSequence();
  }
  // Play game
  else if (gameStarted == true){
    playGame();
  }
}

//------ Start cycling through pre-game slides
void startSequence(){
  showScore = false; // maybe this is unecessary?
  sequenceStarted = true;
  startingTime = millis(); // establish a time on which to base the slideshow
  pageNum = 1; // turn the page
  //delay(pageTurn*100); // slight delay from when they click the screen? maybe delete?
  image(pages[pageNum], 0, 0);
}

//------ Continue cycling through pre-game slides
void continueSequence(){
  image(pages[pageNum], 0, 0); // draw current image to screen
  currentTime = millis();
  if (currentTime - startingTime > pageTurn){ // maybe make this the smaller limit?
    pageNum++;
    startingTime = startingTime + pageTurn;
    /* should i use switch?
    if (pageNum == 4){ // cycle through 4-6 in 1/3 time
      image(pages[4], 0, 0);
      pageNum = 7;
    }  
    if (pageNum == 8){ // flip back and forth quickly between 8 & 9
      image(pages[8], 0, 0);
    }
    if (pageNum == 12){ // one second each until 15
      image(pages[12], 0, 0);
    }*/
  }
    if (pageNum == 16){ // if the entry sequence has finished
        displayface = 16; // blue face to start
        file.play(); // start playing stayin alive
        gameStarted = true;
     }
}

//------ Start game mode
// make face change if nothing happens. and make scores negative.
void playGame(){
  showScore = false;
  image(pages[displayface], 0, 0); //change screen according to how they're playing
  if (file.isPlaying() == false){ // if file has stopped playing, stop game go to scoring sequence 
    saveScore();
    gameStarted = false;
    pageNum = 0;
   }
  nowtime = millis(); 
  beatSwitchState = arduino.digitalRead(beatSwitch); // change to pi for final sketch
  pressureSwitchState = arduino.digitalRead(pressureSwitch); // change to pi for final sketch
  //------ detect when top limit switch is pressed
  if (beatSwitchState == 1 && lastBeatSwitchState == 0){ // when the switch goes from off to on, not on to off
    //------ -1 for incorrect pressure
    if (pressureSwitchState == 0){ //if the bottom switch is not pressed
      // trigger "Push harder!," blue face & pillow  
      score--;
      displayface = 22;
    }
    //------ -1 when too slow
    if (nowtime - pressedtime >= bpmupperlimit){
      // trigger "Too slow!," blue face & pillow 
      score--;
      displayface = 20;
    }
    //------ -1 when too fast
    if (nowtime - pressedtime <= bpmlowerlimit){
      // trigger "Too fast!," blue face & pillow 
      displayface = 21;
      score--;
    }
    //------ +1 for correct speed range, +2 for correct pressure
    if (nowtime - pressedtime >= bpmlowerlimit && nowtime - pressedtime <= bpmupperlimit){
      // probably no feedback since this means it is the right beat but too fast, too slow, or wrong pressure
      score++;
      if (pressureSwitchState == 1 && lastPressureSwitchState == 0){
        // trigger "Keep going!," green face & pillow 
        displayface = 17;
        score = score+2;
      }
    }
    pressedtime = millis(); 
    println(score);
  }
  lastBeatSwitchState = beatSwitchState;
  lastPressureSwitchState = pressureSwitchState;
}


//------ Once the game is finished, save score
void saveScore(){
  // when a player finishes the game (when the sound file stops), add their score to the main score file.
  // save the player's number (playerNum) and read which row it is in after reordering.
  TableRow newRow = table.addRow();
  playerNum = table.getRowCount();
  newRow.setInt("playerNum", playerNum);
  newRow.setString("id", "AAA"); // should be changeable so that they can enter their ranking if it's a high score
  newRow.setInt("score", score);
  table.sortReverse(int(2)); // sorts the table by scores. if two players have the same score, sort them with the highest playerNum first!
  saveTable(table, "data/scores.csv"); // not sure if this should be before the re-sorting.
  ranking = (table.findRowIndex(str(playerNum), 0)) + 1; // get index of thier row
  if (ranking <=10){
    enterName();
  }  
  showRanking = true;
  scoreStartingTime = millis();
  checkShowScore();
}

void checkShowScore(){
  scoreCurrentTime = millis();
  if (scoreCurrentTime - scoreStartingTime < scorePageTurn && showRanking == true){
    showRanking();
  }
  if (scoreCurrentTime - scoreStartingTime >= scorePageTurn && showRanking == true){
    showRanking = false;
    showScore = true;
    scoreStartingTime = scoreStartingTime + scorePageTurn;
  }
  if (scoreCurrentTime - scoreStartingTime < scorePageTurn && showScore == true){
    showTopScores();
  }
  if (scoreCurrentTime - scoreStartingTime >= scorePageTurn && showScore == true){
   showScore = false; 
   score = 0; // reset score
   sequenceStarted = false;
  }
}


//------ Allow top 10 players to enter their names
void enterName() {
  // append ID with entered name
}

//------ Show the top 10 scores by ID and score
void showRanking() {
  fill(255);
  text("You are", width/2, (height/2)-fontSize);
  text("# " + ranking, width/2, (height/2));
  text("in our ranking", width/2, (height/2)+fontSize);
}

  
void showTopScores() {  
  fill(255);
  int rows;
  if (table.getRowCount() < 10){ // if the table has under ten scores, make "row" the number of scores
    rows = table.getRowCount();
  }
  else{ // make it 10 for top scores
    rows = 10;
  }
  int y = height/3;
  for (int i = 0; i < rows; i++) {
    String id = table.getString(i, 1);
    int score = table.getInt(i, 2);
    y = y+fontSize;
    text(id + " " + score, width/2, y);
  }
}

//------ Create new CSV file or erase current one
void eraseScores() {
  table = new Table();
  table.addColumn("playerNum");
  table.addColumn("id");
  table.addColumn("score", Table.INT);
  saveTable(table, "data/scores.csv");
}
