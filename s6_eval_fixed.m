function s6_eval_fixed (fixed_interval)
%% s6_eval_fixed: Evaluation for fixed interval (Fix-Opt, Fix-Con)
%
% Input argument: fixed_interval - interval to test
% Input files: data/rawdata_low_pass_XXX.mat, data/applet_YYY.mat, 
% data/event_XXX_YYY.mat
%
% Result will be displayed in the command window.
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
config;

% Load data
RAWDATA = importdata(strcat('data/rawdata_low_pass_',num2str(wsize),'.mat'));
APPLET = importdata(strcat('data/applet_',num2str(num_applets),'.mat'));
EVENT = importdata(strcat('data/event_',num2str(wsize),'_',num2str(num_applets),'.mat'));

% Total time length
num_ticks = size(RAWDATA,1);

% Sensor data stored in a server
current_value = zeros(num_sensors,1);

% Next polling time of each sensor
next_time = ones(num_sensors,1);

% is_detected (time, applet number) returns true(=1) or false(=0),
% which stores an event is occurred or not.
is_detected = zeros(num_ticks, num_applets);

% Communicaton count
fixed_comm_count = 0;

%% Simulation
for i_tick = 1 : num_ticks
    % Find sensors to check
    triggered_sensors = find(next_time == i_tick);

    % Find applets which have triggered_sensors in their conditions.
    % Actually, it is unnecessary to calculate relevant applets in the 
    % fixed-interval model because all sensors will be updated in the same
    % polling time.
    left_rel_applets = find(ismember(APPLET(:,LEFT_SENSOR),triggered_sensors));
    right_rel_applets = find(ismember(APPLET(:,RIGHT_SENSOR),triggered_sensors));
    rel_applets = union(left_rel_applets, right_rel_applets);

    % Recalculate relevant sensors to check
    updated_sensors = union(APPLET(rel_applets, LEFT_SENSOR),APPLET(rel_applets, RIGHT_SENSOR));
    
    num_updated_sensors = length(updated_sensors);
    fixed_comm_count = fixed_comm_count + num_updated_sensors;
    
    for i_sensor = 1 : num_updated_sensors
        % Update the sensor value
        current_value(updated_sensors(i_sensor)) = RAWDATA(i_tick,updated_sensors(i_sensor));
    end
    % Set the next polling time
    next_time(updated_sensors) = i_tick + fixed_interval;
    
    if num_updated_sensors == 0
        continue
    end
    
    num_rel_applets = length(rel_applets);
    for i_rel_applet = 1 : num_rel_applets
        is_detected(i_tick,rel_applets(i_rel_applet)) = eval_applet(LFUNC, CFUNC, APPLET(rel_applets(i_rel_applet),:), current_value);
    end
end
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% Statistics
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
fixed_comm_count

num_events = size(EVENT,2);
num_misses = 0;
sum_responses = 0;

for i_event = 1 : num_events
    interval = EVENT(OCCUR_TIME, i_event) : EVENT(END_TIME, i_event); %start : end
    
    % Check whether an event is occurred.
    result = find(is_detected(interval, EVENT(APPLET_ID, i_event)),1);
    
    if isempty(result)
        num_misses = num_misses + 1;
    else
        sum_responses = sum_responses + (interval(result) - EVENT(OCCUR_TIME, i_event));
    end
end

fixed_miss_ratio = num_misses / num_events
fixed_average_resp = sum_responses / (num_events-num_misses)
