import Toybox.Graphics;
import Toybox.WatchUi;

class InitialView extends WatchUi.View {

    function initialize() {
        View.initialize();
    }

    function onLayout(dc as Dc) as Void {
        setLayout(Rez.Layouts.InitialLayout(dc));
    }

    function onShow() as Void {
    }

    function onUpdate(dc as Dc) as Void {
        var appVersion = Application.Properties.getValue("AppVersion");
        
        var view = View.findDrawableById("versionLabel") as Text;
        view.setText("v" + appVersion);

        View.onUpdate(dc);
    }

    function onHide() as Void {
    }

}
