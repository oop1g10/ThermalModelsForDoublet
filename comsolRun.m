function [comsolResultsTab, calcDurationSeconds] = comsolRun(params, paramsIndex, disconnect)
%comsolRun  runs Comsol with given parameters and returns table with
%results (from .txt file exported by comsol)
    % set folder names for comsol run
    runOnIridisLinux = isunix(); % Automatically puts true if computed on Iridis Linux (unix) system
    saveComsolResultMPH = false; % Save model file after computation
    
    [~, ~, ~, ~, variant, solution, methodMesh, ~, ~ ] = comsolDataFileInUse_Info( );
    % set folder names for comsol run
    [ comsolFile, exportPath, comsolLibrary, showComsolProgress ] = settings_comsolRun( runOnIridisLinux, methodMesh, variant );

    %% Start connection to comsol server and open model file
    import com.comsol.model.*
    import com.comsol.model.util.*
    addpath(genpath(comsolLibrary));
    % Connect to COMSOL server
    % If COMSOL server is already connected, then do nothing
    try
        % mphstart;
        mphstart('10.20.114.29',2037)
        % mphstart('10.20.114.29',2036)
    catch exception
        if ~contains(exception.message, 'Already connected to a server')
            warning(exception.message)
        end
        a = 1;
        % Already connected, do nothing
    end
    
    % Open model file
    persistent model
    if isempty(model)
        model = mphload(comsolFile); % load model            
    end
    
    % Switch on the progress bar if requested
    ModelUtil.showProgress(showComsolProgress); % display the PROGRESS BAR

    tic(); % Start measure of time needed for one model calculation
    % Set these parameters into the model
    comsolSetParams( model, params );
    
    % Compute model solution and export results
    [planView_filename, profileView_filename] = ...
        comsolComputeAndExport( model, solution, methodMesh, params, paramsIndex, exportPath, saveComsolResultMPH );
    % Import results from .txt files into comsolResultsTab
    comsolResultsTab = table;
    % Plan view
    if ~isempty(planView_filename)
        % Import Comsol results
        comsolResultsTabRow = comsolResultsRowImportFile( exportPath, planView_filename );
        % Add new results to the results table
        comsolResultsTab = comsolResultsTabAdd(comsolResultsTab, comsolResultsTabRow, variant);  
    end
    % Profile view
    if ~isempty(profileView_filename)
        % Import Comsol results
        comsolResultsTabRow = comsolResultsRowImportFile( exportPath, profileView_filename );
        % Add new results to the results table
        comsolResultsTab = comsolResultsTabAdd(comsolResultsTab, comsolResultsTabRow, variant);  
    end
    
    % Stop calculation time duration measurement
    calcDurationSeconds = toc();
    fprintf('Finished %4d, time %7.2f minutes\n', paramsIndex, calcDurationSeconds / 60); % print in log file

    %% Disconnect from Comsol server
    if disconnect
        % Remove model from comsol server memory (close mph file)
        ModelUtil.remove('model') % close mph in server
        ModelUtil.disconnect;    % close comsol server
    end

end

