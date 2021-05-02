%% Delete once finished: 
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% tracking amount of time bar has spent in window
bar_time_threshold = 10; % sec

% before it disappears, bar must be within window for _fraction of the last _threshold sec
bar_disappear_fraction = 0.5; %sec
bar_disappear_threshold = 2; %sec

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% set analog input pins
barPosInputPin = 'A0';
configurePin(uno,barPosInputPin,'AnalogInput') % bar pos

barTimeInputPin = 'A1';
configurePin(uno,barTimeInputPin,'AnalogInput') % time (s) bar has spent within window (0-255)

barTimeMultiplyInputPin = 'A2';
configurePin(uno,barTimeMultiplyInputPin,'AnalogInput') % time multiplier

% set analog output pins
LEDVoltageOutputPin = 'A3';
configurePin(uno,LEDVoltageOutputPin,'PWM') % set LED voltage (0-5V => 0-255)

% set digital output pins 
bypassOutputPin = 'D2';
configurePin(uno,bypassOutputPin,'DigitalOutput') % bypass CL barpos>LED control

manualONOFFOutputPin = 'D3';
configurePin(uno,manualONOFFOutputPin,'DigitalOutput') % manual LED control (ON/OFF)

resetBarTimeOutputPin = 'D4';
configurePin(uno,resetBarTimeOutputPin,'DigitalOutput') % reset time

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% above for reference 


reset_bar_time

clc; disp(['Waiting for cumuluative bar_time to pass ' bar_time_threshold 'sec...'])
bar_time = 0; % seconds
while bar_time < bar_time_threshold  
    
    pause(0.1)
    
    get_time % returns bar_time (sec)
    
    if (bar_time - ct) > 0
        disp(num2str(bar_time)) 
        ct = bar_time;
    end
end
    
% Next: wait for bar position to be within window for x sec, then turn off
% bar/ move it to back and  move to next phase of exp and
     
    
