import Toybox.Lang;
import Toybox.System;
import Toybox.WatchUi;

class MenuGoldenPointDelegate extends WatchUi.Menu2InputDelegate {

    function initialize() {
        Menu2InputDelegate.initialize();
    }

    function onSelect(item as MenuItem) {
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

         var menu = new WatchUi.Menu2({:title=>"Sets"});
                menu.addItem(
                    new MenuItem(
                        "Unlimited",
                        "",
                        :sets_unlimited,
                        {}
                    )
                );
                 menu.addItem(
                    new MenuItem(
                        "3",
                        "",
                        :sets_3,
                        {}
                    )
                );
                 menu.addItem(
                    new MenuItem(
                        "5",
                        "",
                        :sets_5,
                        {}
                    )
                );
                
        WatchUi.pushView(menu, new MenuNumberSetsDelegate(), WatchUi.SLIDE_BLINK);
    }

}