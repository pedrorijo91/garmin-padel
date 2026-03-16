import Toybox.Lang;
import Toybox.Test;

(:test)
function goldenPoint_atDeuce_p1WinsGame(logger as Logger) as Boolean {
    var engine = new GoldenPointGameEngine();
    var status = statusDeuce();
    var won = engine.scorePoint(Sides.SIDE_P1, status);
    return won == true;
}

(:test)
function goldenPoint_atDeuce_p2WinsGame(logger as Logger) as Boolean {
    var engine = new GoldenPointGameEngine();
    var status = statusDeuce();
    var won = engine.scorePoint(Sides.SIDE_P2, status);
    return won == true;
}

(:test)
function goldenPoint_midGame_pointAdded(logger as Logger) as Boolean {
    var engine = new GoldenPointGameEngine();
    var hist = [];
    var status = new MatchStatus(0, 0, 0, 0, 0, 0, 0, 0, hist);
    var won = engine.scorePoint(Sides.SIDE_P1, status);
    return won == false && status.getP1Score() == 15 && status.getP2Score() == 0;
}

(:test)
function goldenPoint_at40_pointWinsGame(logger as Logger) as Boolean {
    var engine = new GoldenPointGameEngine();
    var hist = [];
    var status = new MatchStatus(0, 0, 0, 0, 3, 2, 0, 0, hist); // 40-30 P1
    var won = engine.scorePoint(Sides.SIDE_P1, status);
    return won == true;
}

(:test)
function goldenPoint_at30_pointDoesNotWin(logger as Logger) as Boolean {
    var engine = new GoldenPointGameEngine();
    var hist = [];
    var status = new MatchStatus(0, 0, 0, 0, 2, 0, 0, 0, hist); // 30-0 P1
    var won = engine.scorePoint(Sides.SIDE_P1, status);
    return won == false && status.getP1Score() == 40 && status.getP2Score() == 0;
}

(:test)
function advantage_atDeuce_p1GetsAdvantage(logger as Logger) as Boolean {
    var engine = new AdvantageGameEngine();
    var status = statusDeuce();
    var won = engine.scorePoint(Sides.SIDE_P1, status);
    return won == false && status.getP1Score() == 'A' && status.getP2Score() == 40;
}

(:test)
function advantage_p1Advantage_p1WinsGame(logger as Logger) as Boolean {
    var engine = new AdvantageGameEngine();
    var status = statusP1Advantage();
    var won = engine.scorePoint(Sides.SIDE_P1, status);
    return won == true;
}

(:test)
function advantage_p1Advantage_p2RevertsToDeuce(logger as Logger) as Boolean {
    var engine = new AdvantageGameEngine();
    var status = statusP1Advantage();
    var won = engine.scorePoint(Sides.SIDE_P2, status);
    return won == false && status.getP1Score() == 40 && status.getP2Score() == 40;
}

(:test)
function advantage_at40_30_p1WinsGame(logger as Logger) as Boolean {
    var engine = new AdvantageGameEngine();
    var hist = [];
    var status = new MatchStatus(0, 0, 0, 0, 3, 2, 0, 0, hist); // 40-30
    var won = engine.scorePoint(Sides.SIDE_P1, status);
    return won == true;
}

(:test)
function advantage_p2Advantage_p2WinsGame(logger as Logger) as Boolean {
    var engine = new AdvantageGameEngine();
    var status = statusP2Advantage();
    var won = engine.scorePoint(Sides.SIDE_P2, status);
    return won == true;
}

(:test)
function advantage_atDeuce_p2GetsAdvantage(logger as Logger) as Boolean {
    var engine = new AdvantageGameEngine();
    var status = statusDeuce();
    var won = engine.scorePoint(Sides.SIDE_P2, status);
    return won == false && status.getP1Score() == 40 && status.getP2Score() == 'A';
}

// --- Silver point (one advantage then golden at second deuce) ---

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

// --- Star point (FIP: two advantage cycles then golden point) ---

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
