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