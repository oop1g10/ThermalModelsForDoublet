function t_listRound = timeRoundToMeasured(t_list)
    % Measured times are every 30 seconds
    % Rounding of modelled times by 30 seconds allows to to intersection with
    % unequal values
    tRound = 30; %seconds
    % Round to nearest 30
    t_listRound = round(t_list / tRound, 0) * tRound;

end

