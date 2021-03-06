function plotOneParamChg_choicesFun( plotNamePrefix, q_colorOrder, paramName, paramValues, xUnitCoef, xUnitShift, ...
                                 paramsStd, comparativeStatsTab, ...
                                 y1Name, y1Index, y1Legend, y1Unit, y1Time, ...
                                 y2Name, y2Index, y2Legend, y2Unit, xLabel, useSemiLogX, ...
                                 plotSave, plotExportPath, variant, ...
                                 plot_tSS_OnSamePlot)
% Call function plotOneParamChg_choicesFun to plot one at a time parameter sensitivity analysis with the following options

    %% prepare plot name suffix to save the plot with correct name
    plotnameSuffix_2 = [variant, '_'];
    plotnameSuffix_3 = ''; % additional info if needed to add here.
    plotnameSuffix_4 = '';
    plotnameSuffix_5 = ''; 

    %% necessary params
    params = paramsStd;                       
    %% plot
    if plot_tSS_OnSamePlot % plot both Tb and time to steady state (tss) on the same plot

        plotNameSuffixAdd = [plotnameSuffix_2, plotnameSuffix_3, plotnameSuffix_4, plotnameSuffix_5]; 

        plotOneParamChg( plotNamePrefix, q_colorOrder, paramName, paramValues, xUnitCoef, xUnitShift, ...
                                         params, params, comparativeStatsTab, ...
                                         y1Name, y1Index, y1Legend, y1Unit, y1Time, '-', ...
                                         y2Name, y2Index, y2Legend, y2Unit, ':', ...
                                         xLabel, useSemiLogX, ...
                                         plotSave, plotExportPath, variant, plotNameSuffixAdd)
                                          
    else % plot Tb and T ss on 2 different plots
        plotnameSuffix_5 = y1Name; 
        plotNameSuffixAdd = [plotnameSuffix_2, plotnameSuffix_3, plotnameSuffix_4, plotnameSuffix_5]; 
        plotOneParamChg( plotNamePrefix, q_colorOrder, paramName, paramValues, xUnitCoef, xUnitShift, ...
                                         params, params, comparativeStatsTab, ...
                                         y1Name, y1Index, y1Legend, y1Unit, y1Time, '-', ...
                                         [], [], [], [], [], ... %second y not plotted
                                         xLabel, useSemiLogX, ...
                                         plotSave, plotExportPath, variant, plotNameSuffixAdd)

        plotnameSuffix_5 = y2Name; 
        plotNameSuffixAdd = [plotnameSuffix_2, plotnameSuffix_3, plotnameSuffix_4, plotnameSuffix_5];                             
        plotOneParamChg( plotNamePrefix, q_colorOrder, paramName, paramValues, xUnitCoef, xUnitShift, ...
                                         params, params, comparativeStatsTab, ...
                                         [], [], [], [], y1Time, '-', ...
                                         y2Name, y2Index, y2Legend, y2Unit, ':', ... %second y not plotted
                                         xLabel, useSemiLogX, ...
                                         plotSave, plotExportPath, variant, plotNameSuffixAdd)

    end   
end

