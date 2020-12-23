//
//  Header.h
//  ClouDoc
//
//  Created by emoclew123 on 2016. 3. 31..
//
//

#import <Cordova/CDVPlugin.h>

@interface ProxyConnect : CDVPlugin {
    NSString* callbackID;
}

@property (nonatomic, copy) NSString* callbackID;

- (void) proxyconn:(CDVInvokedUrlCommand*)command;

@end
