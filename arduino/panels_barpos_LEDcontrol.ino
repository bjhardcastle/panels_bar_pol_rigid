// switch LED on/off depending on bar position on panels
// for use during closed-loop bar tracking 
//
// use thorlabs ledd1b in 'trigger mode': 
// - knob on device sets LED voltage
// - arduino TTL switches on/off

// inputs
int barInputPin = A0; // input from panels, sampled on A0
int barPos = 0;  // store the bar position
int barMidlinePos = 48; // (pixels) adjust according to pattern

//outputs
int LEDOutputPin = 2; // output to LED 
//int LEDon = 255; // (pwm duty cycle) 255 = 100%
//int LEDoff = 0; // (pwm duty cycle) 

void setup() {
  // put your setup code here, to run once:
  pinMode(LEDOutputPin, OUTPUT);  // sets the pin as output
  pinMode(LED_BUILTIN, OUTPUT);  // sets the LED as output for testing
}
void loop() {
  // put your main code here, to run repeatedly:
  
  delay(1);
  
  //read bar position
  barPos = analogRead(barInputPin);
  
  if (barPos == (barMidlinePos*1024/96)-1) {
    digitalWrite(LEDOutputPin, HIGH);
    digitalWrite(LED_BUILTIN, HIGH); // for testing
  }
  else {
    digitalWrite(LEDOutputPin, LOW);
    digitalWrite(LED_BUILTIN, LOW); // for testing
  }
}
