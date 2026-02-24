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
                showFinishDialog();
            }
        }
        return true;
    }

    function onTap(clickEvent as WatchUi.ClickEvent) as Boolean {
        showFinishDialog();
        return true;
    }

    private function showFinishDialog() as Void {
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