if ~exist('uno','var')
   barpos_LEDcontrol.init_arduino 
end
writeDigitalPin(uno,resetNanoOutputPin,0) % nano switched OFF
writeDigitalPin(uno,resetNanoOutputPin,1) % nano switched ON
disp('nano reset')