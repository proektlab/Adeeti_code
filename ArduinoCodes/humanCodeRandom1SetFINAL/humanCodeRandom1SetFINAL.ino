//Human_Program
//**NOTE: WIRES FOR AUDIO MUST GO INTO PINS 9 AND 10. INPUT IS PIN 9, OUTPUT IS PIN 10.
//NOTE USER MUST DOWNLOAD toneAC.h, AND ADDED TO LIBRARY BY SKETCH -> INCLUDE LIBRARY
//No photocell light sensor in this set up 
//5 sets of trails: each trial shows up 20 times per set in a random order 
/*Trials
     *A: light only
     *B: tones only 
     *C: AVA
     *D: AVAV
     *E: AAV
 * Board Set up
   * Pin 1: 
   * Pin 2: light copy to EEG 
   * Pin 3: soung copy to EEG
   * Pin 4: Trial A
   * Pin 5: Trial B
   * Pin 6: Trial C
   * Pin 7: Trial D
   * Pin 8: Trial E
   * Pin 9: input for sound
   * Pin 10: output for sound 
   * Pin 11:
   * Pin 12: 
   * Pin 13: to LED 
 *Button will be linked though seperate arduino
 */
#include <toneAC.h>
#define NUMTRIALS 5 //#define is a preprocessor- replaces NUMTRIALS with 5 //preprocessors never have semicolons
#define REPEATS 20 //20 repeats for each trials 

String defaultMode;

int LEDPin = 13;                  // LED connected to digital pin 13    
int LtoEEG = 2;  //light copy to EEG
int StoEEG = 3;  //sound copy to EEG
int AtoEEG = 4;  //trial A to EEG
int BtoEEG = 5;  //trial B to EEG
int CtoEEG = 6;  //trial C to EEG
int DtoEEG = 7;  //trial D to EEG
int EtoEEG = 8;   //trial E to EEG   

long randOff;                 // Initialize a variable for the OFF time

float lightOn;  //time that LED is on

int Initialize = 0;  //Initialize choses setting of setup, default parameters, or user input parameters

char junk = ' ';  //disregards spaces in user answer choices

int TrialTotal;  //total number of times the LED would flash
int A_Counter;  //start trial A counter at 1
int B_Counter;  //start trial B counter at 1
int C_Counter;  //start trail C counter at 1
int D_Counter;  //start trial D counter at 1
int E_Counter;  //start trial E counter at 1

//const int buzzer = 9;
int LowSound;  //lower bound for pitch of sound 
int HighSound;  //higher bound for pitch of sound
float SoundOn;  //how long tone is played for
long randPitchSound = 0;  //initializes delays for pitch of sound 
int Intensity = 5; //Sound volume set at level 5 which is medium

int fixDelay = 200; 
float lowBound;   // lower bound for delay between trials 
float highBound;  //higher bound for delay between trials
int StoLdelay;
int LtoSdelay;
int StoSdelay;

int arrayLength = NUMTRIALS*REPEATS;  //defines the length of the array

char stimSet[NUMTRIALS*REPEATS]; //creates a one dimentional array with 100 elements //curly braces defines elements themselves
//char defines letters 'a'




void randomArray()
{for(int j = 0; j< NUMTRIALS; j++)
   {
     for(int i= 0; i< REPEATS; i++)  //i++ adds one to each i //no semicolon after for() the code after is in {}
     { stimSet[i+REPEATS*j] = j + 1;
     }
   }
   arrayLength = NUMTRIALS*REPEATS;
}

int randomElement(){
  if(arrayLength == 0)  //if statements do not have semi colons, it also has the value in commas
  {
    return -1;
  }
  
  int randIndex = random(0,arrayLength); //picking a random number between 0 and the usuable length of our array
  int randomValue = stimSet[randIndex];
  for(int i= randIndex; i<arrayLength-1; i++)
    { stimSet[i] = stimSet[i+1]; //assigns the i part of stimSet as the next value
    }
  arrayLength--; //subtracts by 1 each time its called
  return randomValue; //when we call RandomElement(), we will return whats in randomValue
  }





void trialA() //trial A, flash only 
  {
    randOff = random(lowBound, highBound);    // generate OFF time between high and low bound times
    digitalWrite(AtoEEG, HIGH); //sends voltage pulse to the EEG that trial A (light flashes only) 
    delay(100);
    digitalWrite(AtoEEG, LOW); 
    delay(fixDelay);

    digitalWrite(LEDPin, HIGH);   // sets the LED on
    digitalWrite(LtoEEG, HIGH);   //sends voltage pulse to EEG
    delay(lightOn);                    // waits for 30ms
    digitalWrite(LEDPin, LOW);    // sets the LED off
    digitalWrite(LtoEEG, LOW);

    Serial.print(F("Trial A (flashes only) has occured ")); Serial.print(A_Counter+1); Serial.print(F(" times")); Serial.print(F("Delay:" )); Serial.println(randOff);
    delay(randOff);               // waits for a random time while OFF

    
    A_Counter = A_Counter + 1;
  }

void trialB()  //trial B tones only 
  {
    randOff = random(lowBound, highBound);
    randPitchSound = random(LowSound, HighSound);
              
    digitalWrite(BtoEEG, HIGH); //sends voltage pulse to the EEG that trial A (tones only) 
    delay(100);
    digitalWrite(BtoEEG, LOW); 
    delay(fixDelay);

    digitalWrite(StoEEG, HIGH);  //sends voltage pulse to EEG that tone is on
    toneAC(randPitchSound, Intensity, SoundOn); // Including toneAC - Send (Random)KHz sound signal, Syntax: toneAC( frequency [, volume [, length [, background ]]] )
    digitalWrite(StoEEG, LOW); 
             
     Serial.print(F("Trial B (tones only) has occured ")); Serial.print(B_Counter+1); Serial.print(F(" times")); Serial.print(F(" ||Pitch = ")); Serial.print(randPitchSound); Serial.print(F("Delay:" )); Serial.println(randOff);
     delay(randOff);        
            
     B_Counter = B_Counter + 1;
    }

void trialC()  //trial C AVA
  {
    randOff = random(lowBound, highBound);    // generate OFF time between lowBound and highBound
    randPitchSound = random(LowSound, HighSound);

    digitalWrite(CtoEEG, HIGH);  //Sends voltage pulse to EEG that trial C (AVA) is occuring
    delay(100);
    digitalWrite(CtoEEG, LOW); 
    delay(fixDelay);

    digitalWrite(StoEEG, HIGH);  //first tone
    toneAC(randPitchSound, Intensity, SoundOn); // Including toneAC - Send (Random)KHz sound signal, Syntax: toneAC( frequency [, volume [, length [, background ]]] )
    digitalWrite(StoEEG, LOW);   
    delay(StoLdelay); 
             
    digitalWrite(LEDPin, HIGH);   // sets the LED on, flash of light 
    digitalWrite(LtoEEG, HIGH);   //sends voltage pulse to EEG
    delay(lightOn);                    //light is on for selected timems
    digitalWrite(LEDPin, LOW);    // sets the LED off
    digitalWrite(LtoEEG, LOW);   //turns off voltage pulse to EEG
    delay(LtoSdelay);               // waits for a random time while OFF
             
    digitalWrite(StoEEG, HIGH);
    toneAC(randPitchSound, Intensity, SoundOn); // Including toneAC - Send (Random)KHz sound signal, Syntax: toneAC( frequency [, volume [, length [, background ]]] )
    digitalWrite(StoEEG, LOW);   
    Serial.print(F("Trial C (AVA) has occured ")); Serial.print(C_Counter+1); Serial.print(F(" times")); Serial.print(F(" ||Pitch = ")); Serial.print(randPitchSound); Serial.print(F("Delay:" )); Serial.println(randOff);
    
    delay(randOff);         
    C_Counter = C_Counter + 1;
   }
   
void trialD()  //trial D, AVAV
 {
    randOff = random(lowBound, highBound);    // generate OFF time between lowBound and highBound
    randPitchSound = random(LowSound, HighSound);

    digitalWrite(DtoEEG, HIGH);  //Sends information to EEG that trial D (AVAV) is occuring
    delay(100);
    digitalWrite(DtoEEG, LOW); 
    delay(fixDelay);

    digitalWrite(StoEEG, HIGH);  //voltage pulse to EEG for tone //first tone 
    toneAC(randPitchSound, Intensity, SoundOn); // Including toneAC - Send (Random)KHz sound signal, Syntax: toneAC( frequency [, volume [, length [, background ]]] )
    digitalWrite(StoEEG, LOW);   
    delay(StoLdelay); 
             
    digitalWrite(LEDPin, HIGH);     // sets the LED on  //first flash
    digitalWrite(LtoEEG, HIGH);     //sends voltage pulse to EEG
    delay(lightOn);                 //light is on for selected timems
    digitalWrite(LEDPin, LOW);      // sets the LED off
    digitalWrite(LtoEEG, LOW);      //turns off voltage pulse to EEG
    delay(LtoSdelay);               // waits for a random time while OFF
             
    digitalWrite(StoEEG, HIGH);     //second tone
    toneAC(randPitchSound, Intensity, SoundOn); // Including toneAC - Send (Random)KHz sound signal, Syntax: toneAC( frequency [, volume [, length [, background ]]] )
    digitalWrite(StoEEG, LOW);   
    delay(StoLdelay);

    digitalWrite(LEDPin, HIGH);   // second flash
    digitalWrite(LtoEEG, HIGH);   //sends voltage pulse to EEG
    delay(lightOn);                    //light is on for selected timems
    digitalWrite(LEDPin, LOW);    // sets the LED off
    digitalWrite(LtoEEG, LOW);   //turns off voltage pulse to EEG
        
    Serial.print(F("Trial D (AVAV) has occured ")); Serial.print(D_Counter+1); Serial.print(F(" times")); Serial.print(F(" ||Pitch = ")); Serial.print(randPitchSound); Serial.print(F("Delay:" )); Serial.println(randOff);

    delay(randOff);         
    D_Counter = D_Counter + 1;         
   }
 
void trialE() //trial E, AAV
   {
     randOff = random(lowBound, highBound);    // generate OFF time between lowBound and highBound
     randPitchSound = random(LowSound, HighSound);

     digitalWrite(EtoEEG, HIGH);  //Sends information to EEG that trial E (AAV) is occuring
     delay(100);
     digitalWrite(EtoEEG, LOW); 
     delay(fixDelay);

     digitalWrite(StoEEG, HIGH);  //voltage pulse to EEG for tone //first tone 
     toneAC(randPitchSound, Intensity, SoundOn); // Including toneAC - Send (Random)KHz sound signal, Syntax: toneAC( frequency [, volume [, length [, background ]]] )
     digitalWrite(StoEEG, LOW);   
     delay(StoSdelay); 

     digitalWrite(StoEEG, HIGH);  //voltage pulse to EEG for tone //second tone 
     toneAC(randPitchSound, Intensity, SoundOn); // Including toneAC - Send (Random)KHz sound signal, Syntax: toneAC( frequency [, volume [, length [, background ]]] )
     digitalWrite(StoEEG, LOW);   
     delay(StoLdelay); 
             
     digitalWrite(LEDPin, HIGH);     // sets the LED on  //first flash
     digitalWrite(LtoEEG, HIGH);     //sends voltage pulse to EEG
     delay(lightOn);                 //light is on for selected timems
     digitalWrite(LEDPin, LOW);      // sets the LED off
     digitalWrite(LtoEEG, LOW);      //turns off voltage pulse to EEG

     Serial.print(F("Trial E (AAV) has occured ")); Serial.print(E_Counter+1); Serial.print(F(" times")); Serial.print(F(" ||Pitch = ")); Serial.print(randPitchSound); Serial.print(F("Delay:" )); Serial.println(randOff); 

     delay(randOff);        
     E_Counter = E_Counter + 1;
    }





  

void setup()                      // run once, when the sketch starts
{
 randomSeed (analogRead (5));    // randomize using analog pin 5 - MUST BE UNUSED AND UNCONNECTED
// pinMode(buzzer, OUTPUT); //set buzzer - pin 9 as an output
 pinMode(LEDPin, OUTPUT);        // sets the digital pin as output
 pinMode(LtoEEG, OUTPUT);
 pinMode(StoEEG, OUTPUT);
 pinMode(AtoEEG, OUTPUT);
 pinMode(BtoEEG, OUTPUT);
 pinMode(CtoEEG, OUTPUT);
 pinMode(DtoEEG, OUTPUT);
 pinMode(EtoEEG, OUTPUT);

 randomArray();
 Serial.begin(9600);
 Serial.println(F("Welcome, Let's begin"));
 Serial.println(F(""));
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
        lowBound = 5000;   //shortest delay= 5 seconds
        highBound = 8000; //longest delay = 10 secodns 
        lightOn = 5; //light on for 5ms 
        
        TrialTotal = 20;  //total trials = 100 
        
        LowSound = 7500;  //Pitch set to 15kHz
        HighSound = 7500;
        SoundOn = 10;  //tone for 50ms
        Intensity = 10; //Sound volume set at level 5 which is medium

        StoLdelay = 10;
        LtoSdelay = 70;
        StoSdelay = 70;
        
        Serial.println(F("Default setting chosen"));
        Serial.print(F("Lower bound of delay between trials is set at ")); Serial.print(lowBound); Serial.println(F(" msecs"));
        Serial.print(F("Upper bound of delay between trials is set at ")); Serial.print(highBound); Serial.println(F(" msecs"));
        Serial.print(F("Light duration is set at ")); Serial.print(lightOn); Serial.println(F(" msecs"));
        Serial.print(F("Lower frequency bound for sound is ")); Serial.print(LowSound); Serial.println(F(" Hz"));
        Serial.print(F("Higher frequency bound for sound is ")); Serial.print(HighSound); Serial.println(F(" Hz"));
        Serial.print(F("Sound duration is set at ")); Serial.print(SoundOn); Serial.println(F(" msecs"));
        Serial.print(F("Volume set at level ")); Serial.println(Intensity);
        Serial.print(F("Delay between tone and flash ")); Serial.print(StoLdelay); Serial.println(F(" msecs"));
        Serial.print(F("Delay between flash and tone ")); Serial.print(LtoSdelay); Serial.println(F(" msecs"));
        Serial.print(F("Delay between two consecutive tones ")); Serial.print(StoSdelay); Serial.println(F(" msecs"));
        Serial.print(F("Total number of trials of each type of stimulus : ")); Serial.println(TrialTotal);
       
        Initialize = 2;
       
       }

       else
       {
        Serial.println(F("User inputs selected"));
        Initialize = 1;
       }
       while (Serial.available() > 0)
       {junk = Serial.read();}  //clears anything in serial

       }

       

      
     }
  
     if (Initialize == 1)
     {
       Serial.println(F("Enter lower bound of delay between trials (msec)"));
       
       while (Serial.available() == 0 );
       {
       lowBound = Serial.parseFloat();
       Serial.print(F("Lower bound is set at ")); Serial.println(lowBound, DEC);
       
       while (Serial.available() > 0)
       {junk = Serial.read();}
       }
       
       Serial.println(F("Enter upper bound of delay between trials (msec)"));
       
       while (Serial.available() == 0);
       {
       highBound = Serial.parseFloat();
       Serial.print(F("Upper bound is set at ")); Serial.println(highBound, DEC);
       
       while (Serial.available() > 0)
       {junk = Serial.read();}
       }
       
       Serial.println(F("Enter duration of light pulse (msec)"));
       
       while (Serial.available() == 0);
       {
       lightOn = Serial.parseFloat();
       Serial.print(F("Light duration is set at ")); Serial.println(lightOn, DEC);
       
       while (Serial.available() > 0)
       {junk = Serial.read();}
       }
    

       Serial.println(F("Lower frequency bound for sound (Hz) (Integer)?)"));
    
       while (Serial.available() == 0);
       {
        LowSound = Serial.parseInt();
        Serial.print(F("Lower frequency bound is ")); Serial.print(LowSound); Serial.println(F(" Hz"));
    
       while (Serial.available() > 0)
       {junk = Serial.read();}
       }

       Serial.println(F("Higher frequency bound for sound (Hz) (Integer)?)"));
    
       while (Serial.available() == 0);
       {
        HighSound = Serial.parseInt();
        Serial.print(F("Higher frequency bound is ")); Serial.print(HighSound); Serial.println(F(" Hz"));
    
       while (Serial.available() > 0)
       {junk = Serial.read();}
       }

       Serial.println(F("Enter duration of audio sound (msec)"));
       
       while (Serial.available() == 0);
       {
       SoundOn = Serial.parseFloat();
       Serial.print(F("Sound duration is set at ")); Serial.println(SoundOn, DEC);
       
       while (Serial.available() > 0)
       {junk = Serial.read();}
       }

       Serial.println(F("Please set the volume for sound (Range: 0 to 10) (Integer)"));
    
       while (Serial.available() == 0);
       {
        Intensity = Serial.parseInt();
        Serial.print(F("Volume set at level ")); Serial.println(Intensity);
    
       while (Serial.available() > 0)
       {junk = Serial.read();}
       }

       Serial.println(F("Please set the delay time between a tone and a flash (msec)"));
    
       while (Serial.available() == 0);
       {
        StoLdelay = Serial.parseInt();
        Serial.print(F("Delay between a tone and a flash is ")); Serial.print(StoLdelay); Serial.println(F("msec"));
    
       while (Serial.available() > 0)
       {junk = Serial.read();}
       }

       Serial.println(F("Please set the delay time between a flash and a tone (msec)"));
    
       while (Serial.available() == 0);
       {
        LtoSdelay = Serial.parseInt();
        Serial.print(F("Delay between a flash and a tone is ")); Serial.print(LtoSdelay); Serial.println(F("msec"));
    
       while (Serial.available() > 0)
       {junk = Serial.read();}
       }

       Serial.println(F("Please set the delay time between two consecutive tones (msec)"));
    
       while (Serial.available() == 0);
       {
        StoSdelay = Serial.parseInt();
        Serial.print(F("Delay between two consecutive flashes is ")); Serial.print(StoSdelay); Serial.println(F("msec"));
    
       while (Serial.available() > 0)
       {junk = Serial.read();}
       }

       Serial.println(F("How many trials of each stimuli should be given per set (Integer)"));
    
       while (Serial.available() == 0);
       {
        TrialTotal = Serial.parseInt();
        Serial.print(F("Total trials: ")); Serial.print(TrialTotal); Serial.println(F(" per set"));
    
       while (Serial.available() > 0)
       {junk = Serial.read();}
       }


       Initialize = 2;
    
     }

     if (Initialize == 2)
     {
      Serial.println(F("Enter 'a' to start"));
    
       while (Serial.available() == 0);
       {
        Serial.println(F("Running..."));
        Initialize = 3;
       }
     }
     if(Initialize == 3)
      {
        int randomVariable = randomElement();
        switch(randomVariable)
        {
          case 1:
            trialA();
            break;
          case 2:
            trialB();
            break;
          case 3: 
            trialC();
            break;
          case 4:
            trialD();
            break;
          case 5:
            trialE();
            break;
          default:
            Serial.println("Program has ended");
            delay(50);
            exit(0);
            break;  
        } 
      }
 }
