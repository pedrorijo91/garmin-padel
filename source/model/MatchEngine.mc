import Toybox.Lang;

// Owns match state (MatchStatus, undo) and delegates point scoring to the current SetEngine.
// Chooses default or deciding (e.g. super-tie) set engine based on set count and tie.
class MatchEngine {

    static const MAX_UNDO = 5;

    private var numberOfSets as Number;
    private var defaultSetEngine as SetEngine;
    private var decidingSetEngine as SetEngine or Null;

    private var matchStatus as MatchStatus;
    private var undoStack as Array<MatchStatus>;

    function initialize(
        sets as Number,
        defaultEngine as SetEngine,
        decidingEngine as SetEngine or Null
    ) {
        self.numberOfSets = sets;
        self.defaultSetEngine = defaultEngine;
        self.decidingSetEngine = decidingEngine;
        self.matchStatus = MatchStatus.New();
        self.undoStack = [];
    }

    function incP1() as Boolean {
        self.saveMatchStatus();
        return self.scorePoint(Sides.SIDE_P1);
    }

    function incP2() as Boolean {
        self.saveMatchStatus();
        return self.scorePoint(Sides.SIDE_P2);
    }

    function addUnforcedError() as Void {
        self.saveMatchStatus();
        self.matchStatus.incUnforcedErrors();
    }

    function undo() as Void {
        if (self.undoStack == null || self.undoStack.size() == 0) {
            return;
        }
        var lastState = self.undoStack[self.undoStack.size() - 1];
        self.matchStatus = lastState;
        self.undoStack.remove(lastState);
    }

    function getMatchStatus() as MatchStatus {
        return self.matchStatus.copy();
    }

    function getHistoricalScores() as Lang.Array<Lang.String> {
        var res = self.matchStatus.getHistoricalScores();
        if (self.matchStatus.getP1Games() != 0 || self.matchStatus.getP2Games() != 0) {
            res.add("" + self.matchStatus.getP1Games() + "-" + self.matchStatus.getP2Games());
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
        var setWon = setEngine.scorePoint(side, self.matchStatus);
        if (setWon) {
            self.resetAfterSetFinish(setEngine);
            Application.getApp().lapSession();
            return self.isMatchOver();
        }
        return false;
    }

    private function resetAfterSetFinish(setEngine as SetEngine) as Void {
        var result;
        if (setEngine.isInSuperTieBreak(self.matchStatus)) {
            result = "" + self.matchStatus.getP1TieScore() + "-" + self.matchStatus.getP2TieScore();
        } else {
            result = "" + self.matchStatus.getP1Games() + "-" + self.matchStatus.getP2Games();
            if (setEngine.isInTieBreak(self.matchStatus)) {
                result += " (" + min(self.matchStatus.getP1TieScore(), self.matchStatus.getP2TieScore()) + ")";
            }
        }
        self.matchStatus.addHistoricalScore(result);
        self.matchStatus.resetGames();
        if (!setEngine.isInSuperTieBreak(self.matchStatus)) {
            self.matchStatus.resetScores();
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
        if (self.undoStack == null) {
            self.undoStack = [];
        }
        if (self.undoStack.size() == MAX_UNDO) {
            self.undoStack.remove(self.undoStack[0]);
        }
        self.undoStack.add(self.matchStatus.copy());
    }
}
