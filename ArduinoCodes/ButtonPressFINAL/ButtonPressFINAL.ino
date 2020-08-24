//initialize variables outside of void setup

int DELAY = 10; //delay is 10ms between hitting the button to make insensitive to glitches/jitter
int buttonPin = 2;
int toEEG = 3;
int buttonCounter = 1;
int buttonWasPressed = false; //buttonwas not pressed earlier

void setup() {
  // put your setup code here, to run once:
  pinMode(buttonPin, INPUT); //button input is in Pin 2
  pinMode(toEEG, OUTPUT); //digital output to collection software
  digitalWrite(buttonPin, HIGH); //turns on the pullup resistor, pin reads HIGH when button is released
  Serial.begin(9600); //intializes the GUI
}

boolean handlePressed()
{
  boolean event;
  int buttonNowPressed = !digitalRead(buttonPin); //Button pressed ==> Pin 2 will have low voltage

  event = buttonNowPressed && !buttonWasPressed; //allows system respond only to change in button state events
  buttonWasPressed = buttonNowPressed; //renames old button state to current state
  return event; //
}

void loop() {
  // put your main code here, to run repeatedly:
  boolean risingEdge = handlePressed();


  // if it is, the buttonState is HIGH:
  if (risingEdge == 1) { //if there is a change in the button pressed state
    // turn LED on:
    digitalWrite(toEEG, HIGH); //voltage to LED or EEG output (pin 3)
    delay(100); //voltage pulse for 30msec
    digitalWrite(toEEG, LOW); //output on pin 3 goes back to low
    Serial.print("The button has been presssed "); Serial.print(buttonCounter); Serial.println(" times");
    buttonCounter = buttonCounter + 1;
  }
}

/*goal: code that shows order of Light pulses, audio beeps and*/


