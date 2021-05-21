%% Setup variables
% variables to track amount of time bar has spent in window
if ~exist('uno','var')
   barpos_LEDcontrol.init_arduino 
end

digitalWrite(uno,bypassOutputPin,0)

disp(['Waiting for cumuluative bar_time to pass ' num2str(bar_time_threshold) 'sec...'])
% bar_time = 0; % seconds
barWindowFlag = 0;
while bar_time < bar_time_threshold
        
    barInWindow = readDigitalPin(uno,barInWindowInputPin);
    
    if barInWindow
        if ~windowFlag % bar was previously outside
            % start timer
            tStart = tic;
        else
            % add elapsed time to sum
            bar_time = bar_time + toc(tStart);
            % restart timer
            tStart = tic;
        end
        windowFlag = 1;
    end
    
    if ~mod(bar_time,1) %== 0
        disp(num2str(bar_time))
    end
end

% Next: wait for bar position to be within window for x sec, then turn off
% bar/ move it to back and  move to next phase of exp and


