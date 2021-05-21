function init_polarizer(AI,AO,rev)
%% Initialise motor by moving in single steps until Hall sensor input is HIGH
% Two AO channel version, May 2021
if nargin < 3 || isempty(rev)
    rev = 0; % default rotation direction 
end
v = ver;

if str2double( v(1).Date(end-3:end) ) < 2015
    
    
    % For 2p + legacy interface. BJH, June 2017
    
    % Get Hall sensor reading
    start(AI)
    sensor_value = getdata(AI,1);
    
    % Voltage should be close to 0V when sensor at 0deg - keep stepping till
    % this is detected. If starting position is already low then move the motor
    % and check again, to be sure:
    if sensor_value < 2
        TTL = create_pulses(10,rev);
        putdata(AO,TTL);   % Queue pulsetrain
        start(AO)          % Send single step to motor
        wait(AO,2)
    end
    
    % Get Hall sensor reading
    start(AI)
    sensor_value = getdata(AI,1);
    
    % Create single TTL pulse vector
    TTL = create_pulses(1,rev);
    
    while sensor_value > 0.75
        putdata(AO,TTL);   % Queue pulsetrain
        start(AO)          % Send single step to motor
        pause(0.1)
        %     pause(0.1)
        start(AI)             % Get Hall sensor reading
        sensor_value = getdata(AI,1); % Update based on sensor reading.
        fprintf([ num2str(sensor_value) '\n'])
    end
    fprintf(['Sensor readout: ' num2str(sensor_value) '\n'])
    
    
else 
    
        
    % For 2p + Session-based equivalentinterface. BJH, Sep 2018
    
    % Get Hall sensor reading
    sensor_value = inputSingleScan(AI);
    
    % Voltage should be close to 0V when sensor at 0deg - keep stepping till
    % this is detected. If starting position is already low then move the motor
    % and check again, to be sure:
    if abs(sensor_value) < 2
        sendSessionSteps(AO,20,rev);
    end
    
    % Get Hall sensor reading
    sensor_value = inputSingleScan(AI);
    
    while sensor_value > 0.5
        
        sendSessionSteps(AO,1,rev);
        pause(0.1)
        
        % Get Hall sensor reading
        sensor_value = inputSingleScan(AI); % Update based on sensor reading.
        
        fprintf([ num2str(sensor_value) '\n'])
    end
    fprintf(['Sensor readout: ' num2str(sensor_value) '\n'])
    
    

end
end

function TTLpulsetrain = create_pulses(num_steps,rev)
% Two AO chan version
if rev
    revChan = 5;
else
    revChan = 0;
end

step_interval = 0.05; %seconds, for TTL pulse: 0-5V then reset to 0V
Fs = 100;                                % Hz
t = 0 : 1/Fs : num_steps*step_interval;
d = 0 : step_interval : num_steps*step_interval;           % repetition freq
p = [0 5 5 5 ];  % gives a pulse to +5V, then resets to 0V for the rest of step_interval
TTLpulsetrain = pulstran(t,d,p,Fs)';
% Two AO chan version
TTLpulsetrain(2,:) = revChan.*ones(length(TTLpulsetrain));
end

function sendSessionSteps(AO,num_steps,rev)
% Two AO chan version
if rev
    revChan = 5;
else
    revChan = 0;
end
for n = 1:num_steps
    outputSingleScan(AO,[0 revChan])
    pause(0.01)
    outputSingleScan(AO,[5 revChan])
    pause(0.01)
    outputSingleScan(AO,[0 revChan])
    pause(0.01)
end

end
