%% eval_applet
% function eval_applet evaluates whether an applet is met or not in given
% rawdata.
%
% Input: lfunc - logical operator, cfunc - comparator, applet, rawdata 
% Output: result - does an applet meet its conditions? (boolean)
function result = eval_applet (lfunc, cfunc, applet, rawdata)

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

left_eval = cfunc{applet(LEFT_COMP)}(rawdata(applet(LEFT_SENSOR)),applet(LEFT_VALUE));
right_eval = cfunc{applet(RIGHT_COMP)}(rawdata(applet(RIGHT_SENSOR)),applet(RIGHT_VALUE));
result = lfunc{applet(LOGICAL_OP)}(left_eval,right_eval);

end

