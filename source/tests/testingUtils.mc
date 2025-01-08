import Toybox.Lang;

// FIXME use in tests
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

function incMatch(
        match as PadelMatch, 
        scoreP1 as Number, gamesP1 as Number, setsP1 as Number, 
        scoreP2 as Number, gamesP2 as Number, setsP2 as Number
    ) as Void {
        // FIXME implement and add better API methods
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