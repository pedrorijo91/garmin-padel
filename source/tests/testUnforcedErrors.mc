import Toybox.Lang;
import Toybox.Test;

(:test)
function unforcedErrorsIncrementTest(logger as Logger) as Boolean {

    var matchConfig = getConfig();
    var match = new PadelMatch(matchConfig);

    match.addUnforcedError();
    match.addUnforcedError();

    var status = match.getMatchStatus();

    return status.getUnforcedErrors() == 2;
}

(:test)
function unforcedErrorsUndoTest(logger as Logger) as Boolean {

    var matchConfig = getConfig();
    var match = new PadelMatch(matchConfig);

    match.addUnforcedError();
    match.addUnforcedError();

    match.undo();

    var status = match.getMatchStatus();

    return status.getUnforcedErrors() == 1;
}

