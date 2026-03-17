import Toybox.Lang;
import Toybox.WatchUi;

class MenuSetTypeDelegate extends WatchUi.Menu2InputDelegate {

    function initialize() {
        Menu2InputDelegate.initialize();
    }

    function onSelect(item as MenuItem) as Void {
        var setType = MatchConfig.SET_TYPE_NORMAL;
        var id = item.getId();
        if (id == :set_type_pro) {
            setType = MatchConfig.SET_TYPE_PRO;
        } else if (id == :set_type_mini) {
            setType = MatchConfig.SET_TYPE_MINI;
        }
        Application.getApp().getMatchConfig().setSetType(setType);

        var nbrSets = Application.getApp().getMatchConfig().getNumberOfSets();
        if (nbrSets == 3 || nbrSets == 5) {
            var menu = new WatchUi.Menu2({:title=>"Super Tie"});
            menu.addItem(new MenuItem("Yes", "", :super_tie_yes, {}));
            menu.addItem(new MenuItem("No", "", :super_tie_no, {}));
            WatchUi.pushView(menu, new MenuSuperTieDelegate(), WatchUi.SLIDE_BLINK);
        } else {
            pushScoreMenu();
        }
    }

    private function pushScoreMenu() as Void {
        var menu = new WatchUi.Menu2({:title=>"Score"});
        menu.addItem(new MenuItem("Golden Point", "", :point_rule_golden, {}));
        menu.addItem(new MenuItem("Star Point", "", :point_rule_star, {}));
        menu.addItem(new MenuItem("Advantages", "", :point_rule_advantage, {}));
        menu.addItem(new MenuItem("Silver Point", "", :point_rule_silver, {}));
        WatchUi.pushView(menu, new MenuScoreDelegate(), WatchUi.SLIDE_BLINK);
    }
}
