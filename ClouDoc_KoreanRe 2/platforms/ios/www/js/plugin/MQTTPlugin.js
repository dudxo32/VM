/*
 * PhoneGap is available under *either* the terms of the modified BSD license *or* the
 * MIT License (2008). See http://opensource.org/licenses/alphabetical for full text.
 *
 * Copyright 2012, Andrew Lunny, Adobe Systems
 * Copyright (c) 2005-2010, Nitobi Software Inc.
 * Copyright (c) 2011, IBM Corporation
 * (c) 2010 Jesse MacFadyen, Nitobi
 */


var MQTTPlugin = (function (gap) {
                  function isFunction(f) {
                  return typeof f === "function";
                  }
                  
                  // placeholder and constants
                  function MQTTPlugin() {
                  }
                  
                  
                  /*
                   * Maintain API consistency with iOS
                   */
                  MQTTPlugin.install = function () {
                  console.log('DeviceUtil.install is deprecated');
                  }
                  
                  /**
                   * Load ChildBrowser
                   */
                  if (!window.plugins) {
                  window.plugins = {};
                  }
                  if (!window.plugins.MQTTPlugin) {
                  window.plugins.MQTTPlugin = new MQTTPlugin();
                  }
                  
                  });

MQTTPlugin.prototype.connect = function(successCallback, failureCallback, brokerIP, brokerPORT, userID, topics, ServiceCode, MQTTtoken) {
    return   cordova.exec(null, null, "MQTTPlugin", "connect", [brokerIP, brokerPORT, userID, topics, ServiceCode, MQTTtoken]);
};


MQTTPlugin.prototype.disconnect = function(successCallback, failureCallback) {
    return   cordova.exec(null, null, "MQTTPlugin", "disconnect", []);
};
