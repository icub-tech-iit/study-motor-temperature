function tests = test_ErrorHandlingTemperature
% TEST_ERRORHANDLINGTEMPERATURE — Unit tests for error detection module.
tests = functiontests(localfunctions);
end

function test_errorDetection(testCase)
  % Ramp from 0 to -100 °C evenly mapped over time
  t = 0:0.002:100;
  T = -t;  % °C
  thr = 55;  % well above the signal (no overheating)
  
  D = errorHandlingTemperature(T, t, thr);

  pct = D.percentage;
  
  % 20% values for each error type are expected.
  % This derives from how errors are defined in the documentation.
  
  verifyThatWithinTolerance(testCase, pct.FOC_TDB_I2C_NACK, 20, 1);
  verifyThatWithinTolerance(testCase, pct.FOC_TDB_NO_MEAS,  20, 1);
  verifyThatWithinTolerance(testCase, pct.TDB_LOST_CONFIG,  20, 1);
  verifyThatWithinTolerance(testCase, pct.TDB_ANY_CONFIG,   20, 1);

  % No overheating expected
  verifyLessThanOrEqual(testCase, pct.OVERHEAT, 0.1);

end



% --- helper assertion ----------------------------------------------------
function verifyThatWithinTolerance(tc, actual, expected, tol)
tc.verifyLessThanOrEqual(abs(actual - expected), tol, ...
  sprintf('%.2f not within ±%.2f of %.2f', actual, tol, expected));
end
