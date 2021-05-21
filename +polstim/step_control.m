%%% Setup MCC DAQ for use with polarizer control box.
% For rigid exps on meeseeks + session-based interface. BJH, May 2021
% -------------------------------------------------------------------------
% Limitations of MCC boards on older versions of MATLAB (2011) mean
% simultaneous AI / AO functions are impossible so we make use of 2 boards
%
% WIRING:
% MCC USB1208FS for sensor readings - with legacy DAQ control
%       AI 0 (board ports 1,3)  - Hall sensor Vout (-10 -> +10V)
%
% MCC USB1208LS for step motor control - with legacy DAQ control
%       AO 0 (board ports 13,14) - motor step signal (0->5V)
%       AO 0 (board ports 13,14) - motor direction signal (0->5V)
%
% Example use:
%
% % Initialise motor by moving to zero position
% init_polarizer(MCCai,MCCao);
%
%
%  current_step = 0;      % Polarizer is at 0 degrees orientation. This variable keeps track.
%                         % range: 0:95 for ST-PM35-15 step motor with
%                         % microstepping: half step
% % Use deg2step_2p function to set motor to desired angle:
% % n=1;
% % current_angle=0;
% % [current_step,current_angle,steps_made] = deg2step_2p(current_angle + 90, current_step, MCCao);
%
% -------------------------------------------------------------------------
v = ver;

if str2double( v(1).Date(end-3:end) ) < 2015
    
    % Setup MCC DAQ (legacy)
    mccinfo = daqhwinfo('mcc');
    boardIDs = strcat(mccinfo.BoardNames, ' (devid: ', mccinfo.InstalledBoardIds, ')')';
    deviceid = mccinfo.InstalledBoardIds;
    MCCadapter = 'mcc';
    
    % Board 0: LS
    % AO 0: Output channel for motor control
    MCCao = analogoutput(MCCadapter,deviceid{1});
    addchannel(MCCao,0);              % Single channel
    MCCao.SampleRate = 100;           %100 Hz output
    MCCao.TriggerType = 'Immediate';
    
    % Board 1: FS
    % AI O: Input channel for Hall sensor (goes to HIGH when polarizer is at 0deg)
    MCCai = analoginput(MCCadapter,deviceid{2});
    addchannel(MCCai,0);              % Single channel
    MCCai.SampleRate = 100;           %100 Hz sampling
    MCCai.SamplesPerTrigger = 1;
    
    
else
    
    % Setup MCC DAQ (session-based)
    
    % Board 0: LS
    % AO 0: Output channel for motor control
    MCCao=daq.createSession('mcc');
    warning off daq:Session:onDemandOnlyChannelsAdded
    addAnalogOutputChannel(MCCao,'Board0',0,'Voltage'); % Board0 on meeseeks/rigid computer
    addAnalogOutputChannel(MCCao,'Board0',1,'Voltage'); % Board0 on meeseeks/rigid computer
    % MCCao.Rate = 100;
    warning on daq:Session:onDemandOnlyChannelsAdded
    
    % Board 1: FS
    % AI O: Input channel for Hall sensor (goes to HIGH when polarizer is at 0deg)
    MCCai=daq.createSession('mcc');
    addAnalogInputChannel(MCCai,'Board1',0,'Voltage'); % Board1 on meeseeks/rigid computer
    MCCai.Rate = 100; % corresponds to 'SampleRate' in legacy code
    MCCai.IsContinuous = 1; % corresponds to 'SamplesPerTrigger' in legacy code
    % MCCai.DurationInSeconds = 0.01; % corresponds to 'SamplesPerTrigger' in legacy code
%     MCCai.NumberOfScans = 2;
%      MCCai.Channels.Range = [0 5];
     MCCai.Channels.TerminalConfig = 'SingleEnded';
end