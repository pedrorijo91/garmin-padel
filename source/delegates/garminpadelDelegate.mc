import Toybox.Lang;
import Toybox.WatchUi;

class garminpadelDelegate extends WatchUi.InputDelegate {

    function initialize() {
        InputDelegate.initialize();
    }

    function onKey(keyEvent as WatchUi.KeyEvent) as Boolean {

        /*
         TODO
            13 KEY_UP -> nothing for now
            8 KEY_DOWN -> nothing for now

            4 KEY_ENTER -> start (show scores)
            5 KEY_ESC -> save and leave?
        */

        WatchUi.pushView(new garminpadelScoreView(), new garminpadelScoreDelegate(), WatchUi.SLIDE_UP);
        
        return true;
    }

}