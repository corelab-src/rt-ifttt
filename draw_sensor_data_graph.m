function draw_sensor_data_graph( filename, varargin )
%% draw_sensor_data_graph: Draw the sensor data graph in Figure 2.
%
% Input: filename - csv file path to print ('Date' column is required and 
%        it should be in the first column), varargin - the name(s) of 
%        column(s) to print, maximum: 2.
%
% Output file: graph.eps
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
if ~ischar(filename)
    disp('filename should be a char array.');
    return
end
if exist(filename, 'file') ~= 2
    disp('file does not exist.');
    return
end
if nargin < 2 || nargin > 3
    disp('the number of column names should be 1 or 2.');
    return
end
for i = 1:(nargin-1)
    if ~ischar(varargin{i})
        disp('a name of a column should be a string.');
        return
    end
end

% Read sensor data
data = readtable(filename);
if sum(strcmp(data.Properties.VariableNames,"Date")) ~= 1
    disp('there is no Date column in the file.');
    return
end
for i = 1:(nargin-1)
    if sum(strcmp(data.Properties.VariableNames,varargin{i})) ~= 1
        disp(strcat('there is no "',varargin{i},'" column in the file.'));
        return
    end
end

% Extract columns to draw, and convert it to array
date_array = table2array(data(:,{'Date'}));
data_array = cell(1,nargin-1);
for i = 1:nargin-1
    data_array{i} = table2array(data(:,{varargin{i}}));
end

fig = figure;
fig.Position = [0 0 1200 300];
set(fig, 'Visible', 'off');

colormat = ['g';'b'];
for i = 1:nargin-1
    scatter(date_array,data_array{i},5,'.',colormat(i));
    hold on;
end
hold off;

xlim([date_array(1) date_array(end)])
datetick('x','mmm dd', 'keeplimits');

print(fig,strcat('graph'),'-depsc','-r0')

end



