function [ comsolResultsTab ] = addToTabAbsentParams( comsolResultsTab )
%Check if comsolDataFile has new variable for model with pipes: pipe_TinLimitDiff (max limit for T in pipe)
% if not such parameter is present (i.e. model is without pipes) add this parameter as 1E9 standard number ( meaning no limit is set)        
    
    % This function is NOT NEEDED NOW
    
    %% example how to use it:
%     params = standardParams( 'homo' );
%     % If column pipe_TinLimitDiff does not exist in table    
%     if ~any(strcmp('pipe_TinLimitDiff', comsolResultsTab.Properties.VariableNames))
%         % add column with default values for each line
%         comsolResultsTab.pipe_TinLimitDiff = repmat({params.pipe_TinLimitDiff}, size(comsolResultsTab, 1), 1);
%     end

end

