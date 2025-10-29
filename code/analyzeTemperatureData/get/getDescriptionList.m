function desc = getDescriptionList(experimentData)
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
      experimentData (1,1) struct
    end
    
    experimentName = getExperimentName(experimentData);
    if ~isfield(experimentData.(experimentName), 'description_list')
      warning('description_list not found under experiment "%s".', experimentName);
    end
    
    desc = experimentData.(experimentName).description_list;
    if isstring(desc)
        desc = cellstr(desc);
    end

end