function wellRelevantPeriodsTab = wellRelevantPeriodAdd(wellRelevantPeriodsTab, ... 
                            wellName, dateTimeFrom, dateTimeTo)
% Return table with added relevant time period for each well  
 
    wellRelevantPeriodsRow = table;
    wellRelevantPeriodsRow.wellName = {wellName};
    wellRelevantPeriodsRow.dateTimeFrom = datetime(dateTimeFrom,'InputFormat','yyyy-MM-dd HH:mm:ss');
    wellRelevantPeriodsRow.dateTimeTo = datetime(dateTimeTo,'InputFormat','yyyy-MM-dd HH:mm:ss');
    wellRelevantPeriodsTab = [wellRelevantPeriodsTab; wellRelevantPeriodsRow];

end