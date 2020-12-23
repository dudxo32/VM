//
//  utilsocket.m
//  ClouDoc
//
//  Created by emoclew123 on 2016. 3. 31..
//
//

#import <Foundation/Foundation.h>
#import "ProxyConnect.h"

@implementation ProxyConnect

@synthesize callbackID;

- (void) proxyconn:(CDVInvokedUrlCommand*)command{
    self.callbackID = command.callbackId;
    
    NSString *protocol = [command.arguments objectAtIndex:0];
    NSString *port = [command.arguments objectAtIndex:1];
    NSString *server = [command.arguments objectAtIndex:2];
    NSString *strMethod = [command.arguments objectAtIndex:3];
    NSString *strTarget = [command.arguments objectAtIndex:4];
    NSString *paraData = [command.arguments objectAtIndex:5];
    NSString *paraCookie = [command.arguments objectAtIndex:6];
    
    NSData *postData = [paraData dataUsingEncoding:NSASCIIStringEncoding allowLossyConversion:YES];
    
    NSString* proxyHost = @"1.212.69.220";
    NSNumber* proxyPort = [NSNumber numberWithInt: 53334];
    
    // Create an NSURLSessionConfiguration that uses the proxy
    NSDictionary *proxyDict = @{
                                @"HTTPEnable"  : [NSNumber numberWithInt:1],
                                (NSString *)kCFStreamPropertyHTTPProxyHost  : proxyHost,
                                (NSString *)kCFStreamPropertyHTTPProxyPort  : proxyPort,
                                
                                @"HTTPSEnable" : [NSNumber numberWithInt:1],
                                (NSString *)kCFStreamPropertyHTTPSProxyHost : proxyHost,
                                (NSString *)kCFStreamPropertyHTTPSProxyPort : proxyPort,
                                };
    
    NSURLSessionConfiguration *configuration = [NSURLSessionConfiguration ephemeralSessionConfiguration];
    configuration.connectionProxyDictionary = proxyDict;
//    protocol, port, Server, strMethod, strTarget, paraData, paraCookie)
    
    // Create a NSURLSession with our proxy aware configuration
    NSURLSession *session = [NSURLSession sessionWithConfiguration:configuration delegate:self delegateQueue:[NSOperationQueue mainQueue]];
    
    // Form the request
    NSMutableURLRequest *request = [[[NSMutableURLRequest alloc] init] autorelease];
    
    
    NSString *smsURL = @"http://";
    smsURL = [smsURL stringByAppendingString:server];
    smsURL = [smsURL stringByAppendingString:strTarget];
    
    
    [request setURL:[NSURL URLWithString:smsURL]];
    [request setHTTPMethod:strMethod];
    [request setValue:@"application/x-www-form-urlencoded" forHTTPHeaderField:@"Content-Type"];
    [request setHTTPBody:postData];
    
    __block NSString *str = nil;
    // Dispatch the request on our custom configured session
    NSURLSessionDataTask *task = [session dataTaskWithRequest:request completionHandler:
                                  ^(NSData *data, NSURLResponse *response, NSError *error) {
                                      NSLog(@"NSURLSession got the response [%@]", response);
                                      NSLog(@"NSURLSession got the data [%@]", [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding]);
                                      str = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
                                      
                                      NSMutableString *stringToReturn = [NSMutableString stringWithString:str];
                                      
                                      //CDVPluginResult* pluginResult = [pluginResult resultWithStatus:CDVCommandStatus_OK messageAsString:[stringToReturn stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding]];
                                      
                                      CDVPluginResult* pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK messageAsString:stringToReturn];
                                      
                                      //    [self writeJavascript:[pluginResult toSuccessCallbackString:self.callbackID]];
                                      [self.commandDelegate sendPluginResult:pluginResult callbackId:command.callbackId];
                                      
                                  }];
    
    NSLog(@"Lets fire up the task!");
    [task resume];
    
}

@end
