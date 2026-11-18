import Toybox.Lang;
import Toybox.Time;

// Thin facade: builds MatchEngine from MatchConfig and delegates all scoring/state to it.
// Keeps the same public API for views and delegates. It reads the clock (Time.now()) and passes it to
// MatchEngine, so the engine itself can be tested with any time.
class PadelMatch {

    private var matchEngine as MatchEngine;
    private var formatSwitch as Boolean;

    function initialize(config as MatchConfig) {
        var training = config.getTraining();
        self.formatSwitch = config.getFormatSwitch() && !training;
        self.matchEngine = new MatchEngine(
            training ? MatchConfig.UNLIMITED_SETS : config.getNumberOfSets(),
            self.gameEngineForPointRule(config.getPointRule()),
            // SET_TYPE_* values are the same as MatchConfig.FORMAT_NORMAL / PRO / MINI
            training ? MatchConfig.FORMAT_FREE : config.getSetType(),
            config.getSuperTie() && !training
        );
        self.matchEngine.startSession(now());
        // training already starts in free play, which is its warm-up
        if (config.getWarmUp()) {
            self.matchEngine.startWarmUp();
        }
    }

    private static function now() as Number {
        return Time.now().value();
    }

    // --- Training (plan 2) ---

    function isTraining() as Boolean {
        return self.matchEngine.isTraining();
    }

    // Training between drills (no score), or the warm-up of a match
    function isFreePlay() as Boolean {
        return self.matchEngine.isFreePlay();
    }

    // Training: Options -> End drill. The drill's score is not recorded; back to free play. Undoable.
    function endDrill() as Void {
        self.matchEngine.switchSetFormat(MatchConfig.FORMAT_FREE, now());
    }

    // Seconds since the current segment (set, drill, free play) started
    function getSegmentSeconds() as Number {
        var secs = now() - self.matchEngine.getMatchStatus().getSegmentStartTime();
        return secs < 0 ? 0 : secs;
    }

    // FIT lap label for the segment in progress when the activity is saved ("Free", "TB [4-3]")
    function segmentLabel() as String {
        return self.matchEngine.segmentLabel();
    }

    function canUndo() as Boolean {
        return self.matchEngine.canUndo();
    }

    // Whether the Options menu offers switching the set format (Friendly and Custom matches only).
    function canSwitchSetFormat() as Boolean {
        return self.formatSwitch;
    }

    // Play MatchConfig.FORMAT_TIE_BREAK / FORMAT_SUPER_TIE / FORMAT_MINI now. See MatchEngine.switchSetFormat.
    // Training: Start drill / Next drill (also FORMAT_NORMAL, a full set).
    function switchSetFormat(format as Number) as Void {
        self.matchEngine.switchSetFormat(format, now());
    }

    // true when points have been played in the current set (switching then drops it)
    function isSetStarted() as Boolean {
        return self.matchEngine.isSetStarted();
    }

    function currentSetResult() as String {
        return self.matchEngine.currentSetResult();
    }

    function currentSetHasGames() as Boolean {
        return self.matchEngine.currentSetHasGames();
    }

    function incP1() as Boolean {
        return self.matchEngine.incP1(now());
    }

    function incP2() as Boolean {
        return self.matchEngine.incP2(now());
    }

    function addUnforcedError() as Void {
        self.matchEngine.addUnforcedError();
    }

    function undo() as Void {
        self.matchEngine.undo();
    }

    function setFirstServer(side as Number) as Void {
        self.matchEngine.setFirstServer(side);
    }

    function switchServer() as Void {
        self.matchEngine.switchServer();
    }

    // Sides.SIDE_P1 (us), Sides.SIDE_P2 (them), or -1 when unknown / match over.
    function getServingSide() as Number {
        return self.matchEngine.getServingSide();
    }

    // Warm-up phase (plan 5): Up/Down end it without scoring.
    function isWarmingUp() as Boolean {
        return self.matchEngine.isWarmingUp();
    }

    // Options -> Start match: ends the warm-up (adds a lap) without scoring.
    function endWarmUp() as Void {
        self.matchEngine.endWarmUp(now());
    }

    function getMatchStatus() as MatchStatus {
        return self.matchEngine.getMatchStatus();
    }

    function getHistoricalScores() as Lang.Array<Lang.String> {
        return self.matchEngine.getHistoricalScores();
    }

    function isInTieBreak() as Boolean {
        return self.matchEngine.isInTieBreak();
    }

    function isInSuperTieBreak() as Boolean {
        return self.matchEngine.isInSuperTieBreak();
    }

    private function gameEngineForPointRule(rule as Number) as GameEngine {
        if (rule == MatchConfig.POINT_RULE_GOLDEN) {
            return new GoldenPointGameEngine();
        }
        if (rule == MatchConfig.POINT_RULE_ADVANTAGE) {
            return new AdvantageGameEngine();
        }
        if (rule == MatchConfig.POINT_RULE_SILVER) {
            return new SilverPointGameEngine();
        }
        if (rule == MatchConfig.POINT_RULE_STAR) {
            return new StarPointGameEngine();
        }
        return new GoldenPointGameEngine();
    }
}
