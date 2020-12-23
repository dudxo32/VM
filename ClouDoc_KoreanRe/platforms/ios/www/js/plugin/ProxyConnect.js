/*
 * PhoneGap is available under *either* the terms of the modified BSD license *or* the
 * MIT License (2008). See http://opensource.org/licenses/alphabetical for full text.
 *
 * Copyright 2012, Andrew Lunny, Adobe Systems
 * Copyright (c) 2005-2010, Nitobi Software Inc.
 * Copyright (c) 2011, IBM Corporation
 * (c) 2010 Jesse MacFadyen, Nitobi
 */


var ProxyConnect = (function (gap) {
                  function isFunction(f) {
                  return typeof f === "function";
                  }
                  
                  // placeholder and constants
                  function ProxyConnect() {
                  }
                  
                  
                  /*
                   * Maintain API consistency with iOS
                   */
                  ProxyConnect.install = function () {
                  console.log('DeviceUtil.install is deprecated');
                  }
                  
                  /**
                   * Load ChildBrowser
                   */
                  if (!window.plugins) {
                  window.plugins = {};
                  }
                  if (!window.plugins.ProxyConnect) {
                  window.plugins.ProxyConnect = new ProxyConnect();
                  }
                  
                  });

ProxyConnect.prototype.proxyconn = function(successCallback, failureCallback, protocol, port, Server, strMethod, strTarget, paraData, paraCookie) {
    return cordova.exec(successCallback, failureCallback, "ProxyConnect", "proxyconn", [protocol, port, Server, strMethod, strTarget, paraData, paraCookie]);
};