/*
 * PhoneGap is available under *either* the terms of the modified BSD license *or* the
 * MIT License (2008). See http://opensource.org/licenses/alphabetical for full text.
 *
 * Copyright 2012, Andrew Lunny, Adobe Systems
 * Copyright (c) 2005-2010, Nitobi Software Inc.
 * Copyright (c) 2011, IBM Corporation
 * (c) 2010 Jesse MacFadyen, Nitobi
 */

var AppManager = (function (gap) {
                 function isFunction(f) {
                 return typeof f === "function";
                 }
                 
                 // placeholder and constants
                 function AppManager() {
                 }
                 
                 
                 /**
                  * Maintain API consistency with iOS
                  */
                 AppManager.install = function () {
                 console.log('CryptUtil.install is deprecated');
                 }
                 
                 /**
                  * Load ChildBrowser
                  */
                 if(!window.plugins) {
                 window.plugins = {};
                 }
                 if (!window.plugins.AppManager) {
                 window.plugins.AppManager = new AppManager();
                 }
                 
                 });


AppManager.prototype.callapp = function(successCallback, failureCallback, filepath, extension, flag, openflag, siteid, user) {
    return   cordova.exec(successCallback, failureCallback, "AppManagerPlugin", "callapplication", [filepath, extension, flag, openflag, siteid, user]);
};

AppManager.prototype.finishapp = function(successCallback, failureCallback) {
    return   cordova.exec(successCallback, failureCallback, "AppManagerPlugin", "finishapp", []);
};

AppManager.prototype.auth_get = function(successCallback, failureCallback) {
    return   cordova.exec(successCallback, failureCallback, "AppManagerPlugin", "auth_get", []);
};

AppManager.prototype.auth_check = function(successCallback, failureCallback) {
    return   cordova.exec(successCallback, failureCallback, "AppManagerPlugin", "auth_check", []);
};

AppManager.prototype.auth_logout = function(successCallback, failureCallback) {
    return   cordova.exec(successCallback, failureCallback, "AppManagerPlugin", "auth_logout", []);
};