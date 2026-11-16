import Toybox.Application;
import Toybox.Lang;

// Owns match state (MatchStatus, undo) and delegates point scoring to the current SetEngine.
// The current set's format is stored in MatchStatus (setFormat). With FORMAT_DEFAULT the config decides:
// the default set engine, or the deciding super tie when sets are tied with one set left.
class MatchEngine {

    static const MAX_UNDO = 5;

    private var numberOfSets as Number;
    private var gameEngine as GameEngine;
    private var defaultSetEngine as SetEngine;
    private var decidingSetEngine as SetEngine or Null;

    // engine for a format chosen mid-match (MatchStatus.setFormat), built on first use. One slot is enough.
    private var formatEngine as SetEngine or Null;
    private var formatEngineFormat as Number;

    private var matchStatus as MatchStatus;
    private var undoStack as Array<MatchStatus>;

    // defaultFormat: MatchConfig.FORMAT_NORMAL / PRO / MINI (same values as SET_TYPE_*).
    // superTie: the deciding set of a limited match is a super tie-break.
    function initialize(
        sets as Number,
        engine as GameEngine,
        defaultFormat as Number,
        superTie as Boolean
    ) {
        self.numberOfSets = sets;
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
    // unfinished set goes into the history with a "*" (e.g. "4-3*", "[5-3]*"), is awarded to nobody, a lap
    // is added, and the chosen format starts from scratch (a game in progress is discarded: it doesn't count
    // in gamesPlayed). When the chosen format finishes, the next set goes back to the match default.
    function switchSetFormat(format as Number) as Void {
        if (self.isMatchOver()) {
            return;
        }
        self.saveMatchStatus();
        var current = self.getCurrentSetEngine();
        var unfinished = !current.isUntouched(self.matchStatus);
        if (unfinished) {
            self.matchStatus.addHistoricalScore(current.formatResult(self.matchStatus, false) + "*");
        }
        self.matchStatus.resetGames();
        self.matchStatus.resetScores();
        self.matchStatus.setSetFormat(format);
        self.applyInitialGames(self.getCurrentSetEngine());
        if (unfinished) {
            Application.getApp().lapSession();
        }
    }

    // true when points have been played in the current set, so switching format records it as unfinished
    function isSetStarted() as Boolean {
        return !self.getCurrentSetEngine().isUntouched(self.matchStatus);
    }

    // Result string the current set would be recorded with if switched now, e.g. "4-3*".
    function unfinishedSetResult() as String {
        return self.getCurrentSetEngine().formatResult(self.matchStatus, false) + "*";
    }

    // false when the current set has no games (a tie-break or super tie set)
    function currentSetHasGames() as Boolean {
        return self.getCurrentSetEngine().hasGames();
    }

    function incP1() as Boolean {
        if (self.isWarmingUp()) {
            self.endWarmUp();
            return false;
        }
        if (self.isMatchOver()) {
            return false;
        }
        self.saveMatchStatus();
        return self.scorePoint(Sides.SIDE_P1);
    }

    function incP2() as Boolean {
        if (self.isWarmingUp()) {
            self.endWarmUp();
            return false;
        }
        if (self.isMatchOver()) {
            return false;
        }
        self.saveMatchStatus();
        return self.scorePoint(Sides.SIDE_P2);
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

    // Team serving the current point: Sides.SIDE_P1, Sides.SIDE_P2, or -1 if unknown or the match is over.
    // Serve alternates every game; a tie-break / super tie counts as one game in that alternation.
    // Inside a tie-break the team due to serve serves point 1, then serve changes every 2 points.
    function getServingSide() as Number {
        var first = self.matchStatus.getFirstServer();
        if (first < 0 || self.isMatchOver()) {
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

    function startWarmUp() as Void {
        self.matchStatus.setPhase(MatchStatus.PHASE_WARM_UP);
    }

    function isWarmingUp() as Boolean {
        return self.matchStatus.getPhase() == MatchStatus.PHASE_WARM_UP;
    }

    function endWarmUp() as Void {
        if (!self.isWarmingUp()) {
            return;
        }
        self.matchStatus.setPhase(MatchStatus.PHASE_MATCH);
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

    // Finished (and unfinished "*") sets, plus the set in progress: its games once a game has been
    // played ("3-1"), or its points for a tie-break / super tie set ("[5-3]").
    function getHistoricalScores() as Lang.Array<Lang.String> {
        var res = self.matchStatus.getHistoricalScores();
        if (self.isMatchOver()) {
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

    private function scorePoint(side as Number) as Boolean {
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
            self.resetAfterSetFinish(setEngine);
            Application.getApp().lapSession();
            return self.isMatchOver();
        }
        return false;
    }

    private function resetAfterSetFinish(setEngine as SetEngine) as Void {
        self.matchStatus.addHistoricalScore(setEngine.formatResult(self.matchStatus, true));
        self.matchStatus.resetGames();
        // a match that ends keeps its final tie points (e.g. the deciding super tie 10-8)
        if (!self.isMatchOver()) {
            self.matchStatus.resetScores();
            // a format chosen mid-match lasts one set: the next set goes back to the match default
            self.matchStatus.setSetFormat(MatchConfig.FORMAT_DEFAULT);
            self.applyInitialGames(self.getCurrentSetEngine());
        }
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
