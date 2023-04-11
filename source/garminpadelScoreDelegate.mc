import Toybox.Lang;
import Toybox.WatchUi;

class garminpadelScoreDelegate extends WatchUi.InputDelegate {

    private var match;

    function initialize() {
        InputDelegate.initialize();
        
        match = new padelMatch();
    }

    function onKey(keyEvent as WatchUi.KeyEvent) as Boolean {
//        System.println("garminpadelScoreDelegate::onKey " + keyEvent.getKey());

        switch (keyEvent.getKey()) {
            case KEY_UP: {
                self.match.incP1();
                break;
            }
            case KEY_DOWN: {
                self.match.incP2();
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

        self.match.printScore();

        return true;
    }

}