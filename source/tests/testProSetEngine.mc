import Toybox.Lang;
import Toybox.Test;

// ProSetEngine: first to 9 games, tie-break at 8-8

(:test)
function proSetEngine_nineGamesWinsSet(logger as Logger) as Boolean {
    var gameEngine = new GoldenPointGameEngine();
    var setEngine = new ProSetEngine(gameEngine);
    var hist = [];
    var status = new MatchStatus(0, 0, 0, 0, 0, 0, 0, 0, hist);
    playNGames(setEngine, Sides.SIDE_P1, status, 9);
    return status.getP1Sets() == 1 && status.getP1Games() == 9 && status.getP2Games() == 0;
}

(:test)
function proSetEngine_tieBreakAt88(logger as Logger) as Boolean {
    var gameEngine = new GoldenPointGameEngine();
    var setEngine = new ProSetEngine(gameEngine);
    var hist = [];
    var status = new MatchStatus(0, 0, 0, 0, 0, 0, 0, 0, hist);
    playSetTo8AllForEngine(setEngine, status);
    var inTie = setEngine.isInTieBreak(status);
    return inTie && status.getP1Games() == 8 && status.getP2Games() == 8;
}

(:test)
function proSetEngine_tieBreakP1Wins75(logger as Logger) as Boolean {
    var gameEngine = new GoldenPointGameEngine();
    var setEngine = new ProSetEngine(gameEngine);
    var hist = [];
    var status = new MatchStatus(0, 0, 0, 0, 0, 0, 0, 0, hist);
    playSetTo8AllForEngine(setEngine, status);
    playTieBreakPoints(setEngine, status, 7, 5);
    return status.getP1Sets() == 1 && status.getP1TieScore() == 7 && status.getP2TieScore() == 5;
}

(:test)
function proSetEngine_87DoesNotWinSet(logger as Logger) as Boolean {
    var gameEngine = new GoldenPointGameEngine();
    var setEngine = new ProSetEngine(gameEngine);
    var hist = [];
    var status = new MatchStatus(0, 0, 0, 0, 0, 0, 0, 0, hist);
    playNGames(setEngine, Sides.SIDE_P1, status, 8);
    playNGames(setEngine, Sides.SIDE_P2, status, 7);
    return status.getP1Sets() == 0 && status.getP2Sets() == 0 && status.getP1Games() == 8 && status.getP2Games() == 7;
}

(:test)
function proSetEngine_97WinsSet(logger as Logger) as Boolean {
    var gameEngine = new GoldenPointGameEngine();
    var setEngine = new ProSetEngine(gameEngine);
    var hist = [];
    var status = new MatchStatus(0, 0, 0, 0, 0, 0, 0, 0, hist);
    playNGames(setEngine, Sides.SIDE_P1, status, 8);
    playNGames(setEngine, Sides.SIDE_P2, status, 7);
    playOneGame(setEngine, Sides.SIDE_P1, status);
    return status.getP1Sets() == 1 && status.getP1Games() == 9 && status.getP2Games() == 7;
}

