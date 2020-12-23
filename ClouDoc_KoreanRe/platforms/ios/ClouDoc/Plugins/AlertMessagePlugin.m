//
//  AlertMessagePlugin.m
//  CentralECMTablet
//
//  Created by Rusa on 12. 12. 14..
//
//

#import "AlertMessagePlugin.h"

@implementation AlertMessagePlugin

@synthesize callbackID;

- (void) alert:(NSMutableArray*)arguments withDict: (NSMutableDictionary*)options{
    self.callbackID = [arguments pop];
    
    NSString *stringObtainedFromJavascript = [arguments objectAtIndex:0];
    NSLog(@"stringObtainedFromJavascript is %@", stringObtainedFromJavascript);
    
    UIAlertView	*av = [[[UIAlertView alloc] initWithTitle:nil message:NSLocalizedString(stringObtainedFromJavascript, nil)
                                                 delegate:nil cancelButtonTitle:NSLocalizedString(@"Confirm",nil)
                                        otherButtonTitles:nil] autorelease];
    
    [av show];

    
    
    NSMutableString *stringToReturn = [NSMutableString stringWithString:@""];
    CDVPluginResult* pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK messageAsString:stringToReturn];
    [self writeJavascript:[pluginResult toSuccessCallbackString:self.callbackID]];
    
}
@end
