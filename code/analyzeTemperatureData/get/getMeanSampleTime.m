function meanSampleTime = getMeanSampleTime(timestamps)
% GETMEANSAMPLETIME — Mean sampling interval [s].
%
% Syntax:
%   meanSampleTime = getMeanSampleTime(timestamps)
%
% Input:
%   timestamps (double) - Monotonic timestamps.
%
% Output:
%   meanSampleTime (double scalar) - Average dt in seconds.
%
% Example:
%   dt = getMeanSampleTime(t);

arguments
  timestamps {mustBeVector}
end

dt = diff(timestamps);
meanSampleTime = mean(dt);
