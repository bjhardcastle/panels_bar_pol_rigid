
% read voltage (0-255 sent => 0-1023 = 0-255 sec)
time_volt = readVoltage(uno,barTimeInputPin);
time_sec = time_volt*255/5;

% read voltage (1023 = 1 sec)
time_multiply_volt = readVoltage(uno,barTimeMultiplyInputPin);
time_multiply = floor(time_multiply_volt*255/5);

if time_multiply < 1
    time_multiply = 1;
end

% find time elapsed
bar_time = time_multiply*255 + time_sec;

time_multiply_volt
time_volt