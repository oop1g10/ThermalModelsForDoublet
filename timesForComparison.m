function t_listComparison = timesForComparison(variant)
% Return list of modelled times which correspond to measured times
% this list is not rounded so can be searched in the table with measurements

% 

    % Load measured data that was imported and saved as mat file
    % Extract name of data file with measured temperatures and Variant
    [~, ~, ~, ~, ~, ~, ~, ~, ~, ~, wellTempDataFileImportCompare ] = ...
                comsolDataFileInUse_Info( );
    % Load table with results wellTempTabTest1
    persistent t_listTest
    if isempty(t_listTest)
        load(wellTempDataFileImportCompare, 't_listTest1');
        t_listTest = t_listTest1;
    end
    % Returned variable name cannot be the same as name of the persistent variable.  
    t_listComparison = t_listTest;
end


