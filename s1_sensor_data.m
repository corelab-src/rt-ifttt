function s1_sensor_data
%% s1_sensor_data: Pre-process sensor data
%
% This simulation assumes that the time intervals between two consecutive 
% sensor data are constant (as one second) to build a MNSVG model and to 
% detect real-time events. But (y)our data may skip some seconds. Therefore, 
% this module makes some average data for the skipped ticks from csv files, 
% and make data be sequential.
%
% Input files: [path/to/your/sample_csv].csv, [path/to/your/rawdata_csv].csv
%
% Output files: sample.mat, rawdata.mat
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

config;

date_col=1;
SAMPLE = generate_data_matrix(sample_csv, date_col, num_sensors, 'sample');
save('data/sample.mat','SAMPLE');

clear;
config;

date_col = 1;
RAWDATA = generate_data_matrix(rawdata_csv, date_col, num_sensors, 'rawdata');
save('data/rawdata.mat','RAWDATA');
end
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function data = generate_data_matrix(csv_path, date_col, num_sensors, name)
%% generate_data_matrix
%
% This function generates the data matrix.
%
% Input: csv_path - the path of .csv file, date_col - the index of Date
% column, num_sensors - the number of sensors, name - the name of data
%
% Ouput: data - data matrix

csv_data = dlmread(csv_path,',',1,1);

format=[];
for i_sensor = 1:(num_sensors+1)
    if i_sensor == date_col
        format=[format '%s'];
    else
        format=[format '%*s'];
    end
end

% Read date and time
file = fopen(csv_path);
date_str = textscan(file,format,'Delimiter',',');
fclose(file);

% Assume that the input date format is '20-Apr-2017 13:33:01'
date = datetime(date_str{1}(2:end),'Locale','en_US');

num_ticks = length(date);
data = transpose(calculate_average(date, csv_data, (1:num_sensors), num_ticks, name));

end
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function data_cell = calculate_average(date, data, sensors, num_ticks, name)
%% calculate_average
%
% This function calculates average of value for skipped ticks, and fill in.
%
% Input arguments: date - Date array, data - Data array, sensors - index of 
% sensors, num_ticks - total time to calculate, name - the name of data
%
% Output argument: data_cell - stored data
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Initialize timestamp & progress
dispstat('','init');
dispstat(strcat('Pre-processing:',name,'.mat'),'keepthis','timestamp');

data_cell = [];
for i_tick = 1:num_ticks-1
    % Display timestamp & progress
	progress = i_tick/num_ticks*100;
	dispstat(sprintf('Progress %d%%',int32(progress)),'timestamp');
    
    % Calculate duration
    duration = date(i_tick+1) - date(i_tick);
    if(duration == seconds(1))
        % If there is no skipped ticks between sensor value, just store it.
        data_cell(:,end+1) = data(i_tick,sensors);
    else
        % Otherwise, fill skipped values with average.
        [h,m,num_skipped_ticks] = hms(duration);
        from = data(i_tick,sensors);
        to = data(i_tick+1,sensors);
        delta = to - from;
        data_cell(:,end+1) = from;
        for i_skipped_tick = 1:num_skipped_ticks-1
            data_cell(:,end+1) = from + delta*(i_skipped_tick/num_skipped_ticks);
        end
    end
end
% The last
data_cell(:,end+1) = data(num_ticks,sensors);

dispstat('Finished','keepprev');
end