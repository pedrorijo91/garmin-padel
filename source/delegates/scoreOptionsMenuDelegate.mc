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
        } else if (item.getId() == :score_option_unforced_error) {
            WatchUi.popView(WatchUi.SLIDE_IMMEDIATE);
            Application.getApp().getMatch().addUnforcedError();
        } else if (item.getId() == :score_option_finish) {
            WatchUi.popView(WatchUi.SLIDE_IMMEDIATE);
            var score = Application.getApp().getScoreString();
            var menu = new WatchUi.Menu2({:title=>"Finish Activity"});
            menu.addItem(
                new MenuItem("Save and exit", score, :finish_save_exit, {})
            );
            menu.addItem(
                new MenuItem("Discard", "Don't save activity", :finish_discard, {})
            );
            menu.addItem(
                new MenuItem("Cancel", "Back to score", :finish_cancel, {})
            );
            WatchUi.pushView(menu, new FinishActivityMenuDelegate(), WatchUi.SLIDE_IMMEDIATE);
        }
    }

}
