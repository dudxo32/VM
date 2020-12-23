//
//  ChildBrowserViewController.m
//
//  Created by Jesse MacFadyen on 21/07/09.
//  Copyright 2009 Nitobi. All rights reserved.
//  Copyright (c) 2011, IBM Corporation
//  Copyright 2011, Randy McMillan
//

#import "ActivityViewController.h"
#import "objc/runtime.h"
#import "objc/message.h"
#import "ServerCmd.h"
#import "FileUtil.h"
#import "MBProgressHUD.h"

extern FileUtil	*g_FileUtil;

@implementation ActivityViewController

@synthesize supportedOrientations;
@synthesize delegate;
@synthesize m_progress;

@synthesize m_filename;
@synthesize m_spinner;
@synthesize m_info;
@synthesize Activityview;
//    Add *-72@2x.png images to ChildBrowser.bundle
//    Just duplicate and rename - @RandyMcMillan

- (void) setStatus: (long long) totalBytesWritten
         totalsize: (long long) m_length
              time: (float) elapsedTime
{
    //    [m_filename setCenter:CGPointMake(Activityview.bounds.size.width/2.0, Activityview.bounds.size.height/2 - 50.0)];
    //    [m_info setCenter:CGPointMake(Activityview.bounds.size.width/2.0, Activityview.bounds.size.height/2 + 5)];
    m_info.text = [NSString stringWithFormat:@"%@ of %@ (%@)",
                   [g_FileUtil getFormattedSize:totalBytesWritten],
                   [g_FileUtil getFormattedSize:m_length],
                   [g_FileUtil getFormattedSpeed:totalBytesWritten time: elapsedTime]];
}

- (void) hideActivity
{
    // 타이틀바 Activity Indicator
    UIApplication* app = [UIApplication sharedApplication];
    app.networkActivityIndicatorVisible = NO;
    
    [m_spinner stopAnimating];
    //	[m_navbar removeFromSuperview];
    [m_filename removeFromSuperview];
    [m_info removeFromSuperview];
}

- (void) showActivity: (UIView *) view
{
    [self showActivity:view filename:nil sender: nil order: 1 totalfile: 1];
}

- (void) showActivity: (UIView *) view
             filename: (NSString *) filename
               sender: (ServerCmd *) serverCmd
                order: (int) nOrder
            totalfile: (int) nTotal
{
    Activityview = view;
    m_serverCmd = serverCmd;
    
    // 타이틀바 Activity Indicator
    UIApplication* app = [UIApplication sharedApplication];
    app.networkActivityIndicatorVisible = YES;
    
    UIWindow* window = [UIApplication sharedApplication].keyWindow;
    m_spinner = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhiteLarge];
    [m_spinner setCenter:CGPointMake(window.frame.size.width/2, window.frame.size.height/2+50)];
    [view addSubview:m_spinner];
    [m_spinner startAnimating];
    
    if (filename)
    {
        CGFloat width = 768;
        int rotation = [[UIDevice currentDevice] orientation];
        if ( rotation == UIInterfaceOrientationLandscapeLeft || rotation == UIInterfaceOrientationLandscapeRight )
            width = 1024;
        
        //		m_navbar = [[[NSBundle mainBundle] loadNibNamed:@"ActivityViewController" owner:self options:nil] lastObject];
        //		m_navbar.frame = CGRectMake(0, 20, width, 44);
        
        UIBarButtonItem	* cancelButton = [[UIBarButtonItem alloc]
                                          initWithBarButtonSystemItem:UIBarButtonSystemItemCancel target:self action:@selector(cancelTapped:)];
        cancelButton.style = UIBarButtonItemStylePlain;
        
        UINavigationItem *barItem = [[UINavigationItem alloc] initWithTitle:@""];
        barItem.leftBarButtonItem = cancelButton;
        
        m_filename = [[UILabel alloc] initWithFrame:CGRectMake(0, window.frame.size.height/2-100, window.frame.size.width, 22)];
        //        m_filename = [[UILabel alloc] init];
        m_filename.backgroundColor = [UIColor clearColor];
        m_filename.textColor = [UIColor whiteColor];
        m_filename.textAlignment = NSTextAlignmentCenter;
        //        [m_filename setCenter:CGPointMake(view.bounds.size.width/2.0, view.bounds.size.height/2 - 50.0)];
        m_filename.text = [filename stringByAppendingFormat:@" (%d/%d)", nOrder, nTotal];
//        m_filename.text = filename;
        
        m_info = [[UILabel alloc] initWithFrame:CGRectMake(0, window.frame.size.height/2, window.frame.size.width, 22)];
        m_info.backgroundColor = [UIColor clearColor];
        m_info.textColor = [UIColor whiteColor];
        m_info.textAlignment = NSTextAlignmentCenter;
        //		[m_info setCenter:CGPointMake(view.bounds.size.width/2.0, view.bounds.size.height/2 + 5)];
        m_progress.progress = 0.0;
        
        //        		[view addSubview:m_navbar];
        [Activityview addSubview:m_filename];
        [Activityview addSubview:m_info];
    }
    Activityview.frame = CGRectMake(0, 0, window.frame.size.width, window.frame.size.height+20);
    
    
//    MBProgressHUD *progress = [MBProgressHUD showHUDAddedTo:self.view animated:YES];
//    progress.bezelView.backgroundColor = [UIColor colorWithRed:0 green:0 blue:0 alpha:0.30];
//    UIActivityIndicatorView* activityIndicator = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhiteLarge];
//    [activityIndicator setCenter:CGPointMake(window.frame.size.width/2,window.frame.size.height/2+100)];
//    [self.view addSubview:activityIndicator];
//    [activityIndicator startAnimating];
    
    
    //    [Activityview removeFromSuperview];
}


+ (NSString*) resolveImageResource:(NSString*)resource
{
    NSString* systemVersion = [[UIDevice currentDevice] systemVersion];
    BOOL isLessThaniOS4 = ([systemVersion compare:@"4.0" options:NSNumericSearch] == NSOrderedAscending);
    
    // the iPad image (nor retina) differentiation code was not in 3.x, and we have to explicitly set the path
    if (isLessThaniOS4)
    {
        return [NSString stringWithFormat:@"%@.png", resource];
    } else if ([[UIScreen mainScreen] respondsToSelector:@selector(scale)] == YES && [[UIScreen mainScreen] scale] == 2.00)
    {
        return [NSString stringWithFormat:@"%@@2x.png", resource];
    }
    
    
    return resource;
}



- (ActivityViewController*)initWithScale:(BOOL)enabled
{
    self = [super init];
    
    //self.scaleEnabled = enabled;
    
    return self;
}


// Implement viewDidLoad to do additional setup after loading the view, typically from a nib.
- (void)viewDidLoad {
    [super viewDidLoad];
    
    //	self.refreshBtn.image = [UIImage imageNamed:[[self class]
    //                                                 resolveImageResource:@"ChildBrowser.bundle/but_refresh"]];
    //	self.backBtn.image = [UIImage imageNamed:[[self class]
    //                                              resolveImageResource:@"ChildBrowser.bundle/arrow_left"]];
    //	self.fwdBtn.image = [UIImage imageNamed:[[self class]
    //                                        resolveImageResource:@"ChildBrowser.bundle/arrow_right"]];
    //	self.safariBtn.image = [UIImage imageNamed:[[self class]
    //                                           resolveImageResource:@"ChildBrowser.bundle/compass"]];
    
    self.webView.delegate = self;
    //self.webView.scalesPageToFit = TRUE;
    //self.webView.backgroundColor = [UIColor whiteColor];
    
    NSLog(@"View did load");
}

- (void)didReceiveMemoryWarning {
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
    
    // Release any cached data, images, etc that aren't in use.
}

- (void)viewDidUnload {
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
    NSLog(@"View did UN-load");
}


- (void)dealloc {
    self.webView.delegate = nil;
    self.delegate = nil;
    self.orientationDelegate = nil;
    [self.supportedOrientations release];
    [self.m_progress release];
#if !__has_feature(objc_arc)
    
    [super dealloc];
#endif
}

-(void)closeBrowser
{
    
}

-(IBAction) onCancelButtonPress: (id) sender
{
    //[ self closeBrowser];
    if(m_serverCmd != NULL)
        [m_serverCmd cancel];
}
//
//- (void)webViewDidFinishLoad:(UIWebView *)sender
//{
//	NSURLRequest *request = self.webView.request;
//	NSLog(@"New Address is : %@",request.URL.absoluteString);
//
//	self.addressLabel.text = request.URL.absoluteString;
//	self.backBtn.enabled = webView.canGoBack;
//	self.fwdBtn.enabled = webView.canGoForward;
//	[self.spinner stopAnimating];
//
//	if (self.delegate != NULL) {
//		[self.delegate onChildLocationChange:request.URL.absoluteString];
//	}
//}
//
//- (void)webView:(UIWebView *)wv didFailLoadWithError:(NSError *)error {
//    NSLog (@"webView:didFailLoadWithError");
//    NSLog (@"%@", [error localizedDescription]);
//    NSLog (@"%@", [error localizedFailureReason]);
//
//    [spinner stopAnimating];
//    addressLabel.text = @"Failed";
//}
//
//#pragma mark - Disaplying Controls
//
//- (void)resetControls
//{
//
//    CGRect rect = addressLabel.frame;
//    rect.origin.y = self.view.frame.size.height-(44+26);
//    [addressLabel setFrame:rect];
//    rect=webView.frame;
//    rect.size.height= self.view.frame.size.height-(44+26);
//    [webView setFrame:rect];
//    [addressLabel setHidden:NO];
//    [toolbar setHidden:NO];
//}
//
//- (void)showLocationBar:(BOOL)isShow
//{
//    if(isShow)
//        return;
//    //the addreslabel heigth 21 toolbar 44
//    CGRect rect = webView.frame;
//    rect.size.height+=(26+44);
//    [webView setFrame:rect];
//    [addressLabel setHidden:YES];
//    [toolbar setHidden:YES];
//}
//
//- (void)showAddress:(BOOL)isShow
//{
//    if(isShow)
//        return;
//    CGRect rect = webView.frame;
//    rect.size.height+=(26);
//    [webView setFrame:rect];
//    [addressLabel setHidden:YES];
//
//}
//
//- (void)showNavigationBar:(BOOL)isShow
//{
//    if(isShow)
//        return;
//    CGRect rect = webView.frame;
//    rect.size.height+=(44);
//    [webView setFrame:rect];
//    [toolbar setHidden:YES];
//    rect = addressLabel.frame;
//    rect.origin.y+=44;
//    [addressLabel setFrame:rect];
//}
//
//#pragma mark - Gesture Recognizer
//
//- (void)addGestureRecognizer
//{
//    UISwipeGestureRecognizer* closeRG = [[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(closeBrowser)];
//    closeRG.direction = UISwipeGestureRecognizerDirectionLeft;
//    closeRG.delegate=self;
//    [self.view addGestureRecognizer:closeRG];
//    [closeRG release];
//}
//
////- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldRecognizeSimultaneouslyWithGestureRecognizer:(UIGestureRecognizer *)otherGestureRecognizer
////{
////    return YES;
////}
//
//- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldReceiveTouch:(UITouch *)touch
//{
//    return YES;
//}
//
//- (BOOL)gestureRecognizerShouldBegin:(UIGestureRecognizer *)gestureRecognizer
//{
//    return YES;
//}
//
//#pragma mark CDVOrientationDelegate
//
- (BOOL)shouldAutorotate
{
    return NO;
}
//
//- (NSUInteger)supportedInterfaceOrientations
//{
//    if ((self.orientationDelegate != nil) && [self.orientationDelegate respondsToSelector:@selector(supportedInterfaceOrientations)]) {
//        return [self.orientationDelegate supportedInterfaceOrientations];
//    }
//
//    // return UIInterfaceOrientationMaskPortrait; // NO - is IOS 6 only
//    return (1 << UIInterfaceOrientationPortrait);
//}
//
- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    if ((self.orientationDelegate != nil) && [self.orientationDelegate respondsToSelector:@selector(shouldAutorotateToInterfaceOrientation:)]) {
        return UIInterfaceOrientationIsPortrait( interfaceOrientation );
    }
}

@end
