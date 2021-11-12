% Clean ALL is used here to clear persistent variables, in case input data is changed
% Persistent variables in function are used as cache.
clear all

% to enlarge displayed figures
set(0, 'DefaultFigurePosition', [100 100 1000 500]);
runOnIridisLinux = false; % if to run on supercomputer which uses Linux

%% Choose which parts of the process to perform
perfomSimulations = false;
    aXYZRatios = true; % Use samples with aXYZ ratios only, ie. set as 1 parameter not vary independently.
    
performLoadFiles = false; % Import txt files as results table from folder
    keyInfoResultsCompStat_FilePrefix = 'keyInfoResultsCompStatTab_'; % Prefix for files to be loaded
    withoutAnalytical_OnlyNumerical = false; % True for testing only. Not to wait for long analytical calculations
    
performMcat = true;
    modelMethodToPlot = 1; % 2 % means: 1 - analytical, 2 - numerical
    plotHistogramMC = false; % plot histogram of MC results for Tb to see the outliers
    plotXYvar_percentiles_MC = false; % option to plot difference between Homo and Hetero models
        plotXYvar_percentiles_MC_lines = true; % to switch on/off ploting of percentile lines if more fixed values (rows) exist
        % Set figure size for poster
        figSize = [0.73 1.35]; % correct width for 3 subplots for journal Alternative energy,
         
        useSubplotDims = []; %to plot individual figures, not as subplots
        % useSubplotDims = [3,3]; %to plot 3 by 3 as subplots
        figSizeSubplots = [2 2]; % Large to contain subplots
        yVarName = 't_b_aquifro5'; % 'T_bh'; % temperature change at borehole wall after 30 years
        % yVarName = 'T_bh_Diff'; % temperature change at borehole wall after 30 years difference between Homo and fracture models
        % yVarName = 'T_bh_RelDiff'; % relative difference

        % For this plot above CHOOSE WHICH PARAMETERS to plot
        paramsFor_q = false;
        paramsFor_aX = false;
    plotSave = false; % save this option plot

%% Folder settings
addpath('.\MCAT5.1') % Only for PC to plot MCAT analysis

% set folder names for comsol run
[~, ~, modelMethods, ~, variant, solution, methodMesh, ~, ~, ~, ~, exportPath ] = ...
            comsolDataFileInUse_Info( );
modelMethod = modelMethods{2}; % Method of model calculation, 1 = analytical, 2 = numerical (if = 1 Nothing will happen). should always be = 2.
fprintf('methodMesh: %s modelMethod: %s \n', methodMesh, modelMethod);

importPathSuffix = '_2d_fieldtest1_new_numansol1000';  % '_2d_fieldtest1';
% ImportPath contains csv files - results from comsol calculations.
importPath = [exportPath, 'MonteCarlo', importPathSuffix, '\'];
% Matlab file for saving data
mcatComsolDataFilename = [exportPath, 'mcatComsolData', importPathSuffix, '.mat'];

% Folder to export plots
plotExportPath = ['C:\Users\Asus\OneDrive\INRS\COMSOLfigs\MonteCarlo' importPathSuffix '\']; 

assert(contains(importPathSuffix, methodMesh), 'Ensure that correct model dimension is selected 2d or 3d.')

%% Prepare ranges and distributions for model parameters for parameters descriptions see function getCalibParams
sampleType = 'LatinHypercubeUniform'; %'Uniform'

assert(strcmp(methodMesh, '2d'), 'MonteCarlo is for 2D only!');
paramsStd = standardParams( variant );  
% Prepare list of parameters with their ranges for MonteCarlo analysis
distribution = 'Uniform';
paramRanges_MC = table;
paramRanges_MC(end+1,:) = prepParamRange('LOG10_q', distribution, log10(1E-6), log10(1E-2), NaN, NaN); % paramsStd.q
% paramRanges_MC(end+1,:) = prepParamRange('LINKED_aX', distribution, 0, 4, NaN, NaN); % aX
paramRanges_MC(end+1,:) = prepParamRange('alpha_deg', distribution, 0, 360, NaN, NaN); %alpha_deg
paramRanges_MC(end+1,:) = prepParamRange('cS', distribution, 700, 1100, NaN, NaN); %cS
paramRanges_MC(end+1,:) = prepParamRange('lS', distribution, 1, 4, NaN, NaN); %lS
paramRanges_MC(end+1,:) = prepParamRange('n', distribution, 0.2, 0.4, NaN, NaN); %n
paramRanges_MC(end+1,:) = prepParamRange('LINKED_H', distribution, 1, 9, NaN, NaN);

%% Monte Carlo simulations of COMSOL model
%Execute COMSOL simulations for prepared samples and save results in files
if perfomSimulations
    % Latin Hypercube sampling and running of model
    % Number of runs
    numberSimul = 1000; 
    paramSamples = prepSamples_COMSOL(paramRanges_MC, numberSimul); %prepare random samples for all parameters

    %List of parameter combination indices to calculate, [] means all
    paramsIndicesToCalculate = [894:numberSimul];
    % Allow to change this from Linux command line by specifying ENV variable:
    % export MATLAB_EVAL="paramsIndicesToCalculate=[1:2];"
    % By getting this ENV variable and evaluating it the variable paramsIndicesToCalculate in Matlab is changed
    env_MATLAB_EVAL = getenv('MATLAB_EVAL');
    if ~isempty(env_MATLAB_EVAL)
        fprintf('Evaluating extra parameters: %s\n', env_MATLAB_EVAL);
        eval(env_MATLAB_EVAL);
    end
    % Set list of parameter indices to calculate to all if empty
    %paramsIndicesToCalculate = 31; % index in parameters combinations table of row with standard parameters set for Tight matrix scenario
    if isempty(paramsIndicesToCalculate)
        % Use all parameter combinations
        paramsIndicesToCalculate = 1:numberSimul;
    else
        % Ensure only valid indices up to size(paramsCombinationsTab,1) are used
        paramsIndicesToCalculate = intersect(paramsIndicesToCalculate, 1:numberSimul);
        warning('Restricting calculation to requested parameter combinations only.')
    end
    
    % SuperTable predefine which will contain all relevant results for MonteCarlo analysis
    keyInfoResultsCompStatTab = table;
    for i = paramsIndicesToCalculate
        % Prepare parameters, compute, export and import results COMSOL
        comsolResultsTab = table;
        %Prepare params for COMSOL execution
        % Use standard parameters with renewed values for sample parameters for MonteCarlo simulation
        paramNames = paramSamples.Properties.VariableNames'; %get names of all columns
        paramValues = table2array(paramSamples(i,:));
        params = getCalibParams( paramValues, paramNames, paramsStd );
        
        % If model method is numerical (not analytical)
        if isModelNumerical( modelMethod )
            % Calculate Comsol model
            fprintf('RunCount: %d, Model parameters: %s\n', i, comsolParams2String( params ));
            [comsolResultsTab, calcDurationSeconds] = comsolRun(params, i, false);
        end
        
    end
    
%     % Save KeyInfo + ResultRow + ComparativeStats = SuperFile:) into csv file will be imported for MCarlo analysis
%     % (can be opened in excel too) 
%     % Generate unique simulation ID based on datetime
%     simID = sprintf('%s-%02d', char(datetime(),'yyyyMMdd-HHmmss'), floor(rand()*100) );
%     % Add simulation indices to filename
%     paramsIndicesToCalculateInfo = sprintf('%04d-%04d(%04d)', min(paramsIndicesToCalculate), max(paramsIndicesToCalculate), numel(paramsIndicesToCalculate));
%     writetable(keyInfoResultsCompStatTab, [exportPath 'keyInfoResultsCompStatTab_' cell2mat(modelMethods) ...
%                                            '_' paramsIndicesToCalculateInfo '_' simID '.csv'], 'Delimiter', ',')

    % If numerical model is used the remove model from comsol server memory (close mph file) and disconnect from comsol server
    if isModelNumerical( modelMethod )    
        import com.comsol.model.*  % pathway to comsol utilities for them to work
        import com.comsol.model.util.*
        ModelUtil.remove('model') % close mph in server
        ModelUtil.disconnect;    % close comsol server
    end   
end

%% Load data from simulation COMSOL files
% Import files and save them as Matlab internal table
if performLoadFiles   
    % Import cvs files as results table from folder
    % Note that table created from import has columns with one value only (e.g. T_x_1, T_x2..)
    % unlike originally created table with has T_x as matrix with all values in one column.
    % importFolderCsv inputs: (from what folder ot import files, what files to selectby PREfix)   
    warning('Part of file indices are calculated')
    iFileList = 1:1000; % ;
    
    if withoutAnalytical_OnlyNumerical
        warning('Only numerical model is evaluated. No comparison with ansol')
        modelMethodsTemp = [modelMethods(2), modelMethods(2)];
        keyInfoResultsCompStatTab = importFolderAndCompStat( importPath, modelMethodsTemp, variant, iFileList );
    else % Both analytical and numerical and their comparison
        keyInfoResultsCompStatTab = importFolderAndCompStat( importPath, modelMethods, variant, iFileList );
    end
    fprintf('Number of comparisons: %d\n', size(keyInfoResultsCompStatTab,1)/2);

    % Remove duplicitly calculated simulations (if present)
    % Prepare list of columns which must be unique
    columnNamesForUniqueTab = [fieldnames(paramsStd);{'modelMethod'}];
    % Ensure that table has all rows with unique values of parameters
    [~,uniqueRowsIndices,~] = unique(keyInfoResultsCompStatTab(:,columnNamesForUniqueTab),'rows'); %
    keyInfoResultsCompStatTab = keyInfoResultsCompStatTab(uniqueRowsIndices,:);
    % number of imported after unique
    fprintf('Number of imported simulations unique: %d\n', size(keyInfoResultsCompStatTab,1));
            
    % Save data for MCAT
    save(mcatComsolDataFilename,'keyInfoResultsCompStatTab');
end

%% Monte Carlo Analysis of results in MCAT
if performMcat
    % Load previously prepared MCAT data 
    load(mcatComsolDataFilename);
    % Choose which model method to plot
    % Filter out analytical results
    keyInfoResultsCompStatTab_MC = ...
        keyInfoResultsCompStatTab( strcmp(keyInfoResultsCompStatTab.modelMethod, modelMethods(modelMethodToPlot)), : );
    fprintf('Number of comparisons used for MC (%s): %d\n', ...
            modelMethods{modelMethodToPlot}, size(keyInfoResultsCompStatTab_MC,1));
    
    % Prepare list of parameters which were varying during simulation runs
    paramsNameList_MC = paramRanges_MC.name;
    paramsTab_MCAT = paramsPrep_MCAT( paramsNameList_MC, keyInfoResultsCompStatTab_MC );
    % IDEA: Can add new params as param ratios
    
    % Prepare table with stats
    statsNames = {'T_bh', ... % temperature at abstraction well (after specified time, e.g. after 15 days) %                   'timeSS_Tbh', ...
                  't_b_aquifro2', ... % time to breakthrough for well number
                  't_b_aquifro3', ... % time to breakthrough for well number
                  't_b_aquifro4', ... % time to breakthrough for well number
                  't_b_aquifro5', ... % time to breakthrough for well number
                  't_b_aquifro6', ... % time to breakthrough for well number                  
                  't_b_aquifro2_RelDiff', ... % relative difference between analytical and numerical models for time to breakthrough for well number
                  't_b_aquifro3_RelDiff', ... % rel dif .....time to breakthrough for well number
                  't_b_aquifro4_RelDiff', ... % rel dif .........time to breakthrough for well number
                  't_b_aquifro5_RelDiff', ... % rel dif ..........time to breakthrough for well number
                  't_b_aquifro6_RelDiff', ... % rel dif ............time to breakthrough for well number                 
                  'T_x', ... % Temperature change at defined distance from injection well along x axis.
                  'xPlume'... % T_plume_listMC =  [1 3 5 7] deg C; extention of thermal plume on x axis after 14.6 days
                  'xPlumeSS'...length of thermal plume at steady state for predefined isotherms (1 3 5 7)
                  'plumeLength'... % reached length of plume in xy space after 14.6 days (or other preset time)
                  'plumeLengthSS'... % same but for steady state 
                  'timeSS_xPlume'... % time to stabilise longitudinal thermal plume of 2 Kelvin temperature change
                  'RMSEadj'...     % Root mean square error adjusted for potential temperature differences at each well.                
                  'T_bh_Diff' ... % difference between analytical and numerical model in temeprature difference after defined time (2 weeks) 
                  'T_bh_RelDiff', ...% relative difference in T bh Diff
                  'timeSS_Tbh_Diff', ...difference between models in time to stabilise temperature change at the injection well
                  'timeSS_Tbh_RelDiff', ... relative diff.
                  'plumeLength_Diff'... difference between models in length of isotherms
                  'plumeLength_RelDiff'... relative difference
                  'RMSEadj_Diff'...room mean square error difference between models
                  'RMSEadj_RelDiff'}; % relaive difference. 
        
    % Some column names have several values, create separate numbered
    % columns for each value. for example T_x will be T_x_1, T_x_2 etc.
    statsTab_MCAT = table;
    for i = 1 : numel(statsNames)
        statsName = statsNames{i};
        statsValues = keyInfoResultsCompStatTab_MC.(statsName); % numerical or analytical
        statsColumns = size(statsValues, 2);
        % If the current column contains sereval values
        if statsColumns > 1
            %  Create separate numbered columns for each value. for example T_x will be T_x_1, T_x_2 etc
            for iColumn = 1 : statsColumns  
                % Add number of subcolumn to the column name
                columnName = sprintf('%s_%d', statsName, iColumn);
                % Add subcolumn to results tab for MCAT tool
                statsTab_MCAT.(columnName) = statsValues(:,iColumn);
            end
        else
            % Assign the unchanged name and values to results table
            columnName = statsName;
            statsTab_MCAT.(columnName) = statsValues; 
        end  
        % If y axis is for time convert seconds to days logarythmic!
        if columnName(1) == 't'
            statsTab_MCAT.(columnName) = log10(secondsToDays(statsTab_MCAT.(columnName)));
        end
    end
            
    %% Plot historgam of MC runs versus Tb
%     if plotHistogramMC
%         plotNamePrefix = 'HistogramMC';
%       %'T_diff'; % plot the histogram for difference in T at borehole between models
%       %'T_Reldiff'; % plot the histogram for relative difference of T at borehole between models (fracture, no fracture)
%        xVariableToPlot = [{'T_diff'},{'T_Reldiff'}];
%        for ivar = 1:2
%             if strcmp(importPathSuffix, importPathSuffix_varied_q) && strcmp(xVariableToPlot{ivar}, 'T_diff') % 5000 sims % basic variant when aquifer parameters (q, axyz) also vary.
%                 xLims = [-3 3];
%                 yLims = [0 150];
%             elseif strcmp(importPathSuffix, importPathSuffix_varied_q) && strcmp(xVariableToPlot{ivar}, 'T_Reldiff') % 5000 sims % basic variant when aquifer parameters (q, axyz) also vary.
%                 xLims = [-40 80];
%                 yLims = [0 150];        
%                 
%                 
%             elseif strcmp(importPathSuffix, importPathSuffix_varied_q_fixedaXYZ) && strcmp(xVariableToPlot{ivar}, 'T_diff') % 5000 sims % basic variant when aquifer parameters (q, axyz) also vary.
%                 xLims = [-3 80];
%                 yLims = [0 150]; 
%             elseif strcmp(importPathSuffix, importPathSuffix_varied_q_fixedaXYZ) && strcmp(xVariableToPlot{ivar}, 'T_Reldiff') % 5000 sims % basic variant when aquifer parameters (q, axyz) also vary.
%                 xLims = [-3 80];
%                 yLims = [0 150]; 
%                 warning('these limits are under question')
% 
%          %   elseif strcmp(importPathSuffix, importPathSuffix_varied_q_fixedaXYZ) % Fixed axyz (0 m and 2 m) and varied q in matrix to analyse infleunce of fracture parameters
%          %       xLims = [];
%          %       yLims = [];
%             elseif strcmp(importPathSuffix, importPathSuffix_slow_q) && strcmp(xVariableToPlot{ivar}, 'T_diff') % Fixed q (slower, E-8) and axyz parameter (aqiufer) to analyse infleunce of fracture parameters
%                 xLims = [-4 4];
%                 yLims = [ 0 150];     
%                 colourOrder = [1];
%             elseif  strcmp(importPathSuffix, importPathSuffix_slow_q) && strcmp(xVariableToPlot{ivar}, 'T_Reldiff')
%                 xLims = [-30 30];
%                 yLims = [0 150];  
%                 colourOrder = [1];
%             elseif strcmp(importPathSuffix, importPathSuffix_fast_q) && strcmp(xVariableToPlot{ivar}, 'T_diff') % Fixed q (fast, E-7) and axyz parameter (aqiufer) to analyse infleunce of fracture parameters
%                 xLims = [-4 4];
%                 yLims = [0 150];
%                 colourOrder = [2];
%             elseif  strcmp(importPathSuffix, importPathSuffix_fast_q) && strcmp(xVariableToPlot{ivar}, 'T_Reldiff')
%                 xLims = [-30 30];
%                 yLims = [0 150]; 
%                 colourOrder = [2];
%             end
% 
%             bins = 100; 
%             if strcmp(xVariableToPlot{ivar}, 'T_diff') % plot the histogram for difference in T at borehole between models
%                 xVar = keyInfoResultsCompStatTab_MC.T_bh_Diff;
%                 plotHistogramMC_fun( xVar, xLims, yLims, xVariableToPlot{ivar}, bins, colourOrder )
%             elseif strcmp(xVariableToPlot{ivar}, 'T_Reldiff') % plot the histogram for relative difference of T at borehole between models (fracture, no fracture)
%                 xVar = 100 * keyInfoResultsCompStatTab_MC.T_bh_RelDiff; % % of relative difference
%                 plotHistogramMC_fun( xVar, xLims, yLims, xVariableToPlot{ivar}, bins, colourOrder ) 
%             end
% 
%             %  Save plot if requested   
%             if plotSave == true   
%                 dataTotalCount = size(keyInfoResultsCompStatTab_MC.T_bh_Diff, 1);
%                 plotName = sprintf('plot%s_%dsimuls_fromData%s_Xvariable%s', ...
%                     plotNamePrefix, dataTotalCount, importPathSuffix, xVariableToPlot{ivar});
%                 saveFig([plotExportPath plotName]);
%             end
%        end
%     end
    
    %% Prepare parameters correlation matrix for best results - similar to MCAT plot
%     bestResultProp = 5/100; %  5% of best results
%     numParamForLeach = 10;
%     
%     %Add result statistics to samples
%     paramSamplesResult = paramSamples;
%     paramSamplesResult.RmseLeach = RmseLeach;
%     paramSamplesResult.RmseLeachCum = RmseLeachCum;
%     paramSamplesResult.ObjFun = ObjFunLeach;
%     paramSamplesResult.RmseCl = RmseCl;
%     paramSamplesResult.RsquaredLeach = -Rsquared; %with minus sign so lowest is best
%     paramSamplesResult.RsquaredLeachCum = -RsquaredCum;
%     paramSamplesResult.RsquaredCl = -RsquaredCl;
%     %Compute and show parameter correlations
%     [paramCorrLeach, paramCorrPValuesLeach, paramCorrTabLeach] = paramCorrCoef(paramSamplesResult, 'ObjFun', bestResultProp, 1, numParamForLeach); %for leachate
%     [paramCorrCl, paramCorrPValuesCl, paramCorrTabCl] = paramCorrCoef(paramSamplesResult, 'RsquaredCl', bestResultProp, 1, size(paramSamples, 2)); %for leachate

    %% Set up input and run MCAT
    % if parameters q and axyz are fixed
    % just for info about available prefices:
    %variants where both q and ax are fixed
%     importPathSuffix_fast_q = '_2d_Fixedq-7axyz0'; % Fixed q (fast, E-7) and axyz parameter (aqiufer) to analyse infleunce of fracture parameters
%     importPathSuffix_slow_q = '_2d_Fixedq-8axyz0'; % Fixed q (slower, E-8) and axyz parameter (aqiufer) to analyse infleunce of fracture parameters
    % other variants 
%     importPathSuffix_varied_q_fixedaXYZ = '_2d_Fixed_axyz_0_2'; % Fixed axyz (0 m and 2 m) and varied q in matrix to analyse infleunce of fracture parameters
%     importPathSuffix_varied_q = '_2d'; % 5000 sims % basic variant when aquifer parameters (q, axyz) also vary.
    

    mcatInput = struct;
    mcatInput.pars = table2array(paramsTab_MCAT);	% MC parameter matrix [no. of sims x no. of pars]
    mcatInput.pstr = str2mat(paramsTab_MCAT.Properties.VariableNames);		    % parameter names [string matrix - use str2mat to create]    
    mcatInput.crit = table2array(statsTab_MCAT);  % MC criteria matrix [no. of sims x no. of criteria]
    mcatInput.cstr = str2mat(statsTab_MCAT.Properties.VariableNames);	    % criteria names [string matrix - use str2mat to create]
    mcatInput.vars = []; % not used [ClMeanFirstYear ClMeanLastYear ClMeanDiff]; % MC variable matrix [no. of sims x no. of pars]
    mcatInput.vstr = []; %not used str2mat('ClMeanFirstYear', 'ClMeanLastYear', 'ClMeanDiff');	    % variable names [string matrix - use str2mat to create]
    mcatInput.mct = [];
    %mct = SimLeachateMod_mm;  % MC ouput time-series matrix [no. of sims x no. of samples]
    %SimLeachateMod_mm = []; %clear it after usage to save memory
    %mct = SimChloridesModelMgL; %MC analysis for Cl model
    mcatInput.obs = [];
    %obs = LeachOutCal.q_obsReal; %measured leachate	            % observed time-series vector [no. of samples x 1]
    %obs = ClCombinedABleachCal.ChloridesMgL;				% measured Chloride concentration	          
    mcatInput.id = modelMethods{modelMethodToPlot}; % descriptor [string]
    mcatInput.dt = 1; % sampling interval in minutes
    mcatInput.t = []; % time vector if irregularly spaced samples

    % start MCAT
    % Assign choices for MCAT plots
    plotParams = struct;
    plotParams.plotSave = true; % if save plot
    plotParams.plotExportPath = plotExportPath; % where to save
    plotParams.markerSize = 3; % size of dots in the dotty plot
    plotParams.highlightLowestParValue = false; % If to plot blue cube for lowest value in dotty plots (called best parameter in MCAT)
    % other IDEA: % Number of lines for 'Regional sensitivity analysis 2' plot, default is 10.
    
    mcat(mcatInput.pars, mcatInput.crit, mcatInput.vars, mcatInput.mct, [], mcatInput.obs,  ...
         mcatInput.id, mcatInput.pstr, mcatInput.cstr, mcatInput.vstr, mcatInput.dt, mcatInput.t, plotParams);

    %% Save figures
    % First preprare the figure
    % then save in assigned folder
    if false % Only for MANUAL execution!
        %saveFig([plotExportPath 'DottyObj_T_bh'])
        saveFig([plotExportPath 'Dotty_Obj_PlumeLength3_5diffK_1000num'])
    end
    
%     %% Calculation and plotting of percentiles TDiff due to fractures
%     keyInfoResultsCompStatTab_MC_orig = keyInfoResultsCompStatTab_MC;
%     if plotXYvar_percentiles_MC
%         %% Calculation of percentiles TDiff due to fractures
%         % Input
%         infoPerc = struct;
%         infoPerc.dataPortion = 0.05; % Portion of data (ratio) to be used for percentile calculation
%         % infoPerc.percentilesSelected = [2.5, 97.5]; % Percentiles to be calculated, 50 = median
%         infoPerc.percentilesSelected = [2.5, 50, 97.5]; % Percentiles to be calculated, 50 = median
%         
%  %        warning('confidence interval is changed from 95% to 50 %!')
%    %      infoPerc.percentilesSelected = [0.5, 50, 99.5]; % Percentiles to be calculated, 50 = median
%      %   infoPerc.percentilesSelected = [15, 50, 85]; % Percentiles to be calculated, 50 = median
%         infoPerc.dataOverlap = 0.7; %  Ratio by how much to overlap the data for moving percentiles calulation 
%         
%         % original aX varied in MC from 0 to 6m
% %         keyInfoResultsCompStatTab_MC = keyInfoResultsCompStatTab_MC_orig(keyInfoResultsCompStatTab_MC_orig.frKRatio < 1000,:);
% %         keyInfoResultsCompStatTab_MC = keyInfoResultsCompStatTab_MC(keyInfoResultsCompStatTab_MC.frDist > 30,:); 
% %         warning('fD is filtered')
%        
%         % Collect results from Homo simulations because they are used to plot Homo case line
%         keyInfoResultsCompStatTab_MC_Homo = ...
%                 keyInfoResultsCompStatTab( strcmp(keyInfoResultsCompStatTab.modelMethod, modelMethods(1)), : );
%     
%         keyInfoResultsCompStatTab_MC = keyInfoResultsCompStatTab_MC_orig;
% 
% 
%         % Prepare table for fracture parameters for plot
%         frParamsPlotTab = paramsPlotTabPrep( variant, ...
%             paramsFor_q, paramsFor_aX, paramsFor_frDist, paramsFor_frSlide, paramsFor_frThick, ...
%             paramsFor_frLength, paramsFor_frAngle, paramsFor_frKRatio, paramsFor_frH, paramsFor_frDip, paramsFor_frZ, ...
%             paramsFor_frDistShort );
%                
%         %If subplots shoud be used, open main figure here
%         if ~isempty(useSubplotDims)
%             setFigSize( figSizeSubplots(1), figSizeSubplots(2) );
%             figure
%         end
%         subPlotPosition = 0;
% 
%         % For each parameter as x variable
%         for i = 1:size(frParamsPlotTab,1)
%             frParamsPlot = frParamsPlotTab(i,:);
%             
%             % If Monte Carlo results DO NOT contain varying q
%             if  ( strcmp(importPathSuffix, importPathSuffix_fast_q) ||  ...
%                      strcmp(importPathSuffix, importPathSuffix_slow_q) ) ...
%                 && strcmp(frParamsPlot.paramName, 'q') 
%                 % Do not plot
%                 continue
%             end
%             % If Monte Carlo results DO NOT contain varying aX
%             if  ( strcmp(importPathSuffix, importPathSuffix_fast_q) ||  ...
%                      strcmp(importPathSuffix, importPathSuffix_slow_q) || ...
%                      strcmp(importPathSuffix, importPathSuffix_varied_q_fixedaXYZ) ) ...
%                 && strcmp(frParamsPlot.paramName, 'aX') 
%                 % Do not plot
%                 continue
%             end
% 
%             % Plot for varying fracture parameters
%             xVarName = frParamsPlot.paramName{1};
%         
%             % Check that x variable exists in result table, 3d fracture parameters are missing from 2d model results
%             if ~any(strcmp(keyInfoResultsCompStatTab_MC.Properties.VariableNames, xVarName))
%                warning(['X variable ' xVarName ' is not in results table so it was not plotted!'])
%                continue
%             end
% 
%             %Split data to N tables, put table to cell of table with input data for plotting, but only exception
%             %when importPathSuffix = importPathSuffix_varied_q_fixedaXYZ 
%             %new table columns: keyInfoResultsCompStatTab_MC, legendText
%             %each row another aX set
%             % If results for several fixed aXYZ values
%             if strcmp(importPathSuffix, importPathSuffix_varied_q_fixedaXYZ)
%                 % Select unique aX values
%                 aX_Unique = unique(keyInfoResultsCompStatTab_MC.aX);
%                 for i = 1:numel(aX_Unique)
%                     % Prepare single empty results row
%                     keyInfoResultsCompStatTab_MC_axMultiTab_Row = table;
%                     if contains(keyInfoResultsCompStatTab.modelMethod{1}, 'MFLS')
%                         % compose a legend text
%                         aX_RowNameValue = {sprintf('a_{xyz} = [%.1f, %.1f, %.1f]m', aXYZ_toTest(aX_Unique(i)))};
%                     elseif contains(keyInfoResultsCompStatTab.modelMethod{1}, 'MILS')
%                         % select only used aXY values from aXYZ list
%                         aXY_toTest = aXYZ_toTest(aX_Unique(i));
%                          % compose a legend text
%                         aX_RowNameValue = {sprintf('a_{xy} = [%.1f, %.1f]m', aXY_toTest(1:2))};                       
%                     end
%                     % add legend text to table
%                     keyInfoResultsCompStatTab_MC_axMultiTab_Row.legendText = aX_RowNameValue;
%                     % Select rows from result table with specific aX value
%                     keyInfoResultsCompStatTab_MC_aXSelected = keyInfoResultsCompStatTab_MC(keyInfoResultsCompStatTab_MC.aX == aX_Unique(i),:);
%                     % add table with results for specific aX to one mega table cell
%                     keyInfoResultsCompStatTab_MC_axMultiTab_Row.ResultsTab = {keyInfoResultsCompStatTab_MC_aXSelected};                    
%                     
%                     % Select rows from HOMO result table with specific aX value 
%                     keyInfoResultsCompStatTab_MC_aXSelected_Homo = keyInfoResultsCompStatTab_MC_Homo(keyInfoResultsCompStatTab_MC_Homo.aX == aX_Unique(i),:);
%                     % add also homo result to be able to plot it as "center" line later
%                     keyInfoResultsCompStatTab_MC_axMultiTab_Row.ResultsTabHomo = {keyInfoResultsCompStatTab_MC_aXSelected_Homo};
% 
% 
%                     % Calculate percentiles for this row
%                         [xVar_yVar_values_tab, xVar_yVar_perc_tab]  = ... 
%                             infoPerc_fun( keyInfoResultsCompStatTab_MC_axMultiTab_Row.ResultsTab{1}, infoPerc, xVarName, yVarName );
%                     % assign it to the mega table
%                     keyInfoResultsCompStatTab_MC_axMultiTab_Row.XY_vals = {xVar_yVar_values_tab};
%                     keyInfoResultsCompStatTab_MC_axMultiTab_Row.PercVals = {xVar_yVar_perc_tab};
% 
%                     % Extract Homo values this row
%                     [xVar_yVar_values_tabHomo, ~]  = ... 
%                         infoPerc_fun( keyInfoResultsCompStatTab_MC_axMultiTab_Row.ResultsTabHomo{1}, infoPerc, xVarName, yVarName );
%                     % assign it to the mega table
%                     keyInfoResultsCompStatTab_MC_axMultiTab_Row.XY_valsHomo = {xVar_yVar_values_tabHomo};                  
%                     
%                     keyInfoResultsCompStatTab_MC_axMultiTab(i,:) = keyInfoResultsCompStatTab_MC_axMultiTab_Row;
% 
%                 end
%             % No splitting of results needed
%             else
%                 % Prepare results table for plotting (one row only)
%                 keyInfoResultsCompStatTab_MC_axMultiTab.legendText = {'aX_SingleVal_or_Varied'};
%                 keyInfoResultsCompStatTab_MC_axMultiTab.ResultsTab = {keyInfoResultsCompStatTab_MC};
%                 % add also homo result to be able to plot it as "center" line later
%                 keyInfoResultsCompStatTab_MC_axMultiTab.ResultsTabHomo = {keyInfoResultsCompStatTab_MC_Homo};
%                 
%                 % Calculate percentiles for this row
%                 [xVar_yVar_values_tab, xVar_yVar_perc_tab]  = ... 
%                     infoPerc_fun( keyInfoResultsCompStatTab_MC_axMultiTab.ResultsTab{1}, infoPerc, xVarName, yVarName );
%                 % assign it to the mega table
%                 keyInfoResultsCompStatTab_MC_axMultiTab.XY_vals = {xVar_yVar_values_tab};
%                 keyInfoResultsCompStatTab_MC_axMultiTab.PercVals = {xVar_yVar_perc_tab};                
%                 
%                 % Extract Homo values this row
%                 [xVar_yVar_values_tabHomo, ~]  = ... 
%                     infoPerc_fun( keyInfoResultsCompStatTab_MC_axMultiTab.ResultsTabHomo{1}, infoPerc, xVarName, yVarName );
%                 % assign it to the mega table
%                 keyInfoResultsCompStatTab_MC_axMultiTab.XY_valsHomo = {xVar_yVar_values_tabHomo};                
%             end
% 
%             %% Plotting of percentiles TDiff due to fractures
%             legendLocation = 'SouthOutside'; %'NorthWest';
% 
%             % Choose colours for plotting dots and three percentile lines ising function setColorOrderPoster
%             if strcmp(importPathSuffix, importPathSuffix_varied_q)
%                 colorOrderPoster = [1 7 8 7]; %green grey dark grey
%                 colorOrder = [1 5 4 5]; %standard colours from matlab
%             elseif strcmp(importPathSuffix, importPathSuffix_slow_q)
%                 colorOrderPoster = [2 7 8 7]; %blue grey dark grey
%                 colorOrder = [2 5 4 5]; %standard colours from matlab
%             elseif strcmp(importPathSuffix, importPathSuffix_fast_q)
%                 colorOrderPoster = [3 7 8 7]; %orange grey dark grey
%                 colorOrder = [3 5 4 5]; %standard colours from matlab
%             elseif strcmp(importPathSuffix, importPathSuffix_varied_q_fixedaXYZ)
%                 colorOrderPoster = [6 7 8 7 4 7 8 7]; % green grey dark grey orange grey dark grey
%                 colorOrder = [1 8 8 8 2 8 8 8]; %standard colours from matlab
%             end
%             colors = setColorOrderPoster( colorOrderPoster ); % always this input colorOrderPoster 
%             % colors = setColorOrder( colorOrder );
%             
%             %If subplots shoud be used, do not save individual plots
%             if ~isempty(useSubplotDims)
%                 plotSaveIndividual = false;
%                 subPlotPosition = subPlotPosition + 1;
%                 %Remove "Fracture" from x label to fit on subplots
%                 xLabelText = frParamsPlot.xLabel{1};
%                 if strcmp(xLabelText(1:9), 'Fracture ')
%                     xLabelText = xLabelText(10:end); % take text after "Fracture "
%                     xLabelText(1) = upper(xLabelText(1)); % make first letter capital
%                 end
%             else
%                 plotSaveIndividual = true;
%                 xLabelText = frParamsPlot.xLabel{1};
%             end
%             
%             % Label for Y axis
%             if strcmp(yVarName, 'T_bh_Diff') % temperature change at borehole wall after 30 years difference between Homo and fracture models
%                 yLabelText = '\DeltaTb_{30y} model difference (K)';
%             elseif strcmp(yVarName, 'T_bh_RelDiff') % temperature change at borehole wall after 30 years difference between Homo and fracture models 
%                 yLabelText = '\DeltaTb_{30y} relative model difference (%)';
%                 
%            elseif strcmp(yVarName, 'xPlume_Diff_1') %Plume length for 0.5K, T_plume_listMC = [0.5 1 2 5];
%                 yLabelText = 'Longitudinal length plume 0.5K_{30y}, model difference (m)';             
%             elseif strcmp(yVarName, 'xPlume_Diff_2') %Plume length for 1K
%                 yLabelText = 'Longitudinal length plume 1K_{30y}, model difference (m)';    
%             elseif strcmp(yVarName, 'xPlume_Diff_3') %Plume length for 2K
%                 yLabelText = 'Longitudinal length plume 2K_{30y}, model difference (m)';  
%             elseif strcmp(yVarName, 'xPlume_Diff_4') %Plume length for 5K
%                 yLabelText = 'Longitudinal length plume 5K_{30y}, model difference (m)';                  
%            
%             elseif strcmp(yVarName, 'T_bh') % temperature change at borehole wall after 30 years
%                 yLabelText = '\DeltaTb_{30y} (K)';
%                 
%             elseif strcmp(yVarName, 'xPlume_1') %Plume length for 0.5K 
%                 yLabelText = 'Longitudinal plume 0.5 K length (m)';
%             elseif strcmp(yVarName, 'xPlume_2') %Plume length for 1K
%                 yLabelText = 'Longitudinal plume 1 K length (m)';
%             elseif strcmp(yVarName, 'xPlume_3') %Plume length for 2K
%                 yLabelText = 'Longitudinal plume 2 K length (m)';
%             elseif strcmp(yVarName, 'xPlume_4') %Plume length for 5K
%                 yLabelText = 'Longitudinal plume 5 K length (m)';
%                 
%             elseif strcmp(yVarName, 'area_q50perc')
%                 yLabelText = 'Area with v_D slowed to 50% (m^2)';
%             end
% 
% 
%             % Plot plotTbDiff_q_perc_MC Temperature difference between Hom and Hetero (with fracture) models with 
%             % similarly varied gw flow and dispersivity and for different fracture params in Monte Carlo
%             model = 'MonteCarlo'; %only used for plot title
%             plotNamePrefix = [yVarName '_' xVarName '_perc_MC' ];
%             % give as input table with data
%             plotXYvar_percentiles_funMC( xVarName, yVarName, keyInfoResultsCompStatTab_MC_axMultiTab, ...
%                                          model, xLabelText, yLabelText, frParamsPlot.xUnitCoef, frParamsPlot.useSemiLogX, colors, ...
%                                          legendLocation, figSize, plotXYvar_percentiles_MC_lines, useSubplotDims, subPlotPosition, infoPerc.percentilesSelected )
%             %  Save plot if requested   
%             if plotSave && plotSaveIndividual == true   
%                 dataTotalCount = size(keyInfoResultsCompStatTab_MC_axMultiTab.ResultsTab{1}, 1);
%                 plotName = sprintf('plot%s_dataPortion%.2f_dataOverlap%.1f_%dsimuls_size%.2f', ...
%                     plotNamePrefix, infoPerc.dataPortion, infoPerc.dataOverlap, dataTotalCount, figSize(1) );
%                 saveFig([plotExportPath plotName])
%             end
%         end
%     
%         
%         %If subplots shoud be used, save whole plot at end
%         if ~isempty(useSubplotDims)
%             %  Save plot if requested   
%             if plotSave    
%                 plotNamePrefix = 'Subplots_perc_MC';
%                 dataTotalCount = size(keyInfoResultsCompStatTab_MC, 1);
%                 plotName = sprintf('%s_plot%s_dataPortion%.2f_dataOverlap%.1f_%dsimuls_size%.2f', ...
%                    yVarName, plotNamePrefix, infoPerc.dataPortion, infoPerc.dataOverlap, dataTotalCount, figSizeSubplots(1) );
%                 saveFig([plotExportPath plotName])
%             end
%         end
%         
%     end
end
