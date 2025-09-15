# Temperature Data Analysis Documentation

## Table of Contents

* [Diagnostics](#diagnostics)

  * [detectOverheating](#detectoverheating)
  * [errorHandlingTemperature](#errorhandlingtemperature)
* [Get Functions](#get-functions)

  * [getExperimentName](#getexperimentname)
  * [getJointIndex](#getjointindex)
  * [getMeanSampleTime](#getmeansampletime)
  * [getTemperatureData](#gettemperaturedata)
  * [getTimestamps](#gettimestamps)
* [Utilities](#utilities)

  * [printDiagnosticMarkDown](#printdiagnosticmarkdown)
* [Visualization](#visualization)

  * [plotOverheatingZones](#plotoverheatingzones)
  * [plotTemperatureData](#plottemperaturedata)
* [Main Script](#main-script)

---

## Diagnostics

### detectOverheating

**Purpose**
Identify contiguous regions where temperature exceeds a threshold for at least 10 seconds.

**Syntax**

```matlab
[mask, regions] = detectOverheating(temperature, timestamps, threshold)
```

**Parameters**

* `temperature` (double vector): Temperature signal \[°C].
* `timestamps` (double or datetime vector): Monotonic timestamps.
* `threshold` (double scalar): Overheat threshold \[°C].

**Return Values**

* `mask` (logical vector): `true` where the signal is in an overheating region that satisfies the persistence condition.
* `regions` (table): Contains columns `startIdx`, `endIdx`, and `length` (in samples) for each overheating region.

**Notes**

* The persistence requirement is **10 seconds**, internally converted to sample counts using the mean sampling interval.
* `mask` is returned as a row vector for consistency.

**Example Usage**

```matlab
[m, R] = detectOverheating(T, t, 55);
```

---

### errorHandlingTemperature

**Purpose**
Generate diagnostic masks and percentages for temperature data, including hardware error codes and overheating detection.

**Syntax**

```matlab
diagnostic = errorHandlingTemperature(temperature, timestamps, temperatureHardwareLimit)
```

**Parameters**

* `temperature` (double vector): Temperature signal \[°C].
* `timestamps` (double or datetime vector): Monotonic timestamps.
* `temperatureHardwareLimit` (double scalar): Overheat threshold \[°C].

**Return Values**

* `diagnostic` (struct) with fields:

  * `.mask.<errorType>`: Logical vectors for:

    * `FOC_TDB_I2C_NACK`
    * `FOC_TDB_NO_MEAS`
    * `TDB_LOST_CONFIG`
    * `TDB_ANY_CONFIG`
    * `OVERHEAT`
  * `.percentage.<errorType>`: Percentages of samples affected (0–100).
  * `.regions.OVERHEAT`: Table of overheating intervals.

**Notes**

* Static diagnostic bands are defined:

  * `-90 to -70 °C`: I2C NACK
  * `-70 to -50 °C`: No measurement
  * `-50 to -30 °C`: Lost config
  * `-30 to -10 °C`: Wrong config
* Overheating requires persistence of ≥10 seconds (calls `detectOverheating`).

**Example Usage**

```matlab
D = errorHandlingTemperature(T, t, 55);
```

---

## Get Functions

### getExperimentName

**Purpose**
Return the top-level field name of an experiment struct.

**Syntax**

```matlab
experimentName = getExperimentName(experimentData)
```

**Parameters**

* `experimentData` (struct): Struct loaded from file.

**Return Values**

* `experimentName` (string scalar): Name of the experiment field.

**Notes**

* If multiple fields exist, returns the first and issues a warning.
* Errors if no fields exist.

**Example Usage**

```matlab
S = load("myLog.mat");
name = getExperimentName(S);
```

---

### getJointIndex

**Purpose**
Find the row index of a joint in the experiment description list.

**Syntax**

```matlab
joint_idx = getJointIndex(joint_name, experimentData)
```

**Parameters**

* `joint_name` (string/char): Target joint name (case-insensitive).
* `experimentData` (struct): Must contain `<experiment>.description_list`.

**Return Values**

* `joint_idx` (double scalar): Row index of the joint in the description list.
  Returns `NaN` if not found.

**Notes**

* Warns if `description_list` is missing.
* Shows up to 10 entries as a hint when joint not found.

**Example Usage**

```matlab
idx = getJointIndex("neck_pitch", S);
```

---

### getMeanSampleTime

**Purpose**
Compute the mean sampling interval from timestamps.

**Syntax**

```matlab
meanSampleTime = getMeanSampleTime(timestamps)
```

**Parameters**

* `timestamps` (double vector): Monotonic time values.

**Return Values**

* `meanSampleTime` (double scalar): Average time step \[s].

**Example Usage**

```matlab
dt = getMeanSampleTime(t);
```

---

### getTemperatureData

**Purpose**
Extract temperature series for a specific joint.

**Syntax**

```matlab
temperatureData = getTemperatureData(joint_name, experimentData)
```

**Parameters**

* `joint_name` (string/char): Joint name as in `description_list`.
* `experimentData` (struct): Must contain `<experiment>.motors_state.temperatures.data`.

**Return Values**

* `temperatureData` (double row vector): Temperature series \[°C].
  Returns `NaN` if data is missing.

**Notes**

* Internally uses `getJointIndex` and `getExperimentName`.

**Example Usage**

```matlab
T = getTemperatureData("torso_pitch_mj1_real_aksim2", experimentData);
```

---

### getTimestamps

**Purpose**
Retrieve and normalize experiment timestamps.

**Syntax**

```matlab
timestamps = getTimestamps(experimentData)
```

**Parameters**

* `experimentData` (struct): Must contain `<experiment>.motors_state.positions.timestamps`.

**Return Values**

* `timestamps` (double vector): Time normalized to start at zero.

**Example Usage**

```matlab
t = getTimestamps(S);
```

---

## Utilities

### printDiagnosticMarkDown

**Purpose**
Generate a Markdown table summarizing diagnostic percentages.

**Syntax**

```matlab
printDiagnosticMarkDown(timestamps, diagnostic)
```

**Parameters**

* `diagnostic` (struct): Output from `errorHandlingTemperature`.
* `timestamps` (double vector): Time normalized to start at zero.

**Example Usage**

```matlab
printDiagnosticMarkDown(t, D);
```

**Output Example**

```markdown
### Temperature data diagnostic report

=== Diagnostic Percentages ===
+----------------------+----------------+
| Condition            | Percentage [%] |
+----------------------+----------------+
| FOC_TDB_I2C_NACK     |           0.00 |
| FOC_TDB_NO_MEAS      |           0.00 |
| TDB_LOST_CONFIG      |           0.00 |
| TDB_ANY_CONFIG       |           0.00 |
| OVERHEAT             |          46.51 |
+----------------------+----------------+

=== Overheat Regions ===
+-----------+-----------+------------------+--------------+
| StartIdx  | EndIdx    | Length [samples] | Duration [s] |
+-----------+-----------+------------------+--------------+
|     34956 |     65345 |            30390 |        64.22 |
+-----------+-----------+------------------+--------------+
```

---

## Visualization

### plotOverheatingZones

**Purpose**
Visualize overheating intervals on a temperature plot.

**Syntax**

```matlab
plotOverheatingZones(temperature, timestamps, overMask, regions, threshold)
```

**Parameters**

* `temperature` (double vector): Temperature signal \[°C].
* `timestamps` (double/datetime vector): Time base.
* `overMask` (logical vector): Overheating activity mask.
* `regions` (table): Overheating start/end indices and lengths.
* `threshold` (double scalar, optional): Overheat threshold \[°C].

**Example Usage**

```matlab
plotOverheatingZones(T, t, D.mask.OVERHEAT, D.regions.OVERHEAT, 55);
```

---

### plotTemperatureData

**Purpose**
Plot temperature vs. time for a joint with labels.

**Syntax**

```matlab
plotTemperatureData(timestamps, temperature, joint_index, joint_name)
```

**Parameters**

* `timestamps` (double/datetime vector): Time base.
* `temperature` (double vector): Temperature \[°C].
* `joint_index` (double scalar): Index of the joint (optional).
* `joint_name` (string/char): Human-readable name.

**Example Usage**

```matlab
plotTemperatureData(t, T, 3, "elbow_pitch");
```

---

## Main Script

### main.m

**Purpose**
Demonstration driver for the temperature analysis pipeline.

**Usage**

* Loads or generates example data.
* Runs diagnostics.
* Plots raw temperature and overheating zones.
* Prints diagnostic report in Markdown format.

**Example Usage**

```matlab
main
```
