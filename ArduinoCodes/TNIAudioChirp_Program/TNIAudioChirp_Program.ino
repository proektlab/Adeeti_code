#include <toneAC.h>
//NOTE WIRES MUST GO INTO PINS 9 AND 10. 9 BEING INPUT AND 10 BEING OUTPUT
//NOTE USER MUST DOWNLOAD toneAC.h, AND ADDED TO LIBRARY BY SKETCH -> INCLUDE LIBRARY
//This program will produce a chirp with tones increasing from 3K to 15K in freq. 20 K is max freq that our stereo can handle
//The chirps will either start from low to high freq or high to low. This will be random
//Audio Program
int Initialize = 0;
String defaultMode;
char junk = ' ';
int LEDTotal;
int LED_Counter = 1;
//const int buzzer = 9; //not needed, can only use PWM 9 input and PWM 10 output
int StoEEG = 5;
float SoundOn;
float LowBoundSoundDelay;
float HighBoundSoundDelay;
int Intensity;
int randChirp;
long randOffSound = 0;
long randPitchSound = 0;


void setup()                      // run once, when the sketch starts
{
 randomSeed (analogRead (5));    // randomize using analog pin 5 - MUST BE UNCONNECTED AND UNUSED
// pinMode(buzzer, OUTPUT); //set buzzer - pin 9 as an output  NOT NEEDED
 Serial.begin(9600);
 Serial.println("Welcome, Let's begin");
 Serial.println("");
 Serial.flush();
}

void loop()                       // run over and over again
{
     if (Initialize == 0)
     {
       Serial.println(F("Press 'y' for default settings and 'n' to input your own settings"));
       while (Serial.available() == 0 );
       {
       defaultMode = Serial.readString();
       Serial.println(defaultMode);

       if (defaultMode == "y")
       {
        LowBoundSoundDelay = 4000;   //shortest delay= 2 seconds
        HighBoundSoundDelay = 5000; //longest delay = 3 secodns 
        SoundOn = 50; //Sound on for 20ms 
        LEDTotal = 100;  //total trials = 50 
        Intensity = 10; //Sound volume set at level 10 which is high
        Serial.println(F("Default setting chosen"));
        Serial.println("Lower frequency is 3KHz");
        Serial.println("Higher frequency is 15KHz");
        Serial.print(F("Lower bound of delay between trials is set at ")); Serial.print(LowBoundSoundDelay); Serial.println(F(" msecs"));
        Serial.print(F("Upper bound of delay between trials is set at ")); Serial.print(HighBoundSoundDelay); Serial.println(F(" msecs"));
        Serial.print(F("Sound duration is set at ")); Serial.print(SoundOn); Serial.println(F(" msecs"));
        Serial.print(F("Volume set at level ")); Serial.println(Intensity);
        Serial.print(F("Total number of trials of each type of stimulus : ")); Serial.println(LEDTotal);
       
        Serial.println("Enter 'a' to start");

        while (Serial.available() == 0);
        {
          Serial.println("Running...");
          Initialize = 1;
        }
       }

       else
       {
         Serial.println(F("User inputs selected"));
         Serial.println("Lower frequency is 3KHz");
         Serial.println("Higher frequency is 15KHz");
         Serial.println("Enter lower bound of sound delay duration for sound (msec)");
         
         while (Serial.available() == 0 );
         {
         LowBoundSoundDelay = Serial.parseFloat();
         Serial.print("Lower sound delay bound is set at "); Serial.println(LowBoundSoundDelay, DEC);
         while (Serial.available() > 0)
         {junk = Serial.read();}
         }
         
         Serial.println("Enter upper bound of delay duration for sound (msec)");
         while (Serial.available() == 0);
           {
           HighBoundSoundDelay = Serial.parseFloat();
           Serial.print("Upper sound delay bound is set at "); Serial.println(HighBoundSoundDelay, DEC);
           while (Serial.available() > 0)
           {junk = Serial.read();}
           }

         Serial.println("Enter duration of audio chirp (msec)");
         while (Serial.available() == 0);
           {
           SoundOn = Serial.parseFloat();
           Serial.print("Sound duration is set at "); Serial.println(SoundOn, DEC);
           while (Serial.available() > 0)
           {junk = Serial.read();}
           }
  
  
         Serial.println("Please set the volume for sound (Range: 0 to 10) (Integer)");
         while (Serial.available() == 0);
           {
            Intensity = Serial.parseInt();
            Serial.print("Volume set at level "); Serial.println(Intensity);
           while (Serial.available() > 0)
           {junk = Serial.read();}
           }
  
  
         Serial.println("How chirps do you want (Integer)");
         while (Serial.available() == 0);
           {
            LEDTotal = Serial.parseInt();
            Serial.print("Audio will turn on a total of "); Serial.print(LEDTotal); Serial.println(" times");
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
       while (Serial.available() > 0)
       {junk = Serial.read();}  //clears anything in serial
   }

       ////
     
     if (Initialize == 1)
     {
      randOffSound = random (LowBoundSoundDelay, HighBoundSoundDelay);
      int SoundPart = SoundOn/25; //There are 25 parts
      digitalWrite(StoEEG, HIGH);
       {
         toneAC(3000, Intensity, SoundPart);
         toneAC(3500, Intensity, SoundPart);
         toneAC(4000, Intensity, SoundPart);
         toneAC(4500, Intensity, SoundPart);
         toneAC(5000, Intensity, SoundPart);
         toneAC(5500, Intensity, SoundPart);
         toneAC(6000, Intensity, SoundPart);
         toneAC(6500, Intensity, SoundPart);
         toneAC(7000, Intensity, SoundPart);
         toneAC(7500, Intensity, SoundPart);
         toneAC(8000, Intensity, SoundPart);
         toneAC(8500, Intensity, SoundPart);
         toneAC(9000, Intensity, SoundPart);
         toneAC(9500, Intensity, SoundPart);
         toneAC(10000, Intensity, SoundPart);
         toneAC(10500, Intensity, SoundPart);
         toneAC(11000, Intensity, SoundPart);
         toneAC(11500, Intensity, SoundPart);
         toneAC(12000, Intensity, SoundPart);
         toneAC(12500, Intensity, SoundPart);
         toneAC(13000, Intensity, SoundPart);
         toneAC(13500, Intensity, SoundPart);
         toneAC(14000, Intensity, SoundPart);
         toneAC(14500, Intensity, SoundPart);
         toneAC(15000, Intensity, SoundPart); //Stereo can only play a max freq of 20000, need better stereo. Mice hearing range is 1000 to 70K
       }
       digitalWrite(StoEEG, LOW);
             
       Serial.print("Pulse Number "); Serial.print(LED_Counter); Serial.print(" ||Duration and delay "); Serial.print(SoundOn); Serial.print(","); Serial.println(randOffSound);       
       delay(randOffSound);
    
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


//frequency - Play the specified frequency indefinitely, turn off with toneAC().
//volume - [optional] Set a volume level. (default: 10, range: 0 to 10 [0 = off])
//length - [optional] Set the length to play in milliseconds. (default: 0 [forever], range: 0 to 2^32-1)
//background - [optional] Play note in background or pause till finished? (default: false, values: true/false)
//toneAC() - Stop output.
//noToneAC() - Same as toneAC().

