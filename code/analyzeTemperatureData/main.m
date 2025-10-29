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
clear, clc

addpath(genpath('.'))

%% Load data
[experimentName, experimentPath] = uigetfile({'*.mat','Data Files (*.mat)'}, ...
                                                  'Select the real data to run the test.');

experimentData = load([experimentPath experimentName]);

%% Get data

descriptionList = getDescriptionList(experimentData);
timestamps = getTimestamps(experimentData);

[joint_idx, isSelected] = listdlg('ListString', descriptionList);

if isSelected
    for i = joint_idx
        
        current_joint_name = descriptionList{i};
        
        temperature = getTemperatureData(current_joint_name, experimentData);
        plotTemperatureData(timestamps, temperature, joint_idx(i), current_joint_name);
        
        diagnostic = errorHandlingTemperature(timestamps, temperature);
        plotOverheatingZones(timestamps, temperature, diagnostic.mask.OVERHEAT, diagnostic.regions.OVERHEAT);
    
        printDiagnosticMarkdown(timestamps, diagnostic);
        
    end
else
    disp('No joint selected');
end