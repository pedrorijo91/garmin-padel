using Toybox.WatchUi;
using Toybox.System;

class UndoConfirmationDelegate extends WatchUi.ConfirmationDelegate {
    function initialize() {
        ConfirmationDelegate.initialize();
    }

    function onResponse(response) {
        if (response == WatchUi.CONFIRM_YES) {
            Application.getApp().getMatch().undo();
        }

		return true;
    }
}