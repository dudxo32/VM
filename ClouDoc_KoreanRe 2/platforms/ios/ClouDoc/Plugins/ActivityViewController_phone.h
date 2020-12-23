//
//  ChildBrowserViewController.h
//
//  Created by Jesse MacFadyen on 21/07/09.
//  Copyright 2009 Nitobi. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol ActivityViewDelegate_phone<NSObject>
-(void) onClose;
@end
@class ServerCmd;

@protocol CDVOrientationDelegate <NSObject>

- (NSUInteger)supportedInterfaceOrientations;
- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation;
- (BOOL)shouldAutorotate;

@end

@interface ActivityViewController_phone : UIViewController < UIWebViewDelegate , UIGestureRecognizerDelegate> {
ServerCmd					*m_serverCmd;}

@property (nonatomic, strong) IBOutlet UIWebView* webView;


@property (nonatomic, unsafe_unretained)id <ActivityViewDelegate_phone> delegate;
@property (nonatomic, unsafe_unretained) id orientationDelegate;
@property (nonatomic, retain) IBOutlet UIProgressView			*m_progress;
@property (nonatomic, retain) 	NSArray* supportedOrientations;
@property (nonatomic, retain) IBOutlet UILabel					*m_filename;
@property (nonatomic, retain) IBOutlet UILabel                  *m_info;
@property (nonatomic, retain) IBOutlet UIActivityIndicatorView	*m_spinner;
@property (nonatomic, retain) IBOutlet UIView                   *Activityview;

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation) interfaceOrientation;

//Disaplying Controls
- (void)resetControls;
- (void)showAddress:(BOOL)isShow;       // display address bar
- (void)showLocationBar:(BOOL)isShow;   // display the whole location bar
- (void)showNavigationBar:(BOOL)isShow; // display navigation buttons


- (IBAction) cancelTapped: (id) sender;

- (void) hideActivity;

- (void) showActivity: (UIView *) view;

- (void) showActivity: (UIView *) view
			 filename: (NSString *) filename
			   sender: (ServerCmd *) serverCmd
				order: (int) nOrder
			totalfile: (int) nTotal;

- (void) setStatus: (long long) totalBytesWritten
		 totalsize: (long long) m_length
			  time: (float) elapsedTime;

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation) interfaceOrientation;
- (ActivityViewController_phone*)initWithScale:(BOOL)enabled;
- (IBAction)onCancelButtonPress:(id)sender;

@end
