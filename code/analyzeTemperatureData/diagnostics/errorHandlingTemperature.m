function diagnostic = errorHandlingTemperature(temperature, timestamps, temperatureHardwareLimit)
% ERRORHANDLINGTEMPERATURE — Build masks and percentages for temperature diagnostics.
%
% Syntax:
%   diagnostic = errorHandlingTemperature(temperature, timestamps, temperatureHardwareLimit)
%
% Inputs:
%   temperature (double vector) - Temperature signal [°C].
%   timestamps  (double/datetime vector) - Monotonic time stamps.
%                                          If datetime, durations are computed in seconds.
%   temperatureHardwareLimit (double scalar) - Overheat threshold [°C].
%
% Output:
%   diagnostic (struct) - Fields:
%     .mask.FOC_TDB_I2C_NACK (logical vector)
%     .mask.FOC_TDB_NO_MEAS  (logical vector)
%     .mask.TDB_LOST_CONFIG  (logical vector)
%     .mask.TDB_ANY_CONFIG   (logical vector)
%     .mask.OVERHEAT         (logical vector)
%     .percentage.<name>     (double scalar, 0–100)
%     .regions.OVERHEAT      (table) startIdx,endIdx,length (samples)
%
% Example:
%   D = errorHandlingTemperature(T, t, 55);
%
% See also: detectOverheating, plotOverheatingZones

arguments
  temperature (1,:) double
  timestamps  (1,:) {mustBeVector}
  temperatureHardwareLimit (1,1) double
end

% --- Static bands from spec (°C) -----------------------------------------
% -90 : I2C NACK from TDB (2FOC cannot read)
% -70 : no reading for 10 consecutive seconds
% -50 : TDB lost given configuration (fallback to default)
% -30 : TDB any configuration different from desired/default
mask.FOC_TDB_I2C_NACK = (temperature >= -90 & temperature < -70);
mask.FOC_TDB_NO_MEAS  = (temperature >= -70 & temperature < -50);
mask.TDB_LOST_CONFIG  = (temperature >= -50 & temperature < -30);
mask.TDB_ANY_CONFIG   = (temperature >= -30 & temperature < -10);

% --- Overheating (temporal condition: must persist for >= 10 s) ----------
[overMask, regions] = detectOverheating(temperature, timestamps, ...
                                        temperatureHardwareLimit);
mask.OVERHEAT = overMask;

% --- Percentages ----------------------------------------------------------
N = numel(temperature) -1;  % using sample count is robust to NaNs in masks
pct = struct();
pct.FOC_TDB_I2C_NACK = 100 * sum(mask.FOC_TDB_I2C_NACK) / N;
pct.FOC_TDB_NO_MEAS  = 100 * sum(mask.FOC_TDB_NO_MEAS)  / N;
pct.TDB_LOST_CONFIG  = 100 * sum(mask.TDB_LOST_CONFIG)  / N;
pct.TDB_ANY_CONFIG   = 100 * sum(mask.TDB_ANY_CONFIG)   / N;
pct.OVERHEAT         = 100 * sum(mask.OVERHEAT)         / N;

% --- Bundle result --------------------------------------------------------
diagnostic.mask      = mask;
diagnostic.percentage = pct;
diagnostic.regions.OVERHEAT = regions;

end