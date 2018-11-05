/*
Jack the Maker for CUF (Jose de Mello Saude) @ Web Summit
CPR Game Machine
November 2018

Version without touch screen (and therefore without enter name sequence or keyboard)
*/

import processing.sound.*;
import processing.io.*;
SoundFile file;

//---ADJUSTMENTS (for difficulty, time spent on slides)
int beatmargin = 300; // change this between about 25 - 200 to make it more or less difficult
int winningScore = 0; // higher than or equal to this = person survives
int pageTurn = 4500; // time spent on each slide (in milliseconds)
int scorePageTurn = 5000; // time spent on each score slide (in milliseconds)
//---ETC
Table table;
PFont myFont; // variable to load font
PImage[] pages = new PImage[45]; // make 44 PImages variables to hold the jpg files for the pages. change for number of pages.
String name = ""; // player name
color textcolor = color(67, 102, 73);
boolean sequenceStarted = false;
boolean gameStarted = false;
boolean showRanking = false;
boolean winner = false;
boolean loser = false;
boolean loser2 = false;
boolean playingagain = false;
boolean notplayingagain = false;
boolean green = false;
boolean blue = true;
boolean ledsareon = false;
int bpm = 576; // song BPM. Heart Association recommendeds BPM between 500-600
int fontSize = 45;
int pageNum = 0;
int startingTime, currentTime, pressedtime, nowtime, scoreStartingTime, scoreCurrentTime, gameStartTime, checkStartTime;
int beatSwitchState, lastBeatSwitchState, pressureSwitchState, lastPressureSwitchState, bpmlowerlimit, bpmupperlimit, ranking, playerNum, displayface;
int score = 0;
int lastScore = 0;
int beatSwitch = 4; // pin for beat switch (top one)
int pressureSwitch = 17; // pin for pressure switch (lower one)
int elapsedTime;

void setup(){ 
  //---TURN ON LEDS--- attempt 1/2
  exec("/home/pi/Desktop/run_leds.sh"); // kills then runs library for led controls
  exec("/home/pi/Desktop/run_blue.sh"); // turns blue leds on
  
  //---LOAD SCORES---
  table = loadTable("data/scores.csv", "header"); //loads the master score file on start up
  //eraseScores(); // use this to create a clean scores file
  table.setColumnType("score", Table.INT); // sets the scores as integers so they are parsed correctly when ordering the table.
  
  //---SET PINS & THINGS---
  GPIO.pinMode(beatSwitch, GPIO.INPUT_PULLUP);
  GPIO.pinMode(pressureSwitch, GPIO.INPUT_PULLUP);
  bpmlowerlimit = bpm-beatmargin;
  bpmupperlimit = bpm+beatmargin;
  Sound s = new Sound(this);
  s.outputDevice(1);
  file = new SoundFile(this, "Staying_Alive.wav");
  frameRate(10);
  //size(1024, 600); // comment if full screen
  fullScreen();
  noCursor();
  background(255);
  myFont = createFont("Effra", fontSize);
  textFont(myFont);
  textSize(fontSize);
  textAlign(CENTER, CENTER);
  noStroke();
  
  //---LOAD PAGES---
  for (int i = 0; i < pages.length; i++){
    pages[i] = loadImage(i+".png");
    pages[i].resize(width, height); // sizes the images to the screen width and height.
  }
  image(pages[0], 0, 0); // display the first screen on startup
  
  //---TURN ON LEDS--- attempt 2/2 (sometimes the first one doesn't work)
  exec("/home/pi/Desktop/run_leds.sh"); // kills then runs library for led controls
  exec("/home/pi/Desktop/run_blue.sh"); // turns blue leds on
  
  //---START TIME---
  startingTime = millis();
}

    
void draw (){
  background(0);
  pressureSwitchState = GPIO.digitalRead(pressureSwitch);
  checkShowScore();
  currentTime = millis();
  elapsedTime = currentTime - startingTime; 
  
  // If someone touches the screen to start
  if (pressureSwitchState == 1 && lastPressureSwitchState == 0 && sequenceStarted == false && loser == false && loser2 == false){ // start sequence
    startSequence();
  }     
  
  // Waiting screen
  else if (sequenceStarted == false){ 
    image(pages[pageNum], 0, 0);
    startScreen();
  } 
  
  // Cycling through display sequence after someone has pressed to start
  else if (sequenceStarted == true && gameStarted == false && showRanking == false && winner == false && loser == false && loser2 == false ){
    continueSequence();
  }
  
  // Play game
  else if (gameStarted == true){
    playGame();
  }
  lastPressureSwitchState = pressureSwitchState;
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
  if (pageNum == 18 && elapsedTime > (pageTurn + (pageTurn/2))){
    pageNum++;
    startingTime = startingTime + (pageTurn + (pageTurn/2)));
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
  else if (elapsedTime > pageTurn){
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

//---PLAY GAME--- start game mode
void playGame(){
  image(pages[displayface], 0, 0); // change screen according to how they're playing
  checkStopped(); // check if the game is over and if so, go to win/lose screens.
  nowtime = millis();
  beatSwitchState = GPIO.digitalRead(beatSwitch);
  //check if nothing's happened
  if (nowtime - checkStartTime >= 2500 && score == lastScore || nowtime - pressedtime >= 2000 && score != lastScore){
    score--;
    displayface = 32;
    lastScore = score;
    if (green == true){
      exec("/home/pi/Desktop/run_blue.sh");
      green = false;
    }
  }
  //---KEEP GOING / TOO FAST / TOO SLOW--- if the bottom switch has been pressed
  if (pressureSwitchState == 1 && lastPressureSwitchState == 0){
    score = score+5;
    checkScore();
    pressedtime = millis();
  }
  //---PUSH HARDER--- if top limit switch is released
  else if (beatSwitchState == 0 && lastBeatSwitchState == 1){
     score--;
     displayface = 35;
     if (green == true){
       exec("/home/pi/Desktop/run_blue.sh");
       green = false;
     }
     pressedtime = millis();
  }
  lastBeatSwitchState = beatSwitchState;
  lastPressureSwitchState = pressureSwitchState;
}


//---CHECK WHETHER GAME HAS STOPPED---
void checkStopped(){
  if (nowtime - gameStartTime >= 30000 && file.isPlaying() == false){ // if 30 seconds have passed and file has stopped playing, stop game & go to scoring sequence 
    saveScore();
    gameStarted = false;
    pageNum = 0;
    if (score >= winningScore){
      image(pages[40], 0, 0);
      winner = true;
      scoreStartingTime = millis();
      if (green == false){
        exec("/home/pi/Desktop/run_green.sh");
      }
    }
    if (score < winningScore){
      image(pages[39], 0, 0);
      loser = true;
      loser2 = false;
      scoreStartingTime = millis();
      exec("/home/pi/Desktop/run_red.sh");
    }
  }
}

//---CHECK SPEED IF PRESSURE SWITCH IS DEPRESSED--- 
void checkScore(){
  if (nowtime - pressedtime >= bpmlowerlimit && nowtime - pressedtime <= bpmupperlimit){
    displayface = 37;
    score = score+10;
    if (green == false){
      exec("/home/pi/Desktop/run_green.sh");
      green = true;
    }
  }
  else if (nowtime - pressedtime <= bpmlowerlimit){
    displayface = 34;
    score--;
    if (green == true){
      exec("/home/pi/Desktop/run_blue.sh");
      green = false;
    }
  }
  else if (nowtime - pressedtime >= bpmupperlimit){
    displayface = 33;
    score--;
    if (green == true){
      exec("/home/pi/Desktop/run_blue.sh");
      green = false;
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
  newRow.setString("id", name);
  newRow.setInt("score", score);
  table.sortReverse(int(2));
  saveTable(table, "data/scores.csv");
  ranking = (table.findRowIndex(str(playerNum), 0)) + 1; // get index of their row
}

//---CHECK SHOW SCORES--- Check whether scores should be shown on screen
void checkShowScore(){
  scoreCurrentTime = millis();
  // ---LOSER SEQUENCE---
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
    if (pressureSwitchState == 1 && lastPressureSwitchState == 0){
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
    lastPressureSwitchState = pressureSwitchState;
  }
  if (scoreCurrentTime - scoreStartingTime < 500 && playingagain == true){
    image(pages[31], 0, 0);
  }
  if (scoreCurrentTime - scoreStartingTime >= 500 && playingagain == true){
    loser2 = false;
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
