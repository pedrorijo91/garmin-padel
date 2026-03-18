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
        var menu = new WatchUi.Menu2({:title=>"Game Mode"});
        menu.addItem(new MenuItem("Tournament", "", GameModes.MODE_TOURNAMENT, {}));
        menu.addItem(new MenuItem("Tournament (super)", "", GameModes.MODE_TOURNAMENT_SUPER, {}));
        menu.addItem(new MenuItem("Pro Set Tournament", "", GameModes.MODE_PRO_SET_TOURNAMENT, {}));
        menu.addItem(new MenuItem("Friendly", "", GameModes.MODE_FRIENDLY, {}));
        menu.addItem(new MenuItem("Custom", "", GameModes.MODE_CUSTOM, {}));
        WatchUi.pushView(menu, new MenuGameModeDelegate(), WatchUi.SLIDE_BLINK);
    }

}