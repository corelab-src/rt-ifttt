%% Run the Simulation
%
% run.m runs all the main modules in order, and simulates RT-IFTTT and
% others.
%
% Please check your configuration in 'config.m'.
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

clear;
config;
rerun_from_s2 = 0;

if exist(rawdata_csv,'file') ~= 2
    disp(strcat(rawdata_csv,' does not exist. Give your sensor data.'));
    return;
end

if exist(rawdata_csv,'file') ~= 2
    disp(strcat(rawdata_csv,' does not exist. Give your sensor data.'));
    return;
end


% clear
if clear_matrix == 1
    prompt = 'Are you sure to clear all the *.mat files? Y/N [N]: ';
    str = input(prompt,'s');
    if isempty(str)
        str = 'N';
    end
    if strcmp(str,'Y')
        delete('data/sample*.mat', 'data/rawdata*.mat', 'data/applet_*.mat', 'data/event_*.mat');
    end
end

% s1_sensor_data
r_exist = (exist('data/rawdata.mat','file') == 2);
s_exist = (exist('data/sample.mat','file') == 2);

if ~r_exist || ~s_exist
    disp('s1_sensor_data is running...');
    s1_sensor_data
    disp('...s1 is done!');
end

% s2_low_pass_filter
sample_exist = (exist(strcat('data/sample_low_pass_',num2str(wsize),'.mat'),'file') == 2);
rawdata_exist = (exist(strcat('data/rawdata_low_pass_',num2str(wsize),'.mat'),'file') == 2);
if ~sample_exist || ~rawdata_exist
    disp('s2_low_pass_filter is running...');
    s2_low_pass_filter
    disp('...s2 is done!');
    rerun_from_s2 = 1;
end

% s3_mnsvg_model
model_exist = (exist(strcat('data/sample_mnsvg_',num2str(wsize),'.mat'),'file') == 2);
if rerun_from_s2 || ~model_exist
    disp('s3_mnsvg_model is running...');
    s3_mnsvg_model
    disp('...s3 is done!');
end

cum_exist = (exist(strcat('data/sample_cum_mnsvg_',num2str(wsize),'.mat'),'file') == 2);
if ~cum_exist
    cumulate_model
end

% s4_applet_generator
rerun_eval = 0;
applet_exist = (exist(strcat('data/applet_',num2str(num_applets),'.mat'),'file') == 2);
if ~applet_exist || rerun_from_s4
    disp('s4_applet_generator is running...');
    s4_applet_generator
    disp('...s4 is done!');
    rerun_eval = 1;
end

% s5_event_detector
event_exist = (exist(strcat('data/event_',num2str(wsize),'_',num2str(num_applets),'.mat'),'file') == 2);
if rerun_from_s2 || rerun_eval || ~event_exist
    disp('s5_event_detector is running...');
    s5_event_detector
    disp('...s5 is done!');
end

% s6_eval_fixed for fix-opt
disp('s6_eval_fixed for fix-opt is running...');
config;
s6_eval_fixed(fix_opt_interval)
disp('...s6 is done!');

% s6_eval_fixed for fix-con
disp('s6_eval_fixed for fix-con is running...');
config;
s6_eval_fixed(fix_con_interval)
disp('...s6 is done!');

% s7_eval_rt_ifttt
disp('s7_eval_rt_ifttt is running...');
s7_eval_rt_ifttt
disp('...s7 is done!');
clear;
