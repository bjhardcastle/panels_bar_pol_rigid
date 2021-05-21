% simple closed-loop bar exp (modified from  for Sam_bar_grating_Exp1 from
% September 2018)                   ben feb 2021 
% a period of closed-loop bar-tracking, then all LEDs turned off 
% 
% LED (+marker on axoboard): MCC Board 0, ao0
% motor, Hall sensor: MCC Board 1+2

clc, clear

%--------------------------------------------------------------------------
%PATTERNS
%{
Currently:
  1. Pattern_zSimple-Bar_on_X-Dark-2D
%}
%--------------------------------------------------------------------------

% PARAMETERS FOR TWEAKING
gain_bartrack       = -5;      % Gain (10x PControl value) for closed-loop bar tracking
time_bartrack       = 20;        % seconds
n_reps              = 1;        % number of repetitions of all EXPERIMENTS (length(w_trials)=length(w_exps)*n_reps)
%--------------------------------------------------------------------------

%GENERAL PARAMETERS
xpos_bartrack       = 41;        % starting position of bar during closed-loop tracking
ypos_bartrack       = 1;         % 
npause              = 0.001;     % pause between Panel_com commands, necessary to prevent crashes!
pat_bartrack        = 2;         % Before and after the trials, engage the fly in bar tracking using this pattern index
%--------------------------------------------------------------------------

% old, unused
pause_between       = 5;        % seconds, pause between disappearing and start of grating motion
gain_grating        = [35,70];  % Gain (10x PControl value) applied to grating (can be array with multiple values - each will be applied in separate trials)
time_grating        = 5;        % seconds
xpos_grating        = [1:6];     % orientation of grating 
ypos_grating        = 1;         % starting position of grating before motion
w_pats              = [1];       % indices of patterns on CF card
n_rev               = [1,-1];    % directions: each pattern is run once forwards & once in reverse

%--------------------------------------------------------------------------
% INITIAL CLOSED-LOOP BAR-TRACKING

Panel_com('set_pattern_id',pat_bartrack);
pause(npause)
Panel_com('set_position',[xpos_bartrack,ypos_bartrack]); %set starting position (xpos,ypos)
pause(npause)
Panel_com('set_mode',[1,0]);                   %closed loop tracking [xpos,ypos] (NOTE: 0=open, 1=closed)
pause(npause)
Panel_com('send_gain_bias',[gain_bartrack,0,0,0]);       %[xgain,xoffset,ygain,yoffset]
pause(npause)
Panel_com('start')
fprintf('* Bar-tracking for 15s *\nMake sure Axoscope is ready awaiting external START\n')
input('Hit any key when ready...  ');

%--------------------------------------------------------------------------

% Setup DAQ for output to Axoscope
ao = analogoutput('mcc',0);
chans=addchannel(ao,0:1);
set(ao,'SampleRate',100);               %100 Hz output

%--------------------------------------------------------------------------

% Axoscope software should be running and awaiting external trigger: send
% now to start logging data
trigger_signal = [ones(50,1)*4;zeros(100,1)];   % trigger_signal = 0.5 secs at 4V, then back to 0V for 1 sec
dummy_signal = trigger_signal.*0;               % must send a signal to each channel
putdata(ao,[dummy_signal trigger_signal]);      % load the data to the DAQ
start(ao);                                      % start the DAQ to send the trigger signal
wait(ao,5);                                     % wait for it to complete
stop(ao);                                       % stop the analog output device (must be stopped to load new data). Voltage remains at current value (0V) until next 'start(ao)' command

%--------------------------------------------------------------------------
% EXPERIMENT TRIALS

% Loop through all trials
for i = 1:n_reps

    % Get parameters for current trial
    n_pat       = w_trials(i,1);
    n_start_x   = w_trials(i,2);
    n_start_y   = w_trials(i,3);
    n_direct    = w_trials(i,4);
    n_speed     = w_trials(i,5);

    % Display info about current trial
    fprintf([num2str(i) '/' num2str(length(w_trials)) ': gain ' num2str(n_direct*n_speed) ', ' num2str((n_start_x-1)*30) 'deg\n']);                             %prints counter to command line

    %----------------------------------------------------------------------

    %CLOSED-LOOP BAR-TRACKING
    % Setup panels:
    Panel_com('stop');
    pause(npause)
    Panel_com('set_pattern_id',pat_bartrack);
    pause(npause)
    Panel_com('set_position',[xpos_bartrack,ypos_bartrack]); %set starting position (xpos,ypos)
    pause(npause)
    Panel_com('set_mode',[1,0]);                   %closed loop tracking [xpos,ypos] (NOTE: 0=open, 1=closed)
    pause(npause)
    Panel_com('send_gain_bias',[gain_bartrack,0,0,0]);       %[xgain,xoffset,ygain,yoffset]
    pause(npause)
    % Go:
    Panel_com('start');
    pause(time_bartrack);

    %----------------------------------------------------------------------
    % Setup pattern and gain markers for this trial
    % - markers are zero during bar-tracking
    % - new markers are sent at end of bar-tracking/start of grating motion
    % - must be within range -5:5 V

    mark_orientation = ones(50,1)*n_start_x/2;              % pattern x position = ao(0)*2
    mark_gain = ones(50,1)*5*n_speed/100;           % gain = ao(1)*100/5

    % Send markers
    stop(ao)                                       % Stops analog output device, but voltage remains at current voltage until next 'start(ao)' command
    putdata(ao,[mark_orientation mark_gain]);

    %----------------------------------------------------------------------

    %GRATING MOTION
    % Setup panels
    Panel_com('stop')
    pause(npause)
    Panel_com('set_pattern_id',n_pat);
    pause(npause)
    Panel_com('set_position',[n_start_x, ypos_grating])
    pause(npause)
    Panel_com('set_mode',[0 0])
    pause(npause)
    Panel_com('send_gain_bias', [0,0,n_speed*n_direct,0]);
    pause(npause)

    % Pause for a moment
    pause(pause_between)    % pause between bar disappearing and start of grating motion

    % Go
    start(ao)                      % starts analog output with new markers
    pause(0.1)
    Panel_com('start')
    pause(time_grating)

    %----------------------------------------------------------------------

    % Stop panels and set markers to 0 to prepare for next trial
    Panel_com('stop')
    pause(npause)
    stop(ao)
    putdata(ao,[mark_orientation*0 mark_gain*0]);                   
    start(ao)

end

%--------------------------------------------------------------------------
% END OF EXPERIMENT
% Send an audible cue
% beep(660,1,0.2)
load sup
sound(data2,fs)
fprintf('Done\r');
Panel_com('stop');
pause(npause)

% Start closed-loop bar-tracking again and leave running
Panel_com('set_pattern_id',pat_bartrack);
pause(npause)
Panel_com('set_position',[xpos_bartrack,ypos_bartrack]); %set starting position (xpos,ypos)
pause(npause)
Panel_com('set_mode',[1,0]);                   %closed loop tracking [xpos,ypos] (NOTE: 0=open, 1=closed)
pause(npause)
Panel_com('send_gain_bias',[gain_bartrack,0,0,0]);       %[xgain,xoffset,ygain,yoffset]
pause(npause)
Panel_com('start')
