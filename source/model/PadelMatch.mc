import Toybox.Lang;

class PadelMatch {

    private var numberOfSets;
    private var superTie;
    private var goldenPoint;

    private var historicalScores;

    private var matchStatus;

    private var prevMatchStatus;

    function initialize(config as MatchConfig) {

        numberOfSets = config.getNumberOfSets();
        superTie = config.getSuperTie();
        goldenPoint = config.getGoldenPoint();

        matchStatus = MatchStatus.New();
        prevMatchStatus = MatchStatus.New();

        historicalScores = [];
    }

    // returns a boolean indicating wether the match has ended.
    function incP1() as Boolean {
        prevMatchStatus = matchStatus.copy();
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

    // returns a boolean indicating wether the match has ended.
    function incP2() as Boolean {
        prevMatchStatus = matchStatus.copy();
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

    function undo() {
        self.matchStatus = self.prevMatchStatus;
    }

    function getMatchStatus() {
        return self.matchStatus.copy();
    }

    function getHistoricalScores() {
        var res = [];
        res.addAll(self.historicalScores);

        if (self.matchStatus.getP1Games() != 0 || self.matchStatus.getP2Games() != 0) {
            res.add("" + self.matchStatus.getP1Games() + "-" + self.matchStatus.getP2Games());
        }

        return res;
    }

    function isInSuperTieBreak() {
        var totalPlayedSets = self.matchStatus.getP1Sets() + self.matchStatus.getP2Sets();
        return self.superTie && self.numberOfSets - totalPlayedSets == 1 && self.matchStatus.getP1Sets() == self.matchStatus.getP2Sets();
    }

    function isInTieBreak() {
        return self.matchStatus.getP1Games() >= 6 && self.matchStatus.getP2Games() >= 6;
    }

    function finishSet() as Boolean {
        resetAfterSetFinish();

        // check if game is over
        var totalPlayedSets = self.matchStatus.getP1Sets() + self.matchStatus.getP2Sets();
        return 
            totalPlayedSets == self.numberOfSets || 
            abs(self.matchStatus.getP1Sets() - self.matchStatus.getP2Sets()) > self.numberOfSets - totalPlayedSets;

    }    

    function finishSuperTie() as Boolean {
        var result = "" + self.matchStatus.getP1TieScore() + "-" + self.matchStatus.getP2TieScore();
        self.historicalScores.add(result);
        return true;
    } 

    function resetAfterSetFinish() {
        var result = "" + self.matchStatus.getP1Games() + "-" + self.matchStatus.getP2Games();
        if (self.isInTieBreak()) {
            result += " (" + self.min(self.matchStatus.getP1TieScore(), self.matchStatus.getP2TieScore()) + ")";
        }

        self.historicalScores.add(result);

        self.matchStatus.resetGames();

        self.resetAfterGameFinish();
    }

    function resetAfterGameFinish() {
        self.matchStatus.resetScores();
    }
}