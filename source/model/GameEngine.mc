import Toybox.Lang;

// Base class for point-by-point game scoring (within a single game).
// Subclasses implement deuce/golden point/advantage rules.
// Stateless: receives MatchStatus, mutates only current game points, returns true if game won.
class GameEngine {

    function initialize() {
    }

    // Apply one point for the given side. Mutates matchStatus (scores only).
    // Returns true if the game is won by that side (caller must inc games and reset scores).
    function scorePoint(side as Number, matchStatus as MatchStatus) as Boolean {
        // Base: subclasses must override
        return false;
    }

    protected function getScoreForSide(side as Number, matchStatus as MatchStatus) as Object {
        return side == Sides.SIDE_P1 ? matchStatus.getP1Score() : matchStatus.getP2Score();
    }

    protected function incScoreForSide(side as Number, matchStatus as MatchStatus) as Void {
        if (side == Sides.SIDE_P1) {
            matchStatus.incP1Score();
        } else {
            matchStatus.incP2Score();
        }
    }

    protected function otherSide(side as Number) as Number {
        return side == Sides.SIDE_P1 ? Sides.SIDE_P2 : Sides.SIDE_P1;
    }
}

// At 40-40 (deuce), the next point wins the game.
class GoldenPointGameEngine extends GameEngine {

    function initialize() {
        GameEngine.initialize();
    }

    function scorePoint(side as Number, matchStatus as MatchStatus) as Boolean {
        var score = self.getScoreForSide(side, matchStatus);
        if (score != 40) {
            self.incScoreForSide(side, matchStatus);
            return false;
        }
        return true; // game won at deuce
    }
}

// Standard advantage: 40-40 -> advantage -> must win next point; losing advantage reverts to deuce.
class AdvantageGameEngine extends GameEngine {

    function initialize() {
        GameEngine.initialize();
    }

    function scorePoint(side as Number, matchStatus as MatchStatus) as Boolean {
        var opponent = self.otherSide(side);
        var sideScore = self.getScoreForSide(side, matchStatus);
        var oppScore = self.getScoreForSide(opponent, matchStatus);

        if (oppScore == 'A') {
            matchStatus.setDeuce();
            return false;
        }
        if (sideScore == 'A' || (sideScore == 40 && oppScore != 40)) {
            return true; // game won
        }
        self.incScoreForSide(side, matchStatus);
        return false;
    }
}

// Advantage with a decisive point after N reverts to deuce (Silver = 1, Star = 2).
// Shared logic for Silver and Star point.
class LimitedAdvantageGameEngine extends GameEngine {

    private var revertThreshold as Number;

    function initialize(threshold as Number) {
        GameEngine.initialize();
        self.revertThreshold = threshold;
    }

    function scorePoint(side as Number, matchStatus as MatchStatus) as Boolean {
        var opponent = self.otherSide(side);
        var sideScore = self.getScoreForSide(side, matchStatus);
        var oppScore = self.getScoreForSide(opponent, matchStatus);

        if (sideScore == 40 && oppScore == 40 && matchStatus.getDeuceRevertCount() >= self.revertThreshold) {
            return true; // decisive point
        }
        if (oppScore == 'A') {
            matchStatus.setDeuce();
            return false;
        }
        if (sideScore == 'A' || (sideScore == 40 && oppScore != 40)) {
            return true;
        }
        self.incScoreForSide(side, matchStatus);
        return false;
    }
}

// Silver point: one advantage; if we revert to deuce, the next point is golden.
class SilverPointGameEngine extends LimitedAdvantageGameEngine {

    function initialize() {
        LimitedAdvantageGameEngine.initialize(1);
    }
}

// FIP Star point: up to two advantage cycles; after second revert, next point is Star Point.
class StarPointGameEngine extends LimitedAdvantageGameEngine {

    function initialize() {
        LimitedAdvantageGameEngine.initialize(2);
    }
}
