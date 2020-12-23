/*
 * PhoneGap is available under *either* the terms of the modified BSD license *or* the
 * MIT License (2008). See http://opensource.org/licenses/alphabetical for full text.
 *
 * Copyright 2012, Andrew Lunny, Adobe Systems
 * Copyright (c) 2005-2010, Nitobi Software Inc.
 * Copyright (c) 2011, IBM Corporation
 * (c) 2010 Jesse MacFadyen, Nitobi
 */


var CryptUtil = (function (gap) {
                  function isFunction(f) {
                    return typeof f === "function";
                  }
                  
                  // placeholder and constants
                  function CryptUtil() {
                  }
                  
                  
                  /**
                   * Maintain API consistency with iOS
                   */
                  CryptUtil.install = function () {
                  console.log('CryptUtil.install is deprecated');
                  }
                  
                /**
                   * Load ChildBrowser
                   */
                 if(!window.plugins) {
                    window.plugins = {};
                 }
                 if (!window.plugins.CryptUtil) {
                    window.plugins.CryptUtil = new CryptUtil();
                 }

                  });

CryptUtil.prototype.call = function(successCallback, failureCallback, paraData, siteid) {
                 cordova.exec(successCallback, failureCallback, "CryptUtilPlugin", "paramencrypt", [paraData, siteid, "false"]);
};
                 
CryptUtil.prototype.login = function(successCallback, failureCallback, paraData, loginkey) {
               return cordova.exec(successCallback, failureCallback, "CryptUtilPlugin", "login", [paraData, loginkey, "false"]);
};
           
CryptUtil.prototype.decrypt = function(successCallback, failureCallback, siteid, user, src, dest) {
                 return   cordova.exec(successCallback, failureCallback, "CryptUtilPlugin", "decrypt", [siteid, user, src, dest]);
};
CryptUtil.prototype.logoimg = function(successCallback, failureCallback, mserver, mport,mdomainid) {
    return   cordova.exec(successCallback, failureCallback, "CryptUtilPlugin", "logoimg", [mserver, mport, mdomainid]);
};
CryptUtil.prototype.saveParam = function(successCallback, failureCallback, param) {
    return   cordova.exec(successCallback, failureCallback, "CryptUtilPlugin", "saveParam", [param]);
};




