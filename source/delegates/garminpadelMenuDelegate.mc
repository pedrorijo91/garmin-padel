import Toybox.Lang;
import Toybox.System;
import Toybox.WatchUi;

class garminpadelMenuDelegate extends WatchUi.MenuInputDelegate {

    function initialize() {
        System.println("garminpadelMenuDelegate::initialize");
        MenuInputDelegate.initialize();
    }

    function onMenuItem(item as Symbol) as Void {
        // https://developer.garmin.com/connect-iq/core-topics/native-controls/
        System.println("garminpadelMenuDelegate::onMenuItem");
        if (item == :item_1) {
            System.println("item 1");
        } else if (item == :item_2) {
            System.println("item 2");
        }
    }

}