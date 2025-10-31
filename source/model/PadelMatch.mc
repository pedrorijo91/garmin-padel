import Toybox.Lang;

class PadelMatch {

    private var numberOfSets as Number;
    private var superTie as Boolean;
    private var goldenPoint as Boolean;

    private var matchStatus as MatchStatus;
    private var statusHistory as Array<MatchStatus>;
    private const MAX_HISTORY_ARRAY_SIZE = 20;

    function initialize(config as MatchConfig) {

        numberOfSets = config.getNumberOfSets();
        superTie = config.getSuperTie();
        goldenPoint = config.getGoldenPoint();

        matchStatus = MatchStatus.New();
        statusHistory = [];
    }
    // returns a boolean indicating whether the match has ended.
    function incP1() as Boolean {
        addMatchStatusToHistory();

        if (self.isInSuperTieBreak()) {
            self.matchStatus.incP1TieScore();

            if (self.matchStatus.getP1TieScore() >= 10 && self.matchStatus.getP1TieScore() - self.matchStatus.getP2TieScore() >= 2) {
                self.matchStatus.incP1Sets();
                var endOfMatch = self.finishSuperTie();
                return endOfMatch;
            }

            return false;
        }

        if (self.isInTieBreak()) {
            self.matchStatus.incP1TieScore();

            if (self.matchStatus.getP1TieScore() >= 7 && self.matchStatus.getP1TieScore() - self.matchStatus.getP2TieScore() >= 2) {
                self.matchStatus.incP1Games();
                self.matchStatus.incP1Sets();
                var endOfMatch = self.finishSet();
                return endOfMatch;
            }

            return false;
        }

        // G:
            // P1 == 40 (end game)
            // P1 != 40 (mid game)
        // A:
            // (end game)
                // P1 == A 
                // P1 == 40 && P2 != A && P2 < 40
            // P2 == A (deuce)
            // (mid game)

        if (self.goldenPoint) {
            // mid game
            if (self.matchStatus.getP1Score() != 40) {
                self.matchStatus.incP1Score();
                return false;
            } else {
                return incP1Game();
            }
        } else {
            // P2 was in Adv, revert to deuce
            if (self.matchStatus.getP2Score() == 'A') {
                self.matchStatus.setDeuce();
                return false;
            }

            // P1 will win game
            if (
                self.matchStatus.getP1Score() == 'A' || 
                (self.matchStatus.getP1Score() == 40 && self.matchStatus.getP2Score() != 40)) {
                    return incP1Game();
            }

            // mid game
            self.matchStatus.incP1Score();
            return false;
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

    function addMatchStatusToHistory() as Void {
        statusHistory.add(matchStatus.copy());
        if (statusHistory.size() > MAX_HISTORY_ARRAY_SIZE) {
            // keep the history size from MAX_HISTORY_ARRAY_SIZE / 2 to MAX_HISTORY_ARRAY_SIZE not to fill up the memory too much
            statusHistory = statusHistory.slice(MAX_HISTORY_ARRAY_SIZE / 2, null);
        }
    }

    // returns a boolean indicating whether the match has ended.
    function incP2() as Boolean {
        addMatchStatusToHistory();

        if (self.isInSuperTieBreak()) {
            self.matchStatus.incP2TieScore();

            if (self.matchStatus.getP2TieScore() >= 10 && self.matchStatus.getP2TieScore() - self.matchStatus.getP1TieScore() >= 2) {
                self.matchStatus.incP2Sets();
                var endOfMatch = self.finishSuperTie();
                return endOfMatch;
            }

            return false;
        }

        if (self.isInTieBreak()) {
            self.matchStatus.incP2TieScore();

            if (self.matchStatus.getP2TieScore() >= 7 && self.matchStatus.getP2TieScore() - self.matchStatus.getP1TieScore() >= 2) {
                self.matchStatus.incP2Games();
                self.matchStatus.incP2Sets();
                var endOfMatch = self.finishSet();
                return endOfMatch;
            }

            return false;
        }

        // G:
            // P1 == 40 (end game)
            // P1 != 40 (mid game)
        // A:
            // (end game)
                // P1 == A 
                // P1 == 40 && P2 != A && P2 < 40
            // P2 == A (deuce)
            // (mid game)

        if (self.goldenPoint) {
            // mid game
            if (self.matchStatus.getP2Score() != 40) {
                self.matchStatus.incP2Score();
                return false;
            } else {
                return incP2Game();
            }
        } else {
            // P1 was in Adv, revert to deuce
            if (self.matchStatus.getP1Score() == 'A') {
                self.matchStatus.setDeuce();
                return false;
            }

            // P2 will win game
            if (
                self.matchStatus.getP2Score() == 'A' || 
                (self.matchStatus.getP2Score() == 40 && self.matchStatus.getP1Score() != 40)) {
                    return incP2Game();
            }

            // mid game
            self.matchStatus.incP2Score();
            return false;
        }
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

    function undo() as Void {
        var historySize = self.statusHistory.size();
        if (historySize > 0) {
            self.matchStatus = self.statusHistory[historySize - 1] as MatchStatus;
            self.statusHistory = self.statusHistory.slice(0, historySize - 1);
        }
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
}