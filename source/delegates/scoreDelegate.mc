import Toybox.Lang;
import Toybox.WatchUi;
import Toybox.ActivityMonitor;

class scoreDelegate extends WatchUi.InputDelegate {

    function initialize() {
        InputDelegate.initialize();
    }

    function onKey(keyEvent as WatchUi.KeyEvent) as Boolean {

        var match = Application.getApp().getMatch();

        switch (keyEvent.getKey()) {
            case KEY_UP: {
                var endOfMatch = match.incP1();

                if (endOfMatch) {
                    WatchUi.pushView(new endView(), new endOfMatchDelegate(), WatchUi.SLIDE_UP);
                }
                
                break;
            }
            case KEY_DOWN: {
                var endOfMatch = match.incP2();

                if (endOfMatch) {
                    WatchUi.pushView(new endView(), new endOfMatchDelegate(), WatchUi.SLIDE_UP);
                }

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