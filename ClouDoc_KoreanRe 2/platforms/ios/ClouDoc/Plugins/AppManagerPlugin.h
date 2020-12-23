//
//  AppManagerPlugin.h
//  ClouDoc
//
//  Created by emoclew123 on 2016. 4. 26..
//
//

#import <Cordova/CDVPlugin.h>

@interface AppManagerPlugin : CDVPlugin {
    NSString* callbackID;
}

@property (nonatomic, copy) NSString* callbackID;

- (void) callapplication:(CDVInvokedUrlCommand*)command;
- (void) finishapp:(CDVInvokedUrlCommand*)command;
- (void) auth_get:(CDVInvokedUrlCommand*)command;
- (void) auth_check:(CDVInvokedUrlCommand*)command;
- (void) auth_logout:(CDVInvokedUrlCommand*)command;

@end
