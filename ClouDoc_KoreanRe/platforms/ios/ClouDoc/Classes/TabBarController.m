//
//  TabBarController.m
//  CentralECM
//
//  Created by HeungKyoo Han on 10. 6. 6..
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import "TabBarController.h"
#import "CentralECMAppDelegate.h"

@class PhotoViewController;
extern CentralECMAppDelegate	*g_appDelegate;

@implementation TabBarController

@synthesize m_bServerTab;
@synthesize m_bClientTab;

- (BOOL)tabBarController:(UITabBarController *)tabBar shouldSelectViewController:(UIViewController *)viewController
{
	if (!g_appDelegate.m_bServerTab && tabBar.selectedIndex == 0 
		&& viewController == [tabBar.viewControllers objectAtIndex:0])
		return NO;
	else if (!g_appDelegate.m_bClientTab && tabBar.selectedIndex == 1 
			 && viewController == [tabBar.viewControllers objectAtIndex:1])
		return NO;
	
	return YES;
}


- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation 
{  
	// UIWindow
	if (interfaceOrientation == UIInterfaceOrientationPortrait)
	{
		return YES;
	}
	
	return YES;
	
//	CentralECMAppDelegate *appDelegate = (CentralECMAppDelegate *)[[UIApplication sharedApplication] delegate];
//
//	if (appDelegate.isRotate == YES)
//	{
//  		return YES;
// 	}
//	else
//	{
//		return NO;
//	}
} 
 
// The designated initializer.  Override if you create the controller programmatically and want to perform customization that is not appropriate for viewDidLoad.
- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
	 NSLog(@"here Tabar");
    if (self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil]) {
        // Custom initialization
    }
    return self;
}

/*
// Implement loadView to create a view hierarchy programmatically, without using a nib.
- (void)loadView {
}
*/
 
// Implement viewDidLoad to do additional setup after loading the view, typically from a nib.
- (void)viewDidLoad {
    [super viewDidLoad];
	[self setDelegate:self];
}

/*
// Override to allow orientations other than the default portrait orientation.
- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
    // Return YES for supported orientations
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}
*/

- (void)didReceiveMemoryWarning {
	// Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
	
	// Release any cached data, images, etc that aren't in use.
}

- (void)viewDidUnload {
	// Release any retained subviews of the main view.
	// e.g. self.myOutlet = nil;
}

- (void)dealloc {
    [super dealloc];
}

@end
