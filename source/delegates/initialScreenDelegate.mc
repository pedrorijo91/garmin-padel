import Toybox.Lang;
import Toybox.WatchUi;

class InitialScreenDelegate extends WatchUi.InputDelegate {

    function initialize() {
        InputDelegate.initialize();
    }

    function onKey(keyEvent as WatchUi.KeyEvent) as Boolean {
        switch (keyEvent.getKey()) {
            case KEY_ESC: {
                System.exit();
            }
            case KEY_ENTER: {

                var menu = new WatchUi.Menu2({:title=>"Score"});
                menu.addItem(
                    new MenuItem(
                        "Golden Point",
                        "",
                        :golden_point_yes,
                        {}
                    )
                );
                menu.addItem(
                    new MenuItem(
                        "Advantages",
                        "",
                        :golden_point_no,
                        {}
                    )
                );
                WatchUi.pushView(menu, new MenuGoldenPointDelegate(), WatchUi.SLIDE_BLINK);
                break;
            }
        }
        
        return true;
    }

}