import Toybox.Application;
import Toybox.Lang;
import Toybox.WatchUi;

// Warm-up setup choice. "Yes": the match starts in a warm-up phase recorded as its own lap (lap 1);
// the first Up/Down press starts the match without scoring. "No": scoring starts at once, as before.
// Custom flow: its own step after the score rule. Presets: a toggle line on the confirm screen.
class MenuWarmUpDelegate extends WatchUi.Menu2InputDelegate {

    // Default for both flows. Flip to false to keep the old behaviour (first press scores) for everyone.
    static const WARM_UP_DEFAULT = true;

    static const TOGGLE_ITEM_ID = :mode_warm_up;

    // Custom flow step: Warm-up Yes / No, then First serve.
    static function pushMenu() as Void {
        var menu = new WatchUi.Menu2({
            :title=>Application.loadResource(Rez.Strings.warm_up) as String,
            :focus=>WARM_UP_DEFAULT ? 0 : 1
        });
        menu.addItem(new MenuItem(Application.loadResource(Rez.Strings.warm_up_yes) as String, Application.loadResource(Rez.Strings.warm_up_yes_sub) as String, :warm_up_yes, {}));
        menu.addItem(new MenuItem(Application.loadResource(Rez.Strings.warm_up_no) as String, Application.loadResource(Rez.Strings.warm_up_no_sub) as String, :warm_up_no, {}));
        WatchUi.pushView(menu, new MenuWarmUpDelegate(), WatchUi.SLIDE_BLINK);
    }

    // Preset confirm screen line, "Warm-up: Yes / No"; selecting it flips the choice.
    static function toggleItem() as MenuItem {
        return new MenuItem(toggleLabel(), Application.loadResource(Rez.Strings.warm_up_toggle_sub) as String, TOGGLE_ITEM_ID, {});
    }

    static function toggle(item as MenuItem) as Void {
        var config = Application.getApp().getMatchConfig();
        config.setWarmUp(!config.getWarmUp());
        item.setLabel(toggleLabel());
        WatchUi.requestUpdate();
    }

    private static function toggleLabel() as String {
        var rez = Application.getApp().getMatchConfig().getWarmUp() ? Rez.Strings.warm_up_on : Rez.Strings.warm_up_off;
        return Application.loadResource(rez) as String;
    }

    function initialize() {
        Menu2InputDelegate.initialize();
    }

    function onSelect(item as MenuItem) as Void {
        Application.getApp().getMatchConfig().setWarmUp(item.getId() == :warm_up_yes);
        MenuFirstServeDelegate.pushMenu();
    }
}
