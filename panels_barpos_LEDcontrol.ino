// switch LED on/off depending on bar position on panels
// for use during closed-loop bar tracking 
//
// use thorlabs ledd1b in 'trigger mode': 
// - knob on device sets LED voltage
// - arduino TTL switches on/off

// inputs
int barInputPin = A0; // input from panels, sampled on A0
int barPinVal = 0; // raw input val (0-1023)
int barPos = 0;  // store the bar position (in pixels)
int barMidlinePos = 49; // (pixels) adjust according to pattern
int bypassInputPin = A2; // input from another TTL source to bypass LED gating and switch LED on
int bypassPinVal = 0; // raw input val (0-1023): 2.5V toggle threshold
int bypassToggle = 0; // stored value, 0 or 1
int LEDToggleRange = 2; // (+/-pixels) half-width of window in which LED will be on

//outputs
int LEDOutputPin = 2; // output to LED 
//int LEDon = 255; // (pwm duty cycle) 255 = 100%
//int LEDoff = 0; // (pwm duty cycle) 

void setup() {
  // put your setup code here, to run once:
  pinMode(LEDOutputPin, OUTPUT);  // sets the pin as output
  pinMode(LED_BUILTIN, OUTPUT);  // sets the LED as output for testing
  //Serial.begin(9600); // for testing
}
void loop() {
  // put your main code here, to run repeatedly:
  
  delay(1);

  //read bypass input (0-1023 <=> 0-5V)
  bypassPinVal = analogRead(bypassInputPin);
  //Serial.println(bypassPinVal); //for testing 
  if (bypassPinVal >= 511) { // 2.5V toggle threshold
     bypassToggle = 1;
  }
  else {
      bypassToggle = 0;
  }
      
  //read bar position (0-1023 <=> 0-5V <=> 1-96pix (for pattern with 96 x-positions
  barPinVal = analogRead(barInputPin);
  barPos = ceil((barPinVal*0.0938)); // *96/1024
  // Serial.println(barPinVal); //for testing 
  //Serial.println(barPos); //for testing 

  if ( ((barPos >= (barMidlinePos-LEDToggleRange)) && (barPos <= (barMidlinePos+LEDToggleRange)) ) || (bypassToggle == 1) ) { // bar is within window, or bypass enabled
    digitalWrite(LEDOutputPin, HIGH);
    digitalWrite(LED_BUILTIN, HIGH); // for testing
    // Serial.println("ON"); //for testing 
  }
  else {
    digitalWrite(LEDOutputPin, LOW);
    digitalWrite(LED_BUILTIN, LOW); // for testing
    // Serial.println("OFF"); //for testing 
  }
}
