% Import temperature measurements for all wells
% Extract only relevant Temperatures to compare with model results
% Save relevant temperature and time list as matfile
clear
clc
%
folder = 'C:\Users\Asus\OneDrive\INRS\WellTProfiles\';

% Extract name of data file with measured temperatures and Variant
[~, ~, ~, ~, variant, ~, ~, ~, ~, wellTempDataFileImport, wellTempDataFileImportCompare ] = ...
            comsolDataFileInUse_Info( );

%% Import
wellTempTabAll = table; % to empty the table
% import folder to process       
importPath = [folder 'rawDataWellForImport\'];
fprintf('Import path (where the excel well temperature files are taken) is: \n%s \n', importPath) % \n = new line

fileList = dir(importPath); % list of files in import folder
% Show progress bar for longer computations, 70 * ~ is to make it big enough for messages contaning params
hWait = waitbar(0, repmat('~', 1, 70), 'Name','Importing well temperatures ...');
for i = 1:numel(fileList)
    % Get filename from list
    filename = fileList(i).name;
    % Skip file names '.' (current folder) and  '..' (parent folder) and any not .txt (for example .mph files)
    if filename(1) == '.' || ~strcmp(filename(end-4:end), '.xlsx')
        continue;
    end
    
    % Show progress info bar
    waitbar(i/numel(fileList), hWait, filename); %show progress

    % Import results
    sheetName = 1; % import data from first sheet from the excel
    dataLines = [2, 200000]; % import data from rows from 2 to maximum 200 000
    wellTempTabPart = importWellTemp([importPath, filename], sheetName, dataLines);
    % Take well info from file name 
    [loggerID, wellName, wellDepth] = wellTempFilenameInfo(filename);
    % Add well info to table
    wellTempTabPart.loggerID = repmat({loggerID}, height(wellTempTabPart), 1); 
    wellTempTabPart.wellName = repmat({wellName}, height(wellTempTabPart), 1); 
    wellTempTabPart.wellDepth = repmat(wellDepth, height(wellTempTabPart), 1); 
    % Add temperatures for one well to table with all wells
    wellTempTabAll = [wellTempTabAll; wellTempTabPart];      
end
close(hWait); %close progress window

% Delete unnessesary measurements based on dates and times
% prepare list of relevant periods to keep
wellRelevantPeriodsTab = wellRelevantPeriodsPrep();  
                        
% for each well period
wellTempTab = table;
for i = 1 : height(wellRelevantPeriodsTab)
    % Select relevant rows based on well name and period
    relevantRows = strcmp(wellTempTabAll.wellName, wellRelevantPeriodsTab.wellName(i)) ...
        & wellTempTabAll.dateTime >= wellRelevantPeriodsTab.dateTimeFrom(i) ...
        & wellTempTabAll.dateTime <= wellRelevantPeriodsTab.dateTimeTo(i);
    wellTempTab = [wellTempTab; wellTempTabAll(relevantRows, :)];
end

%% Save workspace variable table with temperatures as matfile
% Version 7.3 is needed to support files >= 2GB, but older matlab versions cannot read
% this format of table saving. 
% Note minus '-v...' before version name = it means read it as Version to save file, not as string only.

% save(wellTempDataFileImport, 'wellTempTab', '-v7.3');
warning('mph saving skipped')

fprintf('Data is saved with name %s \n ', wellTempDataFileImport)
% save data in excel
% writetable(wellTempTabAll, [wellTempDataFileImport, '.csv'], 'Delimiter', ',')
% free memory. this variable is not needed anymore
clear wellTempTabAll

%% Extract only relevant Temperatures to compare with model results, 
% that is Test 1 time period, observation wells adn inj and abs wells used
% in Test 1 and at depth 28 m (filter is about 6 m high. From 25m to 31 m depth)

% Prepare times that belong to test 1 test period and are also calculated
% by numerical model.
% t = [1, 2, 4, 8]; % (sec)
if strcmp(variant, 'FieldExp2') || strcmp(variant, 'FieldExp2Rotated')  
    timeTestStart = datetime('2020-10-01 14:29:06','InputFormat','yyyy-MM-dd HH:mm:ss');
else
    timeTestStart = datetime('2020-09-14 15:07:30','InputFormat','yyyy-MM-dd HH:mm:ss');
end
% end time for period for test 1 and for all periods (test 1 and test 2 and monitoring)
if strcmp(variant, 'FieldExp1')
    timeTestFinish = datetime('2020-09-18 11:53:00','InputFormat','yyyy-MM-dd HH:mm:ss');
elseif strcmp(variant, 'FieldExp1m')
% test 1 new verion:    test1 + monitoring
    % Actually monitoring for test 1 finished on 17.2 days from start of
    % test. but the end of test 1 plus monitoring calibration is chosen to
    % be end of test 2. because well 2 is not effected by test 2.
    timeTestFinish = datetime('2020-11-27 14:54:30','InputFormat','yyyy-MM-dd HH:mm:ss'); 
else % if all tests and monitoring than use all time
    timeTestFinish = datetime('2020-11-27 14:54:30','InputFormat','yyyy-MM-dd HH:mm:ss');
end
% Filter temperatures for relevant test period only
relevantRows = wellTempTab.dateTime >= timeTestStart ...
    & wellTempTab.dateTime <= timeTestFinish ;
wellTempTabTest = wellTempTab(relevantRows, :);

% Necessary depth (28 m)
% depthTestStart = 27.4; 
% depthTestFinish = 28.6;
  depthTestStart = 20; 
  depthTestFinish = 31;
% Filter temperatures for relevant depth
relevantRows = wellTempTabTest.wellDepth >= depthTestStart ...
    & wellTempTabTest.wellDepth <= depthTestFinish ;
wellTempTabTest = wellTempTabTest(relevantRows, :);

% Necessary wells for test 1 
% Do not need to filter by wells because filtering by period leaves only
% relevant wells.

% Time list for numerical model                        
t_listNum = standardRangesToCompare( variant )';
% Measured times (during field test)
durationTest = wellTempTabTest.dateTime - timeTestStart;
t_listMeasuredAll = seconds(durationTest);
wellTempTabTest.t = t_listMeasuredAll;
t_listMeasured = unique(t_listMeasuredAll);

% Intersection between measured and modelled times
% Measured times are every 30 seconds
% Rounding of modelled times by 30 seconds allows to to intersection with
% unequal values
t_listNumRound = timeRoundToMeasured(t_listNum);
t_listMeasuredRound = timeRoundToMeasured(t_listMeasured);
% Intersection
[t_listIntersectRound, indexListNumRound] = intersect(t_listNumRound, t_listMeasuredRound);
% Select times from numerical time list which intersect with measured times
t_listTest = t_listNum(indexListNumRound);

% Select results based on relevant times t_listTest to 
% extract only relevant Temperatures to compare with model results
t_listMeasuredAllRound = timeRoundToMeasured(t_listMeasuredAll);
% Find which measurements rows contain relevant times for comparison
[~, indexListMeasured] = ismember(t_listMeasuredAllRound, t_listIntersectRound);
wellTempTabTest = wellTempTabTest(indexListMeasured~=0, :);

% Measurements for well 2 after the temperature peak time are not considered for
% calibration
if strcmp(variant, 'FieldExp1')
    % Injection of water and well temperature started to reduce from 16/09,
    % in the morning 6 am, or from approximately from 1 am
    % so data after this time is ignored for parameter calibration 
    timeTestFinishWell2 = datetime('2020-09-16 13:50:00','InputFormat','yyyy-MM-dd HH:mm:ss');
    % Filter temperatures for relevant test period only
    relevantRowsToDelete = wellTempTabTest.dateTime >= timeTestFinishWell2 ...
        & strcmp(wellTempTabTest.wellName, 'aquifro2') ;
    wellTempTabTest = wellTempTabTest(~relevantRowsToDelete, :);
elseif strcmp(variant, 'FieldExp1m')
    % Monitoring for test 1 finishes and info from wells 4 3 and 6 are
    % excluded from calibration for test 1 becuase they are influenced by
    % heat injection by test 2.
    timeTestFinish_Test1m = datetime('2020-10-01 14:29:06','InputFormat','yyyy-MM-dd HH:mm:ss');
    % Filter temperatures for relevant test period only and for relevant
    % wells
    relevantRowsToDelete = wellTempTabTest.dateTime > timeTestFinish_Test1m ...
        & (strcmp(wellTempTabTest.wellName, 'aquifro3') ...
            | strcmp(wellTempTabTest.wellName, 'aquifro4'));
    wellTempTabTest = wellTempTabTest(~relevantRowsToDelete, :);
    % Delete data for well 6 (injection well) after injection finished.
    % because data is disturbed by removal of cable.
    timeTestFinishWell6 = datetime('2020-09-18 11:53:00','InputFormat','yyyy-MM-dd HH:mm:ss');
    % Filter temperatures for relevant test period only
    relevantRowsToDelete = wellTempTabTest.dateTime >= timeTestFinishWell6 ...
        & strcmp(wellTempTabTest.wellName, 'aquifro6') ;
    wellTempTabTest = wellTempTabTest(~relevantRowsToDelete, :);
end

%% Save relevant temperature and time list as matfile
% Version 7.3 is needed to support files >= 2GB, but older matlab versions cannot read
% this format of table saving. 
% Note minus '-v...' before version name = it means read it as Version to save file, not as string only.
save(wellTempDataFileImportCompare, 'wellTempTabTest', 't_listTest', '-v7.3');
fprintf('Data is saved with name %s \n ', wellTempDataFileImportCompare)
% save data in excel
writetable(wellTempTabTest, [wellTempDataFileImportCompare, '.csv'], 'Delimiter', ',')

