import Toybox.Application;
import Toybox.Lang;
import Toybox.WatchUi;

class garminpadelApp extends Application.AppBase {

    private var match;
    private var session;

    function initialize() {
        AppBase.initialize();

        match = new padelMatch();
        session = ActivityRecording.createSession({:sport => Activity.SPORT_RACKET, :subSport => Activity.SUB_SPORT_PADEL, :name => "Padel match"});
        session.start();
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

    function saveSession() as Void {
        var field = session.createField("game_score", 0, FitContributor.DATA_TYPE_STRING, {:mesgType => FitContributor.MESG_TYPE_SESSION, :units => "points", :count => 50});
        var score = "Sets: " + self.match.getP1Sets() + " - " + self.match.getP2Sets();
        field.setData(score);
        self.session.stop();
        self.session.save();
    }
}



function getApp() as garminpadelApp {
    return Application.getApp() as garminpadelApp;
}