import Toybox.Lang;
import Toybox.Test;

(:test)
function goesIntoTieTest(logger as Logger) as Boolean {
    
    var matchConfig = getConfig();
    var match = new PadelMatch(matchConfig);

    playSetTo6All(match);
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
    
    var matchConfig = getConfig();
    var match = new PadelMatch(matchConfig);

    playSetTo6All(match);
    playTieBreak(match, 4, 2);

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
    
    var matchConfig = getConfig();
    var match = new PadelMatch(matchConfig);

    playSetTo6All(match);
    playPointsP1(match, 7);

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
    
    var matchConfig = getConfig();
    var match = new PadelMatch(matchConfig);

    playSetTo6All(match);
    playPointsP1(match, 6);
    playPointsP2(match, 6);
    playPointsP1(match, 1);
    playPointsP2(match, 1);

    var tieStatus = match.getMatchStatus();

    playPointsP1(match, 2);

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

(:test)
function undoInsideTieBreakTest(logger as Logger) as Boolean {
    
    var matchConfig = getConfig();
    var match = new PadelMatch(matchConfig);

    playSetTo6All(match);
    match.incP1();
    match.incP1();
    match.undo();

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
function tieP2WinsSetTest(logger as Logger) as Boolean {
    
    var matchConfig = getConfig();
    var match = new PadelMatch(matchConfig);

    playSetTo6All(match);
    playPointsP1(match, 5);
    playPointsP2(match, 6);
    var res = match.incP2();

    var status = match.getMatchStatus();

    return 
        res == false &&
        status.getP1Sets() == 0 &&
        status.getP2Sets() == 1 &&
        status.getP1Games() == 0 &&
        status.getP2Games() == 0 &&
        status.getP1Score() == 0 &&
        status.getP2Score() == 0 &&
        status.getP1TieScore() == 0 &&
        status.getP2TieScore() == 0;
}
