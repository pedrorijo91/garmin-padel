import Toybox.Lang;

class MatchStatus {

    static const AVAILABLE_POINTS = [0, 15, 30, 40, 'A'];

    // Phase of the session (plan 5). Once plan 2 lands, the warm-up becomes a FREE segment and this
    // can be replaced by the current segment's format, with the same lap and undo rules.
    static const PHASE_MATCH = 0;
    static const PHASE_WARM_UP = 1;

    private var p1Sets as Number;
    private var p2Sets as Number;

    private var p1Games as Number;
    private var p2Games as Number;

    private var p1ScoreIdx as Number;
    private var p2ScoreIdx as Number;

    private var p1TieBreakScore as Number;
    private var p2TieBreakScore as Number;

    private var historicalScores as Array<String>;

    // total unforced errors for our team during the whole match
    private var unforcedErrors as Number;

    // number of times we have returned to 40-40 after having advantage (for Silver/Star point)
    private var deuceRevertCount as Number;

    // team serving the first game of the match: Sides.SIDE_P1, Sides.SIDE_P2, or -1 = unknown (no serving indicator)
    private var firstServer as Number;

    // games actually played in the match (not the mini set's initial 2-2). A tie-break or super tie counts as one game.
    // Used to work out the serving team, which alternates every game.
    private var gamesPlayed as Number;

    // PHASE_MATCH (scoring) or PHASE_WARM_UP (before the first point: Up/Down end it instead of scoring)
    private var phase as Number;

    static function New() as MatchStatus {
        return new MatchStatus(0, 0, 0, 0, 0, 0, 0, 0, []);
    }

    // Max 9 arguments for compatibility with older devices (e.g. marqgolfer)
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
        self.unforcedErrors = 0;
        self.deuceRevertCount = 0;
        self.firstServer = -1;
        self.gamesPlayed = 0;
        self.phase = PHASE_MATCH;
    }

    function getPhase() as Number {
        return self.phase;
    }

    function setPhase(phase as Number) as Void {
        self.phase = phase;
    }

    function getFirstServer() as Number {
        return self.firstServer;
    }

    function setFirstServer(side as Number) as Void {
        self.firstServer = side;
    }

    function getGamesPlayed() as Number {
        return self.gamesPlayed;
    }

    function setGamesPlayed(n as Number) as Void {
        self.gamesPlayed = n;
    }

    function incGamesPlayed() as Void {
        self.gamesPlayed++;
    }

    function getDeuceRevertCount() as Number {
        return self.deuceRevertCount;
    }

    function setDeuceRevertCount(n as Number) as Void {
        self.deuceRevertCount = n;
    }

    function setUnforcedErrors(n as Number) as Void {
        self.unforcedErrors = n;
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

    function setP1Games(n as Number) as Void {
        self.p1Games = n;
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

    function setP2Games(n as Number) as Void {
        self.p2Games = n;
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
        self.deuceRevertCount++;
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
        self.deuceRevertCount = 0;
    }

    function getUnforcedErrors() as Number {
        return self.unforcedErrors;
    }

    function incUnforcedErrors() as Void {
        self.unforcedErrors++;
    }

    function copy() as MatchStatus {
        var newHistory = [];
        newHistory.addAll(self.historicalScores);
        var s = new MatchStatus(p1Sets, p2Sets, p1Games, p2Games, p1ScoreIdx, p2ScoreIdx, p1TieBreakScore, p2TieBreakScore, newHistory);
        s.setUnforcedErrors(self.unforcedErrors);
        s.setDeuceRevertCount(self.deuceRevertCount);
        s.setFirstServer(self.firstServer);
        s.setGamesPlayed(self.gamesPlayed);
        s.setPhase(self.phase);
        return s;
    }
}