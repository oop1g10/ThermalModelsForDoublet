clear
clc
%
folder = 'D:\COMSOL_INRS\export\';
results = 'doubletStdplots4gw' ; %'doubletMeshConvergenceQ3HM3000'; %'doubletMeshConvergence' ; % ;'doublet'; % 
[~, ~, ~, ~, ~, solution, methodMesh, ~, ~ ] = comsolDataFileInUse_Info( );
fprintf('methodMesh: %s \n', methodMesh);
% Name of data file with comsol imported results
comsolDataFileName = sprintf('comsolData_%s_%s_%s.mat', solution, results, methodMesh);
comsolDataFileImport = [folder, comsolDataFileName] ; % place and name where to save results in matfile 

%% Import
comsolResultsTab = table; % to empty the table
% Comsol export folder to process       
comsolImportPath = [folder solution '_' results '_' methodMesh '\'];
fprintf('Comsol import path (where the txt files are taken) is: \n%s \n', comsolImportPath) % \n = new line

fileList = dir(comsolImportPath); % list of files on disk
% Show progress bar for longer computations, 170 * ~ is to make it big enough for messages contaning params
hWait = waitbar(0, repmat('~', 1, 170), 'Name','Importing results ...');
for i = 1:numel(fileList)
     % Get filename from list
    filename = fileList(i).name;
    % Skip file names '.' (current folder) and  '..' (parent folder) and any not .txt (for example .mph files)
    if filename(1) == '.' || ~strcmp(filename(end-3:end), '.txt')
        continue;
    end
    % Skip file names 'qInfo ...' becasue they are imported separately (see below)
    % qInfo file contains additional info from probes and calculations within comsol 
    % (e.g. area of specified change in groundwater velcity, e.g. -20%)
    if comsolFilename_Type(filename, 'qInfo')
        continue;
    end

    % Show progress info bar
    waitbar(i/numel(fileList), hWait, filename); %show progress

    % Import Comsol results
    comsolResultsTabRow = comsolResultsRowImportFile( comsolImportPath, filename );

    % Add new results to the results table
    comsolResultsTab = comsolResultsTabAdd(comsolResultsTab, comsolResultsTabRow);  
end
close(hWait); %close progress window


% Save comsol results workspace variable
% Version 7.3 is needed to support files >= 2GB, but older matlab versions cannot read
% this format of table saving. 
% Note minus '-v...' before version name = it means read it as Version to save file, not as string only.
save(comsolDataFileImport, 'comsolResultsTab', '-v7.3'); 

fprintf('Data is saved with name %s \n ', comsolDataFileImport)

