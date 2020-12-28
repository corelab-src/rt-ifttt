function s7_eval_rt_ifttt
%% s7_eval_rt_ifttt: Evaluation for RT-IFTTT
%
% Input files: data/rawdata_low_pass_XXX.mat, data/applet_YYY.mat, 
% data/event_XXX_YYY.mat, data/sample_cum_mnsvg_XXX.mat
%
% Result will be displayed in the command window.
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
config;
dispstat('','init');
dispstat('Loading variables','keepthis','timestamp');

RAWDATA = importdata(strcat('data/rawdata_low_pass_',num2str(wsize),'.mat'));
APPLET = importdata(strcat('data/applet_',num2str(num_applets),'.mat'));
EVENT = importdata(strcat('data/event_',num2str(wsize),'_',num2str(num_applets),'.mat'));
MNSVG_MODEL = importdata(strcat('data/sample_cum_mnsvg_',num2str(wsize),'.mat'));

% Total time length
num_ticks = size(RAWDATA,1);

% Sensor data stored in a server
current_data = zeros(num_sensors,1);

% Next polling time of each sensor
polling_time = ones(num_sensors,1);

eval_time = zeros(num_applets, 1);

% Maximum of next polling time of each sensor
modeling_time = ones(num_sensors,1);

% is_detected (time, applet number) returns true(=1) or false(=0),
% which stores an event is occurred or not.
is_detected = zeros(num_ticks, num_applets);

% Communication count
rt_ifttt_comm_count = 0;


%% Simulation
% Initialize timestamp & progress
dispstat('','init');
dispstat('Simulating RT-IFTTT','keepthis','timestamp');

for i_tick = 1 : num_ticks
    progress = i_tick/num_ticks*100;
    dispstat(sprintf('Progress %d%%',int32(progress)),'timestamp');
    
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %% Sensor Manager
    % Find sensors to check
    triggered_sensor = find(polling_time == i_tick);
    
    % Find applets which have triggered_sensors in their conditions
    left_rel_applets = find(ismember(APPLET(:,LEFT_SENSOR),triggered_sensor));
    right_rel_applets = find(ismember(APPLET(:,RIGHT_SENSOR),triggered_sensor));
    rel_applets = union(left_rel_applets, right_rel_applets);
    
    % Calculate sensors to be updated
    updated_sensor = union(APPLET(rel_applets, LEFT_SENSOR),APPLET(rel_applets, RIGHT_SENSOR));
    
    % Increase comm_count
    num_updated_sensor = length(updated_sensor);
    rt_ifttt_comm_count = rt_ifttt_comm_count + num_updated_sensor;
    
    % Update the sensor value
    for i_sensor = 1 : num_updated_sensor
        current_data(updated_sensor(i_sensor)) = RAWDATA(i_tick,updated_sensor(i_sensor));
    end
    
    if num_updated_sensor == 0
        continue
    end
    
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %% Sensor polling scheduler    
    % Evaluate all the relevant applets with the updated sensor data
    num_rel_applets = length(rel_applets);
    for i_rel_applet = 1 : num_rel_applets
        is_detected(i_tick,rel_applets(i_rel_applet)) = eval_applet(LFUNC, CFUNC, APPLET(rel_applets(i_rel_applet),:), current_data);
    end
        
    cei_interval = zeros(num_rel_applets, 1);
    % CEI: calculate the CEI for each relevant applets
    for i_rel_applet = 1 : num_rel_applets
        cei_interval(i_rel_applet) = cei(APPLET(rel_applets(i_rel_applet),:), current_data, MNSVG_MODEL, e, CFUNC, delta_t);
        eval_time(rel_applets(i_rel_applet)) = i_tick + cei_interval(i_rel_applet);
    end
    
    % SPI: Determine the next polling intervals of sensors
    for i_sensor = 1 : num_updated_sensor
        spi_time = spi (updated_sensor(i_sensor),APPLET,eval_time);
        modeling_time(updated_sensor(i_sensor)) = i_tick + modeling_interval;
        polling_time(updated_sensor(i_sensor)) = min([modeling_time(updated_sensor(i_sensor)); spi_time]);
    end
end
dispstat('Finished','keepprev');
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% Statistics
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
rt_ifttt_comm_count

num_events = size(EVENT,2);
num_misses = 0;
sum_responses = 0;

for i_event = 1 : num_events
    interval = EVENT(OCCUR_TIME, i_event) : EVENT(END_TIME, i_event);
    
    % Find the index of the first event detection
    result = find(is_detected(interval, EVENT(APPLET_ID, i_event)),1);
    
    if isempty(result)
        num_misses = num_misses + 1;
    else
        sum_responses = sum_responses + (interval(result) - EVENT(OCCUR_TIME, i_event));
    end
end

rt_ifttt_miss_ratio = num_misses / num_events
rt_ifttt_average_resp = sum_responses / (num_events-num_misses)

end
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% CEI function
% Because given applets have one logical operator, this simulation did
% not implement the whole recursive scheme to speed up simulation.
%
% Input
% r: applet, S: sensor value, SP: prediction model, e: miss ratio,
% CFUNC: comparator, delta_t: ∆t array used in 's3_mnsvg_model'.
%
% Output
% i_c: evaluation interval for the condition C.
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function i_c = cei(applet, rawdata, mnsvg_model, e, cfunc, delta_t)
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

% eval_leaf: evaluate a leaf condition
    function ret = eval_leaf(comp, sensor, val)
        ret = cfunc{comp}(rawdata(sensor),val);
    end

% cei function for a leaf condition
    function i_c = cei_leaf(sensor, value, e, applet_deadline)
        found = 0;
        delta_s = abs(rawdata(sensor) - value)/abs(rawdata(sensor));
        num_delta_t = size(delta_t, 2);
        
        % interaction with the value predictor: find a maximum ∆t
        for t = num_delta_t : -1 : 1
            first_index = find(mnsvg_model{sensor}{t}(:,2) >= 1-e,1);
            if mnsvg_model{sensor}{t}(first_index,1) < delta_s
                found = 1;
                break;
            end
        end
        
        if found % if ∆t is found
            i_c = delta_t(t);
            if i_c < applet_deadline % if ∆t < D then
                i_c = applet_deadline;
            end
        else % if ∆t is not found
            i_c = applet_deadline;
        end
    end

% C == Internal(...) then
if applet(LOGICAL_OP) == 1 % if lop == && then
    if eval_leaf(applet(LEFT_COMP), applet(LEFT_SENSOR), applet(LEFT_VALUE)) % if eval(left) then
        i_c = cei_leaf(applet(RIGHT_SENSOR), applet(RIGHT_VALUE), e, applet(DEADLINE)); % use right
    elseif eval_leaf(applet(RIGHT_COMP), applet(RIGHT_SENSOR), applet(RIGHT_VALUE)) % else if eval(right) then
        i_c = cei_leaf(applet(LEFT_SENSOR), applet(LEFT_VALUE), e, applet(DEADLINE)); % use left
    else
        left = cei_leaf(applet(LEFT_SENSOR), applet(LEFT_VALUE), e, applet(DEADLINE));
        right = cei_leaf(applet(RIGHT_SENSOR), applet(RIGHT_VALUE), e, applet(DEADLINE));
        i_c = max(left, right); % maximum of left and right
    end
else % if lop == || then
    left = cei_leaf(applet(LEFT_SENSOR), applet(LEFT_VALUE), 1-sqrt(1-e), applet(DEADLINE));   % use 1-sqrt(1-e)
    right = cei_leaf(applet(RIGHT_SENSOR), applet(RIGHT_VALUE), 1-sqrt(1-e), applet(DEADLINE));  % instead of e
    i_c = min(left, right); % minimum of left and right
end
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% SPI function
% Because the sensor manager makes the set of updated sensor 
% (=updated_sensor) explicitly, SPI function does not return 'Int_max' to
% mark as not updated. Rather, SPI function gets update sensor as 
% an argument.
%
% Input
% updated_sensor(=s_i): updated sensor, applet(=A): APPLET,
% cei_time(=tick+cei_interval): calculated polling time by CEI function.
%
% Output
% spi_time: minimum polling time of cei_time relevant to updated_sensor.
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function spi_time = spi (updated_sensor, applet, cei_time)
LEFT_SENSOR = 1;
RIGHT_SENSOR = 5;

left_rel_applets = find(applet(:,LEFT_SENSOR)==updated_sensor);
right_rel_applets = find(applet(:,RIGHT_SENSOR)==updated_sensor);
rel_applets = union(left_rel_applets, right_rel_applets);
spi_time = min(cei_time(rel_applets));
end