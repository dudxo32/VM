//
//  PhoneGap ! ChildBrowserCommand
//
//
//  Created by Jesse MacFadyen on 10-05-29.
//  Copyright 2010 Nitobi. All rights reserved.
//

#import <Cordova/CDVPlugin.h>
#import "ActivityViewController_phone.h"

@interface ActivityViewCommand_phone : CDVPlugin <ActivityViewDelegate_phone>  { }

@property (nonatomic, retain) ActivityViewController_phone *ActView;
@property (nonatomic, strong) NSString *callbackId;

-(void) showWebPage:(NSMutableArray*)arguments withDict:(NSMutableDictionary*)options;

@end
