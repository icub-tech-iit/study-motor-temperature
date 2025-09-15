function tests = test_detectOverheating
% TEST_DETECTOVERHEATING — Unit tests for overheating detection module.
tests = functiontests(localfunctions);
end

function test_overheatingSynthetic(testCase)
  % Generates a sinusoid with two periods.
  t = (0:0.02:100);
  T = 60*sin(2*pi*t/50);
  thr = 0; % With this threshold two equal length overheat regions should
           % be detected.
  
  expected = 50; % Expected percentage of overheat.
  tol = 1; % Test successuful if pct == 50 +/- 1 [%].

  [mask, R] = detectOverheating(T, t, thr);

  pct = 100*sum(mask)/numel(T);

  % Checks that overheat is observed 50% of the experiment time.
  verifyThatWithinTolerance(testCase, pct, expected, tol);
  % Checks that the correct number of regions (bounded) are detected.
  verifyEqual(testCase, length(R.startIdx), 2)
  verifyEqual(testCase, length(R.endIdx), 2)
  % Visualize the information for visual check.
  figure;
  plotOverheatingZones(T, t, mask, R, thr)
    
end

function test_overheatingReal(testCase)
    
    [experimentName, experimentPath] = uigetfile({'*.mat','Data Files (*.mat)'}, ...
                                                  'Select the real data to run the test.');
    
    experimentData = load([experimentPath experimentName]);

    joint_name  = "torso_pitch_mj1_real_aksim2";

    T = getTemperatureData(joint_name, experimentData);
    t  = getTimestamps(experimentData);

    thr = 55;
    
    [mask, R] = detectOverheating(T, t, thr);
    
    verifyEqual(testCase, length(R.startIdx), 1)
    verifyEqual(testCase, length(R.endIdx), 1)
    
    % Visualize the information for visual check.
    figure;
    plotOverheatingZones(T, t, mask, R, thr)

end

% --- helper assertion ----------------------------------------------------
function verifyThatWithinTolerance(tc, actual, expected, tol)
tc.verifyLessThanOrEqual(abs(actual - expected), tol, ...
  sprintf('%.2f not within ±%.2f of %.2f', actual, tol, expected));
end