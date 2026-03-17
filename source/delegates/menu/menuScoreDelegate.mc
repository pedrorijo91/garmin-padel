import Toybox.Lang;
import Toybox.WatchUi;

// Shown after Sets / Set type / Super Tie. User picks point rule at deuce; then match starts.
class MenuScoreDelegate extends WatchUi.Menu2InputDelegate {

    function initialize() {
        Menu2InputDelegate.initialize();
    }

    function onSelect(item as MenuItem) as Void {
        var rule = MatchConfig.POINT_RULE_GOLDEN;
        var id = item.getId();
        if (id == :point_rule_golden) {
            rule = MatchConfig.POINT_RULE_GOLDEN;
        } else if (id == :point_rule_advantage) {
            rule = MatchConfig.POINT_RULE_ADVANTAGE;
        } else if (id == :point_rule_silver) {
            rule = MatchConfig.POINT_RULE_SILVER;
        } else if (id == :point_rule_star) {
            rule = MatchConfig.POINT_RULE_STAR;
        }
        Application.getApp().getMatchConfig().setPointRule(rule);
        Application.getApp().initMatch();
        WatchUi.pushView(new ScoreView(), new ScoreDelegate(), WatchUi.SLIDE_UP);
    }
}
