//
//  PushPlugin.h
//  CentralECMTablet
//
//  Created by emoclew123 on 2014. 9. 24..
//
//

#import <Cordova/CDVPlugin.h>
@interface PushNotification : CDVPlugin {
    NSDictionary *notificationMessage;
    BOOL    isInline;
    NSString *notificationCallbackId;
    NSString *callback;
    
    BOOL ready;
}

@property (nonatomic, copy) NSString *callbackId;
@property (nonatomic, copy) NSString *notificationCallbackId;
@property (nonatomic, copy) NSString *callback;

@property (nonatomic, strong) NSDictionary *notificationMessage;
@property BOOL                          isInline;

- (void) unregister:(CDVInvokedUrlCommand*)command;
- (void) register:(CDVInvokedUrlCommand*)command;

- (void)didRegisterForRemoteNotificationsWithDeviceToken:(NSData *)deviceToken;
- (void)didFailToRegisterForRemoteNotificationsWithError:(NSError *)error;

- (void)setNotificationMessage:(NSDictionary *)notification;
- (void)notificationReceived;
@end
