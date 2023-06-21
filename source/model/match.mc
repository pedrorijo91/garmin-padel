import Toybox.Lang;

class padelMatch {

    private var numberOfSets;
    private var superTie;

    private var historicalScores;

    private var matchStatus;

    function initialize(config as matchConfig) {

        numberOfSets = config.getNumberOfSets();
        superTie = config.getSuperTie();

        matchStatus = new matchStatus();

        historicalScores = [];
    }

    function incP1() as Boolean {
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

        // normal (not end of game) case
        if (self.matchStatus.getP1Score() != 40) {
            self.matchStatus.incP1Score();
            return false;
        }

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

    function incP2() as Boolean {
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

        // normal (not end of game) case
        if (self.matchStatus.getP2Score() != 40) {
            self.matchStatus.incP2Score();
            return false;
        }

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

    function getMatchStatus() {
        return self.matchStatus;
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
        if (
            totalPlayedSets == self.numberOfSets || 
            abs(self.matchStatus.getP1Sets() - self.matchStatus.getP2Sets()) > self.numberOfSets - totalPlayedSets
        ) {
            return true;
        }

        return false;
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