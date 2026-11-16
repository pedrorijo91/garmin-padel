import Toybox.Lang;

// Single source of truth for player/side identifiers used across GameEngine, SetEngine, MatchEngine.
class Sides {

    static const SIDE_P1 = 0;
    static const SIDE_P2 = 1;

    static function other(side as Number) as Number {
        return side == SIDE_P1 ? SIDE_P2 : SIDE_P1;
    }
}
