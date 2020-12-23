////
////  Header.h
////  ClouDoc
////
////  Created by mac on 2017. 1. 5..
////
////
//
//#ifndef Header_h
//#define Header_h
//#import "AppDelegate.h"
//#import "MainViewController.h"
//#import "PlugPDF/DocumentViewController.h"
//#import "PlugPDF/Document.h"
//
//@interface third : UIViewController<UICollectionViewDataSource,UICollectionViewDelegateFlowLayout,UIPopoverPresentationControllerDelegate, UIPopoverControllerDelegate, UITableViewDelegate, UITableViewDataSource, UIApplicationDelegate, PlugPDFDocumentViewControllerDelegate, UIGestureRecognizerDelegate>
//{
//    UICollectionView *_collectionView;
//}
//
//@property (nonatomic, readwrite, strong) NSArray* supportedOrientations;
//
//@property (retain, nonatomic) IBOutlet UIView *testview;
//@property (strong, nonatomic) UIWindow *window;
//@property (strong, nonatomic) PlugPDFDocumentViewController *DocumentViewController;
//@property (strong, nonatomic) UINavigationBar *navbar;
//@property (strong, nonatomic) UINavigationBar *searchNavbar;
//@property (retain, nonatomic) IBOutlet UINavigationController *nav;
//@property (nonatomic, strong) NSTimer *timer;
//@property (nonatomic, strong) UIView *annotPopupView;
//@property (nonatomic, strong) NSString *title;
//@property (nonatomic, strong) UIView *beforePageView;
//@property (nonatomic, strong) UIView *nextPageView;
//
///* ink */
//@property (retain, nonatomic) IBOutlet UIPopoverController *inkPopoverController;
//@property (nonatomic, strong) UIView *lineView;
//@property (nonatomic, strong) UIView *ColorPickerView;
//@property (nonatomic, strong) UIView *squareColorPickerView;
//@property (nonatomic, strong) UIView *circleColorPickerView;
//@property (nonatomic, strong) UIView *inkView;
//@property (nonatomic, strong) UIBarButtonItem *ink;
//@property (nonatomic, strong) UIBarButtonItem *hide;
//@property (nonatomic, strong) UIView *opacityView;
//@property (nonatomic, strong) IBOutlet UISlider *opacitySlider;
//@property (nonatomic, strong) UILabel *colorLabel;
//@property (nonatomic, strong) UILabel *opacityLabel;
//@property (nonatomic, strong) UILabel *opacityValue;
//@property (nonatomic, strong) UILabel *boldLabel;
//@property (nonatomic, strong) UILabel *boldValue;
//@property (nonatomic, strong) UIView *boldView;
//@property (nonatomic, strong) IBOutlet UISlider *boldSlider;
//@property (nonatomic, strong) UIView *inkPopoverView;
//@property (nonatomic, strong) UIViewController* inkPopoverContent;
//@property (nonatomic, strong) UILabel *underLineLabel;
//@property (nonatomic, strong) UILabel *underLineUseLabel;
//@property (nonatomic, strong) UIView *underLineView;
//@property (nonatomic, strong) UISwitch *underLineSwitch;
//@property (nonatomic, strong) UIView *exampleInkColorView;
//@property (nonatomic, strong) UIColor *exampleInkColor;
//@property (nonatomic, strong) UIView *exampleColorView;
//@property (nonatomic, strong) UIColor *exampleSquareColor;
//@property (nonatomic, strong) UIView *exampleSquareCornerColorView;
//@property (nonatomic, strong) UIColor *exampleSquareCornerColor;
//@property (nonatomic, strong) UIColor *exampleCircleColor;
//@property (nonatomic, strong) UIView *exampleCircleCornerColorView;
//@property (nonatomic, strong) UIColor *exampleCircleCornerColor;
//@property (nonatomic, strong) UIView *exampleHighlightColorView;
//@property (nonatomic, strong) UIColor *exampleHighlightColor;
//@property (nonatomic, strong) UIView *exampleUnderlineColorView;
//@property (nonatomic, strong) UIColor *exampleUnderlineColor;
//@property (nonatomic, strong) UIView *exampleCanclelineColorView;
//@property (nonatomic, strong) UIColor *exampleCanclelineColor;
//@property (nonatomic, strong) UINavigationItem *navItem;
//@property (nonatomic, strong) UISearchBar *searchBar;
//@property (nonatomic, strong) UIButton *beforePage;
//@property (nonatomic, strong) UIButton *nextPage;
//@property (nonatomic, strong) UIButton *displayRotateButton;
//@property (nonatomic, strong) UIButton *bookMarkButton;
//@property (nonatomic, strong) UIButton *inkButton;
//@property (nonatomic, strong) UILabel *squareColorLabel;
//@property (nonatomic, strong) UILabel *circleColorLabel;
//@property (nonatomic, strong) UIButton *inkBtn;
//@property (nonatomic, strong) UIButton *squareBtn;
//@property (nonatomic, strong) UIButton *circleBtn;
//@property (nonatomic, strong) UIButton *highlightBtn;
//@property (nonatomic, strong) UIButton *underlineBtn;
//@property (nonatomic, strong) UIButton *cancleBtn;
//@property (nonatomic, strong) UIButton *noteBtn;
//@property (nonatomic, strong) UIButton *eraserBtn;
//@property (nonatomic, strong) UIButton *hideButton;
//@property (nonatomic, strong) UIView *displayBtnView;
//@property (nonatomic, strong) UIButton *displayBtn;
//@property (nonatomic, strong) UIButton *defaultEraserBtn;
//@property (nonatomic, strong) UIButton *blockEraserBtn;
//@property (nonatomic, strong) UIButton *allEraserBtn;
//
///* bookMark */
//@property (retain, nonatomic) IBOutlet UIPopoverController *BMpopoverController;
//@property (retain, nonatomic) IBOutlet UITableView *BMtableView;
//@property (retain, nonatomic) IBOutlet UINavigationBar *BMnavcon;
//@property (retain, nonatomic) IBOutlet UINavigationItem *BMnavItem;
//@property (retain, nonatomic) IBOutlet NSMutableArray *tabledata;
//@property (retain, nonatomic) IBOutlet NSMutableArray *pagedata;
//
//
///* displayMode */
//@property (retain, nonatomic) IBOutlet UIPopoverController *displayPopoverController;
//@property (nonatomic, strong) UIView *displayPopoverView;
//@property (nonatomic, strong) UIViewController* displayPopoverContent;
//@property (nonatomic, strong) UISlider *pageSlider;
//- (IBAction)btn1touch:(UIButton *)sender;
//- (IBAction)btn2touch:(UIButton *)sender;
//
//-(IBAction)getInkOpacity:(id)sender;
//-(IBAction)getInkBold:(id)sender;
//-(IBAction)getSquareBold:(id)sender;
//
//- (void)applicationDidBecomeActive:(UIApplication *)application;
//- (IBAction)GetInkBackgroundColor:(UIButton *)sender;
//- (IBAction)GetHighlightBackgroundColor:(UIButton *)sender;
//- (IBAction)GetUnderlineBackgroundColor:(UIButton *)sender;
//- (IBAction)getUnderLineSwitch:(id)sender;
//- (IBAction)GetCanclelineBackgroundColor:(UIButton *)sender;
//-(void) initNavigationBar;
//-(void) cancelSearch: (id)sender;
//-(void) backSearch: (id)sender;
//-(void) forSearch: (id)sender;
//- (void) hideBar: (id)sender;
//- (void) displayBar: (id)sender;
//- (BOOL) onTapUp: (id)sender;
//- (BOOL) showNoteContents:(UIViewController *)controller annot: (UIControl *)annot;
//- (BOOL) showNoteAnnotEditView:(UIViewController *)controller annot: (UIControl *)annot;
//- (void) showNoteAnnotEditView: (NoteAnnot*)annot;
//
//
//- (UIInterfaceOrientationMask)application:(UIApplication *)application supportedInterfaceOrientationsForWindow:(UIWindow *)window;
//- (void)willAnimateRotationToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation duration:(NSTimeInterval)duration;
//- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation;
//- (BOOL)shouldAutorotate;
//@end
//
//#endif /* Header_h */
