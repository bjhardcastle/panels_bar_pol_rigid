function bh_rigid_exp_barpos_pol(ao, MCCao, MCCai, polState, parameterSet, expIdx)
import polstim.*
import barpos_LEDcontrol.*
% We enter into this function with Slidebook already running and the NIDAQ
% logging. All that's left is to setup the trials and execute:
disp(['Experiment ' num2str(expIdx) ' running..'])

% Get parameters for this experiment:
pSet = parameterSet(expIdx);

% Pause between experiments:
pause(pSet.recPreExpPauseLength)

%Setup panels
Panel_com('set_pattern_id', pSet.patIdxArray) % First frame of Pattern #1 is mean luminance blank screen
pause(0.01)
Panel_com('all_off')
pause(0.01)
Panel_com('set_mode',[0,0]);
pause(0.01)
Panel_com('set_velfunc_id',[1 0]);
pause(0.01)
Panel_com('set_velfunc_id',[2 0]);
pause(0.01)

for rIdx = 1:pSet.trialReps
    % Display trial/set info
    disp(['Set ' num2str(rIdx) '/' num2str(pSet.trialReps)])
    
    for tIdx = 1:size(pSet.patYposArray,2) % experimental positions only
        
        % Display trial/set info
        disp(['Position ' num2str(tIdx) '/' num2str(size(pSet.patYposArray,2))])
        
        trialYpos = pSet.patYposArray(tIdx);
        mark_ypos = trialYpos/5;
        mark_exp = expIdx/5;
        
        % Set pattern, send new DAQ info
        
        Panel_com('set_position',[1,trialYpos])
        pause(0.01)
        Panel_com('send_gain_bias',[pSet.patXgain,0,0,0])
        pause(0.01)
        try outputSingleScan(ao,[mark_ypos,mark_exp,0,0]), catch, putsample(ao,[mark_ypos,mark_exp,0,0]), end
        pause(pSet.trialStaticPauseLength)
        
        Panel_com('start')
        pause(pSet.trialMotionPauseLength)
        
        % Mark end of trial, then turn off screen
        try outputSingleScan(ao,[0 0 0 0]), catch, putsample(ao,[0 0 0 0]), end
        Panel_com('stop')
        pause(0.01)
        Panel_com('all_off')
        pause(pSet.trialBaselinePauseLength)
        
    end
end

Panel_com('all_off')
pause(0.01)

pause(pSet.recPostExpPauseLength)
