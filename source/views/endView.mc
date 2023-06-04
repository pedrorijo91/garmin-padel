import Toybox.Graphics;
import Toybox.WatchUi;

class endView extends WatchUi.View {

    function initialize() {
        View.initialize();
    }

    function onLayout(dc as Dc) as Void {
        setLayout(Rez.Layouts.EndOfMatchLayout(dc));
    }

    function onShow() as Void {
    }

    function onUpdate(dc as Dc) as Void {        
        var view = View.findDrawableById("resultLabel") as Text;
        var score = Application.getApp().getScoreString();
        view.setText(score);

        View.onUpdate(dc);
    }

    function onHide() as Void {
    }

}
