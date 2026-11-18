import Toybox.Lang;

class MatchConfig {

    public static const UNLIMITED_SETS = 20;

    public static const POINT_RULE_GOLDEN = 0;
    public static const POINT_RULE_ADVANTAGE = 1;
    public static const POINT_RULE_SILVER = 2;
    public static const POINT_RULE_STAR = 3;

    public static const SET_TYPE_NORMAL = 0;
    public static const SET_TYPE_PRO = 1;
    public static const SET_TYPE_MINI = 2;

    // Format of one set (segment) of the session. The first three match SET_TYPE_* one to one.
    // FORMAT_DEFAULT = whatever the match config says for that set (default set type, or the deciding super tie).
    // FORMAT_FREE = free play (training, warm-up): nothing is scored.
    public static const FORMAT_DEFAULT = -1;
    public static const FORMAT_NORMAL = 0;
    public static const FORMAT_PRO = 1;
    public static const FORMAT_MINI = 2;
    public static const FORMAT_TIE_BREAK = 3;
    public static const FORMAT_SUPER_TIE = 4;
    public static const FORMAT_FREE = 5;

    private var superTie as Boolean;
    private var setType as Number;
    private var numberOfSets as Number;
    private var pointRule as Number;
    // start the session in a warm-up phase (its own lap). Off by default; the setup menus turn it on.
    private var warmUp as Boolean;
    // players may switch the current set to a tie-break / super tie / mini set (Friendly and Custom only)
    private var formatSwitch as Boolean;
    // training session: free play by default, scored drills started from Options, never ends by itself
    private var training as Boolean;

    function initialize() {
        superTie = false;
        training = false;
        formatSwitch = false;
        numberOfSets = UNLIMITED_SETS;
        pointRule = POINT_RULE_GOLDEN;
        setType = SET_TYPE_NORMAL;
        warmUp = false;
    }

    function setWarmUp(enabled as Boolean) as Void {
        self.warmUp = enabled;
    }

    function getWarmUp() as Boolean {
        return self.warmUp;
    }

    function setPointRule(rule as Number) as Void {
        self.pointRule = rule;
    }

    function getPointRule() as Number {
        return self.pointRule;
    }

    function setGoldenPoint(goldenPoint as Boolean) as Void {
        self.pointRule = goldenPoint ? POINT_RULE_GOLDEN : POINT_RULE_ADVANTAGE;
    }

    function getGoldenPoint() as Boolean {
        return self.pointRule == POINT_RULE_GOLDEN;
    }

    function setSuperTie(enabled as Boolean) as Void {
        self.superTie = enabled;
    }

    function getSuperTie() as Boolean {
        return self.superTie;
    }

    function setNumberOfSets(sets as Number) as Void {
        self.numberOfSets = sets;
    }

    function getNumberOfSets() as Number {
        return self.numberOfSets;
    }

    function setSetType(type as Number) as Void {
        self.setType = type;
    }

    function getSetType() as Number {
        return self.setType;
    }

    function setFormatSwitch(enabled as Boolean) as Void {
        self.formatSwitch = enabled;
    }

    function getFormatSwitch() as Boolean {
        return self.formatSwitch;
    }

    function setTraining(enabled as Boolean) as Void {
        self.training = enabled;
    }

    function getTraining() as Boolean {
        return self.training;
    }

    function toString() as Lang.String {
        return "matchConfig: " + "superTie: " + self.superTie + ", sets: " + self.numberOfSets + ", pointRule: " + self.pointRule + ", setType: " + self.setType + ", formatSwitch: " + self.formatSwitch + ", training: " + self.training;
    }

}