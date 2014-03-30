int sMin = 1023, sMax = 0;

void setup() {
  Serial.begin(9600);
}

void loop() {
  int sensor = analogRead(A0);
  sMin = min(sMin, sensor);
  sMax = max(sMax, sensor);
  Serial.print(sMin);Serial.print("  ");Serial.println(sMax);
}
