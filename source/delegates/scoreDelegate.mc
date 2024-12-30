import Toybox.Lang;
import Toybox.WatchUi;
import Toybox.ActivityMonitor;

class ScoreDelegate extends WatchUi.InputDelegate {

    function initialize() {
        InputDelegate.initialize();
    }

    function onKey(keyEvent as WatchUi.KeyEvent) as Boolean {

        var match = Application.getApp().getMatch();

        switch (keyEvent.getKey()) {
            case KEY_UP: {
                var endOfMatch = match.incP1();

                if (endOfMatch) {
                    WatchUi.pushView(new EndView(), new EndOfMatchDelegate(), WatchUi.SLIDE_UP);
                }
                
                break;
            }
            case KEY_DOWN: {
                var endOfMatch = match.incP2();

                if (endOfMatch) {
                    WatchUi.pushView(new EndView(), new EndOfMatchDelegate(), WatchUi.SLIDE_UP);
                }

                break;
            }
            case KEY_ENTER: {
                var message = "Undo?";
                var dialog = new WatchUi.Confirmation(message);
                WatchUi.pushView(
                    dialog,
                    new UndoConfirmationDelegate(),
                    WatchUi.SLIDE_IMMEDIATE
                );
                break;
            }
            case KEY_ESC: {
                var score = Application.getApp().getScoreString();
                var message = "Finish Activity?\n" + score;
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

        // this ensures score gets updated as soon as key is processed
        WatchUi.requestUpdate();

        return true;
    }

    function onSwipe(swipeEvent) {
        // ignoring swipe events, so just returning handled=true to avoid other actions
        return true;
    }

}