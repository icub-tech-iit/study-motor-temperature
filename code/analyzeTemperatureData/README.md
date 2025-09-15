# Temperature Analysis & Diagnostics in MATLAB

## Overview

This repository provides a set of MATLAB tools for analyzing temperature data from the robometry `.mat` file output.
It focuses on two main aspects:

1. **Overheating Detection** – identifying when components exceed safe temperature thresholds.
2. **Error Handling & Diagnostics** – detecting and quantifying abnormal sensor or communication states.

The codebase also includes **visualization utilities** and a **unit test suite** to validate functionality on both synthetic and real datasets.

---

## Features

### Overheating Detection

* Detect continuous regions where temperature exceeds a user-defined threshold.
* Compute the percentage of time spent in overheating.
* Visualize overheating periods on top of the temperature signal.

### Error Handling & Diagnostics

* Detect diagnostic bands representing hardware or sensor issues:

  * **FOC\_TDB\_I2C\_NACK** (−90 °C to −70 °C)
  * **FOC\_TDB\_NO\_MEAS** (−70 °C to −50 °C)
  * **TDB\_LOST\_CONFIG** (−50 °C to −30 °C)
  * **TDB\_ANY\_CONFIG** (−30 °C to −10 °C)
* Quantify the percentage of time the system spends in each diagnostic state.
* Combine results with overheating detection for a full diagnostic profile.

### Visualization

* Overlay overheating regions on temperature plots.
* Produce clear diagnostic plots for validation and reporting.

### Testing

* Synthetic tests (sinusoidal and linear ramps).
* Real-data tests using `.mat` experiment files.
* Automatic percentage/tolerance checks for reliability.
* `test_Runner.m` script to run the entire suite.

---

## Example Usage

```matlab
% Load your experimental data
load('experimentData.mat');

% Extract temperature and time
T = getTemperatureData("torso_pitch_mj1_real_aksim2", experimentData);
t = getTimestamps(experimentData);

% Detect overheating
thr = 55; % °C threshold
[R, pctOver] = detectOverheating(T, t, thr);

% Handle error diagnostics
pctDiag = errorHandlingTemperature(T, t, thr);

% Plot overheating regions
plotOverheatingZones(T, t, R);
```

---

## Getting Started

1. Clone this repository.
2. Open the main script from `\study-motor-temperature\code\analyzeTemperatureData` to include all the code in the MATLAB path.
3. Run tests to confirm setup:

   ```matlab
   test_Runner
   ```

---

## Notes

* Some tests are interactive (`uigetfile` prompts for `.mat` input).
* Visualization functions produce figures for manual inspection.
* Can be integrated into larger control or diagnostic frameworks for robotics, embedded systems, or experimental setups.