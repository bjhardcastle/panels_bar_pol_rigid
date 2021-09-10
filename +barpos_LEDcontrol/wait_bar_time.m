%% Setup variables
global uno
if ~exist('uno','var')
   barpos_LEDcontrol.init_arduino 
end

writeDigitalPin(uno,bypassOutputPin,0)

disp(['Waiting for cumuluative bar_time to pass ' num2str(bar_time_threshold) 'sec...'])
% bar_time = 0; % seconds
windowFlag = 0;
barpos_LEDcontrol.reset_bar_time
wbtcounter = 0;
clear tS
tS = 0;                
display_counter = 0;
if ~display_counter
    disp('[counter display is off]')
end
while bar_time < bar_time_threshold
        
    barInWindow = readDigitalPin(uno,barInWindowInputPin);
    
    if barInWindow
        if ~windowFlag % bar was previously outside
            % start timer
            tS = tic;
        else
                wbtcounter = wbtcounter+1;
                % add elapsed time to sum
                if exist('tS','var')
            bar_time = bar_time + toc(tS);
                end
                
                if ~mod(wbtcounter,50) && display_counter
                    disp(num2str(bar_time))
                end
                
                % restart timer
                tS = tic;
        end
        
        windowFlag = 1;
    else
        windowFlag = 0;
        if exist('tS','var')
           clearvars tS
        end

    end
%     if bar_time > 0 && ~mod(bar_time,1) %== 0
%         disp(num2str(bar_time))
%     end
end
disp(['bar wait threshold (' num2str(bar_time_threshold) ') passed!'])
% Next: wait for bar position to be within window for x sec, then turn off
% bar/ move it to back and  move to next phase of exp and


