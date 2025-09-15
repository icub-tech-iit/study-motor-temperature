function plotOverheatingZones(timestamps, temperature, overMask, regions, threshold)
% PLOTOVERHEATINGZONES — Overlay overheating segments on temperature plot.
%
% Syntax:
%   plotOverheatingZones(temperature, timestamps, overMask, regions, threshold)
%
% Inputs:
%   temperature (double vector) - Temperature [°C].
%   timestamps  (double/datetime vector) - Time base.
%   overMask    (logical vector) - True where overheating is active.
%   regions     (table) - startIdx, endIdx, length (samples) for overheating.
%   threshold   (double scalar) - Overheat threshold [°C] (optional for legend/line).
%
% Example:
%   plotOverheatingZones(T, t, D.mask.OVERHEAT, D.regions.OVERHEAT, 55)
%
% See also: detectOverheating

arguments
  timestamps  {mustBeVector}
  temperature (1,:) double
  overMask    (1,:) logical
  regions     table
  threshold   (1,1) double = NaN
end

assert(numel(timestamps) == numel(temperature) && ...
       numel(overMask) == numel(temperature), 'Vectors must have equal length.');

figure('Name','Overheat zones');
plot(timestamps, temperature, 'b-', 'LineWidth', 1.1);
hold on; grid on;

if ~isnan(threshold)
  yline(threshold, '--r', 'Threshold','LabelVerticalAlignment','bottom');
end

% Draw each overheating region as a thick overplot.
for k = 1:length(regions.startIdx)
  idx = regions.startIdx(k):regions.endIdx(k);
  plot(timestamps(idx), temperature(idx), 'r-', 'LineWidth', 2.0);
end

legendEntries = {'temperature'};
if ~isnan(threshold) 
    legendEntries{end+1} = 'threshold';
end
if ~isempty(regions)
    legendEntries{end+1} = 'overheat';
end

legend(legendEntries, 'Interpreter','none', 'Location','best');
hold off;

end