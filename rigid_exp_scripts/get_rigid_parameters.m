%% SETUP PARAMETERS
pSet = [];

% EXP1: BAR TRACK+CL POL EXPOSURE - BAR DISAPPEAR - POL AT NEW ANGLE
n = 1;        
pSet(n).trialReps = 10;
pSet(n).recPreExpPauseLength = 0;
pSet(n).recPostExpPauseLength = 0;
pSet(n).trialBaselinePauseLength = 0;
pSet(n).expRandomHomeAngle = 1;
pSet(n).polHomeAngleArray = [0:7.5:360];
pSet(n).polHomeAngleFixed = [0]; % in case home angle not randomized
pSet(n).polShiftAngleArray = [0, 0, 45, 90, -45, -90]; 
pSet(n).trialRandomizeOrder = 1;
pSet(n).preExpFrontBarThreshold = 30; % s (feed into arduino toolbox)
pSet(n).interTrialBarThreshold = 3; % s (feed into arduino toolbox)
pSet(n).barBrightness = 7; % 0-7
pSet(n).patXposBarStart = 136; % back, center of arena
pSet(n).barFrontalPos = 57;
pSet(n).patYposBarON = pSet(n).barBrightness+1;
pSet(n).patYposBarOFF = 1;
% pSet(n).patIdxArray = [1 2];
pSet(n).patGrating = 1;
pSet(n).patBar = 1;
% pSet(n).patYposArray = [pSet(n).barBrightness+1]; % 1 trial positions (bright)
pSet(n).patXgain = -30;
% pSet(n).trialPreRotatePauseLength = 10;
% pSet(n).LEDvoltageHI = 0.4;
% pSet(n).LEDvoltageLO = 0;
pSet(n).trialTestPauseLength = 0;
pSet(n).trialDuringRotateLEDON = 1; % 1 = keep light on while pol angle changes
pSet(n).trialPauseAfterBarDisappear = 1; % sec
pSet(n).prePolExposeDuration = 30; % sec
pSet.preTrialSetBarWait = 0; % logical, apply preExpFrontBarThreshold before every set of trials

%{
% % 2p settings for reference

% EXP1: UV ON/OFF (NO POL)
n = 1;
pSet(n).recPreExpPauseLength = 5;
pSet(n).recPostExpPauseLength = 5;
pSet(n).trialRandomizeOrder = 0;
pSet(n).trialReps = 3;
pSet(n).trialBaselinePauseLength = 4;
pSet(n).trialTestPauseLength = 4;
pSet(n).trialPreRotatePauseLength = 10;
pSet(n).LEDvoltageHI = 0.4;
pSet(n).LEDvoltageLO = 0;
pSet(n).polAngleArray = [0]; 

% EXP2: UV ON + ROTATE (NO POL)
n = 2;
pSet(n).recPreExpPauseLength = 5;
pSet(n).recPostExpPauseLength = 5;
pSet(n).trialRandomizeOrder = 0;
pSet(n).trialReps = 2;
pSet(n).trialMotorPauseLength = 1;
pSet(n).trialTestPauseLength = 4;
pSet(n).LEDvoltageHI = 0.4;
pSet(n).LEDvoltageLO = 0;
pSet(n).polAngleStep = 30; 
pSet(n).StepDIR = 1;
pSet(n).polOffBetweenTrials = 0;

% EXP3: UV POL ON/OFF 
n = 3;
pSet(n) = pSet(1);
pSet(n).LEDvoltageHI = 1.5;
pSet(n).polAngleArray = [90, 180]; 

% EXP4: UV POL ON + ROTATE 
n = 4;
pSet(n) = pSet(2);
pSet(n).LEDvoltageHI = 1.5;
pSet(n).trialReps = 2;

% EXP5: BLUE SINGLE-PIXEL BARS
n = 5;
pSet(n).recPreExpPauseLength = 5;
pSet(n).recPostExpPauseLength = 5;
pSet(n).trialRandomizeOrder = 0;
pSet(n).trialReps = 2;
pSet(n).trialBaselinePauseLength = 4;
pSet(n).trialStaticPauseLength = 3;
pSet(n).trialMotionPauseLength = 3;
pSet(n).patIdxArray = [1];
pSet(n).patYposArray = [1 3 5 7 9]; % 2 positions per x-location (L-R then R-L motion)
pSet(n).patXvel = 10;

% EXP6: BLUE DOT-FIELD EXPANSION
n = 6;
pSet(n).recPreExpPauseLength = 5;
pSet(n).recPostExpPauseLength = 5;
pSet(n).trialRandomizeOrder = 0;
pSet(n).trialReps = 2;
pSet(n).trialBaselinePauseLength = 4;
pSet(n).trialTestPauseLength = 4;
pSet(n).patIdxArray = [2];
pSet(n).patYposArray = [1 2 3 4]; % 3 positions, left to right (position 4 = all on)
pSet(n).patXvel = 10;

% % EXP7: BLUE BRIGHTNESS ON/OFF THEN BLUE+UV ON/OFF
n = 7;
pSet(n).recPreExpPauseLength = 5;
pSet(n).recPostExpPauseLength = 5;
pSet(n).trialRandomizeOrder = 0;
pSet(n).trialReps = 3;
pSet(n).trialBaselinePauseLength = 4;
pSet(n).trialTestPauseLength = 4;
pSet(n).patIdxArray = [3];
pSet(n).patXposArray = [3]; % maximum is 4 
pSet(n).patXposInterTrial = [1]; % all panels off 
pSet(n).LEDvoltageHI = 1.5;

% EXP8: UV POL ON + ROTATE 
n = 8;
pSet(n) = pSet(2);
pSet(n).polAngleStep = 15;
pSet(n).trialReps = 2;

% % EXP9: BLUE BRIGHTNESS ON/OFF THEN BLUE+UV ON/OFF
n = 9;
pSet(n) = pSet(7);

% EXP10: Pol exp4 in reverse direction
n = 10;
pSet(n) = pSet(4);
pSet(n).StepDIR = 5;

%EXP 11: two-pixel bright bar, 10 positions, for mapping PB
n = 11;
pSet(n) = pSet(5);
pSet(n).patYposArray = [2:12]; % pos 1 is blank screen, so that switching from all_off to posN doesn't bring up a bar on pos1
pSet(n).patIdxArray = [4];
pSet(n).trialRandomizeOrder = 1;
pSet(n).trialStaticPauseLength = 3;
pSet(n).trialMotionPauseLength = 0;
pSet(n).trialBaselinePauseLength = 4;
pSet(n).patXvel = 0;

%}