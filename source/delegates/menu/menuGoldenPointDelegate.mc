import Toybox.Lang;
import Toybox.System;
import Toybox.WatchUi;

class MenuGoldenPointDelegate extends WatchUi.MenuInputDelegate {

    function initialize() {
        MenuInputDelegate.initialize();
    }

    function onMenuItem(item as Symbol) as Void {
        
        var goldenPoint = true;
        if (item == :golden_point_yes) {
            goldenPoint = true;
        } else if (item == :golden_point_no) {
            goldenPoint = false;
        }

        Application.getApp().getMatchConfig().setGoldenPoint(goldenPoint);

        if (goldenPoint == false) {
            WatchUi.pushView(new Rez.Menus.SetsMenu(), new MenuNumberSetsDelegate(), WatchUi.SLIDE_BLINK);
        } else {
            WatchUi.pushView(new Rez.Menus.DeucesMenu(), new MenuGoldenPointDeuceSettingsDelegate(), WatchUi.SLIDE_BLINK);
        }

    }

}
