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
float minVoltages[playerAmount], maxVoltages[playerAmount];
boolean lastWritten = false;
unsigned long lastWrite = millis();
unsigned long intervalWrite = 200;

void setup(){
  Serial.begin(115200);
  pinMode(13, OUTPUT);
  for(int i = 0; i < playerAmount; i++) {
    minVoltages[i] = (1.0 - error) * voltages[i];
    maxVoltages[i] = (1.0 + error) * voltages[i];
  }
}

void loop(){
  playerTouched(analogRead(A0));
  playerTouched(analogRead(A1));
  if(Serial.available() > 0) {
    int val = Serial.read();
    switch(val){
      case 100:
        //here goes feedback on point scored
        break;
      case 101:
        //here goes feedback on lost a point
        break;
      case 200:
        //turn the leds green
        break;
      case 201:
        //turn the leds red
        break;
      case 202:
        //turn the leds blue
        break;
    }
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
