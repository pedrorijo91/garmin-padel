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
                showFinishMenu();
            }
        }
        return true;
    }

    function onTap(clickEvent as WatchUi.ClickEvent) as Boolean {
        showFinishMenu();
        return true;
    }

    private function showFinishMenu() as Void {
        var score = Application.getApp().getScoreString();
        var menu = new WatchUi.Menu2({:title=>"Finish Activity"});
        menu.addItem(
            new MenuItem("Save and exit", score, :finish_save_exit, {})
        );
        menu.addItem(
            new MenuItem("Discard", "Don't save activity", :finish_discard, {})
        );
        menu.addItem(
            new MenuItem("Cancel", "Back to summary", :finish_cancel, {})
        );
        WatchUi.pushView(menu, new FinishActivityMenuDelegate(), WatchUi.SLIDE_IMMEDIATE);
    }

}