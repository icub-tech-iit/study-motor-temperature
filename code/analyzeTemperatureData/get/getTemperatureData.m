function temperatureData = getTemperatureData(joint_name, experimentData)
% GETTEMPERATUREDATA — Extract temperature series for the specified joint.
%
% Syntax:
%   temperatureData = getTemperatureData(joint_name, experimentData)
%
% Inputs:
%   joint_name (string/char) - Target joint name (as in description_list).
%   experimentData (struct)  - Must contain <experiment>.motors_state.temperatures.data
%                              with size [nJoints x nSamples].
%
% Output:
%   temperatureData (double row vector) - Temperature series for the joint [°C].
%                                         Returns NaN if data not available.
%
% Example:
%   T = getTemperatureData("torso_pitch_mj1_real_aksim2", experimentName);
%
% See also: getJointIndex, getExperimentName

arguments
  joint_name {mustBeTextScalar}
  experimentData (1,1) struct
end

joint_idx      = getJointIndex(joint_name, experimentData);
experimentName = getExperimentName(experimentData);

if isnan(joint_idx)
  warning('Cannot resolve joint "%s".', joint_name);
  temperatureData = NaN;
  return;
end

pathOK = isfield(experimentData.(experimentName), 'motors_state') && ...
         isfield(experimentData.(experimentName).motors_state, 'temperatures') && ...
         isfield(experimentData.(experimentName).motors_state.temperatures, 'data');

if ~pathOK
  warning('Temperature data not logged.');
  temperatureData = NaN;
  return;
end

tmp = squeeze(experimentData.(experimentName).motors_state.temperatures.data);
temperatureData = double(tmp(joint_idx, :));
end