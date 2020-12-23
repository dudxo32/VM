/*
 * PhoneGap is available under *either* the terms of the modified BSD license *or* the
 * MIT License (2008). See http://opensource.org/licenses/alphabetical for full text.
 *
 * Copyright 2012, Andrew Lunny, Adobe Systems
 * Copyright (c) 2005-2010, Nitobi Software Inc.
 * Copyright (c) 2011, IBM Corporation
 * (c) 2010 Jesse MacFadyen, Nitobi
 */


var ProxyPlugin = (function (gap) {
                  function isFunction(f) {
                  return typeof f === "function";
                  }
                  
                  // placeholder and constants
                  function ProxyPlugin() {
                  }
                  
                  
                  /*
                   * Maintain API consistency with iOS
                   */
                  ProxyPlugin.install = function () {
                  console.log('DeviceUtil.install is deprecated');
                  }
                  
                  /**
                   * Load ChildBrowser
                   */
                  if (!window.plugins) {
                  window.plugins = {};
                  }
                  if (!window.plugins.ProxyPlugin) {
                  window.plugins.ProxyPlugin = new ProxyPlugin();
                  }
                  
                  });

ProxyPlugin.prototype.save = function(successCallback, failureCallback, ip, port, use) {
	return cordova.exec(null, null, "ProxyPlugin", "save", [ip, port, use]);
};

ProxyPlugin.prototype.load = function(successCallback, failureCallback) {
	return cordova.exec(null, null, "ProxyPlugin", "load", []);
};