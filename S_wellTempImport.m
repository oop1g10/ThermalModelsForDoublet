clear
clc
%
folder = 'C:\Users\Asus\OneDrive\INRS\WellTProfiles\';
% Name of data file with comsol imported results
wellTempDataFileName = 'wellTempData.mat';
wellTempDataFileImport = [folder, wellTempDataFileName]; % place and name where to save results in matfile 

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
wellRelevantPeriodsTab = table;
wellRelevantPeriodsTab = wellRelevantPeriodAdd(wellRelevantPeriodsTab, ... 
                            'aquifro2', '2020-09-14 14:15:00', '2020-09-21 14:42:00');
wellRelevantPeriodsTab = wellRelevantPeriodAdd(wellRelevantPeriodsTab, ... 
                            'aquifro3', '2020-09-14 18:00:00', '2020-09-21 14:47:00');
wellRelevantPeriodsTab = wellRelevantPeriodAdd(wellRelevantPeriodsTab, ... 
                            'aquifro5', '2020-09-14 13:58:00', '2020-09-22 17:29:00');
wellRelevantPeriodsTab = wellRelevantPeriodAdd(wellRelevantPeriodsTab, ... 
                            'aquifro6', '2020-09-14 15:10:00', '2020-09-21 14:47:00'); % these dates are under question
% Second test periods
wellRelevantPeriodsTab = wellRelevantPeriodAdd(wellRelevantPeriodsTab, ... 
                            'aquifro2', '2020-10-01 11:46:00', '2020-10-08 14:00:00');
wellRelevantPeriodsTab = wellRelevantPeriodAdd(wellRelevantPeriodsTab, ... 
                            'aquifro3', '2020-10-01 10:00:00', '2020-10-08 14:00:00');
wellRelevantPeriodsTab = wellRelevantPeriodAdd(wellRelevantPeriodsTab, ... 
                            'aquifro4', '2020-10-01 12:12:00', '2020-10-08 08:20:00');                        
wellRelevantPeriodsTab = wellRelevantPeriodAdd(wellRelevantPeriodsTab, ... 
                            'aquifro5', '2020-10-01 12:27:00', '2020-10-08 13:18:00');
wellRelevantPeriodsTab = wellRelevantPeriodAdd(wellRelevantPeriodsTab, ... 
                            'aquifro6', '2020-10-01 15:07:30', '2020-10-08 13:55:00');
wellRelevantPeriodsTab = wellRelevantPeriodAdd(wellRelevantPeriodsTab, ... 
                            'aquifro7', '2020-10-01 14:30:00', '2020-10-08 13:26:00');   

% Monitorig period well 2
wellRelevantPeriodsTab = wellRelevantPeriodAdd(wellRelevantPeriodsTab, ... 
                            'aquifro2', '2020-10-09 12:00:30', '2020-11-23 11:50:30');                       
wellRelevantPeriodsTab = wellRelevantPeriodAdd(wellRelevantPeriodsTab, ... 
                            'aquifro2', '2020-11-23 16:56:00', '2020-11-27 14:49:30');
% Monitorig period well 3                       
wellRelevantPeriodsTab = wellRelevantPeriodAdd(wellRelevantPeriodsTab, ... 
                            'aquifro3', '2020-10-09 12:09:30', '2020-11-23 11:55:00');                                                
wellRelevantPeriodsTab = wellRelevantPeriodAdd(wellRelevantPeriodsTab, ... 
                            'aquifro3', '2020-11-23 23:00:00', '2020-11-27 14:14:00');
% monitoring times are segmented due to occational temporal removal of sensors 
% to take hand measurements.                                               
% Monitorig period well 4
wellRelevantPeriodsTab = wellRelevantPeriodAdd(wellRelevantPeriodsTab, ... 
                            'aquifro4', '2020-10-09 11:47:30', '2020-10-13 09:14:00' );
wellRelevantPeriodsTab = wellRelevantPeriodAdd(wellRelevantPeriodsTab, ... 
                            'aquifro4', '2020-10-13 11:40:30', '2020-10-30 09:27:00'); 
wellRelevantPeriodsTab = wellRelevantPeriodAdd(wellRelevantPeriodsTab, ...
                            'aquifro4', '2020-10-30 12:39:30', '2020-11-13 11:15:30'); 
wellRelevantPeriodsTab = wellRelevantPeriodAdd(wellRelevantPeriodsTab, ...
                            'aquifro4', '2020-11-13 13:03:30', '2020-11-24 10:29:30');     
wellRelevantPeriodsTab = wellRelevantPeriodAdd(wellRelevantPeriodsTab, ...
                            'aquifro4', '2020-11-24 13:41:00', '2020-11-27 14:16:30');       
                        
% Monitorig period well 5                        
wellRelevantPeriodsTab = wellRelevantPeriodAdd(wellRelevantPeriodsTab, ... 
                            'aquifro5', '2020-10-09 11:59:30', ' 2020-11-23 11:43:30');
                        
wellRelevantPeriodsTab = wellRelevantPeriodAdd(wellRelevantPeriodsTab, ... 
                            'aquifro5', '2020-11-23 16:35:00', ' 2020-11-24 11:16:00');

wellRelevantPeriodsTab = wellRelevantPeriodAdd(wellRelevantPeriodsTab, ... 
                            'aquifro5', '2020-11-24 15:27:30', ' 2020-11-27 14:54:30');
                       
%  Monitorig period well 6                          
wellRelevantPeriodsTab = wellRelevantPeriodAdd(wellRelevantPeriodsTab, ... 
                            'aquifro6', '2020-10-09 14:15:30', '2020-11-23 11:51:30');
wellRelevantPeriodsTab = wellRelevantPeriodAdd(wellRelevantPeriodsTab, ... 
                            'aquifro6', '2020-11-23 16:27:30', '2020-11-27 14:41:30');                        

% Monitorig period well 7                          
wellRelevantPeriodsTab = wellRelevantPeriodAdd(wellRelevantPeriodsTab, ... 
                            'aquifro7', '2020-10-09 13:10:00', '2020-10-13 10:50:00'); 
wellRelevantPeriodsTab = wellRelevantPeriodAdd(wellRelevantPeriodsTab, ... 
                            'aquifro7', '2020-10-13 18:50:00', '2020-11-13 10:16:00');                         
wellRelevantPeriodsTab = wellRelevantPeriodAdd(wellRelevantPeriodsTab, ... 
                            'aquifro7', '2020-11-13 20:26:30', '2020-11-24 11:09:30'); 
wellRelevantPeriodsTab = wellRelevantPeriodAdd(wellRelevantPeriodsTab, ... 
                            'aquifro7', ' 2020-11-25 10:21:00  ', '2020-11-27 14:46:30');           
                        
% for each well period
wellTempTab = table;
for i = 1 : height(wellRelevantPeriodsTab)
    % Select relevant rows based on well name and period
    relevantRows = strcmp(wellTempTabAll.wellName, wellRelevantPeriodsTab.wellName(i)) ...
        & wellTempTabAll.dateTime >= wellRelevantPeriodsTab.dateTimeFrom(i) ...
        & wellTempTabAll.dateTime <= wellRelevantPeriodsTab.dateTimeTo(i);
    wellTempTab = [wellTempTab; wellTempTabAll(relevantRows, :)];
end
% wellTempTab_clean = wellTempTab(wellTempTab.);

% Save workspace variable table with temperatures as matfile
% Version 7.3 is needed to support files >= 2GB, but older matlab versions cannot read
% this format of table saving. 
% Note minus '-v...' before version name = it means read it as Version to save file, not as string only.
save(wellTempDataFileImport, 'wellTempTab', '-v7.3');
fprintf('Data is saved with name %s \n ', wellTempDataFileImport)
% save data in excel
writetable(wellTempTabAll, [wellTempDataFileImport, '.csv'], 'Delimiter', ',')


