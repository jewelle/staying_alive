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
boolean green = false;
boolean blue = true;
boolean red = false;



PFont myFont; // variable to load font
int fontSize = 45; // change this to change font size in the whole project
PImage[] pages = new PImage[45]; // make 44 PImages variables to hold the jpg files for the pages. change for number of pages.
int pageNum = 0;
int pageTurn = 500; // time spent on each slide (in milliseconds)
int winningScore = 10; // higher than this = person survives
int scorePageTurn = 2000; // time spent on each slide (in milliseconds)
int startingTime, currentTime, pressedtime, nowtime, scoreStartingTime, scoreCurrentTime, gameStartTime, checkStartTime;
int beatSwitchState, lastBeatSwitchState, pressureSwitchState, lastPressureSwitchState, bpmlowerlimit, bpmupperlimit, score, lastScore, ranking, playerNum, displayface;
int bpm = 576; // song bpm. Heart Association recommended BPM between 500-600
int beatmargin = 200; // change this between about 25 - 100 to make it more or less difficult
int beatSwitch = 4; // pin for beat switch (top one)
int pressureSwitch = 17; // pin for pressure switch (lower one)
int elapsedTime;
String name = ""; // maybe this should be "AAA"? to signify there is something there to fill? Also change in other function if so.
color textcolor = color(67, 102, 73);//59, 81, 63);//49, 102, 18);


void setup(){ 
  //table = loadTable("data/scores.csv", "header"); //loads the master score file on start up
  eraseScores(); // use this to create a clean file (hopefully just for testing)
  table.setColumnType("score", Table.INT); // sets the scores as integers so they are parsed correctly when ordering the table.
  GPIO.pinMode(beatSwitch, GPIO.INPUT_PULLUP);
  GPIO.pinMode(pressureSwitch, GPIO.INPUT_PULLUP);
  bpmlowerlimit = bpm-beatmargin;
  bpmupperlimit = bpm+beatmargin;
  score = 0;
  lastScore = 0;

  Sound s = new Sound(this); // uncomment these for use with pi
  s.outputDevice(1); // uncomment these for use with pi
  file = new SoundFile(this, "Staying_Alive.wav");
  
  frameRate(10); // can be changed
  //size(1024, 600); // delete if full screen
  fullScreen(); // uncomment this for the full screen game on touch pad
  noCursor(); // uncomment this to hide the cursor for the full screen game
  background(255);
  
  // font things for writing score to screen
  myFont = createFont("Effra", fontSize);
  textFont(myFont);
  textSize(fontSize);
  textAlign(CENTER, CENTER);
  noStroke();
  
  // runs led controls
  exec("/home/pi/Desktop/run_leds.sh");
  // turns blue leds on
  exec("/home/pi/Desktop/run_blue.sh");
  
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
  beatSwitchState = GPIO.digitalRead(beatSwitch);
  checkShowScore();
  currentTime = millis();
  elapsedTime = currentTime - startingTime; 
  // If someone touches the screen to start
  if (beatSwitchState == 0 && lastBeatSwitchState == 1 & sequenceStarted == false && enterName == false && loser2 == false && loser == false){ // start sequence
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
  lastBeatSwitchState = beatSwitchState;
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
    name = "";
    gameStartTime = millis();
    checkStartTime = millis();
  }
}

//---PLAY GAME--- Start game mode
// make face change if nothing happens. and make scores negative.
void playGame(){
  image(pages[displayface], 0, 0); //change screen according to how they're playing
  checkStopped(); // check if the game is over and if so, go to win/lose screens.
  nowtime = millis();
  pressureSwitchState = GPIO.digitalRead(pressureSwitch);
  //check if nothing's happened
  if (nowtime - checkStartTime >= 2500 && score == lastScore || nowtime - pressedtime >= 2000 && score != lastScore){ // if nothing has happened, deduct points.
    score--;
    displayface = 32;
    //checkStartTime = millis();
    lastScore = score;
    if (green == true){
      exec("/home/pi/Desktop/run_blue.sh");
    }
  }
  // if the bottom switch has been pressed
  if (pressureSwitchState == 1 && lastPressureSwitchState == 0){
    score = score+5;
    checkScore();
    pressedtime = millis();
  }
  //------ detect when top limit switch is released
  else if (beatSwitchState == 0 && lastBeatSwitchState == 1){ // when the switch goes from on to off
     // just show push harder
     score--;
     displayface = 35;
     pressedtime = millis();
     // still need to make sure that these alternate between blue faces
  }
  lastBeatSwitchState = beatSwitchState;
  lastPressureSwitchState = pressureSwitchState;
}


//---CHECK WHETHER STOPPED---
void checkStopped(){
  if (nowtime - gameStartTime >= 30000 && file.isPlaying() == false){ // if 30 seconds have passed and file has stopped playing, stop game & go to scoring sequence 
    saveScore();
    gameStarted = false;
    pageNum = 0;
    if (score >= winningScore){
      image(pages[40], 0, 0);
      winner = true; // make this display for a score show
      scoreStartingTime = millis();
      exec("/home/pi/Desktop/run_green.sh");
    }
    if (score < winningScore){
      image(pages[39], 0, 0);
      loser = true; // need to change it to 41 and make it clickable
      loser2 = false;
      scoreStartingTime = millis();
      exec("/home/pi/Desktop/run_red.sh");
    }
  }
}

// still need to make sure that these alternate between blue faces
void checkScore(){
  if (nowtime - pressedtime >= bpmlowerlimit && nowtime - pressedtime <= bpmupperlimit){
    println("correct timing");
    displayface = 37;
    score = score+10;
    if (green == false){
      exec("/home/pi/Desktop/run_green.sh");
      green = true;
    }
    // check which to run, run only once.
  }
  else if (nowtime - pressedtime <= bpmlowerlimit){
    println("too fast");
    displayface = 34;
      // trigger "Too fast!," blue face & pillow 
    score--;
    if (green == true){
      exec("/home/pi/Desktop/run_blue.sh");
    }
  }
  else if (nowtime - pressedtime >= bpmupperlimit){
    println("too slow");
    displayface = 33;
    // trigger "Too slow!," blue face & pillow 
    score--;
    if (green == true){
      exec("/home/pi/Desktop/run_blue.sh");
    }
   }
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
    if (beatSwitchState == 0 && lastBeatSwitchState == 1){
      file.play(); // start playing stayin alive
      playingagain = true;
      score = 0;
      lastScore = 0;
      image(pages[31], 0, 0);
      displayface = 31;
    }
    else{
      notplayingagain = true;
    }
    lastBeatSwitchState = beatSwitchState;
  }
  if (scoreCurrentTime - scoreStartingTime < 500 && playingagain == true){ // wait 100 milliseconds
    image(pages[31], 0, 0);
  }
  if (scoreCurrentTime - scoreStartingTime >= 500 && playingagain == true){
    loser2 = false;
    // blue face to start
    gameStarted = true;
    name = "";
    playingagain = false;
    gameStartTime = millis();
    checkStartTime = millis();
  }
  if (scoreCurrentTime - scoreStartingTime >= scorePageTurn && loser2 == true && notplayingagain == true){
   loser2 = false;
   score = 0; // reset score
   lastScore = 0;
   sequenceStarted = false;
   exec("/home/pi/Desktop/run_blue.sh");
   startingTime = millis();
  }
// ---WINNER SEQUENCE---
  if (scoreCurrentTime - scoreStartingTime < scorePageTurn && winner == true){
    image(pages[40], 0, 0); 
  }
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
    sequenceStarted = false;
    exec("/home/pi/Desktop/run_blue.sh");
    startingTime = millis();
    score = 0;
    lastScore = 0;
  }
}

//---SHOW RANKING--- Show the player's ranking in the system
void showRanking() {
  image(pages[42], 0, 0); 
  fill(textcolor);
  text("#" + ranking, width/2, (height/2));
}

//---ERASE SCORES--- Create new CSV file or erase current one
void eraseScores() {
  table = new Table();
  table.addColumn("playerNum");
  table.addColumn("id");
  table.addColumn("score", Table.INT);
  saveTable(table, "data/scores.csv");
}
