/* Resistance used:
  red - red - orange: 843. player key: 100
  brown - black - yellow: 512. player key: 101
  
  max error: 7%
  
  pulldown resistor:
  brown - black - yellow
  
  A0: analogRead one knee
  A1: analogRead the other
  
  200: green
  201: red
  202: blue
*/
#define playerAmount 2
#define error 0.07

int voltages[] = {843, 512};
int led1Pins[] = {3,5,6};
int led2Pins[] = {9,10,11};
int buttonPins[] = {4,7,8}; //green, red, blue
int buttonPressed[] = {LOW, LOW, LOW};
int red[] = {255,0,0};
int green[] = {0,255,0};
int blue[] = {0,0,255};
float minVoltages[playerAmount], maxVoltages[playerAmount];
boolean lastWritten = false;
boolean blinking = false;
unsigned long lastWrite = millis();
unsigned long intervalWrite = 200;
unsigned long blinkSpeed = 250;

void setup(){
  Serial.begin(115200);
  pinMode(13, OUTPUT);
  for(int i = 0; i < playerAmount; i++) {
    minVoltages[i] = (1.0 - error) * voltages[i];
    maxVoltages[i] = (1.0 + error) * voltages[i];
  }
  for(int i = 0; i < 3; i++) {
    pinMode(led1Pins[i], OUTPUT);
    pinMode(led2Pins[i], OUTPUT);
    pinMode(buttonPins[i], INPUT);
  }
}

void loop(){
  playerTouched(analogRead(A0));
  playerTouched(analogRead(A1));
  if(Serial.available() > 0) {
    int val = Serial.read();
    switch(val){
      case 90:
        //feedback on just joined or no score either
        setLeds(64);
        break;
      case 100:
        //here goes feedback on point scored
        break;
      case 101:
        //here goes feedback on lost a point
        setLeds(0);
        break;
      case 200:
        //turn the leds green
        setLeds(green);
        break;
      case 201:
        //turn the leds red
        setLeds(red);
        break;
      case 202:
        //turn the leds blue
        setLeds(blue);
        break;
    }
    blinking = val == 100;
  }
  for(int i = 0; i < 3; i++) {
    int val = digitalRead(buttonPins[i]);
    if(val && !buttonPressed[i]) {
      Serial.write(200+i);
    }
    buttonPressed[i] = val;
  }
  if (blinking) {
    setLeds((millis() / blinkSpeed) % 2 == 0 ? 127 : 0);
  }
}

void playerTouched(int val) {
  //Serial.write(val/4);
  boolean found = false;
  for(int i = 0; i < playerAmount; i++) {
    if(val > minVoltages[i] && val < maxVoltages[i]) {
      found = true;
      unsigned long time = millis();
      if(lastWrite + intervalWrite < time) {
        lastWrite = time;
        Serial.write(i+100);
      }
    }
  }
}

void setLeds(int val) {
  for(int i = 0; i < 3; i++) {
    analogWrite(led1Pins[i], val);
    analogWrite(led2Pins[i], val);
  }
}

void setLeds(int vals[]) {
  for(int i = 0; i < 3; i++) {
    analogWrite(led1Pins[i], vals[i]);
    analogWrite(led2Pins[i], vals[i]);
  }
}
