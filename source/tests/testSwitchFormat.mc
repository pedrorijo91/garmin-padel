import Toybox.Application;
import Toybox.Lang;
import Toybox.Test;

// Switching the set format mid-match (Options -> Switch to): tie-break, super tie-break, mini set.

// Friendly preset: unlimited normal sets, golden point, format switch allowed.
function friendlyMatch() as PadelMatch {
    return new PadelMatch(GameModes.configForMode(GameModes.MODE_FRIENDLY) as MatchConfig);
}

function expectHistory(logger as Logger, match as PadelMatch, expected as Array<String>, what as String) as Boolean {
    var actual = match.getHistoricalScores();
    var ok = actual.size() == expected.size();
    for (var i = 0; ok && i < expected.size(); i++) {
        ok = actual[i].equals(expected[i]);
    }
    if (!ok) {
        logger.error(what + ": expected history " + expected + " got " + actual);
    }
    return ok;
}

function expectTrue(logger as Logger, condition as Boolean, what as String) as Boolean {
    if (!condition) {
        logger.error(what);
    }
    return condition;
}

// Win the current game-based set 6-3 for P1 (9 games, never 6-x before the end).
function playSet63(match as PadelMatch) as Void {
    playAlternatingGames(match, 6);
    playPointsP1(match, 12);
}

(:test)
function switchSuperTieAfterSetTest(logger as Logger) as Boolean {
    var match = friendlyMatch();
    playSet63(match);
    var ok = expectTrue(logger, !match.isSetStarted(), "new set not started");
    match.switchSetFormat(MatchConfig.FORMAT_SUPER_TIE);
    // set not started: nothing recorded, the current set just becomes a super tie
    ok = ok && expectHistory(logger, match, ["6-3"], "after switch at 0-0");
    ok = ok && expectTrue(logger, match.isInSuperTieBreak() && !match.currentSetHasGames(), "in super tie");
    playPointsP2(match, 8);
    ok = ok && expectHistory(logger, match, ["6-3", "[0-8]"], "super tie in progress");
    playPointsP1(match, 9);
    var over = match.incP1();
    var status = match.getMatchStatus();
    ok = ok && expectTrue(logger, !over, "unlimited match not over");
    ok = ok && expectHistory(logger, match, ["6-3", "[10-8]"], "super tie won");
    ok = ok && expectTrue(logger, status.getP1Sets() == 2 && status.getP2Sets() == 0, "sets 2-0");
    // the next set goes back to the default (normal) format, with tie scores reset
    ok = ok && expectTrue(logger, status.getSetFormat() == MatchConfig.FORMAT_DEFAULT, "format back to default");
    ok = ok && expectTrue(logger, match.currentSetHasGames() && !match.isInSuperTieBreak(), "normal set again");
    ok = ok && expectTrue(logger, status.getP1TieScore() == 0 && status.getP2TieScore() == 0, "tie scores reset");
    playPointsP1(match, 4);
    status = match.getMatchStatus();
    return ok && expectTrue(logger, status.getP1Games() == 1 && status.getP2Games() == 0, "normal game counted");
}

(:test)
function switchTieBreakWinByTwoTest(logger as Logger) as Boolean {
    var match = friendlyMatch();
    match.switchSetFormat(MatchConfig.FORMAT_TIE_BREAK);
    var ok = expectTrue(logger, match.isInTieBreak() && !match.isInSuperTieBreak() && !match.currentSetHasGames(), "in tie-break");
    playPointsP1(match, 5);
    playPointsP2(match, 5);
    match.incP1();
    match.incP2();
    match.incP1();
    // 7-6: not won yet (margin 2)
    ok = ok && expectTrue(logger, match.getMatchStatus().getP1Sets() == 0, "7-6 not won");
    match.incP1();
    return ok && expectHistory(logger, match, ["[8-6]"], "tie-break won 8-6")
        && expectTrue(logger, match.getMatchStatus().getP1Sets() == 1, "set to P1");
}

(:test)
function switchMiniSetTest(logger as Logger) as Boolean {
    var match = friendlyMatch();
    playPointsP1(match, 24);
    match.switchSetFormat(MatchConfig.FORMAT_MINI);
    var status = match.getMatchStatus();
    var ok = expectTrue(logger, status.getP1Games() == 2 && status.getP2Games() == 2, "mini set starts 2-2");
    ok = ok && expectTrue(logger, !match.isSetStarted(), "2-2 is not started");
    ok = ok && expectHistory(logger, match, ["6-0"], "2-2 not shown in history");
    playPointsP1(match, 16);
    status = match.getMatchStatus();
    ok = ok && expectHistory(logger, match, ["6-0", "6-2"], "mini set won");
    ok = ok && expectTrue(logger, status.getP1Sets() == 2 && status.getP1Games() == 0 && status.getP2Games() == 0, "next set 0-0");

    // mini set match: 2-2 with no points is not started (switching away resets to 0-0); a point starts it
    var config = GameModes.configForMode(GameModes.MODE_FRIENDLY) as MatchConfig;
    config.setSetType(MatchConfig.SET_TYPE_MINI);
    var mini = new PadelMatch(config);
    ok = ok && expectTrue(logger, !mini.isSetStarted(), "mini 2-2 not started");
    mini.switchSetFormat(MatchConfig.FORMAT_SUPER_TIE);
    status = mini.getMatchStatus();
    ok = ok && expectTrue(logger, status.getP1Games() == 0 && status.getP2Games() == 0, "switch away from mini resets 2-2");
    mini.switchSetFormat(MatchConfig.FORMAT_MINI);
    mini.incP2();
    return ok && expectTrue(logger, mini.isSetStarted(), "mini started after a point");
}

(:test)
function switchSuperTieEndsBestOf3Test(logger as Logger) as Boolean {
    var config = getConfig();
    config.setSuperTie(false);
    config.setFormatSwitch(true);
    var match = new PadelMatch(config);
    playSet(match, 6, 0);
    playSet(match, 0, 6);
    match.switchSetFormat(MatchConfig.FORMAT_SUPER_TIE);
    playPointsP1(match, 9);
    var over = match.incP1();
    var status = match.getMatchStatus();
    return expectTrue(logger, over && status.getP1Sets() == 2 && status.getP2Sets() == 1, "match over 2-1")
        && expectHistory(logger, match, ["6-0", "0-6", "[10-0]"], "best of 3 with chosen super tie");
}

(:test)
function switchMidSetDropsSetTest(logger as Logger) as Boolean {
    var match = friendlyMatch();
    match.setFirstServer(Sides.SIDE_P1);
    playAlternatingGames(match, 7);
    match.incP1(); // 4-3, 15-0
    var ok = expectTrue(logger, match.isSetStarted(), "set started");
    ok = ok && expectTrue(logger, match.currentSetResult().equals("4-3"), "current set result " + match.currentSetResult());
    match.switchSetFormat(MatchConfig.FORMAT_SUPER_TIE);
    var status = match.getMatchStatus();
    ok = ok && expectHistory(logger, match, [], "dropped set not recorded");
    // awarded to nobody, games and points reset; the game in progress doesn't count
    ok = ok && expectTrue(logger, status.getP1Sets() == 0 && status.getP2Sets() == 0, "no set awarded");
    ok = ok && expectTrue(logger, status.getP1Games() == 0 && status.getP2Games() == 0, "games reset");
    ok = ok && expectTrue(logger, status.getP1Score() == 0 && status.getP2Score() == 0, "points reset");
    ok = ok && expectTrue(logger, match.isInSuperTieBreak(), "in super tie");
    // switching again from the chosen super tie: dropped too
    playPointsP1(match, 5);
    playPointsP2(match, 3);
    ok = ok && expectHistory(logger, match, ["[5-3]"], "super tie in progress");
    match.switchSetFormat(MatchConfig.FORMAT_TIE_BREAK);
    ok = ok && expectHistory(logger, match, [], "dropped super tie not recorded");
    ok = ok && expectTrue(logger, match.isInTieBreak() && match.getMatchStatus().getP1TieScore() == 0, "fresh tie-break");
    playPointsP1(match, 7);
    status = match.getMatchStatus();
    ok = ok && expectHistory(logger, match, ["[7-0]"], "tie-break won");
    return ok && expectTrue(logger, status.getP1Sets() == 1 && status.getP2Sets() == 0, "only the finished tie-break counts");
}

(:test)
function switchUndoTest(logger as Logger) as Boolean {
    var match = friendlyMatch();
    match.setFirstServer(Sides.SIDE_P2);
    playAlternatingGames(match, 7);
    match.incP1();
    var servingBefore = match.getServingSide();
    match.switchSetFormat(MatchConfig.FORMAT_SUPER_TIE);
    match.undo();
    // undo restores the dropped set exactly
    var status = match.getMatchStatus();
    var ok = expectTrue(logger, status.getP1Games() == 4 && status.getP2Games() == 3 && status.getP1Score() == 15, "4-3 15-0 restored");
    ok = ok && expectHistory(logger, match, ["4-3"], "set back in progress after undo");
    ok = ok && expectTrue(logger, status.getSetFormat() == MatchConfig.FORMAT_DEFAULT && match.currentSetHasGames(), "format restored");
    ok = ok && expectTrue(logger, status.getGamesPlayed() == 7 && match.getServingSide() == servingBefore, "serving restored");

    // switch at 0-0, then undo -> the switch is gone
    var match2 = friendlyMatch();
    match2.switchSetFormat(MatchConfig.FORMAT_TIE_BREAK);
    match2.undo();
    ok = ok && expectTrue(logger, match2.currentSetHasGames(), "undo right after choosing reverts it");
    // switch, play a point, undo the point -> still the chosen format
    match2.switchSetFormat(MatchConfig.FORMAT_TIE_BREAK);
    match2.incP1();
    match2.undo();
    ok = ok && expectTrue(logger, match2.isInTieBreak() && !match2.currentSetHasGames(), "undo first point keeps format");

    // undo across the end of a chosen super tie restores its points and format
    var match3 = friendlyMatch();
    match3.switchSetFormat(MatchConfig.FORMAT_SUPER_TIE);
    playPointsP2(match3, 8);
    playPointsP1(match3, 10);
    match3.undo();
    status = match3.getMatchStatus();
    ok = ok && expectTrue(logger, match3.isInSuperTieBreak() && status.getP1TieScore() == 9 && status.getP2TieScore() == 8, "super tie 9-8 restored");
    return ok && expectTrue(logger, status.getP1Sets() == 0 && status.getSetFormat() == MatchConfig.FORMAT_SUPER_TIE, "set and format restored");
}

(:test)
function switchAbandonedSetCountsForNobodyTest(logger as Logger) as Boolean {
    // Custom best of 3 with super tie: an abandoned set doesn't count, so the match goes on
    var config = getConfig();
    config.setFormatSwitch(true);
    var match = new PadelMatch(config);
    playSet(match, 6, 0);
    playAlternatingGames(match, 2);
    match.switchSetFormat(MatchConfig.FORMAT_TIE_BREAK);
    playPointsP2(match, 7);
    var status = match.getMatchStatus();
    var ok = expectTrue(logger, status.getP1Sets() == 1 && status.getP2Sets() == 1, "sets 1-1");
    ok = ok && expectHistory(logger, match, ["6-0", "[0-7]"], "abandoned set not recorded");
    // 1-1 with one set left: back to the default, which is the deciding super tie
    ok = ok && expectTrue(logger, match.isInSuperTieBreak(), "deciding super tie");
    playPointsP1(match, 9);
    var over = match.incP1();
    return ok && expectTrue(logger, over, "match over")
        && expectHistory(logger, match, ["6-0", "[0-7]", "[10-0]"], "final history");
}

(:test)
function switchAfterMatchOverTest(logger as Logger) as Boolean {
    var config = getConfig();
    config.setNumberOfSets(1);
    config.setSuperTie(false);
    config.setFormatSwitch(true);
    var match = new PadelMatch(config);
    playSet(match, 6, 0);
    match.switchSetFormat(MatchConfig.FORMAT_SUPER_TIE);
    match.incP1();
    return expectHistory(logger, match, ["6-0"], "no switch after match over")
        && expectTrue(logger, match.getMatchStatus().getSetFormat() == MatchConfig.FORMAT_DEFAULT, "format unchanged");
}

(:test)
function switchServingTieBreakTest(logger as Logger) as Boolean {
    var match = friendlyMatch();
    match.setFirstServer(Sides.SIDE_P1);
    playAlternatingGames(match, 3);
    // 2-1, P2 serving game 4; abandon it at 30-0
    playPointsP1(match, 2);
    var ok = expectServing(logger, match, Sides.SIDE_P2, "game 4");
    match.switchSetFormat(MatchConfig.FORMAT_TIE_BREAK);
    // the abandoned game doesn't count: P2 still due, serves point 1, then every 2 points
    var expected = [Sides.SIDE_P2, Sides.SIDE_P1, Sides.SIDE_P1, Sides.SIDE_P2, Sides.SIDE_P2];
    for (var i = 0; i < expected.size(); i++) {
        ok = ok && expectServing(logger, match, expected[i], "tie-break point " + (i + 1));
        if (i % 2 == 0) {
            match.incP1();
        } else {
            match.incP2();
        }
    }
    // 3-2, P1 wins 7-2: the tie-break counts as one game -> 4 played, so P1 serves the next set
    playPointsP1(match, 4);
    var status = match.getMatchStatus();
    ok = ok && expectTrue(logger, status.getP1Sets() == 1 && status.getGamesPlayed() == 4, "games played " + status.getGamesPlayed());
    return ok && expectServing(logger, match, Sides.SIDE_P1, "next set game 1");
}

(:test)
function switchServingMiniTest(logger as Logger) as Boolean {
    var match = friendlyMatch();
    match.setFirstServer(Sides.SIDE_P1);
    playSet63(match);
    // 9 games played: P2 due. Switching to a mini set at 0-0 (games become 2-2) doesn't change it
    match.switchSetFormat(MatchConfig.FORMAT_MINI);
    var ok = expectServing(logger, match, Sides.SIDE_P2, "mini set game 1");
    return ok && expectTrue(logger, match.getMatchStatus().getGamesPlayed() == 9, "2-2 not counted");
}

(:test)
function switchAllowedOnlyInFriendlyAndCustomTest(logger as Logger) as Boolean {
    var friendly = GameModes.configForMode(GameModes.MODE_FRIENDLY) as MatchConfig;
    var t = GameModes.configForMode(GameModes.MODE_TOURNAMENT) as MatchConfig;
    var ts = GameModes.configForMode(GameModes.MODE_TOURNAMENT_SUPER) as MatchConfig;
    var pro = GameModes.configForMode(GameModes.MODE_PRO_SET_TOURNAMENT) as MatchConfig;
    // the Custom flow sets it in MenuNumberSetsDelegate; a fresh config has it off
    return expectTrue(logger, friendly.getFormatSwitch() && new PadelMatch(friendly).canSwitchSetFormat(), "friendly allows")
        && expectTrue(logger, !t.getFormatSwitch() && !ts.getFormatSwitch() && !pro.getFormatSwitch(), "tournaments don't")
        && expectTrue(logger, !new PadelMatch(t).canSwitchSetFormat(), "tournament match doesn't")
        && expectTrue(logger, !(new MatchConfig()).getFormatSwitch(), "off by default");
}

(:test)
function switchWithWarmUpTest(logger as Logger) as Boolean {
    // warm-up lap first, then a mid-set switch adds one more lap; a switch with nothing played adds none
    var config = GameModes.configForMode(GameModes.MODE_FRIENDLY) as MatchConfig;
    var match = warmUpMatch(config);
    var app = Application.getApp();
    var laps0 = app.getLapCount();
    match.incP1(); // ends the warm-up, no point scored
    var ok = expectTrue(logger, !match.isWarmingUp() && app.getLapCount() - laps0 == 1, "warm-up lap");
    ok = ok && expectTrue(logger, !match.isSetStarted(), "nothing played after the warm-up");
    match.switchSetFormat(MatchConfig.FORMAT_TIE_BREAK);
    ok = ok && expectTrue(logger, app.getLapCount() - laps0 == 1, "switch at 0-0 adds no lap");
    match.switchSetFormat(MatchConfig.FORMAT_DEFAULT);
    playAlternatingGames(match, 7);
    match.incP1();
    match.switchSetFormat(MatchConfig.FORMAT_SUPER_TIE);
    ok = ok && expectTrue(logger, app.getLapCount() - laps0 == 2, "mid-set switch adds a lap");
    ok = ok && expectTrue(logger, !match.isWarmingUp() && match.isInSuperTieBreak(), "super tie, not back in warm-up");
    // undo goes back to 4-3 but never into the warm-up
    match.undo();
    var status = match.getMatchStatus();
    return ok && expectTrue(logger, !match.isWarmingUp() && status.getP1Games() == 4 && status.getP2Games() == 3, "undo to 4-3");
}
