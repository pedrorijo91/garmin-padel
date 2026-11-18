import Toybox.Lang;
import Toybox.WatchUi;
import Toybox.System;
import Toybox.ActivityMonitor;

class ScoreDelegate extends WatchUi.InputDelegate {

    function initialize() {
        InputDelegate.initialize();
    }

    // Tap top half = P1 point (like KEY_UP), tap bottom half = P2 point (like KEY_DOWN).
    function onTap(clickEvent as WatchUi.ClickEvent) as Boolean {
        var coords = clickEvent.getCoordinates();
        var y = coords[1];
        var screenHeight = System.getDeviceSettings().screenHeight;
        var match = Application.getApp().getMatch();

        if (y < screenHeight / 2) {
            var endOfMatch = match.incP1();
            if (endOfMatch) {
                WatchUi.pushView(new EndView(), new EndOfMatchDelegate(), WatchUi.SLIDE_UP);
            }
        } else {
            var endOfMatch = match.incP2();
            if (endOfMatch) {
                WatchUi.pushView(new EndView(), new EndOfMatchDelegate(), WatchUi.SLIDE_UP);
            }
        }

        WatchUi.requestUpdate();
        return true;
    }

    // Long-press = options menu (Undo / Finish), for touch devices.
    function onHold(clickEvent as WatchUi.ClickEvent) as Boolean {
        pushOptionsMenu();
        return true;
    }

    // Options menu, opened with ENTER or a long-press.
    private function pushOptionsMenu() as Void {
        var match = Application.getApp().getMatch();
        if (match.isWarmingUp()) {
            pushWarmUpOptionsMenu();
            return;
        }
        if (match.isTraining()) {
            pushTrainingOptionsMenu(match);
            return;
        }
        var menu = new WatchUi.Menu2({:title=>"Options"});
        menu.addItem(
            new MenuItem("Undo last point", "", :score_option_undo, {})
        );
        menu.addItem(
            new MenuItem("Unforced error", "", :score_option_unforced_error, {})
        );
        menu.addItem(
            new MenuItem(
                Application.loadResource(Rez.Strings.switch_server) as String,
                servingSubLabel(),
                :score_option_switch_server,
                {}
            )
        );
        // Friendly and Custom only: play a tie-break / super tie / mini set now
        if (match.canSwitchSetFormat()) {
            var sub = match.isSetStarted()
                ? (Application.loadResource(Rez.Strings.switch_format_drops) as String) + match.currentSetResult()
                : Application.loadResource(Rez.Strings.switch_format_sub) as String;
            menu.addItem(
                new MenuItem(
                    Application.loadResource(Rez.Strings.switch_format) as String,
                    sub,
                    :score_option_switch_format,
                    {}
                )
            );
        }
        menu.addItem(
            new MenuItem("Finish activity", "", :score_option_finish, {})
        );
        menu.addItem(
            new MenuItem("Cancel", "Back to score", :score_option_cancel, {})
        );
        WatchUi.pushView(menu, new ScoreOptionsMenuDelegate(), WatchUi.SLIDE_IMMEDIATE);
    }

    // Options in training (plan 2). Free play: Start drill, Undo (only when there is something to undo, e.g.
    // right after End drill or a won drill), Unforced error, Finish. During a drill: End drill, Next drill,
    // Undo, Unforced error, Switch server (the serve marker is off until set here), Finish.
    private function pushTrainingOptionsMenu(match as PadelMatch) as Void {
        var menu = new WatchUi.Menu2({:title=>"Options"});
        var free = match.isFreePlay();
        if (free) {
            menu.addItem(new MenuItem(rez(Rez.Strings.start_drill), rez(Rez.Strings.start_drill_sub), :score_option_switch_format, {}));
            if (match.canUndo()) {
                menu.addItem(new MenuItem(rez(Rez.Strings.undo), "", :score_option_undo, {}));
            }
        } else {
            // an unfinished drill is not recorded: say what ending it drops
            var sub = match.isSetStarted()
                ? rez(Rez.Strings.switch_format_drops) + match.currentSetResult()
                : rez(Rez.Strings.end_drill_sub);
            menu.addItem(new MenuItem(rez(Rez.Strings.end_drill), sub, :score_option_end_drill, {}));
            menu.addItem(new MenuItem(rez(Rez.Strings.next_drill), rez(Rez.Strings.start_drill_sub), :score_option_switch_format, {}));
            menu.addItem(new MenuItem("Undo last point", "", :score_option_undo, {}));
        }
        menu.addItem(new MenuItem("Unforced error", "", :score_option_unforced_error, {}));
        if (!free) {
            menu.addItem(new MenuItem(rez(Rez.Strings.switch_server), servingSubLabel(), :score_option_switch_server, {}));
        }
        menu.addItem(new MenuItem("Finish activity", "", :score_option_finish, {}));
        menu.addItem(new MenuItem("Cancel", "Back to score", :score_option_cancel, {}));
        WatchUi.pushView(menu, new ScoreOptionsMenuDelegate(), WatchUi.SLIDE_IMMEDIATE);
    }

    private function rez(id as ResourceId) as String {
        return Application.loadResource(id) as String;
    }

    // Options during the warm-up (plan 5): no Undo or Unforced error (nothing to undo, no points yet).
    private function pushWarmUpOptionsMenu() as Void {
        var menu = new WatchUi.Menu2({:title=>"Options"});
        menu.addItem(
            new MenuItem(
                Application.loadResource(Rez.Strings.start_match) as String,
                Application.loadResource(Rez.Strings.start_match_sub) as String,
                :score_option_start_match,
                {}
            )
        );
        menu.addItem(
            new MenuItem(
                Application.loadResource(Rez.Strings.switch_server) as String,
                servingSubLabel(),
                :score_option_switch_server,
                {}
            )
        );
        menu.addItem(
            new MenuItem("Finish activity", "", :score_option_finish, {})
        );
        menu.addItem(
            new MenuItem("Cancel", "Back to score", :score_option_cancel, {})
        );
        WatchUi.pushView(menu, new ScoreOptionsMenuDelegate(), WatchUi.SLIDE_IMMEDIATE);
    }

    private function servingSubLabel() as String {
        var side = Application.getApp().getMatch().getServingSide();
        var rez = Rez.Strings.serving_off;
        if (side == Sides.SIDE_P1) {
            rez = Rez.Strings.serving_us;
        } else if (side == Sides.SIDE_P2) {
            rez = Rez.Strings.serving_them;
        }
        return Application.loadResource(rez) as String;
    }

    function onKey(keyEvent as WatchUi.KeyEvent) as Boolean {

        var match = Application.getApp().getMatch();

        switch (keyEvent.getKey()) {
            case KEY_UP: {
                var endOfMatch = match.incP1();

                if (endOfMatch) {
                    WatchUi.pushView(new EndView(), new EndOfMatchDelegate(), WatchUi.SLIDE_UP);
                }
                
                break;
            }
            case KEY_DOWN: {
                var endOfMatch = match.incP2();

                if (endOfMatch) {
                    WatchUi.pushView(new EndView(), new EndOfMatchDelegate(), WatchUi.SLIDE_UP);
                }

                break;
            }
            case KEY_ENTER: {
                pushOptionsMenu();
                break;
            }
            case KEY_ESC: {
                var score = Application.getApp().getScoreString();
                var menu = new WatchUi.Menu2({:title=>"Finish Activity"});
                menu.addItem(
                    new MenuItem("Save and exit", score, :finish_save_exit, {})
                );
                menu.addItem(
                    new MenuItem("Discard", "Don't save activity", :finish_discard, {})
                );
                menu.addItem(
                    new MenuItem("Cancel", "Back to score", :finish_cancel, {})
                );
                WatchUi.pushView(menu, new FinishActivityMenuDelegate(), WatchUi.SLIDE_IMMEDIATE);
                break;
            }
            case KEY_MENU: {
                break;
            }
            case KEY_CLOCK: {
                break;
            }
        }

        // this ensures score gets updated as soon as key is processed
        WatchUi.requestUpdate();

        return true;
    }

    function onSwipe(swipeEvent) {
        // ignoring swipe events, so just returning handled=true to avoid other actions
        return true;
    }

}