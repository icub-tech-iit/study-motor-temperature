function experimentName = getExperimentName(experimentData)
% GETEXPERIMENTNAME — Return the (single) top-level field name in the data struct.
%
% Syntax:
%   experimentName = getExperimentName(experimentData)
%
% Input:
%   experimentData (struct) - Struct loaded from file (one top-level field expected).
%
% Output:
%   experimentName (string scalar) - Name of the experiment field.
%
% Notes:
%   - If multiple fields are present, the first one is returned and a warning is issued.
%
% Example:
%   S = load('myLog.mat'); name = getExperimentName(S);

arguments
  experimentData (1,1) struct
end

f = string(fieldnames(experimentData));
if isempty(f)
  error('experimentData has no fields.');
end
if numel(f) > 1
  warning('Multiple top-level fields found. Using "%s".', f(1));
end
experimentName = f(1);
end