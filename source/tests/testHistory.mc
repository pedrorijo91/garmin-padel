import Toybox.Lang;
import Toybox.Test;

(:test)
function scoreHistoryMidSetTest(logger as Logger) as Boolean {
    
    var matchConfig = new MatchConfig();
    matchConfig.setGoldenPoint(true);
    matchConfig.setNumberOfSets(3);
    matchConfig.setSuperTie(true);

    var match = new PadelMatch(matchConfig);
    // 1-0
    match.incP1();
    match.incP1();
    match.incP1();
    match.incP1();
    // 2-0
    match.incP1();
    match.incP1();
    match.incP1();
    match.incP1();
    // 3-0
    match.incP1();
    match.incP1();
    match.incP1();
    match.incP1();
    // 3-1
    match.incP2();
    match.incP2();
    match.incP2();
    match.incP2();
    
    var history = match.getHistoricalScores();

    return 
        history.size() == 1 &&
        history[0].equals("3-1");
}


(:test)
function scoreHistoryAfterSetTest(logger as Logger) as Boolean {
    
    var matchConfig = new MatchConfig();
    matchConfig.setGoldenPoint(true);
    matchConfig.setNumberOfSets(3);
    matchConfig.setSuperTie(true);

    var match = new PadelMatch(matchConfig);
    // 1-0
    match.incP1();
    match.incP1();
    match.incP1();
    match.incP1();
    // 2-0
    match.incP1();
    match.incP1();
    match.incP1();
    match.incP1();
    // 3-0
    match.incP1();
    match.incP1();
    match.incP1();
    match.incP1();
    // 4-0
    match.incP1();
    match.incP1();
    match.incP1();
    match.incP1();
    // 5-0
    match.incP1();
    match.incP1();
    match.incP1();
    match.incP1();
    // 6-0 (set)
    match.incP1();
    match.incP1();
    match.incP1();
    match.incP1();

    var history = match.getHistoricalScores();

    return 
        history.size() == 1 &&
        history[0].equals("6-0");
}

(:test)
function scoreHistoryMoreThanOneSetTest(logger as Logger) as Boolean {
    
    var matchConfig = new MatchConfig();
    matchConfig.setGoldenPoint(true);
    matchConfig.setNumberOfSets(3);
    matchConfig.setSuperTie(true);

    var match = new PadelMatch(matchConfig);
    // 1-0
    match.incP1();
    match.incP1();
    match.incP1();
    match.incP1();
    // 2-0
    match.incP1();
    match.incP1();
    match.incP1();
    match.incP1();
    // 3-0
    match.incP1();
    match.incP1();
    match.incP1();
    match.incP1();
    // 4-0
    match.incP1();
    match.incP1();
    match.incP1();
    match.incP1();
    // 5-0
    match.incP1();
    match.incP1();
    match.incP1();
    match.incP1();
    // 6-0 (set)
    match.incP1();
    match.incP1();
    match.incP1();
    match.incP1();

    // 1-0
    match.incP1();
    match.incP1();
    match.incP1();
    match.incP1();
    // 2-0
    match.incP1();
    match.incP1();
    match.incP1();
    match.incP1();
    // 2-1
    match.incP2();
    match.incP2();
    match.incP2();
    match.incP2();

    var history = match.getHistoricalScores();

    return 
        history.size() == 2 &&
        history[0].equals("6-0") &&
        history[1].equals("2-1");
}