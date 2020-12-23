//
//  ChildBrowserViewController.h
//
//  Created by Jesse MacFadyen on 21/07/09.
//  Copyright 2009 Nitobi. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <Cordova/CDVPlugin.h>
#import <Cordova/CDVViewController.h>
#import "CentralECMAppDelegate.h"
#import "ActivityViewController.h"
#import "ActivityViewController_phone.h"
#import "NIInterfaceUtil.h"
@protocol ReceiveDataDelegate<NSObject>



/*
 *  onChildLocationChanging:newLoc
 *  
 *  Discussion:
 *    Invoked when a new page has loaded
 */
-(void) onChildLocationChange:(NSString*)newLoc;
-(void) onOpenInSafari;
-(void) onClose;
@end

@protocol CDVOrientationDelegate <NSObject>

- (NSUInteger)supportedInterfaceOrientations;
- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation;
- (BOOL)shouldAutorotate;

@end

@interface ReceiveDataViewController : UIViewController < UIWebViewDelegate , UIGestureRecognizerDelegate>{
    ActivityViewController* ActView;
    ActivityViewController_phone* ActViewPhone;
    CDVViewController* cont;
}

@property (nonatomic, retain) CDVViewController *cont;
@property (nonatomic, retain) ActivityViewController *ActView;
@property (nonatomic, retain) ActivityViewController_phone *ActViewPhone;

@property (nonatomic, strong) IBOutlet UIWebView* webView;
@property (nonatomic, strong) IBOutlet UIBarButtonItem* closeBtn;
@property (nonatomic, strong) IBOutlet UIBarButtonItem* refreshBtn;
@property (nonatomic, strong) IBOutlet UILabel* addressLabel;
@property (nonatomic, strong) IBOutlet UIBarButtonItem* backBtn;
@property (nonatomic, strong) IBOutlet UIBarButtonItem* fwdBtn;
@property (nonatomic, strong) IBOutlet UIBarButtonItem* safariBtn;
@property (nonatomic, strong) IBOutlet UIActivityIndicatorView* spinner;
@property (nonatomic, strong) IBOutlet UIToolbar* toolbar;

@property (nonatomic, unsafe_unretained)id <ReceiveDataDelegate> delegate;
@property (nonatomic, unsafe_unretained) id orientationDelegate;

@property (nonatomic, retain) 	NSArray* supportedOrientations;
@property(nonatomic, retain) NSString* OpenFilePath;
@property(nonatomic, retain) NSString* onSaved;

@property (copy) NSString* imageURL;
@property (assign) BOOL isImage;
@property (assign) BOOL scaleEnabled;
@property (nonatomic, retain) CentralECMAppDelegate *ECMAppDelegate;
- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation) interfaceOrientation;

- (ReceiveDataViewController*)initWithScale:(BOOL)enabled;
- (IBAction)onDoneButtonPress:(id)sender;
-(IBAction) onSavePress:(id)sender;
- (void)loadURL:(NSString*)url file_open:(NSString*)file_open;
- (void)closeBrowser;

//Disaplying Controls
- (void)resetControls;
- (void)showAddress:(BOOL)isShow;       // display address bar
- (void)showLocationBar:(BOOL)isShow;   // display the whole location bar
- (void)showNavigationBar:(BOOL)isShow; // display navigation buttons

-(void)storeCordovaPop;
-(void)restoreCordovaPop;

- (void) setLoginFlag: (BOOL) loginflag SetUserID: (NSString *)user;
- (void) setCookie: (NSMutableArray *) centralecmdelegate;
//- (void) DriveInfo: (NSMutableArray *) m_arrDriveInfo  CookieInfo:(NSMutableArray *)m_arrCookieInfo;
- (void) DRiveInfo: (NIDriveInfo *)driveinfo  CookieInfo:(NICookieInfo *) cookieinfo dstpath:(NSString *)tmpPath  DownFlag:(BOOL)downflag;
@end
