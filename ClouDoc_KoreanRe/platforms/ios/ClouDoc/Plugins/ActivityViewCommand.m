//
//  Created by Jesse MacFadyen on 10-05-29.
//  Copyright 2010 Nitobi. All rights reserved.
//  Copyright (c) 2011, IBM Corporation
//  Copyright 2011, Randy McMillan
//  Copyright 2012, Andrew Lunny, Adobe Systems
//

#import "ActivityViewCommand.h"
#import <Cordova/CDVViewController.h>

@implementation ActivityViewCommand

@synthesize callbackId, ActView;

- (id) initWithWebView:(UIWebView*)theWebView
{
    self = [super initWithWebView:theWebView];
    return self;
}

- (void) showWebPage:(NSMutableArray*)arguments withDict:(NSMutableDictionary*)options // args: url
{	
    self.callbackId = [arguments objectAtIndex:0];
	
    if (self.ActView == nil) {
#if __has_feature(objc_arc)
        self.ActView = [[ActivityViewController alloc] initWithScale:NO];
#else
        self.ActView = [[[ActivityViewController alloc] initWithScale:NO] autorelease];
#endif
        self.ActView.delegate = self;
        self.ActView.orientationDelegate = self.viewController;
    }

    NSLog(@"showLocationBar %d",(int)[[options objectForKey:@"showLocationBar"] boolValue]);

    if (([[UIDevice currentDevice] orientation] == UIDeviceOrientationLandscapeLeft) ||
        ([[UIDevice currentDevice] orientation] == UIDeviceOrientationLandscapeRight))
        
    {
        ActView.view.frame = CGRectMake(0, 0, 1024, 768);
        
    }
    else
    {
        ActView.view.frame = CGRectMake(0, 0, 768, 1024);
    }
    [self.viewController.view addSubview:ActView.view];
    //[self.viewController presentModalViewController:ActView animated:YES];
        
//    // objectAtIndex 0 is the callback id
//    NSString *url = (NSString*) [arguments objectAtIndex:1];
//    
//    [self.ActView resetControls];
//    [self.ActView loadURL:url];
//    if([options objectForKey:@"showAddress"]!=nil)
//        [childBrowser showAddress:[[options objectForKey:@"showAddress"] boolValue]];
//    if([options objectForKey:@"showLocationBar"]!=nil)
//        [childBrowser showLocationBar:[[options objectForKey:@"showLocationBar"] boolValue]];
//    if([options objectForKey:@"showNavigationBar"]!=nil)
//        [childBrowser showNavigationBar:[[options objectForKey:@"showNavigationBar"] boolValue]];
}

-(void) close:(NSMutableArray*)arguments withDict:(NSMutableDictionary*)options // args: url
{
    [self.ActView closeBrowser];
	
}

-(void) onClose
{
    [self.ActView release];
    
}

@end
