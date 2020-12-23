//
//  PhoneGap ! ChildBrowserCommand
//
//
//  Created by Jesse MacFadyen on 10-05-29.
//  Copyright 2010 Nitobi. All rights reserved.
//

#import <Cordova/CDVPlugin.h>
#import "ActivityViewController.h"

@interface ActivityViewCommand : CDVPlugin <ActivityViewDelegate>  { }

@property (nonatomic, retain) ActivityViewController *ActView;
@property (nonatomic, strong) NSString *callbackId;

-(void) showWebPage:(NSMutableArray*)arguments withDict:(NSMutableDictionary*)options;

@end
