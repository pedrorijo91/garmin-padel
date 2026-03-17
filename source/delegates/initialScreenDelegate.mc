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
                openConfigMenu();
                break;
            }
        }

        return true;
    }

    function onTap(clickEvent as WatchUi.ClickEvent) as Boolean {
        openConfigMenu();
        return true;
    }

    private function openConfigMenu() as Void {
        var menu = new WatchUi.Menu2({:title=>"Sets"});
        menu.addItem(new MenuItem("1", "", :sets_1, {}));
        menu.addItem(new MenuItem("3", "", :sets_3, {}));
        menu.addItem(new MenuItem("5", "", :sets_5, {}));
        menu.addItem(new MenuItem("Unlimited", "", :sets_unlimited, {}));
        WatchUi.pushView(menu, new MenuNumberSetsDelegate(), WatchUi.SLIDE_BLINK);
    }

}