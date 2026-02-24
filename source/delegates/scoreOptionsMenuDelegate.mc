import Toybox.Lang;
import Toybox.WatchUi;

class ScoreOptionsMenuDelegate extends WatchUi.Menu2InputDelegate {

    function initialize() {
        Menu2InputDelegate.initialize();
    }

    function onSelect(item as MenuItem) as Void {
        if (item.getId() == :score_option_cancel) {
            WatchUi.popView(WatchUi.SLIDE_IMMEDIATE);
        } else if (item.getId() == :score_option_undo) {
            WatchUi.popView(WatchUi.SLIDE_IMMEDIATE);
            var dialog = new WatchUi.Confirmation("Undo?");
            WatchUi.pushView(
                dialog,
                new UndoConfirmationDelegate(),
                WatchUi.SLIDE_IMMEDIATE
            );
        } else if (item.getId() == :score_option_finish) {
            WatchUi.popView(WatchUi.SLIDE_IMMEDIATE);
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

}
