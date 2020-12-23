//
//  Header.h
//  ClouDoc
//
//  Created by emoclew123 on 2016. 3. 31..
//
//

#import <Cordova/CDVPlugin.h>

@interface ProxyPlugin : CDVPlugin {
    NSString* callbackID;
}

@property (nonatomic, copy) NSString* callbackID;

- (void) save:(CDVInvokedUrlCommand*)command;
- (void) load:(CDVInvokedUrlCommand*)command;

@end
