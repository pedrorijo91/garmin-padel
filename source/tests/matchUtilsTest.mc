import Toybox.Lang;
import Toybox.Test;

(:test)
function testMin(logger as Logger) as Boolean {
  return (min(1,2) == 1);
}

(:test)
function testAbsPositive(logger as Logger) as Boolean {
  return (abs(1) == 1);
}

(:test)
function testAbsNegative(logger as Logger) as Boolean {
  return (abs(-1) == 1);
}