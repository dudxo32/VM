/*
 * PhoneGap is available under *either* the terms of the modified BSD license *or* the
 * MIT License (2008). See http://opensource.org/licenses/alphabetical for full text.
 *
 * Copyright 2012, Andrew Lunny, Adobe Systems
 * Copyright (c) 2005-2010, Nitobi Software Inc.
 * Copyright (c) 2011, IBM Corporation
 * (c) 2010 Jesse MacFadyen, Nitobi
 */


var UpDownManager = (function (gap) {
                    function isFunction(f) {
                    return typeof f === "function";
                    }
                    
                    // placeholder and constants
                    function UpDownManager() {}
                    
                    
                    /**
                     * Maintain API consistency with iOS
                     */
                    UpDownManager.install = function () {
                    console.log('UpDownManager.install is deprecated');
                    }
                    
                     
                    
                    /**
                     * Load ChildBrowser
                     */
                     
                     
                     if (!window.plugins) {
                     window.plugins = {};
                     }
                     if (!window.plugins.UpDownManager) {
                     window.plugins.UpDownManager = new UpDownManager();
                     }

                    });


UpDownManager.prototype.download = function(successCallback, failureCallback, DomainID, DiskType, User, Partition, WebServer, Agent, Option, Cowork,
                                            ShareUser, SharePath, StartPath, OrgCode, path, FileServer,useSSL,FileServerPort, Flag, siteid, attribute, size, LocalCurrentPath, overwrite, offset, useProxy, fileInfo) {
    checkAuth();
    return   cordova.exec(successCallback, failureCallback, "UpDownManagerPlugin", "download", [DomainID, DiskType, User, Partition, WebServer, Agent, Option, Cowork,
                                                                                                 ShareUser, SharePath, StartPath, OrgCode, path, FileServer,useSSL,FileServerPort, Flag, siteid, attribute, size, LocalCurrentPath, overwrite, offset, useProxy, fileInfo]);
    
};

UpDownManager.prototype.upload = function(successCallback, failureCallback, DomainID, DiskType, User, Partition, WebServer, Agent, Option, Cowork,
                                          ShareUser, SharePath, StartPath, OrgCode, path, FileServer, useSSL, FileServerPort, siteid, LocalFilesPath, overwrite, offset) {
    checkAuth();
    return   cordova.exec(successCallback, failureCallback, "UpDownManagerPlugin", "upload", [DomainID, DiskType, User, Partition, WebServer, Agent, Option, Cowork,
                                                                                              ShareUser, SharePath, StartPath, OrgCode, path, FileServer,useSSL,FileServerPort, siteid, LocalFilesPath, overwrite, offset]);
};

UpDownManager.prototype.SetCookie = function(successCallback, failureCallback, DomainID, DiskType, User, Partition, WebServer, Agent, Option, Cowork,
                                             ShareUser, SharePath, StartPath, OrgCode, path, FileServer, useSSL, FileServerPort, siteid, LocalFilesPath, overwrite, offset) {
    checkAuth();
    return   cordova.exec(successCallback, failureCallback, "UpDownManagerPlugin", "setcookie", [DomainID, DiskType, User, Partition, WebServer, Agent, Option, Cowork,
                                                                                                  ShareUser, SharePath, StartPath, OrgCode, path, FileServer,useSSL,FileServerPort, siteid, LocalFilesPath, overwrite, offset]);
};


UpDownManager.prototype.cancel = function(successCallback, failureCallback) {
    return   cordova.exec(successCallback, failureCallback, "UpDownManagerPlugin", "cancel", []);
}

function checkAuth() {
    
    
    /*
     if(){
     
     } else {
     AM = new AppManager();
     AM.finishapp();
     }
     */
}
