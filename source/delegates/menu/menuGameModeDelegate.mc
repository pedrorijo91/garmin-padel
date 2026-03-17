import Toybox.Lang;
import Toybox.WatchUi;

class MenuGameModeDelegate extends WatchUi.Menu2InputDelegate {

    function initialize() {
        Menu2InputDelegate.initialize();
    }

    function onSelect(item as MenuItem) as Void {
        var idObj = item.getId();
        if (idObj == null) {
            return;
        }
        var id = idObj as Symbol;

        if (id == GameModes.MODE_CUSTOM) {
            // Go into the existing custom configuration flow: Sets -> Set Type -> (Super Tie) -> Score.
            pushSetsMenu();
            return;
        }

        var presetConfig = GameModes.configForMode(id);
        if (presetConfig != null) {
            var appConfig = Application.getApp().getMatchConfig();
            appConfig.setNumberOfSets(presetConfig.getNumberOfSets());
            appConfig.setSetType(presetConfig.getSetType());
            appConfig.setSuperTie(presetConfig.getSuperTie());
            appConfig.setPointRule(presetConfig.getPointRule());
            var lines = GameModes.summaryLines(id);
            self.pushModeConfirmMenu(
                GameModes.title(id),
                lines[0],
                lines[1],
                lines[2],
                lines[3]
            );
        }
    }

    private function pushSetsMenu() as Void {
        var menu = new WatchUi.Menu2({:title=>"Sets"});
        menu.addItem(new MenuItem("1", "", :sets_1, {}));
        menu.addItem(new MenuItem("3", "", :sets_3, {}));
        menu.addItem(new MenuItem("5", "", :sets_5, {}));
        menu.addItem(new MenuItem("Unlimited", "", :sets_unlimited, {}));
        WatchUi.pushView(menu, new MenuNumberSetsDelegate(), WatchUi.SLIDE_BLINK);
    }

    private function pushModeConfirmMenu(title as String, line1 as String, line2 as String, line3 as String, line4 as String) as Void {
        var menu = new WatchUi.Menu2({:title=>title});
        menu.addItem(new MenuItem(line1, "", :mode_info_1, {}));
        menu.addItem(new MenuItem(line2, "", :mode_info_2, {}));
        menu.addItem(new MenuItem(line3, "", :mode_info_3, {}));
        menu.addItem(new MenuItem(line4, "", :mode_info_4, {}));
        menu.addItem(new MenuItem("Start match", "Press ENTER/START", :mode_start_confirm, {}));
        WatchUi.pushView(menu, new MenuGameModeConfirmDelegate(), WatchUi.SLIDE_BLINK);
    }
}

