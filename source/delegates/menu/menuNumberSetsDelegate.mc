import Toybox.Lang;
import Toybox.System;
import Toybox.WatchUi;

class menuNumberSetsDelegate extends WatchUi.MenuInputDelegate {

    function initialize() {
        MenuInputDelegate.initialize();
    }

    function onMenuItem(item as Symbol) as Void {
        
        var nbrSets = matchConfig.UNLIMITED_SETS;

         switch (item) {
            case :sets_unlimited: {
                break;
            }
            case :sets_5: {
                nbrSets = 5;
                break;
            }
            case :sets_3: {
                nbrSets = 3;
                break;
            }
        }

        Application.getApp().getMatchConfig().setNumberOfSets(nbrSets);

        // if not unlimited sets, lets ask about super tie config
        if (nbrSets != matchConfig.UNLIMITED_SETS) {
            WatchUi.pushView(new Rez.Menus.SuperTieMenu(), new menuSuperTieDelegate(), WatchUi.SLIDE_BLINK);
        } else {
            Application.getApp().initMatch();
            WatchUi.pushView(new scoreView(), new scoreDelegate(), WatchUi.SLIDE_UP);
        }
    }

}