function s3_mnsvg_model
%% s3_mnsvg_model: Probability model
% This module builds MNSVG model.
% 
% Input file: data/sample_low_pass_XXX.mat
%
% Output file: data/sample_mnsvg_XXX.mat
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
config;

% Load data from 'data/sample_low_pass_XXX.mat'
SAMPLE_AVG = importdata(strcat('data/sample_low_pass_', num2str(wsize), '.mat'));

MNSVG_MODEL = cell(size(SAMPLE_AVG));

% Initialize timestamp & progress
dispstat('','init');
dispstat('Building a MNSVG model','keepthis','timestamp');

% Start!
for i_sensor = 1 : num_sensors
    DATA = SAMPLE_AVG(:,i_sensor);
    % delta_t: time gradient ∆t, configured by config.m
    for i_delta_t = 1 : length(delta_t)
        % Display timestamp & progress
        progress = ((i_sensor-1)*length(delta_t)+i_delta_t)/(num_sensors*length(delta_t))*100;
        dispstat(sprintf('Progress %d%%',int32(progress)),'timestamp');
        
        % To generate a multiset Si∆t(=multiset_delta_s), specify the ts
        % (=start_time) and the tf (=end_time).
        start_time = 1;
        end_time = length(DATA) - delta_t(i_delta_t);
        
        % countMap counts the number of ∆s(=delta_s).
        countMap = containers.Map('KeyType','double','ValueType','double');
        
        % The predictor generates a multiset, Si∆t, that represents
        % a distribution of maximum normalized sensor value gradients over
        % different time points from ts(=start_time) to tf(=end_time) for a
        % certain time gradient, ∆t(=delta_t(i_delta_t)).
        for t0 = start_time : end_time - delta_t(i_delta_t)
            % Calculate ∆s(=delta_s) over a time gradient
            % ∆t(=delta_t) at certain time point t0.
            delta_s = max(abs(DATA(t0+1:t0+delta_t(i_delta_t))-DATA(t0))/abs(DATA(t0)));
            
            % Handle "divided by 0" case
            if DATA(t0) == 0
                continue
            end
            
            % Increase countMap by +1 with given ∆s(delta_s).
            if countMap.isKey(delta_s)
                countMap(delta_s) = countMap(delta_s) + 1.0;
            else
                countMap(delta_s) = 1.0;
            end
        end
        
        % Generate multiset and the probability
        multiset_delta_s = cell2mat(keys(countMap));
        probability = (1/end_time * cell2mat(values(countMap)));
        
        model = sortrows([multiset_delta_s; probability]',1);
        
        % Save the model
        MNSVG_MODEL{i_sensor}{i_delta_t} = model;
    end
end
dispstat('Finished','keepprev');

save(strcat('data/sample_mnsvg_', num2str(wsize), '.mat'), 'MNSVG_MODEL');

% Cumulate the model
cumulate_model
