function [ planViewData, profileViewData, profilePipeData, planView_filename, profileView_filename, paramsIndexTxt, paramsString ] = ...
    comsolExportFileNamePrep(model, solution, modelDimension, params, paramsIndex, exportFolder)
% Prepare column names to go in the results table and file name to be then exported from comsol
% Input params:
% model - COMSOL model object, contains connection to comsol server with
%         all COMSOL data (mesh, solution defined, materials of aquifer..)
% solution - solution identification to compute and export, for example
%           'sol1' with time series defined
% params - structure with selected parameters, for current parameter list
%          see comsolSetParams
% modelDimension - 3D, 2Dplan or 2Dprofile
% Output params
% planViewData, profileViewData, profilePipeData = names of tags used for exported data
    
    %% Prepare file names for export
    % Determine which Export data choice to use depending on computed solution
    profilePipeData = []; % By default no pipes in model are expected
                    
    if strcmp(solution, 'sol1') == true
        if strcmp(modelDimension, '3D')
            planViewData = 'data2'; % identification names recorder by comsol, 'data2, and similar names below are not descriptions but identifications
            profileViewData = 'data3';
            % If model contains pipe export T profile for pipes
            if isModelWithPipe( params )
                profilePipeData = 'data4'; %Data 4 VBHE temperature Pipe Profile 
            end
            
        elseif strcmp(modelDimension, '2Dplan') % 2Dplan
            planViewData = 'data1';
            profileViewData = [];
        else % 2Dprofile
            planViewData = [];
            profileViewData = 'data1';
        end
    else
        assert(false, ['Unsupported solution name: ' solution]) 
    end
    
    % Construct file names for exported data
    % example file name: 'export\plan sol2 q=[5.78704e-07] axyz=[2 0.2 0.2] fe=[5000].txt'
    % Construct string with parameter values
    paramsString  = comsolParams2String( params );
    % Convert index for parameters combination into string, keep zeros in front for good allingment of txt files list in export folder 
    paramsIndexTxt = sprintf('%04d', paramsIndex);
    
    
    % File name for export data for COMSOL as plane slice in plan or profile view (2D)
    if ~isempty(planViewData)
        % Construct full string (name of txt file) for plan and profile
        planView_filename = ['plan ' solution ' ' paramsIndexTxt ' ' paramsString '.txt'];
        planView_filename_WithPath = [exportFolder, planView_filename];
        % Use the constructed file name for export
        model.result().export(planViewData).set('filename', planView_filename_WithPath);
    else
       planView_filename = []; % empty by default if not required
    end
    
    if ~isempty(profileViewData)
        % Construct full string (name of txt file) for plan and profile
        profileView_filename = ['profile ' solution ' ' paramsIndexTxt ' ' paramsString '.txt'];
        profileView_filename_WithPath = [exportFolder, profileView_filename];
        % Use the constructed file name for export
        model.result().export(profileViewData).set('filename', profileView_filename_WithPath);
    else
       profileView_filename = [];  % empty by default if not required
    end
    
    if ~isempty(profilePipeData)
        % Construct full string (name of txt file) for pipe
        profilePipe_filename = ['pipeT ' solution ' ' paramsIndexTxt ' ' paramsString '.txt'];
        profilePipe_filename_WithPath = [exportFolder, profilePipe_filename];
        % Use the constructed file name for export
        model.result().export(profilePipeData).set('filename', profilePipe_filename_WithPath);
    end

    % Construct full file name of txt file for 'q info' export
    qInfo_filename = [exportFolder 'qInfo ' solution ' ' paramsIndexTxt ' ' paramsString '.txt'];
    % Use the constructed file name for export
    model.result().export('tbl1').set('filename', qInfo_filename);

end

