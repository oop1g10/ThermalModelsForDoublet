function paramsPlotTab = paramsPlotTabPrep( variant, ...
    paramsFor_q, paramsFor_aXYZ, paramsFor_alpha_deg, paramsFor_cS, paramsFor_lS, ...
    paramsFor_Ti, paramsFor_n, paramsFor_H, paramsFor_Q, paramsFor_a)

% Prepare table for parameters for plot    
    paramsPlotTab = table;
    paramsPlotRow = table;
    
    % Standard parameters lists for analysis
    [q_list, aXYZ_list, alpha_deg_list, cS_list, lS_list, Ti_list, n_list, H_list, Q_list, a_list ] = ...
          standardRangesToCompare_oneAtATime(variant);
    
    if paramsFor_q
        paramsPlotRow.paramName = {'q'};
        paramsPlotRow.paramValue_list = {q_list};
        paramsPlotRow.xUnitCoef = daysToSeconds( 1 ); % Coefficient to convert parameter values to x axis units
        paramsPlotRow.xUnitShift = 0;
        paramsPlotRow.xLabel = {'Groundwater flow (m/day)'};
        paramsPlotRow.useSemiLogX = true; % Add row in table to say if to use semilog on x axis, logic
        paramsPlotTab = [paramsPlotTab; paramsPlotRow]; % Add row to table
    end    
    if paramsFor_aXYZ
        paramsPlotRow.paramName = {'LINKED_aX'};
        paramsPlotRow.paramValue_list = {aXYZ_list(:,1)'};
        paramsPlotRow.xUnitCoef = 1; % Coefficient to convert parameter values to x axis units
        paramsPlotRow.xUnitShift = 0;
        paramsPlotRow.xLabel = {'Dispersivity (m)'};
        paramsPlotRow.useSemiLogX = false; % Add row in table to say if to use semilog on x axis, logic
        paramsPlotTab = [paramsPlotTab; paramsPlotRow]; % Add row to table
    end
    if paramsFor_alpha_deg
        paramsPlotRow.paramName = {'alpha_deg'};
        paramsPlotRow.paramValue_list = {alpha_deg_list};
        paramsPlotRow.xUnitCoef = 1; % Coefficient to convert parameter values to x axis units
        paramsPlotRow.xUnitShift = 0;
        paramsPlotRow.xLabel = {'Direction of groundwater flow (degrees)'};
        paramsPlotRow.useSemiLogX = false; % Add row in table to say if to use semilog on x axis, logic
        paramsPlotTab = [paramsPlotTab; paramsPlotRow]; % Add row to table
    end        
    if paramsFor_cS
        paramsPlotRow.paramName = {'cS'};
        paramsPlotRow.paramValue_list = {cS_list};
        paramsPlotRow.xUnitCoef = 1; % Coefficient to convert parameter values to x axis units
        paramsPlotRow.xUnitShift = 0;
        paramsPlotRow.xLabel = {'Specific heat capacity of solid (J/kg/K)'}; % specific heat capacity of solid
        paramsPlotRow.useSemiLogX = false; % Add row in table to say if to use semilog on x axis, logic
        paramsPlotTab = [paramsPlotTab; paramsPlotRow]; % Add row to table
    end
    
    if paramsFor_lS
        paramsPlotRow.paramName = {'lS'};
        paramsPlotRow.paramValue_list = {lS_list};
        paramsPlotRow.xUnitCoef = 1; % Coefficient to convert parameter values to x axis units
        paramsPlotRow.xUnitShift = 0;
        paramsPlotRow.xLabel = {'Thermal conductivity of solid (W/m/K)'}; % % [W/m/K ] thermal conductivity of solid in aquifer matrix [W m-1 K-1]
        paramsPlotRow.useSemiLogX = false; % Add row in table to say if to use semilog on x axis, logic
        paramsPlotTab = [paramsPlotTab; paramsPlotRow]; % Add row to table
    end
    if paramsFor_n
        paramsPlotRow.paramName = {'n'};
        paramsPlotRow.paramValue_list = {n_list};
        paramsPlotRow.xUnitCoef = 1; % Coefficient to convert parameter values to x axis units
        paramsPlotRow.xUnitShift = 0;
        paramsPlotRow.xLabel = {'Porosity (-)'}; % porosity of material in aquifer 
        paramsPlotRow.useSemiLogX = false; % Add row in table to say if to use semilog on x axis, logic
        paramsPlotTab = [paramsPlotTab; paramsPlotRow]; % Add row to table
    end
    if paramsFor_H
        paramsPlotRow.paramName = {'LINKED_H'};
        paramsPlotRow.paramValue_list = {H_list};
        paramsPlotRow.xUnitCoef = 1; % Coefficient to convert parameter values to x axis units
        paramsPlotRow.xUnitShift = 0;
        paramsPlotRow.useSemiLogX = false; % Add row in table to say if to use semilog on x axis, logic
        paramsPlotRow.xLabel = {'Thickness of aquifer (m)'};
        paramsPlotTab = [paramsPlotTab; paramsPlotRow]; % Add row to table
    end  
    
    if paramsFor_Q
        paramsPlotRow.paramName = {'Q'};
        paramsPlotRow.paramValue_list = {Q_list};
        paramsPlotRow.xUnitCoef = 1; % Coefficient to convert parameter values to x axis units
        paramsPlotRow.xUnitShift = 0;
        paramsPlotRow.useSemiLogX = false; % Add row in table to say if to use semilog on x axis, logic
        paramsPlotRow.xLabel = {'Flowrate of injected water (m cub. per second)'};
        paramsPlotTab = [paramsPlotTab; paramsPlotRow]; % Add row to table
    end    

    
    if paramsFor_a
        paramsPlotRow.paramName = {'a'};
        paramsPlotRow.paramValue_list = {a_list};
        paramsPlotRow.xUnitCoef = 1; % Coefficient to convert parameter values to x axis units
        paramsPlotRow.xUnitShift = 0;
        paramsPlotRow.useSemiLogX = false; % Add row in table to say if to use semilog on x axis, logic
        paramsPlotRow.xLabel = {'Half distance between injection and pumping wells (m)'};
        paramsPlotTab = [paramsPlotTab; paramsPlotRow]; % Add row to table
    end    

    if paramsFor_Ti
        paramsPlotRow.paramName = {'Ti'};
        paramsPlotRow.paramValue_list = {Ti_list};
        paramsPlotRow.xUnitCoef = 1; % Coefficient to convert parameter values to x axis units
        % For Ti DIFFERENT SHIFT is set to convert K to degC
        paramsPlotRow.xUnitShift = kelvin2DegC(1);
        paramsPlotRow.xLabel = {'Injection temperature (deg C)'}; % Injection temeprature at well 7 (test 2)
        paramsPlotRow.useSemiLogX = false; % Add row in table to say if to use semilog on x axis, logic
        paramsPlotTab = [paramsPlotTab; paramsPlotRow]; % Add row to table
    end

end

