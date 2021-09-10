global uno
if ~exist('uno','var')
   barpos_LEDcontrol.init_arduino 
end

writeDigitalPin(uno,bypassOutputPin,0)

disp(['Waiting for bar to be in window for ' num2str(bar_disappear_fraction*100) '% of previous ' num2str(bar_disappear_threshold) 'sec...'])

bar_time_history_threshold = bar_disappear_fraction*bar_disappear_threshold/bar_disappear_interval;
bar_time_history = zeros(1,bar_disappear_threshold/bar_disappear_interval); % digital vector keeping track of last X seconds
% wait until bar has been within window for a certain amount of time AND bar is currently in window
windowFlag = 0;
wbtcounter = 1;
recent_bar_time = 0;
display_counter = 0;
if ~display_counter
    disp('[counter display is off]')
end

while wbtcounter>0
    
    t0 = tic;
    
    % discard oldest entry in history and append latest reading 
    bar_time_history = circshift(bar_time_history,1);    
    windowFlag = readDigitalPin(uno,barInWindowInputPin);
    bar_time_history(1) = windowFlag;
    wbtcounter = wbtcounter+1;
    if ~mod(wbtcounter,50) && display_counter
        disp(num2str(sum(bar_time_history)*bar_disappear_interval))
    end

    if (sum(bar_time_history) >= bar_time_history_threshold) && windowFlag
        disp(['bar disappear threshold (' num2str(bar_disappear_threshold) ') passed!'])
        wbtcounter = 0;
    else
		 t1 = toc(t0);
		if t1>bar_disappear_interval
			t1 = 0;
			disp('bar_disappear_interval exceeded (try replacing circshift with bitshift for speed, or vectorize)')
		end
		
		pause(bar_disappear_interval - t1)
    end  
end
% disp(['turning off pol bar...'])
% barpos_LEDcontrol.manual_OFF
% Next: rotate pol
