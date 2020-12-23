//
//  ProxyPlugin.m
//  ClouDoc
//
//  Created by emoclew123 on 2016. 3. 31..
//
//

#import <Foundation/Foundation.h>
#import "ProxyPlugin.h"

@implementation ProxyPlugin

@synthesize callbackID;

- (void) save:(CDVInvokedUrlCommand*)command{
    self.callbackID = command.callbackId;

    NSString *host = [command.arguments objectAtIndex:0];
    NSString *port = [command.arguments objectAtIndex:1];
    NSString *use = [command.arguments objectAtIndex:2];
    
    [[NSUserDefaults standardUserDefaults] setValue :host forKey:@"ProxyHost"];
    [[NSUserDefaults standardUserDefaults] setValue :port forKey:@"ProxyPort"];
    [[NSUserDefaults standardUserDefaults] setValue :use forKey:@"ProxyUse"];
    
    
    NSString *ProxyHost = [[NSUserDefaults standardUserDefaults] stringForKey:@"ProxyHost"];
    NSString *ProxyPort = [[NSUserDefaults standardUserDefaults] stringForKey:@"ProxyPort"];
    NSString *ProxyUse = [[NSUserDefaults standardUserDefaults] stringForKey:@"ProxyUse"];
    
    
    if([ProxyUse  isEqual: @"1"]){
        // Proxy Setting
        
        NSDictionary *proxyDict = @{
                                    (NSString *)kCFProxyHostNameKey     : ProxyHost,
                                    (NSString *)kCFProxyPortNumberKey   : ProxyPort,
                                    (NSString *)kCFProxyTypeKey         : (NSString *)kCFProxyTypeHTTP
                                    };
        
        NSURLSessionConfiguration *configuration = [NSURLSessionConfiguration defaultSessionConfiguration];
        [configuration setConnectionProxyDictionary:proxyDict];
        
        
    } else {
        
        // release Proxy Setting
        NSDictionary *proxyDict = @{
                                    (NSString *)kCFProxyHostNameKey     : @"kCFProxyHostNameKey",
                                    (NSString *)kCFProxyPortNumberKey   : @"kCFProxyPortNumberKey",
                                    (NSString *)kCFProxyTypeKey         : @"kCFProxyTypeKey"
                                    };
        
        NSURLSessionConfiguration *configuration = [NSURLSessionConfiguration defaultSessionConfiguration];
        [configuration setConnectionProxyDictionary:proxyDict];
    }

    
}

- (void) load:(CDVInvokedUrlCommand*)command{
    self.callbackID = command.callbackId;
    
    NSString *host = [[NSUserDefaults standardUserDefaults] stringForKey:@"ProxyHost"];
    NSString *port = [[NSUserDefaults standardUserDefaults] stringForKey:@"ProxyPort"];
    NSString *use = [[NSUserDefaults standardUserDefaults] stringForKey:@"ProxyUse"];
    
    NSString *result = [host stringByAppendingString:@"\t"];
    result = [result stringByAppendingString:port];
    result = [result stringByAppendingString:@"\t"];
    result = [result stringByAppendingString:use];
    NSLog(@"Proxy load result string = %@", result);
    
    NSMutableString *stringToReturn = [NSMutableString stringWithString:result];
    
    //CDVPluginResult* pluginResult = [pluginResult resultWithStatus:CDVCommandStatus_OK messageAsString:[stringToReturn stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding]];
    CDVPluginResult* pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK messageAsString:stringToReturn];
    //    [self writeJavascript:[pluginResult toSuccessCallbackString:self.callbackID]];
    [self.commandDelegate sendPluginResult:pluginResult callbackId:command.callbackId];
}
@end
