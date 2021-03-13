function [planView_filename, profileView_filename] = ...
    comsolComputeAndExport( model, solution, methodMesh, params, paramsIndex, exportFolder, saveComsolResultMPH )
% Compute solution and export data
% model - COMSOL model object, contains connection to comsol server with
%         all COMSOL data (mesh, solution defined, materials of aquifer..)
% solution - solution identification to compute and export, for example
%           'sol1' with time series defined
% params - structure with selected parameters, for current parameter list
%          see comsolSetParams
% modelDimension - 3D, 2Dplan or 2Dprofile
    
    %% Compute solution
    model.sol(solution).runAll();
    
    %% Evaluate table with q Info based on computed solution
    comsolExportTabPrep(model);
    [ planViewData, profileViewData, planView_filename, profileView_filename, paramsIndexTxt, paramsString ] = ...            
        comsolExportFileNamePrep(model, solution, methodMesh, params, paramsIndex, exportFolder);

    %% Save mph file on request, should be done before export of txt files because the mph file name is included in the txt file
    if saveComsolResultMPH
        comsolComputed_filename = [exportFolder 'model ' solution ' ' paramsIndexTxt ' ' paramsString '.mph'];
        mphsave(model, comsolComputed_filename);
    end
    
    %% Export selected data for COMSOL as plane slice in plan or profile view (2D)
    if ~isempty(planViewData)
        for id = 1 : numel(planViewData)
            model.result().export(planViewData{id}).run(); % export
        end
    end
    
    if ~isempty(profileViewData)
        for id = 1 : numel(profileViewData)
            model.result().export(profileViewData{id}).run(); % export
        end
    end
    
    % Export the whole table with all data as txt file to specified folder
    % model.result().export('tbl1').run();

end

