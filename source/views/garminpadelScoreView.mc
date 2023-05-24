import Toybox.Lang;
import Toybox.System;
import Toybox.WatchUi;
import Toybox.Graphics;
using Toybox.Time;
using Toybox.Time.Gregorian;

class garminpadelScoreView extends WatchUi.View {

    function initialize() {
        View.initialize();
    }

    // Load your resources here
    function onLayout(dc as Dc) as Void {
        setLayout(Rez.Layouts.ScoreLayout(dc));

        var myTimer = new Timer.Timer();
        myTimer.start(method(:requestUpdate), 1000, true);
    }

    // Called when this View is brought to the foreground. Restore
    // the state of this View and prepare it to be shown. This includes
    // loading resources into memory.
    function onShow() as Void {
    }

    // Update the view
    function onUpdate(dc as Dc) as Void {
        // Call the parent onUpdate function to redraw the layout
        View.onUpdate(dc);

        // Include anything that needs to be updated here
        // e.g. score
        var match = Application.getApp().getMatch();

        dc.drawText(110, 20, Graphics.FONT_SMALL, "Sets: " + match.getP1Sets() + " - " + match.getP2Sets(), Graphics.TEXT_JUSTIFY_CENTER);
        dc.drawText(110, 50, Graphics.FONT_SMALL, "Games: " + match.getP1Games() + " - " + match.getP2Games(), Graphics.TEXT_JUSTIFY_CENTER);

        if (match.isInTieBreak()) {
            dc.drawText(110, 90, Graphics.FONT_MEDIUM, "Tie: " + match.getP1TieScore() + " - " + match.getP2TieScore(), Graphics.TEXT_JUSTIFY_CENTER);
        } else {
            dc.drawText(110, 90, Graphics.FONT_MEDIUM, "Score: " + match.getP1Score() + " - " + match.getP2Score(), Graphics.TEXT_JUSTIFY_CENTER);
        }

        // TODO replace label by steps icon
        var steps = ActivityMonitor.getInfo().steps;
        dc.drawText(120, 160, Graphics.FONT_TINY, "Steps: " + steps, Graphics.TEXT_JUSTIFY_CENTER);

        var info = Gregorian.info(Time.now(), Time.FORMAT_SHORT);
        var timeString = Lang.format("$1$:$2$:$3$", [
            info.hour.format("%02u"),
            info.min.format("%02u"),
            info.sec.format("%02u"),
        ]);
        dc.drawText(120, 190, Graphics.FONT_TINY, timeString, Graphics.TEXT_JUSTIFY_CENTER);
    }

    // Called when this View is removed from the screen. Save the
    // state of this View here. This includes freeing resources from
    // memory.
    function onHide() as Void {
    }

    public function requestUpdate() as Void {
          WatchUi.requestUpdate();
    }

}