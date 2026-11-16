import Toybox.Lang;

// Thin facade: builds MatchEngine from MatchConfig and delegates all scoring/state to it.
// Keeps the same public API for views and delegates.
class PadelMatch {

    private var matchEngine as MatchEngine;

    function initialize(config as MatchConfig) {
        var gameEngine = self.gameEngineForPointRule(config.getPointRule());
        var defaultSetEngine = self.setEngineForSetType(config.getSetType(), gameEngine);
        var decidingSetEngine = null;
        if (config.getSuperTie()) {
            decidingSetEngine = new SuperTieSetEngine();
        }
        self.matchEngine = new MatchEngine(
            config.getNumberOfSets(),
            defaultSetEngine,
            decidingSetEngine
        );
        if (config.getWarmUp()) {
            self.matchEngine.startWarmUp();
        }
    }

    private function setEngineForSetType(setType as Number, gameEngine as GameEngine) as SetEngine {
        if (setType == MatchConfig.SET_TYPE_PRO) {
            return new ProSetEngine(gameEngine);
        }
        if (setType == MatchConfig.SET_TYPE_MINI) {
            return new MiniSetEngine(gameEngine);
        }
        return new NormalSetEngine(gameEngine);
    }

    function incP1() as Boolean {
        return self.matchEngine.incP1();
    }

    function incP2() as Boolean {
        return self.matchEngine.incP2();
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
        self.matchEngine.endWarmUp();
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
