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
(:test)
function testFitStringShortUnchanged(logger as Logger) as Boolean {
  return fitString("6-3 / 4-3* / [10-8]", FIT_STRING_MAX).equals("6-3 / 4-3* / [10-8]");
}

(:test)
function testFitStringTruncated(logger as Logger) as Boolean {
  // six switched sets: 6 * 5 chars + 5 * 3 separators = 45; add two more sets to go past 49
  var s = "[1-0]* / [1-0]* / [1-0]* / [1-0]* / [1-0]* / [1-0]* / [1-0]*";
  var r = fitString(s, FIT_STRING_MAX);
  return r.length() == FIT_STRING_MAX && s.find(r) == 0;
}
