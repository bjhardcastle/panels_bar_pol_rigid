if ~exist('uno','var')
   barpos_LEDcontrol.init_arduino 
end
writeDigitalPin(uno,bypassOutputPin,0)
writeDigitalPin(uno,manualONOFFOutputPin,0)
disp('closed-loop control')
