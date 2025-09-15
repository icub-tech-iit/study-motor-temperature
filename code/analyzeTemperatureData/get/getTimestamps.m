function timestamps = getTimestamps(experimentData)
% GETTIMESTAMPS — Retrieve timestamps from the experiment and normalize to t0 = 0.
%
% Syntax:
%   timestamps = getTimestamps(experimentData)
%
% Input:
%   experimentData (struct) - Must contain <experiment>.motors_state.positions.timestamps
%
% Output:
%   timestamps (double) - Zero-based time.
%     - If numeric stored, returns a numeric vector with first element 0.
%
% Example:
%   t = getTimestamps(S);
%
% See also: getExperimentName

arguments
    experimentData (1,1) struct
end

experimentName = getExperimentName(experimentData);

timestamps = experimentData.(experimentName).motors_state.positions.timestamps;

% Normalize to start at zero in the native representation.
if isempty(timestamps)
    return;
end

timestamps = timestamps - timestamps(1); % [sec]

end