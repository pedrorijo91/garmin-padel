import Toybox.Lang;

// Base class for set rules: games, tie-break, or super-tie.
// Stateless: receives MatchStatus, mutates games/tie scores/sets, returns true when set is won.
// Subclasses implement isInTieBreak, isInSuperTieBreak for the current set.
class SetEngine {

    function initialize() {
    }

    // Apply one point for the given side. Mutates matchStatus (games, tie scores, and sets when set ends).
    // Returns true when the set is won (caller must do set cleanup: history, reset games/scores, lap).
    function scorePoint(side as Number, matchStatus as MatchStatus) as Boolean {
        return false;
    }

    function isInTieBreak(matchStatus as MatchStatus) as Boolean {
        return false;
    }

    function isInSuperTieBreak(matchStatus as MatchStatus) as Boolean {
        return false;
    }

    protected function otherSide(side as Number) as Number {
        if (side == Sides.SIDE_P1) {
            return Sides.SIDE_P2;
        }
        return Sides.SIDE_P1;
    }

    protected function incGamesForSide(side as Number, matchStatus as MatchStatus) as Void {
        if (side == Sides.SIDE_P1) {
            matchStatus.incP1Games();
        } else {
            matchStatus.incP2Games();
        }
    }

    protected function incSetsForSide(side as Number, matchStatus as MatchStatus) as Void {
        if (side == Sides.SIDE_P1) {
            matchStatus.incP1Sets();
        } else {
            matchStatus.incP2Sets();
        }
    }

    protected function getTieScoreForSide(side as Number, matchStatus as MatchStatus) as Number {
        if (side == Sides.SIDE_P1) {
            return matchStatus.getP1TieScore();
        }
        return matchStatus.getP2TieScore();
    }

    protected function incTieScoreForSide(side as Number, matchStatus as MatchStatus) as Void {
        if (side == Sides.SIDE_P1) {
            matchStatus.incP1TieScore();
        } else {
            matchStatus.incP2TieScore();
        }
    }
}

// Standard set: first to 6 games (margin 2), tie-break at 6-6 (first to 7, margin 2).
class NormalSetEngine extends SetEngine {

    private var gameEngine as GameEngine;
    private const GAMES_TO_WIN as Number = 6;
    private const TIE_BREAK_TARGET as Number = 7;
    private const MARGIN as Number = 2;

    function initialize(engine as GameEngine) {
        SetEngine.initialize();
        self.gameEngine = engine;
    }

    function scorePoint(side as Number, matchStatus as MatchStatus) as Boolean {
        var opponent = self.otherSide(side);

        if (self.isInTieBreak(matchStatus)) {
            self.incTieScoreForSide(side, matchStatus);
            var myTie = self.getTieScoreForSide(side, matchStatus);
            var oppTie = self.getTieScoreForSide(opponent, matchStatus);
            if (myTie >= TIE_BREAK_TARGET && myTie - oppTie >= MARGIN) {
                self.incGamesForSide(side, matchStatus);
                self.incSetsForSide(side, matchStatus);
                return true;
            }
            return false;
        }

        var gameWon = self.gameEngine.scorePoint(side, matchStatus);
        if (gameWon) {
            self.incGamesForSide(side, matchStatus);
            matchStatus.resetScores();
            var p1g = matchStatus.getP1Games();
            var p2g = matchStatus.getP2Games();
            if (p1g >= GAMES_TO_WIN && p1g - p2g >= MARGIN) {
                self.incSetsForSide(Sides.SIDE_P1, matchStatus);
                return true;
            }
            if (p2g >= GAMES_TO_WIN && p2g - p1g >= MARGIN) {
                self.incSetsForSide(Sides.SIDE_P2, matchStatus);
                return true;
            }
        }
        return false;
    }

    function isInTieBreak(matchStatus as MatchStatus) as Boolean {
        return matchStatus.getP1Games() >= 6 && matchStatus.getP2Games() >= 6;
    }

    function isInSuperTieBreak(matchStatus as MatchStatus) as Boolean {
        return false;
    }
}

// Deciding set as super tie-break: first to 10 points, margin 2. No games.
class SuperTieSetEngine extends SetEngine {

    private const SUPER_TIE_TARGET as Number = 10;
    private const MARGIN as Number = 2;

    function initialize() {
        SetEngine.initialize();
    }

    function scorePoint(side as Number, matchStatus as MatchStatus) as Boolean {
        var opponent = self.otherSide(side);
        self.incTieScoreForSide(side, matchStatus);
        var myTie = self.getTieScoreForSide(side, matchStatus);
        var oppTie = self.getTieScoreForSide(opponent, matchStatus);
        if (myTie >= SUPER_TIE_TARGET && myTie - oppTie >= MARGIN) {
            self.incSetsForSide(side, matchStatus);
            return true;
        }
        return false;
    }

    function isInTieBreak(matchStatus as MatchStatus) as Boolean {
        return false;
    }

    function isInSuperTieBreak(matchStatus as MatchStatus) as Boolean {
        return true; // whole set is super tie
    }
}
