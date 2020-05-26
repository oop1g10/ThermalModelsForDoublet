function comsolSetParams( model, params )
% Set Comsol parameters
% model - COMSOL model object, contains connection to comsol server with
%         all COMSOL data (mesh, solution defined, materials of aquifer..)
% params - structure with selected parameters, current example:
%        q: 5.7870e-07
%     aXYZ: [2 0.2000 0.2000]
%        H: 100
%       ro: 0.0500
%       fe: 5000

    % List params names
    paramsNames = fieldnames(params);
    suffix = 'par_'; % part of parameter name in Comsol
        % assign parameters from param file to comsol in loop
    for i = 1:numel(paramsNames)
        currentParamName = [suffix paramsNames{i}]; 
        % generate error if parameter with same name does not exists in comsol mph file 
        try
            currentParamValue = model.param.evaluate(currentParamName);
        catch exception
            error(sprintf('Parameter ''%s'' does not exist in Comsol model.', currentParamName))
        end
        
        % get value of parameter from param file
        wantedParamValue = params.(paramsNames{i});
        % assign this param value to corresponding parameter in Comsol
        model.param().set(currentParamName, wantedParamValue);
    end
        
end

