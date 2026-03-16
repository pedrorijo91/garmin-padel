import Toybox.Lang;

// Thin facade: builds MatchEngine from MatchConfig and delegates all scoring/state to it.
// Keeps the same public API for views and delegates.
class PadelMatch {

    private var matchEngine as MatchEngine;

    function initialize(config as MatchConfig) {
        var gameEngine = self.gameEngineForPointRule(config.getPointRule());
        var defaultSetEngine = new NormalSetEngine(gameEngine);
        var decidingSetEngine = null;
        if (config.getSuperTie()) {
            decidingSetEngine = new SuperTieSetEngine();
        }
        self.matchEngine = new MatchEngine(
            config.getNumberOfSets(),
            defaultSetEngine,
            decidingSetEngine
        );
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
