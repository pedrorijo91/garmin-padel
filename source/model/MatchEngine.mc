import Toybox.Application;
import Toybox.Lang;

// Owns match state (MatchStatus, undo) and delegates point scoring to the current SetEngine.
// The current set's format is stored in MatchStatus (setFormat). With FORMAT_DEFAULT the config decides:
// the default set engine, or the deciding super tie when sets are tied with one set left.
// A session is a sequence of segments (sets, drills, free play). FORMAT_FREE is free play: no score.
// Training (defaultFormat = FORMAT_FREE): free play by default, drills chosen from Options, back to free
// play when a drill is won. A match with a warm-up starts with a FREE segment.
// Methods that start a segment take `now` (seconds, Time.now().value()): the model never reads the clock.
class MatchEngine {

    static const MAX_UNDO = 5;

    private var numberOfSets as Number;
    private var defaultFormat as Number;
    private var gameEngine as GameEngine;
    private var defaultSetEngine as SetEngine;
    private var decidingSetEngine as SetEngine or Null;

    // engine for a format chosen mid-match (MatchStatus.setFormat), built on first use. One slot is enough.
    private var formatEngine as SetEngine or Null;
    private var formatEngineFormat as Number;

    private var matchStatus as MatchStatus;
    private var undoStack as Array<MatchStatus>;

    // defaultFormat: MatchConfig.FORMAT_NORMAL / PRO / MINI (same values as SET_TYPE_*), or FORMAT_FREE for training.
    // superTie: the deciding set of a limited match is a super tie-break.
    function initialize(
        sets as Number,
        engine as GameEngine,
        defaultFormat as Number,
        superTie as Boolean
    ) {
        self.numberOfSets = sets;
        self.defaultFormat = defaultFormat;
        self.gameEngine = engine;
        self.formatEngine = null;
        self.formatEngineFormat = MatchConfig.FORMAT_DEFAULT;
        self.defaultSetEngine = self.engineForFormat(defaultFormat);
        self.decidingSetEngine = superTie ? self.engineForFormat(MatchConfig.FORMAT_SUPER_TIE) : null;
        self.matchStatus = MatchStatus.New();
        self.undoStack = [];
        self.applyInitialGames(self.defaultSetEngine);
    }

    private function engineForFormat(format as Number) as SetEngine {
        if (format == MatchConfig.FORMAT_FREE) {
            // the base engine scores nothing: free play
            return new SetEngine();
        }
        if (format == MatchConfig.FORMAT_SUPER_TIE) {
            return new SuperTieSetEngine(SuperTieSetEngine.SUPER_TIE_TARGET);
        }
        if (format == MatchConfig.FORMAT_TIE_BREAK) {
            return new SuperTieSetEngine(SuperTieSetEngine.TIE_BREAK_TARGET);
        }
        if (format == MatchConfig.FORMAT_PRO) {
            return new ProSetEngine(self.gameEngine);
        }
        if (format == MatchConfig.FORMAT_MINI) {
            return new MiniSetEngine(self.gameEngine);
        }
        return new NormalSetEngine(self.gameEngine);
    }

    // Play the given format (MatchConfig.FORMAT_TIE_BREAK / SUPER_TIE / MINI, ...) now, in place of the current set.
    // Undoable. If nothing has been played in the current set, only its format changes. Otherwise the
    // current set is dropped (not written to the score, awarded to nobody), a lap is added, and the chosen
    // format starts from scratch (a game in progress is discarded: it doesn't count in gamesPlayed).
    // When the chosen format finishes, the next set goes back to the match default.
    // Training: Start drill (from free play), Next drill (drill -> drill) and End drill (format FORMAT_FREE).
    // Every change is a new segment with its own lap; the serving team is reset (off until Switch server).
    // A drill left unfinished is recorded with its score so far ("TB [4-3]") but counts for nobody.
    // Leaving free play clears the undo stack: a lap can't be removed, so undo never goes back into it.
    function switchSetFormat(format as Number, now as Number) as Void {
        var training = self.isTraining();
        var fromFree = self.isFreePlay();
        if (self.isMatchOver() || (fromFree && format == MatchConfig.FORMAT_FREE)) {
            return;
        }
        var label = self.segmentLabel();
        var started = self.isSetStarted();
        var newSegment = training || started;
        if (fromFree) {
            self.undoStack = [];
        } else {
            self.saveMatchStatus();
        }
        if (training && !fromFree && started) {
            self.matchStatus.addHistoricalScore(label);
        }
        self.matchStatus.resetGames();
        self.matchStatus.resetScores();
        self.matchStatus.setSetFormat(format);
        self.applyInitialGames(self.getCurrentSetEngine());
        if (newSegment) {
            self.matchStatus.setSegmentStartTime(now);
            if (training) {
                self.resetServing();
            }
            Application.getApp().lapSession(label);
        }
    }

    // The first segment starts when the session starts (no undo entry)
    function startSession(now as Number) as Void {
        self.matchStatus.setSegmentStartTime(now);
    }

    // Training: each drill decides its own server (Options -> Switch server), so a drill starts with none
    private function resetServing() as Void {
        self.matchStatus.setFirstServer(-1);
        self.matchStatus.setGamesPlayed(0);
    }

    // Format being played now: the chosen one, or the match default (FORMAT_FREE in training).
    // Doesn't resolve the deciding super tie of a match (it reports the default set type then).
    function currentFormat() as Number {
        var format = self.matchStatus.getSetFormat();
        return format == MatchConfig.FORMAT_DEFAULT ? self.defaultFormat : format;
    }

    function isTraining() as Boolean {
        return self.defaultFormat == MatchConfig.FORMAT_FREE;
    }

    // free play: training between drills, or the warm-up of a match. Up/Down don't score.
    function isFreePlay() as Boolean {
        return self.currentFormat() == MatchConfig.FORMAT_FREE;
    }

    function canUndo() as Boolean {
        return self.undoStack.size() > 0;
    }

    // Short name of a drill format, used in results ("TB [7-5]") and lap labels
    static function drillName(format as Number) as String {
        if (format == MatchConfig.FORMAT_TIE_BREAK) {
            return "TB";
        }
        if (format == MatchConfig.FORMAT_SUPER_TIE) {
            return "ST";
        }
        if (format == MatchConfig.FORMAT_MINI) {
            return "MS";
        }
        if (format == MatchConfig.FORMAT_PRO) {
            return "Pro";
        }
        return "Set";
    }

    // Label for the FIT lap of the segment in progress: "Free" (or "Warm-up"), or the drill's score so far,
    // e.g. "TB [4-3]" for a drill stopped early.
    function segmentLabel() as String {
        var format = self.currentFormat();
        if (format == MatchConfig.FORMAT_FREE) {
            return self.isTraining() ? "Free" : "Warm-up";
        }
        return self.drillResult(self.getCurrentSetEngine(), false);
    }

    // A drill's score with its prefix: "TB [7-5]", "ST [10-8]", "MS 6-4"; a full set has none ("6-3").
    // finished = false: the score so far ("TB [4-3]", "MS 4-3").
    private function drillResult(setEngine as SetEngine, finished as Boolean) as String {
        var result = setEngine.formatResult(self.matchStatus, finished);
        var format = self.matchStatus.getSetFormat();
        if (self.isTraining() && format != MatchConfig.FORMAT_NORMAL) {
            result = drillName(format) + " " + result;
        }
        return result;
    }

    // true when points have been played in the current set, so switching format drops it
    function isSetStarted() as Boolean {
        return !self.getCurrentSetEngine().isUntouched(self.matchStatus);
    }

    // The current set's score, e.g. "4-3" or "[5-3]" (shown in Options as what switching drops).
    function currentSetResult() as String {
        return self.getCurrentSetEngine().formatResult(self.matchStatus, false);
    }

    // false when the current set has no games (a tie-break or super tie set)
    function currentSetHasGames() as Boolean {
        return self.getCurrentSetEngine().hasGames();
    }

    function incP1(now as Number) as Boolean {
        return self.incSide(Sides.SIDE_P1, now);
    }

    function incP2(now as Number) as Boolean {
        return self.incSide(Sides.SIDE_P2, now);
    }

    // Free play scores nothing and pushes no undo entry. In a match's warm-up the press ends the warm-up.
    private function incSide(side as Number, now as Number) as Boolean {
        if (self.isFreePlay()) {
            self.endWarmUp(now);
            return false;
        }
        if (self.isMatchOver()) {
            return false;
        }
        self.saveMatchStatus();
        return self.scorePoint(side, now);
    }

    function addUnforcedError() as Void {
        self.saveMatchStatus();
        self.matchStatus.incUnforcedErrors();
    }

    // Set which team serves the first game (Sides.SIDE_P1 / SIDE_P2, or -1 to hide the indicator).
    // Called once when the match starts, so no undo entry.
    function setFirstServer(side as Number) as Void {
        self.matchStatus.setFirstServer(side);
    }

    // Fix a wrong serving team mid-match: flips who serves now (and from now on). Undoable.
    // If the serving team was unknown, it becomes "us serving now".
    function switchServer() as Void {
        self.saveMatchStatus();
        var current = self.getServingSide();
        var target = Sides.other(current); // unknown (-1) -> us
        // serving side = firstServer when the alternation index is even, so pick firstServer to land on target
        var parity = self.getServeTurnIndex() % 2;
        self.matchStatus.setFirstServer(parity == 0 ? target : Sides.other(target));
    }

    // Team serving the current point: Sides.SIDE_P1, Sides.SIDE_P2, or -1 if unknown, in training free play or the match is over.
    // Serve alternates every game; a tie-break / super tie counts as one game in that alternation.
    // Inside a tie-break the team due to serve serves point 1, then serve changes every 2 points.
    function getServingSide() as Number {
        var first = self.matchStatus.getFirstServer();
        // training free play has no server; the warm-up keeps it (Switch server works there, the view hides it)
        if (first < 0 || self.isMatchOver() || (self.isTraining() && self.isFreePlay())) {
            return -1;
        }
        return self.getServeTurnIndex() % 2 == 0 ? first : Sides.other(first);
    }

    // Number of serve changes since the start of the match (games played, plus turns inside a tie-break).
    private function getServeTurnIndex() as Number {
        var turns = self.matchStatus.getGamesPlayed();
        if (self.isInTieBreak() || self.isInSuperTieBreak()) {
            var tiePoints = self.matchStatus.getP1TieScore() + self.matchStatus.getP2TieScore();
            turns += (tiePoints + 1) / 2;
        }
        return turns;
    }

    // --- Warm-up phase (plan 5) ---
    // The session starts recording in warm-up; the first Up/Down press (or Options -> Start match) ends it
    // without scoring and adds a lap, so lap 1 is the warm-up. A FIT lap can't be removed, so ending the
    // warm-up clears the undo stack: undo never goes back into the warm-up.
    // The warm-up is a FREE segment (plan 2) in a match whose default format is a scored set.

    function startWarmUp() as Void {
        if (!self.isTraining()) {
            self.matchStatus.setSetFormat(MatchConfig.FORMAT_FREE);
        }
    }

    function isWarmingUp() as Boolean {
        return self.isFreePlay() && !self.isTraining();
    }

    function endWarmUp(now as Number) as Void {
        if (!self.isWarmingUp()) {
            return;
        }
        self.matchStatus.setSetFormat(MatchConfig.FORMAT_DEFAULT);
        self.matchStatus.setSegmentStartTime(now);
        self.undoStack = [];
        Application.getApp().onWarmUpEnd();
    }

    function undo() as Void {
        if (self.undoStack.size() == 0) {
            return;
        }
        var lastState = self.undoStack[self.undoStack.size() - 1];
        self.matchStatus = lastState;
        self.undoStack.remove(lastState);
    }

    function getMatchStatus() as MatchStatus {
        return self.matchStatus.copy();
    }

    // Finished sets, plus the set in progress: its games once a game has been
    // played ("3-1"), or its points for a tie-break / super tie set ("[5-3]").
    function getHistoricalScores() as Lang.Array<Lang.String> {
        var res = self.matchStatus.getHistoricalScores();
        if (self.isMatchOver() || self.isFreePlay()) {
            return res;
        }
        // training: a drill in progress is listed with its prefix once a point is played ("TB [4-3]")
        if (self.isTraining()) {
            if (self.isSetStarted()) {
                res.add(self.segmentLabel());
            }
            return res;
        }
        var setEngine = self.getCurrentSetEngine();
        var inProgress;
        if (setEngine.hasGames()) {
            inProgress = self.matchStatus.getP1Games() != setEngine.getInitialP1Games()
                || self.matchStatus.getP2Games() != setEngine.getInitialP2Games();
        } else {
            inProgress = self.matchStatus.getP1TieScore() != 0 || self.matchStatus.getP2TieScore() != 0;
        }
        if (inProgress) {
            res.add(setEngine.formatResult(self.matchStatus, false));
        }
        return res;
    }

    function isInTieBreak() as Boolean {
        return self.getCurrentSetEngine().isInTieBreak(self.matchStatus);
    }

    function isInSuperTieBreak() as Boolean {
        return self.getCurrentSetEngine().isInSuperTieBreak(self.matchStatus);
    }

    private function getCurrentSetEngine() as SetEngine {
        var format = self.matchStatus.getSetFormat();
        if (format != MatchConfig.FORMAT_DEFAULT) {
            if (self.formatEngine == null || self.formatEngineFormat != format) {
                self.formatEngine = self.engineForFormat(format);
                self.formatEngineFormat = format;
            }
            return self.formatEngine as SetEngine;
        }
        if (self.decidingSetEngine == null) {
            return self.defaultSetEngine;
        }
        var totalPlayed = self.matchStatus.getP1Sets() + self.matchStatus.getP2Sets();
        var setsLeft = self.numberOfSets - totalPlayed;
        var tied = self.matchStatus.getP1Sets() == self.matchStatus.getP2Sets();
        if (self.numberOfSets != MatchConfig.UNLIMITED_SETS && setsLeft == 1 && tied) {
            return self.decidingSetEngine as SetEngine;
        }
        return self.defaultSetEngine;
    }

    private function scorePoint(side as Number, now as Number) as Boolean {
        var setEngine = self.getCurrentSetEngine();
        var gamesBefore = self.matchStatus.getP1Games() + self.matchStatus.getP2Games();
        var setWon = setEngine.scorePoint(side, self.matchStatus);
        // a game won, or a set won (by a game, a tie-break or a super tie), counts as one played game
        if (setWon || self.matchStatus.getP1Games() + self.matchStatus.getP2Games() != gamesBefore) {
            self.matchStatus.incGamesPlayed();
        }
        if (!setWon) {
            if (setEngine.isInTieBreak(self.matchStatus) || setEngine.isInSuperTieBreak(self.matchStatus)) {
                var totalTiePoints = self.matchStatus.getP1TieScore() + self.matchStatus.getP2TieScore();
                if (totalTiePoints > 0 && totalTiePoints % 6 == 0) {
                    Application.getApp().onTieBreakCourtChange();
                }
            }
        }
        if (setWon) {
            var result = self.resetAfterSetFinish(setEngine, now);
            Application.getApp().lapSession(result);
            if (self.isTraining()) {
                Application.getApp().onDrillWon(result);
            }
            return self.isMatchOver();
        }
        return false;
    }

    // Records the finished set and prepares the next one. Returns the result written to the history.
    private function resetAfterSetFinish(setEngine as SetEngine, now as Number) as String {
        // training: say which drill it was ("TB [7-5]"); a match result has no prefix
        var result = self.drillResult(setEngine, true);
        var training = self.isTraining();
        self.matchStatus.addHistoricalScore(result);
        self.matchStatus.resetGames();
        // a match that ends keeps its final tie points (e.g. the deciding super tie 10-8)
        if (!self.isMatchOver()) {
            self.matchStatus.resetScores();
            // a format chosen mid-match lasts one set: the next set goes back to the match default
            self.matchStatus.setSetFormat(MatchConfig.FORMAT_DEFAULT);
            self.applyInitialGames(self.getCurrentSetEngine());
            self.matchStatus.setSegmentStartTime(now);
            // training: a won drill goes back to free play, with no server for the next drill
            if (training) {
                self.resetServing();
            }
        }
        return result;
    }

    private function applyInitialGames(setEngine as SetEngine) as Void {
        var ip1 = setEngine.getInitialP1Games();
        var ip2 = setEngine.getInitialP2Games();
        if (ip1 != 0 || ip2 != 0) {
            self.matchStatus.setP1Games(ip1);
            self.matchStatus.setP2Games(ip2);
        }
    }

    private function isMatchOver() as Boolean {
        var totalPlayed = self.matchStatus.getP1Sets() + self.matchStatus.getP2Sets();
        if (self.numberOfSets == MatchConfig.UNLIMITED_SETS) {
            return false;
        }
        if (totalPlayed == self.numberOfSets) {
            return true;
        }
        var diff = self.matchStatus.getP1Sets() - self.matchStatus.getP2Sets();
        if (diff < 0) {
            diff = -diff;
        }
        return diff > self.numberOfSets - totalPlayed;
    }

    private function saveMatchStatus() as Void {
        if (self.undoStack.size() == MAX_UNDO) {
            self.undoStack.remove(self.undoStack[0]);
        }
        self.undoStack.add(self.matchStatus.copy());
    }
}
