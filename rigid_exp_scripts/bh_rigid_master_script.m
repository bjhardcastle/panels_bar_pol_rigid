%% EXP1: POL SHIFTS FROM HOME ANGLE, W/OUT BAR
delete uno
clearvars uno
addpath(genpath('Y:\ben\avp_pol\panels_barpos_LEDcontrol\'))
Panel_com('stop')
pause(0.1)
Panel_com('all_off')
pause(0.1)
get_rigid_parameters
runInit = 1;
bh_rigid_master_exp( [1] ,pSet, runInit)
%% EXP2: OPEN LOOP POL MAPPING
delete uno
clearvars uno
addpath(genpath('Y:\ben\avp_pol\panels_barpos_LEDcontrol\'))
Panel_com('stop')
pause(0.1)
Panel_com('all_off')
pause(0.1)
get_rigid_parameters
runInit = 1;
bh_rigid_master_exp( [1] ,pSet, runInit)
