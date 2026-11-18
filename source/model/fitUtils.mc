import Toybox.Lang;

// FIT string fields are created with :count => 50, which includes the null terminator.
const FIT_STRING_MAX = 49;
// Training lap score field ("TB [12-10]", "MS 7-6 (10)", "Free"): 15 characters plus the terminator.
const LAP_STRING_MAX = 15;

// A longer string makes setData fail with a System Error ("setData string too long for allocated space")
// that try/catch can't catch: the app stops and the activity isn't saved. Checked in the simulator:
// 49 characters work, 50 crash. So cut the string before writing it, keeping the start (the earliest sets).
// The cut is made before a " / " separator, so only complete set results are kept (never "... / 6").
// Assumes ASCII (one byte per character), which the score always is.
function fitString(s as String, max as Number) as String {
    if (s.length() <= max) {
        return s;
    }
    // end of the last complete result that fits: the position of a separator at or before max
    var end = 0;
    var offset = 0;
    while (true) {
        var idx = (s.substring(offset, s.length()) as String).find(" / ");
        if (idx == null || offset + idx > max) {
            break;
        }
        end = offset + idx;
        offset = end + 3;
    }
    if (end == 0) {
        // a single result longer than max (not expected): plain cut
        end = max;
    }
    return s.substring(0, end) as String;
}


// The score shown in the finish menu and end screen and saved in game_score, e.g. "6-4 / 3-6 / [10-8]".
// Training: "Drills 2-1: TB [7-5] / ST [8-10] / MS 6-4" (drills won by us - them, then each drill's result).
function scoreString(match as PadelMatch) as String {
    var historicalScores = match.getHistoricalScores();
    var score = "";
    for (var i = 0; i < historicalScores.size(); i++) {
        score += (i > 0 ? " / " : "") + historicalScores[i];
    }
    if (match.isTraining()) {
        var status = match.getMatchStatus();
        var drills = "Drills " + status.getP1Sets() + "-" + status.getP2Sets();
        score = historicalScores.size() > 0 ? drills + ": " + score : drills;
    }
    return score;
}
