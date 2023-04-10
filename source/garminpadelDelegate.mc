import Toybox.Lang;
import Toybox.WatchUi;

class garminpadelDelegate extends WatchUi.BehaviorDelegate {

    function initialize() {
        BehaviorDelegate.initialize();
    }

    function onMenu() as Boolean {
        WatchUi.pushView(new Rez.Menus.MainMenu(), new garminpadelMenuDelegate(), WatchUi.SLIDE_UP);
        return true;
    }

}