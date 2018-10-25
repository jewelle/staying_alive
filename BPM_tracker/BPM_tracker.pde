/*
X Determine length between each time the top switch was pressed.
Send a message if the bottom switch is not pressed after ___ seconds.

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
int margin = 40; // change this between about 25 - 100 to make it more or less difficult
int bpmlowerlimit, bpmupperlimit;
// array for scores
int beatSwitch = 12; // pin for beat switch (top one)
int pressureSwitch = 13; // pin for pressure switch (lower one)

void setup() {
  size(470, 280);
  println(Arduino.list());
  arduino = new Arduino(this, "/dev/cu.usbmodem14101", 57600);
  arduino.pinMode(beatSwitch, Arduino.INPUT_PULLUP);
  arduino.pinMode(pressureSwitch, Arduino.INPUT_PULLUP);
  bpmlowerlimit = bpm-margin;
  bpmupperlimit = bpm+margin;
}

void draw() {
   // detect when the switch goes from off to on, not on to off
   nowtime = millis();
   beatSwitchState = arduino.digitalRead(beatSwitch);
   pressureSwitchState = arduino.digitalRead(pressureSwitch);
   if (beatSwitchState == 1 && lastBeatSwitchState == 0){
     if (nowtime - pressedtime >= bpmupperlimit){
       println("too slow!");
       // this will change screen and led on pillow
     }
     if(nowtime - pressedtime <= bpmlowerlimit){
       println("too fast!");
       // this will change screen and led on pillow
     }
     if(nowtime - pressedtime >= bpmlowerlimit && nowtime - pressedtime <= bpmupperlimit){
       println("just right");
       // add a number to the score
       // this will change screen and led on pillow
     }
     pressedtime = millis();  
   }
   lastBeatSwitchState = beatSwitchState;
}
   
//for score:
//count how many times they've gotten "just right"? 
