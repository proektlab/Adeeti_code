//LED Lighting Program

int LEDPin = 13;                  // LED connected to digital pin 13         
int LtoEEG = 5;                   // BNC input to aquition system is on postion 5
long randOff = 0;                 // Initialize a variable for the OFF time
float lowBound;   //float can have decimals 
float highBound;
float lightOn;
int Initialize = 0;
char junk = ' ';
int LEDTotal;
int LED_Counter = 1;
String defaultMode;
char trigFlash;

void setup()                      // run once, when the sketch starts
{
 randomSeed (analogRead (0));    // randomize
 pinMode(LEDPin, OUTPUT);        // sets the digital pin as output
 pinMode(LtoEEG, OUTPUT);
 Serial.begin(9600);
 Serial.println("Welcome, Let's begin");
 Serial.println("");
 Serial.flush();
}
void loop()                       // run over and over again
{
     if (Initialize == 0)
     {
       Serial.println(F("Press 'y' for default settings and 'n' to input your own settings, OR 'go' for manual flashes"));
       while (Serial.available() == 0 );
       {
       defaultMode = Serial.readString();
       Serial.println(defaultMode);
       }
       if (defaultMode == "y")
       {
        lowBound = 4000;   //shortest delay= 4 seconds
        highBound = 5000; //longest delay = 4 secodns 
        lightOn = 10; //Sound on for 10ms 
        LEDTotal = 100;  //total trials = 100 
        Serial.println(F("Default setting chosen"));
        Serial.print(F("Lower bound of delay between trials is set at ")); Serial.print(lowBound); Serial.println(F(" msecs"));
        Serial.print(F("Upper bound of delay between trials is set at ")); Serial.print(highBound); Serial.println(F(" msecs"));
        Serial.print(F("Light duration is set at ")); Serial.print(lightOn); Serial.println(F(" msecs"));
        Serial.print(F("Total number of trials of each type of stimulus : ")); Serial.println(LEDTotal);
        Serial.println("Enter 'a' to start");
        while (Serial.available() == 0);
        {
          Serial.println("Running...");
          Initialize = 1;
        }
       }
       
       if (defaultMode == "go")
        {
          lightOn = 10; //Sound on for 10ms        
          LEDTotal = 100;  //total trials = 100 
          Serial.print(F("Light duration is set at ")); Serial.print(lightOn); Serial.println(F(" msecs"));
          Serial.print(F("Total number of trials of each type of stimulus : ")); Serial.println(LEDTotal);
          Serial.println("Enter 'a' to start");
          while (Serial.available() == 0);
          {
            Serial.println("Running...");
            Initialize = 2;
          }
        }
        
     if (defaultMode == "n")
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
        Initialize = 1;
       }
     }
   }
     
     if (Initialize == 1)
     {
       randOff = random (lowBound, highBound);    // generate OFF time between 2 and 5 seconds
       digitalWrite(LEDPin, HIGH);   // sets the LED on
       digitalWrite(LtoEEG, HIGH);
       delay(lightOn);                    // waits for 30ms
       digitalWrite(LEDPin, LOW);    // sets the LED off
       digitalWrite( LtoEEG, LOW);
       Serial.print("The LED has flashed "); Serial.print(LED_Counter); Serial.print(" times"); Serial.print(" || Delay "); Serial.println(randOff);
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
      
      if (Initialize == 2)
       {
         Serial.println(F("Press 'f' to flash light"));
         while (Serial.available() == 0 );
         { trigFlash = Serial.read(); }
         
         if (trigFlash == 'f')
         {
           digitalWrite(LEDPin, HIGH);   // sets the LED on
           digitalWrite(LtoEEG, HIGH);
           delay(lightOn);                    // waits for 30ms
           digitalWrite(LEDPin, LOW);    // sets the LED off
           digitalWrite( LtoEEG, LOW);
           Serial.print("The LED has flashed "); Serial.print(LED_Counter); Serial.println(" times");
           
           LED_Counter = LED_Counter + 1;
           trigFlash == 'a';
           
           if (LED_Counter == LEDTotal + 1)  //need to add 1 to LEDTotal because LED_Counter is initialized at 1
           {
            delay(50);
            Serial.println("Program has ended");
            delay(50);
            exit(0);
           }
         }
        }
    }
