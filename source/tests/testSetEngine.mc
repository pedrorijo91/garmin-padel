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

// --- ProSetEngine: first to 9 games, tie-break at 8-8 ---

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

// --- MiniSetEngine: starts 2-2, first to 6 games, tie-break at 5-5 ---

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

// --- Normal set margin: 6-3 wins without tie-break ---

(:test)
function normalSetEngine_63WinsSet(logger as Logger) as Boolean {
    var gameEngine = new GoldenPointGameEngine();
    var setEngine = new NormalSetEngine(gameEngine);
    var hist = [];
    var status = new MatchStatus(0, 0, 0, 0, 0, 0, 0, 0, hist);
    playNGames(setEngine, Sides.SIDE_P1, status, 5);
    playNGames(setEngine, Sides.SIDE_P2, status, 3);
    playOneGame(setEngine, Sides.SIDE_P1, status);
    return status.getP1Sets() == 1 && status.getP1Games() == 6 && status.getP2Games() == 3;
}

// --- Initial games: Normal and SuperTie return 0-0 ---

(:test)
function normalSetEngine_initialGamesZero(logger as Logger) as Boolean {
    var setEngine = new NormalSetEngine(new GoldenPointGameEngine());
    return setEngine.getInitialP1Games() == 0 && setEngine.getInitialP2Games() == 0;
}

(:test)
function superTieSetEngine_initialGamesZero(logger as Logger) as Boolean {
    var setEngine = new SuperTieSetEngine();
    return setEngine.getInitialP1Games() == 0 && setEngine.getInitialP2Games() == 0;
}
