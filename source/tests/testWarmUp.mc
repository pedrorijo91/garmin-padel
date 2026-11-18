import Toybox.Application;
import Toybox.Lang;
import Toybox.Test;

// Warm-up phase: the session starts with a warm-up lap; the first press ends it without scoring.

function warmUpMatch(config as MatchConfig) as PadelMatch {
    config.setWarmUp(true);
    return new PadelMatch(config);
}

(:test)
function warmUpOffByDefaultTest(logger as Logger) as Boolean {
    // existing tests and "Warm-up: No" start straight in the match phase, as before
    var match = new PadelMatch(getConfig());
    var status = match.getMatchStatus();
    var ok = !match.isWarmingUp() && status.getSetFormat() == MatchConfig.FORMAT_DEFAULT;
    match.incP1();
    return ok && match.getMatchStatus().getP1Score() == 15;
}

(:test)
function warmUpStartsInWarmUpTest(logger as Logger) as Boolean {
    var match = warmUpMatch(getConfig());
    return match.isWarmingUp() && match.getMatchStatus().getSetFormat() == MatchConfig.FORMAT_FREE;
}

(:test)
function warmUpFirstPressEndsWithoutScoringTest(logger as Logger) as Boolean {
    var match = warmUpMatch(getConfig());
    var lapsBefore = Application.getApp().getLapCount();
    var over = match.incP1();
    var status = match.getMatchStatus();
    var laps = Application.getApp().getLapCount() - lapsBefore;
    if (over || match.isWarmingUp() || laps != 1) {
        logger.error("over=" + over + " warmingUp=" + match.isWarmingUp() + " laps=" + laps);
        return false;
    }
    if (status.getP1Score() != 0 || status.getP2Score() != 0 || status.getP1Games() != 0 || status.getGamesPlayed() != 0) {
        logger.error("scored during warm-up: " + printMatchStatus(status));
        return false;
    }
    // the next press scores as usual
    match.incP1();
    return match.getMatchStatus().getP1Score() == 15 && match.getMatchStatus().getP2Score() == 0;
}

(:test)
function warmUpDownPressEndsWithoutScoringTest(logger as Logger) as Boolean {
    var match = warmUpMatch(getConfig());
    match.incP2();
    var ok = !match.isWarmingUp() && match.getMatchStatus().getP2Score() == 0;
    match.incP2();
    return ok && match.getMatchStatus().getP2Score() == 15;
}

(:test)
function warmUpEndViaOptionsTest(logger as Logger) as Boolean {
    var match = warmUpMatch(getConfig());
    var lapsBefore = Application.getApp().getLapCount();
    match.endWarmUp();
    // ending it again (already in the match phase) does nothing: no second lap
    match.endWarmUp();
    var laps = Application.getApp().getLapCount() - lapsBefore;
    match.incP1();
    return laps == 1 && match.getMatchStatus().getP1Score() == 15;
}

(:test)
function warmUpUndoDoesNotGoBackTest(logger as Logger) as Boolean {
    var match = warmUpMatch(getConfig());
    // a switch during the warm-up pushes an undo entry; ending the warm-up must drop it
    match.setFirstServer(Sides.SIDE_P1);
    match.switchServer();
    match.incP1();
    match.undo();
    var ok = !match.isWarmingUp();
    // the switch made during the warm-up is kept
    ok = ok && match.getServingSide() == Sides.SIDE_P2;
    // undo of a real point goes back to 0-0 in the match phase, never into the warm-up
    match.incP1();
    match.undo();
    match.undo();
    var status = match.getMatchStatus();
    return ok && !match.isWarmingUp() && status.getP1Score() == 0 && status.getSetFormat() == MatchConfig.FORMAT_DEFAULT;
}

(:test)
function warmUpServingTest(logger as Logger) as Boolean {
    // the first server is kept through the warm-up (ScoreView doesn't draw it until the match starts)
    var match = warmUpMatch(getConfig());
    match.setFirstServer(Sides.SIDE_P2);
    var ok = expectServing(logger, match, Sides.SIDE_P2, "during warm-up");
    // Switch server during the warm-up flips it, as in the match
    match.switchServer();
    ok = ok && expectServing(logger, match, Sides.SIDE_P1, "after switch during warm-up");
    match.incP2();
    ok = ok && expectServing(logger, match, Sides.SIDE_P1, "first game after warm-up");
    // the warm-up press is not a game: the serve changes after the first real game
    playPointsP1(match, 4);
    return ok && expectServing(logger, match, Sides.SIDE_P2, "second game");
}

(:test)
function warmUpMiniSetInitialGamesTest(logger as Logger) as Boolean {
    var config = getConfig();
    config.setSetType(MatchConfig.SET_TYPE_MINI);
    var match = warmUpMatch(config);
    match.incP2();
    var status = match.getMatchStatus();
    // mini set still starts 2-2 once the match phase starts, and 4 points make it 3-2
    var ok = status.getP1Games() == 2 && status.getP2Games() == 2;
    playPointsP1(match, 4);
    status = match.getMatchStatus();
    return ok && status.getP1Games() == 3 && status.getP2Games() == 2;
}

(:test)
function warmUpFullMatchLapsTest(logger as Logger) as Boolean {
    // warm-up + 6-4 6-3: lap 1 warm-up, then one lap per set; the score is unchanged
    var match = warmUpMatch(getConfig());
    var lapsBefore = Application.getApp().getLapCount();
    match.incP1();
    for (var g = 0; g < 4; g++) {
        playPointsP1(match, 4);
        playPointsP2(match, 4);
    }
    playPointsP1(match, 8);
    for (var g = 0; g < 3; g++) {
        playPointsP1(match, 4);
        playPointsP2(match, 4);
    }
    // 3-3 -> 6-3: 11 points, then the match point
    playPointsP1(match, 11);
    var over = match.incP1();
    var laps = Application.getApp().getLapCount() - lapsBefore;
    var history = match.getHistoricalScores();
    if (!over || laps != 3 || history.size() != 2 || !history[0].equals("6-4") || !history[1].equals("6-3")) {
        logger.error("over=" + over + " laps=" + laps + " history=" + history);
        return false;
    }
    return true;
}
