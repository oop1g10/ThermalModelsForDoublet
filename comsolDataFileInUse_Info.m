function [comsolDataFile, comsolDataFileConvergence, modelMethods, modelMethodsConvergence, variant, ...
            solution, methodMesh, rSource_notUsed, maxMeshSize, ...
            wellTempDataFileImport, wellTempDataFileImportCompare, exportPath ] = ...
            comsolDataFileInUse_Info( )
        
    rSource_notUsed = NaN; % historical not used value
    % Model decisions: Choose ONLY ONE TRUE
    model_2dPlanComsol = true; 
    model_3dComsol = ~model_2dPlanComsol; % if 2d is selected, 3d choise is automatically FALSE

    % Standard general settings
    if isMyComputer()
        exportPath = 'D:\COMSOL_INRS\export\'; 
    else % Madison computer is used. Change Comsol folder
        exportPath = 'E:\Sasha\COMSOL_INRS\export\';         
    end
    solution = 'sol1'; % solution used in comsol
    % Load results comsolResultsTab from Comsol calculations
    %% 2D
    if model_2dPlanComsol
       % warning('return comsolDataFileConvergence back to default')
      %  comsolDataFileConvergence = [exportPath  'comsolData_sol1_doubletMeshConvergence_0dispersion_6mDepth_2d.mat']; 
        comsolDataFileConvergence = [exportPath  'comsolData_sol1_doubletMeshConvergenceQ3HM3000_2d.mat'];

    %    variant =  'paper_Schulz';%
        % variant = 'Homo'; %
        % comsolDataFile = [folder 'comsolData_sol1_doublet_2d.mat']; 
        % comsolDataFile = [folder 'comsolData_sol1_doubletStdplots4gw_2d.mat'];
        
        % FieldExp 1 = first field experiment, FieldExpAll = all experiments (4 steps: Test1, monitoring1, Test2, monitoring2).  
         variant = 'FieldExp1'; 
         comsolDataFile = [exportPath 'comsolData_sol1_doubletTry_2d.mat']; 
 %        variant = 'FieldExp1m'; 
  %       comsolDataFile = [exportPath 'comsolData_sol1_doubletTest1m_2d.mat']; 
      %   variant = 'FieldExp2'; 
       %  comsolDataFile = [exportPath 'comsolData_sol1_doubletTest2_2d.mat']; 
        % variant = 'FieldExp2Rotated'; 
        % comsolDataFile = [exportPath 'comsolData_sol1_doubletTest2Rotated_2d.mat']; 
%         variant = 'FieldExpAll'; 
%         comsolDataFile = [exportPath 'comsolData_sol1_doubletAll_2d.mat']; 
        
        modelMethods = {'Schulz', 'nDoublet2D'}; % 'nDoublet2D'
        modelMethodsConvergence = {'Schulz', 'nDoublet2D'};
        % "max el size (m) at wel wall in comsol, optimal mesh size
        maxMeshSize = 0.1;
        methodMesh = '2d'; % name of method of meshing in comsol
    % 3D
    elseif model_3dComsol
        comsolDataFile = [exportPath  'comsolData_sol1_doublet_3d.mat']; %        
        variant = 'Homo'; %scenario with permeable matrix
        modelMethods = {'nDoublet3D', 'nDoublet3D'}; %original           
    
        comsolDataFileConvergence = [exportPath  'comsolData_sol1_doubletMeshConvergence_3d.mat'];           
        modelMethodsConvergence = {'Schulz', 'nDoublet3D'};
        maxMeshSize = 0.04; % optimesh 
        methodMesh = '3d'; % name of method of meshing in comsol
    end
    
    % Name of data file with measured temperatures
    wellTempDataFileName = 'wellTempData.mat';
    wellTempDataFileImport = [exportPath, wellTempDataFileName]; % place and name where to save results in matfile 
    if strcmp(variant, 'FieldExpAll')
        wellTempDataFileImportCompare = [exportPath, 'wellTempDataTestAll.mat']; % place and name where to save results in matfile 
    elseif strcmp(variant, 'FieldExp2') || strcmp(variant, 'FieldExp2Rotated')
        wellTempDataFileImportCompare = [exportPath, 'wellTempDataTest2.mat']; % place and name where to save results in matfile 
    elseif strcmp(variant, 'FieldExp1')
        wellTempDataFileImportCompare = [exportPath, 'wellTempDataTest1.mat']; % place and name where to save results in matfile 
    elseif strcmp(variant, 'FieldExp1m')
        wellTempDataFileImportCompare = [exportPath, 'wellTempDataTest1m.mat']; % place and name where to save results in matfile 
    else 
        warning('no such variant for well temperature measurements')
        % No measurements exist for this case but it is returned to avoid
        % errors!!!!!!!!!!!!!
        wellTempDataFileImportCompare = [exportPath, 'wellTempDataTestAll.mat']; % place and name where to save results in matfile 
    end
end

