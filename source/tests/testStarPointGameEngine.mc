import Toybox.Lang;
import Toybox.Test;

// Star point (FIP: two advantage cycles then golden point)

(:test)
function starPoint_atFirstDeuce_advantageNormal(logger as Logger) as Boolean {
    var engine = new StarPointGameEngine();
    var status = statusDeuce();
    var won = engine.scorePoint(Sides.SIDE_P1, status);
    return won == false && status.getP1Score() == 'A' && status.getP2Score() == 40;
}

(:test)
function starPoint_afterOneRevert_stillAdvantageNotStar(logger as Logger) as Boolean {
    var engine = new StarPointGameEngine();
    var status = statusDeuceWithRevertCount(1);
    var won = engine.scorePoint(Sides.SIDE_P1, status);
    return won == false && status.getP1Score() == 'A' && status.getP2Score() == 40;
}

(:test)
function starPoint_afterTwoReverts_nextPointWinsStarPoint(logger as Logger) as Boolean {
    var engine = new StarPointGameEngine();
    var status = statusDeuceWithRevertCount(2);
    var wonP1 = engine.scorePoint(Sides.SIDE_P1, status);
    return wonP1 == true;
}

(:test)
function starPoint_afterTwoReverts_p2WinsStarPoint(logger as Logger) as Boolean {
    var engine = new StarPointGameEngine();
    var status = statusDeuceWithRevertCount(2);
    var won = engine.scorePoint(Sides.SIDE_P2, status);
    return won == true;
}

(:test)
function starPoint_fullSequence_twoRevertsThenP1Wins(logger as Logger) as Boolean {
    var engine = new StarPointGameEngine();
    var status = statusDeuce();
    engine.scorePoint(Sides.SIDE_P1, status);
    engine.scorePoint(Sides.SIDE_P2, status);
    engine.scorePoint(Sides.SIDE_P2, status);
    engine.scorePoint(Sides.SIDE_P1, status);
    var won = engine.scorePoint(Sides.SIDE_P1, status);
    return won == true;
}

(:test)
function starPoint_at40_30_p1WinsGame(logger as Logger) as Boolean {
    var engine = new StarPointGameEngine();
    var hist = [];
    var status = new MatchStatus(0, 0, 0, 0, 3, 2, 0, 0, hist);
    var won = engine.scorePoint(Sides.SIDE_P1, status);
    return won == true;
}

