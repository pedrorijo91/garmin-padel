import Toybox.Lang;
import Toybox.Test;

/*
    normal (super + 3):
        * check goes into tie
        * check tie score
        * check tie finish

        * check 2 sets over
        * check 1-1 set goes into super

        * check super scores work
        * checks super finishes correctly

    normal without super:
        * check last set is normal
    
    unlimited
        * check it finishes after X sets
*/

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