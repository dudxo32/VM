//
//  DeviceStatusPlugin.m
//  CECMPad
//
//  Created by 넷아이디 on 12. 5. 16..
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "DeviceStatusPlugin.h"
#import "FileUtil.h"
#import "ServerCmd.h"
#import "Util.h"
#import "ReceiveDataViewController.h"
@implementation DeviceStatusPlugin

@synthesize callbackID;
@synthesize WebServer;
@synthesize SiteID;

// 분실 신고시 파일 삭제 함수
- (void) DeleteFiles:(CDVInvokedUrlCommand*)command{
    
//    self.callbackID = [arguments pop];
//    self.callbackID = [command.arguments objectAtIndex:0];
    self.callbackID = command.callbackId;
    NSString *stringObtainedFromJavascript = [command.arguments objectAtIndex:0];
    NSLog(@"stringObtainedFromJavascript is %@", stringObtainedFromJavascript);
    
    self.SiteID = [command.arguments objectAtIndex:1];
    self.WebServer = stringObtainedFromJavascript;

    
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *currentFolder = [[NSString alloc] initWithString:[paths objectAtIndex:0]];
    NSFileManager *fileMgr = [NSFileManager defaultManager];
    [fileMgr removeItemAtPath:[currentFolder stringByAppendingPathComponent:@"."]  error: NULL];

    locationManager = [ [ CLLocationManager alloc] init];
    if([locationManager locationServicesEnabled]){
        locationManager.delegate = self;
        locationManager.distanceFilter = kCLDistanceFilterNone;
        locationManager.desiredAccuracy = kCLLocationAccuracyBest; //10M
        [locationManager startUpdatingLocation];
    }
    
    NSMutableString *stringToReturn = [NSMutableString stringWithString:@"Lost Device"];
    
    //CDVPluginResult* pluginResult = [pluginResult resultWithStatus:CDVCommandStatus_OK messageAsString:[stringToReturn stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding]];
     CDVPluginResult* pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK messageAsString:stringToReturn];
//    [self writeJavascript:[pluginResult toSuccessCallbackString:self.callbackID]];
    [self.commandDelegate sendPluginResult:pluginResult callbackId:command.callbackId];
    
}

// 위치 정보 함수
- (void) LocationInfo:(CDVInvokedUrlCommand*)command{
    
    //self.callbackID = [arguments pop];
//    self.callbackID = [command.arguments objectAtIndex:0];
    self.callbackID = command.callbackId;
    NSString *stringObtainedFromJavascript = [command.arguments objectAtIndex:0];
    NSLog(@"stringObtainedFromJavascript is %@", stringObtainedFromJavascript);
    
    self.SiteID = [command.arguments objectAtIndex:1];
    self.WebServer = stringObtainedFromJavascript;
    
//    g_FileUtil = [FileUtil alloc];
//	// ../ECM/.. 폴더 삭제
//	[g_FileUtil deleteFile:[NSString stringWithFormat:@"%@/ECM", [g_FileUtil getDocumentFolder]]];

    locationManager = [ [ CLLocationManager alloc] init];
    if([locationManager locationServicesEnabled]){
        locationManager.delegate = self;
        locationManager.distanceFilter = kCLDistanceFilterNone;
        locationManager.desiredAccuracy = kCLLocationAccuracyBest; //10M
        [locationManager startUpdatingLocation];
    }
    
    NSMutableString *stringToReturn = [NSMutableString stringWithString:@"Stop Device"];
    
 
     CDVPluginResult* pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK messageAsString:stringToReturn];
//    [self writeJavascript:[pluginResult toSuccessCallbackString:self.callbackID]];
    [self.commandDelegate sendPluginResult:pluginResult callbackId:command.callbackId];
    
}


- (void) locationManager:(CLLocationManager *)manager 
              didFailWithError:(NSError *)error{
    NSLog(@"Location Update Failed");
    
    locaininfo = @"NO Location Information";
    
    char* macAddressString= (char*)malloc(18);
    NSString *macAddress= [[NSString alloc] initWithCString:getMacAddress(macAddressString, "en0")
                                                   encoding:NSMacOSRomanStringEncoding];
    NSLog(@" %@ ", macAddress);
    
    
    
    NSString *DeviceID = [Util md5:macAddress ];
    
    NSLog(@" %@ ", DeviceID);
  
//    NSString *DeviceID = [[UIDevice currentDevice] uniqueIdentifier];
//    NSLog(@"DeviceID is %@", DeviceID);
    
    NSLog(@"WebServer is %@", self.WebServer);
    
    ServerCmd	*serverCmd = [[ServerCmd alloc] init];
    [serverCmd DeviceGPS:locaininfo DeviceID:DeviceID WebServer:self.WebServer SiteID:self.SiteID];
}
- (void) locationManager:(CLLocationManager *)manager 
           didUpdateToLocation:(CLLocation *)newLocation 
                  fromLocation:(CLLocation *)oldLocation{
    double  latitude;
    double  longtitude;
    
    latitude = newLocation.coordinate.latitude; //위도 정보
    longtitude = newLocation.coordinate.longitude; //경보 정보
    
    NSString *la = [NSString stringWithFormat:@"%g", latitude];
    
    NSString *lo = [NSString stringWithFormat:@"%g", longtitude];
    
    NSLog(@"%@, %@ ", la, lo);
    la = [la stringByAppendingString:@","];
    locaininfo = [la stringByAppendingString:lo];
    NSLog(@"locationinfo is %@", locaininfo);

    char* macAddressString= (char*)malloc(18);
    NSString *macAddress= [[NSString alloc] initWithCString:getMacAddress(macAddressString,"en0")
                                                   encoding:NSMacOSRomanStringEncoding];
    NSLog(@" %@ ", macAddress);
    
    
    
    NSString *DeviceID = [Util md5:macAddress ];
    
    NSLog(@" %@ ", DeviceID);
//    NSString *DeviceID = [[UIDevice currentDevice] uniqueIdentifier];
//    NSLog(@"DeviceID is %@", DeviceID);
    
    NSLog(@"WebServer is %@", self.WebServer);
    ServerCmd	*serverCmd = [[ServerCmd alloc] init];
    [serverCmd DeviceGPS:locaininfo DeviceID:DeviceID WebServer:self.WebServer SiteID:self.SiteID];
}

@end
