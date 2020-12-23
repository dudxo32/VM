//
//  ChildBrowserViewController.m
//
//  Created by Jesse MacFadyen on 21/07/09.
//  Copyright 2009 Nitobi. All rights reserved.
//  Copyright (c) 2011, IBM Corporation
//  Copyright 2011, Randy McMillan
//

#import "ReceiveDataViewController.h"

#import "objc/runtime.h"
#import "objc/message.h"
#import "DVTextEncoding.h"
#import "FileUtil.h"
#import "UploadFiles.h"
#import "ActivityViewController.h"

//CentralECMAppDelegate   *g_CECMAppDelegate;
ReceiveDataViewController   *g_receivedatacontroller;
BOOL                        g_LoginFlag = NO;
BOOL                        g_Downflag = NO;
NIDriveInfo                 *g_drive;
NICookieInfo                *g_cookieinfo;
NSString                    *g_UserID;
//NSString                    *g_DstPath;
@interface ReceiveDataViewController()

//Gesture Recognizer
- (void)addGestureRecognizer;

@end

@implementation ReceiveDataViewController

@synthesize imageURL, isImage, scaleEnabled;
@synthesize ActView, ActViewPhone,cont;
@synthesize spinner, webView, addressLabel, toolbar;
@synthesize closeBtn, refreshBtn, backBtn, fwdBtn, safariBtn;
@synthesize supportedOrientations, OpenFilePath, onSaved, ECMAppDelegate;
//@synthesize m_arrCookieInfo, m_arrDriveInfo;
//    Add *-72@2x.png images to ChildBrowser.bundle
//    Just duplicate and rename - @RandyMcMillan

static IMP cordovaPopImplementation = NULL;
static const char* cordovaPopEncoding = NULL;

-(void)storeCordovaPop { Method popMethod = class_getInstanceMethod([NSMutableArray class], @selector(pop)); if (!cordovaPopImplementation) { cordovaPopImplementation = method_getImplementation(popMethod); cordovaPopEncoding = method_getTypeEncoding(popMethod); } }

-(void)restoreCordovaPop {
    class_replaceMethod([NSMutableArray class], @selector(pop), cordovaPopImplementation, cordovaPopEncoding); }



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



- (ReceiveDataViewController*)initWithScale:(BOOL)enabled
{
    self = [super init];
	if(self!=nil)
    {
        [self addGestureRecognizer];
    }
	
	self.scaleEnabled = enabled;
	
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
    //g_CECMAppDelegate = [[[CentralECMAppDelegate alloc] init] autorelease];
   // g_LoginFlag = NO;
    self.webView.delegate = self;
	self.webView.scalesPageToFit = TRUE;
	self.webView.backgroundColor = [UIColor whiteColor];
    
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
//    self.delegate = nil;
    self.orientationDelegate = nil;
	[self.supportedOrientations release];
#if !__has_feature(objc_arc)
	[self.webView release];
	[self.closeBtn release];
	[self.refreshBtn release];
	[self.addressLabel release];
	[self.backBtn release];
	[self.fwdBtn release];
	[self.safariBtn release];
	[self.spinner release];
    [self.toolbar release];
//    [g_UserID release];
//    [g_drive release];
//     [g_cookieinfo release];
	[super dealloc];
#endif
}

-(void)closeBrowser
{
	    g_Downflag = NO;
	if (self.delegate != NULL)
	{
		[self.delegate onClose];
	}
    if ([self respondsToSelector:@selector(presentingViewController)]) {
        //Reference UIViewController.h Line:179 for update to iOS 5 difference - @RandyMcMillan
        [[self presentingViewController] dismissViewControllerAnimated:YES completion:nil];
    } else {
        [[self parentViewController] dismissModalViewControllerAnimated:YES];
    }
    
     [self restoreCordovaPop];
}

-(IBAction) onDoneButtonPress:(id)sender
{
    [self.webView stopLoading];
	[self closeBrowser];
    
    NSURLRequest *request = [NSURLRequest requestWithURL:[NSURL URLWithString:@"about:blank"]];
    [self.webView loadRequest:request];
}

-(IBAction) onSavePress:(id)sender
{
    if (g_Downflag) {
        UIActionSheet *SaveSheet = [[UIActionSheet alloc] initWithTitle:NSLocalizedString(@"Save",nil) delegate:self cancelButtonTitle:@"Cancel" destructiveButtonTitle:nil otherButtonTitles:NSLocalizedString(@"To ServerStorage",nil), NSLocalizedString(@"To LocalStorage",nil), nil];
        
        [SaveSheet showInView:self.view];
        [SaveSheet release];
    }
    else{
        [self onSavetoLocal];
    }
    
    
}

- (void) actionSheet: (UIActionSheet *)actionSheet didDismissWithButtonIndex: (NSInteger)buttonIndex {
    UIImagePickerController *picker = [[UIImagePickerController alloc] init];
    picker.delegate = self;
    picker.allowsEditing = YES;
    switch (buttonIndex) {
        case 0:
            NSLog(@"To ServerStorage");
            [self onSavetoServer];
            break;
        case 1:
            NSLog(@"To LocalStorage");
            [self onSavetoLocal];
            break;
        default:
            NSLog(@"Convert UTF-8");
            return;
    }
}

- (void)didEndEncoding:(UIWebView *)saveWeb dec:(NSData *)ed2{
    NSLog(@"success");
    [saveWeb loadData:ed2 MIMEType:@"text/html" textEncodingName:@"UTF-8" baseURL:nil];
    saveWeb.scalesPageToFit=YES;
    //[delegate didFinishEncoding:convencoding];
}
- (void)didFailedEncoding:(UIWebView *)saveWeb{
    NSLog(@"fail");
    //NSURLRequest *request= [NSURLRequest requestWithURL:docUrl];
    //[saveWeb loadRequest:request];
    //[delegate didFinishEncoding:convencoding];
}

- (void)loadURL:(NSString*)url file_open:(NSString*)file_open
{
    //[closeBrowser closeBrowser];
	NSLog(@"Opening Url : %@",url);
    self.OpenFilePath = [url stringByReplacingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
    NSLog(@"path is %@", self.OpenFilePath);

    UIBarButtonItem *barItem = [UIBarButtonItem alloc];

    UIBarButtonItem *flexibleSpace = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace target:nil action:nil];
    
    NSLog(@"file open is %@", file_open);
    

    barItem = [barItem initWithTitle:NSLocalizedString(@"Save",nil) style:UIBarButtonItemStyleBordered target:self action:@selector(onSavePress:)];
    UIBarButtonItem *done = [[UIBarButtonItem alloc] initWithTitle:NSLocalizedString(@"Close",nil) style:UIBarButtonItemStyleBordered target:self action:@selector(onDoneButtonPress:)];
    [toolbar setItems:[NSArray arrayWithObjects:flexibleSpace,barItem,done, nil]];
    [barItem release];
    [done release];
    //toolbar.items = items;

    [self storeCordovaPop];
		imageURL = @"";
		isImage = NO;
		NSURLRequest *request = [NSURLRequest requestWithURL:[NSURL URLWithString:url]];
		[self.webView loadRequest:request];
	//}
	self.webView.hidden = NO;
}


- (void)webViewDidStartLoad:(UIWebView *)sender {
	self.addressLabel.text = @"Loading...";
	//self.backBtn.enabled = webView.canGoBack;
	//self.fwdBtn.enabled = webView.canGoForward;
	
	[self.spinner startAnimating];
	
}

- (void)webViewDidFinishLoad:(UIWebView *)sender 
{
	NSURLRequest *request = self.webView.request;
	NSLog(@"New Address is : %@",request.URL.absoluteString);

	self.addressLabel.text = request.URL.absoluteString;
	//self.backBtn.enabled = webView.canGoBack;
	//self.fwdBtn.enabled = webView.canGoForward;
	[self.spinner stopAnimating];
	
	if (self.delegate != NULL) {
		[self.delegate onChildLocationChange:request.URL.absoluteString];
	}
}

- (void)webView:(UIWebView *)wv didFailLoadWithError:(NSError *)error {
    NSLog (@"webView:didFailLoadWithError");
    NSLog (@"%@", [error localizedDescription]);
    NSLog (@"%@", [error localizedFailureReason]);

    [spinner stopAnimating];
    addressLabel.text = @"Failed";
}

#pragma mark - Disaplying Controls

- (void)resetControls
{
    
    CGRect rect = addressLabel.frame;
    rect.origin.y = self.view.frame.size.height-(44+26);
    [addressLabel setFrame:rect];
    rect=webView.frame;
    rect.size.height= self.view.frame.size.height-(44+26);
    [webView setFrame:rect];
    [addressLabel setHidden:NO];
    [toolbar setHidden:NO];
}

- (void)showLocationBar:(BOOL)isShow
{
    if(isShow)
        return;
    //the addreslabel heigth 21 toolbar 44
    CGRect rect = webView.frame;
    rect.size.height+=(26+44);
    [webView setFrame:rect];
    [addressLabel setHidden:YES];
    [toolbar setHidden:YES];
}

- (void)showAddress:(BOOL)isShow
{
    if(isShow)
        return;
    CGRect rect = webView.frame;
    rect.size.height+=(26);
    [webView setFrame:rect];
    [addressLabel setHidden:YES];
    
}

- (void)showNavigationBar:(BOOL)isShow
{
    if(isShow)
        return;
    CGRect rect = webView.frame;
    rect.size.height+=(44);
    [webView setFrame:rect];
    [toolbar setHidden:YES];
    rect = addressLabel.frame;
    rect.origin.y+=44;
    [addressLabel setFrame:rect];
}

#pragma mark - Gesture Recognizer

- (void)addGestureRecognizer
{
    UISwipeGestureRecognizer* closeRG = [[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(closeBrowser)];
    closeRG.direction = UISwipeGestureRecognizerDirectionLeft;
    closeRG.delegate=self;
    [self.view addGestureRecognizer:closeRG];
    [closeRG release];
}

//- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldRecognizeSimultaneouslyWithGestureRecognizer:(UIGestureRecognizer *)otherGestureRecognizer
//{
//    return YES;
//}

- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldReceiveTouch:(UITouch *)touch
{
    return YES;
}

- (BOOL)gestureRecognizerShouldBegin:(UIGestureRecognizer *)gestureRecognizer
{
    return YES;
}

#pragma mark CDVOrientationDelegate

- (BOOL)shouldAutorotate
{
    if ((self.orientationDelegate != nil) && [self.orientationDelegate respondsToSelector:@selector(shouldAutorotate)]) {
        return [self.orientationDelegate shouldAutorotate];
    }
    return YES;
}

- (NSUInteger)supportedInterfaceOrientations
{
    if ((self.orientationDelegate != nil) && [self.orientationDelegate respondsToSelector:@selector(supportedInterfaceOrientations)]) {
        return [self.orientationDelegate supportedInterfaceOrientations];
    }

    // return UIInterfaceOrientationMaskPortrait; // NO - is IOS 6 only
    return (1 << UIInterfaceOrientationPortrait);
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    if ((self.orientationDelegate != nil) && [self.orientationDelegate respondsToSelector:@selector(shouldAutorotateToInterfaceOrientation:)]) {
        return [self.orientationDelegate shouldAutorotateToInterfaceOrientation:interfaceOrientation];
    }

    return YES;
}

// 호출된 뷰어에서 로컬스토리지 루트에 데이터 저장
- (void) onSavetoLocal
{
    NSString * errmsg;
    
	if (!g_LoginFlag){
        errmsg = NSLocalizedString(@"Login to ues.", nil);
    }
	else{
        NSLog(@"filePath is %@", self.OpenFilePath);
        NSRange range = [self.OpenFilePath rangeOfString:@"file:///localhost/private/var"];
        NSRange range2 = [self.OpenFilePath rangeOfString:@"file:///private/var"];
        if ( range.location != NSNotFound) {
            self.OpenFilePath = [self.OpenFilePath stringByReplacingOccurrencesOfString:@"file:///localhost/private/var" withString:@"/var"];
        }
        else if ( range2.location != NSNotFound) {
            self.OpenFilePath = [self.OpenFilePath stringByReplacingOccurrencesOfString:@"file:///private/var" withString:@"/var"];
        }

        NSLog(@"filePath is %@", self.OpenFilePath);
        FileUtil *utilfile = [[FileUtil alloc] autorelease];
    
    
//    NSString * dstPath = [NSString stringWithFormat:[utilfile getDocumentFolder]];
        NSString * dstPath = [NSString stringWithString:[utilfile getDocumentFolder]];
        dstPath = [dstPath stringByAppendingFormat:@"/Documents/ECM/data/"];
        dstPath = [dstPath stringByAppendingString:g_UserID];
        dstPath = [dstPath stringByAppendingFormat:@"/"];
        dstPath = [dstPath stringByAppendingString: [self.OpenFilePath lastPathComponent]];
//	NSString * dstPath = [[NSString alloc] initWithFormat:@"%@/%@", [utilfile getDocumentFolder], [self.OpenFilePath lastPathComponent]];
	
       // NSString * errmsg;
    
        if ([utilfile copyFile:self.OpenFilePath dstPath:dstPath])
            errmsg = NSLocalizedString(@"file saved", nil);
        else
            errmsg = NSLocalizedString(@"file save failed", nil);
    }
	UIAlertView	*av = [[[UIAlertView alloc] initWithTitle:nil message:NSLocalizedString(errmsg, nil) delegate:nil cancelButtonTitle:NSLocalizedString(@"OK",nil) otherButtonTitles:nil] autorelease];
	[av show];
}


// 호출된 뷰어에서 문서열기한 위치에 데이터 업로드
- (void) onSavetoServer
{
    g_Downflag = NO;
    CentralECMAppDelegate *appDelegate = [[CentralECMAppDelegate alloc]init];
    appDelegate = g_receivedatacontroller.ECMAppDelegate;
    NSString * errmsg;
    
	if (!g_LoginFlag && !g_Downflag){
        errmsg = NSLocalizedString(@"Login to ues.", nil);
    }
	else{
        
        NSLog(@"filePath is %@", self.OpenFilePath);
        
        NSRange range = [self.OpenFilePath rangeOfString:@"file:///localhost/private/var"];
        NSRange range2 = [self.OpenFilePath rangeOfString:@"file:///private/var"];
        if ( range.location != NSNotFound) {
            self.OpenFilePath = [self.OpenFilePath stringByReplacingOccurrencesOfString:@"file:///localhost/private/var" withString:@"/var"];
        }
        else if ( range2.location != NSNotFound) {
            self.OpenFilePath = [self.OpenFilePath stringByReplacingOccurrencesOfString:@"file:///private/var" withString:@"/var"];
        }
        NSLog(@"filePath is %@", self.OpenFilePath);
        
        CentralECMAppDelegate *appdelegate = [[CentralECMAppDelegate alloc] init];
        appdelegate.m_arrCookieInfo =[[NSMutableArray alloc] init];
        appdelegate.m_arrDriveInfo = [[NSMutableArray alloc] init];
        [appdelegate.m_arrCookieInfo addObject:g_cookieinfo];
        [appdelegate.m_arrDriveInfo addObject:g_drive];
        appdelegate.sourceData = [[NSMutableArray alloc] init];
        NSArray *arrPathes = [self.OpenFilePath componentsSeparatedByString:@"\t"];
        //업로드 파일 정보 셋팅
        for (int i= 0; i < arrPathes.count; i++) {
            CFileInfo	* fileInfo = [[CFileInfo alloc] init];
            NSString    *lastPathComponent = [[arrPathes objectAtIndex:i] lastPathComponent];
            fileInfo.m_strName = [NSString stringWithFormat:@"%@", lastPathComponent];
            
            [appdelegate.sourceData addObject: fileInfo];
        }
        appdelegate.sourceFolder = @"";
        
        NSString *tmpPath = [arrPathes objectAtIndex:0];
        appdelegate.sourceFolder = [appdelegate.sourceFolder  stringByAppendingPathComponent:[tmpPath substringToIndex:[tmpPath length]-[[tmpPath lastPathComponent] length]]];
        NSLog(@"sourceFolder is %@", appdelegate.sourceFolder);
        
        if( [[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPhone )
        {
            if(ActViewPhone == nil)
            {
                ActViewPhone = [[ActivityViewController_phone alloc] init];
                [ActViewPhone.view setBackgroundColor:[[[UIColor alloc] initWithWhite:0.0f alpha:0.6f] autorelease]];
                ActViewPhone.delegate = self;
                //cont = (CDVViewController*)[ super appViewController ];
                if (([[UIDevice currentDevice] orientation] == UIDeviceOrientationLandscapeLeft) ||
                    ([[UIDevice currentDevice] orientation] == UIDeviceOrientationLandscapeRight))
                    
                {
                    ActViewPhone.view.frame = CGRectMake(0, 0, 640, 960);
                    
                }
                else
                {
                    ActViewPhone.view.frame = CGRectMake(0, 0, 960, 640);
                }
                //[cont.view addSubview:ActView.view];

                //[self.viewController.view addSubview:ActViewPhone.view];
            }
            
        }
        else{
            if(ActView == nil)
            {
                ActView = [[ActivityViewController alloc] init];
                [ActView.view setBackgroundColor:[[[UIColor alloc] initWithWhite:0.0f alpha:0.6f] autorelease]];
                ActView.delegate = self;
                //cont = (CDVViewController*)[ super appViewController ];
                if (([[UIDevice currentDevice] orientation] == UIDeviceOrientationLandscapeLeft) ||
                    ([[UIDevice currentDevice] orientation] == UIDeviceOrientationLandscapeRight))
                    
                {
                    ActView.view.frame = CGRectMake(0, 0, 1024, 768);
                    
                }
                else
                {
                    ActView.view.frame = CGRectMake(0, 0, 768, 1024);
                }
                //[cont.view addSubview:ActView.view];
               // [self.viewController.view addSubview:ActView.view];
            }
            
        }

        
        UploadFiles *upload = [[UploadFiles alloc] init];
        //    NSString *retValue = [upload UploadFiles:appDelegate];
        NSString *retValue = @"";
        
        if( [[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPhone )
        {
            retValue = [upload UploadFiles_phone:appdelegate ActView:ActViewPhone];
            [ActViewPhone.view removeFromSuperview];
            [ActViewPhone release];
            [cont release];
            
            ActViewPhone = nil;
            cont = nil;
            
        }
        else{
            retValue = [upload UploadFiles:appdelegate ActView:ActView];
            [ActView.view removeFromSuperview];
            [ActView release];
            [cont release];
            
            ActView = nil;
            cont = nil;
            
            
        }

        
        errmsg = NSLocalizedString(@"Uload completed", nil);
    }
    g_Downflag = NO;
    
    UIAlertView	*av = [[[UIAlertView alloc] initWithTitle:nil message:NSLocalizedString(errmsg, nil) delegate:nil cancelButtonTitle:NSLocalizedString(@"OK",nil) otherButtonTitles:nil] autorelease];
    [av show];
}

- (void) setLoginFlag: (BOOL) loginflag SetUserID:(NSString *)user
{
    g_UserID = [[NSString alloc] init];
    g_LoginFlag = loginflag;
    g_UserID = [user copy];
    
}

- (void) setCookie: (NSMutableArray *) centralecmdelegate
{
//    g_CECMAppDelegate = centralecmdelegate;
  //  g_receivedatacontroller.ECMAppDelegate = centralecmdelegate;
}

- (void) DRiveInfo: (NIDriveInfo *)driveinfo  CookieInfo:(NICookieInfo *) cookieinfo dstpath:(NSString *)tmpPath  DownFlag:(BOOL)downflag{
    g_Downflag = downflag;
    //DriveInfo
    
    g_drive = [[NIDriveInfo alloc] init];
    g_cookieinfo = [[NICookieInfo alloc] init];
    if( driveinfo != NULL ){
        g_drive.m_strOwner = [driveinfo.m_strOwner copy];
        g_drive.m_strOwnerType = [driveinfo.m_strOwnerType copy];
        g_drive.m_strFileServerProtocol = [driveinfo.m_strFileServerProtocol copy];
        g_drive.m_strFileServer = [driveinfo.m_strFileServer copy];
        g_drive.m_strFileServerPort = [driveinfo.m_strFileServerPort copy];
        g_drive.m_strPartition = [driveinfo.m_strPartition copy];
        g_drive.m_strStartPath = [driveinfo.m_strStartPath copy];
        g_drive.m_strOrgCode = [driveinfo.m_strOrgCode copy];
        // g_drive.m_strCurrentPath = [driveinfo.m_strCurrentPath copy];
        g_drive.m_strCurrentPath = [tmpPath copy];
    }
    
    if( cookieinfo != NULL ){
        g_cookieinfo.m_strDomainID = [cookieinfo.m_strDomainID copy];
        g_cookieinfo.m_strUser = [cookieinfo.m_strUser copy];
        g_cookieinfo.m_strRealIP = [cookieinfo.m_strRealIP copy];
        g_cookieinfo.m_strWebServer = [cookieinfo.m_strWebServer copy];
        g_cookieinfo.m_strAgent = [cookieinfo.m_strAgent copy];
        g_cookieinfo.m_strSiteID = [cookieinfo.m_strSiteID copy];
    }
    
    
    [driveinfo release];
    [cookieinfo release];
    [tmpPath release];
}

@end
