import Toybox.Application;
import Toybox.Attention;
import Toybox.Lang;
import Toybox.System;
import Toybox.WatchUi;
import Toybox.ActivityRecording;
import Toybox.FitContributor;
using Toybox.Time.Gregorian;

class GarminpadelApp extends Application.AppBase {

    private var matchConfig as MatchConfig;
    private var match as PadelMatch or Null;
    private var session as ActivityRecording.Session or Null;
    private var initialSetps as Number;
    private var initialDay as Number; // we need to check if the activity crossed the day to correctly compute steps
    private var courtChangeBannerUntil as Number;
    // text of the banner shown until courtChangeBannerUntil
    private var bannerText as ResourceId or String;
    // laps added this session (test seam)
    private var lapCount as Number;
    // System.getTimer() when the warm-up started, or null if the match has no warm-up
    private var warmUpStartedAt as Number or Null;
    // System.getTimer() when the warm-up ended, or null while it runs
    private var warmUpEndedAt as Number or Null;
    // null outside training
    private var lapScoreField as FitContributor.Field or Null;
    // label written to the last lap (test seam)
    private var lastLapLabel as String or Null;

    function initialize() {
        AppBase.initialize();
        matchConfig = new MatchConfig();

        initialSetps = 0; 
        initialDay = Gregorian.info(Time.now(), Time.FORMAT_SHORT).day;
        courtChangeBannerUntil = 0;
        bannerText = Rez.Strings.court_change_ends;
        lapCount = 0;
        warmUpStartedAt = null;
        warmUpEndedAt = null;
        lapScoreField = null;
        lastLapLabel = null;
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
        var training = self.matchConfig.getTraining();
        var session = ActivityRecording.createSession({:sport => Activity.SPORT_RACKET, :subSport => Activity.SUB_SPORT_PADEL, :name => training ? "Padel training" : "Padel match"});
        self.session = session;
        // a lap message has its own 256-byte developer-data budget; this field takes 16
        self.lapScoreField = training
            ? session.createField("lap_score", 5, FitContributor.DATA_TYPE_STRING, {:mesgType => FitContributor.MESG_TYPE_LAP, :units => "", :count => LAP_STRING_MAX + 1})
            : null;
        session.start();
        self.courtChangeBannerUntil = 0;
        self.warmUpStartedAt = self.matchConfig.getWarmUp() ? System.getTimer() : null;
        self.warmUpEndedAt = null;
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

    // label: the result of the segment that ends; only written in training
    function lapSession(label as String or Null) as Void {
        self.setLapLabel(label);
        var session = getSession();
        if (session != null) {
            session.addLap();
        }
        self.lapCount++;
    }

    private function setLapLabel(label as String or Null) as Void {
        self.lastLapLabel = label;
        var field = self.lapScoreField;
        if (field != null && label != null) {
            field.setData(fitString(label, LAP_STRING_MAX));
        }
    }

    function getLastLapLabel() as String or Null {
        return self.lastLapLabel;
    }

    function onDrillWon(result as String) as Void {
        self.bannerText = result;
        self.courtChangeBannerUntil = System.getTimer() + 2500;
        if (Attention has :vibrate) {
            Attention.vibrate([new Attention.VibeProfile(75, 300), new Attention.VibeProfile(0, 150), new Attention.VibeProfile(75, 300)] as Array<Attention.VibeProfile>);
        }
    }

    function getLapCount() as Number {
        return self.lapCount;
    }

    // --- Warm-up ---

    // Called by MatchEngine when the warm-up ends: lap 1 = warm-up, then a short vibration and a banner.
    function onWarmUpEnd() as Void {
        self.warmUpEndedAt = System.getTimer();
        self.lapSession(null);
        self.bannerText = Rez.Strings.match_started;
        self.courtChangeBannerUntil = System.getTimer() + 2000;
        if (Attention has :vibrate) {
            Attention.vibrate([new Attention.VibeProfile(75, 300)] as Array<Attention.VibeProfile>);
        }
    }

    // Length of the warm-up in seconds (still counting while it runs), or -1 if the match has no warm-up.
    function getWarmUpSeconds() as Number {
        // null = unset: System.getTimer() is signed and can be negative after it wraps, so no sign checks
        var start = self.warmUpStartedAt;
        if (start == null) {
            return -1;
        }
        var end = self.warmUpEndedAt;
        if (end == null) {
            end = System.getTimer();
        }
        // 32-bit subtraction gives the right interval even across the timer wrap
        return (end - start) / 1000;
    }

    function getBannerText() as String {
        var text = self.bannerText;
        if (text instanceof String) {
            return text;
        }
        return Application.loadResource(text as ResourceId) as String;
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

        // training: the results are on the laps (lap_score)
        if (!self.getMatch().isTraining()) {
            var scoreField = session.createField("game_score", 0, FitContributor.DATA_TYPE_STRING, {:mesgType => FitContributor.MESG_TYPE_SESSION, :units => "points", :count => 50});
            var score = fitString(self.getMatch().getScoreString(), FIT_STRING_MAX);
            scoreField.setData(score);
        }

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

        // the last lap is closed by save(): label it with the segment in progress
        self.setLapLabel(self.getMatch().segmentLabel());

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