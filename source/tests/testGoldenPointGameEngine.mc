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

