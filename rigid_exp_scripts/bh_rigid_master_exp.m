function bh_rigid_master_exp(expSelect,parameterSet,runInit)
import polstim.*
import barpos_LEDcontrol.*
% Added 03/2021:
% Allow pol initialization to be skipped (for example, if a previous
% experiment was aborted before the polarizer rotated there's no need to
% initialize again)
if nargin < 3 || isempty(runInit) || runInit ~= 0
    runInit = 1; % else runInit argument should be 0
end

Panel_com('all_off')
daqreset

% Initial folder setup %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% Establish root folder for today's experiments
todaypath = today_folder_setup;

% % Also make a subfolder for each experiment
% folderpath = exp_folder_setup(expSelect,todaypath);

% Change directory to the experiment folder
cd(todaypath)

% Initial checks %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% We want experiments to run in a certain order: if they were input in
% expSelect in a different order, let the user know:
% (exception is pol exp 4 and its reverse counterpart exp10 - if both of
% these are included, don't force the sequence order)
% if ~isequal(sort(expSelect),expSelect) && ~(any(expSelect==4) && any(expSelect==10))
%     [~] = input(['Warning: selected exps [' num2str(expSelect) ...
%         '] will be run in ascending order!']);
%     expSelect = sort(expSelect);
% end

% If exp1 or exp2 are selected (no polarizer), wait for confirmation that
% polarizer is removed -
% but first check that a mix of 1/2 and 3/4 is not present (mixed pol and
% no pol, which isn't possible)
if any(ismember([99],expSelect)) && any(ismember([1],expSelect))
    disp('Mix of POL and non-POL experiments selected. Abort!')
    return
elseif any(ismember([99],expSelect))
    [~] = input('Remove polarizer then hit any key:  ');
elseif any(ismember([1],expSelect))
    [~] = input('Attach polarizer then hit any key:  ');
end

% Also wait for confirmation that the motor driver and LED are on:
if any(ismember([1,2,3,4,8,10],expSelect))
    [~] = input('Turn on step motor and LED, then hit any key:  ');
    % Setup step motor control and initialize polarizer
    manual_OFF % pol LED OFF
    step_control;
    disp('MCCDAQ started.')
    
    if runInit 
        disp('Initializing..')
        init_polarizer(MCCai,MCCao);
    else
        disp('Initialization skipped..')
    end
    
    polState.current_angle = 0;
    polState.current_step = 0;
end


% Start DAQ logging %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% Verify parameters have not been changed by accident, by comparing with
% saved copy:
% clc;[errorFlag] = checkParameterSet(parameterSet);
% assert(~errorFlag,'Modify parameters and run again');
% Save a copy of the parameters used for this set of experiments
file_name=[todaypath '\aq_EXP_PARAMETERS_' datestr(datevec(now),'yyyymmdd_HHMM')];
save(file_name, 'parameterSet');

% Initialize DAQ (will save a .daq file to current experiment folder)
[ao, ai, dio]=fINIT_NiDAQ(todaypath,0:3,0:6);
try outputSingleScan(ao,[0 0 0 0]), catch, putsample(ao,[0 0 0 0]), end

% Start DAQ recording (stall for time to prevent hastily double-tapped keys
% starting the experiments before slidebook is recording)
try startBackground(ai), catch, start(ai), end

clc;disp('DAQ starting')
pause(0.7)
clc;disp('DAQ starting.')
pause(0.7)
clc;disp('DAQ starting..')
pause(0.7)
clc;disp('DAQ starting...')

% Now we can start recording in Slidebook:
clc;[~] = input('Load fly, then hit any key:  ');

% Experiments %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

for eIdx = 1:length(expSelect)
    expIdx = expSelect(eIdx);
    
    % Enter individual experiments
    switch expIdx
        case {1} % UV square wave
            [polState] = bh_rigid_exp_barpos_pol(ao, MCCao, MCCai, polState, parameterSet, expIdx);
%         case {2,4,8,10} % UV pol rotate
%             [polState] = bh_avp_exp_pol_rotate(ao, MCCao, MCCai, polState, parameterSet, expIdx);
%         case 5     % blue single-pixel bars
%             bh_avp_exp_panels_bars(ao, parameterSet, expIdx);
%         case 6     % blue dot-field
%             bh_avp_exp_panels_dots(ao, parameterSet, expIdx);
%         case {7,9} % blue brightness
%             bh_avp_exp_panels_bright(ao, parameterSet, expIdx);
%         case 11     % blue two-pixel bar, closer spaced for mapping
%             bh_avp_exp_panels_barMap(ao, parameterSet, expIdx);
    end
    
end
% If all is completed succesfully, shut down the DAQ:
pause(5)
stop(ai);
stop(ao);
try outputSingleScan(ao,[0 0 0 0]), catch, putsample(ao,[0 0 0 0]), end

% and LED panels
Panel_com('stop')
pause(0.1)
Panel_com('all_off')

disp(['Experiments complete. Stop Slidebook recording.'])

% Play sound to notify that experiment is complete
load chirp
sound(y,Fs)

disp('Remember to turn off motor controller')
end

function [folderpath] = exp_folder_setup(expSelect,todaypath)
% EXPERIMENT FOLDER SETUP

% Make individual folder for this experiment, if it doesn't already exist
folderIdx = expSelect;
folderpath = [todaypath '\exp' num2str(folderIdx)];
if ~exist(folderpath,'file')
    %..make the folder
    mkdir(folderpath)
end

end

function [todaypath] = today_folder_setup
% INITIAL FOLDER SETUP

% Get today's date
datevector = datevec(date);
% Format date as a string: yymmdd
date_folderformat = num2str([datevector(1)*10000+datevector(2)*100+datevector(3)]);
% If the variable 'bendirpath' doesn't exist yet
if ~exist('bendirpath','var') || ~strcmp(todaypath, ['C:\Users\3i\Desktop\ben\' date_folderformat(1:end)] )
    %..create it (without the leading 20xx in year string yyyy)
    todaypath=['C:\Users\meeseeks\Desktop\ben\' date_folderformat(3:end)];
end
% If the folder of the same name / date doesn't exist yet
if ~exist(todaypath,'file')
    %..make the folder for today
    mkdir(todaypath)
end
if ~exist([todaypath '\funcs'],'file')
    %..make the folder for a copy of the functions used
    mkdir([todaypath '\funcs'])
end
% Get the current time and do as before to format it: yyyymmddhhmm
c=clock;
date_fileformat = num2str([datevector(1)*100000000+datevector(2)*1000000+datevector(3)*10000 + c(4)*100 + c(5)]);
% Create unique file names from the current time
script_copy = [todaypath '\funcs\bh_avp_master_script_' date_fileformat(3:end) '.m'];
exp_copy = [todaypath '\funcs\bh_avp_master_exp_' date_fileformat(3:end) '.m'];
% And copy the two Matlab .m files that are currently in use, from current
% scripts folder
copyfile('Y:\ben\2P_inbox\current_scripts\bh_avp_master_script.m', script_copy);
copyfile('Y:\ben\2P_inbox\current_scripts\bh_avp_master_exp.m', exp_copy);

% % Change directory to today's folder
% cd(todaypath)
end

function errorFlag = checkParameterSet(newSet)
% Compare saved parameter set to new input values, to avoid mistakes
load('Y:\ben\2p_inbox\current_scripts\avp_parameters.mat') % parameters saved as pSet
[~,d1,d2] = comp_struct(newSet,pSet);
if ~isempty(d1) || ~isempty(d2) % differences found
    
    if ~( isempty(d2)||isempty(d1) )
        fields = intersect(fieldnames(d2),fieldnames(d1));
    elseif isempty(d2)
        fields = fieldnames(d1);
    elseif isempty(d1)
            fields = fieldnames(d2);
    end
    
    for n = 1:size(fields,1)
        disp(['Change in pSet.' fields{n} ' found:'])
        disp(['     stored [' num2str([pSet.(fields{n})]) ']'])
        disp(['     change [' num2str([newSet.(fields{n})]) ']'])
    end
    
%     if ~isempty(setdiff(fieldnames(d2),fieldnames(d1)))
%         disp('Some fields not found:')
%         disp(setdiff(fieldnames(d2),fieldnames(d1)))
%     end
    
    continueFlag = 0;
    while ~continueFlag
        [tryStr] = input('To continue with changes, press ''1''. Press any other key to cancel.\n','s');
        if ~isnan(str2double(tryStr)) && str2double(tryStr) == 1
            errorFlag = 0;
            continueFlag = 1;
        elseif ~isnan(str2double(tryStr))
            disp('Try again') % number, but not correct one: possibly a mis-hit key
        else
            errorFlag = 1;
            continueFlag = 1;
        end
    end
else
    disp('Parameters checked: 100% match')
    errorFlag = 0;
end
end
