function [mask, regions] = detectOverheating(timestamps, temperature, threshold)
% DETECTOVERHEATING — Mark contiguous ≥ threshold regions that last ≥10 s.
%
% Syntax:
%   [mask, regions] = detectOverheating(temperature, timestamps, threshold)
%
% Inputs:
%   temperature (double vector) - Temperature signal [°C].
%   timestamps  (double/datetime vector) - Monotonic time stamps.
%   threshold   (double scalar) - Overheat threshold [°C].
%
% Outputs:
%   mask (logical vector) - True where temperature is in an *overheating* region
%                           that lasts at least the minimum duration.
%   regions (table)       - startIdx, endIdx, length (samples) for each region
%                           that satisfies the persistence condition.
%
% Notes:
%   - Minimum persistence is 10 s. This is converted to a sample count using
%     the mean sampling interval.
%
% Example:
%   [m, R] = detectOverheating(T, t, 55);

arguments
  timestamps  (1,:) {mustBeVector}
  temperature (1,:) double
  threshold   (1,1) double
end

% Required persistence in samples.
overheatTimeLimit = 10;                        % [s]
meanSampleTime = mean(diff(timestamps));       % [s]
requiredSamples = max(1, ceil(overheatTimeLimit / meanSampleTime));

above = temperature > threshold;

% Find all contiguous true runs.
d = diff([false above false]);               % 1 at rising edge, -1 at falling
starts = find(d == 1);
ends   = find(d == -1) - 1;
lens   = ends - starts + 1;

% Filter by minimum length.
valid  = lens >= requiredSamples;
starts = starts(valid);
ends   = ends(valid);
lens   = lens(valid);

mask = false(size(temperature));
for k = 1:numel(starts)
  mask(starts(k):ends(k)) = true;
end

regions = table(starts, ends, lens, ...
    'VariableNames', {'startIdx','endIdx','length'});

% Return mask as row vector for consistency with inputs that are row vectors.
mask = reshape(mask, 1, []);
end
