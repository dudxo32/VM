/*
 * PhoneGap is available under *either* the terms of the modified BSD license *or* the
 * MIT License (2008). See http://opensource.org/licenses/alphabetical for full text.
 *
 * Copyright 2012, Andrew Lunny, Adobe Systems
 * Copyright (c) 2005-2010, Nitobi Software Inc.
 * Copyright (c) 2011, IBM Corporation
 * (c) 2010 Jesse MacFadyen, Nitobi
 */


var DeviceStatus = (function (gap) {
                  function isFunction(f) {
                  return typeof f === "function";
                  }
                  
                  // placeholder and constants
                  function DeviceStatus() {
                  }
                  
                  
                  /*
                   * Maintain API consistency with iOS
                   */
                  DeviceStatus.install = function () {
                  console.log('DeviceStatus.install is deprecated');
                  }
                  
                  /**
                   * Load ChildBrowser
                   */
                  if (!window.plugins) {
                  window.plugins = {};
                  }
                  if (!window.plugins.DeviceStatus) {
                  window.plugins.DeviceStatus = new DeviceStatus();
                    }
                    
                  });





DeviceStatus.prototype.deletefiles = function(successCallback, failureCallback, webserver, siteid) {
    return   cordova.exec(successCallback, failureCallback, "DeviceStatusPlugin", "DeleteFiles", [webserver, siteid]);
    
};

DeviceStatus.prototype.locationinfo = function(successCallback, failureCallback, webserver, siteid) {
    return   cordova.exec(successCallback, failureCallback, "DeviceStatusPlugin", "LocationInfo", [webserver, siteid]);
    
};

DeviceStatus.prototype.logout = function(successCallback, failureCallback) {
    return   cordova.exec(successCallback, failureCallback, "DeviceStatusPlugin", "LogOut", []);
    
};