import Toybox.Lang;

class PadelMatch {

    static const MAX_UNDO = 5;
    static const SIDE_P1 = 0;
    static const SIDE_P2 = 1;

    private var numberOfSets as Number;
    private var superTie as Boolean;
    private var goldenPoint as Boolean;

    private var matchStatus as MatchStatus;

    private var undoStack;

    function initialize(config as MatchConfig) {

        numberOfSets = config.getNumberOfSets();
        superTie = config.getSuperTie();
        goldenPoint = config.getGoldenPoint();

        matchStatus = MatchStatus.New();
        undoStack = [];
    }

    // returns a boolean indicating wether the match has ended.
    function incP1() as Boolean {
        self.saveMatchStatus();
        return self.scorePoint(SIDE_P1);
    }

    // returns a boolean indicating wether the match has ended.
    function incP2() as Boolean {
        self.saveMatchStatus();
        return self.scorePoint(SIDE_P2);
    }

    // Generic scorer, parameterized by side
    function scorePoint(side as Number) as Boolean {
        var opponent = self.otherSide(side);

        if (self.isInSuperTieBreak()) {
            self.incTieScoreForSide(side);

            if (self.getTieScoreForSide(side) >= 10 &&
                self.getTieScoreForSide(side) - self.getTieScoreForSide(opponent) >= 2) {

                self.incSetsForSide(side);
                return self.finishSuperTie();
            }

            return false;
        }

        if (self.isInTieBreak()) {
            self.incTieScoreForSide(side);

            if (self.getTieScoreForSide(side) >= 7 &&
                self.getTieScoreForSide(side) - self.getTieScoreForSide(opponent) >= 2) {

                self.incGamesForSide(side);
                self.incSetsForSide(side);
                return self.finishSet();
            }

            return false;
        }

        // Regular game (non tie-break)
        if (self.goldenPoint) {
            // mid game
            if (self.getScoreForSide(side) != 40) {
                self.incScoreForSide(side);
                return false;
            } else {
                return self.incGameForSide(side);
            }
        } else {
            // Advantage rules
            // Opponent was in Adv, revert to deuce
            if (self.getScoreForSide(opponent) == 'A') {
                self.matchStatus.setDeuce();
                return false;
            }

            // Current side will win game
            if (
                self.getScoreForSide(side) == 'A' ||
                (self.getScoreForSide(side) == 40 && self.getScoreForSide(opponent) != 40)
            ) {
                return self.incGameForSide(side);
            }

            // mid game
            self.incScoreForSide(side);
            return false;
        }
    }

    // Side-aware helpers
    function otherSide(side as Number) as Number {
        if (side == SIDE_P1) {
            return SIDE_P2;
        }
        return SIDE_P1;
    }

    function getScoreForSide(side as Number) as Object {
        if (side == SIDE_P1) {
            return self.matchStatus.getP1Score();
        }
        return self.matchStatus.getP2Score();
    }

    function incScoreForSide(side as Number) as Void {
        if (side == SIDE_P1) {
            self.matchStatus.incP1Score();
        } else {
            self.matchStatus.incP2Score();
        }
    }

    function getTieScoreForSide(side as Number) as Number {
        if (side == SIDE_P1) {
            return self.matchStatus.getP1TieScore();
        }
        return self.matchStatus.getP2TieScore();
    }

    function incTieScoreForSide(side as Number) as Void {
        if (side == SIDE_P1) {
            self.matchStatus.incP1TieScore();
        } else {
            self.matchStatus.incP2TieScore();
        }
    }

    function incGamesForSide(side as Number) as Void {
        if (side == SIDE_P1) {
            self.matchStatus.incP1Games();
        } else {
            self.matchStatus.incP2Games();
        }
    }

    function incSetsForSide(side as Number) as Void {
        if (side == SIDE_P1) {
            self.matchStatus.incP1Sets();
        } else {
            self.matchStatus.incP2Sets();
        }
    }

    function incP1Game() as Boolean {
        self.matchStatus.incP1Games();
        self.resetAfterGameFinish();

        // end of set
        if (self.matchStatus.getP1Games() >= 6 && self.matchStatus.getP1Games() - self.matchStatus.getP2Games() >= 2) {
            self.matchStatus.incP1Sets();
            var endOfMatch = self.finishSet();
            return endOfMatch;
        }

        return false;
    }

    function incP2Game() as Boolean {
        self.matchStatus.incP2Games();
        self.resetAfterGameFinish();

        // end of set
        if (self.matchStatus.getP2Games() >= 6 && self.matchStatus.getP2Games() - self.matchStatus.getP1Games() >= 2) {
            self.matchStatus.incP2Sets();
            var endOfMatch = self.finishSet();
            return endOfMatch;
        }

        return false;
    }

    function incGameForSide(side as Number) as Boolean {
        if (side == SIDE_P1) {
            return self.incP1Game();
        }
        return self.incP2Game();
    }

    function undo() as Void {
        if (undoStack == null || undoStack.size() == 0) {
            return;
        }

        var lastState = undoStack[undoStack.size() - 1];
        self.matchStatus = lastState;
        undoStack.remove(lastState); // Arrays remove by object, not index, so remove the stored state object
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

    function isInSuperTieBreak() as Boolean {
        var totalPlayedSets = self.matchStatus.getP1Sets() + self.matchStatus.getP2Sets();
        return self.superTie && self.numberOfSets - totalPlayedSets == 1 && self.matchStatus.getP1Sets() == self.matchStatus.getP2Sets();
    }

    function isInTieBreak() as Boolean {
        return self.matchStatus.getP1Games() >= 6 && self.matchStatus.getP2Games() >= 6;
    }

    function finishSet() as Boolean {
        resetAfterSetFinish();
        Application.getApp().lapSession();

        // check if game is over
        var totalPlayedSets = self.matchStatus.getP1Sets() + self.matchStatus.getP2Sets();
        return 
            totalPlayedSets == self.numberOfSets || 
            abs(self.matchStatus.getP1Sets() - self.matchStatus.getP2Sets()) > self.numberOfSets - totalPlayedSets;

    }    

    function finishSuperTie() as Boolean {
        var result = "" + self.matchStatus.getP1TieScore() + "-" + self.matchStatus.getP2TieScore();
        self.matchStatus.addHistoricalScore(result);
        return true;
    } 

    function resetAfterSetFinish() as Void  {
        var result = "" + self.matchStatus.getP1Games() + "-" + self.matchStatus.getP2Games();
        if (self.isInTieBreak()) {
            result += " (" + self.min(self.matchStatus.getP1TieScore(), self.matchStatus.getP2TieScore()) + ")";
        }

        self.matchStatus.addHistoricalScore(result);

        self.matchStatus.resetGames();

        self.resetAfterGameFinish();
    }

    function resetAfterGameFinish() as Void {
        self.matchStatus.resetScores();
    }

    function saveMatchStatus() as Void {
        if (undoStack == null) {
            undoStack = [];
        }

        if (undoStack.size() == MAX_UNDO) {
            undoStack.remove(undoStack[0]); // Arrays remove by object, not by index, so remove the first element object explicitly
        }

        undoStack.add(self.matchStatus.copy());
    }
}