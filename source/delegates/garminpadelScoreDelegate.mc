import Toybox.Lang;
import Toybox.WatchUi;
import Toybox.ActivityMonitor;

class garminpadelScoreDelegate extends WatchUi.InputDelegate {

    function initialize() {
        InputDelegate.initialize();
    }

    function onKey(keyEvent as WatchUi.KeyEvent) as Boolean {

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
                var message = "Finish Activity?";
                var dialog = new WatchUi.Confirmation(message);
                WatchUi.pushView(
                    dialog,
                    new FinishConfirmationDelegate(),
                    WatchUi.SLIDE_IMMEDIATE
                );
            }
            case KEY_MENU: {
                break;
            }
            case KEY_CLOCK: {
                break;
            }
        }

        WatchUi.requestUpdate();

        return true;
    }

}