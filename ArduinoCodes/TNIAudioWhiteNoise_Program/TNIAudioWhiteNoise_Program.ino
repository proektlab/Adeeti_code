// Make sure to download and add elapsedMillis.h 

#include <elapsedMillis.h>

//Audio Program
//Place positive stereo wire into Pin 9 and the negative into ground
int Initialize = 1;
char junk = ' ';
int LEDTotal;
int LED_Counter = 1;
const int buzzerPin = 9;
int LowSound;
int HighSound;
float SoundOn;
float LowBoundSoundDelay;
float HighBoundSoundDelay;
long randOffSound = 0;
long randPitchSound = 0;

unsigned long int reg;

elapsedMillis timer0;

void setup()                      // run once, when the sketch starts
{
 randomSeed (analogRead (5));    // randomize using analog pin 5, MUST BE UNCONNECTED AND UNUSED
 pinMode(buzzerPin, OUTPUT); //set buzzer - pin 9 as an output
 Serial.begin(9600);
 Serial.println("Welcome, Let's begin");
 Serial.println("");
 Serial.flush();

 // Arbitrary inital value; must not be zero
 reg = 0x55aa55aaL; //The seed for the bitstream. It can be anything except 0.
}

void loop()                 // run over and over again
{
  
//     if (Initialize == 0)
//     {
//
//       Serial.println("Lower frequency bound for sound (Hz) (Integer)?)");
//    
//       while (Serial.available() == 0);
//       {
//        LowSound = Serial.parseInt();
//        Serial.print("Lower frequency bound is "); Serial.print(LowSound); Serial.println(" Hz");
//    
//       while (Serial.available() > 0)
//       {junk = Serial.read();}
//       }
//
//       Serial.println("Higher frequency bound for sound (Hz) (Integer)?)");
//    
//       while (Serial.available() == 0);
//       {
//        HighSound = Serial.parseInt();
//        Serial.print("Higher frequency bound is "); Serial.print(HighSound); Serial.println(" Hz");
//    
//       while (Serial.available() > 0)
//       {junk = Serial.read();}
//       }
//
//       Serial.println("Enter lower bound of sound delay duration for sound (msec)");
//       
//       while (Serial.available() == 0 );
//       {
//       LowBoundSoundDelay = Serial.parseFloat();
//       Serial.print("Lower sound delay bound is set at "); Serial.println(LowBoundSoundDelay, DEC);
//       
//       while (Serial.available() > 0)
//       {junk = Serial.read();}
//       }
//       
//       Serial.println("Enter upper bound of delay duration for sound (msec)");
//       
//       while (Serial.available() == 0);
//       {
//       HighBoundSoundDelay = Serial.parseFloat();
//       Serial.print("Upper sound delay bound is set at "); Serial.println(HighBoundSoundDelay, DEC);
//       
//       while (Serial.available() > 0)
//       {junk = Serial.read();}
//       }
//
//       Serial.println("Enter duration of audio sound (msec)");
//       
//       while (Serial.available() == 0);
//       {
//       SoundOn = Serial.parseFloat();
//       Serial.print("Sound duration is set at "); Serial.println(SoundOn, DEC);
//       
//       while (Serial.available() > 0)
//       {junk = Serial.read();}
//       }
//
//       Serial.println("How many times do you want the Sound to turn on (Integer)");
//    
//       while (Serial.available() == 0);
//       {
//        LEDTotal = Serial.parseInt();
//        Serial.print("Audio will turn on a total of "); Serial.print(LEDTotal); Serial.println(" times");
//    
//       while (Serial.available() > 0)
//       {junk = Serial.read();}
//       }
//
//       Serial.println("Enter 'a' to start");
//    
//       while (Serial.available() == 0);
//       {
//        Serial.println("Running...");
//        Initialize = Initialize + 1;
//       }
//    
//     }
     
     if (Initialize == 1)
     {

         int frequency = 500;
         generateNoise(frequency);
//         delay(5000);
//         Initialize = 0;
         
          
     }
}

void generateNoise(int frequency) 
{
          unsigned long int newr;
          unsigned char lobit;
          unsigned char b31, b29, b25, b24;
           
          // Extract four chosen bits from the 32-bit register
          b31 = (reg & (1L << 31)) >> 31;
          b29 = (reg & (1L << 29)) >> 29;
          b25 = (reg & (1L << 25)) >> 25;
          b24 = (reg & (1L << 24)) >> 24;
        
          // EXOR the four bits together
          lobit = b31 ^ b29 ^ b25 ^ b24;
          
          // Shift and incorporate new bit at bit position 0
          newr = (reg << 1) | lobit;
          
          // Replace register with new value
          reg = newr;
          
          // Drive speaker pin from bit 0 of 'reg'
          digitalWrite(buzzerPin, reg & 1);
          
          // Delay (50) corresponds to 20kHz, but the actual frequency of updates
          // will be lower, due to computation time and loop overhead
          delayMicroseconds(frequency);    // Changing this value changes the frequency.

          

}
