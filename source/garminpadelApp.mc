import Toybox.Application;
import Toybox.Lang;
import Toybox.WatchUi;
using Toybox.Time.Gregorian;

class GarminpadelApp extends Application.AppBase {

    private var matchConfig;
    private var match;
    private var session;
    private var initialSetps;
    private var initialDay; // we need to check if the activity crossed the day to correctly compute steps

    function initialize() {
        AppBase.initialize();
        matchConfig = new MatchConfig();

        initialSetps = 0; 
        initialDay = Gregorian.info(Time.now(), Time.FORMAT_SHORT).day;
    }

    function onStart(state as Dictionary?) as Void {
    }

    function onStop(state as Dictionary?) as Void {
    }

    function getInitialView() as [Views] or [Views, InputDelegates]  {
        return [ new InitialView(), new InitialScreenDelegate() ];
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

    function lapSession() as Void {
        session.addLap();
    }


    function saveSession() as Void {
        var scoreField = session.createField("game_score", 0, FitContributor.DATA_TYPE_STRING, {:mesgType => FitContributor.MESG_TYPE_SESSION, :units => "points", :count => 50});
        var score = self.getScoreString();
        scoreField.setData(score);

        var stepsField = session.createField("steps", 1, FitContributor.DATA_TYPE_UINT32, {:mesgType => FitContributor.MESG_TYPE_SESSION, :units => "steps"});
        var totalSteps = computeTotalSteps();
        stepsField.setData(totalSteps);

        var versionField = session.createField("app_version", 2, FitContributor.DATA_TYPE_STRING, {:mesgType => FitContributor.MESG_TYPE_SESSION, :units => "v", :count => 50});
        var appVersion = Application.loadResource(Rez.Strings.AppVersion) as String;
        versionField.setData(appVersion);

        self.session.stop();
        self.session.save();
    }

    function computeTotalSteps() as Number {
        var currentDay = Gregorian.info(Time.now(), Time.FORMAT_SHORT).day;
        
        if (currentDay == self.initialDay) {
            var finalSteps = ActivityMonitor.getInfo().steps;
            return finalSteps - self.initialSetps;
        } else {
            var history = ActivityMonitor.getHistory();

            if (history.size() < 2) {
                // if for some reason we dont have today and yesterday info
                return -1;
            }

            var finalSteps = history[0].steps + history[1].steps - self.initialSetps;
            return finalSteps;
        }

        
    }
}