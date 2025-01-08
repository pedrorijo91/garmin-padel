import Toybox.Lang;

class MatchConfig {

    public static const UNLIMITED_SETS = 10;

    private var superTie as Boolean;
    private var numberOfSets as Number;
    private var goldenPoint as Boolean;

    function initialize() {
        superTie = false; 
        numberOfSets =  UNLIMITED_SETS;   
        goldenPoint = true; 
    }

    function setGoldenPoint(goldenPoint as Boolean) as Void {
        self.goldenPoint = goldenPoint;
    }

    function getGoldenPoint() as Boolean {
        return self.goldenPoint;
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

    function toString() as Lang.String  {
        return "matchConfig: " + "superTie: " + self.superTie + ", sets: " + self.numberOfSets + ", golden: " + self.goldenPoint;
    }

}