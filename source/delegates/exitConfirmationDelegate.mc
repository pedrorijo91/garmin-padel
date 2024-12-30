using Toybox.WatchUi;
using Toybox.System;

class ExitConfirmationDelegate extends WatchUi.ConfirmationDelegate {
    function initialize() {
        ConfirmationDelegate.initialize();
    }

    function onResponse(response) {
        if (response == WatchUi.CONFIRM_YES) {
            Application.getApp().saveSession();
            System.exit();
        }

		return true;
    }
}