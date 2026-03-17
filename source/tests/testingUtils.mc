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

// --- Helpers for unit tests (engines + MatchStatus) ---

// MatchStatus at 40-40 (score indices 3,3)
function statusDeuce() as MatchStatus {
    var hist = [];
    return new MatchStatus(0, 0, 0, 0, 3, 3, 0, 0, hist);
}

// MatchStatus at P1 advantage (A-40)
function statusP1Advantage() as MatchStatus {
    var hist = [];
    return new MatchStatus(0, 0, 0, 0, 4, 3, 0, 0, hist);
}

// MatchStatus at P2 advantage (40-A)
function statusP2Advantage() as MatchStatus {
    var hist = [];
    return new MatchStatus(0, 0, 0, 0, 3, 4, 0, 0, hist);
}

// MatchStatus at 40-40 with given deuce revert count (for Silver: 1 = golden next; Star: 2 = star point next).
function statusDeuceWithRevertCount(count as Number) as MatchStatus {
    var hist = [];
    var status = new MatchStatus(0, 0, 0, 0, 3, 3, 0, 0, hist);
    status.setDeuceRevertCount(count);
    return status;
}

// Play one full game (4 points) for the given side (golden point).
function playOneGame(engine as SetEngine, side as Number, status as MatchStatus) as Void {
    for (var i = 0; i < 4; i++) {
        engine.scorePoint(side, status);
    }
}

// Play n full games for the given side (each game = 4 points with golden point).
function playNGames(engine as SetEngine, side as Number, status as MatchStatus, n as Number) as Void {
    for (var g = 0; g < n; g++) {
        playOneGame(engine, side, status);
    }
}

// Play until set is 6-6 in games (alternate 6 games P1, 6 games P2). Use before tie-break.
function playSetTo6AllForEngine(engine as SetEngine, status as MatchStatus) as Void {
    for (var g = 0; g < 6; g++) {
        playOneGame(engine, Sides.SIDE_P1, status);
        playOneGame(engine, Sides.SIDE_P2, status);
    }
}

// Play until set is 8-8 in games (Pro Set). Use before tie-break.
function playSetTo8AllForEngine(engine as SetEngine, status as MatchStatus) as Void {
    for (var g = 0; g < 8; g++) {
        playOneGame(engine, Sides.SIDE_P1, status);
        playOneGame(engine, Sides.SIDE_P2, status);
    }
}

// From 2-2, play one game each to reach 3-3. Status must start at 2-2.
function playMiniSetTo3All(engine as SetEngine, status as MatchStatus) as Void {
    playOneGame(engine, Sides.SIDE_P1, status);
    playOneGame(engine, Sides.SIDE_P2, status);
}

// From 2-2, play 3 games each to reach 5-5 (Mini set tie-break). Status must start at 2-2.
function playMiniSetTo5All(engine as SetEngine, status as MatchStatus) as Void {
    for (var g = 0; g < 3; g++) {
        playOneGame(engine, Sides.SIDE_P1, status);
        playOneGame(engine, Sides.SIDE_P2, status);
    }
}

// At tie (6-6 or 8-8), play tie-break points: p1Points for P1 then p2Points for P2 (e.g. 7,5 => 7-5).
function playTieBreakPoints(engine as SetEngine, status as MatchStatus, p1Points as Number, p2Points as Number) as Void {
    for (var i = 0; i < p1Points; i++) {
        engine.scorePoint(Sides.SIDE_P1, status);
    }
    for (var i = 0; i < p2Points; i++) {
        engine.scorePoint(Sides.SIDE_P2, status);
    }
}

// Play super-tie points: p2Points for P2 then p1Points for P1 (e.g. 10, 8 => 10-8 for P1).
function playSuperTiePoints(engine as SuperTieSetEngine, status as MatchStatus, p1Points as Number, p2Points as Number) as Void {
    for (var i = 0; i < p2Points; i++) {
        engine.scorePoint(Sides.SIDE_P2, status);
    }
    for (var i = 0; i < p1Points; i++) {
        engine.scorePoint(Sides.SIDE_P1, status);
    }
}

// Play one game with advantage rules: 40-40 then P1 advantage then P1 wins (5 points P1, 3 P2).
function playOneGameP1WinsWithAdvantage(engine as SetEngine, status as MatchStatus) as Void {
    engine.scorePoint(Sides.SIDE_P1, status);
    engine.scorePoint(Sides.SIDE_P1, status);
    engine.scorePoint(Sides.SIDE_P1, status);
    engine.scorePoint(Sides.SIDE_P2, status);
    engine.scorePoint(Sides.SIDE_P2, status);
    engine.scorePoint(Sides.SIDE_P2, status);
    engine.scorePoint(Sides.SIDE_P1, status);
    engine.scorePoint(Sides.SIDE_P1, status);
}

// Play one game with advantage rules: 40-40, P1 advantage, P2 back to deuce, P2 advantage, P2 wins (4 P1, 6 P2).
function playOneGameP2WinsWithAdvantage(engine as SetEngine, status as MatchStatus) as Void {
    engine.scorePoint(Sides.SIDE_P1, status);
    engine.scorePoint(Sides.SIDE_P1, status);
    engine.scorePoint(Sides.SIDE_P1, status);
    engine.scorePoint(Sides.SIDE_P2, status);
    engine.scorePoint(Sides.SIDE_P2, status);
    engine.scorePoint(Sides.SIDE_P2, status);
    engine.scorePoint(Sides.SIDE_P1, status);
    engine.scorePoint(Sides.SIDE_P2, status);
    engine.scorePoint(Sides.SIDE_P2, status);
    engine.scorePoint(Sides.SIDE_P2, status);
}
