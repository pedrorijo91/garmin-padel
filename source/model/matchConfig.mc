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

    private var superTie as Boolean;
    private var setType as Number;
    private var numberOfSets as Number;
    private var pointRule as Number;

    function initialize() {
        superTie = false;
        numberOfSets = UNLIMITED_SETS;
        pointRule = POINT_RULE_GOLDEN;
        setType = SET_TYPE_NORMAL;
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

    function toString() as Lang.String {
        return "matchConfig: " + "superTie: " + self.superTie + ", sets: " + self.numberOfSets + ", pointRule: " + self.pointRule + ", setType: " + self.setType;
    }

}