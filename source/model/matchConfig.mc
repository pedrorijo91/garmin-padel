import Toybox.Lang;

class matchConfig {

    public static const UNLIMITED_SETS = 10;

    private var numberOfSets;

    function initialize() {
        numberOfSets =  UNLIMITED_SETS;    
    }

    function setNumberOfSets(sets as Number) as Void {
        self.numberOfSets = sets;
    }

    function getNumberOfSets() as Number {
        return self.numberOfSets;
    }

    function toString() as Lang.String  {
        return "matchConfig: " + "sets: " + self.numberOfSets;
    }

}