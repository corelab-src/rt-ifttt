function s4_applet_generator
%% s4_applet_generator: Applet generator
% Applet generator generates random applets which consist of two
% sub-conditions with one logical operator.
%
% Output file: data/applet_YYY.mat
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
config;

% Data structure of APPLET:
% LEFT_SENSOR | LEFT_COMP | LEFT_VALUE | LOGICAL_OP | RIGHT_SENSOR |
% RIGHT_COMP | RIGHT_VALUE | DEADLINE

APPLET = zeros(num_applets, 8);

% The sensor of left condition
APPLET(:, LEFT_SENSOR) = randi([1 num_sensors], size(APPLET(:,LEFT_SENSOR)));
lsensor = APPLET(:, LEFT_SENSOR);
% Comparator (1:<, 2:<=, 3:>=, 4:>)
APPLET(:, LEFT_COMP) = randi([1 length(CFUNC)], size(APPLET(:,LEFT_COMP)));
% Condition value
for i = 1:length(lsensor)
    APPLET(i, LEFT_VALUE) = randi([rand_min(lsensor(i)) rand_max(lsensor(i))]);
end

%for i = 1:length(lsensor)
%    APPLET(i, LEFT_VALUE) = randi([rand_min(lsensor(i)) rand_max(lsensor(i))]);
%end

% logical operator (1:and, 2:or)
APPLET(:, LOGICAL_OP) = randi([1 length(LFUNC)], size(APPLET(:,LOGICAL_OP)));

% The sensor of right condition
APPLET(:, RIGHT_SENSOR) = randi([1 num_sensors], size(APPLET(:,RIGHT_SENSOR)));
rsensor = APPLET(:, RIGHT_SENSOR);
% Comparator
APPLET(:, RIGHT_COMP) = randi([1 length(CFUNC)], size(APPLET(:,RIGHT_COMP)));
% Condition value
for i = 1:length(rsensor)
    APPLET(i, RIGHT_VALUE) = randi([rand_min(rsensor(i)) rand_max(rsensor(i))]);
end

% deadline
APPLET(:, DEADLINE) = deadline(randi([1 num_deadlines], size(APPLET(:,DEADLINE))));


save(strcat('data/applet_',num2str(num_applets),'.mat'), 'APPLET');
end