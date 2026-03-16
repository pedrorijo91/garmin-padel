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

        if (Application.getApp().getMatchConfig().getNumberOfSets() != MatchConfig.UNLIMITED_SETS) {
            var menu = new WatchUi.Menu2({:title=>"Super Tie"});
            menu.addItem(new MenuItem("Yes", "", :super_tie_yes, {}));
            menu.addItem(new MenuItem("No", "", :super_tie_no, {}));
            WatchUi.pushView(menu, new MenuSuperTieDelegate(), WatchUi.SLIDE_BLINK);
        } else {
            Application.getApp().initMatch();
            WatchUi.pushView(new ScoreView(), new ScoreDelegate(), WatchUi.SLIDE_UP);
        }
    }
}
