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
int fontSize = 40; // change this to change font size in the whole project
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
color keycolor = color(88, 229, 57);
int keyboardheight, keyboardwidth, rowheight, margin;
boolean qOver = false;
boolean wOver = false;
boolean eOver = false;
boolean rOver = false;
boolean tOver = false;
boolean yOver = false;
boolean uOver = false;
boolean iOver = false;
boolean oOver = false;
boolean pOver = false;
boolean DELOver = false;
boolean aOver = false;
boolean sOver = false;
boolean dOver = false;
boolean fOver = false;
boolean gOver = false;
boolean hOver = false;
boolean jOver = false;
boolean kOver = false;
boolean lOver = false;
boolean ENTEROver = false;
boolean zOver = false;
boolean xOver = false;
boolean cOver = false;
boolean vOver = false;
boolean bOver = false;
boolean nOver = false;
boolean mOver = false;
int row1Y, row2Y, row3Y;
int row1Wide, DELWide, row2Wide, ENTERWide, row3Wide;
int qX, wX, eX, rX, tX, yX, uX, iX, oX, pX, DELX;
int aX, sX, dX, fX, gX, hX, jX, kX, lX, ENTERX;
int zX, xX, cX, vX, bX, nX, mX;



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
  size(1024, 600); // delete if full screen
  //fullScreen(); // uncomment this for the full screen game on touch pad
  //noCursor(); // uncomment this to hide the cursor for the full screen game
  background(255);
  
  // font things for writing score to screen
  myFont = createFont("Effra", fontSize);
  textFont(myFont);
  textSize(fontSize);
  textAlign(CENTER, CENTER);
  defineKeyboard();
  noStroke();
  
  // uncomment on Pi
  // runs led controls
  //exec("/home/pi/Desktop/run_leds.sh");
  // turns blue leds on
  //exec("/home/pi/Desktop/run_blue.sh");
  
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
  /*if (pageNum == 26 && elapsedTime > pageTurn){ // maybe make this the smaller limit?
    exec("/home/pi/Desktop/run_green.sh");
    pageNum++;
    startingTime = startingTime + pageTurn;
    }
  if (pageNum == 27 && elapsedTime > 1000){
    exec("/home/pi/Desktop/run_red.sh");
    pageNum++;
    startingTime = startingTime + 1000;
  }
  if (pageNum == 28 && elapsedTime > 1000){
    exec("/home/pi/Desktop/run_blue.sh");
    pageNum++;
    startingTime = startingTime + 1000;
  }
  if (pageNum == 29 && elapsedTime > 1000 || pageNum == 30 && elapsedTime > 1000){
    pageNum++;
    startingTime = startingTime + 1000;
  }*/
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
  //---CHECK WHETHER STOPPED---
  if (nowtime - gameStartTime >= 30000 && file.isPlaying() == false){ // if 30 seconds have passed and file has stopped playing, stop game & go to scoring sequence 
    saveScore();
    gameStarted = false;
    pageNum = 0;
    if (score >= winningScore){
      exec("/home/pi/Desktop/run_green.sh");
      image(pages[40], 0, 0);
      winner = true; // make this display for a score show
      scoreStartingTime = millis();
    }
    if (score < winningScore){
      exec("/home/pi/Desktop/run_red.sh");
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
    //------ +1 for correct speed range, +2 for correct pressure
    if (nowtime - pressedtime >= bpmlowerlimit && nowtime - pressedtime <= bpmupperlimit){
      // probably no feedback since this means it is the right beat but too fast, too slow, or wrong pressure
      if (face == false){
        displayface = 35;
      }
      else{
         displayface = 36;
         exec("/home/pi/Desktop/run_green.sh");
      }
      score = score++;
      if (pressureSwitchState == 1 && lastPressureSwitchState == 0){
        // trigger "Keep going!," green face & pillow 
        exec("/home/pi/Desktop/run_green.sh");
        if (face == false){
          displayface = 37;
          
        }
        else{
          displayface = 36;
        }
        score = score+4;
      }
    }
    else{
      exec("/home/pi/Desktop/run_blue.sh");
    }
    // general check because usually when time is wrong, pressure is also wrong
    if (nowtime - pressedtime >= bpmupperlimit && pressureSwitchState == 0){
      // trigger "Too slow!," blue face & pillow 
      score--;
      if (face == false){
        displayface = 33;
      }
      else{
        displayface = 35;
      }
    }
    //------ -1 when too fast
    if (nowtime - pressedtime <= bpmlowerlimit && pressureSwitchState == 0){
      // trigger "Too fast!," blue face & pillow 
      if (face == false){
        displayface = 34;
      }
      else{
        displayface = 35;
      }
      score--;
    }
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
    pressedtime = millis(); 
  }
  lastBeatSwitchState = beatSwitchState;
  lastPressureSwitchState = pressureSwitchState;
  if (nowtime - checkStartTime >= 4000 && score == lastScore){ // if nothing has happened, deduct points.
    score = score-1;
    displayface = 32;
    println("are you there?");
    checkStartTime = millis();
    lastScore = score;
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
      score = 0;
      lastScore = 0;
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
      exec("/home/pi/Desktop/run_blue.sh");
      startingTime = millis();
      score = 0;
      lastScore = 0;
    }
  }
  if (scoreCurrentTime - scoreStartingTime < scorePageTurn && showScore == true && enterName == false){
    showTopScores();
  }
  if (scoreCurrentTime - scoreStartingTime >= scorePageTurn && showScore == true && enterName == false){
   showScore = false; 
   score = 0; // reset score
   lastScore = 0;
   sequenceStarted = false;
   exec("/home/pi/Desktop/run_blue.sh");
  }
  if (enterName == true && showRanking == false && showScore == false){
    keyboardopen = true;
    enterName();
  }
  if (keyboardopen == true){
    update(mouseX, mouseY);
    drawKeyboard();
  }
  /*if (keyboardopen == true && dontopenkeyboard == false){
    exec("/home/pi/Desktop/keyboard.sh"); // open the keyboard with full file path on Pi
    keyboardopen = false;
    dontopenkeyboard = true;
  }*/
}

//---SHOW RANKING--- Show the player's ranking in the system
void showRanking() {
  image(pages[42], 0, 0); 
  fill(textcolor);
  text("#" + ranking, width/2, (height/2));
}

//---ENTER NAME--- Allow top 10 players to enter their names
void enterName() {
  // look at keyPressed function for this.
  image(pages[44], 0, 0); 
  // append ID with entered name
  if (name.length() > 0){
  text(name, 0, 0, width, 2*(height/3));
  }
}

//---SHOW TOP SCORES--- Show the top 10 scores by ID and score
void showTopScores() {  
  image(pages[43], 0, 0);  
  fill(textcolor);
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
/*
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
         keyboardopen = false;
         //exec("ps -ax | grep Chrome"); //to close
         //exec("pidof matchbox-keyboard"); = pid
         //exec("kill" pid);
      }
    }
  }
}
*/

void defineKeyboard(){
  margin = 10;
  keyboardheight = height/2;
  keyboardwidth = width - (margin*2);
  rowheight = (keyboardheight-margin*5)/3;
  row1Y = keyboardheight+margin;
  row2Y = row1Y + rowheight + margin;
  row3Y = row2Y + rowheight + margin;
  // EMJ
  row1Wide = ((keyboardwidth-(margin*2)) / 12) - margin;
  DELWide = (row1Wide*2) + (margin*2);
  row2Wide = ((keyboardwidth-(margin*2)) / 11) - margin;
  ENTERWide = (row1Wide*2) + (margin*2);
  row3Wide = keyboardwidth / 8;
  qX = margin*2;
  wX = row1Wide + qX + margin;
  eX = row1Wide + wX + margin;
  rX = row1Wide + eX + margin;
  tX = row1Wide + rX + margin;
  yX = row1Wide + tX + margin;
  uX = row1Wide + yX + margin;
  iX = row1Wide + uX + margin;
  oX = row1Wide + iX + margin;
  pX = row1Wide + oX + margin;
  DELX = row1Wide + pX + margin;
  aX = margin*3;
  sX = row2Wide + aX + margin;
  dX = row2Wide + sX + margin;
  fX = row2Wide + dX + margin;
  gX = row2Wide + fX + margin;
  hX = row2Wide + gX + margin;
  jX = row2Wide + hX + margin;
  kX = row2Wide + jX + margin;
  lX = row2Wide + kX + margin;
  ENTERX = row2Wide + lX + margin;
  zX = margin*6;
  xX = row3Wide + zX + margin;
  cX = row3Wide + xX + margin;
  vX = row3Wide + cX + margin;
  bX = row3Wide + vX + margin;
  nX = row3Wide + bX + margin;
  mX = row3Wide + nX + margin;
}



void drawKeyboard(){
  fill(255);
  rect(margin, keyboardheight, keyboardwidth, keyboardheight-margin, 10);
  //--- Q
  fill(keycolor);
  rect(qX, row1Y, row1Wide, rowheight, 10);
  fill(textcolor);
  text("Q", qX+(row1Wide/2), row1Y+(rowheight/2));
  //--- W
  fill(keycolor);
  rect(wX, row1Y, row1Wide, rowheight, 10);
  fill(textcolor);
  text("W", wX+(row1Wide/2), row1Y+(rowheight/2));
  //--- E
  fill(keycolor);
  rect(eX, row1Y, row1Wide, rowheight, 10);
  fill(textcolor);
  text("E", eX+(row1Wide/2), row1Y+(rowheight/2));
  //--- R
  fill(keycolor);
  rect(rX, row1Y, row1Wide, rowheight, 10);
  fill(textcolor);
  text("R", rX+(row1Wide/2), row1Y+(rowheight/2));
  //--- T
  fill(keycolor);
  rect(tX, row1Y, row1Wide, rowheight, 10);
  fill(textcolor);
  text("T", tX+(row1Wide/2), row1Y+(rowheight/2));
  //--- Y
  fill(keycolor);
  rect(yX, row1Y, row1Wide, rowheight, 10);
  fill(textcolor);
  text("Y", yX+(row1Wide/2), row1Y+(rowheight/2));
  //--- U
  fill(keycolor);
  rect(uX, row1Y, row1Wide, rowheight, 10);
  fill(textcolor);
  text("U", uX+(row1Wide/2), row1Y+(rowheight/2));
  //--- I
  fill(keycolor);
  rect(iX, row1Y, row1Wide, rowheight, 10);
  fill(textcolor);
  text("I", iX+(row1Wide/2), row1Y+(rowheight/2));
  //--- O
  fill(keycolor);
  rect(oX, row1Y, row1Wide, rowheight, 10);
  fill(textcolor);
  text("O", oX+(row1Wide/2), row1Y+(rowheight/2));
  //--- P
  fill(keycolor);
  rect(pX, row1Y, row1Wide, rowheight, 10);
  fill(textcolor);
  text("P", pX+(row1Wide/2), row1Y+(rowheight/2));
  //--- DEL
  fill(keycolor);
  rect(DELX, row1Y, DELWide, rowheight, 10);
  fill(textcolor);
  text("DEL", DELX+(DELWide/2), row1Y+(rowheight/2));
  //--- A
  fill(keycolor);
  rect(aX, row2Y, row2Wide, rowheight, 10);
  fill(textcolor);
  text("A", aX+(row2Wide/2), row2Y+(rowheight/2));
  //--- S
  fill(keycolor);
  rect(sX, row2Y, row2Wide, rowheight, 10);
  fill(textcolor);
  text("S", sX+(row2Wide/2), row2Y+(rowheight/2));
  //--- D
  fill(keycolor);
  rect(dX, row2Y, row2Wide, rowheight, 10);
  fill(textcolor);
  text("D", dX+(row2Wide/2), row2Y+(rowheight/2));
  //--- F
  fill(keycolor);
  rect(fX, row2Y, row2Wide, rowheight, 10);
  fill(textcolor);
  text("F", fX+(row2Wide/2), row2Y+(rowheight/2));
  //--- G
  fill(keycolor);
  rect(gX, row2Y, row2Wide, rowheight, 10);
  fill(textcolor);
  text("G", gX+(row2Wide/2), row2Y+(rowheight/2));
  //--- H
  fill(keycolor);
  rect(hX, row2Y, row2Wide, rowheight, 10);
  fill(textcolor);
  text("H", hX+(row2Wide/2), row2Y+(rowheight/2));
  //--- J
  fill(keycolor);
  rect(jX, row2Y, row2Wide, rowheight, 10);
  fill(textcolor);
  text("J", jX+(row2Wide/2), row2Y+(rowheight/2));
  //--- K
  fill(keycolor);
  rect(kX, row2Y, row2Wide, rowheight, 10);
  fill(textcolor);
  text("K", kX+(row2Wide/2), row2Y+(rowheight/2));
  //--- L
  fill(keycolor);
  rect(lX, row2Y, row2Wide, rowheight, 10);
  fill(textcolor);
  text("L", lX+(row2Wide/2), row2Y+(rowheight/2));
  //--- ENTER
  fill(keycolor);
  rect(ENTERX, row2Y, ENTERWide, rowheight, 10);
  fill(textcolor);
  text("ENTER", ENTERX+(ENTERWide/2), row2Y+(rowheight/2));
  //--- Z
  fill(keycolor);
  rect(zX, row3Y, row3Wide, rowheight, 10);
  fill(textcolor);
  text("Z", zX+(row3Wide/2), row3Y+(rowheight/2));
  //--- X
  fill(keycolor);
  rect(xX, row3Y, row3Wide, rowheight, 10);
  fill(textcolor);
  text("X", xX+(row3Wide/2), row3Y+(rowheight/2));
  //--- C
  fill(keycolor);
  rect(cX, row3Y, row3Wide, rowheight, 10);
  fill(textcolor);
  text("C", cX+(row3Wide/2), row3Y+(rowheight/2));
  //--- V
  fill(keycolor);
  rect(vX, row3Y, row3Wide, rowheight, 10);
  fill(textcolor);
  text("V", vX+(row3Wide/2), row3Y+(rowheight/2));
  //--- B
  fill(keycolor);
  rect(bX, row3Y, row3Wide, rowheight, 10);
  fill(textcolor);
  text("B", bX+(row3Wide/2), row3Y+(rowheight/2));
  //--- N
  fill(keycolor);
  rect(nX, row3Y, row3Wide, rowheight, 10);
  fill(textcolor);
  text("N", nX+(row3Wide/2), row3Y+(rowheight/2));
  //--- M
  fill(keycolor);
  rect(mX, row3Y, row3Wide, rowheight, 10);
  fill(textcolor);
  text("M", mX+(row3Wide/2), row3Y+(rowheight/2)); 
}

void update(int x, int y){
  if (overQ(qX, row1Y, row1Wide, rowheight)){
    qOver = true;
  }
  else{
    qOver = false;
  }
  if (overW(wX, row1Y, row1Wide, rowheight)){
    wOver = true;
  }
  else{
    wOver = false;
  }
  if (overE(eX, row1Y, row1Wide, rowheight)){
    eOver = true;
  }
  else{
    eOver = false;
  }
  if (overR(rX, row1Y, row1Wide, rowheight)){
    rOver = true;
  }
  else{
    rOver = false;
  }  
  if (overT(tX, row1Y, row1Wide, rowheight)){
    tOver = true;
  }
  else{
    tOver = false;
  }
  if (overY(yX, row1Y, row1Wide, rowheight)){
    yOver = true;
  }
  else{
    yOver = false;
  }
  if (overU(uX, row1Y, row1Wide, rowheight)){
    uOver = true;
  }
  else{
    uOver = false;
  }
  if (overI(iX, row1Y, row1Wide, rowheight)){
    iOver = true;
  }
  else{
    iOver = false;
  }
  if (overO(oX, row1Y, row1Wide, rowheight)){
    oOver = true;
  }
  else{
    oOver = false;
  }
  if (overP(pX, row1Y, row1Wide, rowheight)){
    pOver = true;
  }
  else{
    pOver = false;
  }
  if (overDEL(DELX, row1Y, row1Wide, rowheight)){
    DELOver = true;
  }
  else{
    DELOver = false;
  }
  if (overA(aX, row2Y, row2Wide, rowheight)){
    aOver = true;
  }
  else{
    aOver = false;
  }
  if (overS(sX, row2Y, row2Wide, rowheight)){
    sOver = true;
  }
  else{
    sOver = false;
  }
  if (overD(dX, row2Y, row2Wide, rowheight)){
    dOver = true;
  }
  else{
    dOver = false;
  }
  if (overF(fX, row2Y, row2Wide, rowheight)){
    fOver = true;
  }
  else{
    fOver = false;
  }
  if (overG(gX, row2Y, row2Wide, rowheight)){
    gOver = true;
  }
  else{
    gOver = false;
  }
  if (overH(hX, row2Y, row2Wide, rowheight)){
    hOver = true;
  }
  else{
    hOver = false;
  }
  if (overJ(jX, row2Y, row2Wide, rowheight)){
    jOver = true;
  }
  else{
    jOver = false;
  }
  if (overK(kX, row2Y, row2Wide, rowheight)){
    kOver = true;
  }
  else{
    kOver = false;
  }
  if (overL(lX, row2Y, row2Wide, rowheight)){
    lOver = true;
  }
  else{
    lOver = false;
  }
  if (overENTER(ENTERX, row2Y, row2Wide, rowheight)){
    ENTEROver = true;
  }
  else{
    ENTEROver = false;
  }
  if (overZ(zX, row3Y, row3Wide, rowheight)){
    zOver = true;
  }
  else{
    zOver = false;
  }
  if (overX(xX, row3Y, row3Wide, rowheight)){
    xOver = true;
  }
  else{
    xOver = false;
  }
  if (overC(cX, row3Y, row3Wide, rowheight)){
    cOver = true;
  }
  else{
    cOver = false;
  }
  if (overV(vX, row3Y, row3Wide, rowheight)){
    vOver = true;
  }
  else{
    vOver = false;
  }
  if (overB(bX, row3Y, row3Wide, rowheight)){
    bOver = true;
  }
  else{
    bOver = false;
  }
  if (overN(nX, row3Y, row3Wide, rowheight)){
    nOver = true;
  }
  else{
    nOver = false;
  }
  if (overM(mX, row3Y, row3Wide, rowheight)){
    mOver = true;
  }
  else{
    mOver = false;
  }
}

void mousePressed(){
  if(enterName == true){
  if (qOver) {
    if (name.length() < 3){ 
    name = name +"Q";
    }
  }
  if (wOver) {
    if (name.length() < 3){ 
    name = name +"W";
    }
  }
  if (eOver) {
    if (name.length() < 3){ 
    name = name +"E";
    }
  }
  if (rOver) {
    if (name.length() < 3){ 
    name = name +"R";
    }
  }
  if (tOver) {
    if (name.length() < 3){ 
    name = name +"T";
    }
  }
  if (yOver) {
    if (name.length() < 3){ 
    name = name +"Y";
    }
  }
  if (uOver) {
    if (name.length() < 3){ 
    name = name +"U";
    }
  }
  if (iOver) {
    if (name.length() < 3){ 
    name = name +"I";
    }
  }
  if (oOver) {
    if (name.length() < 3){ 
    name = name +"O";
    }
  }
  if (pOver) {
    if (name.length() < 3){ 
    name = name +"P";
    }
  }
  if (DELOver) {
    if (name.length() > 0){
    name = name.substring(0, name.length()-1);
    }
  }
  if (aOver) {
    if (name.length() < 3){ 
    name = name +"A";
    }
  }
  if (sOver) {
    if (name.length() < 3){ 
    name = name +"S";
    }
  }
  if (dOver) {
    if (name.length() < 3){ 
    name = name +"D";
    }
  }
  if (fOver) {
    if (name.length() < 3){ 
    name = name +"F";
    }
  }
  if (gOver) {
    if (name.length() < 3){ 
    name = name +"G";
    }
  }
  if (hOver) {
    if (name.length() < 3){ 
    name = name +"H";
    };
  }
  if (jOver) {
    if (name.length() < 3){ 
    name = name +"J";
    }
  }
  if (kOver) {
    if (name.length() < 3){ 
    name = name +"K";
    }
  }
  if (lOver) {
    if (name.length() < 3){ 
    name = name +"L";
    }
  }
  if (ENTEROver) {
    if (name.length() == 3){ 
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
         keyboardopen = false;
    }
  }
  if (zOver) {
    if (name.length() < 3){ 
    name = name +"Z";
    }
  }
  if (xOver) {
    if (name.length() < 3){ 
    name = name +"X";
    }
  }
  if (cOver) {
    if (name.length() < 3){ 
    name = name +"C";
    }
  }
  if (vOver) {
    if (name.length() < 3){ 
    name = name +"V";
    }
  }
  if (bOver) {
    if (name.length() < 3){ 
    name = name +"B";
    }
  }
  if (nOver) {
    if (name.length() < 3){ 
    name = name +"N";
    }
  }
  if (mOver) {
    if (name.length() < 3){ 
    name = name +"M";
    }
  }
  }
}

boolean overQ(int x, int y, int width, int height)  {
  if (mouseX >= x && mouseX <= x+width && 
      mouseY >= y && mouseY <= y+height) {
    return true;
  } else {
    return false;
  }
}
boolean overW(int x, int y, int width, int height)  {
  if (mouseX >= x && mouseX <= x+width && 
      mouseY >= y && mouseY <= y+height) {
    return true;
  } else {
    return false;
  }
}
boolean overE(int x, int y, int width, int height)  {
  if (mouseX >= x && mouseX <= x+width && 
      mouseY >= y && mouseY <= y+height) {
    return true;
  } else {
    return false;
  }
}
boolean overR(int x, int y, int width, int height)  {
  if (mouseX >= x && mouseX <= x+width && 
      mouseY >= y && mouseY <= y+height) {
    return true;
  } else {
    return false;
  }
}
boolean overT(int x, int y, int width, int height)  {
  if (mouseX >= x && mouseX <= x+width && 
      mouseY >= y && mouseY <= y+height) {
    return true;
  } else {
    return false;
  }
}
boolean overY(int x, int y, int width, int height)  {
  if (mouseX >= x && mouseX <= x+width && 
      mouseY >= y && mouseY <= y+height) {
    return true;
  } else {
    return false;
  }
}
boolean overU(int x, int y, int width, int height)  {
  if (mouseX >= x && mouseX <= x+width && 
      mouseY >= y && mouseY <= y+height) {
    return true;
  } else {
    return false;
  }
}
boolean overI(int x, int y, int width, int height)  {
  if (mouseX >= x && mouseX <= x+width && 
      mouseY >= y && mouseY <= y+height) {
    return true;
  } else {
    return false;
  }
}
boolean overO(int x, int y, int width, int height)  {
  if (mouseX >= x && mouseX <= x+width && 
      mouseY >= y && mouseY <= y+height) {
    return true;
  } else {
    return false;
  }
}
boolean overP(int x, int y, int width, int height)  {
  if (mouseX >= x && mouseX <= x+width && 
      mouseY >= y && mouseY <= y+height) {
    return true;
  } else {
    return false;
  }
}
boolean overDEL(int x, int y, int width, int height)  {
  if (mouseX >= x && mouseX <= x+width && 
      mouseY >= y && mouseY <= y+height) {
    return true;
  } else {
    return false;
  }
}
boolean overA(int x, int y, int width, int height)  {
  if (mouseX >= x && mouseX <= x+width && 
      mouseY >= y && mouseY <= y+height) {
    return true;
  } else {
    return false;
  }
}
boolean overS(int x, int y, int width, int height)  {
  if (mouseX >= x && mouseX <= x+width && 
      mouseY >= y && mouseY <= y+height) {
    return true;
  } else {
    return false;
  }
}
boolean overD(int x, int y, int width, int height)  {
  if (mouseX >= x && mouseX <= x+width && 
      mouseY >= y && mouseY <= y+height) {
    return true;
  } else {
    return false;
  }
}
boolean overF(int x, int y, int width, int height)  {
  if (mouseX >= x && mouseX <= x+width && 
      mouseY >= y && mouseY <= y+height) {
    return true;
  } else {
    return false;
  }
}
boolean overG(int x, int y, int width, int height)  {
  if (mouseX >= x && mouseX <= x+width && 
      mouseY >= y && mouseY <= y+height) {
    return true;
  } else {
    return false;
  }
}
boolean overH(int x, int y, int width, int height)  {
  if (mouseX >= x && mouseX <= x+width && 
      mouseY >= y && mouseY <= y+height) {
    return true;
  } else {
    return false;
  }
}
boolean overJ(int x, int y, int width, int height)  {
  if (mouseX >= x && mouseX <= x+width && 
      mouseY >= y && mouseY <= y+height) {
    return true;
  } else {
    return false;
  }
}
boolean overK(int x, int y, int width, int height)  {
  if (mouseX >= x && mouseX <= x+width && 
      mouseY >= y && mouseY <= y+height) {
    return true;
  } else {
    return false;
  }
}
boolean overL(int x, int y, int width, int height)  {
  if (mouseX >= x && mouseX <= x+width && 
      mouseY >= y && mouseY <= y+height) {
    return true;
  } else {
    return false;
  }
}
boolean overENTER(int x, int y, int width, int height)  {
  if (mouseX >= x && mouseX <= x+width && 
      mouseY >= y && mouseY <= y+height) {
    return true;
  } else {
    return false;
  }
}
boolean overZ(int x, int y, int width, int height)  {
  if (mouseX >= x && mouseX <= x+width && 
      mouseY >= y && mouseY <= y+height) {
    return true;
  } else {
    return false;
  }
}
boolean overX(int x, int y, int width, int height)  {
  if (mouseX >= x && mouseX <= x+width && 
      mouseY >= y && mouseY <= y+height) {
    return true;
  } else {
    return false;
  }
}
boolean overC(int x, int y, int width, int height)  {
  if (mouseX >= x && mouseX <= x+width && 
      mouseY >= y && mouseY <= y+height) {
    return true;
  } else {
    return false;
  }
}
boolean overV(int x, int y, int width, int height)  {
  if (mouseX >= x && mouseX <= x+width && 
      mouseY >= y && mouseY <= y+height) {
    return true;
  } else {
    return false;
  }
}
boolean overB(int x, int y, int width, int height)  {
  if (mouseX >= x && mouseX <= x+width && 
      mouseY >= y && mouseY <= y+height) {
    return true;
  } else {
    return false;
  }
}
boolean overN(int x, int y, int width, int height)  {
  if (mouseX >= x && mouseX <= x+width && 
      mouseY >= y && mouseY <= y+height) {
    return true;
  } else {
    return false;
  }
}
boolean overM(int x, int y, int width, int height)  {
  if (mouseX >= x && mouseX <= x+width && 
      mouseY >= y && mouseY <= y+height) {
    return true;
  } else {
    return false;
  }
}
