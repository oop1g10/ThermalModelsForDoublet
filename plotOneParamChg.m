function plotOneParamChg( plotNamePrefix, q_colorOrder, paramName, paramValues, xUnitCoef, xUnitShift, ...
                                 params_y1, params_y2, comparativeStatsTab, ...
                                 y1Name, y1Index, y1Legend, y1Unit, y1Time, lineStyle_y1, ...
                                 y2Name, y2Index, y2Legend, y2Unit, lineStyle_y2, ...
                                 xLabel, useSemiLogX, plotSave, plotExportPath, variant, plotNameSuffixAdd)
% Plot key info comparison
% INPUT arguments:
% plotNamePrefix - plot name to save the plot with relevant name
% q_colorOrder - list of standard colours 
% paramName - string with name of changing parameter
% paramValues - list of values to be used in plot along x axis
% xUnitCoef - Coefficient to convert parameter values to x axis units
% xUnitShift - constant value to shift parameter value to convert to other units (K to degC) 
% comparativeStatsTab - table with key info comparisons between two models 
%                       taken as result from function comparativeStats
% y1Name, y2Name - names of two key info criteria for which relative % difference is plotted on y axis
%                 for example 'T_bh', it will be used also for 'T_bh_RelDiff' and 'T_bh_Diff' table columns
% y1Index, y2Index - if key info criterion has more than 1 values (e.g. plume 0.5 and 2K) the index must
%                    be specfied here, otherwise 1 should be used
% y1Legend, y2Legend - legend texts for y1 and y2 key info criteria, example '\\DeltaT_b'
% y1Unit, y2Unit - measurement units used in legend text for y1 and y2 key info criteria, example 'K'
% y1Time - time for which y1 criteria was determined, for example 30 years, specified in seconds
% xLabel - x axis label string corresponding to the changed parameter
% plotSave - save or not to save the generated plot: true or false
% plotExportPath - folder path where to save the figure, for example: 'D:\COMSOL\figuresFractureAnalysis\'
%
    defaultLineWidth = get(groot,'defaultLineLineWidth');
    lineWidthfactor = 1.5; %2; % line width for poster plots, otherwise standard is 1
    plotNameSuffix = '';
    
    % Get values for plot
    % Allocate space for results
    y1_RelDiff = nan(1, numel(paramValues));
    y2_RelDiff = nan(1, numel(paramValues));
    infoTab = table;
    % if only 1 y axis legend is one line
    if isempty(y1Name) || isempty(y2Name)
        legendTexts = cell(1,1); % text for legends on plot
    else % else legend is two lines
        legendTexts = cell(1*2,1); % text for legends on plot
    end

    diffTab = table; % Table with differences list for T bh and timeSS for Tbh (needed for min max values)
    for ip = 1:numel(paramValues)
        % Set parameter value on x axis
        params_y1 = getCalibParams( paramValues(ip), {paramName}, params_y1 );
        params_y2 = getCalibParams( paramValues(ip), {paramName}, params_y2 );
        % Find comparison result row for current parameters combination   
        comparativeStatsRow1 = comsolResultsRowForParams( comparativeStatsTab, params_y1, [], variant );   
        comparativeStatsRow2 = comsolResultsRowForParams( comparativeStatsTab, params_y2, [], variant );  
        % Collect results for plot
        if isempty(y1Name) % do not plot y2 if not asked
            y1_RelDiff(1, ip) = NaN;
        else
            y1_RelDiff(1, ip) = comparativeStatsRow1.([y1Name '_RelDiff'])(y1Index); % construct column name string, e.g. 'T_bh_RelDiff'
        end
        if isempty(y2Name) % do not plot y2 if not asked
            y2_RelDiff(1, ip) = NaN;
        else
            y2_RelDiff(1, ip) = comparativeStatsRow2.([y2Name '_RelDiff'])(y2Index);
        end

        % Collect differences to determine min and max values (to include in legend text later)
        diffRow = table;           
        if isempty(y1Name) % do not plot y2 if not asked
            diffRow.y1_Diff = NaN;
        else
            diffRow.y1_Diff = comparativeStatsRow1.([y1Name '_Diff'])(y1Index);
        end
        if isempty(y2Name) % do not plot y2 if not asked
            diffRow.y2_Diff = NaN;
        else
            diffRow.y2_Diff = comparativeStatsRow2.([y2Name '_Diff'])(y2Index);
        end
        diffTab = [diffTab; diffRow]; % add row to table
        % Collect info for legends
        infoRow = table; % Information needed for legends        
        if isempty(y1Name) % do not plot y2 if not asked
            infoRow.y1 = NaN;
        else
            infoRow.y1 = comparativeStatsRow1.keyModelInfo_target{1}.(y1Name)(y1Index); % target is Homo model
        end
        
        if isempty(y2Name) % do not plot y2 if not asked
            infoRow.y2 = NaN;
        else
            infoRow.y2 = comparativeStatsRow2.keyModelInfo_target{1}.(y2Name)(y2Index);
        end
        % Collect additional (min max) info for legends
        if ~isempty(y1Name)
            infoRow.y1_Diff_Min = min(diffTab.y1_Diff);
            infoRow.y1_Diff_Max = max(diffTab.y1_Diff);
        else
            infoRow.y1_Diff_Min = NaN;
            infoRow.y1_Diff_Max = NaN;
        end
            
        if ~isempty(y2Name)
            infoRow.y2_Diff_Min = min(diffTab.y2_Diff);
            infoRow.y2_Diff_Max = max(diffTab.y2_Diff);
        else
            infoRow.y2_Diff_Min = NaN;
            infoRow.y2_Diff_Max = NaN;
        end
        
        infoTab = [infoTab; infoRow]; % add row to table
        
        % Prepare legend texts
        % Compare model with parameter set from one at a time sensitivity
        % analysis versus model with standard parameter set.
        if strcmp(comparativeStatsTab.modelMethod(1), 'nDoublet2D_vs_nDoublet2Dstd')
            baseModeltoCompare = 'nDoublet2Dstd';  
        end
        
        if ~isempty(y1Name) && ~isempty(y2Name) && strcmp(y1Name, y2Name) % if both y1 and y2 are for Tb or XPlume (i.e. when plot for 2 different fracture distances is required)
            % Tb or xPlume
            legendTexts{1} = legendTexts_forPlotOneParamChg( y1Legend, y1Legend, y1Time,  ...
                                    infoRow, y1Unit, y2Unit, baseModeltoCompare, y1Name);

            % Tb or xPlume
            legendTexts{2} = legendTexts_forPlotOneParamChg( y2Legend, y2Legend, y1Time,  ...
                                    infoRow, y1Unit, y2Unit, baseModeltoCompare, y2Name);
        elseif ~isempty(y1Name) && ~isempty(y2Name) % when plot is for one parameter i.e. y1 is Tb and y2 is Time ss
            % Tb or xPlume
            legendTexts{1} = legendTexts_forPlotOneParamChg( y1Legend, y2Legend, y1Time,  ...
                                    infoRow, y1Unit, y2Unit, baseModeltoCompare, y1Name);
                
            % Time to SS
            legendTexts{2} = legendTexts_forPlotOneParamChg( y1Legend, y2Legend, y1Time,  ...
                                    infoRow, y1Unit, y2Unit, baseModeltoCompare, y2Name);
        % when separate plots are required ( only 2 line per plot)
        elseif ~isempty(y1Name)  
            legendTexts{1} = legendTexts_forPlotOneParamChg( y1Legend, y2Legend, y1Time,  ...
                                    infoRow, y1Unit, y2Unit, baseModeltoCompare, y1Name);
        elseif ~isempty(y2Name)
            legendTexts{1} = legendTexts_forPlotOneParamChg( y1Legend, y2Legend, y1Time,  ...
                                    infoRow, y1Unit, y2Unit, baseModeltoCompare, y2Name);
        end
    end
    
    %% Plot relative change of criteria vs parameter
    setFigSize( 1.1, 1.5 ); %size for single column figure
    figure;
    colors = setColorOrder( q_colorOrder );
    
    % Preallocate x axis values
    xAxisValues = nan(1, numel(paramValues));
    xAxisValues(1,:) = paramValues * xUnitCoef + xUnitShift;
    %Plot first valiable (for example Tb or xPlume)
    if ~isempty(y1Name)
        if useSemiLogX
            % Convert relative diff to percentage (hence * 100)
            semilogx(xAxisValues(1,:), y1_RelDiff(1,:) * 100, 'Color', colors(1,:), 'LineStyle', lineStyle_y1, ...
                'LineWidth', 1.001*defaultLineWidth*lineWidthfactor)
        else
            % Convert relative diff to percentage (hence * 100)
            plot(xAxisValues(1,:), y1_RelDiff(1,:) * 100, 'Color', colors(1,:), 'LineStyle', lineStyle_y1, ...
                'LineWidth', 1.001*defaultLineWidth*lineWidthfactor)   
        end   
        hold on
    end
    
    if ~isempty(y2Name)
        % Plot second valiable (for example tSS)
        if useSemiLogX 
            % Convert relative diff to percentage (hence * 100)
            semilogx(xAxisValues(1,:), y2_RelDiff(1,:) * 100, 'Color', colors(1,:), 'LineStyle', lineStyle_y2, ...
                'LineWidth', 1.001*defaultLineWidth*lineWidthfactor)
        else
            % Convert relative diff to percentage (hence * 100)
            plot(xAxisValues(1,:), y2_RelDiff(1,:) * 100, 'Color', colors(1,:), 'LineStyle', lineStyle_y2, ...
                'LineWidth', 1.001*defaultLineWidth*lineWidthfactor)      
        end
        hold on
    end
    
    legend(legendTexts, 'Location', 'SouthOutside')
   
    %legend(legendTexts_q{(numel(q_list))+1 : end}, 'Location', 'SouthOutside')
    xlabel(xLabel);
    ylabel('Relative % difference');
    title('One-at-a-time sensitivity analysis')
    grid on
    grid minor
    
                     
    if plotSave % save this plot as separate      
       plotNameSuffix = [plotNameSuffix, plotNameSuffixAdd];
       plotName = sprintf('frSingle_%s_%s_%s', plotNamePrefix, paramName, plotNameSuffix);                
       saveFig([plotExportPath plotName])
    end

end

