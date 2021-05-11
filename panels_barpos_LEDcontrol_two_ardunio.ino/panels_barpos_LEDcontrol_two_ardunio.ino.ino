// ####################################################################################################
// switch LED on/off depending on bar position on panels
// for use during closed-loop bar tracking: TWO ARDUINO SETUP
//
// use thorlabs ledd1b in 'MOD mode':
// - Arduino1 controls LED and relays digital signal to arduino 2 when bar is within window
// - Arduino2 waits for bar to enter certain position (within window) 
// - Arduino2 bypasses arduino1 CL control and manually toggles LED
// ####################################################################################################

// int nidx = 0; for testing

// inputs

int barPosInputPin = A0;  // input from panels controller (DAC), sampled on A0
int barPosPinVal = 0;     // raw input val (0-1023)
float barPos = 0;           // store the bar position (in pixels)
int barMidlinePos = 57;   // (pixels) adjust according to pattern
int LEDToggleRange = 2;   // (+/-pixels) half-width of window in which LED will be on

int LEDVoltage = 5;           // store the desired LED voltage (0-5V)

int bypassInputPin = 2;  // input from another TTL source to bypass LED gating
int bypassToggle = LOW;  // toggle HIGH (bypass) or LOW (normal gating mode)

int manualONOFFInputPin = 3;  // input from another TTL source to manually switch LED on at specified voltage
int manualONOFFToggle = LOW;  // toggle HIGH to switch ON (bypassPinVal must also be HIGH)

// ####################################################################################################

//outputs

int LEDOutputPin = A2;    // output to LED (pwm duty cycle) 0-255 => 0-100%
int LEDOutputPinVal = 0;  // value to be sent (0-255)

int windowFlagOutputPin = 4;  // mark when bar is within window with digital signal, sent to arduino 1 (connected to Matlab)
int windowFlag = LOW;  // 

// ####################################################################################################

void setup() {
// put your setup code here, to run once:

pinMode(barPosInputPin, INPUT);

pinMode(LEDOutputPin, OUTPUT);              // sets the pin as output
pinMode(LED_BUILTIN, OUTPUT);               // sets the LED as output for testing
pinMode(bypassInputPin, INPUT);                          // sets the pin as output
pinMode(manualONOFFInputPin, INPUT);                          // sets the pin as output
pinMode(windowFlagOutputPin, OUTPUT);                          // sets the pin as output

// Serial.begin(9600);  // for testing
// Serial.begin(115200); // for testing
// Serial.print("\n\tnano reset\n");

LEDOutputPinVal = LEDVoltage * 51;  //255/5

}
// ####################################################################################################

void loop() {
// put your main code here, to run repeatedly:

delay(1);
// ####################################################################################################

//read bypass pin
bypassToggle = digitalRead(bypassInputPin);

// ####################################################################################################

if (!bypassToggle) {
// main section: gating of LED based on bar pos
// ####################################################################################################

//read bar position (0-1023 <=> 0-5V <=> 1-160pix (for pattern with 160 x-positions
barPosPinVal = analogRead(barPosInputPin);
barPos = floor(barPosPinVal * 0.0733);  // *75/1023 (assuming bar pattern has 160 positions, arduino reads half of these (1023  = 80pix))
// barPos = floor(barPosPinVal * 0.0938);  // *96/1023 (assuming bar pattern has 160 positions, arduino reads half of these (1023  = 80pix))
// barPos = floor(barPosPinVal * 0.1564);  // *160/1023 (assuming bar pattern has 160 positions, arduino reads half of these (1023  = 80pix))

if ((barPos >= (barMidlinePos - LEDToggleRange)) && (barPos <= (barMidlinePos + LEDToggleRange))) {  // bar is within window
analogWrite(LEDOutputPin, LEDOutputPinVal);
// digitalWrite(LED_BUILTIN, HIGH);  // for testing
windowFlag = 1; 
}
else {  // LED off
analogWrite(LEDOutputPin, 0);
// digitalWrite(LED_BUILTIN, LOW);  // for testing
windowFlag = 0; 
}
}
// ####################################################################################################
else {
// main section skipped: bypass is toggled HIGH
// allow manual ON/OFF control of LED
manualONOFFToggle = digitalRead(manualONOFFInputPin);
if (manualONOFFToggle) {  // LED on
analogWrite(LEDOutputPin, LEDOutputPinVal);
// digitalWrite(LED_BUILTIN, HIGH);  // for testing
} else {                            // LED off
analogWrite(LEDOutputPin, LOW);
// digitalWrite(LED_BUILTIN, LOW);  // for testing
}
windowFlag = 0; 
}
// ####################################################################################################

//// after switching LED ON/OFF, write to outputs
digitalWrite(windowFlagOutputPin, windowFlag);  

// ####################################################################################################

// for testing

// nidx++; 
// if (nidx % 1000 == 0) {

// // barPosPinVal = analogRead(barPosInputPin);
// // barPos = round(barPosPinVal * 0.0733);  // *80/1023 (assuming bar pattern has 160 positions, arduino reads half of these ie 80pix = 1023)
// // // at start, read desired LED voltage from matlab-connected Arduino1 and setup for output to LED on pwm pin
// // LEDVoltagePinVal = analogRead(LEDVoltageInputPin);  // 0-1023 (read) => 0-255 (sent) => 0-100%
// // LEDVoltage = LEDVoltagePinVal * 0.00488;            // 5/1023
// // //Serial.println(LEDVoltage); //for testing
// // LEDOutputPinVal = LEDVoltage * 51;  //255/5
// // analogWrite(LEDOutputPin, LEDOutputPinVal);

// Serial.print("\n\n#########################################");

// // Serial.print("\nresetBarTimeToggle\t\t");
// // Serial.print(resetBarTimeToggle);

// Serial.print("\nbypassToggle\t\t\t");
// Serial.print(bypassToggle);

// Serial.print("\nmanualONOFFToggle\t\t");
// Serial.print(manualONOFFToggle);

// Serial.print("\nwindowFlag\t\t\t");
// Serial.print(windowFlag);

// Serial.print("\nbarPosPin\t\t\t");
// Serial.print(barPosPinVal);

// Serial.print("\nbarPos\t\t\t\t");
// Serial.print(barPos);
// // Serial.print("\nLEDVoltage\t\t\t");
// // Serial.print(LEDVoltage);

// // Serial.print("\nLEDVoltage\t\t\t");
// // Serial.print(LEDVoltage);

// // float barTimeTotal = 0;
// // barTimeTotal = (float)barTimeMultiplyVal * 255.0 + (float)barTimePinVal;
// // byte barTimeByte = barTimeTotal;
// // Wire.beginTransmission(0);  // transmit to device #4
// // Wire.write(barTimeByte);    // sends one byte
// // Wire.endTransmission();     // stop transmitting

// // Serial.print("\nbarTimeTotal\t\t\t");
// // Serial.print(barTimeTotal);
// // Serial.print(" s");

// // Serial.print("\nbarTimeSumMS\t\t\t");
// // Serial.print(barTimeSumMS);
// // Serial.print(" ms");

// // Serial.print("\nbarTimeSumS\t\t\t");
// // Serial.print(barTimeSumS);
// // Serial.print(" s");

// // Serial.print("\nbarTimeMultiplyVal\t\t");
// // Serial.print(barTimeMultiplyVal);

// // Serial.print("\nbarTimePinVal\t\t\t");
// // Serial.print(barTimePinVal);

// Serial.print("\n");

// }  // end of testing serial print commands
// ####################################################################################################
}
