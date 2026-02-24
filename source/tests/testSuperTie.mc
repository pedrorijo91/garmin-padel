import Toybox.Lang;
import Toybox.Test;

(:test)
function goesIntoSuperTieTest(logger as Logger) as Boolean {

    var matchConfig = getConfig();
    var match = new PadelMatch(matchConfig);

    playSet(match, 6, 0);
    playSet(match, 0, 6);
    playPointsP1(match, 1);
    playPointsP2(match, 2);

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
    
    var matchConfig = getConfig();
    var match = new PadelMatch(matchConfig);

    playSet(match, 6, 0);
    playSet(match, 0, 6);
    playPointsP1(match, 9);
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
    
    var matchConfig = getConfig();
    var match = new PadelMatch(matchConfig);

    playSet(match, 6, 0);
    playSet(match, 0, 6);
    playPointsP1(match, 9);
    playPointsP2(match, 9);

    var tieStatus = match.getMatchStatus();

    playPointsP1(match, 1);
    playPointsP2(match, 1);
    playPointsP1(match, 1);
    playPointsP2(match, 1);
    playPointsP1(match, 2);

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
    
    var matchConfig = getConfig();
    var match = new PadelMatch(matchConfig);

    playSet(match, 6, 0);
    playSet(match, 0, 6);
    match.incP1();
    match.incP1();
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
    
    var matchConfig = getConfig();
    var match = new PadelMatch(matchConfig);

    playSet(match, 6, 0);
    playSet(match, 0, 6);

    // super tie: P2 wins 10-8
    playPointsP1(match, 8);
    playPointsP2(match, 9);
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
