import Toybox.Lang;
import Toybox.System;
import Toybox.WatchUi;

class MenuNumberSetsDelegate extends WatchUi.Menu2InputDelegate {

    function initialize() {
        Menu2InputDelegate.initialize();
    }

    function onSelect(item as MenuItem) as Void {

        var nbrSets = MatchConfig.UNLIMITED_SETS;
        var id = item.getId();

        if (id != null) {
            if (id == :sets_1) {
                nbrSets = 1;
            } else if (id == :sets_3) {
                nbrSets = 3;
            } else if (id == :sets_5) {
                nbrSets = 5;
            }
            // else :sets_unlimited, nbrSets stays UNLIMITED_SETS
        }

        Application.getApp().getMatchConfig().setNumberOfSets(nbrSets);

        var menu = new WatchUi.Menu2({:title=>"Set Type"});
        menu.addItem(new MenuItem("Normal", "", :set_type_normal, {}));
        menu.addItem(new MenuItem("Pro Set", "", :set_type_pro, {}));
        menu.addItem(new MenuItem("Mini", "", :set_type_mini, {}));
        WatchUi.pushView(menu, new MenuSetTypeDelegate(), WatchUi.SLIDE_BLINK);
    }

}