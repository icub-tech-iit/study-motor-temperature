# Test Suite Documentation

## Table of Contents

* [tests/test\_detectOverheating.m](#test_detectoverheatingm)

  * [test\_detectOverheating](#function-test_detectoverheating)
  * [Local test: test\_overheatingSynthetic](#local-test-test_overheatingsynthetic)
  * [Local test: test\_overheatingReal](#local-test-test_overheatingreal)
  * [Local helper: verifyThatWithinTolerance](#local-helper-verifythatwithintolerance)
* [tests/test\_ErrorHandlingTemperature.m](#test_errorhandlingtemperaturem)

  * [test\_ErrorHandlingTemperature](#function-test_errorhandlingtemperature)
  * [Local test: test\_errorDetection](#local-test-test_errordetection)
  * [Local helper: verifyThatWithinTolerance](#local-helper-verifythatwithintolerance-1)
* [tests/test\_Runner.m](#test_runnerm)

---

## `tests/test_detectOverheating.m`

### Function: `test_detectOverheating`

**Purpose**
Entry point for unit tests validating the overheating detection module.

**Parameters**
*None (MATLAB unit test framework calls this without user parameters).*

**Return Values**

* `tests` (array of `matlab.unittest.Test`): Suite constructed from local test functions.

**Example Usage**

```matlab
results = runtests('test_detectOverheating');
disp(results);
```

**Notes**

* Uses MATLAB’s `functiontests(localfunctions)` pattern.
* Aggregates the local tests defined in this file.

---

### Local test: `test_overheatingSynthetic(testCase)`

**Purpose**
Validate that `detectOverheating` correctly identifies two symmetric overheating regions and \~50% overheating time on a synthetic sinusoid.

**Parameters**

* `testCase` (`matlab.unittest.FunctionTestCase`): Provided by the framework.

**Behavior & Checks**

* Builds a sinusoid `T = 60*sin(2*pi*t/50)` over `t = 0:0.02:100`.
* Uses `thr = 0` so the sinusoid is above threshold half the time.
* Asserts:

  * Overheating percentage is **50% ± 1%**.
  * Exactly **2** overheating regions are detected (`startIdx` and `endIdx` lengths are both 2).
* Produces a figure for visual inspection using `plotOverheatingZones`.

**Return Values**
*None (asserts via `verify*` APIs).*

**Example Usage**

```matlab
r = runtests('test_detectOverheating', 'ProcedureName', 'test_overheatingSynthetic');
```

**Notes**

* Creates a plot window for visual verification.

---

### Local test: `test_overheatingReal(testCase)`

**Purpose**
Run overheating detection on real data loaded from a `.mat` file and verify exactly one overheating region.

**Parameters**

* `testCase` (`matlab.unittest.FunctionTestCase`): Provided by the framework.

**Behavior & Checks**

* Prompts the user to select a `.mat` file via `uigetfile`.
* Loads `experimentData` and extracts:

  * `T` via `getTemperatureData("torso_pitch_mj1_real_aksim2", experimentData)`
  * `t` via `getTimestamps(experimentData)`
* Runs `detectOverheating` with `thr = 55`.
* Asserts:

  * One region detected (`length(R.startIdx) == 1` and `length(R.endIdx) == 1`).
* Produces a figure for visual inspection.

**Return Values**
*None (asserts via `verify*` APIs).*

**Example Usage**

```matlab
r = runtests('test_detectOverheating', 'ProcedureName', 'test_overheatingReal');
```

**Notes**

* **Interactive**: requires file selection.
* Creates a plot window.

---

### Local helper: `verifyThatWithinTolerance(tc, actual, expected, tol)`

**Purpose**
Assert that `actual` is within `±tol` of `expected`.

**Parameters**

* `tc` (`matlab.unittest.FunctionTestCase`)
* `actual` (double)
* `expected` (double)
* `tol` (double)

**Return Values**
*None (performs an assertion).*

**Example Usage**

```matlab
verifyThatWithinTolerance(testCase, pct, 50, 1);
```

**Notes**

* Wraps `verifyLessThanOrEqual(abs(actual - expected), tol, ...)` with a formatted message.

---

## `tests/test_ErrorHandlingTemperature.m`

### Function: `test_ErrorHandlingTemperature`

**Purpose**
Entry point for unit tests validating the temperature diagnostic/error handling module.

**Parameters**
*None.*

**Return Values**

* `tests` (array of `matlab.unittest.Test`): Suite constructed from local test functions.

**Example Usage**

```matlab
results = runtests('test_ErrorHandlingTemperature');
disp(results);
```

**Notes**

* Uses MATLAB’s `functiontests(localfunctions)` pattern.

---

### Local test: `test_errorDetection(testCase)`

**Purpose**
Verify diagnostic percentage buckets for hardware error bands on a linear ramp and confirm no overheating.

**Parameters**

* `testCase` (`matlab.unittest.FunctionTestCase`)

**Behavior & Checks**

* Constructs a time base `t = 0:0.002:100` and a linear ramp `T = -t` that spans `0` to `-100 °C`.
* Calls `errorHandlingTemperature(T, t, 55)`; overheating should not occur.
* Asserts (each within **±1%** tolerance) that the percentage of time in each band is \~**20%**:

  * `FOC_TDB_I2C_NACK` (−90 to −70 °C)
  * `FOC_TDB_NO_MEAS`  (−70 to −50 °C)
  * `TDB_LOST_CONFIG`  (−50 to −30 °C)
  * `TDB_ANY_CONFIG`   (−30 to −10 °C)
* Asserts that overheating percentage is essentially **0%** (≤ 0.1).

**Return Values**
*None.*

**Example Usage**

```matlab
r = runtests('test_ErrorHandlingTemperature', 'ProcedureName', 'test_errorDetection');
```

---

### Local helper: `verifyThatWithinTolerance(tc, actual, expected, tol)`

**Purpose**
Assert that `actual` is within `±tol` of `expected`, with a formatted message.

**Parameters**

* `tc` (`matlab.unittest.FunctionTestCase`)
* `actual` (double)
* `expected` (double)
* `tol` (double)

**Return Values**
*None.*

**Example Usage**

```matlab
verifyThatWithinTolerance(testCase, pct.TDB_ANY_CONFIG, 20, 1);
```

---

## `tests/test_Runner.m`

### Script: `test_Runner`

**Purpose**
Convenience script to run selected test files and display results.

**Parameters**
*None (script).*

**Return Values**
*None (prints to Command Window).*

**Behavior**

* Executes:

  ```matlab
  testResult_ErrorHandlingTemperature = runtests('test_ErrorHandlingTemperature');
  disp(testResult_ErrorHandlingTemperature);
  ```
* Contains a commented line to also run `test_detectOverheating`:

  ```matlab
  % testResult_detectOverheating = runtests('test_detectOverheating');
  % disp(testResult_detectOverheating);
  ```

**Example Usage**

```matlab
test_Runner
```

**Notes**

* Enable the second `runtests` line to include overheating tests:

  ```matlab
  testResult_detectOverheating = runtests('test_detectOverheating');
  disp(testResult_detectOverheating);
  ```

---

## General Notes for the Test Suite

* The tests rely on functions from the repository:

  * `detectOverheating`, `errorHandlingTemperature`, `plotOverheatingZones`,
    `getTemperatureData`, `getTimestamps`.
* Some tests create figures for visual inspection; this is intentional but can be commented out for headless CI runs.
* `test_overheatingReal` is **interactive** due to `uigetfile`. For automated pipelines, consider replacing with a fixed path.
