// LED lighting with Matlab interface 

int LEDPin = 13;                  // LED connected to digital pin 13         
int LtoEEG = 5;                   // BNC input to aquition system is on postion 5
int command;

void setup() {
  Serial.begin(9600);
  pinMode(LEDPin, OUTPUT);
  pinMode(LtoEEG, OUTPUT);
  // BNC input to aquition system is on postion 5
  // put your setup code here, to run once:
  digitalWrite(LEDPin, HIGH);
 delay(1000)  ;
 digitalWrite(LEDPin, LOW);
}

void loop() {
  if((Serial.available() > 0) ){
  command = Serial.read();
  if(command==1){
    digitalWrite(LEDPin, HIGH);
    digitalWrite(LtoEEG, HIGH);
    delay(1000)  ;
    digitalWrite(LEDPin, LOW);
    digitalWrite(LtoEEG, LOW);
  }
  // put your main code here, to run repeatedly:
  }
}
