function [ stepsCountLog, stepsCountLin, rangeLog, rangeLin, stepsCountRangeLog ] = ...
    stepsCountForLogLin(startStepSize, growthRate, skipRadius, logRangeEnd, rangeFull)
    % Calculate number of steps needed to cover logarythmically and linearly the specific range, 
    % 
    % For linear steps use the last (biggest) step in logarythmic steps list
    stepsCountLog = stepCountLog(startStepSize, growthRate, skipRadius, logRangeEnd);
    lastLogStepSize = startStepSize * growthRate^(stepsCountLog-1); % -1 because step 1 is gr^0, next is gr^1 etc
    % TO DELETE
%     stepsCountLin = logRangeEnd / lastLogStepSize;
%     % Ratio between logarythmic and linear sections (step counts) used to make steps list from range
%     logLinStepsCount_ratio = stepsCountLog / stepsCountLin;
    
    % Full range for list generation
    % Split full range to logarythmic part and linear part at 50m threshhold (logRangeEnd)
    rangeLog(1) = min([rangeFull(1), logRangeEnd]);
    rangeLog(2) = min([logRangeEnd, rangeFull(2)]);
    rangeLin(1) = max([logRangeEnd, rangeFull(1)]);
    rangeLin(2) = max([rangeFull(2), logRangeEnd]);
    
    % Count of steps needed for logarythmic part of full range
    stepsCountRangeLog = stepCountLog(startStepSize, growthRate, skipRadius, rangeLog);
    stepsCountLog = stepsCountRangeLog(2) - stepsCountRangeLog(1);
    % Count of steps needed for linear part of full range
    stepsCountLin = (rangeLin(2) - rangeLin(1)) / lastLogStepSize;
end

function stepsCount = stepCountLog(startStepSize, growthRate, rangeStart, rangeEnd)
   % Calculate number of log steps (n) needed to reach from x1 to x2 using growth rate gr
   
   % Wolfram Alpha formula (found with text "sum gr^x for x from 0 to n")
   % http://www.wolframalpha.com/input/?i=sum+a%5Ex+for+x+from+1+to+n
   % S = (gr^(n + 1) - 1)/(gr - 1)
   % therefore: n = log( S*(gr-1) + 1) / log(gr) - 1
   % rangeEnd = S * startStepSize, startStepSize is minimum mesh size in comsol (0.01m)
   % so therefore: S = rangeEnd / startStepSize
   
   S = (rangeEnd - rangeStart) / startStepSize;
   % the last +1 is needed as gr^0 is the first step
   stepsCount = log( S*(growthRate-1) + 1) / log(growthRate) - 1 + 1; 

end

