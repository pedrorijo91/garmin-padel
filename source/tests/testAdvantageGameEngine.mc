import Toybox.Lang;
import Toybox.Test;

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

