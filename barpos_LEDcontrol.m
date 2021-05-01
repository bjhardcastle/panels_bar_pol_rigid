function barpos_LEDcontrol(arduinoObj)%,pSet)
% // switch LED on/off depending on bar position on panels
% // for use during closed-loop bar tracking
% //
% // use thorlabs ledd1b in 'trigger mode':
% // - knob on device sets LED voltage
% // - arduino TTL switches on/off
%
barInputPin = 'A0';
LEDOutputPin = 'D3';
barMidlinePos = 49; % (pixels) adjust according to pattern
LEDToggleRange = 2; % (+/-pixels) half-width of window in which LED will be on

LEDOutputVoltage = 5; % Volts

windowFlag = 0;
barTimeSum = 0;
barTimeThreshold = 10;
while barTimeSum <= barTimeThreshold
    barPinVal = readVoltage(arduinoObj,barInputPin);
    barPos = ceil((barPinVal*96/1023)); % *96/1024
    
    if ((barPos >= (barMidlinePos-LEDToggleRange)) && (barPos <= (barMidlinePos+LEDToggleRange)) )%% bar is within window
        writePWMVoltage(arduinoObj,LEDOutputPin,LEDOutputVoltage)
        % writeDigitalPin(arduinoObj,LEDOutputPin,1)
        
        if ~windowFlag % bar was previously outside
            % start timer
            tStart = tic;
        else
            % add elapsed time to sum
            barTimeSum = barTimeSum + toc(tStart);
            % restart timer
            tStart = tic;
        end
        windowFlag = 1;
        
    else % bar is outside window
        
        writePWMVoltage(arduinoObj,LEDOutputPin,0)
        % writeDigitalPin(arduinoObj,LEDOutputPin,0)
        
        windowFlag = 0;
    end
end
