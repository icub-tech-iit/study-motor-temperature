% MAIN — Example driver for the temperature analysis pipeline.
%
% Syntax:
%   main
%
% Description:
%   Demonstrates typical usage of the analysis functions:
%   - load/prepare timestamps (here synthetic for demo)
%   - compute diagnostics, plot data and overheating zones
%   - print a Markdown table with percentages
%
% Example:
%   main

% --- Demo data (replace with your I/O as needed) -------------------------
% Example: 250 s of data at ~0.5 Hz equivalent with a smooth sinusoid
% timestamps = (0:0.5:250);                   % seconds (numeric) for demo
% temperature = 95*sin(2*pi*timestamps/250);   % °C, synthetic
% temperatureHardwareLimit = 0;                % Example threshold (°C)

addpath(genpath('.'))

[experimentName, experimentPath] = uigetfile({'*.mat','Data Files (*.mat)'}, ...
                                                  'Select the real data to run the test.');

experimentData = load([experimentPath experimentName]);
%%
timestamps = getTimestamps(experimentData);

% The joint names are listed inside the "description list" section of the
% experiment data (experimentData -> experiment Name -> description_list).
joint_name = 'torso_pitch_mj1_real_aksim2';
joint_index = getJointIndex(joint_name, experimentData);

temperature = getTemperatureData('torso_pitch_mj1_real_aksim2', experimentData);

plotTemperatureData(timestamps, temperature, joint_index, joint_name)

temperatureHardwareLimit = 31;

diagnostic = errorHandlingTemperature(timestamps, temperature, temperatureHardwareLimit);

printDiagnosticMarkdown(timestamps, diagnostic)

[mask, regions] = detectOverheating(timestamps, temperature, temperatureHardwareLimit);

plotOverheatingZones(timestamps, temperature, mask, regions);