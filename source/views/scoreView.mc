import Toybox.Lang;
import Toybox.System;
import Toybox.WatchUi;
import Toybox.Graphics;
using Toybox.Time;
using Toybox.Time.Gregorian;

class ScoreView extends WatchUi.View {

    function initialize() {
        View.initialize();
    }

    function onLayout(dc as Dc) as Void {
        setLayout(Rez.Layouts.ScoreLayout(dc));

        var myTimer = new Timer.Timer();
        myTimer.start(method(:requestUpdate), 1000, true);
    }

    function onShow() as Void {
    }

    function onUpdate(dc as Dc) as Void {
        var match = Application.getApp().getMatch();
        var matchStatus = match.getMatchStatus();

        var setsLabel = View.findDrawableById("setsLabel") as Text;
        setsLabel.setText("Sets: " + matchStatus.getP1Sets() + " - " + matchStatus.getP2Sets());

        var gamesLabel = View.findDrawableById("gamesLabel") as Text;
        var scoreLabel = View.findDrawableById("scoreLabel") as Text;

        if (match.isInSuperTieBreak()) {
            gamesLabel.setText("");
            scoreLabel.setText("Super: " + matchStatus.getP1TieScore() + " - " + matchStatus.getP2TieScore());
        } else {
            gamesLabel.setText("Games: " + matchStatus.getP1Games() + " - " + matchStatus.getP2Games());

            if (match.isInTieBreak()) {
                scoreLabel.setText("Tie: " + matchStatus.getP1TieScore() + " - " + matchStatus.getP2TieScore());
            } else {
                scoreLabel.setText("Score: " + matchStatus.getP1Score() + " - " + matchStatus.getP2Score());
            }
        }

        var steps = ActivityMonitor.getInfo().steps;

        var heartRateIterator = ActivityMonitor.getHeartRateHistory(1, true);
        var heartRate = heartRateIterator.next().heartRate;

        var stepsAndHeartLabel = View.findDrawableById("stepsAndHeartLabel") as Text;
        stepsAndHeartLabel.setText("" + steps + " / " + heartRate);

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

    function onHide() as Void {
    }

    public function requestUpdate() as Void {
        WatchUi.requestUpdate();
    }

}