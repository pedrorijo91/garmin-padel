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
        var menu = new WatchUi.Menu2({:title=>"Options"});
        menu.addItem(
            new MenuItem("Undo last point", "", :score_option_undo, {})
        );
        menu.addItem(
            new MenuItem("Unforced error", "", :score_option_unforced_error, {})
        );
        menu.addItem(
            new MenuItem("Finish activity", "", :score_option_finish, {})
        );
        menu.addItem(
            new MenuItem("Cancel", "Back to score", :score_option_cancel, {})
        );
        WatchUi.pushView(menu, new ScoreOptionsMenuDelegate(), WatchUi.SLIDE_IMMEDIATE);
        return true;
    }

    function onKey(keyEvent as WatchUi.KeyEvent) as Boolean {

        var match = Application.getApp().getMatch();

        switch (keyEvent.getKey()) {
            case KEY_UP: {
                var endOfMatch = match.incP1();

                if (endOfMatch) {
                    var deviceSettings = System.getDeviceSettings();
                    if (deviceSettings.vibrateOn) {
                        Attention.vibrate([ new Attention.VibeProfile(25, 500) ]);
                    } 

                    WatchUi.pushView(new EndView(), new EndOfMatchDelegate(), WatchUi.SLIDE_UP);
                }
                
                break;
            }
            case KEY_DOWN: {
                var endOfMatch = match.incP2();

                if (endOfMatch) {
                    var deviceSettings = System.getDeviceSettings();
                    if (deviceSettings.vibrateOn) {
                        Attention.vibrate([ new Attention.VibeProfile(25, 500) ]);
                    } 

                    WatchUi.pushView(new EndView(), new EndOfMatchDelegate(), WatchUi.SLIDE_UP);
                }

                break;
            }
            case KEY_ENTER: {
                var menu = new WatchUi.Menu2({:title=>"Options"});
                menu.addItem(
                    new MenuItem("Undo last point", "", :score_option_undo, {})
                );
                menu.addItem(
                    new MenuItem("Unforced error", "", :score_option_unforced_error, {})
                );
                menu.addItem(
                    new MenuItem("Finish activity", "", :score_option_finish, {})
                );
                menu.addItem(
                    new MenuItem("Cancel", "Back to score", :score_option_cancel, {})
                );
                WatchUi.pushView(menu, new ScoreOptionsMenuDelegate(), WatchUi.SLIDE_IMMEDIATE);
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