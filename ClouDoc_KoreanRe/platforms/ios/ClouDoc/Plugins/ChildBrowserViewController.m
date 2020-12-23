//
//  ChildBrowserViewController.m
//
//  Created by Jesse MacFadyen on 21/07/09.
//  Copyright 2009 Nitobi. All rights reserved.
//  Copyright (c) 2011, IBM Corporation
//  Copyright 2011, Randy McMillan
//

#import "ChildBrowserViewController.h"
#import "AppDelegate.h"
#import "objc/runtime.h"
#import "objc/message.h"
#import "DVTextEncoding.h"
#import "FileUtil.h"

FileUtil				*g_FileUtil;
@interface ChildBrowserViewController()

//Gesture Recognizer
- (void)addGestureRecognizer;

@end

@implementation ChildBrowserViewController

@synthesize imageURL, isImage, scaleEnabled;
@synthesize delegate, orientationDelegate;
@synthesize spinner, webView, addressLabel, toolbar;
@synthesize closeBtn, refreshBtn, backBtn, fwdBtn, safariBtn;
@synthesize supportedOrientations, OpenFilePath,convencoding;
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



- (ChildBrowserViewController*)initWithScale:(BOOL)enabled
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
    
    self.webView.delegate = self;
	self.webView.scalesPageToFit = TRUE;
	self.webView.backgroundColor = [UIColor whiteColor];
    
    
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

	[super dealloc];
#endif
}

-(void)closeBrowser
{
	
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
    g_FileUtil = [FileUtil alloc];
    
	// .tmp 폴더 삭제
	[g_FileUtil deleteFile:[NSString stringWithFormat:@"%@/.tmp", [g_FileUtil getDocumentFolder]]];

    
     [self restoreCordovaPop];
}

-(IBAction) onDoneButtonPress:(id)sender
{
    [self.webView stopLoading];
	[self closeBrowser];
    
    NSURLRequest *request = [NSURLRequest requestWithURL:[NSURL URLWithString:@"about:blank"]];
    [self.webView loadRequest:request];
}

-(IBAction) onOpenInPress:(id)sender
{
   
    NSURL   *pUrl = [NSURL fileURLWithPath:self.OpenFilePath];
    NSLog(@"pUrl is %@", pUrl);

    
    UIDocumentInteractionController *docController = [UIDocumentInteractionController interactionControllerWithURL:pUrl];
    docController.delegate = self;
    [docController retain];
    //    docController.UTI = @"com.adobe.pdf";
    [docController presentOpenInMenuFromRect:CGRectZero inView:self.view animated:YES];

    AppDelegate *app = [[AppDelegate alloc] autorelease];
    [app setChildbroswer:self];
    
}

-(IBAction) onSafariButtonPress:(id)sender
{
	
    UIActionSheet *photoSourceSheet = [[UIActionSheet alloc] initWithTitle:@"Convert" delegate:self cancelButtonTitle:@"취소" destructiveButtonTitle:nil otherButtonTitles:@"EUC-KR > UTF-8", @"SHIFT-JIS > UTF-8", @"GBK > UTF-8", nil];
    
    [photoSourceSheet showInView:self.view];
    [photoSourceSheet release];
	 
}
- (void) actionSheet: (UIActionSheet *)actionSheet didDismissWithButtonIndex: (NSInteger)buttonIndex {
    UIImagePickerController *picker = [[UIImagePickerController alloc] init];
    picker.delegate = self;
    picker.allowsEditing = YES;
    switch (buttonIndex) {
        case 0:
            NSLog(@"Convert EUC-KR to UTF-8");
            convencoding = @"euckr";
            //            picker.sourceType = UIImagePickerControllerSourceTypeCamera;
            break;
        case 1:
            NSLog(@"Convert SHIFT-JIS to UTF-8");
            convencoding = @"shiftjis";
            //            picker.sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
            break;
        case 2:
            NSLog(@"Convert BGK to UTF-8");
            convencoding = @"gbk";
            //            picker.sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
            break;
        default:
            // They picked cancel
            NSLog(@"Convert UTF-8");
            return;
    }
    NSURL *docURL = [NSURL fileURLWithPath:self.OpenFilePath];
    NSURLRequest *request = [NSURLRequest requestWithURL:docURL];
    NSString *requestURL = [NSString stringWithFormat:@"%@", [request URL]];
    DVTextEncoding *dvEncoding = [[[DVTextEncoding alloc] init] autorelease];
    dvEncoding.delegate = self;
    dvEncoding.convencoding = convencoding;
    [dvEncoding koreanWebText:requestURL webview:webView];
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
	NSLog(@"Opening Url : %@",url);
    self.OpenFilePath = [url stringByReplacingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
    NSLog(@"path is %@", self.OpenFilePath);
    
//    g_childbroswer.delegate = self.delegate;

//	if( [url hasSuffix:@".png" ]  || 
//	    [url hasSuffix:@".jpg" ]  || 
//		[url hasSuffix:@".jpeg" ] || 
//		[url hasSuffix:@".bmp" ]  || 
//		[url hasSuffix:@".gif" ]  )
//	{
//		self.imageURL = nil;
//		self.imageURL = url;
//		self.isImage = YES;
//		NSString* htmlText = @"<html><body style='background-color:#333;margin:0px;padding:0px;'><img style='min-height:200px;margin:0px;padding:0px;width:100%;height:auto;' alt='' src='IMGSRC'/></body></html>";
//		htmlText = [ htmlText stringByReplacingOccurrencesOfString:@"IMGSRC" withString:url ];
//
//		[webView loadHTMLString:htmlText baseURL:[NSURL URLWithString:@""]];
//		
//	}
//	else
//	{
   
    
     
    
    UIBarButtonItem *barItem = [UIBarButtonItem alloc];
    UIBarButtonItem *barItem2 = [UIBarButtonItem alloc];
    UIBarButtonItem *flexibleSpace = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace target:nil action:nil];
    
    NSMutableArray *items = [[toolbar.items mutableCopy]autorelease];

    NSString * ext = [self.OpenFilePath pathExtension];
    if([ext isEqualToString:@"txt"]){
          barItem = [barItem initWithTitle:NSLocalizedString(@"Conv",nil) style:UIBarButtonItemStyleBordered target:self action:@selector(onSafariButtonPress:)];
        //[items addObject:barItem];
//        [toolbar setItems:[NSArray arrayWithObjects:flexibleSpace,barItem, nil]];
//        [barItem release];
        //self.safariBtn.title = @"Conv";
    }
    
    NSLog(@"file open is %@", file_open);
    
    if([file_open isEqualToString:@"app"]){
        //self.fwdBtn.title = @"Open in ...";
        barItem2 = [barItem2 initWithTitle:NSLocalizedString(@"Open in...",nil) style:UIBarButtonItemStyleBordered target:self action:@selector(onOpenInPress:)];
//        [toolbar setItems:[NSArray arrayWithObjects:flexibleSpace,barItem2, nil]];
        //[items addObject:barItem2];
//        [barItem2 release];
    }
    UIBarButtonItem *done = [[UIBarButtonItem alloc] initWithTitle:NSLocalizedString(@"Close",nil) style:UIBarButtonItemStyleBordered target:self action:@selector(onDoneButtonPress:)];
    [toolbar setItems:[NSArray arrayWithObjects:flexibleSpace,barItem,barItem2,done, nil]];
    [barItem release];
    [barItem2 release];
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


@end
