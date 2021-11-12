clear
% Run Comsol server before running this script

%% Computation Options
runOnIridisLinux = isunix(); % Automatically puts true if computed on Iridis Linux (unix) system
saveComsolResultMPH = false; % Save model file after computation
noCalcOnlyParamsSaveMPH = false; % In case of batch runs to use only single Comsol-Matlab LiveLink licence, 
                                % to set params on mph and save it, do not run Comsol through Matlab
%% Parameters to calculate
paramsFor_FieldTest = false; % minimum number of params for test model runs
paramsFor_standardPlots = false;
paramsFor_plottb_a_Q_q = false;
paramsFor_meshConvergence = true;
% One at a time sensitivity analysis
paramsFor_q = false;
paramsFor_aXYZ = false;
paramsFor_alpha_deg = false;
paramsFor_cS = false;
paramsFor_lS = false;
paramsFor_Ti = false;
paramsFor_n = false;
paramsFor_H = false;
paramsFor_Q = false; 
paramsFor_a = false;

[comsolDataFile, comsolDataFileConvergence, modelMethods, modelMethodsConvergence, variant,...
    solution, methodMesh, ~, ~ ] = comsolDataFileInUse_Info( );

[ ~, q_list, ~, ~, ~, ~, ~, ~, ~, ~, ~, ~, ~, ~, ~, ~, Q_list, a_list ] = ...
    standardRangesToCompare( variant );

%% Run settings
% Folder with export files
if runOnIridisLinux
    addpath('~/comsol/matlab_files') % Tell matlab where all functions are located
end

[~, ~, ~, ~, ~, solution, methodMesh, ~, ~ ] = comsolDataFileInUse_Info( );
fprintf('methodMesh: %s\n', methodMesh);

% set folder names for comsol run
[ comsolFile, exportPath, comsolLibrary, showComsolProgress ] = settings_comsolRun( runOnIridisLinux, methodMesh, variant );

%List of parameter combination indices to calculate, [] means all
paramsIndicesToCalculate = [];
%paramsIndicesToCalculate = [4]; % Set to [1:10] for example to calculate first 10 only
% Allow to change this from Linux command line by specifying ENV variable:
% export MATLAB_EVAL="paramsIndicesToCalculate=[1:2];"
% By getting this ENV variable and evaluating it the variable paramsIndicesToCalculate in Matlab is changed
env_MATLAB_EVAL = getenv('MATLAB_EVAL');
if ~isempty(env_MATLAB_EVAL)
    fprintf('Evaluating extra parameters: %s\n', env_MATLAB_EVAL);
    eval(env_MATLAB_EVAL);
end

%% Input flow and heat tranpost parameters
% Standard model parameters
paramsStd = standardParams(variant);

%% Prepare list of parameters to loop the calculation
% Parameters for standard plots
paramsCombinationsTab = table;
if paramsFor_FieldTest
    paramsList = paramsStd;
    % paramsList.alpha_deg = [90, 0]; % direction of groundwater flow
    % Prepare combinations of all parameters to run model through
    paramsCombinationsTab = [paramsCombinationsTab; paramsCombinationsPrep(paramsList)];
    
    % Calculate numerical model with parameters of calibrated analytical model
    % paramsCalib = paramsFromCalib('Numerical2: RunCount:558 WIDER ranges init 431. zerodisp', variant);
    paramsCalib = paramsFromCalib('Numerical2: 424', variant);
    paramsList = paramsCalib;
%     paramsCombinationsTab = [paramsCombinationsTab; paramsCombinationsPrep(paramsList)];

%     paramsCalib = paramsFromCalib('Analytical: from Init424', variant);
%     paramsList = paramsCalib;
    
    % List of q (gw velocity)
    paramsList.q = q_list; % add zero groundwater velocity as first in list    
    % List of aXYZ (aquifer dispersivities in 3D)
    aXYZ_list = aXYZ_toTest( [0 2] ); % longitudinal dispersivity [m]
    paramsList.aX = aXYZ_list(:,1)'; 
    paramsList.aY = aXYZ_list(:,2)'; 
    paramsList.aZ = aXYZ_list(:,3)';
    paramsCombinationsTab = [paramsCombinationsTab; paramsCombinationsPrep(paramsList)];
end
if paramsFor_standardPlots
    paramsList = paramsStd;
    % List of q (gw velocity)
    paramsList.q = q_list; % add zero groundwater velocity as first in list    
    % List of aXYZ (aquifer dispersivities in 3D)
    aXYZ_list = aXYZ_toTest( [0 2] ); % longitudinal dispersivity [m]
    paramsList.aX = aXYZ_list(:,1)'; 
    paramsList.aY = aXYZ_list(:,2)'; 
    paramsList.aZ = aXYZ_list(:,3)';
    % Prepare combinations of all parameters to run model through
    paramsCombinationsTab = [paramsCombinationsTab; paramsCombinationsPrep(paramsList)];
end
if paramsFor_plottb_a_Q_q
    paramsList = paramsStd;
    % List of q (gw velocity)
    paramsList.q =  q_list(2:end); % add zero groundwater velocity as first in list    
    % List of flow in injection well [m^3/second]
    paramsList.Q = Q_list;
    % List of Half distance between injection and abstraction wells [m]
    paramsList.a = a_list;
    % fixed angle of g flow
    paramsList.alpha_deg = 180; % 
    % Prepare combinations of all parameters to run model through
    paramsCombinationsTab = [paramsCombinationsTab; paramsCombinationsPrep(paramsList)];
end
if paramsFor_meshConvergence
    paramsList = paramsStd;
    [ ~, q_list, aXYZ_list, ~, ~, ~, ~, ~, ~, ~ ] = standardRangesToCompare( variant );
    if strcmp(methodMesh, '2d')
        paramsList.maxMeshSize = [ 0.02 0.03 0.04 0.05 0.07 0.1 0.13 0.16 0.2 0.25 0.3]; % max mesh size at source [m] optimal = 0.01
      %  paramsList.maxMeshSize = [0.05 0.04 0.03 0.02 0.015 0.012 0.011 0.01 0.009 0.008 0.007 0.006 0.0055 0.005 0.0045 0.004]; % max mesh size at source [m] optimal = 0.01
    else % 3D
        %paramsList.maxMeshSize = [0.08 0.07 0.06]; % max mesh size at source [m] handmade optimal = 0.04        
       paramsList.maxMeshSize = [ 0.039 0.040 0.041 0.044 0.045 0.046 0.047 0.048 0.049 0.05 0.06 0.07 0.08 ...
           0.036 0.037 0.038 ]; % %NOTE! mesh 0.042 0.043 has stiffness matrix error when calculates, so excluded from the list.
       warning(' 0.036 0.037 0.038 = try for HIGH MEM!!!!!!!!! not enough memory for normal green comps')
       % max mesh size at source [m] handmade optimal = 0.04        
 %       paramsList.maxMeshSize = [ 0.3 0.25 0.2 0.15 0.1 0.07 0.06 0.05 0.04 0.039 ]; % max mesh size at source [m] handmade optimal = 0.04        
        % WARNING maxMeshSize smaller than 0.039 cannot be computed due to lack of memory on my comp and on Iridis
    end
%     % Better do mesh convergence with nonzero groundwater flow and non zero dispersivity
%     paramsList.q = q_list; %q_list(3); % non zero groundwater velocity
%     paramsList.aX = aXYZ_list(2,1); % non zero ax 
%     paramsList.aY = aXYZ_list(2,2); 
%     paramsList.aZ = aXYZ_list(2,3); 
    % Prepare combinations of all parameters to run model through
    paramsCombinationsTab = [paramsCombinationsTab; paramsCombinationsPrep(paramsList)];
end

%% One at a time sensitivity analysis 
% Prepare unique combinations of parameters
paramsCombinationsTab_oneAtATime = ...
        standardParamsCombinations( variant, paramsFor_q, paramsFor_aXYZ, paramsFor_alpha_deg, paramsFor_cS, ... 
                                            paramsFor_lS, paramsFor_Ti, paramsFor_n, paramsFor_H, ...
                                            paramsFor_Q, paramsFor_a );
paramsCombinationsTab = [paramsCombinationsTab; paramsCombinationsTab_oneAtATime];


% Remove duplicated parameter combinations
paramsCombinationsTab = unique(paramsCombinationsTab);

%% Start connection to comsol server and open model file
% Show progress bar for longer computations, 130 underscores is to make it big enough for messages contaning params
hWait = waitbar(0,['Connecting to COMSOL and openning model ... ' repmat('~', 1, 130)], ...
                'Name','Calculating model for your parameter combinations, please wait :) ...');
import com.comsol.model.*
import com.comsol.model.util.*
addpath(genpath(comsolLibrary));
% Connect to COMSOL server
% If COMSOL server is already connected, then do nothing
try
    mphstart;
catch exception
    a = 1;
    % Already connected, do nothing
end
% Switch on the progress bar if requested
ModelUtil.showProgress(showComsolProgress); % display the PROGRESS BAR
% Open model file
model = mphload(comsolFile); % load model

%% Calculate model for all combinations of parameters and Export the results OR for batch runs just save many mph with params
% Set list of parameter indices to calculate to all if empty
%paramsIndicesToCalculate = 31; % index in parameters combinations table of row with standard parameters set for Tight matrix scenario
if isempty(paramsIndicesToCalculate)
    % Use all parameter combinations
    paramsIndicesToCalculate = 1:size(paramsCombinationsTab,1);
else
    % Ensure only valid indices up to size(paramsCombinationsTab,1) are used
    paramsIndicesToCalculate = intersect(paramsIndicesToCalculate, 1:size(paramsCombinationsTab,1));
    warning('Restricting calculation to requested parameter combinations only.')
end

% In case of batch runs to use only single Comsol-Matlab LiveLink licence,
% do not run Comsol through Matlab, only save empty mph file with desired parameters.
% This mph file will be executed without matlab just by running comsol batch job mode
if noCalcOnlyParamsSaveMPH
    % Prepare table columns names in comsol for export of data. It has to be done with solution precalculated
    % because otherwise tab prep does not function
    comsolExportTabPrep(model);
end

progressIndex = 0; %index for showing progress
for i = paramsIndicesToCalculate % i is index of particular parameter combination
    % Current parameters to calculate
    params = table2struct(paramsCombinationsTab(i,:));
    
    %% Show progress
    progressIndex = progressIndex + 1;
    paramsString = comsolParams2String( params );
    waitbar(progressIndex/numel(paramsIndicesToCalculate), hWait, ['Calculating ' paramsString]); %show progress
    % Show which parameters are calculated, %4d formats the number to width 4 so ids texts is aligned in column in the log file (on iridis)
    fprintf('Calculating %4d: %s\n', i, paramsString);
    % Calculate model
    tic(); % Start measure of time needed for one model calculation
    % Set these parameters into the model
    comsolSetParams( model, params );
    
    % In case of batch runs to use only single Comsol-Matlab LiveLink licence,
    % do not run Comsol through Matlab, only save empty mph file with desired parameters.
    % This mph file will be executed without matlab just by running comsol batch job mode
    if noCalcOnlyParamsSaveMPH
        % Prepare export file name in comsol for export of data
        comsolExportFileNamePrep(model, solution, methodMesh, params, i, exportPath);
        % Clear mesh and solution before saving
        model.mesh().clearMeshes();
        model.sol("sol1").clearSolutionData();
        % Save mph file
        paramsIndexTxt = sprintf('%04d', i);
        comsol_filename = [exportPath 'model_' solution '_job_' paramsIndexTxt '.mph'];
        mphsave(model, comsol_filename);      
    else
        % Compute model solution and export results
        comsolComputeAndExport( model, solution, methodMesh, params, i, exportPath, saveComsolResultMPH );
    end
    % Stop calculation time duration measurement
    calcDurationSeconds = toc();
    fprintf('Finished %4d, time %7.2f minutes: %s\n', i, calcDurationSeconds / 60, paramsString); % print in log file
end
close(hWait); %close progress window

%% Disconnect from Comsol server
% Remove model from comsol server memory (close mph file)
ModelUtil.remove('model')
ModelUtil.disconnect;
