import Toybox.Application;
import Toybox.Lang;
import Toybox.WatchUi;

class garminpadelApp extends Application.AppBase {

    private var matchConfig;
    private var match;
    private var session;

    function initialize() {
        AppBase.initialize();
        matchConfig = new matchConfig();
    }

    // onStart() is called on application start up
    function onStart(state as Dictionary?) as Void {
    }

    // onStop() is called when your application is exiting
    function onStop(state as Dictionary?) as Void {
    }

    // Return the initial view of your application here
    function getInitialView() as Array<Views or InputDelegates>? {
        return [ new initialView(), new initialScreenDelegate() ] as Array<Views or InputDelegates>;
    }

    // TODO kinda meh that we allow everyone to update the matchConfig and we realy it's on a valid state at this moment
    function initMatch() as Void {
        System.println("init match: " + self.matchConfig);

        self.match = new padelMatch(self.matchConfig);

        self.session = ActivityRecording.createSession({:sport => Activity.SPORT_RACKET, :subSport => Activity.SUB_SPORT_PADEL, :name => "Padel match"});
        self.session.start();
    }

    function getMatch() as padelMatch {
        return self.match;
    }

    function getMatchConfig() as matchConfig {
        return self.matchConfig;
    }

    function getScoreString() as String {
        var score = "";
        var historicalScores = self.match.getHistoricalScores();
        for(var i = 0; i < historicalScores.size(); i++ ) {
            score += historicalScores[i] + " / ";
        }
        if(historicalScores.size() > 0) {
            score = score.substring(0, score.length() - 3);
        }

        return score;
    }

    function saveSession() as Void {
        var field = session.createField("game_score", 0, FitContributor.DATA_TYPE_STRING, {:mesgType => FitContributor.MESG_TYPE_SESSION, :units => "points", :count => 50});
        
        var score = self.getScoreString();
        field.setData(score);
        
        self.session.stop();
        self.session.save();
    }
}