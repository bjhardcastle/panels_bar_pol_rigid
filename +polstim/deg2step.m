function [updated_pos, deg_actual, num_steps] = deg2step(deg_target, current_pos, AO)
%% Converts desired step motor angle (in degrees) into the required steps for motor
% Actuates number of steps to bring motor as close as possible to the target angle.
% Requires current motor position. 
% Updated for meeseeks rigid exps, two AO channels. May 2021

% ASSUMPTIONS: - 48 steps per revolution (7.5 deg per step) by default
%                                (microstepping up to 1/8th also possible)
%              - current_pos in range 0:47
%              - motor was initialised to 0deg && current_pos set to 0
micro_steps = 1; % EasyDriver board can microstep [1/2, 1/4, 1/8]th steps. 
                 % 1 = full steps, 48 steps per revolution

% Calculate steps required from current motor position:
total_steps = 48/micro_steps; % Steps in full 360 rotation
step_resolution = 360/total_steps;
req_steps = mod([round(deg_target/step_resolution) - current_pos], total_steps); % 3.75 deg / step
if req_steps > total_steps*0.5
    rev = 1;
    num_steps = total_steps - req_steps;
else
    rev = 0;
    num_steps = req_steps;
end

% In case daq objct was left running:
% stop(AO)

if num_steps ~= 0 
    
    v = ver;
    
    if str2double( v(1).Date(end-3:end) ) < 2015
        % Legacy code

    TTL = create_pulses(num_steps,rev);    
    
    % Send steps to motor:
    putdata(AO,TTL);   % Queue pulsetrain
    start(AO)
    wait(AO,5)
    
    else % Session-based code
        
        sendSessionSteps(AO,num_steps,rev)
        
    end
        
end

updated_pos = mod([current_pos + req_steps], total_steps); % steps

deg_actual = updated_pos * step_resolution; % degrees 
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
p = [0 5];   % gives a pulse to +5V, then resets to 0V for the rest of step_interval
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
%     outputSingleScan(AO,[0 revChan])
%     pause(0.01)
    outputSingleScan(AO,[5 revChan])
    pause(0.02)
    outputSingleScan(AO,[0 revChan])
    pause(0.01)
end

end