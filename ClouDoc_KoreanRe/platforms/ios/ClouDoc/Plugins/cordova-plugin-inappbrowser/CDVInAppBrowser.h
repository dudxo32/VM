/*
 Licensed to the Apache Software Foundation (ASF) under one
 or more contributor license agreements.  See the NOTICE file
 distributed with this work for additional information
 regarding copyright ownership.  The ASF licenses this file
 to you under the Apache License, Version 2.0 (the
 "License"); you may not use this file except in compliance
 with the License.  You may obtain a copy of the License at
 
 http://www.apache.org/licenses/LICENSE-2.0
 
 Unless required by applicable law or agreed to in writing,
 software distributed under the License is distributed on an
 "AS IS" BASIS, WITHOUT WARRANTIES OR CONDITIONS OF ANY
 KIND, either express or implied.  See the License for the
 specific language governing permissions and limitations
 under the License.
 */

#import <Cordova/CDVPlugin.h>
#import <Cordova/CDVInvokedUrlCommand.h>
#import <Cordova/CDVScreenOrientationDelegate.h>
#import <Cordova/CDVViewController.h>

#import "AppDelegate.h"
#import "MainViewController.h"
#import "PlugPDF/DocumentViewController.h"
#import "PlugPDF/Document.h"
#import "PlugPDF/NavigationController.h"
#import "PlugPDF/OutlineItem.h"

#ifdef __CORDOVA_4_0_0
#import <Cordova/CDVUIWebViewDelegate.h>
#else
#import <Cordova/CDVWebViewDelegate.h>
#endif

@class CDVInAppBrowserViewController;

@interface CDVInAppBrowser : CDVPlugin<UICollectionViewDataSource,UICollectionViewDelegateFlowLayout,UIPopoverPresentationControllerDelegate, UIPopoverControllerDelegate, UITableViewDelegate, UITableViewDataSource, UIApplicationDelegate, PlugPDFDocumentViewControllerDelegate, UIGestureRecognizerDelegate, PlugPDFDocumentViewEventDelegate, PlugPDFAnnotEventDelegate, UIWebViewDelegate, UIPopoverBackgroundViewMethods, UISearchBarDelegate, UITextFieldDelegate> {
    UICollectionView *_collectionView;
}

@property (nonatomic, retain) CDVInAppBrowserViewController* inAppBrowserViewController;
@property (nonatomic, retain) NSString* OpenFilePath;
@property (nonatomic, copy) NSString* callbackId;
@property (nonatomic, copy) NSRegularExpression *callbackIdPattern;
@property(nonatomic, retain) NSString* convencoding;
@property (strong, nonatomic) PlugPDFDocumentViewController *DocumentViewController;

- (void)open:(CDVInvokedUrlCommand*)command;
- (void)close:(CDVInvokedUrlCommand*)command;
- (void)injectScriptCode:(CDVInvokedUrlCommand*)command;
- (void)show:(CDVInvokedUrlCommand*)command;
- (void)loadURL:(CDVInvokedUrlCommand*)command;

@property (nonatomic, readwrite, strong) NSArray* supportedOrientations;

@property (retain, nonatomic) IBOutlet UIView *testview;
@property (strong, nonatomic) UIWindow *window;
@property (strong, nonatomic) UINavigationBar *navbar;
@property (strong, nonatomic) UINavigationBar *searchNavbar;
@property (retain, nonatomic) IBOutlet UINavigationController *nav;
@property (nonatomic, strong) NSTimer *timer;
@property (nonatomic, strong) UIView *annotPopupView;
@property (nonatomic, strong) NSString *title;
@property (nonatomic, strong) UIView *beforePageView;
@property (nonatomic, strong) UIView *nextPageView;
@property (nonatomic, strong) UIView *tapBar;
@property (nonatomic, strong) AppDelegate *AD;
@property (nonatomic, strong) NSString *pdfPath;

@property (nonatomic, strong) UIView* hideView;
@property (nonatomic, strong) UIView* handView;
@property (nonatomic, strong) UIView* eraserView;
@property (nonatomic, strong) UIView* penView;
@property (nonatomic, strong) UIView* searchView;
@property (nonatomic, strong) UIView* bookMarkView;
@property (nonatomic, strong) UIView* displayModeView;
@property (nonatomic, strong) UIView* saveView;

@property (nonatomic, strong) UIView* backSearchView;
@property (nonatomic, strong) UIView* forSearchView;

/* ink */
@property (retain, nonatomic) IBOutlet UIPopoverController *inkPopoverController;
@property (nonatomic, strong) UIView *lineView;
@property (nonatomic, strong) UIView *ColorPickerView;
@property (nonatomic, strong) UIView *squareColorPickerView;
@property (nonatomic, strong) UIView *circleColorPickerView;
@property (nonatomic, strong) UIView *inkView;
//@property (nonatomic, strong) UIBarButtonItem *ink;
@property (nonatomic, strong) UIBarButtonItem *hide;
@property (nonatomic, strong) UIView *opacityView;
@property (nonatomic, strong) IBOutlet UISlider *opacitySlider;
@property (nonatomic, strong) UILabel *colorLabel;
@property (nonatomic, strong) UILabel *opacityLabel;
@property (nonatomic, strong) UILabel *opacityValue;
@property (nonatomic, strong) UILabel *boldLabel;
@property (nonatomic, strong) UILabel *boldValue;
@property (nonatomic, strong) UIView *boldView;
@property (nonatomic, strong) IBOutlet UISlider *boldSlider;
@property (nonatomic, strong) UIView *inkPopoverView;
@property (nonatomic, strong) UIViewController* inkPopoverContent;
@property (nonatomic, strong) UILabel *underLineLabel;
@property (nonatomic, strong) UILabel *underLineUseLabel;
@property (nonatomic, strong) UIView *underLineView;
@property (nonatomic, strong) UISwitch *underLineSwitch;
@property (nonatomic, strong) UIView *exampleInkColorView;
@property (nonatomic, strong) UIColor *exampleInkColor;
@property (nonatomic, strong) UIView *exampleColorView;
@property (nonatomic, strong) UIColor *exampleSquareColor;
@property (nonatomic, strong) UIView *exampleSquareCornerColorView;
@property (nonatomic, strong) UIColor *exampleSquareCornerColor;
@property (nonatomic, strong) UIColor *exampleCircleColor;
@property (nonatomic, strong) UIView *exampleCircleCornerColorView;
@property (nonatomic, strong) UIColor *exampleCircleCornerColor;
@property (nonatomic, strong) UIView *exampleHighlightColorView;
@property (nonatomic, strong) UIColor *exampleHighlightColor;
@property (nonatomic, strong) UIView *exampleUnderlineColorView;
@property (nonatomic, strong) UIColor *exampleUnderlineColor;
@property (nonatomic, strong) UIView *exampleCanclelineColorView;
@property (nonatomic, strong) UIColor *exampleCanclelineColor;
@property (nonatomic, strong) UINavigationItem *navItem;
@property (nonatomic, strong) UISearchBar *searchBar;
@property (nonatomic, strong) UIButton *beforePage;
@property (nonatomic, strong) UIButton *nextPage;
@property (nonatomic, strong) UIButton *displayRotateButton;
@property (nonatomic, strong) UIButton *bookMarkButton;
@property (nonatomic, strong) UIButton *inkButton;
@property (nonatomic, strong) UILabel *squareColorLabel;
@property (nonatomic, strong) UILabel *circleColorLabel;
@property (nonatomic, strong) UIButton *inkBtn;
@property (nonatomic, strong) UIButton *squareBtn;
@property (nonatomic, strong) UIButton *circleBtn;
@property (nonatomic, strong) UIButton *highlightBtn;
@property (nonatomic, strong) UIButton *underlineBtn;
@property (nonatomic, strong) UIButton *cancleBtn;
@property (nonatomic, strong) UIButton *noteBtn;
@property (nonatomic, strong) UIButton *eraserBtn;
@property (nonatomic, strong) UIButton *hideButton;
@property (nonatomic, strong) UIView *displayBtnView;
@property (nonatomic, strong) UIButton *displayBtn;
@property (nonatomic, strong) UIButton *defaultEraserBtn;
@property (nonatomic, strong) UIButton *blockEraserBtn;
@property (nonatomic, strong) UIButton *allEraserBtn;
@property (nonatomic, strong) UITextView *memoTextView;
@property (nonatomic, strong) UIView *memoBtnView;
@property (nonatomic, strong) UIButton* closeTap;
@property (nonatomic, strong) UIButton* backgroundTap;
@property (nonatomic, strong) UIButton* closeAllTap;
@property (nonatomic, strong) UIButton *displayModeButton;
@property CGPoint point;
@property (nonatomic, strong) UILongPressGestureRecognizer* longPress;
@property (nonatomic, strong) UIView* CloseTapView;
@property (nonatomic, strong) UIButton* handButton;
@property (nonatomic, strong) UIImage* handImage;
@property (nonatomic, strong) UIBarButtonItem* pen;
@property (nonatomic, strong) UIBarButtonItem* eraser;
@property (retain, nonatomic) IBOutlet UIPopoverController *penPopoverController;
@property (nonatomic, strong) UIViewController* penPopoverContent;
@property (nonatomic, strong) UIView *penPopoverView;
@property (retain, nonatomic) IBOutlet UIPopoverController *eraserPopoverController;
@property (nonatomic, strong) UIViewController* eraserPopoverContent;
@property (nonatomic, strong) UIView *eraserPopoverView;
@property (nonatomic, strong) NoteAnnot* tmpNote;
@property (nonatomic, strong) BaseAnnot* tmpBaseNote;
@property (nonatomic, strong) UIImage* noteIcon;
@property (nonatomic, strong) UIButton* noteIconBtn;
@property (nonatomic, strong) UIView* lineView2;
@property (nonatomic, strong) UIView* memoIconView;
@property (nonatomic, strong) NSMutableArray* viewArray;
@property (nonatomic, strong) UITapGestureRecognizer *pan;
@property (nonatomic, strong) UITapGestureRecognizer *cellTap;
@property (nonatomic, strong) UITapGestureRecognizer *backGesture;
@property (nonatomic, strong) UITapGestureRecognizer *allCloseGesture;
@property (nonatomic, strong) UIView* pageMoveView;
@property (nonatomic, strong) UILabel* pageIndicator;
@property (nonatomic, strong) UIButton *forwardButton;
@property (nonatomic, strong) UIBarButtonItem *backBtn;
@property (nonatomic, strong) UIView *closeBtnView;
@property (nonatomic, strong) UIButton *closeBtn;
@property (nonatomic, strong) UIView* backgroundTapView;
@property (nonatomic, strong) UIView* closeAllTapView;
@property (nonatomic, strong) UIView* secondLineView;
@property (nonatomic, strong) UIView* tmpView;
@property (nonatomic, strong) UIView* addBMView;
@property (nonatomic, strong) UIView* deleteBMView;
@property (nonatomic, strong) UIView* completeBMView;
@property (nonatomic, strong) UIButton *addBMbtn;
@property (nonatomic, strong) UIButton *deleteBMbtn;
@property (nonatomic, strong) UIButton *completeBMbtn;
@property (nonatomic, strong) UITapGestureRecognizer* displayBarGesture;
@property (nonatomic, strong) UITapGestureRecognizer* closeTapGesture;

/* bookMark */
@property (retain, nonatomic) IBOutlet UIPopoverController *BMpopoverController;
@property (retain, nonatomic) IBOutlet UITableView *BMtableView;
@property (retain, nonatomic) IBOutlet UINavigationBar *BMnavcon;
@property (retain, nonatomic) IBOutlet UINavigationItem *BMnavItem;
@property (retain, nonatomic) IBOutlet NSMutableArray *tabledata;
@property (retain, nonatomic) IBOutlet NSMutableArray *pagedata;
@property (nonatomic, strong) UIView* BMpopoverView;

/* displayMode */
@property (retain, nonatomic) IBOutlet UIPopoverController *displayPopoverController;
@property (nonatomic, strong) UIView *displayPopoverView;
@property (nonatomic, strong) UIViewController* displayPopoverContent;
@property (nonatomic, strong) UISlider *pageSlider;
- (IBAction)btn1touch:(UIButton *)sender;
- (IBAction)btn2touch:(UIButton *)sender;

-(IBAction)getInkOpacity:(id)sender;
-(IBAction)getInkBold:(id)sender;
-(IBAction)getSquareBold:(id)sender;

- (void)applicationDidBecomeActive:(UIApplication *)application;
- (IBAction)GetInkBackgroundColor:(UIButton *)sender;
- (IBAction)GetHighlightBackgroundColor:(UIButton *)sender;
- (IBAction)GetUnderlineBackgroundColor:(UIButton *)sender;
- (IBAction)getUnderLineSwitch:(id)sender;
- (IBAction)GetCanclelineBackgroundColor:(UIButton *)sender;
-(void) initNavigationBar;
-(void) cancelSearch: (id)sender;
-(void) backSearch: (id)sender;
-(void) forSearch: (id)sender;
- (void) hideBar: (id)sender;
- (void) displayBar: (id)sender;
- (BOOL) onTapUp: (id)sender;
- (BOOL) showNoteContents:(UIViewController *)controller annot: (UIControl *)annot;
- (BOOL) showNoteAnnotEditView:(UIViewController *)controller annot: (UIControl *)annot;
- (void) showNoteAnnotEditView: (NoteAnnot*)annot;


- (UIInterfaceOrientationMask)application:(UIApplication *)application supportedInterfaceOrientationsForWindow:(UIWindow *)window;
- (void)willAnimateRotationToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation duration:(NSTimeInterval)duration;
- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation;
- (BOOL)shouldAutorotate;

@end

static NSString* urlpath;
static NSString* convencoding;

@interface CDVInAppBrowserOptions : NSObject {}

@property (nonatomic, assign) BOOL location;
@property (nonatomic, assign) BOOL toolbar;
@property (nonatomic, copy) NSString* closebuttoncaption;
@property (nonatomic, copy) NSString* toolbarposition;
@property (nonatomic, assign) BOOL clearcache;
@property (nonatomic, assign) BOOL clearsessioncache;

@property (nonatomic, copy) NSString* presentationstyle;
@property (nonatomic, copy) NSString* transitionstyle;

@property (nonatomic, assign) BOOL enableviewportscale;
@property (nonatomic, assign) BOOL mediaplaybackrequiresuseraction;
@property (nonatomic, assign) BOOL allowinlinemediaplayback;
@property (nonatomic, assign) BOOL keyboarddisplayrequiresuseraction;
@property (nonatomic, assign) BOOL suppressesincrementalrendering;
@property (nonatomic, assign) BOOL hidden;
@property (nonatomic, assign) BOOL disallowoverscroll;

+ (CDVInAppBrowserOptions*)parseOptions:(NSString*)options;

@end

@interface CDVInAppBrowserViewController : UIViewController <UIWebViewDelegate, CDVScreenOrientationDelegate>{
@private
    NSString* _userAgent;
    NSString* _prevUserAgent;
    NSInteger _userAgentLockToken;
    CDVInAppBrowserOptions *_browserOptions;
    
#ifdef __CORDOVA_4_0_0
    CDVUIWebViewDelegate* _webViewDelegate;
#else
    CDVWebViewDelegate* _webViewDelegate;
#endif
    
}

@property (nonatomic, strong) IBOutlet UIWebView* webView;
@property (nonatomic, strong) IBOutlet UIBarButtonItem* closeButton;
@property (nonatomic, strong) IBOutlet UILabel* addressLabel;
@property (nonatomic, strong) IBOutlet UIBarButtonItem* backButton;
@property (nonatomic, strong) IBOutlet UIBarButtonItem* forwardButton;
@property (nonatomic, strong) IBOutlet UIActivityIndicatorView* spinner;
@property (nonatomic, strong) IBOutlet UIToolbar* toolbar;

@property (nonatomic, weak) id <CDVScreenOrientationDelegate> orientationDelegate;
@property (nonatomic, weak) CDVInAppBrowser* navigationDelegate;
@property (nonatomic) NSURL* currentURL;

- (void)close;
- (void)navigateTo:(NSURL*)url;
- (void)showLocationBar:(BOOL)show;
- (void)showToolBar:(BOOL)show : (NSString *) toolbarPosition;
- (void)setCloseButtonTitle:(NSString*)title;

- (id)initWithUserAgent:(NSString*)userAgent prevUserAgent:(NSString*)prevUserAgent browserOptions: (CDVInAppBrowserOptions*) browserOptions;

@end

@interface CDVInAppBrowserNavigationController : UINavigationController

@property (nonatomic, weak) id <CDVScreenOrientationDelegate> orientationDelegate;

@end

