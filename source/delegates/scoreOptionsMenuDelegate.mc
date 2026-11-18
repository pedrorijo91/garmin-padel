import Toybox.Lang;
import Toybox.WatchUi;

class ScoreOptionsMenuDelegate extends WatchUi.Menu2InputDelegate {

    function initialize() {
        Menu2InputDelegate.initialize();
    }

    function onSelect(item as MenuItem) as Void {
        if (item.getId() == :score_option_cancel) {
            WatchUi.popView(WatchUi.SLIDE_IMMEDIATE);
        } else if (item.getId() == :score_option_undo) {
            WatchUi.popView(WatchUi.SLIDE_IMMEDIATE);
            var dialog = new WatchUi.Confirmation("Undo?");
            WatchUi.pushView(
                dialog,
                new UndoConfirmationDelegate(),
                WatchUi.SLIDE_IMMEDIATE
            );
        } else if (item.getId() == :score_option_unforced_error) {
            WatchUi.popView(WatchUi.SLIDE_IMMEDIATE);
            Application.getApp().getMatch().addUnforcedError();
        } else if (item.getId() == :score_option_switch_server) {
            WatchUi.popView(WatchUi.SLIDE_IMMEDIATE);
            Application.getApp().getMatch().switchServer();
        } else if (item.getId() == :score_option_switch_format) {
            WatchUi.popView(WatchUi.SLIDE_IMMEDIATE);
            pushSwitchFormatMenu();
        } else if (item.getId() == :format_tie_break) {
            switchSetFormat(MatchConfig.FORMAT_TIE_BREAK);
        } else if (item.getId() == :format_super_tie) {
            switchSetFormat(MatchConfig.FORMAT_SUPER_TIE);
        } else if (item.getId() == :format_mini) {
            switchSetFormat(MatchConfig.FORMAT_MINI);
        } else if (item.getId() == :format_normal) {
            // training only: a full set as a drill
            switchSetFormat(MatchConfig.FORMAT_NORMAL);
        } else if (item.getId() == :score_option_end_drill) {
            // training: back to free play; the drill's score is not recorded (undo brings it back)
            WatchUi.popView(WatchUi.SLIDE_IMMEDIATE);
            Application.getApp().getMatch().endDrill();
        } else if (item.getId() == :score_option_finish) {
            WatchUi.popView(WatchUi.SLIDE_IMMEDIATE);
            var score = Application.getApp().getMatch().getScoreString();
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
        } else if (item.getId() == :score_option_start_match) {
            // warm-up only (plan 5): end it without scoring
            WatchUi.popView(WatchUi.SLIDE_IMMEDIATE);
            Application.getApp().getMatch().endWarmUp();
        }
    }

    // "Switch to" submenu, or "Start drill" / "Next drill" in training (with a full Set too).
    // Its items are handled by this delegate too (saves a class on low-memory devices).
    private function pushSwitchFormatMenu() as Void {
        var match = Application.getApp().getMatch();
        var training = match.isTraining();
        var title = Rez.Strings.switch_format;
        if (training) {
            title = match.isFreePlay() ? Rez.Strings.start_drill : Rez.Strings.next_drill;
        }
        var menu = new WatchUi.Menu2({:title=>Application.loadResource(title) as String});
        menu.addItem(new MenuItem(Application.loadResource(Rez.Strings.format_tie_break) as String, Application.loadResource(Rez.Strings.format_tie_break_sub) as String, :format_tie_break, {}));
        menu.addItem(new MenuItem(Application.loadResource(Rez.Strings.format_super_tie) as String, Application.loadResource(Rez.Strings.format_super_tie_sub) as String, :format_super_tie, {}));
        menu.addItem(new MenuItem(Application.loadResource(Rez.Strings.format_mini) as String, Application.loadResource(Rez.Strings.format_mini_sub) as String, :format_mini, {}));
        if (training) {
            menu.addItem(new MenuItem(Application.loadResource(Rez.Strings.format_set) as String, Application.loadResource(Rez.Strings.format_set_sub) as String, :format_normal, {}));
        }
        WatchUi.pushView(menu, new ScoreOptionsMenuDelegate(), WatchUi.SLIDE_IMMEDIATE);
    }

    private function switchSetFormat(format as Number) as Void {
        WatchUi.popView(WatchUi.SLIDE_IMMEDIATE);
        Application.getApp().getMatch().switchSetFormat(format);
    }

}
