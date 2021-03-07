%clear
%% Decide which plots to generate
plotT_time_wellDepth = true; % T vs time at different depths in well
    plotTestNumber = 3; % 2 % 0 % 1 = (test 1) 2 = test 2, if 3 means monitoring period only. % 0 means all plots % 
    
%% Save the plots
plotSave = true;
plotExportPath = 'C:\Users\Asus\OneDrive\INRS\WellTProfiles\figs\';

%% Load previously saved mat file with all data wellTempTab
% load('C:\Users\Asus\OneDrive\INRS\WellTProfiles\wellTempData.mat')
load('D:\COMSOL_INRS\export\wellTempData.mat')
% warning('load skipped')

% Well name list
wellNameList = unique(wellTempTab.wellName);
% set time periods for test to plot
if plotTestNumber == 1
    % Start Finish date for heat injection
    dateTimeStart_inj = datetime('2020-09-14 15:07:30', 'InputFormat','yyyy-MM-dd HH:mm:ss');
    dateTimeFinish_inj = datetime('2020-09-18 11:53:00', 'InputFormat','yyyy-MM-dd HH:mm:ss');
    % time intervals to plot
    xDateTimeStart = datetime('2020-09-13 15:07:30', 'InputFormat','yyyy-MM-dd HH:mm:ss');
    xDateTimeFinish = datetime('2020-09-23 17:29:00', 'InputFormat','yyyy-MM-dd HH:mm:ss');
elseif plotTestNumber == 2
    % Start Finish date for heat injection
    dateTimeStart_inj = datetime('2020-10-01 14:30:00', 'InputFormat','yyyy-MM-dd HH:mm:ss');
    dateTimeFinish_inj = datetime('2020-10-03 16:46:00', 'InputFormat','yyyy-MM-dd HH:mm:ss');
    % time intervals to plot
    xDateTimeStart = datetime('2020-10-01 09:00:00', 'InputFormat','yyyy-MM-dd HH:mm:ss');
    xDateTimeFinish = datetime('2020-10-08 15:00:00', 'InputFormat','yyyy-MM-dd HH:mm:ss');
elseif plotTestNumber == 3
    % Start Finish date for heat injection
    dateTimeStart_inj = [];
    dateTimeFinish_inj = [];
    % this is monitoring period, no heat injection occurs
    % time intervals to plot:
    xDateTimeStart = datetime('2020-10-09 11:00:00', 'InputFormat','yyyy-MM-dd HH:mm:ss');
    xDateTimeFinish = datetime('2020-11-27 15:00:00', 'InputFormat','yyyy-MM-dd HH:mm:ss');
else
    % Start Finish date for heat injection
    dateTimeStart_inj = [];
    dateTimeFinish_inj = [];
    % time intervals to plot
    xDateTimeStart = datetime('2020-09-13 09:07:30', 'InputFormat','yyyy-MM-dd HH:mm:ss');
    xDateTimeFinish = datetime('2020-11-27 15:00:00', 'InputFormat','yyyy-MM-dd HH:mm:ss');
end

%% T vs time at different depths in well
if plotT_time_wellDepth
    plotNamePrefix = 'T_time_wellDepth'; % plot name to save the plot with relevant name    
    % One plot for each well
    for iw = 1:numel(wellNameList)
        % Extract depths list for each well
        wellDepthList = unique( wellTempTab.wellDepth(strcmp(wellTempTab.wellName, wellNameList{iw})) );
        T_depth = cell(numel(wellDepthList), 2);
        legendTexts_depth = cell(size(T_depth, 1), 1); % text for legends on plot
        for id = 1:numel(wellDepthList)
            % Read data for this well for specified depth
            wellTempTabPart = wellNameDepthSelect(wellTempTab, wellNameList{iw}, wellDepthList(id));
            T_depth(id, 1) = {wellTempTabPart.dateTime}; % x coordinates
            T_depth(id, 2) = {wellTempTabPart.tempC}; % y coordinates
            
            legendTexts_depth{id} = sprintf('%s: depth = %.2f m', ...
                wellNameList{iw}, wellDepthList(id)); % legend text
        end
        
        % Plot T vs time at different depths in well
        depth_colorOrder = [1 2 3 4 5 6 7];
        % Duplicate colour number to be enough for  each depth 
        depth_colorOrder = sort(repmat( depth_colorOrder, 1, ceil(numel(legendTexts_depth) / numel(depth_colorOrder)) ));        
        plotName = sprintf('%s_testNumber%d_%s', plotNamePrefix, plotTestNumber, wellNameList{iw}); %% include test 1 test 2 or both
        plotTitleT_time_wellDepth = plotName;
        plotTitleT_time_wellDepth(plotTitleT_time_wellDepth == '_') = '-'; %replace _ with - in plot title not to print as subscript
            
        plotT_time_wellDepth_fun( T_depth(:,1),  T_depth(:,2), ...
            legendTexts_depth, depth_colorOrder, plotTitleT_time_wellDepth, {'-', '--'}, {'none'},...
            dateTimeStart_inj, dateTimeFinish_inj, xDateTimeStart, xDateTimeFinish)   
        % Save figure
        if plotSave
            saveFig([plotExportPath plotName])
        end    
    end
end
