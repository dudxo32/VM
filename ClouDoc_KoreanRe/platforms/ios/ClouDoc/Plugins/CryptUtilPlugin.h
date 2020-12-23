//
//  CryptUtilPlugin.h
//  ECM_Tablet
//
//  Created by 넷아이디 on 11. 12. 20..
//  Copyright (c) 2011 __MyCompanyName__. All rights reserved.
//

#import <Cordova/CDVPlugin.h>
#import "Util.h"

@interface CryptUtilPlugin : CDVPlugin {
    NSString* callbackID;
}

@property (nonatomic, copy) NSString* callbackID;

- (NSString *) encode: (NSString *) str 
			  withKey: (NSString *) key;

- (NSString *) decode: (NSString *) str 
			  withKey: (NSString *) key;

- (void) login:(CDVInvokedUrlCommand*)command;
- (void) paramencrypt:(CDVInvokedUrlCommand*)command;
- (void) logoimg:(CDVInvokedUrlCommand*)command;
- (void) saveParam:(CDVInvokedUrlCommand*)command;
- (void) getlogoimg: (NSString *) server
               with: (NSString *) port
               with: (NSString *) DomainID;
@end
