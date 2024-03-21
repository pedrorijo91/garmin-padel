import Toybox.Lang;
import Toybox.Test;

(:test)
function goesNormalLastSetTest(logger as Logger) as Boolean {

    var matchConfig = new MatchConfig();
    matchConfig.setGoldenPoint(true);
    matchConfig.setNumberOfSets(3);
    matchConfig.setSuperTie(false);

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

    // 3rd set: 1-0
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
    
    var status = match.getMatchStatus();

    return 
        status.getP1Sets() == 1 &&
        status.getP2Sets() == 1 &&
        status.getP1Games() == 2 &&
        status.getP2Games() == 1 &&
        status.getP1Score() == 0 &&
        status.getP2Score() == 0 &&
        status.getP1TieScore() == 0 &&
        status.getP2TieScore() == 0;
}