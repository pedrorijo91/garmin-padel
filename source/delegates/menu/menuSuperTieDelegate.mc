import Toybox.Lang;
import Toybox.System;
import Toybox.WatchUi;

class MenuSuperTieDelegate extends WatchUi.Menu2InputDelegate {

    function initialize() {
        Menu2InputDelegate.initialize();
    }

    function onSelect(item as MenuItem) as Void {
        var superTie = false;
        if (item.getId() == :super_tie_yes) {
            superTie = true;
        } else if (item.getId() == :super_tie_no) {
            superTie = false;
        }

        Application.getApp().getMatchConfig().setSuperTie(superTie);

        var menu = new WatchUi.Menu2({:title=>"Score"});
        menu.addItem(new MenuItem("Golden Point", "", :point_rule_golden, {}));
        menu.addItem(new MenuItem("Star Point", "", :point_rule_star, {}));
        menu.addItem(new MenuItem("Advantages", "", :point_rule_advantage, {}));
        menu.addItem(new MenuItem("Silver Point", "", :point_rule_silver, {}));
        WatchUi.pushView(menu, new MenuScoreDelegate(), WatchUi.SLIDE_BLINK);
    }
}