import Toybox.Application;
import Toybox.Lang;
import Toybox.WatchUi;

class garminpadelApp extends Application.AppBase {

    private var matchConfig;
    private var match;
    private var session;
    private var initialSetps;

    function initialize() {
        AppBase.initialize();
        matchConfig = new MatchConfig();
        initialSetps = 0;
    }

    function onStart(state as Dictionary?) as Void {
    }

    function onStop(state as Dictionary?) as Void {
    }

    function getInitialView() as Array<Views or InputDelegates>? {
        return [ new InitialView(), new InitialScreenDelegate() ] as Array<Views or InputDelegates>;
    }

    // TODO kinda meh that we allow everyone to update the matchConfig and we rely it's on a valid state at this moment
    function initMatch() as Void {
        self.match = new PadelMatch(self.matchConfig);
        self.initialSetps = ActivityMonitor.getInfo().steps;
        self.session = ActivityRecording.createSession({:sport => Activity.SPORT_RACKET, :subSport => Activity.SUB_SPORT_PADEL, :name => "Padel match"});
        self.session.start();
    }

    function getMatch() as PadelMatch {
        return self.match;
    }

    function getMatchConfig() as MatchConfig {
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
        var scoreField = session.createField("game_score", 0, FitContributor.DATA_TYPE_STRING, {:mesgType => FitContributor.MESG_TYPE_SESSION, :units => "points", :count => 50});
        var score = self.getScoreString();
        scoreField.setData(score);

        var stepsField = session.createField("steps", 1, FitContributor.DATA_TYPE_UINT32, {:mesgType => FitContributor.MESG_TYPE_SESSION, :units => "steps"});
        var finalSteps = ActivityMonitor.getInfo().steps;
        var totalSteps = finalSteps - self.initialSetps;
        stepsField.setData(totalSteps);

        var versionField = session.createField("app_version", 2, FitContributor.DATA_TYPE_STRING, {:mesgType => FitContributor.MESG_TYPE_SESSION, :units => "v", :count => 50});
        var appVersion = Application.Properties.getValue("AppVersion");
        versionField.setData(appVersion);

        self.session.stop();
        self.session.save();
    }
}