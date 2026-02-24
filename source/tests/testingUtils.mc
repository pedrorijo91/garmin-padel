import Toybox.Lang;

function getConfig() as MatchConfig {
    var matchConfig = new MatchConfig();
    matchConfig.setGoldenPoint(true);
    matchConfig.setNumberOfSets(3);
    matchConfig.setSuperTie(true);
    return matchConfig;
}

function getAdvConfig() as MatchConfig {
    var matchConfig = getConfig();
    matchConfig.setGoldenPoint(false);
    return matchConfig;
}

// Play n points for P1 (calls match.incP1() n times). Use for setup when order does not matter.
function playPointsP1(match as PadelMatch, n as Number) as Void {
    for (var i = 0; i < n; i++) {
        match.incP1();
    }
}

// Play n points for P2 (calls match.incP2() n times). Use for setup when order does not matter.
function playPointsP2(match as PadelMatch, n as Number) as Void {
    for (var i = 0; i < n; i++) {
        match.incP2();
    }
}

// Play a full set to p1Games - p2Games (no tie-break). Each game is 4 points.
// E.g. playSet(match, 6, 0) => 6-0 set for P1; playSet(match, 0, 6) => 0-6 set for P2.
function playSet(match as PadelMatch, p1Games as Number, p2Games as Number) as Void {
    playPointsP1(match, p1Games * 4);
    playPointsP2(match, p2Games * 4);
}

// Play until the current set is 6-6 in games (alternates games so the set is not won). Use before tie-break.
function playSetTo6All(match as PadelMatch) as Void {
    for (var g = 0; g < 6; g++) {
        playPointsP1(match, 4);
        playPointsP2(match, 4);
    }
}

// Play tie-break points assuming score is already 6-6. Plays p1Tie points for P1 then p2Tie for P2.
// E.g. playTieBreak(match, 5, 7) => P2 wins tie 7-5.
function playTieBreak(match as PadelMatch, p1Tie as Number, p2Tie as Number) as Void {
    playPointsP1(match, p1Tie);
    playPointsP2(match, p2Tie);
}

// Play super tie-break points assuming sets are 1-1 (or deciding set). Plays p1Points for P1 then p2Points for P2.
// E.g. playSuperTieBreak(match, 8, 10) => P2 wins super tie 10-8.
function playSuperTieBreak(match as PadelMatch, p1Points as Number, p2Points as Number) as Void {
    playPointsP1(match, p1Points);
    playPointsP2(match, p2Points);
}

function printMatchStatus(status as MatchStatus) as String {
    return 
        "P1Sets=" + status.getP1Sets() + 
        ",P2Sets=" + status.getP2Sets() + 
        ",P1Games=" + status.getP1Games() + 
        ",P2Games=" + status.getP2Games() + 
        ",P1Score=" + status.getP1Score() + 
        ",P2Score=" + status.getP2Score() + 
        ",P1TieScore=" + status.getP1TieScore() + 
        ",P2TieScore=" + status.getP2TieScore() +
        ",history=" + status.getHistoricalScores();
}
