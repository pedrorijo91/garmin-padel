import Toybox.Lang;
import Toybox.System;
import Toybox.WatchUi;

class menuSuperTieDelegate extends WatchUi.MenuInputDelegate {

    function initialize() {
        MenuInputDelegate.initialize();
    }

    function onMenuItem(item as Symbol) as Void {
        
        var superTie = false;
        if (item == :super_tie_yes) {
            superTie = true;
        } else if (item == :super_tie_no) {
            superTie = false;
        }

        Application.getApp().getMatchConfig().setSuperTie(superTie);
        Application.getApp().initMatch();
        WatchUi.pushView(new scoreView(), new scoreDelegate(), WatchUi.SLIDE_UP);
    }

}