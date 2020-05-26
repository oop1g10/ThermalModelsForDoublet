function [   ] = comsolExportTabPrep(model)
% Prepare column names to go in the results table and file name to be then exported from comsol
% model - COMSOL model object, contains connection to comsol server with
%         all COMSOL data (mesh, solution defined, materials of aquifer..)
   
%% NOT USED FOR NOW
%     %% Prepare table with q Info based on computed solution
%     % Update table with q info (darcy groundwater velocities)
%     model.result().table('tbl7').clearTableData(); % Clear old data in table (if any)
%     % Update Maximum vD (darcy velocity, q) in fracture line to table 7 
%     model.result().numerical('max4').set('table', 'tbl7');
%     model.result().numerical('max4').setResult();
%     % Update Average vD (darcy velocity, q) in fracture line to table 7  
%     
%     % NOT needed as it is solved by geometry
%     %Delete fracture sectoins outside of whole model domain, if they left error occurs in Vd average calc.
%     %model.result().numerical("av1").selection().set([2, 3, 4]);
%     
%     model.result().numerical('av1').set('table', 'tbl7');
%     model.result().numerical('av1').appendResult();
%     % Update Minimum vD (darcy velocity, q) in fracture line to table 7 
%     model.result().numerical('min2').set('table', 'tbl7');
%     model.result().numerical('min2').appendResult();
%     % Update vD (darcy velocity, q) at borehole wall to table 7 
%     model.result().numerical('pev5').set('table', 'tbl7');
%     model.result().numerical('pev5').appendResult();
%     % Update vD (darcy velocity, q) at 10 meters from center of model (x, y = [10, 0]) to table 7 
%     model.result().numerical('pev6').set('table', 'tbl7');
%     model.result().numerical('pev6').appendResult(); 
%     
%     qInfoNumber = [1:26]; % compute flow reduction area and volume due to fracture 
%     % Comsol export for 2D now uses "dummy" empty columns to number of columns is the same as in 3D
% %     if strcmp(modelDimension, '3D')
% %         qInfoNumber = [1:22]; % compute flow reduction area and volume due to fracture 
% %     elseif contains(modelDimension, '2D')
% %         qInfoNumber = [1:9]; % for 2D compute only area of q reduction due to fracture.
% %     end
%     for iqNum = 1 : numel(qInfoNumber)
%         qString = ['int',num2str(qInfoNumber(iqNum)),];
%         % Update area (m^2) when local near fracture Darcy flow is slower than par_qEffectLimit as it is lowered by fracture flow 
%         % for example:  area for 0.9 * par_q (area for 90% of original matrix velocity) and so on until 0.1* par_q
%         model.result().numerical(qString).set('table', 'tbl7');
%         model.result().numerical(qString).appendResult();
%     end
%    
end

