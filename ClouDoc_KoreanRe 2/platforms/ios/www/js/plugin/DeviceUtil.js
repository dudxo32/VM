/*
 * PhoneGap is available under *either* the terms of the modified BSD license *or* the
 * MIT License (2008). See http://opensource.org/licenses/alphabetical for full text.
 *
 * Copyright 2012, Andrew Lunny, Adobe Systems
 * Copyright (c) 2005-2010, Nitobi Software Inc.
 * Copyright (c) 2011, IBM Corporation
 * (c) 2010 Jesse MacFadyen, Nitobi
 */


var DeviceUtil = (function (gap) {
                    function isFunction(f) {
                        return typeof f === "function";
                    }

                    // placeholder and constants
                    function DeviceUtil() {
                    }


                    /*
                     * Maintain API consistency with iOS
                     */
                    DeviceUtil.install = function () {
                        console.log('DeviceUtil.install is deprecated');
                    }

                    /**
                     * Load ChildBrowser
                     */
                    if (!window.plugins) {
                        window.plugins = {};
                    }
                    if (!window.plugins.DeviceUtil) {
                        window.plugins.DeviceUtil = new DeviceUtil();
                    }
                  
                    });



DeviceUtil.prototype.DevicePlatform = function(successCallback, failureCallback) {
    return   cordova.exec(successCallback, failureCallback, "DeviceUtilPlugin", "Platform", []);
};

DeviceUtil.prototype.langID = function(successCallback, failureCallback) {
    return   cordova.exec(successCallback, failureCallback, "DeviceUtilPlugin", "LangID", []);
};

DeviceUtil.prototype.progress = function(successCallback, failureCallback, process) {
    return   cordova.exec(successCallback, failureCallback, "DeviceUtilPlugin", "progress", [process]);
};

DeviceUtil.prototype.Use3G = function(successCallback, failureCallback) {
    return   cordova.exec(successCallback, failureCallback, "DeviceUtilPlugin", "Use3G", []);
};

DeviceUtil.prototype.alert = function(successCallback, failureCallback, message) {
    return   cordova.exec(successCallback, failureCallback, "DeviceUtilPlugin", "Alert", [message]);
};

DeviceUtil.prototype.confirm = function(successCallback, failureCallback, message) {
    return   cordova.exec(successCallback, failureCallback, "DeviceUtilPlugin", "confirm", [message]);
};

DeviceUtil.prototype.getlocalRoot = function(successCallback, failureCallback) {
    return   cordova.exec(successCallback, failureCallback, "DeviceUtilPlugin", "getlocalRoot", []);
};

DeviceUtil.prototype.LogOut = function(successCallback, failureCallback) {
    return   cordova.exec(successCallback, failureCallback, "DeviceUtilPlugin", "LogOut", []);
};

DeviceUtil.prototype.alertCrashLog = function(successCallback, failureCallback) {
    return   cordova.exec(successCallback, failureCallback, "DeviceUtilPlugin", "alertCrashLog", []);
};
