#include <Wire.h> // reqd for I2C 

// ####################################################################################################
// switch LED on/off depending on bar position on panels
// for use during closed-loop bar tracking: TWO ARDUINO SETUP
//
// use thorlabs ledd1b in 'MOD mode':
// - Arduino1 sets voltage level > sends to Arduino2
// - Arduino2 waits for bar to enter certain position (within window)
// - Arduino2 sends to voltage level to LED driver via PWM Aout
// ####################################################################################################

// inputs

int barPosInputPin = A0; // input from panels controller (DAC), sampled on A0
int barPosPinVal = 0; // raw input val (0-1023)
int barPos = 0;  // store the bar position (in pixels)
int barMidlinePos = 49; // (pixels) adjust according to pattern
int LEDToggleRange = 2; // (+/-pixels) half-width of window in which LED will be on

int LEDVoltageInputPin = A7; // input from Aout on Arduino1 (connected to Matlab), specify LED voltage
int LEDVoltagePinVal = 0; // (from pwm duty cycle) 0-1023 (read) => 0-255 (sent) => 0-100%
int LEDVoltage = 0; // store the desired LED voltage (0-5V)

int bypassInputPin = 2; // input from another TTL source to bypass LED gating
int bypassToggle = LOW; // toggle HIGH (bypass) or LOW (normal gating mode)

int manualONOFFInputPin = 3; // input from another TTL source to manually switch LED on at specified voltage
int manualONOFFToggle = LOW; // toggle HIGH to switch ON (bypassPinVal must also be HIGH)

int resetBarTimeInputPin = 4; // input from another TTL source to bypass LED gating
int resetBarTimeToggle = LOW; // toggle HIGH to reset device

// ####################################################################################################

//outputs

int LEDOutputPin = A2; // output to LED (pwm duty cycle) 0-255 => 0-100%
int LEDOutputPinVal = 0; // value to be sent (0-255)

int barTimeOutputPin = A1; // output to Arduino1 (connected to Matlab), specifying bar time spent within window
int barTimePinVal = 0; // 0-255 (sent) => 0-255s
int barTimeSumS = 150; // (sec) counter 0-255, counts cumulative time within window, wraps around when 255 reached
int barTimeSumMS = 0; // (ms) counter 0-999, counts ms within window since last integer number of seconds

int barTimeMultiplyOutputPin = A3; // output to Arduino1 (connected to Matlab), specifying bar time spent within window
int barTimeMultiplyVal = 240; // 0-255 (used to multiply value on barTimePinVal)

// ####################################################################################################

void setup() {
  // put your setup code here, to run once:

  pinMode(barPosInputPin, INPUT);
  pinMode(LEDVoltageInputPin, INPUT);
  pinMode(LEDOutputPin, OUTPUT);  // sets the pin as output
  pinMode(barTimeOutputPin, OUTPUT);  // sets the pin as output
  pinMode(barTimeMultiplyOutputPin, OUTPUT);  // sets the pin as output
  pinMode(LED_BUILTIN, OUTPUT);  // sets the LED as output for testing
  pinMode(0, INPUT);  // sets the pin as output
  pinMode(1, INPUT);  // sets the pin as output
  pinMode(2, INPUT);  // sets the pin as output

  Serial.begin(9600); // for testing
   // Serial.begin(115200); // for testing
  Serial.print("\n\tnano reset\n");

  Wire.begin(0);
  
  // at start, read desired LED voltage from matlab-connected Arduino1 and setup for output to LED on pwm pin
  LEDVoltagePinVal = analogRead(LEDVoltageInputPin); // 0-1023 (read) => 0-255 (sent) => 0-100%
  LEDVoltage = LEDVoltagePinVal * 0.00488; // 5/1023
  //Serial.println(LEDVoltage); //for testing
  LEDOutputPinVal = LEDVoltage * 51; //255/5

}
// ####################################################################################################

void loop() {
  // put your main code here, to run repeatedly:

  delay(1);
  // ####################################################################################################

  //read reset time pin
  resetBarTimeToggle = digitalRead(resetBarTimeInputPin);
  if (resetBarTimeToggle) {
    barTimeSumS = 0;
    barTimeSumMS = 0;
  }

  //read bypass pin
  bypassToggle = digitalRead(bypassInputPin);

  // ####################################################################################################

  if (!bypassToggle) {
    // main section: gating of LED based on bar pos
    // ####################################################################################################

    //read bar position (0-1023 <=> 0-5V <=> 1-96pix (for pattern with 96 x-positions
    barPosPinVal = analogRead(barPosInputPin);
    barPos = ceil((barPosPinVal * 0.0938)); // *96/1024
    //Serial.println(barPosPinVal); //for testing
    //Serial.println(barPos); //for testing
barPos = 48;
    if ((barPos >= (barMidlinePos - LEDToggleRange)) && (barPos <= (barMidlinePos + LEDToggleRange)) ) { // bar is within window
      //  digitalWrite(LEDOutputPin, HIGH);
      analogWrite(LEDOutputPin, LEDOutputPinVal);
      digitalWrite(LED_BUILTIN, HIGH); // for testing
      // Serial.println("ON"); //for testing

      // increment millisecond counter
      barTimeSumMS = (barTimeSumMS + 1) % 1000;

      // if 1 second cumulative time in window has passed, increment second counter
      if (barTimeSumMS == 999) {
        if (barTimeSumS == 255) { // 255 seconds have passed, increment multiple counter
          barTimeMultiplyVal++;
        }
        barTimeSumS = (barTimeSumS + 1) % 256;
        // Serial.println(barTimeSumS); //for testing
      }

    }
    // ####################################################################################################
    else { // LED off
      // digitalWrite(LEDOutputPin, LOW);
      analogWrite(LEDOutputPin, 0);
      digitalWrite(LED_BUILTIN, LOW); // for testing
      // Serial.println("OFF"); //for testing
    }
  }
  // ####################################################################################################
  else {
    // main section skipped: bypass is toggled HIGH
    // allow manual ON/OFF control of LED
    manualONOFFToggle = digitalRead(manualONOFFInputPin);
    if (manualONOFFToggle) {// LED on
      analogWrite(LEDOutputPin, LEDOutputPinVal);
      digitalWrite(LED_BUILTIN, HIGH); // for testing
    }
    else { // LED off
      analogWrite(LEDOutputPin, 0);
      digitalWrite(LED_BUILTIN, LOW); // for testing
    }
  }
  // ####################################################################################################

  // after switching LED ON/OFF, write barTime and multiplier to PWM outputs
  barTimePinVal = barTimeSumS;
  analogWrite(barTimeOutputPin, barTimePinVal);
  analogWrite(barTimeMultiplyOutputPin, barTimeMultiplyVal);

  // ####################################################################################################

  // for testing

  delay(1000);
  
  // at start, read desired LED voltage from matlab-connected Arduino1 and setup for output to LED on pwm pin
  LEDVoltagePinVal = analogRead(LEDVoltageInputPin); // 0-1023 (read) => 0-255 (sent) => 0-100%
  LEDVoltage = LEDVoltagePinVal * 0.00488; // 5/1023
  //Serial.println(LEDVoltage); //for testing
  LEDOutputPinVal = LEDVoltage * 51; //255/5

  Serial.print("\n\n#########################################");

  Serial.print("\nresetBarTimeToggle\t\t");
  Serial.print(resetBarTimeToggle);

  Serial.print("\nbypassToggle\t\t\t");
  Serial.print(bypassToggle);

  Serial.print("\nmanualONOFFToggle\t\t");
  Serial.print(manualONOFFToggle);

  Serial.print("\nLEDVoltage\t\t\t");
  Serial.print(LEDVoltage);
  
 Serial.print("\nLEDVoltage\t\t\t");
  Serial.print(LEDVoltage);

float barTimeTotal = 0;
  barTimeTotal = (float)barTimeMultiplyVal*255.0 + (float)barTimePinVal;
  byte barTimeByte = barTimeTotal;
 Wire.beginTransmission(0); // transmit to device #4
  Wire.write(barTimeByte);              // sends one byte  
  Wire.endTransmission();    // stop transmitting
  
  Serial.print("\nbarTimeTotal\t\t\t");
  Serial.print(barTimeTotal);
  Serial.print(" s");

Serial.print("\nbarTimeSumMS\t\t\t");
  Serial.print(barTimeSumMS);
  Serial.print(" ms");
  
Serial.print("\nbarTimeSumS\t\t\t");
  Serial.print(barTimeSumS);
  Serial.print(" s");

  Serial.print("\nbarTimeMultiplyVal\t\t");
  Serial.print(barTimeMultiplyVal);
  
    Serial.print("\nbarTimePinVal\t\t\t");
  Serial.print(barTimePinVal);
  
  Serial.print("\n");

  // ####################################################################################################

}
