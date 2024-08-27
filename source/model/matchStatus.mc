import Toybox.Lang;

class MatchStatus {

    static const AVAILABLE_POINTS = [0, 15, 30, 40, 'A'];

    private var p1Sets;
    private var p2Sets;

    private var p1Games;
    private var p2Games;

    private var p1ScoreIdx;
    private var p2ScoreIdx;

    private var p1TieBreakScore;
    private var p2TieBreakScore;

    private var historicalScores;


    static function New() {
        return new MatchStatus(0,0,0,0,0,0,0,0, []);
    }

    function initialize(p1Sets, p2Sets, p1Games, p2Games, p1ScoreIdx, p2ScoreIdx, p1TieBreakScore, p2TieBreakScore, historicalScores) {
        self.p1Sets = p1Sets;
        self.p2Sets = p2Sets;

        self.p1Games = p1Games;
        self.p2Games = p2Games;
        
        self.p1ScoreIdx = p1ScoreIdx;
        self.p2ScoreIdx = p2ScoreIdx;

        self.p1TieBreakScore = p1TieBreakScore;
        self.p2TieBreakScore = p2TieBreakScore;

        self.historicalScores = historicalScores;
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

    function getHistoricalScores() as Lang.Array<Lang.String> {
        var res = [];
        res.addAll(self.historicalScores);
        return res;
    }

    function addHistoricalScore(result) {
        self.historicalScores.add(result);
    }

    function setDeuce() {
        self.p1ScoreIdx = 3;
        self.p2ScoreIdx = 3;
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

    function copy() as MatchStatus {
        var newHistory = [];
        newHistory.addAll(self.historicalScores);
        return new MatchStatus(p1Sets, p2Sets, p1Games, p2Games, p1ScoreIdx, p2ScoreIdx, p1TieBreakScore, p2TieBreakScore, newHistory);
    }
}