/*
 * PhoneGap is available under *either* the terms of the modified BSD license *or* the
 * MIT License (2008). See http://opensource.org/licenses/alphabetical for full text.
 *
 * Copyright 2012, Andrew Lunny, Adobe Systems
 * Copyright (c) 2005-2010, Nitobi Software Inc.
 * Copyright (c) 2011, IBM Corporation
 * (c) 2010 Jesse MacFadyen, Nitobi
 */

var Entertainment = (function (gap) {
                 function isFunction(f) {
                 return typeof f === "function";
                 }
                 
                 // placeholder and constants
                 function Entertainment() {
                 }
                 
                 
                 /**
                  * Maintain API consistency with iOS
                  */
                 Entertainment.install = function () {
                 console.log('Entertainment.install is deprecated');
                 }
                 
                 /**
                  * Load ChildBrowser
                  */
                 if(!window.plugins) {
                 window.plugins = {};
                 }
                 if (!window.plugins.Entertainment) {
                 window.plugins.Entertainment = new Entertainment();
                 }
                 
                 });



Entertainment.prototype.Photo = function(successCallback, failureCallback) {
    return   cordova.exec(successCallback, failureCallback, "EntertainmentPlugin", "Photo", []);
};


Entertainment.prototype.Video = function(successCallback, failureCallback) {
    return   cordova.exec(successCallback, failureCallback, "EntertainmentPlugin", "Video", []);
};

Entertainment.prototype.Gallery = function(successCallback, failureCallback, RetValue, Path, FileName, cameraFlag) {
    return   cordova.exec(successCallback, failureCallback, "EntertainmentPlugin", "Gallery", [RetValue, Path, FileName, cameraFlag]);
};

Entertainment.prototype.GalleryPhoto = function(successCallback, failureCallback) {
    return   cordova.exec(successCallback, failureCallback, "EntertainmentPlugin", "galleryphoto", []);
};

Entertainment.prototype.GalleryVideo = function(successCallback, failureCallback) {
    return   cordova.exec(successCallback, failureCallback, "EntertainmentPlugin", "galleryvideo", []);
};



Entertainment.prototype.getBMList = function(successCallback, failureCallback, userID) {
    return  cordova.exec(successCallback, failureCallback, "EntertainmentPlugin", "readFile", [GetlocalStorage("UserID")]);
}

Entertainment.prototype.appendBM = function(successCallback, failureCallback, User, folderName, path, fileInfo) {
    return  cordova.exec(successCallback, failureCallback, "EntertainmentPlugin", "appendBookmark", [User, folderName, path, fileInfo]);
}

Entertainment.prototype.changeBM = function(successCallback, failureCallback, User, folderName, fileInfo) {
    return  cordova.exec(successCallback, failureCallback, "EntertainmentPlugin", "changeBookmark", [User, folderName, fileInfo]);
}

Entertainment.prototype.removeBM = function(successCallback, failureCallback, User, folderName, path) {
    return  cordova.exec(successCallback, failureCallback, "EntertainmentPlugin", "removeBookmark", [User, folderName, path]);
}

Entertainment.prototype.appendBMFolder = function(successCallback, failureCallback, User, folderName, path) {
    return  cordova.exec(successCallback, failureCallback, "EntertainmentPlugin", "appendBMFolder", [User, folderName, path]);
}

Entertainment.prototype.changeBMFolder = function(successCallback, failureCallback, User, folderName, path) {
    return  cordova.exec(successCallback, failureCallback, "EntertainmentPlugin", "changeBMFolder", [User, folderName, path]);
}

Entertainment.prototype.removeBMFolder = function(successCallback, failureCallback, User, folderName, path) {
    return  cordova.exec(successCallback, failureCallback, "EntertainmentPlugin", "removeBMFolder", [User, folderName, path]);
}

Entertainment.prototype.changeBMFolOrder = function(successCallback, failureCallback, User, BMList) {
    return  cordova.exec(successCallback, failureCallback, "EntertainmentPlugin", "changeBMFolOrder", [User, BMList]);
}
