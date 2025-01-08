import Toybox.Application;
import Toybox.Lang;
import Toybox.WatchUi;
import Toybox.ActivityRecording;
using Toybox.Time.Gregorian;

class GarminpadelApp extends Application.AppBase {

    private var matchConfig as MatchConfig;
    private var match as PadelMatch or Null;
    private var session as ActivityRecording.Session or Null;
    private var initialSetps as Number;
    private var initialDay as Number; // we need to check if the activity crossed the day to correctly compute steps

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
        self.initialSetps = ActivityMonitor.getInfo().steps as Number;
        self.session = ActivityRecording.createSession({:sport => Activity.SPORT_RACKET, :subSport => Activity.SUB_SPORT_PADEL, :name => "Padel match"});
        self.session.start();
    }

    function getMatch() as PadelMatch {
        return self.match as PadelMatch;
    }

    function getMatchConfig() as MatchConfig {
        return self.matchConfig;
    }

    private function getSession() as ActivityRecording.Session or Null {
        return self.session;
    }

    function getScoreString() as String {
        var score = "";
        var historicalScores = self.getMatch().getHistoricalScores();
        for(var i = 0; i < historicalScores.size(); i++ ) {
            score += historicalScores[i] + " / ";
        }
        if(historicalScores.size() > 0) {
            score = score.substring(0, score.length() - 3);
        }

        return score as String;
    }

    function lapSession() as Void {
        var session = getSession();
        if (session != null) {
            session.addLap();
        }
    }

    function saveSession() as Void {
        var session = getSession();

        if (session == null) {
            return;
        }

        var scoreField = session.createField("game_score", 0, FitContributor.DATA_TYPE_STRING, {:mesgType => FitContributor.MESG_TYPE_SESSION, :units => "points", :count => 50});
        var score = self.getScoreString();
        scoreField.setData(score);

        var stepsField = session.createField("steps", 1, FitContributor.DATA_TYPE_UINT32, {:mesgType => FitContributor.MESG_TYPE_SESSION, :units => "steps"});
        var totalSteps = computeTotalSteps();
        stepsField.setData(totalSteps);

        var versionField = session.createField("app_version", 2, FitContributor.DATA_TYPE_STRING, {:mesgType => FitContributor.MESG_TYPE_SESSION, :units => "v", :count => 50});
        var appVersion = Application.loadResource(Rez.Strings.AppVersion) as String;
        versionField.setData(appVersion);

        session.stop();
        session.save();
    }

    function computeTotalSteps() as Number {
        var currentDay = Gregorian.info(Time.now(), Time.FORMAT_SHORT).day;
        
        if (currentDay == self.initialDay) {
            var finalSteps = ActivityMonitor.getInfo().steps as Number;
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