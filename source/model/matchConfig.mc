import Toybox.Lang;

class matchConfig {

static const AVAILABLE_POINTS = [0, 15, 30, 40];

    private var superTie;

    function initialize() {
        superTie = false;       
    }

    function setSuperTie(enabled as Boolean) as Void {
        self.superTie = enabled;
    }

    function getSuperTie() as Boolean {
        return self.superTie;
    }

    function toString() as Lang.String  {
        return "matchConfig: " + "superTie: " + self.superTie;
    }

}