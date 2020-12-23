//
//  DeviceStatusPlugin.h
//  CECMPad
//
//  Created by 넷아이디 on 12. 5. 16..
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//


#import <Cordova/CDVPlugin.h>
#import "ChildBrowserViewController.h"
#import "CentralECMAppDelegate.h"
#import "CoreLocation/CoreLocation.h"
#import "Macaddress.h"
@interface DeviceStatusPlugin : CDVPlugin <CLLocationManagerDelegate>{
    NSString                *callbackID;
    CentralECMAppDelegate   *appDelegate;
    CLLocationManager       *locationManager;
    NSString                *locaininfo;
    NSString                *WebServer;
    NSString                *SiteID;
}

@property (nonatomic, copy)     NSString* callbackID;
@property (nonatomic, retain)   NSString* WebServer;
@property (nonatomic, retain)   NSString* SiteID;
- (void) DeleteFiles:(CDVInvokedUrlCommand*)command;
- (void) LocationInfo:(CDVInvokedUrlCommand*)command;
- (void) locationManager:(CLLocationManager *)manager didFailWithError:(NSError *)error;
- (void) locationManager:(CLLocationManager *)manager didUpdateToLocation:(CLLocation *)newLocation fromLocation:(CLLocation *)oldLocation;

@end
