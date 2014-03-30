/* Resistance used:
  red - red - orange: 843
  brown - black - yellow: 512
  
  max error: 7%
  
  pulldown resistor:
  brown - black - yellow
*/

void setup(){
  Serial.begin(115200);
  pinMode(13, OUTPUT);
}

void loop(){
  if(Serial.available() > 0){
    int val = Serial.read();
    for(int i = 0; i < val; i++) {
      digitalWrite(13, HIGH);
      delay(500);
      digitalWrite(13, LOW);
      delay(500);
    }
    Serial.write(val+1);
  }
}
