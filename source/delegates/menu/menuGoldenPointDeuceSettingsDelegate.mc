import Toybox.Lang;
import Toybox.System;
import Toybox.WatchUi;

class MenuGoldenPointDeuceSettingsDelegate extends WatchUi.MenuInputDelegate {

    function initialize() {
        MenuInputDelegate.initialize();
    }

    function onMenuItem(item as Symbol) as Void {
        
        var nbrDeuces = 1;

         switch (item) {
            case :deuces_1: {
                nbrDeuces = 1;
                break;
            }
            case :deuces_2: {
                nbrDeuces = 2;
                break;
            }
        }

        Application.getApp().getMatchConfig().setNumberOfDeuces(nbrDeuces);
        WatchUi.pushView(new Rez.Menus.SetsMenu(), new MenuNumberSetsDelegate(), WatchUi.SLIDE_BLINK);

    }

}