import Toybox.Lang;
import Toybox.Test;

(:test)
function golden_incP1WhenDeuceTest(logger as Logger) as Boolean {
    
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
    match.incP2();
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