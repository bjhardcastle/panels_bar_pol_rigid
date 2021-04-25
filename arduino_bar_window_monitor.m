bar_time_threshold = 10; % sec

try 
    % connect to arduino
    uno = arduino('COM4', 'Uno');
    
    % set analog input pin
    configurePin(uno,'A0','AnalogInput')
    
catch ME
    % arduino connection may already exist, which causes error. 
    % If it has the variable name we want we can igore it:
    if strcmp(ME.identifier, 'MATLAB:hwsdk:general:connectionExists')
        assert(exist('uno','var'),'Naming conflict: Arduino object should be removed or renamed')
    else
        rethrow(ME);
    end
end
    
% variables to track amount of time bar has spent in window
time_volt_init = readVoltage(uno,'A0'); %initial voltage reading
bar_time = 0; % seconds

clc; disp(['Waiting for cumuluative bar_time to pass ' bar_time_threshold 'sec...'])
ct = 0;
while bar_time < bar_time_threshold  
    
    pause(1)
    
    % read voltage (5V/1023 = 1 sec)
    time_volt = readVoltage(uno,'A0');
    
    % find time elapsed 
    bar_time = floor((time_volt - time_volt_init)/1023);
    
    %disp(['bar_time:' num2str(bar_time)])
    if (bar_time - ct) > 0
        disp(num2str(bar_time)) 
        ct = bar_time;
    end
end
    
% Next: wait for bar position to be within window for x sec, then turn off
% bar/ move it to back and  move to next phase of exp and
     
    
