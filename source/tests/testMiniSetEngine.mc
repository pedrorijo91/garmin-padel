import Toybox.Lang;
import Toybox.Test;

// MiniSetEngine: starts 2-2, first to 6 games, tie-break at 5-5

(:test)
function miniSetEngine_startsAt22(logger as Logger) as Boolean {
    var gameEngine = new GoldenPointGameEngine();
    var setEngine = new MiniSetEngine(gameEngine);
    var hist = [];
    var status = new MatchStatus(0, 0, 0, 0, 0, 0, 0, 0, hist);
    status.setP1Games(2);
    status.setP2Games(2);
    return setEngine.getInitialP1Games() == 2 && setEngine.getInitialP2Games() == 2;
}

(:test)
function miniSetEngine_fourGamesFrom22Wins62(logger as Logger) as Boolean {
    var gameEngine = new GoldenPointGameEngine();
    var setEngine = new MiniSetEngine(gameEngine);
    var hist = [];
    var status = new MatchStatus(0, 0, 2, 2, 0, 0, 0, 0, hist);
    playNGames(setEngine, Sides.SIDE_P1, status, 4);
    return status.getP1Sets() == 1 && status.getP1Games() == 6 && status.getP2Games() == 2;
}

(:test)
function miniSetEngine_32DoesNotWinSet(logger as Logger) as Boolean {
    var gameEngine = new GoldenPointGameEngine();
    var setEngine = new MiniSetEngine(gameEngine);
    var hist = [];
    var status = new MatchStatus(0, 0, 2, 2, 0, 0, 0, 0, hist);
    playOneGame(setEngine, Sides.SIDE_P1, status);
    playOneGame(setEngine, Sides.SIDE_P2, status);
    return status.getP1Sets() == 0 && status.getP2Sets() == 0 && status.getP1Games() == 3 && status.getP2Games() == 3;
}

(:test)
function miniSetEngine_54DoesNotWinSet(logger as Logger) as Boolean {
    var gameEngine = new GoldenPointGameEngine();
    var setEngine = new MiniSetEngine(gameEngine);
    var hist = [];
    var status = new MatchStatus(0, 0, 2, 2, 0, 0, 0, 0, hist);
    playNGames(setEngine, Sides.SIDE_P1, status, 3);
    playNGames(setEngine, Sides.SIDE_P2, status, 2);
    return status.getP1Sets() == 0 && status.getP2Sets() == 0 && status.getP1Games() == 5 && status.getP2Games() == 4;
}

(:test)
function miniSetEngine_tieBreakAt55(logger as Logger) as Boolean {
    var gameEngine = new GoldenPointGameEngine();
    var setEngine = new MiniSetEngine(gameEngine);
    var hist = [];
    var status = new MatchStatus(0, 0, 2, 2, 0, 0, 0, 0, hist);
    playMiniSetTo5All(setEngine, status);
    var inTie = setEngine.isInTieBreak(status);
    return inTie && status.getP1Games() == 5 && status.getP2Games() == 5;
}

(:test)
function miniSetEngine_tieBreakP2Wins75(logger as Logger) as Boolean {
    var gameEngine = new GoldenPointGameEngine();
    var setEngine = new MiniSetEngine(gameEngine);
    var hist = [];
    var status = new MatchStatus(0, 0, 2, 2, 0, 0, 0, 0, hist);
    playMiniSetTo5All(setEngine, status);
    playTieBreakPoints(setEngine, status, 5, 7);
    return status.getP2Sets() == 1 && status.getP1TieScore() == 5 && status.getP2TieScore() == 7;
}

