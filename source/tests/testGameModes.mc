import Toybox.Lang;
import Toybox.Test;

(:test)
function gameModes_tournamentPresetMapping(logger as Logger) as Boolean {
    var c = GameModes.configForMode(GameModes.MODE_TOURNAMENT) as MatchConfig;
    return c != null &&
        c.getNumberOfSets() == 3 &&
        c.getSetType() == MatchConfig.SET_TYPE_NORMAL &&
        c.getSuperTie() == false &&
        c.getPointRule() == MatchConfig.POINT_RULE_GOLDEN;
}

(:test)
function gameModes_tournamentSuperPresetMapping(logger as Logger) as Boolean {
    var c = GameModes.configForMode(GameModes.MODE_TOURNAMENT_SUPER) as MatchConfig;
    return c != null &&
        c.getNumberOfSets() == 3 &&
        c.getSetType() == MatchConfig.SET_TYPE_NORMAL &&
        c.getSuperTie() == true &&
        c.getPointRule() == MatchConfig.POINT_RULE_GOLDEN;
}

(:test)
function gameModes_proSetTournamentPresetMapping(logger as Logger) as Boolean {
    var c = GameModes.configForMode(GameModes.MODE_PRO_SET_TOURNAMENT) as MatchConfig;
    return c != null &&
        c.getNumberOfSets() == 1 &&
        c.getSetType() == MatchConfig.SET_TYPE_PRO &&
        c.getSuperTie() == false &&
        c.getPointRule() == MatchConfig.POINT_RULE_GOLDEN;
}

(:test)
function gameModes_friendlyPresetMapping(logger as Logger) as Boolean {
    var c = GameModes.configForMode(GameModes.MODE_FRIENDLY) as MatchConfig;
    return c != null &&
        c.getNumberOfSets() == MatchConfig.UNLIMITED_SETS &&
        c.getSetType() == MatchConfig.SET_TYPE_NORMAL &&
        c.getSuperTie() == false &&
        c.getPointRule() == MatchConfig.POINT_RULE_GOLDEN;
}

(:test)
function gameModes_customReturnsNull(logger as Logger) as Boolean {
    var c = GameModes.configForMode(GameModes.MODE_CUSTOM);
    return c == null;
}

