function s2_low_pass_filter
%% s2_low_pass_filter: Low pass filter
%
% Since the sensor data are too raw to run other modules, this module
% generates low-pass-filtered data from the sensro data.
%
% Input files: data/sample.mat, data/rawdata.mat
%
% Output files: data/sample_low_pass_XXX.mat, data/rawdata_low_pass_XXX.mat
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
config;

% Load data from 'data/sample.mat'
SAMPLE = importdata('data/sample.mat');

% Calculate average for each sensor
SAMPLE_AVG = low_pass_filter (SAMPLE, wsize);

save(strcat('data/sample_low_pass_',num2str(wsize),'.mat'),'SAMPLE_AVG');

clear('SAMPLE','SAMPLE_AVG');

% Apply the same filter to 'data/rawdata.mat'
RAWDATA = importdata('data/rawdata.mat');
RAWDATA_AVG = low_pass_filter (RAWDATA, wsize);

save(strcat('data/rawdata_low_pass_',num2str(wsize),'.mat'),'RAWDATA_AVG');

end
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function data_avg = low_pass_filter (data, wsize)
%% low_pass_filter
%
% This function calculates the average of the window of which size is
% 'wsize'.
%
% Input arguments: data - sensor data, wsize - window size
%
% Output argument: data_avg - low-pass-filtered data
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
num_ticks = size(data,1);
data_avg = zeros(size(data,1)-wsize, size(data,2));
for i_tick = 1 : num_ticks - wsize
    data_avg(i_tick,:) = mean(data(i_tick:i_tick+wsize-1,:));
end

end
