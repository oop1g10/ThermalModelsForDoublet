function t_listComparison = timesForComparison(variant)
% Return list of modelled times which correspond to measured times
% this list is not rounded so can be searched in the table with measurements

% 

    % Load measured data that was imported and saved as mat file
    % Extract name of data file with measured temperatures and Variant
    [~, ~, ~, ~, ~, ~, ~, ~, ~, ~, wellTempDataFileImportCompare ] = ...
                comsolDataFileInUse_Info( );
    % Load table with results wellTempTabTest
    persistent t_listTest
    if isempty(t_listTest)
        load(wellTempDataFileImportCompare, 't_listTest');
    end
    % Returned variable name cannot be the same as name of the persistent variable.  
    t_listComparison = t_listTest;
    % For analytical solution Test2 Rotated only times from the first day
    % of heat injection are taken. Because after heat injection rate
    % changes. Analytical soltuion assumes constant heat injection rate. 
    if strcmp(variant, 'FieldExp2Rotated')
        % Keep only times up to one day
        t_listComparison = t_listComparison(secondsToDays(t_listComparison) < 1);

        % Remove two times from the list for test 2 rotated, because in
        % these times temperature sensors from well 4 were removed and the
        % measurements are wrong
        t_listComparison = t_listComparison( t_listComparison ~= 68459.904 );
        t_listComparison = t_listComparison( t_listComparison ~= 7.206019200000001e+04 );
    end
    
end


