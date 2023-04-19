import Toybox.Application;
import Toybox.Lang;
import Toybox.WatchUi;

class garminpadelApp extends Application.AppBase {

    private var match;

    function initialize() {
        AppBase.initialize();

        match = new padelMatch();
    }

    // onStart() is called on application start up
    function onStart(state as Dictionary?) as Void {
    }

    // onStop() is called when your application is exiting
    function onStop(state as Dictionary?) as Void {
    }

    // Return the initial view of your application here
    function getInitialView() as Array<Views or InputDelegates>? {
        return [ new garminpadelView(), new garminpadelDelegate() ] as Array<Views or InputDelegates>;
    }

    function getMatch() as padelMatch {
        return self.match;
    }
}



function getApp() as garminpadelApp {
    return Application.getApp() as garminpadelApp;
}