import Toybox.Application;
import Toybox.Attention;
import Toybox.Lang;
import Toybox.System;
import Toybox.WatchUi;
import Toybox.ActivityRecording;
using Toybox.Time.Gregorian;

class GarminpadelApp extends Application.AppBase {

    private var matchConfig as MatchConfig;
    private var match as PadelMatch or Null;
    private var session as ActivityRecording.Session or Null;
    private var initialSetps as Number;
    private var initialDay as Number; // we need to check if the activity crossed the day to correctly compute steps
    private var courtChangeBannerUntil as Number;
    // text of the banner shown until courtChangeBannerUntil ("Change ends", or "Match started" after the warm-up)
    private var bannerText as ResourceId;
    // laps added this session (test seam for the warm-up lap, plan 5)
    private var lapCount as Number;
    // System.getTimer() when the warm-up started, or -1 if the match has no warm-up
    private var warmUpStartedAt as Number;
    // System.getTimer() when the warm-up ended, or -1 while it runs
    private var warmUpEndedAt as Number;

    function initialize() {
        AppBase.initialize();
        matchConfig = new MatchConfig();

        initialSetps = 0; 
        initialDay = Gregorian.info(Time.now(), Time.FORMAT_SHORT).day;
        courtChangeBannerUntil = 0;
        bannerText = Rez.Strings.court_change_ends;
        lapCount = 0;
        warmUpStartedAt = -1;
        warmUpEndedAt = -1;
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
        self.courtChangeBannerUntil = 0;
        self.warmUpStartedAt = self.matchConfig.getWarmUp() ? System.getTimer() : -1;
        self.warmUpEndedAt = -1;
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
        self.lapCount++;
    }

    function getLapCount() as Number {
        return self.lapCount;
    }

    // --- Warm-up (plan 5) ---

    // Called by MatchEngine when the warm-up ends: lap 1 = warm-up, then a short vibration and a banner.
    function onWarmUpEnd() as Void {
        self.warmUpEndedAt = System.getTimer();
        self.lapSession();
        self.bannerText = Rez.Strings.match_started;
        self.courtChangeBannerUntil = System.getTimer() + 2000;
        if (Attention has :vibrate) {
            Attention.vibrate([new Attention.VibeProfile(75, 300)] as Array<Attention.VibeProfile>);
        }
    }

    // Length of the warm-up in seconds (still counting while it runs), or -1 if the match has no warm-up.
    function getWarmUpSeconds() as Number {
        if (self.warmUpStartedAt < 0) {
            return -1;
        }
        var end = self.warmUpEndedAt >= 0 ? self.warmUpEndedAt : System.getTimer();
        return (end - self.warmUpStartedAt) / 1000;
    }

    function getBannerText() as String {
        return Application.loadResource(self.bannerText) as String;
    }

    function onTieBreakCourtChange() as Void {
        self.courtChangeBannerUntil = System.getTimer() + 2500;
        self.bannerText = Rez.Strings.court_change_ends;
        var vibe1 = new Attention.VibeProfile(75, 150);
        var vibe2 = new Attention.VibeProfile(75, 150);
        Attention.vibrate([vibe1, vibe2] as Array<Attention.VibeProfile>);
    }

    function isCourtChangeBannerVisible() as Boolean {
        return self.courtChangeBannerUntil != 0 && System.getTimer() < self.courtChangeBannerUntil;
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

        var unforcedErrorsField = session.createField("unforced_errors", 3, FitContributor.DATA_TYPE_UINT16, {:mesgType => FitContributor.MESG_TYPE_SESSION, :units => "count"});
        var unforcedErrors = self.getMatch().getMatchStatus().getUnforcedErrors();
        unforcedErrorsField.setData(unforcedErrors);

        var warmUpSeconds = self.getWarmUpSeconds();
        if (warmUpSeconds >= 0) {
            var warmUpField = session.createField("warmup_seconds", 4, FitContributor.DATA_TYPE_UINT16, {:mesgType => FitContributor.MESG_TYPE_SESSION, :units => "s"});
            warmUpField.setData(warmUpSeconds > 65535 ? 65535 : warmUpSeconds);
        }

        session.stop();
        session.save();
    }

    function discardSession() as Void {
        var session = getSession();

        if (session == null) {
            return;
        }

        // stop recording but do not save a FIT file
        session.stop();
        session.discard();
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