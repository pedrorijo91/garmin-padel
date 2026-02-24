import Toybox.Lang;
import Toybox.Test;

(:test)
function goesIntoSuperTieTest(logger as Logger) as Boolean {

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

    // 0-1
    match.incP2();
    match.incP2();
    match.incP2();
    match.incP2();
    // 0-2
    match.incP2();
    match.incP2();
    match.incP2();
    match.incP2();
    // 0-3
    match.incP2();
    match.incP2();
    match.incP2();
    match.incP2();
    // 0-4
    match.incP2();
    match.incP2();
    match.incP2();
    match.incP2();
    // 0-5
    match.incP2();
    match.incP2();
    match.incP2();
    match.incP2();
    // 0-6 (1-1 sets)
    match.incP2();
    match.incP2();
    match.incP2();
    match.incP2();

    // super: 1-2
    match.incP2();
    match.incP1();
    match.incP2();
    var status = match.getMatchStatus();

    return 
        status.getP1Sets() == 1 &&
        status.getP2Sets() == 1 &&
        status.getP1Games() == 0 &&
        status.getP2Games() == 0 &&
        status.getP1Score() == 0 &&
        status.getP2Score() == 0 &&
        status.getP1TieScore() == 1 &&
        status.getP2TieScore() == 2;
}

(:test)
function superTieFinishTest(logger as Logger) as Boolean {
    
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

    // 0-1
    match.incP2();
    match.incP2();
    match.incP2();
    match.incP2();
    // 0-2
    match.incP2();
    match.incP2();
    match.incP2();
    match.incP2();
    // 0-3
    match.incP2();
    match.incP2();
    match.incP2();
    match.incP2();
    // 0-4
    match.incP2();
    match.incP2();
    match.incP2();
    match.incP2();
    // 0-5
    match.incP2();
    match.incP2();
    match.incP2();
    match.incP2();
    // 0-6 (1-1 sets)
    match.incP2();
    match.incP2();
    match.incP2();
    match.incP2();

    // 10-0 super
    match.incP1();
    match.incP1();
    match.incP1();
    match.incP1();
    match.incP1();
    match.incP1();
    match.incP1();
    match.incP1();
    match.incP1();
    var res = match.incP1();

    var status = match.getMatchStatus();
        
    return 
        res == true && // true means game over
        status.getP1Sets() == 2 &&
        status.getP2Sets() == 1 &&
        status.getP1Games() == 0 &&
        status.getP2Games() == 0 &&
        status.getP1Score() == 0 &&
        status.getP2Score() == 0 &&
        status.getP1TieScore() == 10 &&
        status.getP2TieScore() == 0;
}

(:test)
function superTieFinishOnlyWhenAdvantageTest(logger as Logger) as Boolean {
    
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

    // 0-1
    match.incP2();
    match.incP2();
    match.incP2();
    match.incP2();
    // 0-2
    match.incP2();
    match.incP2();
    match.incP2();
    match.incP2();
    // 0-3
    match.incP2();
    match.incP2();
    match.incP2();
    match.incP2();
    // 0-4
    match.incP2();
    match.incP2();
    match.incP2();
    match.incP2();
    // 0-5
    match.incP2();
    match.incP2();
    match.incP2();
    match.incP2();
    // 0-6 (1-1 sets)
    match.incP2();
    match.incP2();
    match.incP2();
    match.incP2();

    // super: 9-9
    match.incP1();
    match.incP2();
    match.incP1();
    match.incP2();
    match.incP1();
    match.incP2();
    match.incP1();
    match.incP2();
    match.incP1();
    match.incP2();
    match.incP1();
    match.incP2();
    match.incP1();
    match.incP2();
    match.incP1();
    match.incP2();
    match.incP1();
    match.incP2();

    var tieStatus = match.getMatchStatus();

    // tie: 13-11 (set)
    match.incP1();
    match.incP2();
    match.incP1();
    match.incP2();
    match.incP1();
    match.incP1();

    var status = match.getMatchStatus();

    return 
        tieStatus.getP1Sets() == 1 &&
        tieStatus.getP2Sets() == 1 &&
        tieStatus.getP1Games() == 0 &&
        tieStatus.getP2Games() == 0 &&
        tieStatus.getP1Score() == 0 &&
        tieStatus.getP2Score() == 0 &&
        tieStatus.getP1TieScore() == 9 &&
        tieStatus.getP2TieScore() == 9 && 
        status.getP1Sets() == 2 &&
        status.getP2Sets() == 1 &&
        status.getP1Games() == 0 &&
        status.getP2Games() == 0 &&
        status.getP1Score() == 0 &&
        status.getP2Score() == 0 &&
        status.getP1TieScore() == 13 &&
        status.getP2TieScore() == 11;
}

(:test)
function undoInsideSuperTieBreakTest(logger as Logger) as Boolean {
    
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

    // 0-1
    match.incP2();
    match.incP2();
    match.incP2();
    match.incP2();
    // 0-2
    match.incP2();
    match.incP2();
    match.incP2();
    match.incP2();
    // 0-3
    match.incP2();
    match.incP2();
    match.incP2();
    match.incP2();
    // 0-4
    match.incP2();
    match.incP2();
    match.incP2();
    match.incP2();
    // 0-5
    match.incP2();
    match.incP2();
    match.incP2();
    match.incP2();
    // 0-6 (1-1 sets)
    match.incP2();
    match.incP2();
    match.incP2();
    match.incP2();

    // super: 2-0
    match.incP1();
    match.incP1();

    // undo last super tie point -> 1-0
    match.undo();

    var status = match.getMatchStatus();

    return 
        status.getP1Sets() == 1 &&
        status.getP2Sets() == 1 &&
        status.getP1Games() == 0 &&
        status.getP2Games() == 0 &&
        status.getP1Score() == 0 &&
        status.getP2Score() == 0 &&
        status.getP1TieScore() == 1 &&
        status.getP2TieScore() == 0;
}

(:test)
function superTieP2WinsTest(logger as Logger) as Boolean {
    
    var matchConfig = new MatchConfig();
    matchConfig.setGoldenPoint(true);
    matchConfig.setNumberOfSets(3);
    matchConfig.setSuperTie(true);

    var match = new PadelMatch(matchConfig);

    // 1-0 set
    match.incP1();
    match.incP1();
    match.incP1();
    match.incP1();
    match.incP1();
    match.incP1();
    match.incP1();
    match.incP1();
    match.incP1();
    match.incP1();
    match.incP1();
    match.incP1();
    match.incP1();
    match.incP1();
    match.incP1();
    match.incP1();
    match.incP1();
    match.incP1();
    match.incP1();
    match.incP1();
    match.incP1();
    match.incP1();
    match.incP1();
    match.incP1();

    // 0-1 set
    match.incP2();
    match.incP2();
    match.incP2();
    match.incP2();
    match.incP2();
    match.incP2();
    match.incP2();
    match.incP2();
    match.incP2();
    match.incP2();
    match.incP2();
    match.incP2();
    match.incP2();
    match.incP2();
    match.incP2();
    match.incP2();
    match.incP2();
    match.incP2();
    match.incP2();
    match.incP2();
    match.incP2();
    match.incP2();
    match.incP2();
    match.incP2();
    match.incP2();

    // super tie: P2 wins 10-8 (e.g. 8 incP1, 10 incP2 in super)
    match.incP1();
    match.incP2();
    match.incP1();
    match.incP2();
    match.incP1();
    match.incP2();
    match.incP1();
    match.incP2();
    match.incP1();
    match.incP2();
    match.incP1();
    match.incP2();
    match.incP1();
    match.incP2();
    match.incP1();
    match.incP2();
    var res = match.incP2();

    var status = match.getMatchStatus();

    return 
        res == true &&
        status.getP1Sets() == 1 &&
        status.getP2Sets() == 2 &&
        status.getP1Games() == 0 &&
        status.getP2Games() == 0 &&
        status.getP1Score() == 0 &&
        status.getP2Score() == 0 &&
        status.getP1TieScore() == 8 &&
        status.getP2TieScore() == 10;
}
