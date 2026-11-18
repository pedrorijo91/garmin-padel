import Toybox.Application;
import Toybox.Lang;
import Toybox.System;
import Toybox.WatchUi;
import Toybox.Graphics;
using Toybox.Time;
using Toybox.Time.Gregorian;
import Toybox.ActivityMonitor;

class ScoreView extends WatchUi.View {

    function initialize() {
        View.initialize();
    }

    function onLayout(dc as Dc) as Void {
        setLayout(Rez.Layouts.ScoreLayout(dc));

        // this ensures view gets updated every second instead of waiting for key press
        var myTimer = new Timer.Timer();
        myTimer.start(method(:requestUpdate), 1000, true);
    }

    function onShow() as Void {
    }

    function onHide() as Void {
    }

    function onUpdate(dc as Dc) as Void {
        var match = Application.getApp().getMatch();
        var matchStatus = match.getMatchStatus();

        var setsLabel = View.findDrawableById("setsLabel") as Text;
        var training = match.isTraining();
        var setsPrefix = training ? Application.loadResource(Rez.Strings.drills) as String : "Sets: ";
        setsLabel.setText(setsPrefix + matchStatus.getP1Sets() + " - " + matchStatus.getP2Sets());

        var gamesLabel = View.findDrawableById("gamesLabel") as Text;
        var scoreLabel = View.findDrawableById("scoreLabel") as Text;

        if (!match.currentSetHasGames()) {
            // the set is a single tie-break (deciding or chosen super tie, or a chosen tie-break): no games
            gamesLabel.setText("");
            var tieLabel = match.isInSuperTieBreak() ? "Super: " : "Tie: ";
            scoreLabel.setText(tieLabel + matchStatus.getP1TieScore() + " - " + matchStatus.getP2TieScore());
        } else {
            gamesLabel.setText("Games: " + matchStatus.getP1Games() + " - " + matchStatus.getP2Games());

            if (match.isInTieBreak()) {
                scoreLabel.setText("Tie: " + matchStatus.getP1TieScore() + " - " + matchStatus.getP2TieScore());
            } else {
                scoreLabel.setText("Score: " + matchStatus.getP1Score() + " - " + matchStatus.getP2Score());
            }
        }

        if (training && match.isFreePlay()) {
            if (matchStatus.getP1Sets() + matchStatus.getP2Sets() == 0) {
                setsLabel.setText(Application.loadResource(Rez.Strings.training) as String);
            }
            gamesLabel.setText(Application.loadResource(Rez.Strings.free_play) as String);
            var secs = match.getSegmentSeconds();
            scoreLabel.setText((secs / 60) + ":" + (secs % 60).format("%02d"));
        }

        // Warm-up: no score yet, show its length and how to start the match
        if (match.isWarmingUp()) {
            var secs = Application.getApp().getWarmUpSeconds();
            if (secs < 0) {
                secs = 0;
            }
            setsLabel.setText(Application.loadResource(Rez.Strings.warm_up) as String);
            gamesLabel.setText(Application.loadResource(Rez.Strings.warm_up_press_to_start) as String);
            scoreLabel.setText((secs / 60) + ":" + (secs % 60).format("%02d"));
        }

        var steps = ActivityMonitor.getInfo().steps;

        var heartRateIterator = ActivityMonitor.getHeartRateHistory(1, true);
        var heartRate = (heartRateIterator.next() as ActivityMonitor.HeartRateSample).heartRate;

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

        drawServingIndicator(dc, match.isWarmingUp() ? -1 : match.getServingSide());

        if (Application.getApp().isCourtChangeBannerVisible()) {
            var w = dc.getWidth();
            var h = dc.getHeight();
            var padX = w / 12;
            var padY = h / 14;
            var boxTop = h * 38 / 100;
            var fh = dc.getFontHeight(Graphics.FONT_MEDIUM);
            var boxH = fh + padY;
            dc.setColor(Graphics.COLOR_DK_GRAY, Graphics.COLOR_DK_GRAY);
            dc.fillRectangle(padX, boxTop, w - 2 * padX, boxH);
            dc.setColor(Graphics.COLOR_YELLOW, Graphics.COLOR_TRANSPARENT);
            var msg = Application.getApp().getBannerText();
            var textY = boxTop + (boxH - fh) / 2;
            dc.drawText(w / 2, textY, Graphics.FONT_MEDIUM, msg, Graphics.TEXT_JUSTIFY_CENTER);
        }
    }

    // Marks the serving team along the screen edge: top half = us (Up), bottom half = them (Down).
    // Drawn from dc size only (no per-device layouts). White, so it also works on black-and-white screens.
    // Round screens: a thick arc hugging the edge. Other shapes (rectangle, Instinct semi-octagon): a bar on the edge.
    private function drawServingIndicator(dc as Dc, side as Number) as Void {
        if (side < 0) {
            return;
        }
        var w = dc.getWidth();
        var h = dc.getHeight();
        var pen = w / 30;
        if (pen < 4) {
            pen = 4;
        }
        var top = side == Sides.SIDE_P1;
        dc.setColor(Graphics.COLOR_WHITE, Graphics.COLOR_TRANSPARENT);

        if (System.getDeviceSettings().screenShape == System.SCREEN_SHAPE_ROUND) {
            // 80 degrees centred on 12 / 6 o'clock (0 deg = 3 o'clock, counter-clockwise).
            // Wider, it touches the steps/heart icons on small screens.
            var start = top ? 50 : 230;
            dc.setPenWidth(pen);
            dc.drawArc(w / 2, h / 2, w / 2 - pen / 2, Graphics.ARC_COUNTER_CLOCKWISE, start, start + 80);
            dc.setPenWidth(1);
        } else {
            var barW = w * 2 / 5;
            var x = (w - barW) / 2;
            // Instinct: the round sub-screen hides what is drawn under it, so keep the top bar left of it
            if (top && (WatchUi has :getSubscreen)) {
                var sub = WatchUi.getSubscreen();
                var subX = sub != null ? sub.x : null;
                if (subX != null && subX < x + barW) {
                    x = subX - pen - barW;
                }
            }
            dc.fillRectangle(x, top ? 0 : h - pen, barW, pen);
        }
    }

    public function requestUpdate() as Void {
        WatchUi.requestUpdate();
    }

}