import Toybox.Application;
import Toybox.Lang;
import Toybox.WatchUi;

// Last setup step (presets and custom flow): which team serves first. Starts the match.
// "Skip" leaves the serving team unknown, so no serving indicator is drawn.
class MenuFirstServeDelegate extends WatchUi.Menu2InputDelegate {

    static function pushMenu() as Void {
        var menu = new WatchUi.Menu2({:title=>Application.loadResource(Rez.Strings.first_serve_title) as String});
        menu.addItem(new MenuItem(Application.loadResource(Rez.Strings.serve_us) as String, Application.loadResource(Rez.Strings.first_serve_us_sub) as String, :first_serve_us, {}));
        menu.addItem(new MenuItem(Application.loadResource(Rez.Strings.serve_them) as String, Application.loadResource(Rez.Strings.first_serve_them_sub) as String, :first_serve_them, {}));
        menu.addItem(new MenuItem(Application.loadResource(Rez.Strings.first_serve_skip) as String, Application.loadResource(Rez.Strings.first_serve_skip_sub) as String, :first_serve_skip, {}));
        WatchUi.pushView(menu, new MenuFirstServeDelegate(), WatchUi.SLIDE_BLINK);
    }

    function initialize() {
        Menu2InputDelegate.initialize();
    }

    function onSelect(item as MenuItem) as Void {
        var id = item.getId();
        var side = -1;
        if (id == :first_serve_us) {
            side = Sides.SIDE_P1;
        } else if (id == :first_serve_them) {
            side = Sides.SIDE_P2;
        }
        startMatch(side);
    }

    // Starts recording and shows the score screen. side: first server, or -1 for no serve marker.
    static function startMatch(side as Number) as Void {
        var app = Application.getApp();
        app.initMatch();
        app.getMatch().setFirstServer(side);
        WatchUi.pushView(new ScoreView(), new ScoreDelegate(), WatchUi.SLIDE_UP);
    }
}
