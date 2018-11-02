/*
Jack the Maker for CUF (Jose de Mello Saude) @ Web Summit
CPR Game Machine
October 2018
*/

// WAV or AIF are recommended file formats for the SoundFile library when using Raspberry Pi.

import processing.sound.*;
import processing.io.*;
SoundFile file;

Table table;
boolean sequenceStarted = false; // detect whether the sequence & game have started
boolean gameStarted = false;
boolean showRanking = false;
boolean showScore = false;
boolean enterName = false;
boolean winner = false;
boolean loser = false;
boolean loser2 = false;
boolean playingagain = false;
boolean notplayingagain = false;
boolean keyboardopen = false;
boolean dontopenkeyboard = false;
boolean face = false;

PFont myFont; // variable to load font
int fontSize = 60; // change this to change font size in the whole project
PImage[] pages = new PImage[45]; // make 44 PImages variables to hold the jpg files for the pages. change for number of pages.
int pageNum = 0;
int pageTurn = 5000; // time spent on each slide (in milliseconds)
int winningScore = 30; // higher than this = person survives
int scorePageTurn = 5000; // time spent on each slide (in milliseconds)
int startingTime, currentTime, pressedtime, nowtime, scoreStartingTime, scoreCurrentTime, gameStartTime;
int beatSwitchState, lastBeatSwitchState, pressureSwitchState, lastPressureSwitchState, bpmlowerlimit, bpmupperlimit, score, ranking, playerNum, displayface;
int bpm = 576; // song bpm. Heart Association recommended BPM between 500-600
int margin = 100; // change this between about 25 - 100 to make it more or less difficult
int beatSwitch = 4; // pin for beat switch (top one)
int pressureSwitch = 17; // pin for pressure switch (lower one)
int elapsedTime;
String name = "AAA"; // maybe this should be "AAA"? to signify there is something there to fill? Also change in other function if so.

void setup(){ 
  //table = loadTable("data/scores.csv", "header"); //loads the master score file on start up
  eraseScores(); // use this to create a clean file (hopefully just for testing)
  table.setColumnType("score", Table.INT); // sets the scores as integers so they are parsed correctly when ordering the table.
  GPIO.pinMode(beatSwitch, GPIO.INPUT_PULLUP);
  GPIO.pinMode(pressureSwitch, GPIO.INPUT_PULLUP);
  bpmlowerlimit = bpm-margin;
  bpmupperlimit = bpm+margin;
  score = 0;

  Sound s = new Sound(this); // uncomment these for use with pi
  s.outputDevice(1); // uncomment these for use with pi
  file = new SoundFile(this, "Staying_Alive.wav");
  
  frameRate(10); // can be changed
  size(470, 280); // delete if full screen
  //fullScreen(); // uncomment this for the full screen game on touch pad
  //noCursor(); // uncomment this to hide the cursor for the full screen game
  background(255);
  
  // font things for writing score to screen
  myFont = createFont("Effra", fontSize);
  textFont(myFont);
  textSize(fontSize);
  textAlign(CENTER, CENTER);
   
  // load and resize images to screen
  // make sure theyre scaled. can make one of the variables 0 for scaling
  for (int i = 0; i < pages.length; i++){
    pages[i] = loadImage(i+".png");
    pages[i].resize(width, height); // sizes the images to the screen width and height.
  }
  image(pages[0], 0, 0); // display the first screen on startup
  startingTime = millis();
}

void draw (){
  background(0); // to refresh when drawing to the screen every frame
  checkShowScore();
  currentTime = millis();
  elapsedTime = currentTime - startingTime; 
  // If someone touches the screen to start
  if (mousePressed == true & sequenceStarted == false && enterName == false && loser2 == false && loser == false){ // start sequence
    println("pressed1");
    startSequence();
  }     
  // Waiting screen (this will be animated too)
  else if (sequenceStarted == false && showScore == false && enterName == false){ 
    image(pages[pageNum], 0, 0);
    startScreen();
  } 
  // Cycling through display sequence after someone has pressed to start
  else if (sequenceStarted == true && gameStarted == false && showRanking == false && showScore == false && enterName == false && winner == false && loser == false && loser2 == false ){
    continueSequence();
  }
  // Play game
  else if (gameStarted == true){
    playGame();
  }
}

//---START SCREEN--- Play opening screen gif
void startScreen(){
  if (pageNum == 0 && elapsedTime > (pageTurn/3) || pageNum == 1 && elapsedTime > (pageTurn/3)){
    pageNum++;
    startingTime = startingTime + (pageTurn/3);
  }
  else if (pageNum == 2 && elapsedTime > (pageTurn/3)){
    pageNum = 0;
    startingTime = startingTime + (pageTurn/3);  
  }
}

//---START SEQUENCE--- Start cycling through pre-game slides
void startSequence(){
  sequenceStarted = true;
  startingTime = millis(); // establish a time on which to base the slideshow
  pageNum = 3; // turn the page
  image(pages[pageNum], 0, 0);
}

//---CONTINUE SEQUENCE--- Continue cycling through pre-game slides
void continueSequence(){
  image(pages[pageNum], 0, 0); // draw current image to screen
  // check which page number it is to determine flipping sequence & time
  if (pageNum == 4 && elapsedTime > (pageTurn/2) || pageNum == 5 && elapsedTime > (pageTurn/2)){
    pageNum++;
    startingTime = startingTime + (pageTurn/2);
  }
  if (pageNum == 8 && elapsedTime > (pageTurn/3) || pageNum == 9 && elapsedTime > (pageTurn/3)){
    pageNum++;
    startingTime = startingTime + (pageTurn/3);
  }
  if (pageNum == 12 && elapsedTime > (pageTurn/3) || pageNum == 13 && elapsedTime > (pageTurn/3) || pageNum == 14 && elapsedTime > (pageTurn/3) || pageNum == 15 && elapsedTime > (pageTurn/3) || pageNum == 16 && elapsedTime > (pageTurn/3)){
    pageNum++;
    startingTime = startingTime + (pageTurn/3);
  }
  if (pageNum == 19 && elapsedTime > (pageTurn/4) || pageNum == 20 && elapsedTime > (pageTurn/4) || pageNum == 21 && elapsedTime > (pageTurn/4) || pageNum == 22 && elapsedTime > (pageTurn/4)){
    pageNum++;
    startingTime = startingTime + (pageTurn/4);
  }
  if (pageNum == 25 && elapsedTime > (pageTurn/2)){
    pageNum++;
    startingTime = startingTime + (pageTurn/2);
  }
  if (pageNum == 27 && elapsedTime > 1000 || pageNum == 28 && elapsedTime > 1000 || pageNum == 29 && elapsedTime > 1000 || pageNum == 30 && elapsedTime > 1000){
    pageNum++;
    startingTime = startingTime + 1000;
  }
  else if (elapsedTime > pageTurn){ // maybe make this the smaller limit?
    pageNum++;
    startingTime = startingTime + pageTurn;
    }
  if (pageNum == 31){ // if the entry sequence has finished
      displayface = 31; // blue face to start
      file.play(); // start playing stayin alive
      gameStarted = true;
      name = "AAA";
      gameStartTime = millis();
  }
}

//---PLAY GAME--- Start game mode
// make face change if nothing happens. and make scores negative.
void playGame(){
  image(pages[displayface], 0, 0); //change screen according to how they're playing
  //---CHECK WHETHER STOPPED---
  if (nowtime - gameStartTime >= 30000 && file.isPlaying() == false){ // if 30 seconds have passed and file has stopped playing, stop game & go to scoring sequence 
    saveScore();
    gameStarted = false;
    pageNum = 0;
    if (score >= winningScore){
      image(pages[40], 0, 0);
      winner = true; // make this display for a score show
      scoreStartingTime = millis();
    }
    if (score < winningScore){
      println("oops were here again");
      image(pages[39], 0, 0);
      loser = true; // need to change it to 41 and make it clickable
      loser2 = false;
      scoreStartingTime = millis();
    }
   }
  nowtime = millis(); 
  beatSwitchState = GPIO.digitalRead(beatSwitch); // change to pi for final sketch
  pressureSwitchState = GPIO.digitalRead(pressureSwitch); // change to pi for final sketch
  // beatSwitch is on until pressed, so pressed = 0.
  //------ detect when top limit switch is released
  if (beatSwitchState == 0 && lastBeatSwitchState == 1){ // when the switch goes from on to off
    face = !face;
    //------ -1 for incorrect pressure
    if (pressureSwitchState == 0){ //if the bottom switch is not pressed
      // trigger "Push harder!," blue face & pillow  
      score--;
      if (face == false){
        displayface = 35;
      }
      else{
       // displayface = 32;
      }
    }
    //------ -1 when too slow
    if (nowtime - pressedtime >= bpmupperlimit){
      // trigger "Too slow!," blue face & pillow 
      score--;
      if (face == false){
        displayface = 33;
      }
      else{
        displayface = 32;
      }
    }
    //------ -1 when too fast
    if (nowtime - pressedtime <= bpmlowerlimit){
      // trigger "Too fast!," blue face & pillow 
      if (face == false){
        displayface = 34;
      }
      else{
        displayface = 32;
      }
      score--;
    }
    //------ +1 for correct speed range, +2 for correct pressure
    if (nowtime - pressedtime >= bpmlowerlimit && nowtime - pressedtime <= bpmupperlimit){
      // probably no feedback since this means it is the right beat but too fast, too slow, or wrong pressure
      displayface = 36;
      score++;
      if (pressureSwitchState == 1 && lastPressureSwitchState == 0){
        // trigger "Keep going!," green face & pillow 
        if (face == false){
          displayface = 37;
        }
        else{
          displayface = 36;
        }
        score = score+2;
      }
    }
    pressedtime = millis(); 
  }
  lastBeatSwitchState = beatSwitchState;
  lastPressureSwitchState = pressureSwitchState;
  if (nowtime - gameStartTime >= 1000 && score == 0){ // if nothing has happened, deduct points.
    score = score-20;
    displayface = 32;
  }
  println(score);
}


//---SAVE SCORE--- Once the game is finished, save score
void saveScore(){
  // when a player finishes the game (when the sound file stops), add their score to the main score file.
  // save the player's number (playerNum) and read which row it is in after reordering.
  TableRow newRow = table.addRow();
  playerNum = table.getRowCount();
  newRow.setInt("playerNum", playerNum);
  newRow.setString("id", name); // should be changeable so that they can enter their ranking if it's a high score
  newRow.setInt("score", score);
  table.sortReverse(int(2)); // sorts the table by scores. if two players have the same score, sort them with the highest playerNum first!
  saveTable(table, "data/scores.csv"); // not sure if this should be before the re-sorting.
  ranking = (table.findRowIndex(str(playerNum), 0)) + 1; // get index of thier row
}

//---CHECK SHOW SCORES--- Check whether scores should be shown on screen
void checkShowScore(){
  scoreCurrentTime = millis();
// ---LOSER SEQUENCE--- // make it 5 seconds waiting
  if (scoreCurrentTime - scoreStartingTime < scorePageTurn && loser == true && loser2 == false && gameStarted == false){
    image(pages[39], 0, 0); // dead face page
  }
  if (scoreCurrentTime - scoreStartingTime >= scorePageTurn && loser == true && loser2 == false){
    loser = false;
    loser2 = true;
    scoreStartingTime = millis();
  }
  if (scoreCurrentTime - scoreStartingTime < scorePageTurn && loser2 == true && loser == false && playingagain == false){
    image(pages[41], 0, 0);// try again page
    if (mousePressed == true){
      file.play(); // start playing stayin alive
      playingagain = true;
      image(pages[31], 0, 0);
      displayface = 31;
    }
    else{
      notplayingagain = true;
    }
  }
  if (scoreCurrentTime - scoreStartingTime < 500 && playingagain == true){ // wait 100 milliseconds
    image(pages[31], 0, 0);
  }
  if (scoreCurrentTime - scoreStartingTime >= 500 && playingagain == true){
    loser2 = false;
    // blue face to start
    gameStarted = true;
    name = "AAA";
    playingagain = false;
    gameStartTime = millis();
  }
  if (scoreCurrentTime - scoreStartingTime >= scorePageTurn && loser2 == true && notplayingagain == true){
   loser2 = false;
   score = 0; // reset score
   sequenceStarted = false;
   startingTime = millis();
  }
// ---WINNER SEQUENCE---
  if (scoreCurrentTime - scoreStartingTime < scorePageTurn && winner == true){
    image(pages[40], 0, 0); 
  }
  // goes directly from this to enter name part, then speeds thru opening screen. need to show ranking first and fix timing.
  if (scoreCurrentTime - scoreStartingTime >= scorePageTurn && winner == true){
    showRanking = true;
    winner = false;
    scoreStartingTime = millis();
  }
  if (scoreCurrentTime - scoreStartingTime < scorePageTurn && showRanking == true){
    showRanking();
  }
  if (scoreCurrentTime - scoreStartingTime >= scorePageTurn && showRanking == true){
    showRanking = false;
    if (ranking <=10){
      enterName = true;
      dontopenkeyboard = false;
      enterName();
    }
    else{ // go back to opening slide
      sequenceStarted = false;
      startingTime = millis();
      score = 0;
    }
  }
  if (scoreCurrentTime - scoreStartingTime < scorePageTurn && showScore == true && enterName == false){
    showTopScores();
  }
  if (scoreCurrentTime - scoreStartingTime >= scorePageTurn && showScore == true && enterName == false){
   showScore = false; 
   score = 0; // reset score
   sequenceStarted = false;
  }
  if (enterName == true && showRanking == false && showScore == false){
    keyboardopen = true;
    enterName();
  }
  if (keyboardopen == true && dontopenkeyboard == false){
    exec("/home/pi/Desktop/keyboard.sh"); // open the keyboard with full file path on Pi
    keyboardopen = false;
    dontopenkeyboard = true;
  }
}

//---SHOW RANKING--- Show the player's ranking in the system
void showRanking() {
  image(pages[42], 0, 0); 
  fill(49, 102, 18);
  text("#" + ranking, width/2, (height/2));
}

//---ENTER NAME--- Allow top 10 players to enter their names
void enterName() {
  // look at keyPressed function for this.
  image(pages[44], 0, 0); 
  // append ID with entered name
  if (name.length() > 0){
  text(name.toUpperCase(), 0, 0, width, height);
  }
}

//---SHOW TOP SCORES--- Show the top 10 scores by ID and score
void showTopScores() {  
  image(pages[43], 0, 0);  
  fill(49, 102, 18);
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
    text(id.toUpperCase() + " " + score, width/2, y);
  }
  startingTime = millis();
}

//---ERASE SCORES--- Create new CSV file or erase current one
void eraseScores() {
  table = new Table();
  table.addColumn("playerNum");
  table.addColumn("id");
  table.addColumn("score", Table.INT);
  saveTable(table, "data/scores.csv");
}

void keyPressed() {
  if (enterName == true){ 
    if (keyCode == BACKSPACE) {
      if (name.length() > 0) {
        name = name.substring(0, name.length()-1);
      }
    } else if (keyCode == DELETE) {
      name = "";
    } else if (keyCode != SHIFT && keyCode != CONTROL && keyCode != ALT) {
      if (name.length() < 3){ 
      name = name + key;
      }
    }
    if (keyCode == ENTER || keyCode == RETURN){  
      if (name.length() == 3){
         // remove row then add row
         int rowNum = table.findRowIndex(str(playerNum), 0);
         table.removeRow(rowNum);
         TableRow newRow = table.addRow();
         newRow.setInt("playerNum", playerNum);
         newRow.setString("id", name); // should be changeable so that they can enter their ranking if it's a high score
         newRow.setInt("score", score);
         table.sortReverse(int(2)); // sorts the table by scores. if two players have the same score, sort them with the highest playerNum first!
         saveTable(table, "data/scores.csv"); // not sure if this should be before the re-sorting.
         enterName = false;
         showScore = true;
         scoreStartingTime = millis();
         //exec("ps -ax | grep Chrome"); //to close
         //exec("pidof matchbox-keyboard"); = pid
         //exec("kill" pid);
      }
    }
  }
}
