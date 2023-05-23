class padelMatch {

    static const AVAILABLE_POINTS = [0, 15, 30, 40];

    private var p1Sets;
    private var p2Sets;

    private var p1Games;
    private var p2Games;

    private var p1ScoreIdx;
    private var p2ScoreIdx;

    private var p1TieBreakScore;
    private var p2TieBreakScore;

    private var historicalScores;

    function initialize() {
        p1Sets = 0;
        p2Sets = 0;

        p1Games = 0;
        p2Games = 0;
        
        p1ScoreIdx = 0;
        p2ScoreIdx = 0;

        p1TieBreakScore = 0;
        p2TieBreakScore = 0;

        historicalScores = [];
        
    }

    // FIXME remove debug prints
    function printScore() {
        System.println("score: sets " + self.p1Sets + " - " + self.p2Sets);
        System.println("score: games " + self.p1Games + " - " + self.p2Games);
        System.println("score: " + AVAILABLE_POINTS[self.p1ScoreIdx] + " - " + AVAILABLE_POINTS[self.p2ScoreIdx]);
        System.println("tie break: " + self.p1TieBreakScore + " - " + self.p2TieBreakScore);
        System.println("historicalScores: " + self.historicalScores);
    }

    function incP1() {
        if (self.isInTieBreak()) {
            self.p1TieBreakScore++;

            if (self.p1TieBreakScore >= 7 && self.p1TieBreakScore - self.p2TieBreakScore >= 2) {
                self.p1Games++;
                self.p1Sets++;
                self.resetAfterSetFinish();
            }

            return;
        }

        // normal (not end of game) case
        if (AVAILABLE_POINTS[self.p1ScoreIdx] != 40) {
            self.p1ScoreIdx++;
            return;
        }

        self.p1Games++;
        self.resetAfterGameFinish();

        // end of set
        if (self.p1Games >= 6 && self.p1Games - self.p2Games >= 2) {
            self.p1Sets++;
            self.resetAfterSetFinish();
        }
    }


    function incP2() {
        if (self.isInTieBreak()) {
            self.p2TieBreakScore++;

            if (self.p2TieBreakScore >= 7 && self.p2TieBreakScore - self.p1TieBreakScore >= 2) {
                self.p2Games++;
                self.p2Sets++;
                self.resetAfterSetFinish();
            }

            return;
        }

        // normal (not end of game) case
        if (AVAILABLE_POINTS[self.p2ScoreIdx] != 40) {
            self.p2ScoreIdx++;
            return;
        }

        self.p2Games++;
        self.resetAfterGameFinish();

        // end of set
        if (self.p2Games >= 6 && self.p2Games - self.p1Games >= 2) {
            self.p2Sets++;
            self.resetAfterSetFinish();
        }
    }

    function getP1Sets() {
        return self.p1Sets;
    }

    function getP1Games() {
        return self.p1Games;
    }

    function getP1Score() {
        return AVAILABLE_POINTS[self.p1ScoreIdx];
    }

    function getP1TieScore() {
        return self.p1TieBreakScore;
    }

    function getP2Sets() {
        return self.p2Sets;
    }

    function getP2Games() {
        return self.p2Games;
    }

    function getP2Score() {
        return AVAILABLE_POINTS[self.p2ScoreIdx];
    }

    function getP2TieScore() {
        return self.p2TieBreakScore;
    }

    function getHistoricalScores() {
        return self.historicalScores;
    }

    function isInTieBreak() {
        return self.p1Games >= 6 && self.p2Games >= 6;
    }

    function resetAfterSetFinish() {
        var result = "" + self.p1Games + "-" + self.p2Games;
        if (self.isInTieBreak()) {
            result += " (" + self.min(self.p1TieBreakScore, self.p2TieBreakScore) + ")";
        }

        self.historicalScores.add(result);

        self.p1Games = 0;
        self.p2Games = 0;

        self.resetAfterGameFinish();
    }

    function resetAfterGameFinish() {
        self.p1ScoreIdx = 0;
        self.p2ScoreIdx = 0;

        self.p1TieBreakScore = 0;
        self.p2TieBreakScore = 0;
    }

    // TODO move out of here
    function min(x, y) {
        if (x > y) {
            return y;
        } else {
            return x;
        }
    }

}