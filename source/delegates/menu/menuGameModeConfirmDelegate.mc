import Toybox.Lang;
import Toybox.WatchUi;

// Confirmation screen after selecting a preset game mode.
// Shows the configuration summary; START/ENTER asks who serves first, then begins the match, BACK returns to the mode menu.
class MenuGameModeConfirmDelegate extends WatchUi.Menu2InputDelegate {

    function initialize() {
        Menu2InputDelegate.initialize();
    }

    function onSelect(item as MenuItem) as Void {
        if (item.getId() == MenuWarmUpDelegate.TOGGLE_ITEM_ID) {
            MenuWarmUpDelegate.toggle(item);
            return;
        }
        if (item.getId() != :mode_start_confirm) {
            return;
        }
        // MatchConfig was already populated in MenuGameModeDelegate. Last step: who serves first (starts the match).
        // Training skips it: the serve marker is off until Options -> Switch server during a drill.
        if (Application.getApp().getMatchConfig().getTraining()) {
            MenuFirstServeDelegate.startMatch(-1);
            return;
        }
        MenuFirstServeDelegate.pushMenu();
    }
}

