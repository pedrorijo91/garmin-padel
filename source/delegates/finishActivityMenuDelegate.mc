import Toybox.Lang;
import Toybox.WatchUi;
using Toybox.System;

class FinishActivityMenuDelegate extends WatchUi.Menu2InputDelegate {

    function initialize() {
        Menu2InputDelegate.initialize();
    }

    function onSelect(item as MenuItem) as Void {
        if (item.getId() == :finish_save_exit) {
            WatchUi.popView(WatchUi.SLIDE_IMMEDIATE);
            Application.getApp().saveSession();
            System.exit();
        } else if (item.getId() == :finish_discard) {
            WatchUi.popView(WatchUi.SLIDE_IMMEDIATE);
            Application.getApp().discardSession();
            System.exit();
        } else if (item.getId() == :finish_cancel) {
            // just close the menu and go back
            WatchUi.popView(WatchUi.SLIDE_IMMEDIATE);
        }
    }
}

