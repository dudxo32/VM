
/**
 *  
 * @return Instance of DirectoryListing
 */


var UpDownManager = function() { 

}

/**
 * @param directory The directory for which we want the listing
 * @param successCallback The callback which will be called when directory listing is successful
 * @param failureCallback The callback which will be called when directory listing encouters an error
 */
UpDownManager.prototype.download = function(successCallback, failureCallback, DomainID, DiskType, User, Partition, WebServer, Agent, Option, Cowork,
											ShareUser, SharePath, StartPath, OrgCode, path, FileServer,useSSL,FileServerPort, Flag, siteid, attribute, size, LocalCurrentPath, overwrite, offset) {
	return   PhoneGap.exec(successCallback, failureCallback, "UpDownManagerPlugin", "download", [DomainID, DiskType, User, Partition, WebServer, Agent, Option, Cowork,
            ShareUser, SharePath, StartPath, OrgCode, path, FileServer,useSSL,FileServerPort, Flag, siteid, attribute, size, LocalCurrentPath, overwrite, offset]); 

};

UpDownManager.prototype.upload = function(successCallback, failureCallback, DomainID, DiskType, User, Partition, WebServer, Agent, Option, Cowork,
 		ShareUser, SharePath, StartPath, OrgCode, path, FileServer, useSSL, FileServerPort, siteid, LocalFilesPath, overwrite, offset) {
    return   PhoneGap.exec(successCallback, failureCallback, "UpDownManagerPlugin", "upload", [DomainID, DiskType, User, Partition, WebServer, Agent, Option, Cowork,
            ShareUser, SharePath, StartPath, OrgCode, path, FileServer,useSSL,FileServerPort, siteid, LocalFilesPath, overwrite, offset]); 
};


UpDownManager.prototype.cancel = function(successCallback, failureCallback) {
    return   PhoneGap.exec(successCallback, failureCallback, "UpDownManagerPlugin", "cancel", []);
}
/**
 * <ul>
 * <li>Register the Directory Listing Javascript plugin.</li>
 * <li>Also register native call which will be called when this plugin runs</li>
 * </ul>
 */


if (!window.plugins) {
    window.plugins = {};
}
if (!window.plugins.UpDownManager) {
    window.plugins.UpDownManager = new UpDownManager();
}
