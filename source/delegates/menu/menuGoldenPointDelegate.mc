import Toybox.Lang;
import Toybox.System;
import Toybox.WatchUi;

class MenuGoldenPointDelegate extends WatchUi.Menu2InputDelegate {

    function initialize() {
        Menu2InputDelegate.initialize();
    }

    function onSelect(item as MenuItem) {
       var goldenPoint = true;
        if (item.getId() == :golden_point_yes) {
            goldenPoint = true;
        } else if (item.getId() == :golden_point_no) {
            goldenPoint = false;
        }

        Application.getApp().getMatchConfig().setGoldenPoint(goldenPoint);

         var menu = new WatchUi.Menu2({:title=>"Sets"});
                menu.addItem(
                    new MenuItem(
                        "Unlimited",
                        "",
                        :sets_unlimited,
                        {}
                    )
                );
                 menu.addItem(
                    new MenuItem(
                        "3",
                        "",
                        :sets_3,
                        {}
                    )
                );
                 menu.addItem(
                    new MenuItem(
                        "5",
                        "",
                        :sets_5,
                        {}
                    )
                );
                
        WatchUi.pushView(menu, new MenuNumberSetsDelegate(), WatchUi.SLIDE_BLINK);
    }

}