//LED Lighting Program

int LEDPin = 13;                  // LED connected to digital pin 13         
int ReceiverPin = 5;                   // LED Receiving for Voltage Recording
long randOff = 0;                 // Initialize a variable for the OFF time
float lowBound;   //float can have decimals 
float highBound;
float lightOn;
int Initialize = 0;
char junk = ' ';
int LEDTotal;
int LED_Counter = 1;

int photocellPin = 0;   //photocell initializing
int photocellReading;
float voltageON;
float voltageOFF;




void setup()                      // run once, when the sketch starts
{
 randomSeed (analogRead (0));    // randomize
 pinMode(LEDPin, OUTPUT);        // sets the digital pin as output
 pinMode(ReceiverPin, OUTPUT);
 Serial.begin(9600);
 Serial.println("Welcome, Let's begin");
 Serial.println("");
 Serial.flush();
}

void loop()                       // run over and over again
{
  
     if (Initialize == 0)
     {
       Serial.println("Enter lower bound of delay duration for light (msec)");
       
       while (Serial.available() == 0 );
       {
       lowBound = Serial.parseFloat();
       Serial.print("Lower bound is set at "); Serial.println(lowBound, DEC);
       
       while (Serial.available() > 0)
       {junk = Serial.read();}
       }
       
       Serial.println("Enter upper bound of delay duration for light (msec)");
       
       while (Serial.available() == 0);
       {
       highBound = Serial.parseFloat();
       Serial.print("Upper bound is set at "); Serial.println(highBound, DEC);
       
       while (Serial.available() > 0)
       {junk = Serial.read();}
       }
       
       Serial.println("Enter duration of light pulse (msec)");
       
       while (Serial.available() == 0);
       {
       lightOn = Serial.parseFloat();
       Serial.print("Light duration is set at "); Serial.println(lightOn, DEC);
       
       while (Serial.available() > 0)
       {junk = Serial.read();}
       }
    
       Serial.println("How many times do you want the LED to turn on (Integer)");
    
       while (Serial.available() == 0);
       {
        LEDTotal = Serial.parseInt();
        Serial.print("LED will turn on a total of "); Serial.print(LEDTotal); Serial.println(" times");
    
       while (Serial.available() > 0)
       {junk = Serial.read();}
       }

       Serial.println("Enter 'a' to start");
    
       while (Serial.available() == 0);
       {
        Serial.println("Running...");
        Initialize = Initialize + 1;
       }
    
     }
     
     if (Initialize == 1)
     {
             randOff = random (lowBound, highBound);    // generate OFF time between 2 and 5 seconds
             
             digitalWrite(LEDPin, HIGH);   // sets the LED on
             digitalWrite(ReceiverPin, HIGH);
             photocellReading = analogRead(photocellPin);  //recording photocell raw number
             voltageON = photocellReading * (5.0 / 1023.0);  //converting raw number to voltage
             delay(lightOn);                    // waits for 30ms
             digitalWrite(LEDPin, LOW);    // sets the LED off
             digitalWrite( ReceiverPin, LOW);
             photocellReading = analogRead(photocellPin);
             voltageOFF = photocellReading * (5.0 / 1023.0); 
             Serial.print("The LED has flashed "); Serial.print(LED_Counter); Serial.print(" times"); Serial.print("|| VoltageON = "); Serial.print(voltageON, DEC); Serial.print("|| VoltageOFF = "); Serial.print(voltageOFF, DEC); Serial.print(" ||Duration of pitch and delay "); Serial.print(lightOn); Serial.print(","); Serial.println(randOff);
             delay(randOff);               // waits for a random time while OFF

    
             LED_Counter = LED_Counter + 1;
    
             if (LED_Counter == LEDTotal + 1)  //need to add 1 to LEDTotal because LED_Counter is initialized at 1
             {
              delay(50);
              Serial.println("Program has ended");
              delay(50);
              exit(0);
             }
      }

  
}
