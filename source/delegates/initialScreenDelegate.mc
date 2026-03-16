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
        var menu = new WatchUi.Menu2({:title=>"Score"});
        menu.addItem(
            new MenuItem(
                "Golden Point",
                "",
                :point_rule_golden,
                {}
            )
        );
        menu.addItem(
            new MenuItem(
                "Star Point",
                "",
                :point_rule_star,
                {}
            )
        );
        menu.addItem(
            new MenuItem(
                "Advantages",
                "",
                :point_rule_advantage,
                {}
            )
        );
        menu.addItem(
            new MenuItem(
                "Silver Point",
                "",
                :point_rule_silver,
                {}
            )
        );
        WatchUi.pushView(menu, new MenuGoldenPointDelegate(), WatchUi.SLIDE_BLINK);
    }

}