import Toybox.Lang;

class MatchStatus {

    static const AVAILABLE_POINTS = [0, 15, 30, 40, 'A'];

    private var p1Sets as Number;
    private var p2Sets as Number;

    private var p1Games as Number;
    private var p2Games as Number;

    private var p1ScoreIdx as Number;
    private var p2ScoreIdx as Number;

    private var p1TieBreakScore as Number;
    private var p2TieBreakScore as Number;

    private var historicalScores as Array<String>;


    static function New() as MatchStatus {
        return new MatchStatus(0,0,0,0,0,0,0,0, []);
    }

    function initialize(
        p1Sets  as Number, 
        p2Sets as Number, 
        p1Games as Number, 
        p2Games as Number, 
        p1ScoreIdx as Number, 
        p2ScoreIdx as Number, 
        p1TieBreakScore as Number, 
        p2TieBreakScore as Number, 
        historicalScores as Array<String>
    ) {

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


    function getP1Sets() as Number {
        return self.p1Sets;
    }

    function incP1Sets() as Void {
        self.p1Sets++;
    }

    function getP1Games() as Number {
        return self.p1Games;
    }

    function incP1Games() as Void {
        self.p1Games++;
    }

    function getP1Score() as Object {
        return AVAILABLE_POINTS[self.p1ScoreIdx];
    }

    function incP1Score() as Void {
        self.p1ScoreIdx++;
    }

    function getP1TieScore() as Number {
        return self.p1TieBreakScore;
    }

    function incP1TieScore() as Void {
        self.p1TieBreakScore++;
    }

    function getP2Sets() as Number {
        return self.p2Sets;
    }

    function incP2Sets() as Void {
        self.p2Sets++;
    }

    function getP2Games() as Number {
        return self.p2Games;
    }

    function incP2Games() as Void {
        self.p2Games++;
    }

    function getP2Score() as Object {
        return AVAILABLE_POINTS[self.p2ScoreIdx];
    }

    function incP2Score() as Void {
        self.p2ScoreIdx++;
    }

    function getP2TieScore() as Number {
        return self.p2TieBreakScore;
    }

    function incP2TieScore() as Void {
        self.p2TieBreakScore++;
    }

    function getHistoricalScores() as Lang.Array<Lang.String> {
        var res = [];
        res.addAll(self.historicalScores);
        return res;
    }

    function addHistoricalScore(result as String) as Void {
        self.historicalScores.add(result);
    }

    function setDeuce() as Void {
        self.p1ScoreIdx = 3;
        self.p2ScoreIdx = 3;
    }

    function resetGames() as Void {
        self.p1Games = 0;
        self.p2Games = 0;
    }

    function resetScores() as Void {
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