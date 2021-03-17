function [ comsolFile, exportPath, comsolLibrary, showComsolProgress ] = settings_comsolRun( runOnIridisLinux, methodMesh, variant )
%SETTINGS_COMSOLRUN returns all names and settings needed for comsol run

if runOnIridisLinux
    % Current folder from which matlab was executed
    [~,dirAttrib] = fileattrib('.'); % get attributes of current folder
    comsolPath = [dirAttrib.Name '/'];
    exportPath = [comsolPath 'export/'];
    comsolLibrary = '/local/software/comsol/5.5/mli';
    showComsolProgress = false; % progress info
elseif isMyComputer() % if computation is on my laptop
    % if computation is on Windows
    %comsolPath = 'D:\COMSOL\cylinder mesh\';
    comsolPath = 'D:\COMSOL_INRS\models\';
    exportPath = [comsolPath 'export\'];
    comsolLibrary = 'C:\Program Files\COMSOL\COMSOL56\Multiphysics\mli';
    showComsolProgress = false; % progress info
else % Madison computer is used. Change Comsol folder
    comsolPath = 'E:\Sasha\COMSOL_INRS\models\';
    exportPath = [comsolPath 'export\'];
    comsolLibrary = 'C:\Program Files\COMSOL\COMSOL56\Multiphysics_copy1\mli';
    showComsolProgress = false; % progress info
end

if  strcmp(methodMesh, '3d')
    %Distinguish model name without and with pipe
    comsolFile = [comsolPath '3D_TODO_Matlab'];
elseif strcmp(methodMesh, '2d')
    % Distinguish model accoring to variant
    % FieldExp 1 = first field experiment; FieldExp1m = first field experiment with monitoring;
    %FieldExpAll = all experiments (4 steps: Test1, monitoring1, Test2, monitoring2).
    if  strcmp(variant, 'FieldExpAll')
        comsolFile = [comsolPath 'doublet_2d_AllTests_Matlab'];        
    elseif strcmp(variant, 'FieldExp2')
        comsolFile = [comsolPath 'doublet_2d_Test2_Matlab'];        
    elseif strcmp(variant, 'FieldExp1')
        comsolFile = [comsolPath 'doublet_2d_Matlab'];     
    elseif strcmp(variant, 'FieldExp1m')
        comsolFile = [comsolPath 'doubletMonitoring_2d_Matlab'];
    end
else
    error('Please specify correct model dimension!')
end


end

