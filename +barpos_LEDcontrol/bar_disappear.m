if ~exist('uno','var')
   barpos_LEDcontrol.init_arduino 
end

digitalWrite(uno,bypassOutputPin,0)

disp(['Waiting for bar to be in window for ' num2str(bar_disappear_fraction*100) '% of previous ' num2str(bar_disappear_threshold) 'sec...'])

bar_time_history = zeros(1,bar_disappear_threshold/bar_disappear_interval); % digital vector keeping track of last X seconds
% wait until bar has been within window for a certain amount of time AND bar is currently in window
windowFlag = 0;
while (sum(bar_time_history) < bar_disappear_fraction*bar_disappear_threshold) && ~windowFlag
    
    t0 = tic;
    
    % discard oldest entry in history and append latest reading 
    bar_time_history = circshift(bar_time_history,1);    
    windowFlag = readDigitalPin(uno,barInWindowInputPin);
    bar_time_history(1) = windowFlag;
    
    if (sum(bar_time_history) >= bar_disappear_fraction*bar_disappear_threshold) && windowFlag
		return
    else
		t1 = toc(t0);
		if t1>bar_disappear_interval
			t1 = 0;
			disp('bar_disappear_interval exceeded (try replacing circshift with bitshift for speed, or vectorize)')
		end
		
		pause(bar_disappear_interval - t1)
    end  
end

barpos_LEDcontrol.manual_OFF
% Next: rotate pol
