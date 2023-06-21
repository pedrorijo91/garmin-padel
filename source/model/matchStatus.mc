class MatchStatus {

    static const AVAILABLE_POINTS = [0, 15, 30, 40];

    private var p1Sets;
    private var p2Sets;

    private var p1Games;
    private var p2Games;

    private var p1ScoreIdx;
    private var p2ScoreIdx;

    private var p1TieBreakScore;
    private var p2TieBreakScore;

    function initialize() {
        self.p1Sets = 0;
        self.p2Sets = 0;

        self.p1Games = 0;
        self.p2Games = 0;
        
        self.p1ScoreIdx = 0;
        self.p2ScoreIdx = 0;

        self.p1TieBreakScore = 0;
        self.p2TieBreakScore = 0;
     }

    function getP1Sets() {
        return self.p1Sets;
    }

    function incP1Sets() {
        self.p1Sets++;
    }

    function getP1Games() {
        return self.p1Games;
    }

    function incP1Games() {
        self.p1Games++;
    }

    function getP1Score() {
        return AVAILABLE_POINTS[self.p1ScoreIdx];
    }

    function incP1Score() {
        self.p1ScoreIdx++;
    }

    function getP1TieScore() {
        return self.p1TieBreakScore;
    }

    function incP1TieScore() {
        self.p1TieBreakScore++;
    }

    function getP2Sets() {
        return self.p2Sets;
    }

    function incP2Sets() {
        self.p2Sets++;
    }

    function getP2Games() {
        return self.p2Games;
    }

    function incP2Games() {
        self.p2Games++;
    }

    function getP2Score() {
        return AVAILABLE_POINTS[self.p2ScoreIdx];
    }

    function incP2Score() {
        self.p2ScoreIdx++;
    }

    function getP2TieScore() {
        return self.p2TieBreakScore;
    }

    function incP2TieScore() {
        self.p2TieBreakScore++;
    }

    function resetGames() {
        self.p1Games = 0;
        self.p2Games = 0;
    }

    function resetScores() {
        self.p1ScoreIdx = 0;
        self.p1TieBreakScore = 0;

        self.p2ScoreIdx = 0;
        self.p2TieBreakScore = 0;
    }
}