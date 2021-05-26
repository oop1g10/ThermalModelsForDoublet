function paramsCombinationsTab = paramsCombinationsPrep( paramsList )
% Prepare table of parameter sets to sample from to conduct model comparison
    
    % Get names of parameters to combine
    paramNames = fieldnames(paramsList);
    
    % Prepare array of cells, each cell with one parameter or parameter list
    paramsInCells = cell(1, numel(paramNames));
    for i = 1:numel(paramNames)
        paramsInCells(i) = {paramsList.(paramNames{i})};
    end
    
    % Create all combinations (systematic) of parameters as matrix, rows
    % correspond to one parameter, columns for each combinations of
    % parameters, but it is transposed so it is THE OTHER WAY AROUND.
    % Dynamic input as varargin paramsInCells{:} turns array of cells into separate arguments, 
    % values of cells (opened cells = matrices)
    % combvec_copy is inbuilt Matlab function from Deep learning toolbox.
    % here a copy of it is used because on madison computer it is not
    % installed.
    paramsCombinationsMatrix = combvec_copy( paramsInCells{:} )';
    
    % Save combinations as table with columns corresponding to parameter
    % names and rows to each combination set
    paramsCombinationsTab = array2table(paramsCombinationsMatrix, 'VariableNames', paramNames);

    % Specific case for dispersivities: add aY and aZ based on specified proportions to aX.
%     aXYZ_list = aXYZ_toTest( paramsCombinationsTab.aX' );
    paramsCombinationsTab.aY = paramsCombinationsTab.aX;
    paramsCombinationsTab.aZ = paramsCombinationsTab.aX;
    
    % Specific case for Aquifer thickness and well depth: add M same as H.
    paramsCombinationsTab.M = paramsCombinationsTab.H;

end
