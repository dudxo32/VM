//
//  EntertainmentPlugin.h
//  CECMPad
//
//  Created by 넷아이디 on 12. 7. 16..
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//


#import <Cordova/CDVPlugin.h>
#import "OrderedDictionary.h"

#import <Util.h>

@interface EntertainmentPlugin : CDVPlugin{
    NSString* callbackID;
    
}

@property (nonatomic, copy) NSString* callbackID;

//- (void) Photo:(NSMutableArray*)arguments withDict: (NSMutableDictionary*)options;
//- (void) Video:(NSMutableArray*)arguments withDict: (NSMutableDictionary*)options;
- (void) Gallery:(NSMutableArray*)arguments withDict: (NSMutableDictionary*)options;
- (void) readFile : (CDVInvokedUrlCommand*)command;
- (void) appendBookmark : (CDVInvokedUrlCommand*)command;
- (void) appendBMFolder : (CDVInvokedUrlCommand*)command;
- (void) changeBMFolder : (CDVInvokedUrlCommand*)command;
- (void) removeBMFolder : (CDVInvokedUrlCommand*)command;
- (void) changeBMFolOrder : (CDVInvokedUrlCommand*)command;

@end

