//
//  AppManagerPlugin.m
//  ClouDoc
//
//  Created by emoclew123 on 2016. 4. 26..
//
//

#import <Foundation/Foundation.h>
#import "AppManagerPlugin.h"

@implementation AppManagerPlugin

@synthesize callbackID;

- (void) callapplication:(CDVInvokedUrlCommand *)command{
    self.callbackID = command.callbackId;
    NSLog(@"callapplication");

}

- (void) finishapp:(CDVInvokedUrlCommand *)command{
    self.callbackID = command.callbackId;
    
    NSLog(@"Finish App");
    
    exit(0);
}

- (void) auth_get:(CDVInvokedUrlCommand*)command{
    self.callbackID = command.callbackId;
    
    NSDictionary *infoDic = [[NSBundle mainBundle] infoDictionary];
    NSString *appVersion = [infoDic objectForKey:@"CFBundleShortVersionString"];
    
    NSString *UrlString = @"tmckoreanre://?schemes=netidcloudoc&ver=";
    UrlString = [UrlString stringByAppendingString:appVersion];
    UrlString = [UrlString stringByAppendingString:@"&mode=get"];
    
    NSURL *url = [NSURL URLWithString:UrlString];
    if([[UIApplication sharedApplication] canOpenURL:url]) {
        [[UIApplication sharedApplication] openURL:url];
    }
    
    CDVPluginResult* pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK];
    
    //    [self writeJavascript:[pluginResult toSuccessCallbackString:self.callbackID]];
    [self.commandDelegate sendPluginResult:pluginResult callbackId:command.callbackId];
}

- (void) auth_check:(CDVInvokedUrlCommand*)command{
    self.callbackID = command.callbackId;
    
    NSDictionary *infoDic = [[NSBundle mainBundle] infoDictionary];
    NSString *appVersion = [infoDic objectForKey:@"CFBundleShortVersionString"];
    
    NSString *UrlString = @"tmckoreanre://?schemes=netidcloudoc&ver=";
    UrlString = [UrlString stringByAppendingString:appVersion];
    UrlString = [UrlString stringByAppendingString:@"&mode=check"];
    
    NSURL *url = [NSURL URLWithString:UrlString];
    if([[UIApplication sharedApplication] canOpenURL:url]) {
        [[UIApplication sharedApplication] openURL:url];
    }
    
    CDVPluginResult* pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK];
    
    //    [self writeJavascript:[pluginResult toSuccessCallbackString:self.callbackID]];
    [self.commandDelegate sendPluginResult:pluginResult callbackId:command.callbackId];
}

- (void) auth_logout:(CDVInvokedUrlCommand*)command{
    self.callbackID = command.callbackId;
    
    NSDictionary *infoDic = [[NSBundle mainBundle] infoDictionary];
    NSString *appVersion = [infoDic objectForKey:@"CFBundleShortVersionString"];
    
    NSString *UrlString = @"tmckoreanre://?schemes=netidcloudoc&ver=";
    UrlString = [UrlString stringByAppendingString:appVersion];
    UrlString = [UrlString stringByAppendingString:@"&mode=logout"];
    
    NSURL *url = [NSURL URLWithString:UrlString];
    if([[UIApplication sharedApplication] canOpenURL:url]) {
        [[UIApplication sharedApplication] openURL:url];
    }
    
    CDVPluginResult* pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK];
    
    //    [self writeJavascript:[pluginResult toSuccessCallbackString:self.callbackID]];
    [self.commandDelegate sendPluginResult:pluginResult callbackId:command.callbackId];
}

@end