import Toybox.Lang;
import Toybox.WatchUi;

class EndOfMatchDelegate extends WatchUi.InputDelegate {

    function initialize() {
        InputDelegate.initialize();
    }

    function onKey(keyEvent as WatchUi.KeyEvent) as Boolean {

        switch (keyEvent.getKey()) {
            case KEY_ESC: {}
            case KEY_ENTER: {
                var score = Application.getApp().getScoreString();
                var message = "Finish Activity?\n" + score;
                var dialog = new WatchUi.Confirmation(message);
                WatchUi.pushView(
                    dialog,
                    new ExitConfirmationDelegate(),
                    WatchUi.SLIDE_IMMEDIATE
                );
            }
        }
        
        return true;
    }

}