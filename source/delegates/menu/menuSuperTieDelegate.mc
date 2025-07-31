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
        Application.getApp().initMatch();
        WatchUi.pushView(new ScoreView(), new ScoreDelegate(), WatchUi.SLIDE_UP);
    }

}