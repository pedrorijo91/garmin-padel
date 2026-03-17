import Toybox.Lang;

// Preset game modes and mapping to MatchConfig.
class GameModes {

    static const MODE_TOURNAMENT = :mode_tournament;
    static const MODE_TOURNAMENT_SUPER = :mode_tournament_super;
    static const MODE_PRO_SET_TOURNAMENT = :mode_pro_set_tournament;
    static const MODE_FRIENDLY = :mode_friendly;
    static const MODE_CUSTOM = :mode_custom;

    // Returns a new MatchConfig for the given preset, or null for Custom.
    static function configForMode(modeId as Symbol) as MatchConfig or Null {
        if (modeId == MODE_TOURNAMENT) {
            var c = new MatchConfig();
            c.setNumberOfSets(3);
            c.setSetType(MatchConfig.SET_TYPE_NORMAL);
            c.setSuperTie(false);
            c.setPointRule(MatchConfig.POINT_RULE_GOLDEN);
            return c;
        }
        if (modeId == MODE_TOURNAMENT_SUPER) {
            var c = new MatchConfig();
            c.setNumberOfSets(3);
            c.setSetType(MatchConfig.SET_TYPE_NORMAL);
            c.setSuperTie(true);
            c.setPointRule(MatchConfig.POINT_RULE_GOLDEN);
            return c;
        }
        if (modeId == MODE_PRO_SET_TOURNAMENT) {
            var c = new MatchConfig();
            c.setNumberOfSets(1);
            c.setSetType(MatchConfig.SET_TYPE_PRO);
            c.setSuperTie(false);
            c.setPointRule(MatchConfig.POINT_RULE_GOLDEN);
            return c;
        }
        if (modeId == MODE_FRIENDLY) {
            var c = new MatchConfig();
            c.setNumberOfSets(MatchConfig.UNLIMITED_SETS);
            c.setSetType(MatchConfig.SET_TYPE_NORMAL);
            c.setSuperTie(false);
            c.setPointRule(MatchConfig.POINT_RULE_GOLDEN);
            return c;
        }
        return null;
    }

    static function title(modeId as Symbol) as String {
        if (modeId == MODE_TOURNAMENT) {
            return "Tournament";
        }
        if (modeId == MODE_TOURNAMENT_SUPER) {
            return "Tournament (super)";
        }
        if (modeId == MODE_PRO_SET_TOURNAMENT) {
            return "Pro Set Tournament";
        }
        if (modeId == MODE_FRIENDLY) {
            return "Friendly";
        }
        return "Game Mode";
    }

    static function summaryLines(modeId as Symbol) as Array<String> {
        if (modeId == MODE_TOURNAMENT) {
            return ["Sets: 3", "Set type: Normal", "Super tie: No", "Score: Golden Point"];
        }
        if (modeId == MODE_TOURNAMENT_SUPER) {
            return ["Sets: 3", "Set type: Normal", "Super tie: Yes", "Score: Golden Point"];
        }
        if (modeId == MODE_PRO_SET_TOURNAMENT) {
            return ["Sets: 1", "Set type: Pro set", "Super tie: No", "Score: Golden Point"];
        }
        if (modeId == MODE_FRIENDLY) {
            return ["Sets: Unlimited", "Set type: Normal", "Super tie: No", "Score: Golden Point"];
        }
        return ["", "", "", ""];
    }
}

