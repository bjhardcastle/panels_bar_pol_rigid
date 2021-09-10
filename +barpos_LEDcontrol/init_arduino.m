%% Setup variables 
global uno

% if ~exist('pSet') || ~isfield(pSet,'bar_time_threshold')
    
% tracking amount of time bar has spent in window
bar_time_threshold = 30; % sec

% before it disappears, bar must be within window for _fraction of the last _threshold sec
bar_disappear_fraction = 0.9; 
bar_disappear_threshold = 2; %sec
bar_disappear_interval = 0.1; %sec

% % voltages to send to LED driver (MOD mode: 0-5V => 0-100%)
% LED_voltage_ON = 5; % V
% LED_voltage_OFF = 0; % V
% note- LED voltage now hard-coded in nano

% startup conditions: 
% bypass zero = LED gated by window, in CL with bar position
% bypass one = LED is controlled by manual toggle once connection is established Matlab->arduino
bypass_toggle = 0;
manual_ONOFF_toggle = 0;

%% Establish connection to arduino
try 
    % connect to arduino
    uno = arduino('COM4', 'Uno');
catch ME
    % arduino connection may already exist, which causes error. 
    % If it has the variable name we want we can igore it:
    if strcmp(ME.identifier, 'MATLAB:hwsdk:general:connectionExists')
        assert(exist('uno','var'),'Naming conflict: Arduino object should be removed or renamed')
    else
        rethrow(ME);
    end
end

%% Setup i/o

% set analog input pins
% barPosInputPin = 'A0';
% configurePin(uno,barPosInputPin,'AnalogInput') % bar pos
% 
% % removed - time now calculated in matlab
% barTimeInputPin = 'A1';
% configurePin(uno,barTimeInputPin,'AnalogInput') % time (s) bar has spent within window (0-255)

% barTimeMultiplyInputPin = 'A3';
% configurePin(uno,barTimeMultiplyInputPin,'AnalogInput') % time multiplier

% set analog output pins. Valid PWM pin numbers for board Uno are "D3", "D5-D6", "D9-D11".
% LEDVoltageOutputPin = 'A3';
% configurePin(uno,LEDVoltageOutputPin,'AnalogOutput') % set LED voltage (0-5V => 0-255)
% LEDVoltageOutputPin = 'D11'; % solder to D11(uno)/A7(nano)
% configurePin(uno,LEDVoltageOutputPin,'PWM') % set LED voltage (0-5V => 0-255)

% set digital output pins 
bypassOutputPin = 'D2';
configurePin(uno,bypassOutputPin,'DigitalOutput') % bypass CL barpos>LED control

manualONOFFOutputPin = 'D3';
configurePin(uno,manualONOFFOutputPin,'DigitalOutput') % manual LED control (ON/OFF)

barInWindowInputPin = 'D4';
configurePin(uno,barInWindowInputPin,'DigitalInput') % reset time

resetNanoOutputPin = 'D12';% solder to D8(uno)/RST(nano)
configurePin(uno,resetNanoOutputPin,'DigitalOutput') % reset time

barpos_LEDcontrol.reset_nano
barpos_LEDcontrol.restore_control
barpos_LEDcontrol.reset_bar_time
