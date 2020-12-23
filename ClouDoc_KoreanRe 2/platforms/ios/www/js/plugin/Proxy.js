
/**
 *  
 * @return Instance of DirectoryListing
 */
var Proxy = function() { 
}

/**
 * @param directory The directory for which we want the listing
 * @param successCallback The callback which will be called when directory listing is successful
 * @param failureCallback The callback which will be called when directory listing encouters an error
 */
Proxy.prototype.save = function(successCallback, failureCallback, value) {
    return   PhoneGap.exec(successCallback, failureCallback, "ProxyPlugin", "save", [value]);
};

/**
 * <ul>
 * <li>Register the Directory Listing Javascript plugin.</li>
 * <li>Also register native call which will be called when this plugin runs</li>
 * </ul>
 */
PhoneGap.addConstructor(function() {
	//Register the javascript plugin with PhoneGap
	PhoneGap.addPlugin('Proxy', new Proxy());
});