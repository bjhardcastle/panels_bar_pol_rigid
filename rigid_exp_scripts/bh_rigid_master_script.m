%% REC1: NO POL
Panel_com('all_off')
get_rigid_parameters

bh_rigid_master_exp( [1] ,pSet)

%% REC1: NO POL low voltage
Panel_com('all_off')
LED_OFF
get_rigid_parameters
pSet(1).LEDvoltageHI = 0.4;
pSet(2).LEDvoltageHI = 0.4;
pSet(7).LEDvoltageHI = 0.4;

bh_rigid_master_exp( [1,2,7] ,pSet)

%% REC2: POL
Panel_com('all_off')
LED_OFF
get_rigid_parameters

bh_rigid_master_exp( [3,4,5,6,9] ,pSet)

%% REC3: FINE-STEP POL
Panel_com('all_off')
LED_OFF
get_rigid_parameters

% modified, finer step size
bh_rigid_master_exp( [8], pSet)

%% REC4: QUICK POL
Panel_com('all_off')
LED_OFF
get_rigid_parameters

bh_rigid_master_exp( [3,4,5,9] ,pSet)
%%
Panel_com('all_off')
LED_OFF
get_rigid_parameters

bh_rigid_master_exp( [3,4,9] ,pSet)

%% REC4: HI res POL
Panel_com('all_off')
LED_OFF
get_rigid_parameters
pSet(2).trialTestPauseLength = 10;
pSet(2).LEDvoltageHI = 0.5;
pSet(4).trialTestPauseLength = 10;
bh_rigid_master_exp( [4] ,pSet)

%%
Panel_com('all_off')
LED_OFF
get_rigid_parameters
% pSet(4).StepDIR = 5;
bh_rigid_master_exp( [4,3,10] ,pSet)

%% Multipol
Panel_com('all_off')
LED_OFF
get_rigid_parameters
bh_rigid_master_exp( [4,4,10,4] ,pSet)
%% Multipol rev
Panel_com('all_off')
LED_OFF
get_rigid_parameters
bh_rigid_master_exp( [10] ,pSet)
%% Multipol rev
Panel_com('all_off')
LED_OFF
get_rigid_parameters
 pSet(3).polAngleArray = 90;
pSet(3).trialReps = 3;
bh_rigid_master_exp( [4,3,4] ,pSet)
%%
Panel_com('all_off')
LED_OFF
get_rigid_parameters
 pSet(3).polAngleArray = 45;
pSet(3).trialReps = 3;
pSet(3).recPostExpPauseLength = 30;
pSet(3).recPreExpPauseLength = 30;
bh_rigid_master_exp( [4,3,10] ,pSet)
%%
Panel_com('all_off')
LED_OFF
get_rigid_parameters
 pSet(3).polAngleArray = 90;
% pSet(3).trialReps = 1;
bh_rigid_master_exp( [4,10,3,4,3,10] ,pSet)

%%
Panel_com('all_off')
LED_OFF
get_rigid_parameters
%  pSet(3).polAngleArray = 90;
% pSet(3).trialReps = 1;
pSet(9).LEDvoltageHI = 0;
 pSet(9).trialReps = 1;
bh_rigid_master_exp( [9,4,9,10] ,pSet)
%% Bar on-screen while mapping pol tuning: shift location between exp4/10
Panel_com('stop')
Panel_com('all_off')
LED_OFF
go_camera
get_rigid_parameters

pSet(4).patIdxArray = 1;
pSet(4).patYposArray = 3;
pSet(4).patXvel = 0.5;
pSet(4).StepDIR = 1; % rotate same direction in exp4 and exp10

pSet(10).patIdxArray = 1;
pSet(10).patYposArray = 7;
pSet(10).patXvel = 0.5;
pSet(10).StepDIR = 1; % rotate same direction in exp4 and exp10

bh_rigid_master_exp( [4,4,10,4] ,pSet)

%% Bar on-screen while mapping pol tuning: shift location between exp4/10
Panel_com('stop')
Panel_com('all_off')
LED_OFF
go_camera
get_rigid_parameters

pSet(4).patIdxArray = 1;
pSet(4).patYposArray = 3;
pSet(4).patXvel = 0;

pSet(10).patIdxArray = 1;
pSet(10).patYposArray = 7;
pSet(10).StepDIR = 1;
pSet(10).patXvel = 0;

bh_rigid_master_exp( [4,10] ,pSet)
%%
Panel_com('all_off')
go_camera
LED_OFF
get_rigid_parameters
bh_rigid_master_exp( [4,5] ,pSet)
%% PB mapping
Panel_com('all_off')
LED_OFF
go_camera

% Run fast flash pol and bar mapping 
get_rigid_parameters
pSet(4).trialRandomizeOrder = 1;
pSet(4).polOffBetweenTrials = 1;
pSet(4).trialTestPauseLength = 4;
pSet(4).trialMotorPauseLength = 4;
pSet(4).polAngleStep = 15;
pSet(4).trialReps = 2;
pSet(11).trialStaticPauseLength = 4;
pSet(11).trialBaselinePauseLength = 4;
pSet(11).trialReps = 2;
bh_rigid_master_exp( [4,11] ,pSet)

%% Run regular pol mapping 
Panel_com('all_off')
LED_OFF
go_camera

get_rigid_parameters
pSet(4).trialReps = 3;
bh_rigid_master_exp( [4] ,pSet)
%%
% Run regular pol mapping in reverse
Panel_com('all_off')
LED_OFF
go_camera
pSet(4).StepDIR = 5;
pSet(4).trialReps = 3;
bh_rigid_master_exp( [3,4,11] ,pSet)
%%
% Run regular pol control 
get_rigid_parameters
pSet(2).trialReps = 3;
bh_rigid_master_exp( [1,2] ,pSet)
%%
Panel_com('all_off')
LED_OFF
get_rigid_parameters
pSet(2).LEDvoltageHI = 0.4;
pSet(2).trialReps = 2;
bh_rigid_master_exp( [2] ,pSet)
%%
%%
% Run regular pol mapping 
Panel_com('all_off')
LED_OFF
get_rigid_parameters

% go_camera
pSet(4).trialReps = 3;

bh_rigid_master_exp( [4] ,pSet)
%% Run regular pol mapping ctrl
Panel_com('all_off')
LED_OFF
get_rigid_parameters

go_camera
pSet(2).trialReps = 3;
bh_rigid_master_exp( [1,2] ,pSet)
%% Rand pol map
Panel_com('all_off')
LED_OFF
get_rigid_parameters

go_camera
pSet(4).trialReps = 2;
pSet(4).trialRandomizeOrder = 1;
pSet(4).polOffBetweenTrials = 1;

bh_rigid_master_exp( [4] ,pSet)
