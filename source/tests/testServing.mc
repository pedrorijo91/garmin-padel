import Toybox.Lang;
import Toybox.Test;

// Serving indicator (team level): which team serves, following padel rules.

function servingMatch(firstServer as Number) as PadelMatch {
    var match = new PadelMatch(getConfig());
    match.setFirstServer(firstServer);
    return match;
}

// Play `n` games alternating winners (P1, P2, P1, ...), so a set is never won by it if n <= 10.
function playAlternatingGames(match as PadelMatch, n as Number) as Void {
    for (var g = 0; g < n; g++) {
        if (g % 2 == 0) {
            playPointsP1(match, 4);
        } else {
            playPointsP2(match, 4);
        }
    }
}

function expectServing(logger as Logger, match as PadelMatch, expected as Number, what as String) as Boolean {
    var actual = match.getServingSide();
    if (actual != expected) {
        logger.error(what + ": expected " + expected + " got " + actual + " (" + printMatchStatus(match.getMatchStatus()) + ")");
        return false;
    }
    return true;
}

(:test)
function servingAlternatesEveryGameTest(logger as Logger) as Boolean {
    var match = servingMatch(Sides.SIDE_P1);
    var ok = expectServing(logger, match, Sides.SIDE_P1, "game 1");
    // the serve does not change inside a game
    playPointsP2(match, 3);
    ok = ok && expectServing(logger, match, Sides.SIDE_P1, "game 1 at 0-40");
    playPointsP2(match, 1);
    ok = ok && expectServing(logger, match, Sides.SIDE_P2, "game 2");
    playPointsP2(match, 4);
    ok = ok && expectServing(logger, match, Sides.SIDE_P1, "game 3");
    playPointsP1(match, 4);
    ok = ok && expectServing(logger, match, Sides.SIDE_P2, "game 4");
    return ok;
}

(:test)
function servingFirstServerThemTest(logger as Logger) as Boolean {
    var match = servingMatch(Sides.SIDE_P2);
    var ok = expectServing(logger, match, Sides.SIDE_P2, "game 1");
    playPointsP1(match, 4);
    ok = ok && expectServing(logger, match, Sides.SIDE_P1, "game 2");
    return ok;
}

(:test)
function servingCarriesAcrossSetTest(logger as Logger) as Boolean {
    var match = servingMatch(Sides.SIDE_P1);
    // 4-4, then P1 wins two games: 6-4 = 10 games played
    playAlternatingGames(match, 8);
    playPointsP1(match, 8);
    var status = match.getMatchStatus();
    var ok = status.getP1Sets() == 1 && status.getP1Games() == 0;
    ok = ok && expectServing(logger, match, Sides.SIDE_P1, "set 2 game 1 after 6-4");

    // 6-3 = 9 games, so the next set starts with the other team
    var match2 = servingMatch(Sides.SIDE_P1);
    playAlternatingGames(match2, 6);
    playPointsP1(match2, 12);
    ok = ok && match2.getMatchStatus().getP1Sets() == 1;
    ok = ok && expectServing(logger, match2, Sides.SIDE_P2, "set 2 game 1 after 6-3");
    return ok;
}

(:test)
function servingTieBreakRotationTest(logger as Logger) as Boolean {
    var match = servingMatch(Sides.SIDE_P1);
    playSetTo6All(match);
    var ok = match.isInTieBreak();
    // 12 games played, so P1 is due: point 1 P1, points 2-3 P2, points 4-5 P1, points 6-7 P2
    var expected = [Sides.SIDE_P1, Sides.SIDE_P2, Sides.SIDE_P2, Sides.SIDE_P1, Sides.SIDE_P1, Sides.SIDE_P2, Sides.SIDE_P2];
    for (var i = 0; i < expected.size(); i++) {
        ok = ok && expectServing(logger, match, expected[i], "tie-break point " + (i + 1));
        // alternate winners so the tie-break doesn't end
        if (i % 2 == 0) {
            match.incP1();
        } else {
            match.incP2();
        }
    }
    return ok;
}

(:test)
function servingAfterTieBreakSetTest(logger as Logger) as Boolean {
    var match = servingMatch(Sides.SIDE_P1);
    playSetTo6All(match);
    playTieBreak(match, 7, 3);
    var status = match.getMatchStatus();
    var ok = status.getP1Sets() == 1 && !match.isInTieBreak();
    // P1 served first in the tie-break, so P2 serves first in the next set
    ok = ok && expectServing(logger, match, Sides.SIDE_P2, "set 2 game 1 after tie-break");
    playPointsP1(match, 4);
    ok = ok && expectServing(logger, match, Sides.SIDE_P1, "set 2 game 2 after tie-break");
    return ok;
}

(:test)
function servingProSetTieBreakTest(logger as Logger) as Boolean {
    var config = getConfig();
    config.setSetType(MatchConfig.SET_TYPE_PRO);
    var match = new PadelMatch(config);
    match.setFirstServer(Sides.SIDE_P2);
    // 8-8 = 16 games, P2 due
    for (var g = 0; g < 8; g++) {
        playPointsP1(match, 4);
        playPointsP2(match, 4);
    }
    var ok = match.isInTieBreak();
    ok = ok && expectServing(logger, match, Sides.SIDE_P2, "pro set tie-break point 1");
    match.incP1();
    ok = ok && expectServing(logger, match, Sides.SIDE_P1, "pro set tie-break point 2");
    return ok;
}

(:test)
function servingSuperTieTest(logger as Logger) as Boolean {
    // sets 6-1, 0-6: 13 games played, so the deciding super tie starts with P2
    var match = servingMatch(Sides.SIDE_P1);
    playPointsP2(match, 4);
    playPointsP1(match, 24);
    playPointsP2(match, 24);
    var ok = match.isInSuperTieBreak();
    var expected = [Sides.SIDE_P2, Sides.SIDE_P1, Sides.SIDE_P1, Sides.SIDE_P2, Sides.SIDE_P2, Sides.SIDE_P1];
    for (var i = 0; i < expected.size(); i++) {
        ok = ok && expectServing(logger, match, expected[i], "super tie point " + (i + 1));
        if (i % 2 == 0) {
            match.incP1();
        } else {
            match.incP2();
        }
    }

    // sets 6-0, 0-6: 12 games played, so the super tie starts with P1
    var match2 = servingMatch(Sides.SIDE_P1);
    playPointsP1(match2, 24);
    playPointsP2(match2, 24);
    ok = ok && match2.isInSuperTieBreak();
    ok = ok && expectServing(logger, match2, Sides.SIDE_P1, "super tie point 1 after 12 games");
    return ok;
}

(:test)
function servingMiniSetStartsAt22Test(logger as Logger) as Boolean {
    var config = getConfig();
    config.setSetType(MatchConfig.SET_TYPE_MINI);
    var match = new PadelMatch(config);
    match.setFirstServer(Sides.SIDE_P2);
    var status = match.getMatchStatus();
    var ok = status.getP1Games() == 2 && status.getP2Games() == 2;
    // 2-2 on the board, but no games played: the chosen team serves first
    ok = ok && expectServing(logger, match, Sides.SIDE_P2, "mini set game 1");
    playPointsP1(match, 4);
    ok = ok && expectServing(logger, match, Sides.SIDE_P1, "mini set game 2");
    // win the mini set 6-2 (4 games played) -> next set starts with the first server again
    playPointsP1(match, 12);
    status = match.getMatchStatus();
    ok = ok && status.getP1Sets() == 1 && status.getP1Games() == 2;
    ok = ok && expectServing(logger, match, Sides.SIDE_P2, "mini set 2 game 1");
    return ok;
}

(:test)
function servingUndoTest(logger as Logger) as Boolean {
    var match = servingMatch(Sides.SIDE_P1);
    // undo across a game won
    playPointsP1(match, 4);
    var ok = expectServing(logger, match, Sides.SIDE_P2, "after game 1");
    match.undo();
    ok = ok && expectServing(logger, match, Sides.SIDE_P1, "undo game 1");
    match.incP1();
    ok = ok && expectServing(logger, match, Sides.SIDE_P2, "redo game 1");

    // undo across a set won by a tie-break
    var match2 = servingMatch(Sides.SIDE_P1);
    playSetTo6All(match2);
    playTieBreak(match2, 7, 0);
    ok = ok && expectServing(logger, match2, Sides.SIDE_P2, "after tie-break set");
    match2.undo();
    ok = ok && match2.isInTieBreak();
    // tie-break at 6-0: 6 points played, turn (6+1)/2 = 3 -> P2
    ok = ok && expectServing(logger, match2, Sides.SIDE_P2, "undo set: tie-break 6-0");
    match2.undo();
    // tie-break at 5-0: turn 3 -> P2
    ok = ok && expectServing(logger, match2, Sides.SIDE_P2, "undo: tie-break 5-0");
    match2.undo();
    // tie-break at 4-0: turn 2 -> P1
    ok = ok && expectServing(logger, match2, Sides.SIDE_P1, "undo: tie-break 4-0");
    match2.incP1();
    match2.incP1();
    match2.incP1();
    ok = ok && expectServing(logger, match2, Sides.SIDE_P2, "replayed tie-break set");
    ok = ok && match2.getMatchStatus().getGamesPlayed() == 13;
    return ok;
}

(:test)
function servingUnknownTest(logger as Logger) as Boolean {
    var match = new PadelMatch(getConfig());
    var ok = expectServing(logger, match, -1, "default");
    playPointsP1(match, 4);
    ok = ok && expectServing(logger, match, -1, "after a game");
    playSetTo6All(match);
    ok = ok && expectServing(logger, match, -1, "tie-break");

    var match2 = servingMatch(-1);
    ok = ok && expectServing(logger, match2, -1, "skipped");
    return ok;
}

(:test)
function servingSwitchServerTest(logger as Logger) as Boolean {
    var match = servingMatch(Sides.SIDE_P1);
    playPointsP1(match, 4);
    var ok = expectServing(logger, match, Sides.SIDE_P2, "game 2");
    match.switchServer();
    ok = ok && expectServing(logger, match, Sides.SIDE_P1, "game 2 after switch");
    playPointsP1(match, 4);
    ok = ok && expectServing(logger, match, Sides.SIDE_P2, "game 3 after switch");
    // the switch is undoable
    match.undo();
    match.undo();
    match.undo();
    match.undo();
    ok = ok && expectServing(logger, match, Sides.SIDE_P1, "game 2 after undoing game 3");
    match.undo();
    ok = ok && expectServing(logger, match, Sides.SIDE_P2, "undo switch");

    // switching inside a tie-break flips the current point's server
    var match2 = servingMatch(Sides.SIDE_P1);
    playSetTo6All(match2);
    match2.incP1();
    ok = ok && expectServing(logger, match2, Sides.SIDE_P2, "tie-break point 2");
    match2.switchServer();
    ok = ok && expectServing(logger, match2, Sides.SIDE_P1, "tie-break point 2 after switch");
    match2.incP1();
    ok = ok && expectServing(logger, match2, Sides.SIDE_P1, "tie-break point 3 after switch");
    match2.incP1();
    ok = ok && expectServing(logger, match2, Sides.SIDE_P2, "tie-break point 4 after switch");

    // switching when the server was unknown turns the indicator on with us serving
    var match3 = new PadelMatch(getConfig());
    playPointsP2(match3, 4);
    match3.switchServer();
    ok = ok && expectServing(logger, match3, Sides.SIDE_P1, "switch from unknown");
    playPointsP2(match3, 4);
    ok = ok && expectServing(logger, match3, Sides.SIDE_P2, "game after switch from unknown");
    return ok;
}

(:test)
function servingMatchOverTest(logger as Logger) as Boolean {
    var match = servingMatch(Sides.SIDE_P1);
    playPointsP1(match, 48);
    return match.getMatchStatus().getP1Sets() == 2 && expectServing(logger, match, -1, "match over");
}

(:test)
function servingStatusCopyTest(logger as Logger) as Boolean {
    var status = MatchStatus.New();
    var ok = status.getFirstServer() == -1 && status.getGamesPlayed() == 0;
    status.setFirstServer(Sides.SIDE_P2);
    status.incGamesPlayed();
    status.incGamesPlayed();
    var copy = status.copy();
    status.incGamesPlayed();
    status.setFirstServer(Sides.SIDE_P1);
    return ok && copy.getFirstServer() == Sides.SIDE_P2 && copy.getGamesPlayed() == 2;
}
