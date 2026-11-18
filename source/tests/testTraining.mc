import Toybox.Application;
import Toybox.Lang;
import Toybox.Test;

// Training mode: free play, with scored drills started from Options.

function trainingMatch() as PadelMatch {
    return new PadelMatch(GameModes.configForMode(GameModes.MODE_TRAINING) as MatchConfig);
}

function lapsSince(before as Number) as Number {
    return Application.getApp().getLapCount() - before;
}

function lastLap() as String {
    var label = Application.getApp().getLastLapLabel();
    return label == null ? "<none>" : label;
}

(:test)
function trainingPresetTest(logger as Logger) as Boolean {
    var c = GameModes.configForMode(GameModes.MODE_TRAINING) as MatchConfig;
    if (!c.getTraining() || c.getNumberOfSets() != MatchConfig.UNLIMITED_SETS || c.getFormatSwitch()
            || c.getPointRule() != MatchConfig.POINT_RULE_GOLDEN) {
        logger.error(c.toString());
        return false;
    }
    // other presets are not training
    var friendly = GameModes.configForMode(GameModes.MODE_FRIENDLY) as MatchConfig;
    // a warm-up flag left on doesn't add a warm-up: free play already is one
    c.setWarmUp(true);
    var match = new PadelMatch(c);
    return !friendly.getTraining() && match.isTraining() && match.isFreePlay() && !match.isWarmingUp()
        && !match.canSwitchSetFormat();
}

(:test)
function trainingStartsInFreePlayTest(logger as Logger) as Boolean {
    var match = trainingMatch();
    var lapsBefore = Application.getApp().getLapCount();
    var over = match.incP1() || match.incP2();
    var status = match.getMatchStatus();
    if (over || !match.isFreePlay() || match.canUndo() || lapsSince(lapsBefore) != 0) {
        logger.error("over=" + over + " free=" + match.isFreePlay() + " canUndo=" + match.canUndo());
        return false;
    }
    if (status.getP1Score() != 0 || status.getP2Score() != 0 || status.getGamesPlayed() != 0
            || match.getHistoricalScores().size() != 0) {
        logger.error("scored in free play: " + printMatchStatus(status));
        return false;
    }
    // no serving marker in free play, even if one was set
    match.setFirstServer(Sides.SIDE_P1);
    return match.getServingSide() == -1 && match.getScoreString().equals("Drills 0-0");
}

(:test)
function trainingSuperTieDrillTest(logger as Logger) as Boolean {
    var match = trainingMatch();
    var lapsBefore = Application.getApp().getLapCount();
    match.switchSetFormat(MatchConfig.FORMAT_SUPER_TIE);
    if (match.isFreePlay() || !match.isInSuperTieBreak() || lapsSince(lapsBefore) != 1 || !lastLap().equals("Free")) {
        logger.error("start drill: free=" + match.isFreePlay() + " laps=" + lapsSince(lapsBefore) + " label=" + lastLap());
        return false;
    }
    playPointsP2(match, 7);
    playPointsP1(match, 10);
    var status = match.getMatchStatus();
    var history = match.getHistoricalScores();
    if (!match.isFreePlay() || history.size() != 1 || !history[0].equals("ST [10-7]")) {
        logger.error("after drill: free=" + match.isFreePlay() + " " + printMatchStatus(status));
        return false;
    }
    if (status.getP1Sets() != 1 || status.getP2Sets() != 0 || status.getP1TieScore() != 0 || lapsSince(lapsBefore) != 2
            || !lastLap().equals("ST [10-7]")) {
        logger.error("laps=" + lapsSince(lapsBefore) + " label=" + lastLap() + " " + printMatchStatus(status));
        return false;
    }
    // back in free play: presses do nothing again
    match.incP1();
    return match.getMatchStatus().getP1TieScore() == 0 && match.getScoreString().equals("Drills 1-0: ST [10-7]");
}

(:test)
function trainingEndDrillRecordsScoreSoFarTest(logger as Logger) as Boolean {
    var match = trainingMatch();
    match.switchSetFormat(MatchConfig.FORMAT_TIE_BREAK);
    playPointsP1(match, 4);
    playPointsP2(match, 3);
    // Finish during a drill: its score so far is in the score
    var history = match.getHistoricalScores();
    if (history.size() != 1 || !history[0].equals("TB [4-3]") || !match.segmentLabel().equals("TB [4-3]")) {
        logger.error("in progress: " + history + " label=" + match.segmentLabel());
        return false;
    }
    var lapsBefore = Application.getApp().getLapCount();
    match.endDrill();
    var status = match.getMatchStatus();
    history = match.getHistoricalScores();
    // recorded as 4-3, but counts for nobody
    if (!match.isFreePlay() || history.size() != 1 || !history[0].equals("TB [4-3]") || status.getP1Sets() + status.getP2Sets() != 0) {
        logger.error("after end: free=" + match.isFreePlay() + " " + printMatchStatus(status));
        return false;
    }
    if (status.getP1TieScore() != 0 || status.getP2TieScore() != 0 || lapsSince(lapsBefore) != 1 || !lastLap().equals("TB [4-3]")
            || !match.getScoreString().equals("Drills 0-0: TB [4-3]")) {
        logger.error("laps=" + lapsSince(lapsBefore) + " label=" + lastLap() + " score=" + match.getScoreString());
        return false;
    }
    // a drill ended before any point isn't written to the score (its lap is still labelled)
    match.switchSetFormat(MatchConfig.FORMAT_MINI);
    match.endDrill();
    return match.getHistoricalScores().size() == 1 && lastLap().equals("MS 2-2");
}

(:test)
function trainingUndoAfterEndDrillTest(logger as Logger) as Boolean {
    var match = trainingMatch();
    match.switchSetFormat(MatchConfig.FORMAT_TIE_BREAK);
    playPointsP1(match, 4);
    playPointsP2(match, 3);
    match.endDrill();
    // Undo is in the free-play menu now
    if (!match.canUndo()) {
        logger.error("nothing to undo after End drill");
        return false;
    }
    match.undo();
    var status = match.getMatchStatus();
    if (match.isFreePlay() || !match.isInTieBreak() || status.getP1TieScore() != 4 || status.getP2TieScore() != 3) {
        logger.error("undo: free=" + match.isFreePlay() + " " + printMatchStatus(status));
        return false;
    }
    // the drill goes on from 4-3
    playPointsP1(match, 3);
    var history = match.getHistoricalScores();
    return match.isFreePlay() && history.size() == 1 && history[0].equals("TB [7-3]");
}

(:test)
function trainingMiniSetDrillTest(logger as Logger) as Boolean {
    var match = trainingMatch();
    match.switchSetFormat(MatchConfig.FORMAT_MINI);
    var status = match.getMatchStatus();
    if (status.getP1Games() != 2 || status.getP2Games() != 2 || match.isFreePlay()) {
        logger.error("mini start: " + printMatchStatus(status));
        return false;
    }
    playPointsP2(match, 4); // 2-3
    playPointsP1(match, 16); // 6-3
    status = match.getMatchStatus();
    var history = match.getHistoricalScores();
    if (!match.isFreePlay() || history.size() != 1 || !history[0].equals("MS 6-3")) {
        logger.error("mini end: free=" + match.isFreePlay() + " " + printMatchStatus(status));
        return false;
    }
    return status.getP1Games() == 0 && status.getP2Games() == 0 && status.getP1Sets() == 1;
}

(:test)
function trainingSetDrillHasNoPrefixTest(logger as Logger) as Boolean {
    var match = trainingMatch();
    match.switchSetFormat(MatchConfig.FORMAT_NORMAL);
    playSet(match, 0, 3);
    playSet(match, 6, 0); // 6-3
    match.switchSetFormat(MatchConfig.FORMAT_TIE_BREAK);
    playPointsP2(match, 7);
    var s = match.getScoreString();
    if (!s.equals("Drills 1-1: 6-3 / TB [0-7]")) {
        logger.error("score=" + s);
        return false;
    }
    return match.isFreePlay();
}

(:test)
function trainingNextDrillTest(logger as Logger) as Boolean {
    var match = trainingMatch();
    match.switchSetFormat(MatchConfig.FORMAT_TIE_BREAK);
    playPointsP1(match, 4);
    playPointsP2(match, 3);
    // Next drill: straight to a super tie, no free play in between, one lap; the tie-break is kept as 4-3
    var lapsBefore = Application.getApp().getLapCount();
    match.switchSetFormat(MatchConfig.FORMAT_SUPER_TIE);
    var status = match.getMatchStatus();
    if (match.isFreePlay() || !match.isInSuperTieBreak() || status.getP1TieScore() != 0 || status.getP2TieScore() != 0
            || lapsSince(lapsBefore) != 1 || !lastLap().equals("TB [4-3]") || match.getHistoricalScores().size() != 1) {
        logger.error("next ST: laps=" + lapsSince(lapsBefore) + " label=" + lastLap() + " " + printMatchStatus(status));
        return false;
    }
    // an untouched drill is still its own segment: a lap even with no points
    match.switchSetFormat(MatchConfig.FORMAT_MINI);
    status = match.getMatchStatus();
    // the untouched super tie isn't written to the score
    if (status.getP1Games() != 2 || status.getP2Games() != 2 || lapsSince(lapsBefore) != 2 || !lastLap().equals("ST [0-0]")
            || match.getHistoricalScores().size() != 1) {
        logger.error("next MS: laps=" + lapsSince(lapsBefore) + " " + printMatchStatus(status));
        return false;
    }
    // undo walks back through the drills: super tie at 0-0, then the tie-break at 4-3
    match.undo();
    var ok = match.isInSuperTieBreak() && match.getMatchStatus().getP1Games() == 0;
    match.undo();
    status = match.getMatchStatus();
    return ok && match.isInTieBreak() && !match.isInSuperTieBreak() && status.getP1TieScore() == 4 && status.getP2TieScore() == 3;
}

(:test)
function trainingUndoNeverBackIntoFreePlayTest(logger as Logger) as Boolean {
    var match = trainingMatch();
    match.switchSetFormat(MatchConfig.FORMAT_TIE_BREAK);
    playPointsP1(match, 2);
    match.endDrill();
    match.addUnforcedError();
    // starting a drill ends a free-play segment (a lap): undo can't go back before it
    match.switchSetFormat(MatchConfig.FORMAT_SUPER_TIE);
    if (match.canUndo()) {
        logger.error("undo stack kept across a finished free segment");
        return false;
    }
    match.undo();
    return match.isInSuperTieBreak() && !match.isFreePlay() && match.getMatchStatus().getUnforcedErrors() == 1;
}

(:test)
function trainingServingResetPerDrillTest(logger as Logger) as Boolean {
    var match = trainingMatch();
    match.switchSetFormat(MatchConfig.FORMAT_MINI);
    // off by default in training; Switch server turns it on during a drill
    if (match.getServingSide() != -1) {
        logger.error("serving on by default");
        return false;
    }
    match.switchServer();
    playPointsP1(match, 4); // 3-2, one game played: them serving
    if (match.getServingSide() != Sides.SIDE_P2) {
        logger.error("serving=" + match.getServingSide());
        return false;
    }
    match.endDrill();
    var status = match.getMatchStatus();
    if (status.getFirstServer() != -1 || status.getGamesPlayed() != 0 || match.getServingSide() != -1) {
        logger.error("not reset by End drill: " + status.getFirstServer() + " / " + status.getGamesPlayed());
        return false;
    }
    // inside the undo entry: undo brings both back
    match.undo();
    if (match.getServingSide() != Sides.SIDE_P2 || match.getMatchStatus().getGamesPlayed() != 1) {
        logger.error("undo: serving=" + match.getServingSide());
        return false;
    }
    // a won drill resets them too
    playPointsP1(match, 12); // 6-2
    status = match.getMatchStatus();
    var ok = match.isFreePlay() && status.getFirstServer() == -1 && status.getGamesPlayed() == 0;
    // and the next drill starts without a server
    match.switchSetFormat(MatchConfig.FORMAT_TIE_BREAK);
    return ok && match.getServingSide() == -1;
}

(:test)
function trainingSegmentTimeTest(logger as Logger) as Boolean {
    // MatchEngine takes the time from its caller, so the test controls it
    var engine = new MatchEngine(MatchConfig.UNLIMITED_SETS, new GoldenPointGameEngine(), MatchConfig.FORMAT_FREE, false);
    engine.startSession(100);
    engine.incP1(150); // free play: no new segment
    var t0 = engine.getMatchStatus().getSegmentStartTime();
    engine.switchSetFormat(MatchConfig.FORMAT_TIE_BREAK, 160);
    var t1 = engine.getMatchStatus().getSegmentStartTime();
    for (var i = 0; i < 7; i++) {
        engine.incP1(200 + i);
    }
    var t2 = engine.getMatchStatus().getSegmentStartTime(); // won at 206: free play starts then
    engine.undo();
    var t3 = engine.getMatchStatus().getSegmentStartTime(); // back in the drill
    engine.switchSetFormat(MatchConfig.FORMAT_FREE, 300);
    var t4 = engine.getMatchStatus().getSegmentStartTime();
    if (t0 != 100 || t1 != 160 || t2 != 206 || t3 != 160 || t4 != 300 || !engine.isFreePlay()) {
        logger.error("times: " + [t0, t1, t2, t3, t4]);
        return false;
    }
    return true;
}

(:test)
function trainingUnforcedErrorsCountEverywhereTest(logger as Logger) as Boolean {
    var match = trainingMatch();
    match.addUnforcedError();
    match.switchSetFormat(MatchConfig.FORMAT_TIE_BREAK);
    match.addUnforcedError();
    match.endDrill();
    return match.getMatchStatus().getUnforcedErrors() == 2;
}

(:test)
function trainingLapLabelLimitsTest(logger as Logger) as Boolean {
    // every drill result fits the 15-character lap field (training saves no session score)
    var longest = ["MS 7-6 (12)", "ST [12-10]", "Free"];
    for (var i = 0; i < longest.size(); i++) {
        if (!fitString(longest[i], LAP_STRING_MAX).equals(longest[i])) {
            logger.error("lap label cut: " + longest[i]);
            return false;
        }
    }
    // a longer label is cut on purpose, never left to the platform
    return fitString("1234567890123456789", LAP_STRING_MAX).length() == LAP_STRING_MAX;
}
