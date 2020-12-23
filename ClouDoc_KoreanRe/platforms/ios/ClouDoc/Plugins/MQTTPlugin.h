//
//  Header.h
//  ClouDoc
//
//  Created by emoclew123 on 2016. 3. 30..
//
//

#import <Cordova/CDVPlugin.h>
#import "MQTTClient.h"
#import <MQTTWebsocketTransport.h>

@interface MQTTPlugin : CDVPlugin {
    NSString* callbackID;
}

@property (nonatomic, copy) NSString* callbackID;

- (void) connect:(CDVInvokedUrlCommand*)command;
- (void) disconnect:(CDVInvokedUrlCommand*)command;

@end
