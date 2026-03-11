import Toybox.Lang;

// Base class for point-by-point game scoring (within a single game).
// Subclasses implement deuce/golden point/advantage rules.
// Stateless: receives MatchStatus, mutates only current game points, returns true if game won.
class GameEngine {

    static const SIDE_P1 = 0;
    static const SIDE_P2 = 1;

    function initialize() {
    }

    // Apply one point for the given side. Mutates matchStatus (scores only).
    // Returns true if the game is won by that side (caller must inc games and reset scores).
    function scorePoint(side as Number, matchStatus as MatchStatus) as Boolean {
        // Base: subclasses must override
        return false;
    }

    protected function getScoreForSide(side as Number, matchStatus as MatchStatus) as Object {
        if (side == SIDE_P1) {
            return matchStatus.getP1Score();
        }
        return matchStatus.getP2Score();
    }

    protected function incScoreForSide(side as Number, matchStatus as MatchStatus) as Void {
        if (side == SIDE_P1) {
            matchStatus.incP1Score();
        } else {
            matchStatus.incP2Score();
        }
    }

    protected function otherSide(side as Number) as Number {
        if (side == SIDE_P1) {
            return SIDE_P2;
        }
        return SIDE_P1;
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
