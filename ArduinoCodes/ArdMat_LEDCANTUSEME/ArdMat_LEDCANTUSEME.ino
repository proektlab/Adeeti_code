// LED lighting with Matlab interface 
#define MAX_CHANNELS  4
#define START_CODE 255

int LEDPin = 13;                  // LED connected to digital pin 13         
int LtoEEG = 5;                   // BNC input to aquition system is on postion 5
int command;

int channelIndex = 0;
int executedChannels = 0;

unsigned long startTime;

unsigned int portIDs[MAX_CHANNELS];
unsigned long startTimes[MAX_CHANNELS];
unsigned long endTimes[MAX_CHANNELS];
int pinStates[MAX_CHANNELS]; //0 is waiting, 1 is on, 2 is off


void setup() {
  Serial.begin(9600);
}

void loop() {
  if(Serial.available() > 0)
  {
    unsigned int peekInt;
    if ((peekInt = Serial.read()) == START_CODE)
    {
      
      executedChannels = 0;

      for (int i = 0; i < channelIndex; i++)
      {
        pinStates[i] = 0;
      }
      
      startTime = micros();
      
      while (executedChannels < channelIndex)
      {
        unsigned long currentTime = micros();
        
        for (int i = 0; i < channelIndex; i++)
        {
          if (pinStates[i] == 0 && startTime + startTimes[i]*1000 < currentTime)
          {
            digitalWrite(portIDs[i], HIGH);

            pinStates[i] = 1;
          }
          else if (pinStates[i] == 1 && startTime + endTimes[i]*1000 < currentTime)
          {
            digitalWrite(portIDs[i], LOW);

            pinStates[i] = 2;

            executedChannels++;
          }
        }
      }

      channelIndex = 0;
    }
    else
    {
      portIDs[channelIndex] = peekInt;

      pinMode(portIDs[channelIndex], OUTPUT);
      
      while (Serial.available() == 0);
      startTimes[channelIndex] = unsigned(Serial.read());
      startTimes[channelIndex] = startTimes[channelIndex] << 8;

      while (Serial.available() == 0);
      startTimes[channelIndex] += unsigned(Serial.read());

      while (Serial.available() == 0);
      endTimes[channelIndex] = unsigned(Serial.read());
      endTimes[channelIndex] = endTimes[channelIndex] << 8;

      while (Serial.available() == 0);
      endTimes[channelIndex] += unsigned(Serial.read());
      
  
      channelIndex++;
    }
  }

  
}
