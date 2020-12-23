
/**
 *
 * @return Instance of DirectoryListing
 */

var AlertMessage = function() {
}

/**
 * @param directory The directory for which we want the listing
 * @param successCallback The callback which will be called when directory listing is successful
 * @param failureCallback The callback which will be called when directory listing encouters an error
 */
AlertMessage.prototype.call = function(successCallback, failureCallback, message) {
    return   PhoneGap.exec(successCallback, failureCallback, "AlertMessagePlugin", "alert", [message]);
    
};

/**
 * <ul>
 * <li>Register the Directory Listing Javascript plugin.</li>
 * <li>Also register native call which will be called when this plugin runs</li>
 * </ul>
 */
if(!window.plugins) {
    window.plugins = {};
}
if (!window.plugins.AlertMessage) {
    window.plugins.AlertMessage = new AlertMessage();
}
