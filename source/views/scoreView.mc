import Toybox.Lang;
import Toybox.System;
import Toybox.WatchUi;
import Toybox.Graphics;
using Toybox.Time;
using Toybox.Time.Gregorian;

class scoreView extends WatchUi.View {

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
        // Include anything that needs to be updated here
        // e.g. score
        var match = Application.getApp().getMatch();

        var setsLabel = View.findDrawableById("setsLabel") as Text;
        setsLabel.setText("Sets: " + match.getP1Sets() + " - " + match.getP2Sets());

        var gamesLabel = View.findDrawableById("gamesLabel") as Text;
        gamesLabel.setText("Games: " + match.getP1Games() + " - " + match.getP2Games());

        var scoreLabel = View.findDrawableById("scoreLabel") as Text;
        if (match.isInTieBreak()) {
            scoreLabel.setText("Tie: " + match.getP1TieScore() + " - " + match.getP2TieScore());
        } else {
            scoreLabel.setText("Score: " + match.getP1Score() + " - " + match.getP2Score());
        }

        var steps = ActivityMonitor.getInfo().steps;

        var heartRateIterator = ActivityMonitor.getHeartRateHistory(1, true);
        var sample = heartRateIterator.next();

        var stepsAndHeartLabel = View.findDrawableById("stepsAndHeartLabel") as Text;
        stepsAndHeartLabel.setText("" + steps + " / " + sample.heartRate);

        var info = Gregorian.info(Time.now(), Time.FORMAT_SHORT);
        var timeString = Lang.format("$1$:$2$:$3$", [
            info.hour.format("%02u"),
            info.min.format("%02u"),
            info.sec.format("%02u"),
        ]);
        var clockLabel = View.findDrawableById("clockLabel") as Text;
        clockLabel.setText(timeString);

        View.onUpdate(dc);
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