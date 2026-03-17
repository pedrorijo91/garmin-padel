import Toybox.Lang;
import Toybox.Test;

(:test)
function initMatchTest(logger as Logger) as Boolean {
    
    var matchConfig = new MatchConfig();
    matchConfig.setGoldenPoint(true);
    matchConfig.setNumberOfSets(3);
    matchConfig.setSuperTie(true);

    var match = new PadelMatch(matchConfig);
    var status = match.getMatchStatus();

    return 
        status.getP1Sets() == 0 &&
        status.getP2Sets() == 0 &&
        status.getP1Games() == 0 &&
        status.getP2Games() == 0 &&
        status.getP1Score() == 0 &&
        status.getP2Score() == 0 &&
        status.getP1TieScore() == 0 &&
        status.getP2TieScore() == 0;
  }


(:test)
function firstIncP1Test(logger as Logger) as Boolean {
    
    var matchConfig = new MatchConfig();
    matchConfig.setGoldenPoint(true);
    matchConfig.setNumberOfSets(3);
    matchConfig.setSuperTie(true);

    var match = new PadelMatch(matchConfig);
    var res = match.incP1();
    var status = match.getMatchStatus();

    return 
        res == false && // false means it's not match end
        status.getP1Sets() == 0 &&
        status.getP2Sets() == 0 &&
        status.getP1Games() == 0 &&
        status.getP2Games() == 0 &&
        status.getP1Score() == 15 &&
        status.getP2Score() == 0 &&
        status.getP1TieScore() == 0 &&
        status.getP2TieScore() == 0;
  }

(:test)
function multiIncP1Test(logger as Logger) as Boolean {
    
    var matchConfig = new MatchConfig();
    matchConfig.setGoldenPoint(true);
    matchConfig.setNumberOfSets(3);
    matchConfig.setSuperTie(true);

    var match = new PadelMatch(matchConfig);
    match.incP1();
    match.incP1();
    var res = match.incP1();
    var status = match.getMatchStatus();

    return 
        res == false && // false means it's not match end
        status.getP1Sets() == 0 &&
        status.getP2Sets() == 0 &&
        status.getP1Games() == 0 &&
        status.getP2Games() == 0 &&
        status.getP1Score() == 40 &&
        status.getP2Score() == 0 &&
        status.getP1TieScore() == 0 &&
        status.getP2TieScore() == 0;
  }

(:test)
function incGameP1Test(logger as Logger) as Boolean {
    
    var matchConfig = new MatchConfig();
    matchConfig.setGoldenPoint(true);
    matchConfig.setNumberOfSets(3);
    matchConfig.setSuperTie(true);

    var match = new PadelMatch(matchConfig);
    match.incP1();
    match.incP1();
    match.incP1();
    var res = match.incP1();
    var status = match.getMatchStatus();

    return 
        res == false && // false means it's not match end
        status.getP1Sets() == 0 &&
        status.getP2Sets() == 0 &&
        status.getP1Games() == 1 &&
        status.getP2Games() == 0 &&
        status.getP1Score() == 0 &&
        status.getP2Score() == 0 &&
        status.getP1TieScore() == 0 &&
        status.getP2TieScore() == 0;
  }

(:test)
function incP2ToDeuceTest(logger as Logger) as Boolean {
    
    var matchConfig = new MatchConfig();
    matchConfig.setGoldenPoint(true);
    matchConfig.setNumberOfSets(3);
    matchConfig.setSuperTie(true);

    var match = new PadelMatch(matchConfig);
    match.incP1();
    match.incP1();
    match.incP1();
    match.incP2();
    match.incP2();
    var res = match.incP2();
    var status = match.getMatchStatus();

    return 
        res == false && // false means it's not match end
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
function incSetP1Test(logger as Logger) as Boolean {
    
    var matchConfig = getConfig();
    var match = new PadelMatch(matchConfig);

    playPointsP1(match, 23);
    var res = match.incP1();

    var status = match.getMatchStatus();

    return 
        res == false && // false means it's not match end
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
function finishWhenTwoSetsTest(logger as Logger) as Boolean {

    var matchConfig = getConfig();
    var match = new PadelMatch(matchConfig);

    playSet(match, 6, 0);
    playPointsP1(match, 23);
    var res = match.incP1();
    var status = match.getMatchStatus();

    return 
        res == true && // true means it's match end
        status.getP1Sets() == 2 &&
        status.getP2Sets() == 0 &&
        status.getP1Games() == 0 &&
        status.getP2Games() == 0 &&
        status.getP1Score() == 0 &&
        status.getP2Score() == 0 &&
        status.getP1TieScore() == 0 &&
        status.getP2TieScore() == 0;
}

(:test)
function noScoringWhenMatchOverTest(logger as Logger) as Boolean {
    var matchConfig = getConfig();
    var match = new PadelMatch(matchConfig);
    playSet(match, 6, 0);
    playPointsP1(match, 23);
    match.incP1();
    var statusBefore = match.getMatchStatus();
    var resP1 = match.incP1();
    var resP2 = match.incP2();
    var statusAfter = match.getMatchStatus();
    return resP1 == false && resP2 == false &&
        statusAfter.getP1Sets() == statusBefore.getP1Sets() &&
        statusAfter.getP2Sets() == statusBefore.getP2Sets() &&
        statusAfter.getP1Games() == statusBefore.getP1Games() &&
        statusAfter.getP2Games() == statusBefore.getP2Games();
}

(:test)
function miniSetInitAt22Test(logger as Logger) as Boolean {
    var matchConfig = getConfig();
    matchConfig.setSetType(MatchConfig.SET_TYPE_MINI);
    var match = new PadelMatch(matchConfig);
    var status = match.getMatchStatus();
    return status.getP1Games() == 2 && status.getP2Games() == 2 &&
        status.getP1Sets() == 0 && status.getP2Sets() == 0;
}

(:test)
function proSetOneSetWinsMatchTest(logger as Logger) as Boolean {
    var matchConfig = getConfig();
    matchConfig.setNumberOfSets(1);
    matchConfig.setSetType(MatchConfig.SET_TYPE_PRO);
    matchConfig.setSuperTie(false);
    var match = new PadelMatch(matchConfig);
    playPointsP1(match, 9 * 4);
    var status = match.getMatchStatus();
    return status.getP1Sets() == 1 && status.getP1Games() == 0 && status.getP2Games() == 0;
}

(:test)
function miniSetFourGamesFrom22WinsSetTest(logger as Logger) as Boolean {
    var matchConfig = getConfig();
    matchConfig.setNumberOfSets(1);
    matchConfig.setSetType(MatchConfig.SET_TYPE_MINI);
    matchConfig.setSuperTie(false);
    var match = new PadelMatch(matchConfig);
    playPointsP1(match, 4 * 4);
    var status = match.getMatchStatus();
    return status.getP1Sets() == 1 && status.getP1Games() == 0 && status.getP2Games() == 0;
}