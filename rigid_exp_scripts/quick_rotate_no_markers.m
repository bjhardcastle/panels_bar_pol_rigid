%% initialize polarizer:

import polstim.*   % get package

step_control;
init_polarizer(MCCai,MCCao);

%% With LED on, revolve polarizer n times at t sec per revolution:
steps_per_rev = 48*8; % fixed by hardware, don't change

n_rev = 5;

t_int = 1/6;

idx_rev = 0;
idx_step = 0;
current_pos = 0; % range 0:47, at 0 after initialization
current_deg = 0; 

step_interval = 1/6; %seconds, for TTL pulse: 0-5V then reset to 0V
Fs = 1000;                                % Hz
t = 0 : 1/Fs : steps_per_rev*step_interval;
d = 0 : step_interval : steps_per_rev*step_interval;           % repetition freq
p = [0 5];   % gives a pulse to +5V, then resets to 0V for the rest of step_interval

TTLpulsetrain = pulstran(t,d,p,Fs)';


while idx_rev <= n_rev
    tic
%     deg_target = current_deg + 360/steps_per_rev;
%     [current_pos, current_deg, num_steps] = deg2step(deg_target, current_pos, ao);
                idx_rev = idx_rev+1;
disp(['rev ' num2str(idx_rev)])


   putdata(ao,TTLpulsetrain);   % Queue pulsetrain
    start(ao)
    wait(ao,128)
    
%     pause(t_int);
       
%     idx_step = idx_step+1;
%     if ~mod(idx_step,steps_per_rev)
        toc
        
%     end
end
 
disp('Done. Remember to turn off polarizer control box')