//  iphone
//  CentralECMAppDelegate.m
//  CentralECM
//
//  Created by HeungKyoo Han on 10. 04. 17.
//  Copyright __MyCompanyName__ 2010. All rights reserved.
//

#import "CentralECMAppDelegate.h"
#import "FileUtil.h"
#import "ActivityViewController.h"
#import "Reachability.h"


CentralECMAppDelegate	*g_appDelegate;
FileUtil				*g_FileUtil;
ActivityViewController	*g_activityViewController;

@implementation CentralECMAppDelegate

@synthesize m_bServerTab;
@synthesize m_bClientTab;

@synthesize	sourceServerViewController;
@synthesize	sourceClientViewController;

@synthesize window;
@synthesize	loginViewController;
@synthesize accountViewController;
@synthesize	rootViewController;
@synthesize navServerController;
@synthesize navClientController;
@synthesize serverRootViewController;
@synthesize sourceFolder;
@synthesize sourceData;
@synthesize sourceImage;
@synthesize sourceType;
@synthesize targetType;
@synthesize pasteStatus;
@synthesize isRecursive;
@synthesize settingViewController;
@synthesize isRotate;
@synthesize app;
@synthesize childbrowserViewController;

@synthesize m_arrDriveInfo;
@synthesize m_arrCookieInfo;
//
// (0 : Yes, 1 : All Yes, 2 : No, 3 : cancel)
// (0 : Yes, 1 : No, 2 : cancel)
//
- (int) checkOverwrite: (NSString *) fileName 
				allYes: (BOOL) bAllYes
{
	int index = -1;
    
//	NSString *ask = [NSString stringWithFormat: NSLocalizedString(@"%@ file already exists.\n Would you like to overwrite?", nil), fileName];
//	
//	if (bAllYes)
//	{
//		index = [ModalActionSheet ask: ask
//						   withCancel: NSLocalizedString(@"Cancel", nil) 
//					  withDestructive: nil
//						  withButtons: [NSArray arrayWithObjects:NSLocalizedString(@"Yes", nil), 
//										NSLocalizedString(@"All Yes", nil),
//										NSLocalizedString(@"No", nil), nil]
//								where: g_appDelegate.rootViewController.tabBar];
//	}
//	else
//	{
//		index = [ModalActionSheet ask: ask
//						   withCancel: NSLocalizedString(@"Cancel", nil) 
//					  withDestructive: nil
//						  withButtons: [NSArray arrayWithObjects:NSLocalizedString(@"Yes", nil), 
//										NSLocalizedString(@"No", nil), nil]
//								where: g_appDelegate.rootViewController.tabBar];
//	}
    
	return index;
}

- (BOOL) check3G: (int) type
{
	//return [self check3G: type where:g_appDelegate.rootViewController.tabBar];
    return YES;
}

// 와이파이 연결이 안되면 3G로 연결할지 물어본다.
- (BOOL) check3G: (int) type 
		   where: (id) where
{
	BOOL	b3G = YES;
	
	Reachability *reachability = [Reachability reachabilityForLocalWiFi];
	NetworkStatus networkStatus = [reachability currentReachabilityStatus];
	
	NSUserDefaults *prefs = [NSUserDefaults standardUserDefaults];
	BOOL	isOn = NO;
	
	if (type == UPLOAD)
		isOn  = [prefs boolForKey:@"3gupload_preference"];
	else if (type == DOWNLOAD)
		isOn = [prefs boolForKey:@"3gdownload_preference"];
    
	if (isOn)
		return YES;
	
	if (networkStatus == NotReachable)
	{
		// EDGE or 3G connection found
		int index = -1;
		
//		index = [ModalActionSheet ask:NSLocalizedString(@"Connect to 3G network.\n Would you like to proceed?", nil)
//						   withCancel:NSLocalizedString(@"Cancel", nil) 
//					  withDestructive:nil
//						  withButtons: [NSArray arrayWithObjects:NSLocalizedString(@"Yes", nil), 
//										NSLocalizedString(@"No", nil), nil]
//								where:where];
		
		// 예가 아니면
		if (index != 0)
			b3G = NO;
	}
	
	return b3G;
}

- (void) flipToLoginView
{
//	[rootViewController.view removeFromSuperview];
//	[navServerController popToRootViewControllerAnimated:NO];
//	[window addSubview:loginViewController.view];
}

- (void) flipToAccountView
{
//	[loginViewController.view removeFromSuperview];
//	[rootViewController.view removeFromSuperview];
//	[navServerController popToRootViewControllerAnimated:NO];
//	[window addSubview:accountViewController.view];
	
}

- (void) flipToRootView
{
//	[loginViewController.view removeFromSuperview];
//	[window addSubview:rootViewController.view];
//	[rootViewController setSelectedIndex:0];
}

- (void)applicationDidFinishLaunching:(UIApplication *)application
{  
	self.sourceData  = [NSMutableArray array];
	self.sourceImage = [NSMutableArray array];
	self.pasteStatus = NO;
	self.isRecursive = 0;
	self.app = application;
    
	g_appDelegate = self;
    
	m_bServerTab = TRUE;
	m_bClientTab = TRUE;
	
	g_FileUtil = [FileUtil alloc];
    
	// .tmp 폴더 삭제
	[g_FileUtil deleteFile:[NSString stringWithFormat:@"%@/.tmp", [g_FileUtil getDocumentFolder]]];
    
	g_activityViewController = [ActivityViewController alloc];
	
	// 3초간 정지.
	[NSThread sleepForTimeInterval:3];
	
	// Override point for customization after application launch
//	[window	addSubview:loginViewController.view];
	[window makeKeyAndVisible];
}

- (void)dealloc
{
	// .tmp 폴더 삭제
	[g_FileUtil deleteFile:[NSString stringWithFormat:@"%@/.tmp", [g_FileUtil getDocumentFolder]]];
    
    [window release];
	self.sourceData = nil;
	self.sourceImage = nil;
	[loginViewController release];
	[rootViewController release];
	[settingViewController release];
	[serverRootViewController release];
    [super dealloc];
}

@end
