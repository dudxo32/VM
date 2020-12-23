//
//  MQTTPlugin.m
//  ClouDoc
//
//  Created by emoclew123 on 2016. 3. 30..
//
//

#import <Foundation/Foundation.h>
#import "MQTTPlugin.h"

@implementation MQTTPlugin

@synthesize callbackID;

- (void) connect:(CDVInvokedUrlCommand*)command{
    // brokerIP, brokerPORT, userID, topis
    
    self.callbackID = command.callbackId;
    
    // MQTT Setting
    MQTTWebsocketTransport *transport = [[MQTTWebsocketTransport alloc] init];
    transport.host = [command.arguments objectAtIndex:0];
    NSString *port = [command.arguments objectAtIndex:1];
    
    transport.port = [port intValue];

    MQTTSession *session = [[MQTTSession alloc] init];
    [session setClientId:[command.arguments objectAtIndex:2]];
    
    NSString *UserID = [command.arguments objectAtIndex:4];
    UserID = [UserID stringByAppendingString:@"\t"];
    UserID = [UserID stringByAppendingString:[command.arguments objectAtIndex:2]];
    
    NSString *token = [command.arguments objectAtIndex:5];
    
    session.userName = UserID;
    session.password = token;
    
    session.transport = transport;
    
    session.delegate = self;
    
    [session connectAndWaitTimeout:30];
    
    // Topic
    [session subscribeToTopic:[command.arguments objectAtIndex:3] atLevel:1 subscribeHandler:^(NSError *error, NSArray<NSNumber *> *gQoss){
        if (error) {
            NSLog(@"Subscription failed %@", error.localizedDescription);
        } else {
            NSLog(@"Subscription sucessfull! Granted Qos: %@", gQoss);
        }
    }];
    
 }

- (void) disconnect:(CDVInvokedUrlCommand*)command{
}
@end
