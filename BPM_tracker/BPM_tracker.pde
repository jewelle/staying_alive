/*
Determine length between each time the top switch was pressed.
Send a message if the bottom switch is not also pressed.

How many milliseconds should pass between each beat?
100 - 120 bpm = 
There are 60,000 millis per min
60,000/100 = 600mpm
60,000/120 = 500mpm

Stayin' Alive = 104bpm
60,000/104 = 576mpm
*/

import cc.arduino.*;
import org.firmata.*;
import processing.serial.*;

Arduino arduino;
int beatSwitchState, lastBeatSwitchState;
int pressureSwitchState, lastPressureSwitchState;
int pressedtime, nowtime;
int bpm = 576; // 
int margin = 25; // change this between about 25 - 100 to make it more or less difficult
int bpmlowerlimit, bpmupperlimit;
// array for scores
int beatSwitch = 12; // pin for beat switch (top one)
int pressureSwitch = 13; // pin for pressure switch (lower one)
int score;


void setup() {
  size(470, 280);
  println(Arduino.list());
  arduino = new Arduino(this, "/dev/cu.usbmodem14101", 57600);
  arduino.pinMode(beatSwitch, Arduino.INPUT_PULLUP);
  arduino.pinMode(pressureSwitch, Arduino.INPUT_PULLUP);
  bpmlowerlimit = bpm-margin;
  bpmupperlimit = bpm+margin;
  score = 0;
}

void draw() {
   nowtime = millis();
   
   beatSwitchState = arduino.digitalRead(beatSwitch);
   pressureSwitchState = arduino.digitalRead(pressureSwitch);
   
   // detect when top limit switch is pressed
   if (beatSwitchState == 1 && lastBeatSwitchState == 0){ // when the switch goes from off to on, not on to off
     if (pressureSwitchState == 0){ //if the bottom switch is not pressed
       //println("push harder!");  
       // add a negative score
       score--;
     }
     if (nowtime - pressedtime >= bpmupperlimit){
       //println("too slow!");
       // this will change screen and led on pillow
       // adds a negative score
       score--;
     }
     if (nowtime - pressedtime <= bpmlowerlimit){
       //println("too fast!");
       // this will change screen and led on pillow
       // adds a negative score
       score--;
     }
     if (nowtime - pressedtime >= bpmlowerlimit && nowtime - pressedtime <= bpmupperlimit){
        //println("right speed");
        score = score+2;
       if (pressureSwitchState == 1 && lastPressureSwitchState == 0){
            //println("right speed & pressure");
            score--;
       }
       // add a number to the score
       // this will change screen and led on pillow
       // check whether bottom is also pressed
     }
     pressedtime = millis();  
     println(score);
   }
   lastBeatSwitchState = beatSwitchState;
   lastPressureSwitchState = pressureSwitchState;
}
   
//for score:
//count how many times they've gotten "just right"? 
