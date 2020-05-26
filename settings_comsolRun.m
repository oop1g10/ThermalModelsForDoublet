function [ comsolPath, exportPath, comsolLibrary, showComsolProgress ] = settings_comsolRun( runOnIridisLinux )
%SETTINGS_COMSOLRUN returns all names and settings needed for comsol run

if runOnIridisLinux
    % Current folder from which matlab was executed
    [~,dirAttrib] = fileattrib('.'); % get attributes of current folder
    comsolPath = [dirAttrib.Name '/'];
    exportPath = [comsolPath 'export/'];
    comsolLibrary = '/local/software/comsol/5.5/mli';
    showComsolProgress = false; % progress info
else % if computation is on Windows
    %comsolPath = 'D:\COMSOL\cylinder mesh\';
    comsolPath = 'D:\COMSOL_INRS\models\';
    exportPath = [comsolPath 'export\'];
    comsolLibrary = 'C:\Program Files\COMSOL\COMSOL55\Multiphysics_copy1\mli';
    showComsolProgress = true; % progress info
end

end

