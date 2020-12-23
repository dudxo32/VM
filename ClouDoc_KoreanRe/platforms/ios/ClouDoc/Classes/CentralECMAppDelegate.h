// iphone
//  CentralECMAppDelegate.h
//  CentralECM
//
//  Created by HeungKyoo Han on 10. 04. 17.
//  Copyright __MyCompanyName__ 2010. All rights reserved.
//

#import <UIKit/UIKit.h>
#define COPY 1
#define CUT	 2
#define RENAMES 3
#define CANCEL 4

#define CART   1
#define SERVER 0

#define	NONE	0
#define	UPLOAD	1
#define	DOWNLOAD	2

@class LoginViewController;
@class AccountViewController;
@class ServerRootViewController;
@class SettingViewController;
@class ServerViewController;
@class ClientViewController;
@class TabBarController;
@class ServerCmd;
@class ChildBrowserViewController;

@interface CentralECMAppDelegate : NSObject <UIApplicationDelegate>
{
    
    UIWindow					*window;
	UIApplication				*app;
	TabBarController			*rootViewController;
	UINavigationController		*navServerController;
	UINavigationController		*navClientController;
	LoginViewController			*loginViewController;
	AccountViewController		*accountViewController;
	ServerRootViewController	*serverRootViewController;
	SettingViewController		*settingViewController;
	ServerViewController		*sourceServerViewController;
	ClientViewController		*sourceClientViewController;
    ChildBrowserViewController  *childbrowserViewController;
    
	// copy, cut된 폴더의 위치
	NSString				*sourceFolder;
	// copy, cut된 자료
	NSMutableArray			*sourceData;
	// PhotoViewController에서 보여줄 이미지
	NSMutableArray			*sourceImage;
	// copy,cut,rename, paste으 상태를 나타낸다.
	NSInteger				pasteStatus;
	// copy, cut된 위치 
	NSInteger				sourceType;
	// paste될 위치
	NSInteger				targetType;
	// 자기, 자기 자식폴더로 이동되는지를 체크하는 값
	NSInteger       		isRecursive;
	BOOL					isRotate;
	
	BOOL					m_bServerTab;
	BOOL					m_bClientTab;
	
	
	// DriveInfo
	NSMutableArray			*m_arrDriveInfo;
    NSMutableArray			*m_arrCookieInfo;
}

@property (nonatomic, assign) NSMutableArray *m_arrDriveInfo;
@property (nonatomic, assign) NSMutableArray *m_arrCookieInfo;

@property (nonatomic, assign) BOOL	m_bServerTab;
@property (nonatomic, assign) BOOL	m_bClientTab;

@property (nonatomic, retain) IBOutlet UIWindow *window;
@property (nonatomic, retain) IBOutlet LoginViewController *loginViewController;
@property (nonatomic, retain) IBOutlet AccountViewController *accountViewController;

@property (nonatomic, retain) IBOutlet TabBarController *rootViewController;
@property (nonatomic, retain) IBOutlet UINavigationController *navServerController;
@property (nonatomic, retain) IBOutlet UINavigationController *navClientController;
@property (nonatomic, retain) IBOutlet ServerRootViewController *serverRootViewController;
@property (nonatomic, retain) IBOutlet SettingViewController *settingViewController;
@property (nonatomic, retain) ServerViewController	*sourceServerViewController;
@property (nonatomic, retain) ClientViewController	*sourceClientViewController;
@property (nonatomic, retain) ChildBrowserViewController *childbrowserViewController;

@property (nonatomic, copy)			   NSString		    *sourceFolder;
@property (nonatomic, retain)		   NSMutableArray	*sourceData;
@property (nonatomic, retain)		   NSMutableArray	*sourceImage;
@property (nonatomic, assign)		   NSInteger	    pasteStatus;
@property (nonatomic, assign)		   NSInteger	   sourceType;
@property (nonatomic, assign)		   NSInteger	   targetType;
@property (nonatomic, assign)		   NSInteger       isRecursive;
@property (nonatomic, assign)		   BOOL       isRotate;
@property (nonatomic, assign)		   UIApplication       *app;

- (int) checkOverwrite: (NSString *) fileName 
				allYes: (BOOL) bAllYes;

- (BOOL) check3G: (int) type;

- (BOOL) check3G: (int) type 
		   where: (id) where;

- (void) flipToLoginView;

- (void) flipToAccountView;

- (void) flipToRootView;

@end

extern	CentralECMAppDelegate	* g_appDelegate;

