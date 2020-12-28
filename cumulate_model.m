function cumulate_model
%% Cumulate Model
% This module cumulates the probability model to calculate the probability
% of CEI function easily.
%
% Input file: data/sample_mnsvg_XXX.mat
%
% Ouput file: data/sample_cum_mnsvg_XXX.mat
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

config;

MNSVG_MODEL = importdata(strcat('data/sample_mnsvg_',num2str(wsize),'.mat'));

for i_sensor = 1 : num_sensors
    for i_delta_t = 1 : length(delta_t)
        num_ticks = size(MNSVG_MODEL{i_sensor}{i_delta_t}, 1);
        
        % Cumulate
        for i_tick = 2 : num_ticks
            MNSVG_MODEL{i_sensor}{i_delta_t}(i_tick,2) = MNSVG_MODEL{i_sensor}{i_delta_t}(i_tick-1,2) + MNSVG_MODEL{i_sensor}{i_delta_t}(i_tick,2);
        end
    end
end

save(strcat('data/sample_cum_mnsvg_',num2str(wsize),'.mat'),'MNSVG_MODEL');

end
