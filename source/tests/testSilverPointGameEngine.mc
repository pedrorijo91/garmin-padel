import Toybox.Lang;
import Toybox.Test;

// Silver point (one advantage then golden at second deuce)

(:test)
function silverPoint_atFirstDeuce_p1GetsAdvantage(logger as Logger) as Boolean {
    var engine = new SilverPointGameEngine();
    var status = statusDeuce();
    var won = engine.scorePoint(Sides.SIDE_P1, status);
    return won == false && status.getP1Score() == 'A' && status.getP2Score() == 40;
}

(:test)
function silverPoint_afterOneRevert_nextPointWinsGame(logger as Logger) as Boolean {
    var engine = new SilverPointGameEngine();
    var status = statusDeuceWithRevertCount(1);
    var wonP1 = engine.scorePoint(Sides.SIDE_P1, status);
    return wonP1 == true;
}

(:test)
function silverPoint_afterOneRevert_p2WinsGolden(logger as Logger) as Boolean {
    var engine = new SilverPointGameEngine();
    var status = statusDeuceWithRevertCount(1);
    var won = engine.scorePoint(Sides.SIDE_P2, status);
    return won == true;
}

(:test)
function silverPoint_firstDeuce_thenRevert_thenP1WinsGolden(logger as Logger) as Boolean {
    var engine = new SilverPointGameEngine();
    var status = statusDeuce();
    engine.scorePoint(Sides.SIDE_P1, status);
    engine.scorePoint(Sides.SIDE_P2, status);
    var won = engine.scorePoint(Sides.SIDE_P1, status);
    return won == true;
}

(:test)
function silverPoint_at40_30_p1WinsGame(logger as Logger) as Boolean {
    var engine = new SilverPointGameEngine();
    var hist = [];
    var status = new MatchStatus(0, 0, 0, 0, 3, 2, 0, 0, hist);
    var won = engine.scorePoint(Sides.SIDE_P1, status);
    return won == true;
}

