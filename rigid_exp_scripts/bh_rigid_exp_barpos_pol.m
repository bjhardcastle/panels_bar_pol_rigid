function [polState,homeAngle] = bh_rigid_exp_barpos_pol(ao, ai, MCCao, MCCai, polState, parameterSet, expIdx)
global uno
import polstim.*
% import barpos_LEDcontrol.*
% We enter into this function with the NIDAQ NOT logging.
disp(['Experiment ' num2str(expIdx) ' running..'])

% Turn off LED and all markers
try outputSingleScan(ao,[0 0 0 0]), catch, putsample(ao,[0,0,0,0]), end

% Get parameters for this experiment:
pSet = parameterSet(expIdx);

% Make array of angles to be tested:
angleArray = repmat([pSet.polShiftAngleArray],pSet.trialReps,1);

% Randomize within sets - if fly stops flying we at least have complete
% sets of data
if pSet.trialRandomizeOrder
    for rep = 1:pSet.trialReps
        trialIdxArray(rep,:) = randperm(length(pSet.polShiftAngleArray));
        angleArray(rep,:) = angleArray(rep,trialIdxArray(rep,:));
    end
end

% Pause between experiments:
pause(pSet.recPreExpPauseLength)

% Set home angle:
homeAngle = pSet.polHomeAngle; % already randomized before entering this script
[polState.current_step, polState.current_angle] = deg2step(homeAngle, polState.current_step, MCCao);
clc;


disp(['Home angle set: ' num2str(homeAngle) 'deg'])

%Setup panels for positioning fly
barpos_LEDcontrol.init_arduino
barpos_LEDcontrol.reset_nano
barpos_LEDcontrol.manual_OFF
Panel_com('set_pattern_id', pSet.patBar) %
pause(0.01)
Panel_com('set_position',[pSet.barFrontalPos ,pSet.patYposBarON]); %set starting position (xpos,ypos)
pause(0.01)
Panel_com('set_mode',[1,0]);
pause(0.01)
Panel_com('send_gain_bias',[0,0,0,0]);       %[xgain,xoffset,ygain,yoffset]
pause(0.01)
Panel_com('start')
pause(0.01)

disp('Switch step controller OFF');
% Turn on LED, closed-loop bar control then confirm when set up:
key_command = 's';
while ~strcmp(key_command,'c')
    key_command = input('Load fly and finetune position, then make choice:\n c: continue \n s: static bar \n m: closed-loop bar \n','s');
    switch key_command
        case 'c'
            Panel_com('stop')
            pause(0.01)
            Panel_com('send_gain_bias',[pSet.patXgain,0,0,0]);       %[xgain,xoffset,ygain,yoffset]
            pause(0.01)
            Panel_com('start')
            pause(0.01)
            continue
        case 's'
            Panel_com('stop')
            pause(0.01)
            Panel_com('set_position',[pSet.barFrontalPos ,pSet.patYposBarON]); %set starting position (xpos,ypos)
            pause(0.01)
            Panel_com('send_gain_bias',[0,0,0,0]);       %[xgain,xoffset,ygain,yoffset]
            pause(0.01)
            Panel_com('start')
            pause(0.01)
        case 'm'
            Panel_com('stop')
            pause(0.01)
            Panel_com('send_gain_bias',[pSet.patXgain,0,0,0]);       %[xgain,xoffset,ygain,yoffset]
            pause(0.01)
            Panel_com('start')
            pause(0.01)

        otherwise
            disp('enter c/s/m only')
    end
end

[~] = input('Switch POL step-controller ON and hit any key:  ');

% Panel_com('stop')
% pause(0.01)
% Panel_com('all_off')
% pause(0.01)

% [~] = input('Switch POL step-controller ON, then hit any key:  ');

% Expose at home position for some amount of time
if pSet.prePolExposeDuration > 0
    
    Panel_com('stop')
    pause(0.01)
    Panel_com('set_position',[pSet.barFrontalPos ,pSet.patYposBarON]); %set starting position (xpos,ypos)
    pause(0.01)

    barpos_LEDcontrol.reset_nano
    barpos_LEDcontrol.manual_OFF
    
    disp(['pre-exposure for ' num2str(pSet.prePolExposeDuration) 's'])
    [~] = input('Switch POL LED ON, then hit any key:  ');
    
    disp('bar position fixed, frontal. POL on')
    
    for pidx = 1:4
        pause(floor(pSet.prePolExposeDuration/4))
        disp([num2str(pidx*floor(pSet.prePolExposeDuration/4)) 's'])
    end
    pause(mod(pSet.prePolExposeDuration,4))
end

% Restore CL bar tracking
barpos_LEDcontrol.restore_control
Panel_com('start')
pause(0.01)

disp('Experiment start')
% Panel_com('set_pattern_id', pSet.patBar)
% pause(0.01)
% Panel_com('set_position',[pSet.patXposBarStart,pSet.patYposBarON]); %set starting position (xpos,ypos)
% pause(0.01)
% Panel_com('start')
% pause(0.01)

% Exp starts:
% Start DAQ recording
try startBackground(ai), catch, start(ai), end
try outputSingleScan(ao,[0 0 0 0]), catch, putsample(ao,[0 0 0 0]), end

% Write markers to DAQ output
mark_angle = abs(polState.current_angle*5/360);
mark_angle_sign = sign(polState.current_angle) + 2; % = 1,2,or3
mark_trial = 0;
mark_CL =0;
try outputSingleScan(ao,[mark_trial,mark_CL,mark_angle,mark_angle_sign]), catch, putsample(ao,[mark_trial,mark_spare,mark_angle,mark_angle_sign]), end

clc;disp('DAQ started')
% pause(0.7)
% clc;disp('DAQ starting.')
% pause(0.7)
% clc;disp('DAQ starting..')
% pause(0.7)
% clc;disp('DAQ starting...')


% pSet.trialDuringRotateLEDON
% pSet.trialPauseAfterRotate


for rIdx = 1:pSet.trialReps
    if pSet.preTrialSetBarWait
        % Wait until bar+pol have been presented for certain amount of time
        bar_time_threshold = pSet.preExpFrontBarThreshold;
        barpos_LEDcontrol.wait_bar_time
    end
    
    %     if rIdx>0.5*pSet.trialReps
    %         pSet.trialDuringRotateLEDON = 1;
    %     end
    
    % Display trial/set info
    disp(['Set ' num2str(rIdx) '/' num2str(pSet.trialReps)])
    
    for tIdx = 1:size(angleArray,2)
        
        % %Wait some additional time
        %         pause(randi(10))
        % %Wait until bar+pol have been presented for certain amount of time
        %         barpos_LEDcontrol.wait_bar_time
        barpos_LEDcontrol.reset_bar_time
        bar_time_threshold = pSet.interTrialBarThreshold;
        barpos_LEDcontrol.wait_bar_time
        
        % Wait for bar to be within frontal window, then disappear
        barpos_LEDcontrol.bar_disappear
        if ~pSet.trialDuringRotateLEDON
            % pol disappears
            barpos_LEDcontrol.manual_OFF
        else
            % or stays on during rotation
            barpos_LEDcontrol.manual_ON
        end
        % Bar disappears
        mark_trial = 0;
        mark_CL = 1;
        try outputSingleScan(ao,[mark_trial,mark_CL,mark_angle,mark_angle_sign]), catch, putsample(ao,[mark_trial,mark_CL,mark_angle,mark_angle_sign]), end
        Panel_com('stop')
        pause(0.01)
        Panel_com('set_position',[pSet.patXposBarStart,pSet.patYposBarOFF]);
        pause(0.01)
        Panel_com('set_mode',[0,0]);
        pause(0.01)
        Panel_com('start')
        pause(0.01)
        startTime = tic;

        
        %Rotate pol
        % Display trial/set info
        polAngle = angleArray(rIdx,tIdx);
        disp('------------------------------------------------')
        disp(['Set ' num2str(rIdx) '/' num2str(pSet.trialReps) ', Trial ' num2str(tIdx) ': rotating ' num2str(polAngle) 'deg'])
        disp('------------------------------------------------')
        [polState.current_step, polState.current_angle] = deg2step(homeAngle+polAngle, polState.current_step, MCCao);

        % Give the motor time to rotate
        polTime = toc(startTime);
        if pSet.trialPauseAfterBarDisappear >= polTime 
            pause(pSet.trialPauseAfterBarDisappear - polTime)
        else
            disp(['motor rotation longer than pSet.trialPauseAfterBarDisappear (' num2str(pSet.trialPauseAfterBarDisappear) 's)'])
        end
        
        % Record trial
        mark_angle = abs(polAngle*5/360); % relative to home
        mark_angle_sign = sign(polAngle) + 2; % = 1,2,or3
        mark_trial = trialIdxArray(rIdx,tIdx)*5/20;
        mark_CL = 1;
        try outputSingleScan(ao,[mark_trial,mark_CL,mark_angle,mark_angle_sign]), catch, putsample(ao,[mark_trial,mark_CL,mark_angle,mark_angle_sign]), end
        
        barpos_LEDcontrol.manual_ON
        pause(pSet.trialTestPauseLength)
        
        % Mark end of trial
        mark_trial = 0;
        try outputSingleScan(ao,[mark_trial mark_CL mark_angle mark_angle_sign]), catch, putsample(ao,[mark_trial mark_CL mark_angle mark_angle_sign]), end
        
        %Rotate back to homeAngle
        if ~pSet.trialDuringRotateLEDON
            % pol disappears
            barpos_LEDcontrol.manual_OFF
        else
            % or stays on during rotation
            barpos_LEDcontrol.manual_ON
        end
        
        startTime = tic;
        [polState.current_step, polState.current_angle] = deg2step(homeAngle, polState.current_step, MCCao);
        disp(['Returned to home angle: ' num2str(homeAngle) 'deg'])
        polTime = toc(startTime);
        if pSet.trialPauseAfterBarDisappear >= polTime
            pause(pSet.trialPauseAfterBarDisappear - polTime)
        else
            disp(['motor rotation longer than pSet.trialPauseAfterBarDisappear (' num2str(pSet.trialPauseAfterBarDisappear) 's)'])
        end
 
        % Give the motor time to rotate
        %pause(pSet.trialPauseAfterRotate)
        
        % Restore CL bar tracking
        barpos_LEDcontrol.restore_control
        Panel_com('stop')
        pause(0.01)
        Panel_com('set_position',[pSet.barFrontalPos,pSet.patYposBarON]); %set starting position (xpos,ypos)
        pause(0.01)
        Panel_com('set_mode',[1,0]);
        pause(0.01)
        Panel_com('send_gain_bias',[pSet.patXgain,0,0,0]);       %[xgain,xoffset,ygain,yoffset]
        pause(0.01)
        Panel_com('start')
        pause(0.01)
        
        % Record markers
        mark_angle = abs(0*5/360);
        mark_angle_sign = sign(0) + 2; % = 1,2,or3
        mark_trial = 0;
        mark_CL = 0;
        try outputSingleScan(ao,[mark_trial,mark_CL,mark_angle,mark_angle_sign]), catch, putsample(ao,[mark_trial,mark_CL,mark_angle,mark_angle_sign]), end
        
    end
end

Panel_com('stop')
pause(0.01)
Panel_com('set_position',[pSet.patXposBarStart,pSet.patYposBarOFF]);
pause(0.01)
Panel_com('set_mode',[0,0]);
pause(0.01)
Panel_com('all_off')
pause(0.01)     
           
barpos_LEDcontrol.manual_OFF

pause(pSet.recPostExpPauseLength)
