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

    // For mini set: when starting the set, games can be initialized (e.g. 2-2). Default 0-0.
    function getInitialP1Games() as Number {
        return 0;
    }

    function getInitialP2Games() as Number {
        return 0;
    }

    protected function otherSide(side as Number) as Number {
        return side == Sides.SIDE_P1 ? Sides.SIDE_P2 : Sides.SIDE_P1;
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
        return side == Sides.SIDE_P1 ? matchStatus.getP1TieScore() : matchStatus.getP2TieScore();
    }

    protected function incTieScoreForSide(side as Number, matchStatus as MatchStatus) as Void {
        if (side == Sides.SIDE_P1) {
            matchStatus.incP1TieScore();
        } else {
            matchStatus.incP2TieScore();
        }
    }
}

// Parameterized set: first to gamesToWin (margin 2), tie-break when both have tieBreakAt games (first to 7, margin 2).
// Optional initial games for mini set (start 2-2). Subclasses pass (gameEngine, gamesToWin, tieBreakAt, initialP1, initialP2).
class GamesSetEngine extends SetEngine {

    private var gameEngine as GameEngine;
    private var gamesToWin as Number;
    private var tieBreakAt as Number;
    private var initialP1 as Number;
    private var initialP2 as Number;
    private const TIE_BREAK_TARGET as Number = 7;
    private const MARGIN as Number = 2;

    function initialize(engine as GameEngine, gamesToWin as Number, tieBreakAt as Number, initialP1 as Number, initialP2 as Number) {
        SetEngine.initialize();
        self.gameEngine = engine;
        self.gamesToWin = gamesToWin;
        self.tieBreakAt = tieBreakAt;
        self.initialP1 = initialP1;
        self.initialP2 = initialP2;
    }

    function getInitialP1Games() as Number {
        return self.initialP1;
    }

    function getInitialP2Games() as Number {
        return self.initialP2;
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
            if (p1g >= self.gamesToWin && p1g - p2g >= MARGIN) {
                self.incSetsForSide(Sides.SIDE_P1, matchStatus);
                return true;
            }
            if (p2g >= self.gamesToWin && p2g - p1g >= MARGIN) {
                self.incSetsForSide(Sides.SIDE_P2, matchStatus);
                return true;
            }
        }
        return false;
    }

    function isInTieBreak(matchStatus as MatchStatus) as Boolean {
        return matchStatus.getP1Games() >= self.tieBreakAt && matchStatus.getP2Games() >= self.tieBreakAt;
    }

    function isInSuperTieBreak(matchStatus as MatchStatus) as Boolean {
        return false;
    }
}

// Standard set: first to 6 games, tie-break at 6-6.
class NormalSetEngine extends GamesSetEngine {

    function initialize(engine as GameEngine) {
        GamesSetEngine.initialize(engine, 6, 6, 0, 0);
    }
}

// Pro set: first to 9 games, tie-break at 8-8.
class ProSetEngine extends GamesSetEngine {

    function initialize(engine as GameEngine) {
        GamesSetEngine.initialize(engine, 9, 8, 0, 0);
    }
}

// Mini set: starts 2-2, first to 6 games wins (margin 2), tie-break at 5-5.
class MiniSetEngine extends GamesSetEngine {

    function initialize(engine as GameEngine) {
        GamesSetEngine.initialize(engine, 6, 5, 2, 2);
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
