import Toybox.Lang;
import Toybox.WatchUi;

class garminpadelScoreDelegate extends WatchUi.InputDelegate {

    function initialize() {
        InputDelegate.initialize();
    }

    function onKey(keyEvent as WatchUi.KeyEvent) as Boolean {
//        System.println("garminpadelScoreDelegate::onKey " + keyEvent.getKey());

        var match = Application.getApp().getMatch();

        switch (keyEvent.getKey()) {
            case KEY_UP: {
                match.incP1();
                break;
            }
            case KEY_DOWN: {
                match.incP2();
                break;
            }
            case KEY_ENTER: {
                break;
            }
            case KEY_ESC: {
                break;
            }
            case KEY_MENU: {
                break;
            }
            case KEY_CLOCK: {
                break;
            }
        }

        match.printScore();
        WatchUi.requestUpdate();

        return true;
    }

}