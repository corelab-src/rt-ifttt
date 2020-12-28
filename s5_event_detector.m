function s5_event_detector
%% s5_event_detector: Event detector
% Event detector checks when an event of an applet occurs in given rawdata.
% 
% Input files: data/rawdata_low_pass_XXX.mat, dat/applet_YYY.mat
%
% Output file: data/event_XXX_YYY.mat
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
config;

APPLET = importdata(strcat('data/applet_', num2str(num_applets), '.mat'));
RAWDATA = importdata(strcat('data/rawdata_low_pass_',num2str(wsize),'.mat'));

% Total time length
num_ticks = size(RAWDATA,1);

% is_occurred is true(=1) when the conditions of an applet(=i_applet) meet 
% at a given time(=i_tick), otherwise false(=0)
is_occurred = zeros(num_ticks, num_applets);

% Current sensor value
current_data = zeros(num_sensors,1);

% Initialize timestamp & progress
dispstat('','init');
dispstat('Calculate events','keepthis','timestamp');

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% Mark the ticks when the applet conditions meet
for i_tick = 1 : num_ticks
    % Display timestamp & progress
    progress = i_tick/num_ticks*100;
    dispstat(sprintf('Progress %d%%',int32(progress)),'timestamp');
    
    % Get data from sensors at the current time(=i_tick).
    for i_sensor = 1 : num_sensors
        current_data(i_sensor) = RAWDATA(i_tick,i_sensor);
    end
    
    for i_applet = 1 : num_applets
        is_occurred(i_tick, i_applet) = eval_applet(LFUNC, CFUNC, APPLET(i_applet,:), current_data);
    end
end

count_event = 0;

dispstat('Finished','keepprev');

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% Count events with "endurance"
% Since sensor data values change rapidly in a short time, the result of 
% evaluation of an applet (=is_occurred) can flip in a very short time. We 
% might think an event occurs when the result becomes true, but it would
% overestimate the number of events to count every transition of the result
% from 0(=false) to 1(=true). To detect events precisely, we have to count
% events with "endurance".
% This module adopts the concept of "occurrence" and "endurance". 
% "occurrence" saves the state whether an event occurs or not. When 
% "occurrence" is 0 and "is_occurred()" is 1, "occurrence" becomes 1 and
% marks it as an event. However, when "occurrence" is 1 and "is_occurred()"
% now becomes 0, "occurrence" will not change to 0 until the deadline ends;
% instead, "endurance" counts the time how long the "is_occurred()" remains
% 0. If "is_occurred()" becomes 1 again within the deadline, the module
% will not count it as an event but resets "endurance" to zero. If
% "is_occurred()" lasts 0 after the deadline ends, "occurrence" becomes 0.

% data structure of EVENT:
%   APPLET_ID  
%   OCCUR_TIME
%   END_TIME

% Initialize timestamp & progress
dispstat('','init');
dispstat('Count events','keepthis','timestamp');

for i_applet = 1 : num_applets
    % Get deadline
    deadline = APPLET(i_applet, DEADLINE);
    
    occurrence = 0;
    endurance = 0;
    
    for i_tick = 1 : num_ticks
        % Display timestamp & progress
        progress = ((i_applet-1)*num_ticks+i_tick)/(num_ticks*num_applets)*100;
        dispstat(sprintf('Progress %d%%',int32(progress)),'timestamp');
        
        % occurrence: 0 -> 1
        if occurrence == 0 && is_occurred(i_tick, i_applet)
            count_event = count_event + 1;
            % Save the EVENT
            EVENT(:,count_event) = [i_applet; i_tick; i_tick + deadline];            
            occurrence = 1;
        
        % occurrence: 1 -> 1
        elseif occurrence == 1 && is_occurred(i_tick, i_applet)
            endurance = 0;
        
        % occurrence: 1 -> 0, waiting on the deadline
        elseif occurrence == 1 && ~is_occurred(i_tick, i_applet)
            if endurance < deadline
                endurance = endurance + 1;
            else
                occurrence = 0;
                endurance = 0;
            end
        end
    end
end

dispstat('Finished','keepprev');

save(strcat('data/event_',num2str(wsize),'_',num2str(num_applets),'.mat'),'EVENT');