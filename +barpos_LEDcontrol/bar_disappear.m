
digitalWrite(uno,bypassOutputPin,0)

disp(['Waiting for bar to be in window for ' num2str(bar_disappear_fraction*100) '% of previous ' num2str(bar_disappear_threshold) 'sec...'])

bar_time_history = zeros(1,bar_disappear_threshold/bar_disappear_interval); % digital vector keeping track of last X seconds
while sum(bar_time_history) < bar_disappear_fraction*bar_disappear_threshold
    
    pause(bar_disappear_interval)
    
    % discard oldest entry in history and append latest reading 
    bar_time_history = circshift(bar_time_history,1);    

    bar_time_history(1) = digitalRead(uno,barInWindowInputPin);=
    
end

% Next: manual off, rotate pol
