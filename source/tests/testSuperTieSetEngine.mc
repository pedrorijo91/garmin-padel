import Toybox.Lang;
import Toybox.Test;

(:test)
function superTieSetEngine_wholeSetIsSuperTie(logger as Logger) as Boolean {
    var setEngine = new SuperTieSetEngine();
    var hist = [];
    var status = new MatchStatus(0, 0, 0, 0, 0, 0, 0, 0, hist);
    return setEngine.isInSuperTieBreak(status) == true;
}

(:test)
function superTieSetEngine_firstTo10Wins(logger as Logger) as Boolean {
    var setEngine = new SuperTieSetEngine();
    var hist = [];
    var status = new MatchStatus(0, 0, 0, 0, 0, 0, 0, 0, hist);
    playSuperTiePoints(setEngine, status, 10, 8);
    return status.getP1Sets() == 1 && status.getP1TieScore() == 10 && status.getP2TieScore() == 8;
}

(:test)
function superTieSetEngine_109DoesNotWin(logger as Logger) as Boolean {
    var setEngine = new SuperTieSetEngine();
    var hist = [];
    var status = new MatchStatus(0, 0, 0, 0, 0, 0, 0, 0, hist);
    playSuperTiePoints(setEngine, status, 10, 9); // 10-9: no margin, set not won
    return status.getP1Sets() == 0 && status.getP2Sets() == 0 && status.getP1TieScore() == 10 && status.getP2TieScore() == 9;
}

// P2 wins super tie (symmetry)

(:test)
function superTieSetEngine_p2Wins108(logger as Logger) as Boolean {
    var setEngine = new SuperTieSetEngine();
    var hist = [];
    var status = new MatchStatus(0, 0, 0, 0, 0, 0, 0, 0, hist);
    playSuperTiePoints(setEngine, status, 8, 10);
    return status.getP2Sets() == 1 && status.getP1TieScore() == 8 && status.getP2TieScore() == 10;
}

// Initial games for SuperTie set

(:test)
function superTieSetEngine_initialGamesZero(logger as Logger) as Boolean {
    var setEngine = new SuperTieSetEngine();
    return setEngine.getInitialP1Games() == 0 && setEngine.getInitialP2Games() == 0;
}

