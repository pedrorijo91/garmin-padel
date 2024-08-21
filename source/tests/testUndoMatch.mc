import Toybox.Lang;
import Toybox.Test;

(:test)
function undoOnceTest(logger as Logger) as Boolean {
    
    var matchConfig = new MatchConfig();
    matchConfig.setGoldenPoint(true);
    matchConfig.setNumberOfSets(3);
    matchConfig.setSuperTie(true);

    // match 30-30 and then 40-30  
    var match = new PadelMatch(matchConfig);
    match.incP1();
    match.incP1();
    match.incP2();
    match.incP2();
    match.incP1();

    match.undo();

    var status = match.getMatchStatus();

    return 
        status.getP1Sets() == 0 &&
        status.getP2Sets() == 0 &&
        status.getP1Games() == 0 &&
        status.getP2Games() == 0 &&
        status.getP1Score() == 30 &&
        status.getP2Score() == 30 &&
        status.getP1TieScore() == 0 &&
        status.getP2TieScore() == 0;
}

(:test)
function multipleUndoTest(logger as Logger) as Boolean {
    
    var matchConfig = new MatchConfig();
    matchConfig.setGoldenPoint(true);
    matchConfig.setNumberOfSets(3);
    matchConfig.setSuperTie(true);

    // match 30-30 and then 40-30  
    var match = new PadelMatch(matchConfig);
    match.incP1();
    match.incP1();
    match.incP2();
    match.incP2();
    match.incP1();

    match.undo();
    match.undo();
    match.undo();

    var status = match.getMatchStatus();

    return 
        status.getP1Sets() == 0 &&
        status.getP2Sets() == 0 &&
        status.getP1Games() == 0 &&
        status.getP2Games() == 0 &&
        status.getP1Score() == 30 &&
        status.getP2Score() == 30 &&
        status.getP1TieScore() == 0 &&
        status.getP2TieScore() == 0;
}

(:test)
function undoAfterGameTest(logger as Logger) as Boolean {
    
    var matchConfig = new MatchConfig();
    matchConfig.setGoldenPoint(true);
    matchConfig.setNumberOfSets(3);
    matchConfig.setSuperTie(true);

    // match 40-30 and then P1  
    var match = new PadelMatch(matchConfig);
    match.incP1();
    match.incP1();
    match.incP1();
    match.incP2();
    match.incP2();

    match.incP1();

    match.undo();

    var status = match.getMatchStatus();

    return 
        status.getP1Sets() == 0 &&
        status.getP2Sets() == 0 &&
        status.getP1Games() == 0 &&
        status.getP2Games() == 0 &&
        status.getP1Score() == 40 &&
        status.getP2Score() == 30 &&
        status.getP1TieScore() == 0 &&
        status.getP2TieScore() == 0;
}

(:test)
function undoAfterSetTest(logger as Logger) as Boolean {
    
    var matchConfig = new MatchConfig();
    matchConfig.setGoldenPoint(true);
    matchConfig.setNumberOfSets(3);
    matchConfig.setSuperTie(true);

    // match was (5-2) 40-15 and then P1 
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
    // 3-2
    match.incP2();
    match.incP2();
    match.incP2();
    match.incP2();
    // 4-2
    match.incP1();
    match.incP1();
    match.incP1();
    match.incP1();
    // 5-2
    match.incP1();
    match.incP1();
    match.incP1();
    match.incP1();
    // 40-15
    match.incP1();
    match.incP1();
    match.incP1();
    match.incP2();

    match.incP1();

    match.undo();

    var status = match.getMatchStatus();

    var history = match.getHistoricalScores();
    logger.debug(history);

    Test.assert(history.size == 2);

    return 
        history.size == 1 &&
        history[0] == "5-2" &&
        status.getP1Sets() == 0 &&
        status.getP2Sets() == 0 &&
        status.getP1Games() == 5 &&
        status.getP2Games() == 2 &&
        status.getP1Score() == 40 &&
        status.getP2Score() == 15 &&
        status.getP1TieScore() == 0 &&
        status.getP2TieScore() == 0;
}

(:test)
function undoAdvantagesTest(logger as Logger) as Boolean {
    
    var matchConfig = new MatchConfig();
    matchConfig.setGoldenPoint(false);
    matchConfig.setNumberOfSets(3);
    matchConfig.setSuperTie(true);

    // match 40-40 and then A-40  
    var match = new PadelMatch(matchConfig);
    match.incP1();
    match.incP1();
    match.incP1();
    match.incP2();
    match.incP2();
    match.incP2();
    match.incP1();

    match.undo();

    var status = match.getMatchStatus();

    return 
        status.getP1Sets() == 0 &&
        status.getP2Sets() == 0 &&
        status.getP1Games() == 0 &&
        status.getP2Games() == 0 &&
        status.getP1Score() == 40 &&
        status.getP2Score() == 40 &&
        status.getP1TieScore() == 0 &&
        status.getP2TieScore() == 0;
}

(:test)
function undoAdvAfterGameTest(logger as Logger) as Boolean {
    
    var matchConfig = new MatchConfig();
    matchConfig.setGoldenPoint(false);
    matchConfig.setNumberOfSets(3);
    matchConfig.setSuperTie(true);

    // match A-40 and then P1  
    var match = new PadelMatch(matchConfig);
    match.incP1();
    match.incP1();
    match.incP1();
    match.incP2();
    match.incP2();
    match.incP2();
    match.incP1();

    match.incP1();

    match.undo();

    var status = match.getMatchStatus();

    return 
        status.getP1Sets() == 0 &&
        status.getP2Sets() == 0 &&
        status.getP1Games() == 0 &&
        status.getP2Games() == 0 &&
        status.getP1Score() == 'A' &&
        status.getP2Score() == 40 &&
        status.getP1TieScore() == 0 &&
        status.getP2TieScore() == 0;
}

