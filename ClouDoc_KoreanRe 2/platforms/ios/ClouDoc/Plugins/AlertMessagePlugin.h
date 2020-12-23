//
//  AlertMessagePlugin.h
//  CentralECMTablet
//
//  Created by Rusa on 12. 12. 14..
//
//

#import <Cordova/CDVPlugin.h>
#import "Util.h"

@interface AlertMessagePlugin : CDVPlugin {
    NSString* callbackID;
}

@property (nonatomic, copy) NSString* callbackID;

- (void) alert:(NSMutableArray*)arguments withDict: (NSMutableDictionary*)options;
@end
