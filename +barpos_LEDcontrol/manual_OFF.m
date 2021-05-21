if ~exist('uno','var')
   barpos_LEDcontrol.init_arduino 
end
writeDigitalPin(uno,manualONOFFOutputPin,0)
writeDigitalPin(uno,bypassOutputPin,1)
disp('manual LED OFF')
