import Toybox.Lang;
import Toybox.System;
import Toybox.WatchUi;
import Toybox.Graphics;

class garminpadelScoreView extends WatchUi.View {

    function initialize() {
        View.initialize();
    }

    // Load your resources here
    function onLayout(dc as Dc) as Void {
        setLayout(Rez.Layouts.ScoreLayout(dc));
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

        dc.drawText(100, 20, Graphics.FONT_SMALL, "Sets: " + match.getP1Sets() + " - " + match.getP2Sets(), Graphics.TEXT_JUSTIFY_CENTER);
        dc.drawText(100, 70, Graphics.FONT_MEDIUM, "Games: " + match.getP1Games() + " - " + match.getP2Games(), Graphics.TEXT_JUSTIFY_CENTER);
        dc.drawText(100, 120, Graphics.FONT_LARGE, "Score: " + match.getP1Score() + " - " + match.getP2Score(), Graphics.TEXT_JUSTIFY_CENTER);
    }

    // Called when this View is removed from the screen. Save the
    // state of this View here. This includes freeing resources from
    // memory.
    function onHide() as Void {
    }

}