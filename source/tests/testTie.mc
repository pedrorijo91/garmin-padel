import Toybox.Lang;
import Toybox.Test;

(:test)
function goesIntoTieTest(logger as Logger) as Boolean {
    
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
    // 5-1
    match.incP2();
    match.incP2();
    match.incP2();
    match.incP2();
    // 5-2
    match.incP2();
    match.incP2();
    match.incP2();
    match.incP2();  
    // 5-3
    match.incP2();
    match.incP2();
    match.incP2();
    match.incP2();  
    // 5-4
    match.incP2();
    match.incP2();
    match.incP2();
    match.incP2();  
    // 5-5
    match.incP2();
    match.incP2();
    match.incP2();
    match.incP2();  
    // 5-6
    match.incP2();
    match.incP2();
    match.incP2();
    match.incP2();
    // 6-6
    match.incP1();
    match.incP1();
    match.incP1();
    match.incP1();              

    // tie: 1-0
    match.incP1();
    var status = match.getMatchStatus();

    return 
        status.getP1Sets() == 0 &&
        status.getP2Sets() == 0 &&
        status.getP1Games() == 6 &&
        status.getP2Games() == 6 &&
        status.getP1Score() == 0 &&
        status.getP2Score() == 0 &&
        status.getP1TieScore() == 1 &&
        status.getP2TieScore() == 0;
}

(:test)
function tieScoreTest(logger as Logger) as Boolean {
    
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
    // 5-1
    match.incP2();
    match.incP2();
    match.incP2();
    match.incP2();
    // 5-2
    match.incP2();
    match.incP2();
    match.incP2();
    match.incP2();  
    // 5-3
    match.incP2();
    match.incP2();
    match.incP2();
    match.incP2();  
    // 5-4
    match.incP2();
    match.incP2();
    match.incP2();
    match.incP2();  
    // 5-5
    match.incP2();
    match.incP2();
    match.incP2();
    match.incP2();  
    // 5-6
    match.incP2();
    match.incP2();
    match.incP2();
    match.incP2();
    // 6-6
    match.incP1();
    match.incP1();
    match.incP1();
    match.incP1();              

    // tie: 4-2
    match.incP1();
    match.incP1();
    match.incP1();
    match.incP1();
    match.incP2();
    match.incP2();
    var status = match.getMatchStatus();

    return 
        status.getP1Sets() == 0 &&
        status.getP2Sets() == 0 &&
        status.getP1Games() == 6 &&
        status.getP2Games() == 6 &&
        status.getP1Score() == 0 &&
        status.getP2Score() == 0 &&
        status.getP1TieScore() == 4 &&
        status.getP2TieScore() == 2;
}

(:test)
function tieFinishTest(logger as Logger) as Boolean {
    
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
    // 5-1
    match.incP2();
    match.incP2();
    match.incP2();
    match.incP2();
    // 5-2
    match.incP2();
    match.incP2();
    match.incP2();
    match.incP2();  
    // 5-3
    match.incP2();
    match.incP2();
    match.incP2();
    match.incP2();  
    // 5-4
    match.incP2();
    match.incP2();
    match.incP2();
    match.incP2();  
    // 5-5
    match.incP2();
    match.incP2();
    match.incP2();
    match.incP2();  
    // 5-6
    match.incP2();
    match.incP2();
    match.incP2();
    match.incP2();
    // 6-6
    match.incP1();
    match.incP1();
    match.incP1();
    match.incP1();              

    // tie: 7-0 (set)
    match.incP1();
    match.incP1();
    match.incP1();
    match.incP1();
    match.incP1();
    match.incP1();
    match.incP1();
    var status = match.getMatchStatus();

    return 
        status.getP1Sets() == 1 &&
        status.getP2Sets() == 0 &&
        status.getP1Games() == 0 &&
        status.getP2Games() == 0 &&
        status.getP1Score() == 0 &&
        status.getP2Score() == 0 &&
        status.getP1TieScore() == 0 &&
        status.getP2TieScore() == 0;
}

(:test)
function tieFinishOnlyWhenAdvantageTest(logger as Logger) as Boolean {
    
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
    // 5-1
    match.incP2();
    match.incP2();
    match.incP2();
    match.incP2();
    // 5-2
    match.incP2();
    match.incP2();
    match.incP2();
    match.incP2();  
    // 5-3
    match.incP2();
    match.incP2();
    match.incP2();
    match.incP2();  
    // 5-4
    match.incP2();
    match.incP2();
    match.incP2();
    match.incP2();  
    // 5-5
    match.incP2();
    match.incP2();
    match.incP2();
    match.incP2();  
    // 5-6
    match.incP2();
    match.incP2();
    match.incP2();
    match.incP2();
    // 6-6
    match.incP1();
    match.incP1();
    match.incP1();
    match.incP1();              
    // tie: 6-6
    match.incP1();
    match.incP1();
    match.incP1();
    match.incP1();
    match.incP1();
    match.incP1();
    match.incP2();
    match.incP2();
    match.incP2();
    match.incP2();
    match.incP2();
    match.incP2();
    // tie: 7-7
    match.incP1();
    match.incP2();
    var tieStatus = match.getMatchStatus();

    // tie: 9-7 (set)
    match.incP1();
    match.incP1();

    var status = match.getMatchStatus();

    return 
        tieStatus.getP1Sets() == 0 &&
        tieStatus.getP2Sets() == 0 &&
        tieStatus.getP1Games() == 6 &&
        tieStatus.getP2Games() == 6 &&
        tieStatus.getP1Score() == 0 &&
        tieStatus.getP2Score() == 0 &&
        tieStatus.getP1TieScore() == 7 &&
        tieStatus.getP2TieScore() == 7 && 
        status.getP1Sets() == 1 &&
        status.getP2Sets() == 0 &&
        status.getP1Games() == 0 &&
        status.getP2Games() == 0 &&
        status.getP1Score() == 0 &&
        status.getP2Score() == 0 &&
        status.getP1TieScore() == 0 &&
        status.getP2TieScore() == 0;
}