function [comsolDataFile, comsolDataFileConvergence, modelMethods, modelMethodsConvergence, variant, ...
            solution, methodMesh, rSource_notUsed, maxMeshSize ] = ...
            comsolDataFileInUse_Info( )
        
    rSource_notUsed = NaN; % historical not used value
    % Model decisions: Choose ONLY ONE TRUE
    model_2dPlanComsol = true; 
    model_3dComsol = ~model_2dPlanComsol; % if 2d is selected, 3d choise is automatically FALSE

    % Standard general settings
    folder = 'D:\COMSOL_INRS\export\'; 
    solution = 'sol1'; % solution used in comsol
    % Load results comsolResultsTab from Comsol calculations
    %% 2D
    if model_2dPlanComsol
        comsolDataFileConvergence = [folder  'comsolData_sol1_doubletMeshConvergence_2d.mat'];

        % variant =  'paper_Schulz';%
        % variant = 'Homo'; %
        % comsolDataFile = [folder 'comsolData_sol1_doublet_2d.mat']; 
        % comsolDataFile = [folder 'comsolData_sol1_doubletStdplots4gw_2d.mat'];
        
        variant = 'FieldExp1'; %  
        comsolDataFile = [folder 'comsolData_sol1_doubletTry_2d.mat']; 
        
        modelMethods = {'Schulz', 'nDoublet2D'}; % 'nDoublet2D'
        modelMethodsConvergence = {'Schulz', 'nDoublet2D'};
        % "max el size (m) at wel wall in comsol, optimal mesh size
        maxMeshSize = 0.1;
        methodMesh = '2d'; % name of method of meshing in comsol
    % 3D
    elseif model_3dComsol
        comsolDataFile = [folder  'comsolData_sol1_doublet_3d.mat']; %        
        variant = 'Homo'; %scenario with permeable matrix
        modelMethods = {'nDoublet3D', 'nDoublet3D'}; %original           
    
        comsolDataFileConvergence = [folder  'comsolData_sol1_doubletMeshConvergence_3d.mat'];           
        modelMethodsConvergence = {'Schulz', 'nDoublet3D'};
        maxMeshSize = 0.04; % optimesh 
        methodMesh = '3d'; % name of method of meshing in comsol
    end
end

