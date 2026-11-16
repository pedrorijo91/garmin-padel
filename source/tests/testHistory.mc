import Toybox.Lang;
import Toybox.Test;

(:test)
function scoreHistoryMidSetTest(logger as Logger) as Boolean {
    
    var matchConfig = getConfig();
    var match = new PadelMatch(matchConfig);

    playSet(match, 3, 1);

    var history = match.getHistoricalScores();

    return 
        history.size() == 1 &&
        history[0].equals("3-1");
}


(:test)
function scoreHistoryAfterSetTest(logger as Logger) as Boolean {
    
    var matchConfig = getConfig();
    var match = new PadelMatch(matchConfig);

    playSet(match, 6, 0);

    var history = match.getHistoricalScores();

    return 
        history.size() == 1 &&
        history[0].equals("6-0");
}

(:test)
function scoreHistoryMoreThanOneSetTest(logger as Logger) as Boolean {
    
    var matchConfig = getConfig();
    var match = new PadelMatch(matchConfig);

    playSet(match, 6, 0);
    playSet(match, 2, 1);

    var history = match.getHistoricalScores();

    return 
        history.size() == 2 &&
        history[0].equals("6-0") &&
        history[1].equals("2-1");
}

(:test)
function scoreHistoryTieBreakSetTest(logger as Logger) as Boolean {

    var matchConfig = getConfig();
    var match = new PadelMatch(matchConfig);

    playSetTo6All(match);
    playTieBreak(match, 5, 7);

    var history = match.getHistoricalScores();

    return
        history.size() == 1 &&
        history[0].equals("6-7 (5)");
}

(:test)
function scoreHistorySuperTieBracketsTest(logger as Logger) as Boolean {

    var matchConfig = getConfig();
    var match = new PadelMatch(matchConfig);

    playSet(match, 6, 0);
    playSet(match, 0, 6);
    playSuperTieBreak(match, 3, 2);

    // a super tie in progress is shown with its points
    var inProgress = match.getHistoricalScores();

    playPointsP2(match, 6);
    playPointsP1(match, 7);

    var history = match.getHistoricalScores();

    return
        inProgress.size() == 3 &&
        inProgress[2].equals("[3-2]") &&
        history.size() == 3 &&
        history[0].equals("6-0") &&
        history[1].equals("0-6") &&
        history[2].equals("[10-8]");
}
