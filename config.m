%% Configuration
% variable configuration of each module

%% common variables
% the number of sensors
num_sensors = 10;

% the number of applets
num_applets = 100;

% To clear saved *.mat files, set clear_matrix = 1.
clear_matrix = 0;

% To rerun evaluation part (s4 ~ s7) set rerun_from_s4 = 1.
rerun_from_s4 = 0;

%% s1_sensor_data
% Give your sensor data path. default: 'data/sample.csv'
sample_csv = 'data/sample.csv';
% Give your sensor data path. default: 'data/rawdata.csv'
rawdata_csv = 'data/rawdata.csv';

%% s2_low_pass_filter
% window size (seconds)
wsize = 600;

%% s3_mnsvg_model
% ∆t: Due to a huge size of the model, MNSVG model takes some ∆t for
% prediction, not all the possible ∆t. default: [1, 10, 20, ..., 900]
delta_t = [1 10:10:900];

%% s4_applet_generator
% Random deadline. default: [30 60 300 600]
deadline = [30 60 300 600];
num_deadlines = size(deadline,2);

% Min and max value of each sensor (indexed by 1 to num_sensors)
rand_max = [10 150000 50 100 1030 1 1 40 50 1030];
rand_min = [0 0 0 0 1000 0 0 20 0 1000 ];

% Index of applet_XXX.mat (DO NOT CHANGE!)
% Left condition
LEFT_SENSOR = 1;
LEFT_COMP = 2;
LEFT_VALUE = 3;
% Logical operator
LOGICAL_OP = 4;
% Right condition
RIGHT_SENSOR = 5;
RIGHT_COMP = 6;
RIGHT_VALUE = 7;
% Deadline
DEADLINE = 8;

% Comparators and logical operators (DO NOT CHANGE!)
CFUNC = {str2func('<'), str2func('<='), str2func('>='), str2func('>')};
LFUNC = {str2func('and'), str2func('or')};

%% s5_event_detector

% Index of event_XXX_YYY.mat (DO NOT CHANGE!)
APPLET_ID = 1;
OCCUR_TIME = 2;
END_TIME = 3;


%% s6_eval_fixed
% Fixed polling interval (900 seconds for Fix-Opt, 30 secnods for Fix-Con)
fix_opt_interval = 900;
fix_con_interval = 30;

%% s7_eval_rt_ifttt
% Modeling polling interval
modeling_interval = 900;

% Target miss ratio
e = 0.1;

