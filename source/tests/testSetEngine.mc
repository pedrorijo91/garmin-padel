import Toybox.Lang;
import Toybox.Test;

// Play one full game (4 points) for the given side with NormalSetEngine (golden point).
function playOneGame(engine as NormalSetEngine, side as Number, status as MatchStatus) as Void {
    for (var i = 0; i < 4; i++) {
        engine.scorePoint(side, status);
    }
}

// Play one game with advantage rules: 40-40 then P1 advantage then P1 wins (5 points P1, 3 P2).
function playOneGameP1WinsWithAdvantage(engine as NormalSetEngine, status as MatchStatus) as Void {
    engine.scorePoint(SetEngine.SIDE_P1, status);
    engine.scorePoint(SetEngine.SIDE_P1, status);
    engine.scorePoint(SetEngine.SIDE_P1, status);
    engine.scorePoint(SetEngine.SIDE_P2, status);
    engine.scorePoint(SetEngine.SIDE_P2, status);
    engine.scorePoint(SetEngine.SIDE_P2, status);
    engine.scorePoint(SetEngine.SIDE_P1, status);
    engine.scorePoint(SetEngine.SIDE_P1, status);
}

// Play one game with advantage rules: 40-40, P1 advantage, P2 back to deuce, P2 advantage, P2 wins (4 P1, 6 P2).
function playOneGameP2WinsWithAdvantage(engine as NormalSetEngine, status as MatchStatus) as Void {
    engine.scorePoint(SetEngine.SIDE_P1, status);
    engine.scorePoint(SetEngine.SIDE_P1, status);
    engine.scorePoint(SetEngine.SIDE_P1, status);
    engine.scorePoint(SetEngine.SIDE_P2, status);
    engine.scorePoint(SetEngine.SIDE_P2, status);
    engine.scorePoint(SetEngine.SIDE_P2, status);
    engine.scorePoint(SetEngine.SIDE_P1, status);
    engine.scorePoint(SetEngine.SIDE_P2, status);
    engine.scorePoint(SetEngine.SIDE_P2, status);
    engine.scorePoint(SetEngine.SIDE_P2, status);
}

(:test)
function normalSetEngine_sixGamesWinsSet(logger as Logger) as Boolean {
    var gameEngine = new GoldenPointGameEngine();
    var setEngine = new NormalSetEngine(gameEngine);
    var hist = [];
    var status = new MatchStatus(0, 0, 0, 0, 0, 0, 0, 0, hist);
    var setWon = false;
    for (var g = 0; g < 6; g++) {
        for (var p = 0; p < 4; p++) {
            setWon = setEngine.scorePoint(SetEngine.SIDE_P1, status);
            if (setWon) {
                break;
            }
        }
        if (setWon) {
            break;
        }
    }
    return setWon && status.getP1Sets() == 1 && status.getP1Games() == 6 && status.getP2Games() == 0;
}

(:test)
function normalSetEngine_tieBreakAt66(logger as Logger) as Boolean {
    var gameEngine = new GoldenPointGameEngine();
    var setEngine = new NormalSetEngine(gameEngine);
    var hist = [];
    var status = new MatchStatus(0, 0, 0, 0, 0, 0, 0, 0, hist);
    for (var g = 0; g < 6; g++) {
        playOneGame(setEngine, SetEngine.SIDE_P1, status);
        playOneGame(setEngine, SetEngine.SIDE_P2, status);
    }
    var inTie = setEngine.isInTieBreak(status);
    return inTie && status.getP1Games() == 6 && status.getP2Games() == 6;
}

(:test)
function normalSetEngine_tieBreak_76DoesNotWin(logger as Logger) as Boolean {
    var gameEngine = new GoldenPointGameEngine();
    var setEngine = new NormalSetEngine(gameEngine);
    var hist = [];
    var status = new MatchStatus(0, 0, 0, 0, 0, 0, 0, 0, hist);
    for (var g = 0; g < 6; g++) {
        playOneGame(setEngine, SetEngine.SIDE_P1, status);
        playOneGame(setEngine, SetEngine.SIDE_P2, status);
    }
    for (var i = 0; i < 6; i++) {
        setEngine.scorePoint(SetEngine.SIDE_P1, status);
        setEngine.scorePoint(SetEngine.SIDE_P2, status);
    }
    setEngine.scorePoint(SetEngine.SIDE_P1, status);
    var setWonAt76 = status.getP1Sets() == 0 && status.getP2Sets() == 0 && status.getP1TieScore() == 7 && status.getP2TieScore() == 6;
    if (!setWonAt76) {
        return false;
    }
    setEngine.scorePoint(SetEngine.SIDE_P1, status);
    return status.getP1Sets() == 1 && status.getP1TieScore() == 8 && status.getP2TieScore() == 6;
}

(:test)
function normalSetEngine_tieBreakP1Wins75(logger as Logger) as Boolean {
    var gameEngine = new GoldenPointGameEngine();
    var setEngine = new NormalSetEngine(gameEngine);
    var hist = [];
    var status = new MatchStatus(0, 0, 0, 0, 0, 0, 0, 0, hist);
    for (var g = 0; g < 6; g++) {
        playOneGame(setEngine, SetEngine.SIDE_P1, status);
        playOneGame(setEngine, SetEngine.SIDE_P2, status);
    }
    var setWon = false;
    for (var i = 0; i < 7; i++) {
        setWon = setEngine.scorePoint(SetEngine.SIDE_P1, status);
        if (setWon) {
            break;
        }
        if (i < 5) {
            setEngine.scorePoint(SetEngine.SIDE_P2, status);
        }
    }
    return setWon && status.getP1Sets() == 1 && status.getP1TieScore() == 7 && status.getP2TieScore() == 5;
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
    for (var i = 0; i < 8; i++) {
        setEngine.scorePoint(SetEngine.SIDE_P2, status);
    }
    var setWon = false;
    for (var i = 0; i < 10; i++) {
        setWon = setEngine.scorePoint(SetEngine.SIDE_P1, status);
        if (setWon) {
            break;
        }
    }
    return setWon && status.getP1Sets() == 1 && status.getP1TieScore() == 10 && status.getP2TieScore() == 8;
}

(:test)
function superTieSetEngine_109DoesNotWin(logger as Logger) as Boolean {
    var setEngine = new SuperTieSetEngine();
    var hist = [];
    var status = new MatchStatus(0, 0, 0, 0, 0, 0, 0, 0, hist);
    for (var i = 0; i < 9; i++) {
        setEngine.scorePoint(SetEngine.SIDE_P2, status);
    }
    for (var i = 0; i < 10; i++) {
        setEngine.scorePoint(SetEngine.SIDE_P1, status);
    }
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
    for (var g = 0; g < 4; g++) {
        playOneGame(setEngine, SetEngine.SIDE_P1, status);
    }
    for (var g = 0; g < 4; g++) {
        playOneGame(setEngine, SetEngine.SIDE_P2, status);
    }
    playOneGame(setEngine, SetEngine.SIDE_P1, status);
    return status.getP1Games() == 6 && status.getP2Games() == 4 && status.getP1Sets() == 1 && status.getP2Sets() == 0;
}
