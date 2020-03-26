function [nodeXYZ, T_nodeTime, v_x_nodeTime, v_y_nodeTime, Hp_nodeTime, timeList] ...
    = comsolImportFile(filename, startRow, endRow)
%comsolImportFile Import numeric data from a text file as column vectors.
%   [nodeXYZ, T_nodeTime, timeList]
%   = comsolImportFile(FILENAME) Reads data from text file FILENAME for the
%   default selection.
%
%   [X1,Y1,Z1,T01,T02,T03,T04,T05,T06,T07,T08,T09,T10,T11,T12,T13,T14,T15,T16,T17,T18,T19,T20,T21,T22,T23,T24,T25,T26,T27,T28,T29,T30,T31,T32,T33]
%   = IMPORTFILE(FILENAME, STARTROW, ENDROW) Reads data from rows STARTROW
%   through ENDROW of text file FILENAME.
%
% Example:
%   [x1,y1,z1,T01,T02,T03,T04,T05,T06,T07,T08,T09,T10,T11,T12,T13,T14,T15,T16,T17,T18,T19,T20,T21,T22,T23,T24,T25,T26,T27,T28,T29,T30,T31,T32,T33] = importfile('mesh zero gw data 3 log time finer 025 time step.txt',9, 56882);
%
%    See also TEXTSCAN.

% Auto-generated by MATLAB on 2017/02/17 10:54:18

% Initialize variables if not specified as input arguments
if nargin<=2
    startRow = 9;
    endRow = inf;
end

%% Read columns of data as strings:
% For more information, see the TEXTSCAN documentation.
% Temperature columns has fixed width of 25 characters
T_ColumnSpecH = '%25s';%header
T_ColumnSpecD = '%25f';%data
% Support up to 140 columns for different time steps
% for each exported variable: temperature, vx, vy, H (that means 4 variables)
varCount = 4; % number of variables in the result table
maxColumns = 140 * varCount; 
% First in row are x, y and z coordinates, then temperature columns
formatSpecH = ['%26s%25s%25s', repmat(T_ColumnSpecH,1,maxColumns), '%s%[^\n\r]'];
formatSpecD = ['%26f%25f%25f', repmat(T_ColumnSpecD,1,maxColumns), '%s%[^\n\r]'];

%% Open the text file.
fileID = fopen(filename,'r');

%% Read columns of data according to format string.
% This call is based on the structure of the file used to generate this
% code. If an error occurs for a different file, try regenerating the code
% from the Import Tool.
%Get the header row as strings
dataArrayH = textscan(fileID, formatSpecH, 1, 'Delimiter', '', 'WhiteSpace', '', ...
                        'HeaderLines', startRow(1)-1, 'ReturnOnError', false);
%Read all the other data with numbers
dataArrayD = textscan(fileID, formatSpecD, endRow(1)-startRow(1), 'Delimiter', '', 'WhiteSpace', '', ...
                        'HeaderLines', 0, 'ReturnOnError', false);

%% Close the text file.
fclose(fileID);

%% Convert the contents of columns containing numeric strings to numbers.
% Replace non-numeric strings with NaN.
% Values in raw not needed
% raw = repmat({''},length(dataArray{1}),length(dataArray)-1);
% for col=1:length(dataArray)-1
%     raw(1:length(dataArray{col}),col) = dataArray{col};
% end
numericDataH = NaN(1, size(dataArrayD,2));
numericDataD = NaN(size(dataArrayD{1},1),size(dataArrayD,2));

for col=1:length(dataArrayD)-1
    % Converts strings in the input cell array to numbers. Replaced non-numeric
    % strings with NaN.
    rawDataH = dataArrayH{col};
    rawDataD = dataArrayD{col};
    
    %Data from Comsol are properly formatted, so no need for extra
    %check and conversions. Instead of the below, convert whole column at
    %once.
    try % Save obtained column in the intermediate working variable numericDataD
        % if last column has more than 1 column than return error. 
        % it indicates that the number of prespecified columns should be increased (maxColumns)
        numericDataD(:, col) = rawDataD; %data already read as numbers
    catch me
        error('File has more columns than defined in maxColumns.');
    end
    
    %Do it just for the first row which contains time values in header
    %texts for example "T (K) @ t=10" in days
    row = 1; %the header row
    % Create a regular expression to detect and remove non-numeric prefixes and
    % suffixes.
    regexstr = '(?<prefix>.*?)(?<numbers>([-]*(\d+[\,]*)+[\.]{0,1}\d*[eEdD]{0,1}[-+]*\d*[i]{0,1})|([-]*(\d+[\,]*)*[\.]{1,1}\d+[eEdD]{0,1}[-+]*\d*[i]{0,1}))(?<suffix>.*)';
    try
        % If cell contains number also in variable name, e.g. "T0 (K) @ t=0.001095", number detection does not work
        % because 0 is found after T. So T0 is replaced by To.
        % small loop belo is NOT USED because Td is used rahter than T - par_T0, but it is left just in case
        if strncmp(rawDataH{row}, 'T0', 2)
            rawDataH{row}(2) = 'o';
        end
        % Extract number if present in the heading of the column, it is time of simulation (t)
        result = regexp(rawDataH{row}, regexstr, 'names');
        numbers = result.numbers;

        % Detected commas in non-thousand locations.
        invalidThousandsSeparator = false;
        if any(numbers==',')
            thousandsRegExp = '^\d+?(\,\d{3})*\.{0,1}\d*$';
            if isempty(regexp(thousandsRegExp, ',', 'once'))
                numbers = NaN;
                invalidThousandsSeparator = true;
            end
        end
        % Convert numeric strings to numbers.
        if ~invalidThousandsSeparator
            numbers = textscan(strrep(numbers, ',', ''), '%f');
            numericDataH(row, col) = numbers{1};
            %raw{row, col} = numbers{1};
        end
    catch me
    end
    %If no number on second row of the column (first row is header)
    %then no more time intervals were exported, exit the for loop
    if isnan(numericDataD(1, col))
        break %exit the for loop
    end
end


%% Replace non-numeric cells with NaN
% Takes too much time and is not necessary, so commented out
% R = cellfun(@(x) ~isnumeric(x) && ~islogical(x),raw); % Find non-numeric cells
% raw(R) = {NaN}; % Replace non-numeric cells

%% Return file content as matrices
% Extract used coordinate indices
for col = 1:3
    for coordIndex = 1:3
        coordNames = 'xyz';
        % Coordinates in header of file are stored as : '% x' or 'y  '.
        % Which means "% SPACE x" and "y SPACE SPACE".
        % So check first and third letter for coordinate match. {1} is used to
        % unpack string from cell, (1) is used to take first or third
        % character (3) from string.
        % Upper means to make upper case of the letter/symbol, this is needed to enable x = X or X = x
        if upper(dataArrayH{col}{1}(1)) == upper(coordNames(coordIndex))...
                || upper(dataArrayH{col}{1}(3)) == upper(coordNames(coordIndex))
            coordIndicesUsed(col) = coordIndex;
            % coordIndicesUsed is indices of used coords e.g. [1,2] = x, y, and [1,3] = x, z
            break; % if found, go to search for coord name in the next column
        end
    end
end
% Assign Node coordinates
nodeXYZ = nan(size(numericDataD,1), 3);
nodeXYZ(:,coordIndicesUsed) = numericDataD(:,1:numel(coordIndicesUsed));
% Assign Temperatures for each node (rows) and time step (columns)
T_nodeTime = numericDataD(:,numel(coordIndicesUsed)+1:varCount:end); %last columns are spare, without data (NaNs)
% Assign groundwater velocity in x direction for each node (rows) and time step (columns)
v_x_nodeTime = numericDataD(:,numel(coordIndicesUsed)+2:varCount:end); 
% Assign groundwater velocity in y direction for each node (rows) and time step (columns)
v_y_nodeTime = numericDataD(:,numel(coordIndicesUsed)+3:varCount:end); 
% Assign Hydraulic potential (Hp) for each node (rows) and time step (columns)
Hp_nodeTime = numericDataD(:,numel(coordIndicesUsed)+4:varCount:end); 

%Times corresponding to the temperature columns
%timeList = 10 .^ [-2:0.25:6];
% the same time is repeated for each variable, so only each 4th time is taken to have unique time list
timeList = numericDataH(1, numel(coordIndicesUsed)+1:varCount:end); %times saved in column header
%Time convert from Days (standart in comsol) to Seconds
timeList = daysToSeconds(timeList);

%Number of columns (time steps) in imported file can vary, get list of
%non-empty columns
nonEmptyColumns = ~isnan(timeList);
%Leave only non empty columns as result
timeList = timeList(:, nonEmptyColumns);
T_nodeTime = T_nodeTime(:, nonEmptyColumns);
v_x_nodeTime = v_x_nodeTime(:, nonEmptyColumns);
v_y_nodeTime = v_y_nodeTime(:, nonEmptyColumns);
Hp_nodeTime = Hp_nodeTime(:, nonEmptyColumns);

% Idea was to solve problem of duplicate points to match DelenauyTriangulation indices, but it does not solve it.
% % Leave only rows with unique coordinates
% [nodeXYZ, ia] = unique(nodeXYZ, 'rows');
% % Save only results which correspond to unique coordinates in the same order as coordinates list
% T_nodeTime = T_nodeTime(ia);
% v_x_nodeTime = v_x_nodeTime(ia);
% v_y_nodeTime = v_y_nodeTime(ia);
% Hp_nodeTime = Hp_nodeTime(ia);

end