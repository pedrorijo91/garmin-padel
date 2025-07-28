import Toybox.Lang;
import Toybox.System;
import Toybox.WatchUi;

class MenuNumberSetsDelegate extends WatchUi.Menu2InputDelegate {

    function initialize() {
        Menu2InputDelegate.initialize();
    }

    function onSelect(item as MenuItem) as Void {
        
        var nbrSets = MatchConfig.UNLIMITED_SETS;

         switch (item.getId()) {
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
        if (nbrSets != MatchConfig.UNLIMITED_SETS) {
            var menu = new WatchUi.Menu2({:title=>"Super Tie"});
                menu.addItem(
                    new MenuItem(
                        "Yes",
                        "",
                        :super_tie_yes,
                        {}
                    )
                );
                 menu.addItem(
                    new MenuItem(
                        "No",
                        "",
                        :super_tie_no,
                        {}
                    )
                );
                 menu.addItem(
                    new MenuItem(
                        "5",
                        "",
                        :sets_5,
                        {}
                    )
                );
                
        WatchUi.pushView(menu, new MenuSuperTieDelegate(), WatchUi.SLIDE_BLINK);
        } else {
            Application.getApp().initMatch();
            WatchUi.pushView(new ScoreView(), new ScoreDelegate(), WatchUi.SLIDE_UP);
        }
    }

}