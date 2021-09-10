global uno
if ~exist('uno','var')
   barpos_LEDcontrol.init_arduino 
end
writeDigitalPin(uno,bypassOutputPin,1)
writeDigitalPin(uno,manualONOFFOutputPin,1)
disp('manual LED ON')
