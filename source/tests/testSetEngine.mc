import Toybox.Lang;
import Toybox.Test;

(:test)
function normalSetEngine_sixGamesWinsSet(logger as Logger) as Boolean {
    var gameEngine = new GoldenPointGameEngine();
    var setEngine = new NormalSetEngine(gameEngine);
    var hist = [];
    var status = new MatchStatus(0, 0, 0, 0, 0, 0, 0, 0, hist);
    playNGames(setEngine, Sides.SIDE_P1, status, 6);
    return status.getP1Sets() == 1 && status.getP1Games() == 6 && status.getP2Games() == 0;
}

(:test)
function normalSetEngine_tieBreakAt66(logger as Logger) as Boolean {
    var gameEngine = new GoldenPointGameEngine();
    var setEngine = new NormalSetEngine(gameEngine);
    var hist = [];
    var status = new MatchStatus(0, 0, 0, 0, 0, 0, 0, 0, hist);
    playSetTo6AllForEngine(setEngine, status);
    var inTie = setEngine.isInTieBreak(status);
    return inTie && status.getP1Games() == 6 && status.getP2Games() == 6;
}

(:test)
function normalSetEngine_tieBreak_76DoesNotWin(logger as Logger) as Boolean {
    var gameEngine = new GoldenPointGameEngine();
    var setEngine = new NormalSetEngine(gameEngine);
    var hist = [];
    var status = new MatchStatus(0, 0, 0, 0, 0, 0, 0, 0, hist);
    playSetTo6AllForEngine(setEngine, status);
    playTieBreakPoints(setEngine, status, 6, 6);
    setEngine.scorePoint(Sides.SIDE_P1, status); // 7-6: set not won (need margin 2)
    var setWonAt76 = status.getP1Sets() == 0 && status.getP2Sets() == 0 && status.getP1TieScore() == 7 && status.getP2TieScore() == 6;
    if (!setWonAt76) {
        return false;
    }
    setEngine.scorePoint(Sides.SIDE_P1, status); // 8-6: set won
    return status.getP1Sets() == 1 && status.getP1TieScore() == 8 && status.getP2TieScore() == 6;
}

(:test)
function normalSetEngine_tieBreakP1Wins75(logger as Logger) as Boolean {
    var gameEngine = new GoldenPointGameEngine();
    var setEngine = new NormalSetEngine(gameEngine);
    var hist = [];
    var status = new MatchStatus(0, 0, 0, 0, 0, 0, 0, 0, hist);
    playSetTo6AllForEngine(setEngine, status);
    playTieBreakPoints(setEngine, status, 7, 5);
    return status.getP1Sets() == 1 && status.getP1TieScore() == 7 && status.getP2TieScore() == 5;
}

(:test)
function normalSetEngine_notInSuperTie(logger as Logger) as Boolean {
    var gameEngine = new GoldenPointGameEngine();
    var setEngine = new NormalSetEngine(gameEngine);
    var hist = [];
    var status = new MatchStatus(0, 0, 6, 6, 0, 0, 3, 3, hist);
    return setEngine.isInSuperTieBreak(status) == false;
}

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

// --- NormalSetEngine + AdvantageGameEngine (variable-length games) ---

(:test)
function normalSetEngine_advantageGame_p1WinsAfterDeuce(logger as Logger) as Boolean {
    var gameEngine = new AdvantageGameEngine();
    var setEngine = new NormalSetEngine(gameEngine);
    var hist = [];
    var status = new MatchStatus(0, 0, 0, 0, 0, 0, 0, 0, hist);
    playOneGameP1WinsWithAdvantage(setEngine, status);
    return status.getP1Games() == 1 && status.getP2Games() == 0 && status.getP1Score() == 0 && status.getP2Score() == 0;
}

(:test)
function normalSetEngine_advantageGame_p2WinsAfterDeuceAndRevert(logger as Logger) as Boolean {
    var gameEngine = new AdvantageGameEngine();
    var setEngine = new NormalSetEngine(gameEngine);
    var hist = [];
    var status = new MatchStatus(0, 0, 0, 0, 0, 0, 0, 0, hist);
    playOneGameP2WinsWithAdvantage(setEngine, status);
    return status.getP1Games() == 0 && status.getP2Games() == 1 && status.getP1Score() == 0 && status.getP2Score() == 0;
}

(:test)
function normalSetEngine_advantageEngine_setCompletes64(logger as Logger) as Boolean {
    var gameEngine = new AdvantageGameEngine();
    var setEngine = new NormalSetEngine(gameEngine);
    var hist = [];
    var status = new MatchStatus(0, 0, 0, 0, 0, 0, 0, 0, hist);
    playOneGameP1WinsWithAdvantage(setEngine, status);
    playNGames(setEngine, Sides.SIDE_P1, status, 4);
    playNGames(setEngine, Sides.SIDE_P2, status, 4);
    playOneGame(setEngine, Sides.SIDE_P1, status); // 6-4, set won
    return status.getP1Games() == 6 && status.getP2Games() == 4 && status.getP1Sets() == 1 && status.getP2Sets() == 0;
}
