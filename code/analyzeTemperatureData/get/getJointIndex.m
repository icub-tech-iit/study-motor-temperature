function joint_idx = getJointIndex(joint_name, experimentData)
% GETJOINTINDEX — Row index of the specified joint in the description list.
%
% Syntax:
%   joint_idx = getJointIndex(joint_name, experimentData)
%
% Inputs:
%   joint_name (string/char) - Joint name to look up (case-insensitive).
%   experimentData (struct)  - Data struct containing <experiment>.description_list.
%
% Output:
%   joint_idx (double scalar) - Index (row number) of the joint in the description list.
%                               Returns NaN if not found or input invalid.
%
% Example:
%   idx = getJointIndex('neck_pitch', S);
%
% See also: getExperimentName

arguments
  joint_name {mustBeTextScalar}
  experimentData (1,1) struct
end

experimentName = getExperimentName(experimentData);
if ~isfield(experimentData.(experimentName), 'description_list')
  warning('description_list not found under experiment "%s".', experimentName);
  joint_idx = NaN; return;
end

desc = experimentData.(experimentName).description_list;
if isstring(desc)
    desc = cellstr(desc);
end

joint_idx = find(strcmpi(char(joint_name), desc), 1, 'first');
if isempty(joint_idx)
  % Provide a concise hint without interactive prompts.
  maxShow = min(10, numel(desc));
  warnList = strjoin(desc(1:maxShow), ', ');
  warning('Joint "%s" not found. First entries: %s%s', ...
          joint_name, warnList, iff(numel(desc) > maxShow, ' ...', ''));
  joint_idx = NaN;
end
end

% --- local utility --------------------------------------------------------
function out = iff(cond, a, b)
out = b;
    if cond 
        out = a;
    end
end