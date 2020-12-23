/*
 * PhoneGap is available under *either* the terms of the modified BSD license *or* the
 * MIT License (2008). See http://opensource.org/licenses/alphabetical for full text.
 *
 * Copyright 2012, Andrew Lunny, Adobe Systems
 * Copyright (c) 2005-2010, Nitobi Software Inc.
 * Copyright (c) 2011, IBM Corporation
 * (c) 2010 Jesse MacFadyen, Nitobi
 */
var Activity = (function (gap) {
    function isFunction(f) {
        return typeof f === "function";
    }

    // placeholder and constants
    function Activity() {}

    var CLOSE_EVENT = 0,
        LOCATION_CHANGED_EVENT = 1,
        OPEN_EXTERNAL_EVENT = 2;

    /**
     * Function called when the child browser has an event.
     */
    function onEvent(data) {
        switch (data.type) {
            case CLOSE_EVENT:
                if (isFunction(Activity.onClose)) {
                    Activity.onClose();
                }
                break;
            case LOCATION_CHANGED_EVENT:
                if (isFunction(Activity.onLocationChange)) {
                    Activity.onLocationChange(data.location);
                }
                break;
            case OPEN_EXTERNAL_EVENT:
                if (isFunction(Activity.onOpenExternal)) {
                    Activity.onOpenExternal();
                }
                break;
        }
    }

    /**
     * Function called when the child browser has an error.
     */
    function onError(data) {
        if (isFunction(Activity.onError)) {
            Activity.onError(data);
        }
    }

    /**
     * Maintain API consistency with iOS
     */
    Activity.install = function () {
        console.log('Activity.install is deprecated');
    }



    /**
     * Load ChildBrowser
     */
                
                if(!window.plugins) {
                window.plugins = {};
                }
                if (!window.plugins.Activity) {
                window.plugins.Activity = new Activity();
                }


    return Activity;
});



/**
 * Display a new browser with the specified URL.
 * This method loads up a new web view in a dialog.
 *
 * @param url           The url to load
 * @param options       An object that specifies additional options
 */
Activity.showWebPage = function (url, options) {
    
    if (!options) {
        options = { showLocationBar: true };
    }
    cordova.exec(onEvent, onError, "ActivityView", "showWebPage", [url, options]);
};

/**
 * Close the browser opened by showWebPage.
 */
Activity.close = function () {
    cordova.exec(null, null, "Activity", "close", []);
};

/**
 * Display a new browser with the specified URL.
 * This method starts a new web browser activity.
 *
 * @param url           The url to load
 * @param usePhoneGap   Load url in PhoneGap webview [optional]
 */
ChildBrowser.openExternal = function(url, usePhoneGap) {
    
    if (usePhoneGap) {
        navigator.app.loadUrl(url);
    } else {
        cordova.exec(null, null, "Activity", "openExternal", [url, usePhoneGap]);
    }
};
