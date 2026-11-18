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
  return fitString("6-3 / 7-6 (5) / [10-8]", FIT_STRING_MAX).equals("6-3 / 7-6 (5) / [10-8]");
}

(:test)
function testFitStringTruncated(logger as Logger) as Boolean {
  // a long friendly: 10 sets = 10 * 3 chars + 9 * 3 separators = 57
  var s = "6-4 / 4-6 / 6-3 / 3-6 / 7-5 / 5-7 / 6-2 / 2-6 / 6-1 / 1-6";
  var r = fitString(s, FIT_STRING_MAX);
  // cut before the separator: 8 complete sets (45 chars), no partial "/ 6" at the end
  if (!r.equals("6-4 / 4-6 / 6-3 / 3-6 / 7-5 / 5-7 / 6-2 / 2-6")) {
    logger.error("got '" + r + "'");
    return false;
  }
  // a separator right at the limit keeps everything before it
  return fitString("[10-8] / 6-4", 8).equals("[10-8]") && fitString("6-4 / 6-3", 6).equals("6-4");
}
