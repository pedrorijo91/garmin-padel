import Toybox.Lang;
import Toybox.Test;

(:test)
function goesNormalLastSetTest(logger as Logger) as Boolean {

    var matchConfig = getConfig();
    matchConfig.setSuperTie(false);
    var match = new PadelMatch(matchConfig);

    playSet(match, 6, 0);
    playSet(match, 0, 6);
    playSet(match, 2, 1);

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