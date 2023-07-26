const int inPin = 7;                   // the number of the input pin
//const int BitPin = 4;                   // the number of the input pin
static unsigned long startTime = 0;  // the time the switch state change was first detected
static boolean state;                // the current state of the switch
unsigned long trig = 0; // length of signal (for detecting trial type
const int bitPulseLength = 2;
const int bitbreakLength = 5;
static unsigned long REFRESH_INTERVAL = 7; // ms ...set later by sum of above;
static unsigned long lastRefreshTime = 0;
static unsigned long bitCounter = 0;
int bitArray[] = {0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0};
//int currentBit = 0;
int i ;


void setup()
{
  pinMode(inPin, INPUT);
  digitalWrite(inPin, LOW); // turn on pull-up resistor
  Serial.begin(9600);
}
void loop()
{
  if (digitalRead(inPin) != state) // check to see if the switch has changed state
  {
    state = ! state;
    if (state == HIGH)
    {
      Serial.println(1);// trigger for sound only when it follows a trial type number so 20 35 50 or 
      //65 ms withing 5ish ms error and 80 for sound recording trigger
      startTime = millis();  // start time
    }
    if (state == LOW)
    {
      trig = (millis() - startTime); // length signal was high
      Serial.println(trig);
      startTime = 0; // reset start time
    }
  }
  lastRefreshTime = millis();
  if ((trig >= 6) && (trig <= 14)) // start listening to bit code BIT CODE INIT IS 9 MS PULSE
  {
    while (bitCounter < 10)
    {
      //      Serial.println(7);//


      if (digitalRead(inPin) != state) // check to see if the switch has changed state
      {
        //        bitArray[bitCounter] = 1;
        //        Serial.println(3);//
        state = ! state;
        if (state == LOW) // ADD DEBOUNCER HERE!!!
        {
          bitArray[bitCounter] = 1;
          //                    Serial.println(3);//
        }

      }
      //      Serial.println(millis() - lastRefreshTime);//
      if (millis() - lastRefreshTime >= REFRESH_INTERVAL) // if time interval has been reached
      {
        //         Serial.println(lastRefreshTime);//
        //        Serial.println(state);
        //                Serial.println(bitArray[bitCounter]);//
        //        lastRefreshTime += REFRESH_INTERVAL;
        lastRefreshTime = millis();
        bitCounter += 1;
        //        Serial.println(bitCounter);//
        //                recordBits();
      }
      //      else
      //      {
      //        Serial.println(5);//
      //      }



    }
    for (i = 0; i <= 9; i++)
    {
      Serial.println(bitArray[i]);
    }
    trig = 0;
    bitCounter = 0;
    memset(bitArray, 0, sizeof(bitArray)); // clear bit array
  }
  //        Serial.println(bitArray);//

}
