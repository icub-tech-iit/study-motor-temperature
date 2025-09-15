function plotTemperatureData(timestamps, temperature, joint_index, joint_name)
% PLOTTEMPERATUREDATA — Plot temperature vs time with descriptive labeling.
%
% Syntax:
%   plotTemperatureData(timestamps, temperature, joint_index, joint_name)
%
% Inputs:
%   timestamps (double/datetime vector) - Time base.
%   temperature (double vector)         - Temperature [°C], same length as timestamps.
%   joint_index (double scalar)         - Index of the joint (optional, NaN allowed).
%   joint_name  (string/char)           - Human-readable joint name.
%
% Example:
%   plotTemperatureData(t, T, 3, "elbow_pitch");

arguments
  timestamps {mustBeVector}
  temperature (1,:) double
  joint_index (1,1) double = NaN
  joint_name {mustBeTextScalar} = ""
end
assert(numel(timestamps) == numel(temperature), 'Time and temperature must have equal length.');

figure('Name','Temperature'); 
plot(timestamps, temperature, 'LineWidth', 1.2);
grid on; xlabel('Time [sec]'); ylabel('Temperature [°C]');

% Title: robust formatting without relying on non-MATLAB properties.
if ~isnan(joint_index) && strlength(joint_name) > 0
  title(sprintf('Motor %d — %s', joint_index, char(joint_name)), 'Interpreter', 'none');
elseif strlength(joint_name) > 0
  title(string(joint_name), 'Interpreter', 'none');
end
end
