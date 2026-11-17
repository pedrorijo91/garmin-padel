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
  // a long friendly: 10 sets = 10 * 3 chars + 9 * 3 separators = 57
  var s = "6-4 / 4-6 / 6-3 / 3-6 / 7-5 / 5-7 / 6-2 / 2-6 / 6-1 / 1-6";
  var r = fitString(s, FIT_STRING_MAX);
  return r.length() == FIT_STRING_MAX && s.find(r) == 0;
}
