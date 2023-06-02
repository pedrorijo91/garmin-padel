import Toybox.Lang;
import Toybox.WatchUi;

class initialScreenDelegate extends WatchUi.InputDelegate {

    function initialize() {
        InputDelegate.initialize();
    }

    function onKey(keyEvent as WatchUi.KeyEvent) as Boolean {

        switch (keyEvent.getKey()) {
            case KEY_ESC: {}
            case KEY_ENTER: {
                WatchUi.pushView(new Rez.Menus.SetsMenu(), new menuNumberSetsDelegate(), WatchUi.SLIDE_BLINK);
                break;
            }
        }
        
        return true;
    }

}