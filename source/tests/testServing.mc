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
function servingCarriesAcrossSetTest(logger as Logger) as Boolean {
    // 6-3 = 9 games: the alternation carries on, so the next set starts with the other team
    var match = servingMatch(Sides.SIDE_P1);
    playAlternatingGames(match, 6);
    playPointsP1(match, 12);
    return match.getMatchStatus().getP1Sets() == 1
        && expectServing(logger, match, Sides.SIDE_P2, "set 2 game 1 after 6-3");
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
function servingSuperTieTest(logger as Logger) as Boolean {
    // sets 6-1, 0-6: 13 games played, so the deciding super tie starts with P2
    var match = servingMatch(Sides.SIDE_P1);
    playPointsP2(match, 4);
    playPointsP1(match, 24);
    playPointsP2(match, 24);
    var ok = match.isInSuperTieBreak();
    var expected = [Sides.SIDE_P2, Sides.SIDE_P1, Sides.SIDE_P1, Sides.SIDE_P2];
    for (var i = 0; i < expected.size(); i++) {
        ok = ok && expectServing(logger, match, expected[i], "super tie point " + (i + 1));
        if (i % 2 == 0) {
            match.incP1();
        } else {
            match.incP2();
        }
    }
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
    // undo across a set won by a tie-break, back into the tie-break rotation
    var match = servingMatch(Sides.SIDE_P1);
    playSetTo6All(match);
    playTieBreak(match, 7, 0);
    var ok = expectServing(logger, match, Sides.SIDE_P2, "after tie-break set");
    match.undo();
    // tie-break at 6-0: turn (6+1)/2 = 3 -> P2
    ok = ok && match.isInTieBreak() && expectServing(logger, match, Sides.SIDE_P2, "undo set: tie-break 6-0");
    match.undo();
    match.undo();
    // tie-break at 4-0: turn 2 -> P1
    ok = ok && expectServing(logger, match, Sides.SIDE_P1, "undo: tie-break 4-0");
    playPointsP1(match, 3);
    return ok && expectServing(logger, match, Sides.SIDE_P2, "replayed tie-break set");
}

(:test)
function servingUnknownTest(logger as Logger) as Boolean {
    // "Skip": nothing to show, through games and tie-breaks
    var match = new PadelMatch(getConfig());
    var ok = expectServing(logger, match, -1, "default");
    playSetTo6All(match);
    return ok && expectServing(logger, match, -1, "tie-break");
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
    // the switch itself is undoable
    for (var i = 0; i < 5; i++) {
        match.undo();
    }
    ok = ok && expectServing(logger, match, Sides.SIDE_P2, "undo switch");

    // switching when the server was unknown turns the indicator on with us serving
    var match2 = new PadelMatch(getConfig());
    playPointsP2(match2, 4);
    match2.switchServer();
    ok = ok && expectServing(logger, match2, Sides.SIDE_P1, "switch from unknown");
    playPointsP2(match2, 4);
    return ok && expectServing(logger, match2, Sides.SIDE_P2, "game after switch from unknown");
}
