import Toybox.Lang;
import Toybox.WatchUi;

// Confirmation screen after selecting a preset game mode.
// Shows the configuration summary; START/ENTER asks who serves first, then begins the match, BACK returns to the mode menu.
class MenuGameModeConfirmDelegate extends WatchUi.Menu2InputDelegate {

    function initialize() {
        Menu2InputDelegate.initialize();
    }

    function onSelect(item as MenuItem) as Void {
        if (item.getId() != :mode_start_confirm) {
            return;
        }
        // MatchConfig was already populated in MenuGameModeDelegate. Last step: who serves first (starts the match).
        MenuFirstServeDelegate.pushMenu();
    }
}

