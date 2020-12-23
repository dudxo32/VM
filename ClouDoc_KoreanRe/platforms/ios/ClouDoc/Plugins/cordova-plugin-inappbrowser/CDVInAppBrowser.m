/*
 *  뷰어 판서 팝업 버그 수정
 *  즐겨찾기함 들어간 후 해당 즐겨찾기함 이름 변경 시 현재경로에 변경한 이름이 즉시 반영되지 않는 현상 수정
 */

//  1. 문서 가로보기
//  2. 문서 세로보기
//  3. 문서 두장보기
//  4. 펜
//  5. 사각형 그리기
//  6. 원 그리기
//  7. 하이라이트
//  8. 밑줄
//  9. 취소선
// 10. 메모
// 11. 지우개
// 12. 이전페이지 이동
// 13. 다음페이지 이동
// 14.
// 15. 주석모드 취소 / 문서 종료
// 16. 저장
// 17. 화면 회전 허용/금지
// 18. 뷰어보기 팝업
// 19. 북마크
// 20. 검색
// 21. 판서 팝업
// 22. 문서 썸네일보기
// 23. 북마크 추가
// 24. 북마크 제거
// 25. 북마크 편집 완료
// 26. 실시간 지우개
// 27. 블록 지우개
// 28. 전체 지우기
// 29. 보기 모드
// 30. 노트 아이콘 팝업

#import "CDVInAppBrowser.h"
#import "AppDelegate.h"
#import <Cordova/CDVPluginResult.h>
#import <Cordova/CDVUserAgentUtil.h>
#import "objc/runtime.h"
#import "objc/message.h"
#import "DVTextEncoding.h"
#import "FileUtil.h"
#import <UIKit/UIKit.h>

#define    kInAppBrowserTargetSelf @"_self"
#define    kInAppBrowserTargetSystem @"_system"
#define    kInAppBrowserTargetBlank @"_blank"

#define    kInAppBrowserToolbarBarPositionBottom @"bottom"
#define    kInAppBrowserToolbarBarPositionTop @"top"

#define    TOOLBAR_HEIGHT 44.0
#define    LOCATIONBAR_HEIGHT 21.0
#define    FOOTER_HEIGHT ((TOOLBAR_HEIGHT) + (LOCATIONBAR_HEIGHT))

#pragma mark CDVInAppBrowser

@interface CDVInAppBrowser () {
    NSInteger _previousStatusBarStyle;
    
    int numberOfSection;
    BOOL isSwipeDeleting;
    int EditMode;
    int counter;
    int inkTag;
    int inkOpacityValue;
    float inkBoldValue;
    int highlightOpacityValue;
    int squareBoldValue;
    int circleBoldValue;
    int useUnderline;
    int beforeSliderValue;
    int currentSliderValue;
    int eraserMode;
    int inkMode;
    int click;
    int index;
    int beforeIndex;
    int cellSize;
    int loadcount;
    float pageDelay;
    
    BOOL isAnnot;
    BOOL isRotate;
    BOOL UsingInk;
    BOOL UsingSquare;
    BOOL UsingCircle;
    BOOL UsingHighlight;
    BOOL UsingUnderline;
    BOOL UsingCancle;
    BOOL UsingNote;
    BOOL UsingEraser;
    BOOL UsingSearch;
    BOOL isHidden;
    BOOL firstOpenView;
    BOOL isEbook;
    BOOL isHorizontal;
    BOOL isError;
    BOOL activateNoteMode;
    BOOL fromCollectionViewInit;
    BOOL fromOnTapUp;
    BOOL penPopup;
    BOOL inkPopup;
    BOOL displayPopup;
    BOOL bookmarkPopup;
    BOOL openViewer;
    BOOL displayHorizontal;
    BOOL displayVertical;
    BOOL addedAnnot;
    BOOL fromThumbnail;
    BOOL hiddenClose;
    BOOL fromOrientation;
    BOOL isSplit;
    BOOL eraserPopup;
    BOOL verticalThumbnailToEbook;
    BOOL fromPageFlip;
    BOOL firstOnTapUp;
    BOOL viewLoad;
    BOOL fromCellClick;
    BOOL pagedidchange;
}
@end

@implementation CDVInAppBrowser

@synthesize OpenFilePath;

- (void)pluginInitialize
{
    _previousStatusBarStyle = -1;
    _callbackIdPattern = nil;
}

- (void)onReset
{
    [self close:nil];
}

- (void)close:(CDVInvokedUrlCommand*)command
{
    if (self.inAppBrowserViewController == nil) {
        NSLog(@"IAB.close() called but it was already closed.");
        return;
    }
    // Things are cleaned up in browserExit.
    [self.inAppBrowserViewController close];
}

- (BOOL) isSystemUrl:(NSURL*)url
{
    if ([[url host] isEqualToString:@"itunes.apple.com"]) {
        return YES;
    }
    
    return NO;
}

- (void)open:(CDVInvokedUrlCommand*)command
{
    [[UIApplication sharedApplication] setStatusBarHidden:YES animated:NO];
    self.callbackId = command.callbackId;
    
    self.AD = [[UIApplication sharedApplication] delegate];
    
    self.tabledata = [[NSMutableArray alloc] init];
    self.pagedata = [[NSMutableArray alloc] init];
    inkOpacityValue = (int)[[NSUserDefaults standardUserDefaults] integerForKey:@"inkOpacityValue"];
    if(!inkOpacityValue) inkOpacityValue = 100;
    inkBoldValue = [[NSUserDefaults standardUserDefaults] floatForKey:@"inkBoldValue"];
    if(!inkBoldValue) inkBoldValue = 0.5;
    squareBoldValue = (int)[[NSUserDefaults standardUserDefaults] integerForKey:@"squareBoldValue"];
    if(!squareBoldValue) squareBoldValue = 1;
    circleBoldValue = (int)[[NSUserDefaults standardUserDefaults] integerForKey:@"circleBoldValue"];
    if(!circleBoldValue) circleBoldValue = 1;
    highlightOpacityValue = (int)[[NSUserDefaults standardUserDefaults] integerForKey:@"highlightOpacityValue"];
    if(!highlightOpacityValue) highlightOpacityValue = 100;
    useUnderline = (int)[[NSUserDefaults standardUserDefaults] integerForKey:@"useUnderline"];
    if(!useUnderline) useUnderline = 0;
    beforeSliderValue = 0;
    eraserMode = (int)[[NSUserDefaults standardUserDefaults] integerForKey:@"eraserMode"];
    if(!eraserMode) eraserMode = 1;
    inkMode = (int)[[NSUserDefaults standardUserDefaults] integerForKey:@"inkMode"];
    if(!inkMode) inkMode = 1;
    pageDelay = 0;
    loadcount = 0;
    beforeIndex = self.AD.pdfCount;
    self.inkPopoverView = [[UIView alloc] init];   //view
    self.inkPopoverContent = [[UIViewController alloc] init]; //ViewController
    NSData *exampleInkColorData = [[NSUserDefaults standardUserDefaults] objectForKey:@"exampleInkColor"];
    self.exampleInkColor = [NSKeyedUnarchiver unarchiveObjectWithData:exampleInkColorData];
    if(!self.exampleInkColor) self.exampleInkColor = [UIColor blackColor];
    NSData *exampleHighlightColorData = [[NSUserDefaults standardUserDefaults] objectForKey:@"exampleHighlightColor"];
    self.exampleHighlightColor = [NSKeyedUnarchiver unarchiveObjectWithData:exampleHighlightColorData];
    if(!self.exampleHighlightColor) self.exampleHighlightColor = [UIColor yellowColor];
    NSData *exampleUnderlineColorData = [[NSUserDefaults standardUserDefaults] objectForKey:@"exampleUnderlineColor"];
    self.exampleUnderlineColor = [NSKeyedUnarchiver unarchiveObjectWithData:exampleUnderlineColorData];
    if(!self.exampleUnderlineColor) self.exampleUnderlineColor = [UIColor blackColor];
    NSData *exampleCanclelineColorData = [[NSUserDefaults standardUserDefaults] objectForKey:@"exampleCanclelineColor"];
    self.exampleCanclelineColor = [NSKeyedUnarchiver unarchiveObjectWithData:exampleCanclelineColorData];
    if(!self.exampleCanclelineColor) self.exampleCanclelineColor = [UIColor blackColor];
    NSData *exampleSquareColorData = [[NSUserDefaults standardUserDefaults] objectForKey:@"exampleSquareColor"];
    self.exampleSquareColor = [NSKeyedUnarchiver unarchiveObjectWithData:exampleSquareColorData];
    if(!self.exampleSquareColor) self.exampleSquareColor = [UIColor clearColor];
    NSData *exampleSquareCornerColorData = [[NSUserDefaults standardUserDefaults] objectForKey:@"exampleSquareCornerColor"];
    self.exampleSquareCornerColor = [NSKeyedUnarchiver unarchiveObjectWithData:exampleSquareCornerColorData];
    if(!self.exampleSquareCornerColor) self.exampleSquareCornerColor = [UIColor blackColor];
    NSData *exampleCircleColorData = [[NSUserDefaults standardUserDefaults] objectForKey:@"exampleCircleColor"];
    self.exampleCircleColor = [NSKeyedUnarchiver unarchiveObjectWithData:exampleCircleColorData];
    if(!self.exampleCircleColor) self.exampleCircleColor = [UIColor clearColor];
    NSData *exampleCircleCornerColorData = [[NSUserDefaults standardUserDefaults] objectForKey:@"exampleCircleCornerColor"];
    self.exampleCircleCornerColor = [NSKeyedUnarchiver unarchiveObjectWithData:exampleCircleCornerColorData];
    if(!self.exampleCircleCornerColor) self.exampleCircleCornerColor = [UIColor blackColor];
    isAnnot = NO;
    isRotate = YES;
    UsingInk = NO;
    UsingSquare = NO;
    UsingCircle = NO;
    UsingHighlight = NO;
    UsingUnderline = NO;
    UsingCancle = NO;
    UsingNote = NO;
    UsingEraser = NO;
    UsingSearch = NO;
    isHidden = NO;
    firstOpenView = NO;
    isError = NO;
    activateNoteMode = NO;
    fromCollectionViewInit = NO;
    fromOnTapUp = NO;
    penPopup = NO;
    inkPopup = NO;
    eraserPopup = NO;
    displayPopup = NO;
    bookmarkPopup = NO;
    openViewer = YES;
    displayHorizontal = YES;
    displayVertical = NO;
    fromThumbnail = NO;
    hiddenClose = NO;
    fromOrientation = NO;
    isSplit = NO;
    verticalThumbnailToEbook = NO;
    fromPageFlip = NO;
    firstOnTapUp = YES;
    viewLoad = NO;
    fromCellClick = NO;
    pagedidchange = YES;
    
    self.noteIcon = [UIImage imageNamed:@"viewer-icon/icon-memo-01.png"];
    
    int orientation = [[UIApplication sharedApplication] statusBarOrientation];
    if((int)orientation == 3 || (int)orientation == 4) isHorizontal = YES;
    else isHorizontal = NO;
    
    CDVPluginResult* pluginResult;
    
    NSArray *arrItem = [[command argumentAtIndex:0] componentsSeparatedByString:@"netid_&"];
    [[NSUserDefaults standardUserDefaults] setValue:arrItem[1] forKey:@"documentPreview"];
    [[NSUserDefaults standardUserDefaults] setValue:arrItem[2] forKey:@"filelength"];
    
    NSString* url = arrItem[0];
    NSString* target = [command argumentAtIndex:1 withDefault:kInAppBrowserTargetSelf];
    NSString* options = [command argumentAtIndex:2 withDefault:@"" andClass:[NSString class]];
    
    urlpath = url;
    
    NSLog(@"url = %@", url);
    NSLog(@"target = %@", target);
    NSLog(@"options = %@", options);
    
    
    //    // Generate the path to the new directory
    //    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSLibraryDirectory, NSUserDomainMask, YES);
    //    NSString *newDirectory = [NSString stringWithFormat:@"%@/test2/test3/test4", [paths objectAtIndex:0]];
    //
    //    BOOL isDir;
    //    BOOL exists = [[NSFileManager defaultManager] fileExistsAtPath:newDirectory isDirectory:&isDir];
    //    if (exists) {
    //        NSLog(@"exists file YES");
    //        if (isDir) {
    //            NSLog(@"exists folder YES");
    //        }
    //    }
    //
    //    // Check if the directory already exists
    //    if (![[NSFileManager defaultManager] fileExistsAtPath:newDirectory]) {
    //        // Directory does not exist so create it
    //        NSLog(@"Directory does not exist so create it");
    //        [[NSFileManager defaultManager] createDirectoryAtPath:newDirectory withIntermediateDirectories:YES attributes:nil error:nil];
    //    } else {
    //        NSLog(@"Directory does exist");
    //    }
    //
    //    exists = [[NSFileManager defaultManager] fileExistsAtPath:newDirectory isDirectory:&isDir];
    //    if (exists) {
    //        NSLog(@"exists2 file YES");
    //        if (isDir) {
    //            NSLog(@"exists2 folder YES");
    //        }
    //    }
    
    BOOL isOpened;
    isOpened = NO;
    for (id key in self.AD.tmpVCDic)
    {
        if([key isEqualToString:self.AD.tmpFilePath]) isOpened = YES;
    }
    
    
    NSString *pdfPath = url.stringByRemovingPercentEncoding;
    pdfPath = [pdfPath stringByReplacingOccurrencesOfString:@"file://" withString:@""];
    NSLog(@"pdfPath = %@", pdfPath);
    
    BOOL Exist = NO;
    NSRange strRange1 = [url rangeOfString:@".xlsx"];
    NSRange strRange2 = [url rangeOfString:@".xls"];
    NSRange strRange3 = [url rangeOfString:@".docx"];
    NSRange strRange4 = [url rangeOfString:@".doc"];
    NSRange strRange5 = [url rangeOfString:@".hwp"];
    NSRange strRange6 = [url rangeOfString:@".pptx"];
    NSRange strRange7 = [url rangeOfString:@".ppt"];
    NSRange strRange8 = [url rangeOfString:@".pdf"];
    NSString *convertPdfPath;
    
    NSString *encodingPath = url.stringByRemovingPercentEncoding;
    
    if (strRange1.location != NSNotFound) {
        Exist = YES;
        convertPdfPath = [encodingPath stringByReplacingOccurrencesOfString:@"xlsx" withString:@"pdf"];
    } else if(strRange2.location != NSNotFound){
        Exist = YES;
        convertPdfPath = [encodingPath stringByReplacingOccurrencesOfString:@"xls" withString:@"pdf"];
    } else if(strRange3.location != NSNotFound){
        Exist = YES;
        convertPdfPath = [encodingPath stringByReplacingOccurrencesOfString:@"docx" withString:@"pdf"];
    } else if(strRange4.location != NSNotFound){
        Exist = YES;
        convertPdfPath = [encodingPath stringByReplacingOccurrencesOfString:@"doc" withString:@"pdf"];
    } else if(strRange5.location != NSNotFound){
        Exist = YES;
        convertPdfPath = [encodingPath stringByReplacingOccurrencesOfString:@"hwp" withString:@"pdf"];
    } else if(strRange6.location != NSNotFound){
        Exist = YES;
        convertPdfPath = [encodingPath stringByReplacingOccurrencesOfString:@"pptx" withString:@"pdf"];
    } else if(strRange7.location != NSNotFound){
        Exist = YES;
        convertPdfPath = [encodingPath stringByReplacingOccurrencesOfString:@"ppt" withString:@"pdf"];
    } else if(strRange8.location != NSNotFound){
        Exist = YES;
        convertPdfPath = encodingPath;
    }
    
    if (Exist) {
        encodingPath = [encodingPath stringByReplacingOccurrencesOfString:@"file://" withString:@""];
        convertPdfPath = [convertPdfPath stringByReplacingOccurrencesOfString:@"file://" withString:@""];
        BOOL fileExists = [[NSFileManager defaultManager] fileExistsAtPath:encodingPath];
        if(fileExists) NSLog(@"Yes");
        else NSLog(@"no");
        
        //        if(strRange8.location == NSNotFound){
        //            [[NSFileManager defaultManager] moveItemAtPath:encodingPath toPath:convertPdfPath error:nil];
        //        }
        
        NSLog(@"convertPdfPath = %@", convertPdfPath);
        self.pdfPath = convertPdfPath;
        
        
        // 다른 경로의 같은 이름인 파일 구별
        BOOL existDic = NO;
        NSString* tmpPath = [[convertPdfPath lastPathComponent] stringByDeletingPathExtension];
        if(!self.AD.isOpened)
        {
            for(int i = 0; i < self.AD.VCDic.count; i++)
            {
                for(id key in self.AD.VCDic)
                {
                    NSString* tmpKey = [[key lastPathComponent] stringByDeletingPathExtension];
                    if([tmpKey isEqualToString:tmpPath])
                    {
                        NSString* tmpExtension = @"(";
                        tmpExtension = [tmpExtension stringByAppendingString:[NSString stringWithFormat:@"%d",i+1]];
                        tmpExtension = [tmpExtension stringByAppendingString:@")"];
                        tmpPath = [[convertPdfPath lastPathComponent] stringByDeletingPathExtension];
                        tmpPath = [tmpPath stringByAppendingString:tmpExtension];
                    }
                }
            }
            NSString* newPdfPath = [convertPdfPath stringByReplacingOccurrencesOfString:[[convertPdfPath lastPathComponent] stringByDeletingPathExtension] withString:tmpPath];
            [[NSFileManager defaultManager] moveItemAtPath:encodingPath toPath:newPdfPath error:nil];
            self.pdfPath = newPdfPath;
            [self.AD.tmpVCDic setObject:self.pdfPath forKey:self.AD.tmpFilePath];
        } else {
            if(strRange8.location == NSNotFound){
                [[NSFileManager defaultManager] moveItemAtPath:encodingPath toPath:convertPdfPath error:nil];
            }
            for(int i = 0; i < 10; i++)
            {
                for(id key in self.AD.tmpVCDic)
                {
                    if([key isEqualToString:self.AD.tmpFilePath]){
                        NSString* tmpKey = [[[self.AD.tmpVCDic valueForKey:key] lastPathComponent] stringByDeletingPathExtension];
                        NSString* tmpExtension = @"";
                        if(!existDic && i == 0){
                            tmpPath = [[convertPdfPath lastPathComponent] stringByDeletingPathExtension];
                        }
                        if(!existDic && i != 0){
                            tmpExtension = @"(";
                            tmpExtension = [tmpExtension stringByAppendingString:[NSString stringWithFormat:@"%d",i]];
                            tmpExtension = [tmpExtension stringByAppendingString:@")"];
                            tmpPath = [[convertPdfPath lastPathComponent] stringByDeletingPathExtension];
                            tmpPath = [tmpPath stringByAppendingString:tmpExtension];
                            
                        }
                        if([tmpKey isEqualToString:tmpPath])
                        {
                            existDic = YES;
                        }
                    }
                }
            }
            if(existDic){
                NSString* newPdfPath = [convertPdfPath stringByReplacingOccurrencesOfString:[[convertPdfPath lastPathComponent] stringByDeletingPathExtension] withString:tmpPath];
                NSLog(@"newPdfPath = %@", newPdfPath);
                self.pdfPath = newPdfPath;
            }
        }
        
        if ([[[NSUserDefaults standardUserDefaults] objectForKey:@"filelength"] isEqualToString:@"end"]) {
            [self ViewControllerInit];
            if(isError) return;
            [self initCollectionView];
            [self initNavigationBar];
            [self initMovePageButton];
        }
        else {
            [self ViewControllerInit];
        }
    } else {
        if (url != nil) {
#ifdef __CORDOVA_4_0_0
            NSURL* baseUrl = [self.webViewEngine URL];
#else
            NSURL* baseUrl = [self.webView.request URL];
#endif
            NSURL* absoluteUrl = [[NSURL URLWithString:url relativeToURL:baseUrl] absoluteURL];
            
            if ([self isSystemUrl:absoluteUrl]) {
                target = kInAppBrowserTargetSystem;
            }
            
            if ([target isEqualToString:kInAppBrowserTargetSelf]) {
                [self openInCordovaWebView:absoluteUrl withOptions:options];
            } else if ([target isEqualToString:kInAppBrowserTargetSystem]) {
                [self openInSystem:absoluteUrl];
            } else { // _blank or anything else
                [self openInInAppBrowser:absoluteUrl withOptions:options];
            }
            
            pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK];
        } else {
            pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_ERROR messageAsString:@"incorrect number of arguments"];
        }
        
        [pluginResult setKeepCallback:[NSNumber numberWithBool:YES]];
        [self.commandDelegate sendPluginResult:pluginResult callbackId:command.callbackId];
    }
    //    UITapGestureRecognizer *pan = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(aaaa:)];
    //    [self.window.rootViewController.view addGestureRecognizer:pan];
    
    // 클립보드 복사 금지
    self.longPress = [[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(handleLongPressGestures:)]; // allocating the UILongPressGestureRecognizer
    
    self.longPress.allowableMovement=100; // Making sure the allowable movement isn't too narrow
    
    self.longPress.minimumPressDuration=0.3; // This is important - the duration must be long enough to allow taps but not longer than the period in which the scroll view opens the magnifying glass
    
    self.longPress.delegate=self; // initialization stuff
    self.longPress.delaysTouchesBegan=YES;
    self.longPress.delaysTouchesEnded=YES;
    
    self.longPress.cancelsTouchesInView=YES; // That's when we tell the gesture recognizer to block the gestures we want
    
    self.pan = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(pan:)];
    
    self.viewArray = [[NSMutableArray alloc] init];
    [self.viewArray addObject:self.AD.navigationController.view];
}

- (void)viewDidLoad:(PlugPDFDocumentViewController*)viewController
{
    NSLog(@"PlugPdfDocumentViewController Init Event");
    //    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(5.3 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
    UITapGestureRecognizer *pan = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(pan:)];
    //    [viewController.documentView addGestureRecognizer:pan];
    /*    [self.navigationController.navigationBar setBackgroundImage: nil
     forBarMetrics: UIBarMetricsDefault];
     [self.navigationController.toolbar setBackgroundImage: nil
     forToolbarPosition: UIToolbarPositionBottom
     barMetrics: UIBarMetricsDefault];
     [viewController setToolbarItems: nil];*/
    //    });
}
- (void)pan: (UITapGestureRecognizer*)recognizer
{
    //    self.point = [recognizer locationInView: self.DocumentViewController.documentView];
    
    //    NSLog(@"-=-=-=-=-=-==-=-=onSingleTapGesture point(%.f, %.f)", point.x, point.y);
}

//- (void)aaaa: (UITapGestureRecognizer*)recognizer
//{
//    NSLog(@"aaaa");
//}

//- (BOOL)onLongPress: (UILongPressGestureRecognizer*)longPress view:(UIView*)view{
//    NSLog(@"onLongPress");
//    return NO;
//}



- (void)AnnotisAdded: (UIControl*)annot{
    addedAnnot = YES;
    NSLog(@"AnnotisAdded");
    penPopup = NO;
    inkPopup = NO;
    eraserPopup = NO;
    [self.penPopoverController dismissPopoverAnimated:NO];
    [self.inkPopoverController dismissPopoverAnimated:NO];
    
    [self.DocumentViewController setNoteIcon:self.noteIcon];
    
    if ([annot isKindOfClass:[NoteAnnot class]]){
        [self.DocumentViewController saveAnnot:(BaseAnnot*)annot];
        [self.handButton sendActionsForControlEvents:UIControlEventTouchUpInside];
    }
}

- (void)AnnotisRemoved: (UIControl*)annot{
    NSLog(@"AnnotisRemoved");
    penPopup = NO;
    inkPopup = NO;
    eraserPopup = NO;
    [self.eraserPopoverController dismissPopoverAnimated:NO];
    [self.inkPopoverController dismissPopoverAnimated:NO];
}

//- (BOOL)onSwipe: (UISwipeGestureRecognizer*)swipe{
//    NSLog(@"Swipe");
//    return NO;
//}
//
- (BOOL)onSingleTap: (UITapGestureRecognizer*)singleTap view:(UIView*)view{
    
    NSLog(@"onSingleTap");
    //    PlugPDFPageView* pageView = [self.DocumentViewController.documentView pageView:self.DocumentViewController.pageIdx];
    //    self.point = [singleTap locationInView: pageView.imageView] ;
    //    NSLog(@"-=-=-=-=-=-==-=-=onSingleTapGesture point(%.f, %.f)", self.point.x, self.point.y);
    if(UsingNote && !fromOnTapUp){
        if(isHidden) {
            [self.displayBtn sendActionsForControlEvents:UIControlEventTouchUpInside];
            dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.1 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                PlugPDFPageView* pageView = [self.DocumentViewController.documentView pageView:self.DocumentViewController.pageIdx];
                self.point = [singleTap locationInView: pageView.imageView] ;
                NSLog(@"-=-=-=-=-=-==-=-=onSingleTapGesture point(%.f, %.f)", self.point.x, self.point.y);
                
                self.lineView = [[UIView alloc] initWithFrame:CGRectMake(0,55, self.window.frame.size.width, 2)];
                self.lineView.backgroundColor = [UIColor colorWithRed:0.09 green:(0.20) blue:0.35 alpha:1.00];
                
                self.memoTextView = [[UITextView alloc] initWithFrame:CGRectMake(0,60, self.inkPopoverView.frame.size.width, 200)];
                self.memoTextView.backgroundColor = [UIColor colorWithRed:1.00 green:0.95 blue:0.74 alpha:1.00];
                [self.memoTextView setFont:[UIFont systemFontOfSize:15]];
                
                self.memoBtnView = [[UIView alloc] initWithFrame:CGRectMake(0,260, self.inkPopoverView.frame.size.width, 40)];
                self.memoBtnView.backgroundColor = [UIColor colorWithRed:0.94 green:0.92 blue:0.94 alpha:1.00];
                
                self.noteIconBtn = [[UIButton alloc] initWithFrame: CGRectMake(10, 7.5, 25, 25)];
                [self.noteIconBtn setImage:self.noteIcon forState:UIControlStateNormal];
                [self.noteIconBtn addTarget: self action: @selector(memo) forControlEvents: UIControlEventTouchUpInside];
                self.noteIconBtn.tag = 30;
                
                UILabel* memoOK = [[UILabel alloc] initWithFrame:CGRectMake(275, 5, 30, 30)];
                memoOK.text = @"확인";
                memoOK.userInteractionEnabled = YES;
                UITapGestureRecognizer *OKGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(MemoOk)];
                [memoOK addGestureRecognizer:OKGesture];
                
                UILabel* memoCancel = [[UILabel alloc] initWithFrame:CGRectMake(320, 5, 30, 30)];
                memoCancel.text = @"취소";
                memoCancel.userInteractionEnabled = YES;
                UITapGestureRecognizer *CancelGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(MemoCancel)];
                [memoCancel addGestureRecognizer:CancelGesture];
                
                [self.memoBtnView addSubview:self.noteIconBtn];
                [self.memoBtnView addSubview:memoOK];
                [self.memoBtnView addSubview:memoCancel];
                
                [self.inkPopoverView addSubview:self.lineView];
                [self.inkPopoverView addSubview:self.memoTextView];
                [self.inkPopoverView addSubview:self.memoBtnView];
                
                self.inkPopoverController.popoverContentSize = CGSizeMake(365, 300);
                [self.inkPopoverController presentPopoverFromRect:CGRectMake(CGRectGetWidth(self.annotPopupView.frame)/2, 30, 0, 0) inView:self.annotPopupView permittedArrowDirections:UIPopoverArrowDirectionUp animated:YES];
            });
        } else {
            PlugPDFPageView* pageView = [self.DocumentViewController.documentView pageView:self.DocumentViewController.pageIdx];
            self.point = [singleTap locationInView: pageView.imageView] ;
            NSLog(@"-=-=-=-=-=-==-=-=onSingleTapGesture point(%.f, %.f)", self.point.x, self.point.y);
            
            self.lineView = [[UIView alloc] initWithFrame:CGRectMake(0,55, self.window.frame.size.width, 2)];
            self.lineView.backgroundColor = [UIColor colorWithRed:0.09 green:(0.20) blue:0.35 alpha:1.00];
            
            self.memoTextView = [[UITextView alloc] initWithFrame:CGRectMake(0,60, self.inkPopoverView.frame.size.width, 200)];
            self.memoTextView.backgroundColor = [UIColor colorWithRed:1.00 green:0.95 blue:0.74 alpha:1.00];
            [self.memoTextView setFont:[UIFont systemFontOfSize:15]];
            
            self.memoBtnView = [[UIView alloc] initWithFrame:CGRectMake(0,260, self.inkPopoverView.frame.size.width, 40)];
            self.memoBtnView.backgroundColor = [UIColor colorWithRed:0.94 green:0.92 blue:0.94 alpha:1.00];
            
            self.noteIconBtn = [[UIButton alloc] initWithFrame: CGRectMake(10, 7.5, 25, 25)];
            [self.noteIconBtn setImage:self.noteIcon forState:UIControlStateNormal];
            [self.noteIconBtn addTarget: self action: @selector(openPlugPDF3:) forControlEvents: UIControlEventTouchUpInside];
            self.noteIconBtn.tag = 30;
            
            UILabel* memoOK = [[UILabel alloc] initWithFrame:CGRectMake(275, 5, 30, 30)];
            memoOK.text = @"확인";
            memoOK.userInteractionEnabled = YES;
            UITapGestureRecognizer *OKGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(MemoOk)];
            [memoOK addGestureRecognizer:OKGesture];
            
            UILabel* memoCancel = [[UILabel alloc] initWithFrame:CGRectMake(320, 5, 30, 30)];
            memoCancel.text = @"취소";
            memoCancel.userInteractionEnabled = YES;
            UITapGestureRecognizer *CancelGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(MemoCancel)];
            [memoCancel addGestureRecognizer:CancelGesture];
            
            [self.memoBtnView addSubview:self.noteIconBtn];
            [self.memoBtnView addSubview:memoOK];
            [self.memoBtnView addSubview:memoCancel];
            
            [self.inkPopoverView addSubview:self.lineView];
            [self.inkPopoverView addSubview:self.memoTextView];
            [self.inkPopoverView addSubview:self.memoBtnView];
            
            self.inkPopoverController.popoverContentSize = CGSizeMake(365, 300);
            [self.inkPopoverController presentPopoverFromRect:CGRectMake(CGRectGetWidth(self.annotPopupView.frame)/2, 30, 0, 0) inView:self.annotPopupView permittedArrowDirections:UIPopoverArrowDirectionUp animated:YES];
        }
        
        //        if(fromOnTapUp){
        //            [self.noteBtn setImage:[UIImage imageNamed:@"viewer-icon/pan-icon-07.png"] forState:UIControlStateNormal];
        //            [self.handButton setImage:[UIImage imageNamed:@"viewer-icon/hand-on.png"] forState:UIControlStateNormal];
        //            [self.inkButton setImage:[UIImage imageNamed:@"viewer-icon/top-icon-06.png"] forState:UIControlStateNormal];
        //        }
        UsingNote = NO;
    }
    
    return NO;
}
//
//- (void)pan:(UITapGestureRecognizer *)gesture
//{
//    NSLog(@"pan");
//    // get information from the gesture object
//}


-(void) initCollectionView{
    [self.tapBar removeFromSuperview];
    NSLog(@"initCollectionView");
    self.tapBar = [[UIView alloc] initWithFrame:CGRectMake(0, 0, CGRectGetWidth(self.window.frame), 40)];
    self.tapBar.backgroundColor = [UIColor colorWithRed:0.03 green:0.16 blue:0.32 alpha:0.70];
    UICollectionViewFlowLayout *layout=[[UICollectionViewFlowLayout alloc] init];
    _collectionView=[[UICollectionView alloc] initWithFrame:CGRectMake(0, 0, CGRectGetWidth(self.tapBar.frame)-100, 40) collectionViewLayout:layout];
    [_collectionView setDataSource:self];
    [_collectionView setDelegate:self];
    
    int orientation = [[UIApplication sharedApplication] statusBarOrientation];
    CGFloat windowHeight = CGRectGetHeight(self.window.frame);
    CGFloat windowWidth = CGRectGetWidth(self.window.frame);
    NSLog(@"windowWidth = %f", windowWidth);
    if(windowWidth > 1000) isSplit = YES;
    else isSplit = NO;
    if(windowWidth > 1200){
        cellSize = (CGRectGetWidth(self.tapBar.frame)-100)/4;
    } else if (windowWidth < 1200 && windowWidth > 700) {
        cellSize = (CGRectGetWidth(self.tapBar.frame)-100)/3;
    } else {
        cellSize = (CGRectGetWidth(self.tapBar.frame)-100)/3;
    }
    
    [_collectionView registerClass:[UICollectionViewCell class] forCellWithReuseIdentifier:@"cellIdentifier"];
    [_collectionView setBackgroundColor:[UIColor colorWithRed:0.03 green:0.16 blue:0.32 alpha:0.70]];
    [_collectionView setShowsHorizontalScrollIndicator:YES];
    
    ((UICollectionViewFlowLayout *)_collectionView.collectionViewLayout).scrollDirection = UICollectionViewScrollDirectionHorizontal;
    [_collectionView setAlwaysBounceHorizontal:YES];
    ((UICollectionViewFlowLayout *)_collectionView.collectionViewLayout).minimumLineSpacing = 0; // 셀 간격
    [_collectionView setAllowsMultipleSelection:NO];
    
    
    self.backgroundTapView = [[UIView alloc] initWithFrame:CGRectMake(self.tapBar.frame.size.width-80, 0, 40, 40)];
    self.backGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(BackgroundTap:)];
    [self.backgroundTapView addGestureRecognizer:self.backGesture];
    
    self.backgroundTap = [[UIButton alloc] initWithFrame: CGRectMake(0, 10, 20, 20)];
    [self.backgroundTap setImage:[UIImage imageNamed:@"viewer-icon/home.png"] forState:UIControlStateNormal];
    [self.backgroundTap addTarget: self action: @selector(BackgroundTap:) forControlEvents: UIControlEventTouchUpInside];
    [self.backgroundTapView addSubview:self.backgroundTap];
    [self.tapBar addSubview:self.backgroundTapView];
    
    self.closeAllTapView = [[UIView alloc] initWithFrame:CGRectMake(self.tapBar.frame.size.width-40, 0, 40, 40)];
    self.allCloseGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(CloseAllTap:)];
    [self.closeAllTapView addGestureRecognizer:self.allCloseGesture];
    
    self.closeAllTap = [[UIButton alloc] initWithFrame: CGRectMake(0, 10, 20, 20)];
    [self.closeAllTap setImage:[UIImage imageNamed:@"viewer-icon/tap-close-03.png"] forState:UIControlStateNormal];
    [self.closeAllTap addTarget: self action: @selector(CloseAllTap:) forControlEvents: UIControlEventTouchUpInside];
    [self.closeAllTapView addSubview:self.closeAllTap];
    [self.tapBar addSubview:self.closeAllTapView];
    
    [self.tapBar addSubview:_collectionView];
    [self.AD.navigationController.view addSubview:self.tapBar];
    
    NSLog(@"init collection index = %d", index);
    
    if(firstOpenView){
        NSLog(@"firstOpenView in");
        //        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.1 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        int i = 0;
        for (id key in self.AD.VCDic) {
            if(i == index) {
                self.title = [[key lastPathComponent] stringByDeletingPathExtension];
                //                    self.navbar.topItem.title = self.title;
                self.backBtn.title = self.title;
                self.pdfPath = key;
                //                    NSURL *url = [NSURL URLWithString:[self.pdfPath stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding]];
                //                    [self.DocumentViewController saveAsFile:url];
                [self.DocumentViewController saveAsFile:[[NSURL alloc] initFileURLWithPath: self.pdfPath]];
                //                [self.DocumentViewController saveFile:YES];
                self.DocumentViewController = nil;
                //                self.DocumentViewController = [PlugPDFDocumentViewController initWithPath:key password:@"" title:@""];
                self.DocumentViewController = [self.AD.VCDic objectForKey:key];
                int i = 0;
                @try{
                    NSLog(@"Push");
                    [self.AD.navigationController pushViewController:self.DocumentViewController animated:NO];
                    i = 1;
                }@catch (NSException * e) {
                    NSLog(@"Pop");
                    [self.AD.navigationController popToViewController:self.DocumentViewController animated:NO];
                }@finally {
                    //                        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.3 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                    if(isHidden){
                        [self.DocumentViewController setEnableAlwaysVisible:NO];
                    } else {
                        [self.DocumentViewController setEnableAlwaysVisible:YES];
                    }
                    
                    // 탭 자동 이동
                    int i = 1;
                    for (id key in self.AD.VCDic) {
                        if([key isEqualToString:self.pdfPath]){
                            break;
                        }
                        i = i + 1;
                    }
                    
                    NSLog(@"windowWidth = %f", windowWidth);
                    NSLog(@"VCDic.count = %lu", (unsigned long)self.AD.VCDic.count);
                    if(windowWidth > 1200){
                        if(self.AD.VCDic.count > 4){
                            long movePoint = (long)(i-4)*cellSize;
                            if(movePoint < 1) movePoint = 0;
                            [_collectionView setContentOffset:CGPointMake(movePoint, 0) animated:YES];
                        }
                    } else if (windowWidth < 1200 && windowWidth > 700) {
                        if(self.AD.VCDic.count > 3){
                            long movePoint = (long)(i-3)*cellSize;
                            if(movePoint < 1) movePoint = 0;
                            [_collectionView setContentOffset:CGPointMake(movePoint, 0) animated:YES];
                        }
                    } else {
                        if(self.AD.VCDic.count > 3){
                            long movePoint = (long)(i-3)*cellSize;
                            if(movePoint < 1) movePoint = 0;
                            [_collectionView setContentOffset:CGPointMake(movePoint, 0) animated:YES];
                        }
                    }
                    
                    //셀 강제 선택
                    [self collectionView:_collectionView didSelectItemAtIndexPath:[NSIndexPath indexPathForRow:index inSection:0]];
                    //                        });
                }
            }
            i = i + 1;
        }
        //        });
    } else {
        NSLog(@"firstOpenView no in");
        // 탭 자동 이동
        int i = 1;
        for (id key in self.AD.VCDic) {
            if([key isEqualToString:self.pdfPath]){
                break;
            }
            i = i + 1;
        }
        
        int orientation = [[UIApplication sharedApplication] statusBarOrientation];
        NSLog(@"windowWidth = %f", windowWidth);
        NSLog(@"VCDic.count = %lu", (unsigned long)self.AD.VCDic.count);
        if(windowWidth > 1200){
            if(self.AD.VCDic.count > 4){
                long movePoint = (long)(i-4)*cellSize;
                if(movePoint < 1) movePoint = 0;
                [_collectionView setContentOffset:CGPointMake(movePoint, 0) animated:YES];
            }
        } else if (windowWidth < 1200 && windowWidth > 700) {
            if(self.AD.VCDic.count > 3){
                long movePoint = (long)(i-3)*cellSize;
                if(movePoint < 1) movePoint = 0;
                [_collectionView setContentOffset:CGPointMake(movePoint, 0) animated:YES];
            }
        } else {
            if(self.AD.VCDic.count > 3){
                long movePoint = (long)(i-3)*cellSize;
                if(movePoint < 1) movePoint = 0;
                [_collectionView setContentOffset:CGPointMake(movePoint, 0) animated:YES];
            }
        }
        
        //셀 강제 선택
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.3 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            [self collectionView:_collectionView didSelectItemAtIndexPath:[NSIndexPath indexPathForRow:index inSection:0]];
        });
    }
    
    firstOpenView = YES;
}

-(void) ViewControllerInit{
    fromCollectionViewInit = YES;
    click = 0;
    self.window = [UIApplication sharedApplication].keyWindow;
    BOOL existDocument = NO;
    int i = 1;
    for (id key in self.AD.VCDic) {
        if([key isEqualToString:self.pdfPath]){
            self.title = [[key lastPathComponent] stringByDeletingPathExtension];
            self.backBtn.title = self.title;
            existDocument = YES;
            self.AD.pdfCount = i;
            self.DocumentViewController = [self.AD.VCDic objectForKey:self.pdfPath];
            [self.AD.navigationController pushViewController:self.DocumentViewController animated:YES];
            index = i-1;
            beforeIndex = index;
            UIDeviceOrientation deviceOrientation = [[UIDevice currentDevice] orientation];
            if((int)deviceOrientation == 3 || (int)deviceOrientation == 4){
                [self.DocumentViewController setEnablePageFlipEffect:NO];
                [self.DocumentViewController setDisplayMode:PlugPDFDocumentDisplayModeHorizontal];
            } else {
                [self.DocumentViewController setEnablePageFlipEffect:YES];
            }
            return;
        }
        i = i + 1;
    }
    if(!existDocument){
        self.title = [[self.pdfPath lastPathComponent] stringByDeletingPathExtension];
        self.AD.pdfCount = self.AD.pdfCount + 1;
        @try {
            self.DocumentViewController = [PlugPDFDocumentViewController initWithPath: self.pdfPath
                                                                             password: @""
                                                                                title: nil];
        }
        @catch (NSException *exception) {
            NSString* alertString = @"";
            
            if([exception.name isEqualToString:@"PasswordMismatch"]) {
                isError = YES;
                alertString = @"비밀번호가 맞지 않습니다.";
            } else if ([exception.name isEqualToString:@"CorruptedPDF"]) {
                isError = YES;
                alertString = @"PDF형식의 파일이 아닙니다.";
            }
                
                
            NSLog(@"Exception %@ %@", exception.name, exception.description);
            self.AD.pdfCount = self.AD.pdfCount - 1;
            
            BOOL fileExists = [[NSFileManager defaultManager] fileExistsAtPath:self.pdfPath];
            if(fileExists) {
                NSLog(@"file exist!!!!");
            } else {
                NSLog(@"file not exist!!!!");
                alertString = @"파일을 찾을 수 없습니다.";
            }
            
            
            
            UIAlertController * alert=   [UIAlertController
                                          alertControllerWithTitle:alertString
                                          message:@""
                                          preferredStyle:UIAlertControllerStyleAlert];
            
            UIAlertAction* ok = [UIAlertAction
                                 actionWithTitle:@"OK"
                                 style:UIAlertActionStyleDefault
                                 handler:^(UIAlertAction * action)
                                 {
                                     [alert dismissViewControllerAnimated:YES completion:nil];
                                 }];
            
            [alert addAction:ok];
            
            [self.AD.navigationController presentViewController:alert animated:YES completion:nil];
            dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.01 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                self.AD.viewController.view.frame =  CGRectMake(0, -20, self.AD.viewController.view.window.frame.size.width, self.AD.viewController.view.window.frame.size.height+20);
            });
            
            return;
        }
        
        if (self.DocumentViewController) {
            [self.AD.navigationController pushViewController: self.DocumentViewController animated: NO];
            
            NSLog(@"%@", [UIDevice currentDevice].systemVersion);
            
            if ([[UIDevice currentDevice].systemVersion hasPrefix:@"7"] ||
                [[UIDevice currentDevice].systemVersion hasPrefix:@"8"] ||
                [[UIDevice currentDevice].systemVersion hasPrefix:@"9"] ||
                [[UIDevice currentDevice].systemVersion hasPrefix:@"10"] ||
                [[UIDevice currentDevice].systemVersion hasPrefix:@"11"]) {
                [self.DocumentViewController setAutomaticallyAdjustsScrollViewInsets: NO];
            }
            
            [self.DocumentViewController setDocumentViewControllerDelegate: self];
            [self.DocumentViewController setDocumentViewEventDelegate: self];
            [self.DocumentViewController setAnnotEventDelegate: self];
            [self.DocumentViewController setEnableAnnotNotePopup:NO];
            [self.DocumentViewController setThumbnailbackground:[UIColor blackColor]];
            [self.DocumentViewController setPageIndicatorPoint:CGPointMake(0, 110)];
            [self.DocumentViewController setEnablePageIndicator:NO];
            [self.DocumentViewController setToolBarPageIndicatorButton:YES];
            [self.DocumentViewController setDragEraserSize:20];
            if([[[NSUserDefaults standardUserDefaults] valueForKey:@"documentPreview"] isEqualToString:@"use"])
                [self.DocumentViewController setEnableThumbnailMultiplePagePreview:YES];
            else
                [self.DocumentViewController setEnableThumbnailMultiplePagePreview:NO];
            [self.DocumentViewController setThumbnailViewCount: 2];
            [self.DocumentViewController setBackButtonIcon: [UIImage imageNamed: @"PlugPDF.bundle/footer_arrow_before@2x.png"]];
            [self.DocumentViewController setNextButtonIcon: [UIImage imageNamed: @"PlugPDF.bundle/footer_arrow_next@2x.png"]];
            
            
            UIDeviceOrientation deviceOrientation = [[UIDevice currentDevice] orientation];
            NSLog(@"%d", (int)deviceOrientation);
            if((int)deviceOrientation == 3 || (int)deviceOrientation == 4){
                [self.DocumentViewController setEnablePageFlipEffect:NO];
                [self.DocumentViewController setDisplayMode:PlugPDFDocumentDisplayModeHorizontal];
            } else {
                [self.DocumentViewController setDisplayMode:PlugPDFDocumentDisplayModeHorizontal];
                [self.DocumentViewController setEnablePageFlipEffect:YES];
            }
        }
        
        // 화면 회전 감지 노티 등록
        [self registerDeviceOrientationNotification];
        [self.DocumentViewController setEnableTopBar:NO];
        
        [self.DocumentViewController setNavigationBarImage:[[NSBundle mainBundle] pathForResource: @"viewer-icon/bottom-bar70" ofType: @"png"]];
        [self.DocumentViewController.navigationController.toolbar setBackgroundColor:[UIColor colorWithRed:0.09 green:0.27 blue:0.48 alpha:0.70]];
        
        [self.AD.VCDic setObject:self.DocumentViewController forKey:self.pdfPath];
        index = (int)[self.AD.VCDic count]-1;
        NSLog(@"index = %d", index);
        beforeIndex = index;
        
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.1 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            CGSize documentSize = [self.DocumentViewController.documentView.document pageSize:0];
            CGFloat documentHeight = documentSize.height;
            CGFloat documentWidth = documentSize.width;
            CGFloat windowHeight = CGRectGetHeight(self.window.frame);
            CGFloat windowWidth = CGRectGetWidth(self.window.frame);
            
            if(documentWidth > documentHeight){
                [self.DocumentViewController setPagePreviewRect:CGRectMake(0.01, (windowHeight-documentHeight*(windowWidth/documentWidth))/2, windowWidth, documentHeight*(windowWidth/documentWidth))];
            } else {
                if(windowWidth < 700)
                    [self.DocumentViewController setPagePreviewRect:CGRectMake(0.01, (windowHeight-documentHeight*(windowWidth/documentWidth))/2, windowWidth, documentHeight*(windowWidth/documentWidth))];
                else
                    [self.DocumentViewController setPagePreviewRect:CGRectMake((windowWidth-(documentWidth*(windowHeight/documentHeight)))/2, 0.01, documentWidth*(windowHeight/documentHeight), windowHeight)];
            }
            
            [self.DocumentViewController setEnableTopBar:NO];
            [self.DocumentViewController setNavigationToolBarHidden:NO];
            [self.DocumentViewController setEnableAlwaysVisible:YES];
            [self.DocumentViewController setEnableAnnotNotePopup:NO];
            [self.DocumentViewController setPageIndicatorPoint:CGPointMake(0, 110)];
            [self.DocumentViewController.documentView addGestureRecognizer:self.longPress];
        });
        
        if ([[[NSUserDefaults standardUserDefaults] objectForKey:@"filelength"] isEqualToString:@"end"])
        {
            dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.2 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                [self.hideButton sendActionsForControlEvents:UIControlEventTouchUpInside];
            });
        }
        
    } else {
        
    }
    
    if(!self.DocumentViewController.modifyContentPermission || !self.DocumentViewController.modifyAnnotPermission){
        UIAlertController * alert=   [UIAlertController
                                      alertControllerWithTitle:@"해당 파일은 읽기 전용 상태로\n판서를 할 수 없습니다."
                                      message:@""
                                      preferredStyle:UIAlertControllerStyleAlert];
        
        UIAlertAction* ok = [UIAlertAction
                             actionWithTitle:@"OK"
                             style:UIAlertActionStyleDefault
                             handler:^(UIAlertAction * action)
                             {
                                 [alert dismissViewControllerAnimated:YES completion:nil];
                             }];
        
        [alert addAction:ok];
        
        [self.DocumentViewController presentViewController:alert animated:YES completion:nil];
    }
}

- (void) pageSliderValueChanged:(PlugPDFDocumentViewController*)viewController
{
    NSString* pageIdx = [NSString stringWithFormat:@"%d", (int)self.DocumentViewController.sliderPageIdx+1];
    pageIdx = [pageIdx stringByAppendingString:@" / "];
    pageIdx = [pageIdx stringByAppendingString:[NSString stringWithFormat:@"%d", (int)self.DocumentViewController.pageCount]];
    self.pageIndicator.text = pageIdx;
}

-(void)callNote{
    //    if (self.DocumentViewController && [self.DocumentViewController respondsToSelector:@selector(showNoteAnnotEditView: annot:)]){
    //        //        if ([self.DocumentViewController showNoteAnnotEditView: self cannot: annot]) return;
    //    }
}

-(void) initNavigationBar{
    self.navbar = [[UINavigationBar alloc]initWithFrame:CGRectMake(0, 40, CGRectGetWidth(self.window.frame), 41)];
    self.navItem = [[UINavigationItem alloc] init];
    
    self.navbar.translucent = NO;
    [self.navbar setTintColor:[UIColor whiteColor]];
    [self.navbar setBarTintColor:[UIColor colorWithRed:0.09 green:0.27 blue:0.48 alpha:0.70]];
    
    //    self.navItem.title = self.title;
    [self.navbar setTitleTextAttributes:@{NSForegroundColorAttributeName : [UIColor whiteColor]}];
    [self.navbar setBackgroundImage:[UIImage imageNamed:@"viewer-icon/bottom-bar70"] forBarMetrics:UIBarMetricsDefault];
    self.navbar.shadowImage = [UIImage new];
    self.navbar.translucent = YES;
    self.AD.navigationController.view.backgroundColor = [UIColor clearColor];
    
    
    //    UIImage *myImage = [UIImage imageNamed:@"viewer-icon/logo.png"];
    //    UIButton *myButton = [UIButton buttonWithType:UIButtonTypeCustom];
    //    [myButton setImage:myImage forState:UIControlStateNormal];
    //    myButton.frame = CGRectMake(0.0, 3.0, 130,30);
    //    [myButton addTarget:self action:@selector(openPlugPDF:) forControlEvents:UIControlEventTouchUpInside];
    //    myButton.tag = 15;
    //    UIBarButtonItem *backBtn = [[UIBarButtonItem alloc] initWithCustomView:myButton];
    self.backBtn = [[UIBarButtonItem alloc] init];
    self.backBtn.title = self.title;
    
    
    //    self.handImage = [UIImage imageNamed:@"viewer-icon/hand-on.png"];
    //    self.handButton = [UIButton buttonWithType:UIButtonTypeCustom];
    //    [self.handButton setImage:self.handImage forState:UIControlStateNormal];
    //    self.handButton.frame = CGRectMake(0.0, 7.0, 30,30);
    //    [self.handButton addTarget:self action:@selector(openPlugPDF:) forControlEvents:UIControlEventTouchUpInside];
    //    self.handButton.tag = 29;
    //    UIBarButtonItem *hand = [[UIBarButtonItem alloc] initWithCustomView:self.handButton];
    
    
    
    
    
    
    //    UIImage *saveImage = [UIImage imageNamed:@"viewer-icon/top-icon-01.png"];
    //    UIButton *saveButton = [UIButton buttonWithType:UIButtonTypeCustom];
    //    [saveButton setImage:saveImage forState:UIControlStateNormal];
    //    saveButton.frame = CGRectMake(0, 50, 30, 30);
    //    [saveButton addTarget:self action:@selector(openPlugPDF:) forControlEvents:UIControlEventTouchUpInside];
    //    saveButton.tag = 16;
    //    UIBarButtonItem *save = [[UIBarButtonItem alloc] initWithCustomView:saveButton];
    //    save.customView.frame = CGRectMake(0, 0, 30, 30);
    
    UIImage *displayRotateImage = [UIImage imageNamed:@"viewer-icon/top-icon-02-01.png"];
    self.displayRotateButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [self.displayRotateButton setImage:displayRotateImage forState:UIControlStateNormal];
    self.displayRotateButton.frame = CGRectMake(0.0, 7.0, 30,30);
    [self.displayRotateButton addTarget:self action:@selector(openPlugPDF:) forControlEvents:UIControlEventTouchUpInside];
    self.displayRotateButton.tag = 17;
    UIBarButtonItem *displayRotate = [[UIBarButtonItem alloc] initWithCustomView:self.displayRotateButton];
    
    //    UIImage *displayModeImage = [UIImage imageNamed:@"viewer-icon/top-icon-03-01.png"];
    //    self.displayModeButton = [UIButton buttonWithType:UIButtonTypeCustom];
    //    [self.displayModeButton setImage:displayModeImage forState:UIControlStateNormal];
    //    self.displayModeButton.frame = CGRectMake(0.0, 7.0, 30,30);
    //    [self.displayModeButton addTarget:self action:@selector(openPlugPDF:) forControlEvents:UIControlEventTouchUpInside];
    //    self.displayModeButton.tag = 18;
    //    UIBarButtonItem *displayMode = [[UIBarButtonItem alloc] initWithCustomView:self.displayModeButton];
    
    //    UIImage *bookMarkImage = [UIImage imageNamed:@"viewer-icon/top-icon-04.png"];
    //    self.bookMarkButton = [UIButton buttonWithType:UIButtonTypeCustom];
    //    [self.bookMarkButton setImage:bookMarkImage forState:UIControlStateNormal];
    //    self.bookMarkButton.frame = CGRectMake(0.0, 7.0, 30,30);
    //    [self.bookMarkButton addTarget:self action:@selector(openPlugPDF:) forControlEvents:UIControlEventTouchUpInside];
    //    self.bookMarkButton.tag = 19;
    //    UIBarButtonItem *bookMark = [[UIBarButtonItem alloc] initWithCustomView:self.bookMarkButton];
    
    //    UIImage *searchImage = [UIImage imageNamed:@"viewer-icon/top-icon-05.png"];
    //    UIButton *searchButton = [UIButton buttonWithType:UIButtonTypeCustom];
    //    [searchButton setImage:searchImage forState:UIControlStateNormal];
    //    searchButton.frame = CGRectMake(0.0, 7.0, 30,30);
    //    [searchButton addTarget:self action:@selector(openPlugPDF:) forControlEvents:UIControlEventTouchUpInside];
    //    searchButton.tag = 20;
    //    UIBarButtonItem *search = [[UIBarButtonItem alloc] initWithCustomView:searchButton];
    
    //    UIImage* eraserImage = [UIImage imageNamed:@"viewer-icon/pan-icon-08.png"];
    //    self.eraserBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    //    [self.eraserBtn setImage:eraserImage forState:UIControlStateNormal];
    //    self.eraserBtn.frame = CGRectMake(0.0, 7.0, 30,30);
    //    [self.eraserBtn addTarget:self action:@selector(openPlugPDF3:) forControlEvents:UIControlEventTouchUpInside];
    //    self.eraserBtn.tag = 11;
    //    self.eraser = [[UIBarButtonItem alloc] initWithCustomView:self.eraserBtn];
    
    //    UIImage* penImage = [UIImage imageNamed:@"viewer-icon/pan-icon-01.png"];
    //    self.inkBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    //    [self.inkBtn setImage:penImage forState:UIControlStateNormal];
    //    self.inkBtn.frame = CGRectMake(0.0, 7.0, 30,30);
    //    [self.inkBtn addTarget:self action:@selector(openPlugPDF3:) forControlEvents:UIControlEventTouchUpInside];
    //    self.inkBtn.tag = 4;
    //    self.pen = [[UIBarButtonItem alloc] initWithCustomView:self.inkBtn];
    
    //    UIImage *inkImage = nil;
    //    if(inkMode == 1) inkImage = [UIImage imageNamed:@"viewer-icon/pan-icon-04.png"];
    //    else if(inkMode == 2) inkImage = [UIImage imageNamed:@"viewer-icon/pan-icon-05.png"];
    //    else if(inkMode == 3) inkImage = [UIImage imageNamed:@"viewer-icon/pan-icon-06.png"];
    //    else if(inkMode == 4) inkImage = [UIImage imageNamed:@"viewer-icon/pan-icon-02.png"];
    //    else if(inkMode == 5) inkImage = [UIImage imageNamed:@"viewer-icon/pan-icon-03.png"];
    //    self.inkButton = [UIButton buttonWithType:UIButtonTypeCustom];
    //    [self.inkButton setImage:inkImage forState:UIControlStateNormal];
    //    self.inkButton.frame = CGRectMake(0.0, 7.0, 30,30);
    //    [self.inkButton addTarget:self action:@selector(openPlugPDF:) forControlEvents:UIControlEventTouchUpInside];
    //    self.inkButton.tag = 21;
    //    self.ink = [[UIBarButtonItem alloc] initWithCustomView:self.inkButton];
    //
    //    UIImage *hideImage = [UIImage imageNamed:@"viewer-icon/tap-up.png"];
    //    self.hideButton = [UIButton buttonWithType:UIButtonTypeCustom];
    //    [self.hideButton setImage:hideImage forState:UIControlStateNormal];
    //    self.hideButton.frame = CGRectMake(0.0, 7.0, 20,20);
    //    [self.hideButton addTarget:self action:@selector(hideBar:) forControlEvents:UIControlEventTouchUpInside];
    //    self.hide = [[UIBarButtonItem alloc] initWithCustomView:self.hideButton];
    
    
    self.hideView = [[UIView alloc] initWithFrame:CGRectMake(self.navbar.frame.size.width-40, 0, 40, 40)];
    UITapGestureRecognizer* hideGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(hideBar:)];
    [self.hideView addGestureRecognizer:hideGesture];
    self.hideButton = [[UIButton alloc] initWithFrame: CGRectMake(0, 12.5, 20, 20)];
    [self.hideButton setImage:[UIImage imageNamed:@"viewer-icon/tap-up.png"] forState:UIControlStateNormal];
    [self.hideButton addTarget: self action: @selector(hideBar:) forControlEvents: UIControlEventTouchUpInside];
    [self.hideView addSubview:self.hideButton];
    
    
    self.handView = [[UIView alloc] initWithFrame:CGRectMake(self.navbar.frame.size.width-82.5, 0, 40, 40)];
    UITapGestureRecognizer* handGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(onHand)];
    [self.handView addGestureRecognizer:handGesture];
    self.handButton = [[UIButton alloc] initWithFrame: CGRectMake(0, 7.5, 30, 30)];
    [self.handButton setImage:[UIImage imageNamed:@"viewer-icon/hand-on.png"] forState:UIControlStateNormal];
    [self.handButton addTarget: self action: @selector(onHand) forControlEvents: UIControlEventTouchUpInside];
    self.handButton.tag = 29;
    [self.handView addSubview:self.handButton];
    
    
    UIImage *inkImage = nil;
    if(inkMode == 1) inkImage = [UIImage imageNamed:@"viewer-icon/pan-icon-04.png"];
    else if(inkMode == 2) inkImage = [UIImage imageNamed:@"viewer-icon/pan-icon-05.png"];
    else if(inkMode == 3) inkImage = [UIImage imageNamed:@"viewer-icon/pan-icon-06.png"];
    else if(inkMode == 4) inkImage = [UIImage imageNamed:@"viewer-icon/pan-icon-02.png"];
    else if(inkMode == 5) inkImage = [UIImage imageNamed:@"viewer-icon/pan-icon-03.png"];
    self.inkView = [[UIView alloc] initWithFrame:CGRectMake(self.navbar.frame.size.width-120, 0, 40, 40)];
    UITapGestureRecognizer* inkGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(onAnnot)];
    [self.inkView addGestureRecognizer:inkGesture];
    self.inkButton = [[UIButton alloc] initWithFrame: CGRectMake(0, 7.5, 30, 30)];
    [self.inkButton setImage:inkImage forState:UIControlStateNormal];
    [self.inkButton addTarget: self action: @selector(onAnnot) forControlEvents: UIControlEventTouchUpInside];
    self.inkButton.tag = 21;
    [self.inkView addSubview:self.inkButton];
    
    
    UIImage* eraserImage = [UIImage imageNamed:@"viewer-icon/pan-icon-08.png"];
    self.eraserView = [[UIView alloc] initWithFrame:CGRectMake(self.navbar.frame.size.width-160, 0, 40, 40)];
    UITapGestureRecognizer* eraserGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(onEraser)];
    [self.eraserView addGestureRecognizer:eraserGesture];
    self.eraserBtn = [[UIButton alloc] initWithFrame: CGRectMake(0, 7.5, 30, 30)];
    [self.eraserBtn setImage:eraserImage forState:UIControlStateNormal];
    [self.eraserBtn addTarget: self action: @selector(onEraser) forControlEvents: UIControlEventTouchUpInside];
    self.eraserBtn.tag = 11;
    [self.eraserView addSubview:self.eraserBtn];
    
    
    UIImage* penImage = [UIImage imageNamed:@"viewer-icon/pan-icon-01.png"];
    self.penView = [[UIView alloc] initWithFrame:CGRectMake(self.navbar.frame.size.width-200, 0, 40, 40)];
    UITapGestureRecognizer* penGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(onPen)];
    [self.penView addGestureRecognizer:penGesture];
    self.inkBtn = [[UIButton alloc] initWithFrame: CGRectMake(0, 7.5, 30, 30)];
    [self.inkBtn setImage:penImage forState:UIControlStateNormal];
    [self.inkBtn addTarget: self action: @selector(onPen) forControlEvents: UIControlEventTouchUpInside];
    self.inkBtn.tag = 4;
    [self.penView addSubview:self.inkBtn];
    
    
    UIImage *searchImage = [UIImage imageNamed:@"viewer-icon/top-icon-05.png"];
    self.searchView = [[UIView alloc] initWithFrame:CGRectMake(self.navbar.frame.size.width-240, 0, 40, 40)];
    UITapGestureRecognizer* searchGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(onSearch)];
    [self.searchView addGestureRecognizer:searchGesture];
    UIButton *searchButton = [[UIButton alloc] initWithFrame: CGRectMake(0, 7.5, 30, 30)];
    [searchButton setImage:searchImage forState:UIControlStateNormal];
    [searchButton addTarget: self action: @selector(onSearch) forControlEvents: UIControlEventTouchUpInside];
    searchButton.tag = 20;
    [self.searchView addSubview:searchButton];
    
    
    UIImage *bookMarkImage = [UIImage imageNamed:@"viewer-icon/top-icon-04.png"];
    self.bookMarkView = [[UIView alloc] initWithFrame:CGRectMake(self.navbar.frame.size.width-280, 0, 40, 40)];
    UITapGestureRecognizer* bookMarkGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(onBookmark)];
    [self.bookMarkView addGestureRecognizer:bookMarkGesture];
    self.bookMarkButton = [[UIButton alloc] initWithFrame: CGRectMake(0, 7.5, 30, 30)];
    [self.bookMarkButton setImage:bookMarkImage forState:UIControlStateNormal];
    [self.bookMarkButton addTarget: self action: @selector(onBookmark) forControlEvents: UIControlEventTouchUpInside];
    self.bookMarkButton.tag = 19;
    [self.bookMarkView addSubview:self.bookMarkButton];
    
    
    UIImage *displayModeImage = [UIImage imageNamed:@"viewer-icon/top-icon-03-01.png"];
    self.displayModeView = [[UIView alloc] initWithFrame:CGRectMake(self.navbar.frame.size.width-320, 0, 40, 40)];
    UITapGestureRecognizer* displayModeGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(onDisplayMode)];
    [self.displayModeView addGestureRecognizer:displayModeGesture];
    self.displayModeButton = [[UIButton alloc] initWithFrame: CGRectMake(0, 7.5, 30, 30)];
    [self.displayModeButton setImage:displayModeImage forState:UIControlStateNormal];
    [self.displayModeButton addTarget: self action: @selector(onDisplayMode) forControlEvents: UIControlEventTouchUpInside];
    self.displayModeButton.tag = 18;
    [self.displayModeView addSubview:self.displayModeButton];
    
    
    UIImage *saveImage = [UIImage imageNamed:@"viewer-icon/top-icon-01.png"];
    self.saveView = [[UIView alloc] initWithFrame:CGRectMake(self.navbar.frame.size.width-360, 0, 40, 40)];
    UITapGestureRecognizer* saveGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(fileSave)];
    [self.saveView addGestureRecognizer:saveGesture];
    UIButton *saveButton = [[UIButton alloc] initWithFrame: CGRectMake(0, 7.5, 30, 30)];
    [saveButton setImage:saveImage forState:UIControlStateNormal];
    [saveButton addTarget: self action: @selector(fileSave) forControlEvents: UIControlEventTouchUpInside];
    saveButton.tag = 16;
    [self.saveView addSubview:saveButton];
    
    
    if(self.DocumentViewController.modifyContentPermission || self.DocumentViewController.modifyAnnotPermission){
        [self.navbar addSubview:self.hideView];
        [self.navbar addSubview:self.handView];
        [self.navbar addSubview:self.inkView];
        [self.navbar addSubview:self.eraserView];
        [self.navbar addSubview:self.penView];
        [self.navbar addSubview:self.searchView];
        [self.navbar addSubview:self.bookMarkView];
        [self.navbar addSubview:self.displayModeView];
        [self.navbar addSubview:self.saveView];
    } else {
        [self.navbar addSubview:self.hideView];
        [self.navbar addSubview:self.handView];
        [self.navbar addSubview:self.searchView];
        [self.navbar addSubview:self.displayModeView];
        
        [self.handButton sendActionsForControlEvents:UIControlEventTouchUpInside];
    }
    
    
    UIView *blankView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 10, 1)];
    UIBarButtonItem* blank = [[UIBarButtonItem alloc] initWithCustomView:blankView];
    
    //    self.navItem.leftBarButtonItems = [NSArray arrayWithObjects:self.backBtn,nil];
    //    self.navItem.rightBarButtonItems = [NSArray arrayWithObjects:self.hide, blank, hand, self.ink, self.eraser, self.pen, search, bookMark, displayMode, save, nil];
    
    [self.navbar setItems:@[self.navItem]];
    
    //do something like background color, title, etc you self
    [self.AD.navigationController.view addSubview:self.navbar];
}

-(void)initMovePageButton{
    CGFloat windowWidth = CGRectGetWidth(self.window.frame);
    if(windowWidth > 400){
        self.pageMoveView = [[UIView alloc] initWithFrame:CGRectMake(CGRectGetWidth(self.window.frame) - 203, CGRectGetHeight(self.window.frame) - 42, 186, 40)];
    } else {
        self.pageMoveView = [[UIView alloc] initWithFrame:CGRectMake(CGRectGetWidth(self.window.frame) - 203, CGRectGetHeight(self.window.frame) - 42, 186, 40)];
    }
    self.pageMoveView.layer.cornerRadius = 20;
    [self.pageMoveView setBackgroundColor:[UIColor colorWithRed:0.09 green:0.24 blue:0.44 alpha:0.50]];
    
    self.beforePageView = [[UIView alloc] initWithFrame:CGRectMake(3, 0, 40, 40)];
    self.beforePageView.layer.cornerRadius = 20;
    UITapGestureRecognizer *goBeforePage = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(goBeforePage:)];
    [self.beforePageView addGestureRecognizer:goBeforePage];
    
    self.beforePage = [[UIButton alloc] initWithFrame: CGRectMake(2, 6, 16, 28)];
    [self.beforePage setImage:[UIImage imageNamed:@"viewer-icon/footer-arrow-before.png"] forState:UIControlStateNormal];
    [self.beforePage addTarget: self action: @selector(goBeforePage:) forControlEvents: UIControlEventTouchUpInside];
    self.beforePage.tag = 12;
    [self.beforePageView addSubview:self.beforePage];
    
    self.nextPageView = [[UIView alloc] initWithFrame:CGRectMake(143, 0, 40, 40)];
    self.nextPageView.layer.cornerRadius = 20;
    UITapGestureRecognizer *goNextPage = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(goNextPage:)];
    [self.nextPageView addGestureRecognizer:goNextPage];
    
    self.nextPage = [[UIButton alloc] initWithFrame: CGRectMake(14, 6, 16, 28)];
    [self.nextPage setImage:[UIImage imageNamed:@"viewer-icon/footer-arrow-next.png"] forState:UIControlStateNormal];
    [self.nextPage addTarget: self action: @selector(goNextPage:) forControlEvents: UIControlEventTouchUpInside];
    self.nextPage.tag = 13;
    [self.nextPageView addSubview:self.nextPage];
    
    self.pageIndicator = [[UILabel alloc] initWithFrame:CGRectMake(43, 0, 100, 40)];
    self.pageIndicator.textAlignment=UITextAlignmentCenter;
    NSString* pageIdx = [NSString stringWithFormat:@"%d", (int)self.DocumentViewController.pageIdx+1];
    pageIdx = [pageIdx stringByAppendingString:@" / "];
    pageIdx = [pageIdx stringByAppendingString:[NSString stringWithFormat:@"%d", (int)self.DocumentViewController.pageCount]];
    self.pageIndicator.text = pageIdx;
    self.pageIndicator.textColor = [UIColor whiteColor];
    
    [self.pageMoveView addSubview:self.pageIndicator];
    [self.pageMoveView addSubview:self.beforePageView];
    [self.pageMoveView addSubview:self.nextPageView];
    [self.AD.navigationController.view addSubview:self.pageMoveView];
}

-(void) goNextPage:(id)sender{
    if(pagedidchange){
        if(isEbook){
            if(self.DocumentViewController.pageIdx+2 < self.DocumentViewController.pageCount){
                [self.DocumentViewController gotoPage:self.DocumentViewController.pageIdx+2 fitToScreen:YES];
            } else if (self.DocumentViewController.pageIdx+2 == self.DocumentViewController.pageCount){
                [self.DocumentViewController gotoPage:self.DocumentViewController.pageCount-1 fitToScreen:YES];
            }
        } else {
            if(self.DocumentViewController.pageIdx+1 < self.DocumentViewController.pageCount){
                [self.DocumentViewController gotoPage:self.DocumentViewController.pageIdx+1 fitToScreen:YES];
            }
        }
    }
}

-(void) goBeforePage:(id)sender{
    if(pagedidchange){
        if(isEbook){
            if(self.DocumentViewController.pageIdx-2 >= 0){
                [self.DocumentViewController gotoPage:self.DocumentViewController.pageIdx-2 fitToScreen:YES];
            } else if(self.DocumentViewController.pageIdx-2 == -1){
                [self.DocumentViewController gotoPage:self.DocumentViewController.pageIdx-1 fitToScreen:YES];
            }
        } else {
            if(self.DocumentViewController.pageIdx-1 >= 0){
                [self.DocumentViewController gotoPage:self.DocumentViewController.pageIdx-1 fitToScreen:YES];
            }
        }
    }
}

-(void) CloseTap:(id)sender{ // 닫기 취소
    penPopup = NO;
    inkPopup = NO;
    eraserPopup = NO;
    UIAlertController * alert =   [UIAlertController
                                   alertControllerWithTitle:@"저장하지 않은 내용은\n모두 삭제됩니다.\n현재 문서를 닫으시겠습니까?"
                                   message:@""
                                   preferredStyle:UIAlertControllerStyleAlert];
    
    UIAlertAction* ok = [UIAlertAction
                         actionWithTitle:@"저장 후 닫기"
                         style:UIAlertActionStyleDefault
                         handler:^(UIAlertAction * action)
                         {
                             if(isHidden) hiddenClose = YES;
                             
                             //                             NSURL *url = [NSURL URLWithString:[self.pdfPath stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding]];
                             //                             [self.DocumentViewController saveAsFile:url];
                             [self.DocumentViewController saveAsFile:[[NSURL alloc] initFileURLWithPath: self.pdfPath]];
                             //                                 [self.DocumentViewController saveFile:YES];
                             
                             NSDate *nsDate = [NSDate date];
                             NSCalendar *nsCalendar = [NSCalendar currentCalendar];
                             unsigned int unitFlags = NSCalendarUnitYear | NSCalendarUnitMonth | NSCalendarUnitDay | NSCalendarUnitHour | NSCalendarUnitMinute | NSCalendarUnitSecond;
                             NSDateComponents *nsDateComponents = [nsCalendar components:unitFlags fromDate:nsDate];
                             
                             NSString *currentTime = @"";
                             NSString *month = @"";
                             NSString *day = @"";
                             NSString *hour = @"";
                             NSString *minute = @"";
                             NSString *second = @"";
                             if([nsDateComponents month] < 10) {
                                 month = @"0";
                                 month = [month stringByAppendingString:[@((long)[nsDateComponents month]) stringValue]];
                             } else {
                                 month = [month stringByAppendingString:[@((long)[nsDateComponents month]) stringValue]];
                             }
                             if([nsDateComponents day] < 10) {
                                 day = @"0";
                                 day = [day stringByAppendingString:[@((long)[nsDateComponents day]) stringValue]];
                             } else {
                                 day = [day stringByAppendingString:[@((long)[nsDateComponents day]) stringValue]];
                             }
                             if([nsDateComponents hour] < 10) {
                                 hour = @"0";
                                 hour = [hour stringByAppendingString:[@((long)[nsDateComponents hour]) stringValue]];
                             } else {
                                 hour = [hour stringByAppendingString:[@((long)[nsDateComponents hour]) stringValue]];
                             }
                             if([nsDateComponents minute] < 10) {
                                 minute = @"0";
                                 minute = [minute stringByAppendingString:[@((long)[nsDateComponents minute]) stringValue]];
                             } else {
                                 minute = [minute stringByAppendingString:[@((long)[nsDateComponents minute]) stringValue]];
                             }
                             if([nsDateComponents second] < 10) {
                                 second = @"0";
                                 second = [second stringByAppendingString:[@((long)[nsDateComponents second]) stringValue]];
                             } else {
                                 second = [second stringByAppendingString:[@((long)[nsDateComponents second]) stringValue]];
                             }
                             currentTime = [currentTime stringByAppendingString:[@((long)[nsDateComponents year]) stringValue]];
                             currentTime = [currentTime stringByAppendingString:month];
                             currentTime = [currentTime stringByAppendingString:day];
                             currentTime = [currentTime stringByAppendingString:hour];
                             currentTime = [currentTime stringByAppendingString:minute];
                             currentTime = [currentTime stringByAppendingString:second];
                             
                             NSString* uploadFilePath = self.pdfPath;
                             NSString* appendTime = currentTime;
                             appendTime = [appendTime stringByAppendingString:@"_"];
                             appendTime = [appendTime stringByAppendingString:self.title];
                             
                             uploadFilePath = [uploadFilePath stringByReplacingOccurrencesOfString:self.title withString:appendTime];
                             
                             [[NSFileManager defaultManager] moveItemAtPath:self.pdfPath toPath:uploadFilePath error:nil];
                             NSLog(@"uploadFilePath = %@", uploadFilePath);
                             [[NSUserDefaults standardUserDefaults] setValue:uploadFilePath forKey:@"pdfPath"];
                             NSNotificationCenter *notificationCenter = [NSNotificationCenter defaultCenter];
                             NSDictionary *dic = [NSDictionary dictionaryWithObject:@"test2" forKey:@"secondKey"];
                             [notificationCenter postNotificationName:@"secondNotification" object:self userInfo:dic];
                             
                             
                             
                             [[UIApplication sharedApplication] setStatusBarHidden:NO animated:NO];
                             [alert dismissViewControllerAnimated:YES completion:nil];
                             
                             [self.penPopoverController dismissPopoverAnimated:NO];
                             [self.inkPopoverController dismissPopoverAnimated:NO];
                             [self.eraserPopoverController dismissPopoverAnimated:NO];
                             [self.BMpopoverController dismissPopoverAnimated:NO];
                             [self.displayPopoverController dismissPopoverAnimated:NO];
                             
                             NSLog(@"CloseTap");
                             beforeIndex = index;
                             self.AD.pdfCount = self.AD.pdfCount - 1;
                             
                             int i = 0;
                             for (id key in self.AD.VCDic) {
                                 if(i == index) {
                                     [self.AD.VCDic removeObjectForKey:key];
                                 }
                                 i = i + 1;
                             }
                             for (id key in self.AD.tmpVCDic) {
                                 if(i == index) {
                                     [self.AD.VCDic removeObjectForKey:key];
                                 }
                                 i = i + 1;
                             }
                             
                             NSLog(@"%@     ,     %d", self.AD.checkFile, index);
                             [self.AD.checkFile removeObjectAtIndex:index];
                             NSLog(@"%@", self.AD.checkFile);
                             
                             if(self.AD.VCDic.count == 0){
                                 openViewer = NO;
                                 [[UIApplication sharedApplication] setStatusBarHidden:NO animated:NO];
                                 
                                 [self releaseAnnotBtn];
                                 [self releaseAnnots];
                                 [self releaseSubViews];
                                 [self.DocumentViewController releaseTools];
                                 
                                 AppDelegate *AD = [[UIApplication sharedApplication] delegate];
                                 [AD.navigationController popToViewController:AD.viewController animated:NO];
                                 AD.navigationController.toolbarHidden = YES;
                                 AD.navigationController.navigationBarHidden = YES;
                                 
                                 dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.01 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                                     AD.viewController.view.frame =  CGRectMake(0, -20, AD.viewController.view.window.frame.size.width, AD.viewController.view.window.frame.size.height+20);
                                 });
                                 
                                 [self.tapBar removeFromSuperview];
                                 [self.navbar removeFromSuperview];
                                 [self.pageMoveView removeFromSuperview];
                                 [self.searchNavbar removeFromSuperview];
                                 
                                 [self.DocumentViewController dismissViewControllerAnimated:YES completion:nil];
                             } else {
                                 if(index-1 == -1) index = 0;
                                 else index = index - 1;
                                 
                                 [self.tapBar removeFromSuperview];
                                 //        click = 0;
                                 [self initCollectionView];
                                 //        [self initNavigationBar];
                                 
                                 int i = 0;
                                 for (id key in self.AD.VCDic) {
                                     if(i == index) {
                                         self.title = [[key lastPathComponent] stringByDeletingPathExtension];
                                         //                                         self.navbar.topItem.title = self.title;
                                         self.backBtn.title = self.title;
                                         self.pdfPath = key;
                                         //                    NSURL *url = [NSURL URLWithString:[self.pdfPath stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding]];
                                         //                    [self.DocumentViewController saveAsFile:url];
                                         //                [self.DocumentViewController saveFile:YES];
                                         self.DocumentViewController = nil;
                                         //                self.DocumentViewController = [PlugPDFDocumentViewController initWithPath:key password:@"" title:@""];
                                         self.DocumentViewController = [self.AD.VCDic objectForKey:key];
                                         int i = 0;
                                         @try{
                                             [self.AD.navigationController pushViewController:self.DocumentViewController animated:NO];
                                             i = 1;
                                         }@catch (NSException * e) {
                                             [self.AD.navigationController popToViewController:self.DocumentViewController animated:NO];
                                         }@finally {
                                             dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.2 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                                                 //                            [self.DocumentViewController refreshView];
                                                 CGSize documentSize = [self.DocumentViewController.documentView.document pageSize:0];
                                                 CGFloat documentHeight = documentSize.height;
                                                 CGFloat documentWidth = documentSize.width;
                                                 CGFloat windowHeight = CGRectGetHeight(self.window.frame);
                                                 CGFloat windowWidth = CGRectGetWidth(self.window.frame);
                                                 
                                                 if(documentWidth > documentHeight){
                                                     [self.DocumentViewController setPagePreviewRect:CGRectMake(0.01, (windowHeight-documentHeight*(windowWidth/documentWidth))/2, windowWidth, documentHeight*(windowWidth/documentWidth))];
                                                 } else {
                                                     if(windowWidth < 700)
                                                         [self.DocumentViewController setPagePreviewRect:CGRectMake(0.01, (windowHeight-documentHeight*(windowWidth/documentWidth))/2, windowWidth, documentHeight*(windowWidth/documentWidth))];
                                                     else
                                                         [self.DocumentViewController setPagePreviewRect:CGRectMake((windowWidth-(documentWidth*(windowHeight/documentHeight)))/2, 0.01, documentWidth*(windowHeight/documentHeight), windowHeight)];
                                                 }
                                                 if(UsingInk == YES){ [self.DocumentViewController setTool:PlugPDFInkTool]; }
                                                 else if(UsingSquare == YES){
                                                     [self.DocumentViewController setTool:PlugPDFSquareTool];
                                                     [self.DocumentViewController setShapeWidth:squareBoldValue];
                                                     [self.DocumentViewController setSquareAnnotColor:self.exampleSquareColor];
                                                     [self.DocumentViewController setShapeColor:self.exampleSquareCornerColor];
                                                     [self.DocumentViewController setSquareAnnotOpacity:1.0];
                                                     if([[UIColor clearColor] isEqual:self.exampleSquareColor]){
                                                         [self.DocumentViewController setSquareAnnotTransparent:YES];
                                                     } else {
                                                         [self.DocumentViewController setSquareAnnotTransparent:NO];
                                                     }
                                                 } else if(UsingCircle == YES){
                                                     [self.DocumentViewController setTool:PlugPDFCircleTool];
                                                     [self.DocumentViewController setShapeWidth:circleBoldValue];
                                                     [self.DocumentViewController setCircleAnnotColor:self.exampleCircleColor];
                                                     [self.DocumentViewController setShapeColor:self.exampleCircleCornerColor];
                                                     [self.DocumentViewController setCircleAnnotOpacity:1.0];
                                                     if([[UIColor clearColor] isEqual:self.exampleCircleColor]){
                                                         [self.DocumentViewController setCircleAnnotTransparent:YES];
                                                     } else {
                                                         [self.DocumentViewController setCircleAnnotTransparent:NO];
                                                     }
                                                 } else if(UsingHighlight == YES){ [self.DocumentViewController setTool:PlugPDFTextHighlightTool]; }
                                                 else if(UsingUnderline == YES){ [self.DocumentViewController setTool:PlugPDFTextUnderlineTool]; }
                                                 else if(UsingCancle == YES){ [self.DocumentViewController setTool:PlugPDFTextStrikeoutTool]; }
                                                 else if(UsingNote == YES){ [self.DocumentViewController setTool:PlugPDFNoteTool]; }
                                                 else if(UsingEraser == YES){ [self.DocumentViewController setTool:PlugPDFEraserTool]; }
                                                 [self.DocumentViewController setEnableTopBar:NO];
                                                 [self.DocumentViewController setEnableAnnotNotePopup:NO];
                                                 [self.DocumentViewController setPageIndicatorPoint:CGPointMake(0, 110)];
                                             });
                                         }
                                         
                                     }
                                     i = i + 1;
                                 }
                             }
                             
                             [self.DocumentViewController.documentView removeGestureRecognizer:self.pan];
                             [self.AD.navigationController.view makeToast:@"저장되었습니다." duration:1.0 position:[NSValue valueWithCGPoint:CGPointMake(self.viewController.view.frame.size.width/2, self.viewController.view.frame.size.height-150)]];
                         }];
    
    
    
    
    
    UIAlertAction* cancel = [UIAlertAction
                             actionWithTitle:@"닫기"
                             style:UIAlertActionStyleDefault
                             handler:^(UIAlertAction * action)
                             {
                                 if(isHidden) hiddenClose = YES;
                                 
                                 [alert dismissViewControllerAnimated:YES completion:nil];
                                 
                                 [self.penPopoverController dismissPopoverAnimated:NO];
                                 [self.inkPopoverController dismissPopoverAnimated:NO];
                                 [self.eraserPopoverController dismissPopoverAnimated:NO];
                                 [self.BMpopoverController dismissPopoverAnimated:NO];
                                 [self.displayPopoverController dismissPopoverAnimated:NO];
                                 
                                 NSLog(@"CloseTap");
                                 beforeIndex = index;
                                 self.AD.pdfCount = self.AD.pdfCount - 1;
                                 
                                 NSString* removeFilePath = @"";
                                 
                                 int i = 0;
                                 for (id key in self.AD.VCDic) {
                                     if(i == index) {
                                         [self.AD.VCDic removeObjectForKey:key];
                                         removeFilePath = key;
                                     }
                                     i = i + 1;
                                 }
                                 for (id key in self.AD.tmpVCDic) {
                                     if(i == index) {
                                         [self.AD.VCDic removeObjectForKey:key];
                                     }
                                     i = i + 1;
                                 }
                                 
                                 NSLog(@"%@     ,     %d", self.AD.checkFile, index);
                                 [self.AD.checkFile removeObjectAtIndex:index];
                                 NSLog(@"%@", self.AD.checkFile);
                                 
                                 if(self.AD.VCDic.count == 0){
                                     openViewer = NO;
                                     [[UIApplication sharedApplication] setStatusBarHidden:NO animated:NO];
                                     //        if(isAnnot){
                                     //            isAnnot = NO;
                                     [self releaseAnnotBtn];
                                     [self releaseAnnots];
                                     [self releaseSubViews];
                                     [self.DocumentViewController releaseTools];
                                     
                                     AppDelegate *AD = [[UIApplication sharedApplication] delegate];
                                     [AD.navigationController popToViewController:AD.viewController animated:NO];
                                     AD.navigationController.toolbarHidden = YES;
                                     AD.navigationController.navigationBarHidden = YES;
                                     
                                     dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.01 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                                         AD.viewController.view.frame =  CGRectMake(0, -20, AD.viewController.view.window.frame.size.width, AD.viewController.view.window.frame.size.height+20);
                                     });
                                     
                                     [self.tapBar removeFromSuperview];
                                     [self.navbar removeFromSuperview];
                                     [self.pageMoveView removeFromSuperview];
                                     [self.searchNavbar removeFromSuperview];
                                     
                                     [self.DocumentViewController dismissViewControllerAnimated:YES completion:nil];
                                     [[NSFileManager defaultManager] removeItemAtPath:removeFilePath error:nil];
                                 } else {
                                     if(index-1 == -1) index = 0;
                                     else index = index - 1;
                                     
                                     [self.tapBar removeFromSuperview];
                                     //        click = 0;
                                     [self initCollectionView];
                                     //        [self initNavigationBar];
                                     
                                     int i = 0;
                                     for (id key in self.AD.VCDic) {
                                         if(i == index) {
                                             self.title = [[key lastPathComponent] stringByDeletingPathExtension];
                                             //                                             self.navbar.topItem.title = self.title;
                                             self.backBtn.title = self.title;
                                             
                                             //                    NSURL *url = [NSURL URLWithString:[self.pdfPath stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding]];
                                             //                    [self.DocumentViewController saveAsFile:url];
                                             //                [self.DocumentViewController saveFile:YES];
                                             self.DocumentViewController = nil;
                                             //                self.DocumentViewController = [PlugPDFDocumentViewController initWithPath:key password:@"" title:@""];
                                             self.DocumentViewController = [self.AD.VCDic objectForKey:key];
                                             int i = 0;
                                             @try{
                                                 [self.AD.navigationController pushViewController:self.DocumentViewController animated:NO];
                                                 i = 1;
                                             }@catch (NSException * e) {
                                                 [self.AD.navigationController popToViewController:self.DocumentViewController animated:NO];
                                             }@finally {
                                                 //                                                 [self.DocumentViewController setEnablePageFlipEffect:NO];
                                                 //                                                 dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.2 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                                                 //                            [self.DocumentViewController refreshView];
                                                 //                                                     CGSize documentSize = [self.DocumentViewController.documentView.document pageSize:0];
                                                 //                                                     CGFloat documentHeight = documentSize.height;
                                                 //                                                     CGFloat documentWidth = documentSize.width;
                                                 //                                                     CGFloat windowHeight = CGRectGetHeight(self.window.frame);
                                                 //                                                     CGFloat windowWidth = CGRectGetWidth(self.window.frame);
                                                 //
                                                 
                                                 //                                                     if(UsingInk == YES){ [self.DocumentViewController setTool:PlugPDFInkTool]; }
                                                 //                                                     else if(UsingSquare == YES){ [self.DocumentViewController setTool:PlugPDFSquareTool]; }
                                                 //                                                     else if(UsingCircle == YES){ [self.DocumentViewController setTool:PlugPDFCircleTool]; }
                                                 //                                                     else if(UsingHighlight == YES){ [self.DocumentViewController setTool:PlugPDFTextHighlightTool]; }
                                                 //                                                     else if(UsingUnderline == YES){ [self.DocumentViewController setTool:PlugPDFTextUnderlineTool]; }
                                                 //                                                     else if(UsingCancle == YES){ [self.DocumentViewController setTool:PlugPDFTextStrikeoutTool]; }
                                                 //                                                     else if(UsingNote == YES){ [self.DocumentViewController setTool:PlugPDFNoteTool]; }
                                                 //                                                     else if(UsingEraser == YES){ [self.DocumentViewController setTool:PlugPDFEraserTool]; }
                                                 //                                                     [self.DocumentViewController setEnableTopBar:NO];
                                                 //                                                     [self.DocumentViewController setEnableAnnotNotePopup:NO];
                                                 //                                                     [self.DocumentViewController setPageIndicatorPoint:CGPointMake(0, 110)];
                                                 
                                                 click = 1;
                                                 //                                                 });
                                             }
                                         }
                                         i = i + 1;
                                     }
                                 }
                                 [self.DocumentViewController.documentView removeGestureRecognizer:self.pan];
                                 [[NSFileManager defaultManager] removeItemAtPath:removeFilePath error:nil];
                             }];
    
    UIAlertAction* cancel2 = [UIAlertAction
                              actionWithTitle:@"취소"
                              style:UIAlertActionStyleDefault
                              handler:^(UIAlertAction * action)
                              {
                                  [alert dismissViewControllerAnimated:YES completion:nil];
                              }];
    
    //    [alert addAction:ok];
    [alert addAction:cancel];
    [alert addAction:cancel2];
    
    [self.DocumentViewController presentViewController:alert animated:YES completion:nil];
}

- (void)BackgroundTap: (id)sender{
    openViewer = NO;
    [self.penPopoverController dismissPopoverAnimated:NO];
    [self.inkPopoverController dismissPopoverAnimated:NO];
    [self.eraserPopoverController dismissPopoverAnimated:NO];
    [self.BMpopoverController dismissPopoverAnimated:NO];
    [self.displayPopoverController dismissPopoverAnimated:NO];
    
    [[UIApplication sharedApplication] setStatusBarHidden:NO animated:NO];
    NSLog(@"BackgroundTap");
    //    if(isAnnot){
    //        isAnnot = NO;
    //        [self releaseAnnotBtn];
    //        [self releaseAnnots];
    //        [self releaseSubViews];
    //        [self.DocumentViewController releaseTools];
    //    } else {
    NSURL *url = [NSURL URLWithString:[self.pdfPath stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding]];
    //    [self.DocumentViewController saveAsFile:url];
    //    [self.DocumentViewController saveFile:YES];
    [self releaseAnnotBtn];
    [self releaseAnnots];
    [self releaseSubViews];
    [self.DocumentViewController releaseTools];
    
    //  [self dismissViewControllerAnimated:NO completion:nil];
    AppDelegate *AD = [[UIApplication sharedApplication] delegate];
    [AD.navigationController popToViewController:AD.viewController animated:NO];
    AD.navigationController.toolbarHidden = YES;
    AD.navigationController.navigationBarHidden = YES;
    
    [self.navbar removeFromSuperview];
    [self.tapBar removeFromSuperview];
    [self.pageMoveView removeFromSuperview];
    [self.searchNavbar removeFromSuperview];
    
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.01 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        AD.viewController.view.frame =  CGRectMake(0,-20,AD.viewController.view.window.frame.size.width,AD.viewController.view.window.frame.size.height+20);
    });
    //            [self.AD.VCDic setObject:self.DocumentViewController forKey:self.pdfPath];
    //    }
    
    [self.DocumentViewController.documentView removeGestureRecognizer:self.pan];
}

- (void)CloseAllTap: (id)sender{
    if(UsingNote){
        UsingNote = NO;
        activateNoteMode = NO;
        [self.handButton sendActionsForControlEvents:UIControlEventTouchUpInside];
    }
    
    [self.penPopoverController dismissPopoverAnimated:NO];
    [self.inkPopoverController dismissPopoverAnimated:NO];
    [self.eraserPopoverController dismissPopoverAnimated:NO];
    [self.BMpopoverController dismissPopoverAnimated:NO];
    [self.displayPopoverController dismissPopoverAnimated:NO];
    
    penPopup = NO;
    inkPopup = NO;
    eraserPopup = NO;
    
    // 닫기, 취소
    UIAlertController * alert=   [UIAlertController
                                  alertControllerWithTitle:@"저장하지 않은 내용은\n모두 삭제됩니다.\n모든 문서를 닫으시겠습니까?"
                                  message:@""
                                  preferredStyle:UIAlertControllerStyleAlert];
    
    UIAlertAction* ok = [UIAlertAction
                         actionWithTitle:@"닫기"
                         style:UIAlertActionStyleDefault
                         handler:^(UIAlertAction * action)
                         {
                             [self.penPopoverController dismissPopoverAnimated:NO];
                             [self.inkPopoverController dismissPopoverAnimated:NO];
                             [self.eraserPopoverController dismissPopoverAnimated:NO];
                             [self.BMpopoverController dismissPopoverAnimated:NO];
                             [self.displayPopoverController dismissPopoverAnimated:NO];
                             
                             self.AD.pdfCount = 0;
                             
                             openViewer = NO;
                             [[UIApplication sharedApplication] setStatusBarHidden:NO animated:NO];
                             [alert dismissViewControllerAnimated:YES completion:nil];
                             
                             //                             NSURL *url = [NSURL URLWithString:[self.pdfPath stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding]];
                             //                             [self.DocumentViewController saveAsFile:url];
                             //                             [self.DocumentViewController saveFile:YES];
                             [self releaseAnnotBtn];
                             [self releaseAnnots];
                             [self releaseSubViews];
                             [self.DocumentViewController releaseTools];
                             
                             //  [self dismissViewControllerAnimated:NO completion:nil];
                             AppDelegate *AD = [[UIApplication sharedApplication] delegate];
                             [AD.navigationController popToViewController:AD.viewController animated:NO];
                             AD.navigationController.toolbarHidden = YES;
                             AD.navigationController.navigationBarHidden = YES;
                             
                             [self.navbar removeFromSuperview];
                             [self.tapBar removeFromSuperview];
                             [self.pageMoveView removeFromSuperview];
                             [self.searchNavbar removeFromSuperview];
                             
                             dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.01 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                                 AD.viewController.view.frame =  CGRectMake(0,-20,AD.viewController.view.window.frame.size.width,AD.viewController.view.window.frame.size.height+20);
                             });
                             NSLog(@"CloseAllTap");
                             
                             [self.DocumentViewController dismissViewControllerAnimated:YES completion:nil];
                             
                             for(int i = 0; i < self.AD.VCDic.count; i++)
                             {
                                 for(id key in self.AD.VCDic)
                                 {
                                     [[NSFileManager defaultManager] removeItemAtPath:key error:nil];
                                 }
                             }
                             
                             [self.AD.VCDic removeAllObjects];
                             [self.AD.tmpVCDic removeAllObjects];
                             [self.AD.checkFile removeAllObjects];
                         }];
    UIAlertAction* cancel = [UIAlertAction
                             actionWithTitle:@"취소"
                             style:UIAlertActionStyleDefault
                             handler:^(UIAlertAction * action)
                             {
                                 [alert dismissViewControllerAnimated:YES completion:nil];
                             }];
    
    [alert addAction:ok];
    [alert addAction:cancel];
    
    [self.DocumentViewController presentViewController:alert animated:YES completion:nil];
    [self.DocumentViewController.documentView removeGestureRecognizer:self.pan];
}


// 셀 갯수
- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section
{
    return [self.AD.VCDic count];
}

// 셀 속성
- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    NSLog(@"셀 속성");
    UICollectionViewCell *cell=[collectionView dequeueReusableCellWithReuseIdentifier:@"cellIdentifier" forIndexPath:indexPath];
    
    for (UILabel *lbl in cell.contentView.subviews)
    {
        if ([lbl isKindOfClass:[UILabel class]])
        {
            [lbl removeFromSuperview];
        }
    }
    
    for (UIView *lbl in cell.contentView.subviews)
    {
        if ([lbl isKindOfClass:[UIView class]])
        {
            for (UIButton *bt in lbl.subviews)
            {
                if ([bt isKindOfClass:[UIButton class]])
                {
                    [bt removeFromSuperview];
                }
            }
        }
    }
    
    cell.backgroundColor = [UIColor colorWithRed:0.06 green:0.20 blue:0.39 alpha:0.50];
    cell.layer.borderColor = [UIColor blackColor].CGColor;
    cell.layer.borderWidth = 1;
    
    UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(10, 5, CGRectGetWidth(cell.frame)-40, 30)];
    label.textColor = [UIColor whiteColor];
    int i = 0;
    for (id key in self.AD.VCDic) {
        if(i == (int)indexPath.row) {
            label.text = [[key lastPathComponent] stringByDeletingPathExtension];
        }
        i = i + 1;
    }
    
    [cell.contentView addSubview:label];
    
    return cell;
}

- (UIEdgeInsets)collectionView:(UICollectionView*)collectionView layout:(UICollectionViewLayout *)collectionViewLayout insetForSectionAtIndex:(NSInteger)section {
    return UIEdgeInsetsMake(0, 0, 0, 0); // top, left, bottom, right
}

// 셀 사이즈
- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath
{
    return CGSizeMake(cellSize, 40);
}

// 셀 클릭 이벤트
- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath
{
    NSLog(@"didSelectItemAtIndexPath beforeIndex = %d", beforeIndex);
    NSLog(@"Select index before = %d", index);
    //    NSLog(@"document Path1 = %@", self.pdfPath);
    //    NSURL *url = [NSURL URLWithString:[self.pdfPath stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding]];
    //    [self.DocumentViewController saveAsFile:url];
    //    [self.DocumentViewController saveFile:YES];
    beforeIndex = index;
    index = (int)indexPath.row;
    self.AD.back_index = index;
    click = click+1;
    NSLog(@"click = %d", click);
    if(click == 2) {
        [self collectionView:_collectionView didDeselectItemAtIndexPath:[NSIndexPath indexPathForRow:beforeIndex inSection:0]];
    }
    NSLog(@"indexPath.row = %ld", (long)indexPath.row);
    UICollectionViewCell* cell = [collectionView cellForItemAtIndexPath:indexPath];
    
    for (UIView *lbl in cell.contentView.subviews)
    {
        if ([lbl isKindOfClass:[UIView class]])
        {
            for (UIButton *bt in lbl.subviews)
            {
                if ([bt isKindOfClass:[UIButton class]])
                {
                    [bt removeFromSuperview];
                }
            }
            [lbl removeGestureRecognizer:self.cellTap];
        }
    }
    
    self.CloseTapView = [[UIView alloc] initWithFrame:CGRectMake(cell.frame.size.width-40, 0, 40, 40)];
    self.cellTap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(CloseTap:)];
    [self.CloseTapView addGestureRecognizer:self.cellTap];
    
    self.closeTap = [[UIButton alloc] initWithFrame: CGRectMake(15, 12, 15, 15)];
    [self.closeTap setImage:[UIImage imageNamed:@"viewer-icon/tap-close-01.png"] forState:UIControlStateNormal];
    [self.closeTap addTarget: self action: @selector(CloseTap:) forControlEvents: UIControlEventTouchUpInside];
    
    [self.CloseTapView addSubview:self.closeTap];
    
    [cell.contentView addSubview:self.CloseTapView];
    
    cell.layer.backgroundColor = [UIColor colorWithRed:0.16 green:0.36 blue:0.61 alpha:0.90].CGColor;
    if(fromCollectionViewInit) {
        
    } else NSLog(@"fromCollectionViewInit NO");
    //    if(!fromCollectionViewInit){
    if(click > 1){
        int i = 0;
        NSLog(@"in click");
        for (id key in self.AD.VCDic) {
            if(i == (int)indexPath.row) {
                if(isSplit){
                    self.title = [[key lastPathComponent] stringByDeletingPathExtension];
                    //                    self.navbar.topItem.title = self.title;
                    self.backBtn.title = self.title;
                } else {
                    self.backBtn.title = @"";
                }
                self.pdfPath = key;
                
                //                    NSURL *url = [NSURL URLWithString:[self.pdfPath stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding]];
                //                    [self.DocumentViewController saveAsFile:url];
                //                [self.DocumentViewController saveFile:YES];
                self.DocumentViewController = nil;
                //                self.DocumentViewController = [PlugPDFDocumentViewController initWithPath:key password:@"" title:@""];
                self.DocumentViewController = [self.AD.VCDic objectForKey:key];
                //                [self.DocumentViewController setEnablePageFlipEffect:NO];
                int i = 0;
                @try{
                    [self.AD.navigationController pushViewController:self.DocumentViewController animated:NO];
                    i = 1;
                }@catch (NSException * e) {
                    [self.AD.navigationController popToViewController:self.DocumentViewController animated:NO];
                }@finally {
                    //                        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.2 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                    int orientation = [[UIApplication sharedApplication] statusBarOrientation];
                    if((int)orientation == 3 || (int)orientation == 4){
                        if(isEbook){
                            NSLog(@"PlugPDFDocumentDisplayModeEBook Mode");
                            if(self.DocumentViewController.pageCount == 1){
                                [self.DocumentViewController setEnablePageFlipEffect:NO];
                                [self.DocumentViewController setDisplayMode:PlugPDFDocumentDisplayModeHorizontal];
                            } else {
                                if(verticalThumbnailToEbook) {
                                    NSLog(@"verticalThumbnailToEbook 1111");
                                    [self.DocumentViewController setEnablePageFlipEffect:NO];
                                    if(self.DocumentViewController.displayMode != PlugPDFDocumentDisplayModeHorizontal)
                                        [self.DocumentViewController setDisplayMode:PlugPDFDocumentDisplayModeHorizontal];
                                    [self.DocumentViewController setEnablePageFlipEffect:YES];
                                    verticalThumbnailToEbook = NO;
                                } else {
                                    NSLog(@"Not Ebook");
                                    if(self.DocumentViewController.displayMode == PlugPDFDocumentDisplayModeThumbnail){
                                        [self.DocumentViewController setEnablePageFlipEffect:YES];
                                        [self.DocumentViewController setDisplayMode:PlugPDFDocumentDisplayModeHorizontal];
                                    } else {
                                        if(self.DocumentViewController.displayMode == PlugPDFDocumentDisplayModeVertical){
                                            [self.DocumentViewController setEnablePageFlipEffect:YES];
                                            [self.DocumentViewController setDisplayMode:PlugPDFDocumentDisplayModeHorizontal];
                                        } else {
                                            [self.DocumentViewController setEnablePageFlipEffect:YES];
                                            //                                            [self.DocumentViewController refreshView];
                                        }
                                    }
                                }
                            }
                            [self.displayModeButton setImage:[UIImage imageNamed:@"viewer-icon/top-icon-03-03.png"] forState:UIControlStateNormal];
                        } else {
                            isEbook = NO;
                            if(displayHorizontal) {
                                NSLog(@"PlugPDFDocumentDisplayModeHorizontal Mode");
                                if(self.DocumentViewController.displayMode == PlugPDFDocumentDisplayModeThumbnail){
                                    [self.DocumentViewController setEnablePageFlipEffect:NO];
                                    [self.DocumentViewController setDisplayMode:PlugPDFDocumentDisplayModeHorizontal];
                                } else {
                                    [self.DocumentViewController setEnablePageFlipEffect:NO];
                                    if(self.DocumentViewController.displayMode == PlugPDFDocumentDisplayModeVertical)
                                        [self.DocumentViewController setDisplayMode:PlugPDFDocumentDisplayModeHorizontal];
                                }
                                //                                [self.DocumentViewController refreshView];
                                [self.displayModeButton setImage:[UIImage imageNamed:@"viewer-icon/top-icon-03-01.png"] forState:UIControlStateNormal];
                                //                        [self.DocumentViewController setDisplayMode:PlugPDFDocumentDisplayModeHorizontal];
                            } else if(displayVertical){
                                //                                [self.DocumentViewController setEnablePageFlipEffect:NO];
                                //                                [self.DocumentViewController setDisplayMode:PlugPDFDocumentDisplayModeVertical];
                                //                                [self.displayModeButton setImage:[UIImage imageNamed:@"viewer-icon/top-icon-03-02.png"] forState:UIControlStateNormal];
                                
                                if(verticalThumbnailToEbook) {
                                    NSLog(@"verticalThumbnailToEbook");
                                    [self.DocumentViewController setEnablePageFlipEffect:NO];
                                    if(self.DocumentViewController.displayMode != PlugPDFDocumentDisplayModeHorizontal)
                                        [self.DocumentViewController setDisplayMode:PlugPDFDocumentDisplayModeHorizontal];
                                    [self.DocumentViewController setEnablePageFlipEffect:YES];
                                    verticalThumbnailToEbook = NO;
                                    isEbook = YES;
                                    NSLog(@"verticalThumbnailToEbook2");
                                    [self.displayModeButton setImage:[UIImage imageNamed:@"viewer-icon/top-icon-03-03.png"] forState:UIControlStateNormal];
                                } else {
                                    //                                    if(self.DocumentViewController.displayMode == PlugPDFDocumentDisplayModeThumbnail){
                                    //                                        [self.DocumentViewController setEnablePageFlipEffect:YES];
                                    //                                        [self.DocumentViewController setDisplayMode:PlugPDFDocumentDisplayModeHorizontal];
                                    //                                    } else {
                                    //                                        [self.DocumentViewController setEnablePageFlipEffect:NO];
                                    [self.DocumentViewController setDisplayMode:PlugPDFDocumentDisplayModeVertical];
                                    //                                    }
                                }
                            }
                        }
                    } else {
                        if(isEbook){
                            [self.DocumentViewController setEnablePageFlipEffect:YES];
                            [self.DocumentViewController setDisplayMode:PlugPDFDocumentDisplayModeHorizontal];
                            //                            [self.DocumentViewController refreshView];
                        } else if(displayHorizontal) {
                            NSLog(@"PlugPDFDocumentDisplayModeHorizontal Mode222");
                            if(self.DocumentViewController.displayMode == PlugPDFDocumentDisplayModeThumbnail){
                                [self.DocumentViewController setEnablePageFlipEffect:YES];
                                [self.DocumentViewController setDisplayMode:PlugPDFDocumentDisplayModeHorizontal];
                            } else {
                                //                                [self.DocumentViewController setEnablePageFlipEffect:NO];
                                if(self.DocumentViewController.displayMode == 1)
                                    [self.DocumentViewController setDisplayMode:PlugPDFDocumentDisplayModeHorizontal];
                                [self.DocumentViewController setEnablePageFlipEffect:YES];
                            }
                            
                            //                            [self.DocumentViewController refreshView];
                            [self.displayModeButton setImage:[UIImage imageNamed:@"viewer-icon/top-icon-03-01.png"] forState:UIControlStateNormal];
                        } else if(displayVertical){
                            NSLog(@"PlugPDFDocumentDisplayModeVertical Mode222");
                            //                            [self.DocumentViewController setEnablePageFlipEffect:NO];
                            [self.DocumentViewController setDisplayMode:PlugPDFDocumentDisplayModeVertical];
                            //                            [self.DocumentViewController refreshView];
                            [self.displayModeButton setImage:[UIImage imageNamed:@"viewer-icon/top-icon-03-02.png"] forState:UIControlStateNormal];
                        }
                    }
                }
            }
            i = i + 1;
        }
        if(UsingSearch){
            UsingSearch = NO;
            [self.DocumentViewController releaseTools];
            [self releaseAnnots];
            
            [self.DocumentViewController.documentView addGestureRecognizer:self.longPress];
            [self.DocumentViewController.documentView removeGestureRecognizer:self.pan];
            
            [self.searchNavbar removeFromSuperview];
            [self initNavigationBar];
        }
    } else {
        if(fromCollectionViewInit){
            isEbook = NO;
            displayHorizontal = YES;
            displayVertical = NO;
            NSLog(@"Horizontal Mode");
            
            //        if(self.DocumentViewController.pageIdx+1 == self.DocumentViewController.pageCount)
            //            [self.DocumentViewController gotoPage:self.DocumentViewController.pageIdx-1 fitToScreen:YES];
            
            int orientation = [[UIApplication sharedApplication] statusBarOrientation];
            CGFloat widthSize = CGRectGetWidth(self.window.frame);
            if((int)orientation == 3 || (int)orientation == 4){
                [self.DocumentViewController setEnablePageFlipEffect:NO];
            } else {
                [self.DocumentViewController setEnablePageFlipEffect:YES];
            }
            
            [self.DocumentViewController setDisplayMode:PlugPDFDocumentDisplayModeHorizontal];
            [self.displayPopoverController dismissPopoverAnimated:NO];
            [self.displayModeButton setImage:[UIImage imageNamed:@"viewer-icon/top-icon-03-01.png"] forState:UIControlStateNormal];
            //            [self.DocumentViewController refreshView];
        } else {
            int orientation = [[UIApplication sharedApplication] statusBarOrientation];
            CGFloat windowWidth = CGRectGetWidth(self.window.frame);
            if((int)orientation == 3 || (int)orientation == 4){
                if(isEbook){
                    NSLog(@"PlugPDFDocumentDisplayModeEBook Mode222");
                    if(self.DocumentViewController.pageCount == 1){
                        [self.DocumentViewController setEnablePageFlipEffect:NO];
                        [self.DocumentViewController setDisplayMode:PlugPDFDocumentDisplayModeHorizontal];
                        //                        [self.DocumentViewController refreshView];
                    } else {
                        [self.DocumentViewController setEnablePageFlipEffect:YES];
                        //                        [self.DocumentViewController setDisplayMode:PlugPDFDocumentDisplayModeHorizontal];
                        //                        [self.DocumentViewController refreshView];
                    }
                    [self.displayModeButton setImage:[UIImage imageNamed:@"viewer-icon/top-icon-03-03.png"] forState:UIControlStateNormal];
                } else {
                    NSLog(@"PlugPDFDocumentDisplayModeHorizontal Mode");
                    if(displayHorizontal) {
                        [self.DocumentViewController setEnablePageFlipEffect:NO];
                        [self.DocumentViewController setDisplayMode:PlugPDFDocumentDisplayModeHorizontal];
                        //                        [self.DocumentViewController refreshView];
                    } else if(displayVertical){
                        //                        [self.DocumentViewController setEnablePageFlipEffect:NO];
                        [self.DocumentViewController setDisplayMode:PlugPDFDocumentDisplayModeVertical];
                        //                        [self.DocumentViewController refreshView];
                    }
                }
            } else {
                if(isEbook) {
                    [self.displayModeButton setImage:[UIImage imageNamed:@"viewer-icon/top-icon-03-01.png"] forState:UIControlStateNormal];
                    [self.DocumentViewController setEnablePageFlipEffect:YES];
                    [self.DocumentViewController setDisplayMode:PlugPDFDocumentDisplayModeHorizontal];
                    //                    [self.DocumentViewController refreshView];
                    isEbook = NO;
                    displayHorizontal = YES;
                    displayVertical = NO;
                } else if(displayHorizontal) {
                    [self.DocumentViewController setEnablePageFlipEffect:YES];
                    //                        [self.DocumentViewController setDisplayMode:PlugPDFDocumentDisplayModeHorizontal];
                    //                    [self.DocumentViewController refreshView];
                    [self.displayModeButton setImage:[UIImage imageNamed:@"viewer-icon/top-icon-03-01.png"] forState:UIControlStateNormal];
                    isEbook = NO;
                    displayHorizontal = YES;
                    displayVertical = NO;
                } else if(displayVertical){
                    //                    [self.DocumentViewController setEnablePageFlipEffect:NO];
                    [self.DocumentViewController setDisplayMode:PlugPDFDocumentDisplayModeVertical];
                    //                    [self.DocumentViewController refreshView];
                    [self.displayModeButton setImage:[UIImage imageNamed:@"viewer-icon/top-icon-03-02.png"] forState:UIControlStateNormal];
                    isEbook = NO;
                    displayHorizontal = NO;
                    displayVertical = YES;
                }
            }
        }
    }
    
    if(self.DocumentViewController.displayMode == PlugPDFDocumentDisplayModeThumbnail){
        [self.DocumentViewController setEnablePageFlipEffect:YES];
        [self.DocumentViewController setDisplayMode:PlugPDFDocumentDisplayModeHorizontal];
    }
    //    }
    
    int orientation = [[UIApplication sharedApplication] statusBarOrientation];
    //    if(viewLoad) {
//    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.01 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
    
//    });
    //        viewLoad = NO;
    //    } else {
    //        [self.DocumentViewController refreshView];
    //    }
    
    fromCollectionViewInit = NO;
    fromCellClick = YES;
    
    [self.hideView removeFromSuperview];
    [self.handView removeFromSuperview];
    [self.inkView removeFromSuperview];
    [self.eraserView removeFromSuperview];
    [self.penView removeFromSuperview];
    [self.searchView removeFromSuperview];
    [self.bookMarkView removeFromSuperview];
    [self.displayModeView removeFromSuperview];
    [self.saveView removeFromSuperview];
    
    if(self.DocumentViewController.modifyContentPermission || self.DocumentViewController.modifyAnnotPermission){
        [self.navbar addSubview:self.hideView];
        [self.navbar addSubview:self.handView];
        [self.navbar addSubview:self.inkView];
        [self.navbar addSubview:self.eraserView];
        [self.navbar addSubview:self.penView];
        [self.navbar addSubview:self.searchView];
        [self.navbar addSubview:self.bookMarkView];
        [self.navbar addSubview:self.displayModeView];
        [self.navbar addSubview:self.saveView];
        
        [self.searchView setFrame:CGRectMake(self.navbar.frame.size.width-240, 0, 40, 40)];
        [self.displayModeView setFrame:CGRectMake(self.navbar.frame.size.width-320, 0, 40, 40)];
    } else {
        [self.navbar addSubview:self.hideView];
        [self.navbar addSubview:self.handView];
        [self.navbar addSubview:self.searchView];
        [self.navbar addSubview:self.displayModeView];
        
        [self.searchView setFrame:CGRectMake(self.navbar.frame.size.width-120, 0, 40, 40)];
        [self.displayModeView setFrame:CGRectMake(self.navbar.frame.size.width-160, 0, 40, 40)];
        
        [self.handButton sendActionsForControlEvents:UIControlEventTouchUpInside];
    }
    [self.DocumentViewController refreshView];
}

// 선택 해제된 셀
-(void)collectionView:(UICollectionView *)collectionView didDeselectItemAtIndexPath:(NSIndexPath *)indexPath{
    NSLog(@"DeSelect indexPath.row = %d", (int)indexPath.row);
    beforeIndex = (int)indexPath.row;
    UICollectionViewCell* cell = [collectionView cellForItemAtIndexPath:indexPath];
    cell.layer.backgroundColor = [UIColor colorWithRed:0.06 green:0.20 blue:0.39 alpha:0.50].CGColor;
    
    for (UIView *lbl in cell.contentView.subviews)
    {
        if ([lbl isKindOfClass:[UIView class]])
        {
            for (UIButton *bt in lbl.subviews)
            {
                if ([bt isKindOfClass:[UIButton class]])
                {
                    [bt removeFromSuperview];
                }
            }
            [lbl removeGestureRecognizer:self.cellTap];
        }
    }
}

-(void)collectionView:(UICollectionView *)collectionView didEndDisplayingCell:(UICollectionViewCell *)cell forItemAtIndexPath:(NSIndexPath *)indexPath{
    NSLog(@"Deleted");
    cell.layer.backgroundColor = [UIColor colorWithRed:0.06 green:0.20 blue:0.39 alpha:0.50].CGColor;
    for (UIView *lbl in cell.contentView.subviews)
    {
        if ([lbl isKindOfClass:[UIView class]])
        {
            for (UIButton *bt in lbl.subviews)
            {
                if ([bt isKindOfClass:[UIButton class]])
                {
                    [bt removeFromSuperview];
                }
            }
            [lbl removeGestureRecognizer:self.cellTap];
        }
    }
    //    UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(10, 5, CGRectGetWidth(cell.frame)-40, 30)];
    //    label.textColor = [UIColor whiteColor];
    //    label.text = @"";
}

-(void)collectionView:(UICollectionView *)collectionView willDisplayCell:(nonnull UICollectionViewCell *)cell forItemAtIndexPath:(nonnull NSIndexPath *)indexPath{
    NSLog(@"Display Cell indexPath.row = %ld, index = %d", (long)indexPath.row, index);
    
    if((long)indexPath.row == index){
        cell.layer.backgroundColor = [UIColor colorWithRed:0.16 green:0.36 blue:0.61 alpha:0.90].CGColor;
        
        self.CloseTapView = [[UIView alloc] initWithFrame:CGRectMake(cell.frame.size.width-40, 0, 40, 40)];
        self.cellTap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(CloseTap:)];
        [self.CloseTapView addGestureRecognizer:self.cellTap];
        
        self.closeTap = [[UIButton alloc] initWithFrame: CGRectMake(15, 12, 15, 15)];
        [self.closeTap setImage:[UIImage imageNamed:@"viewer-icon/tap-close-01.png"] forState:UIControlStateNormal];
        [self.closeTap addTarget: self action: @selector(CloseTap:) forControlEvents: UIControlEventTouchUpInside];
        
        [self.CloseTapView addSubview:self.closeTap];
        
        [cell.contentView addSubview:self.CloseTapView];
    }
    
    //    UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(10, 5, CGRectGetWidth(cell.frame)-40, 30)];
    //    label.textColor = [UIColor whiteColor];
    //    int i = 0;
    //    for (id key in self.AD.VCDic) {
    //        if(i == (int)indexPath.row) {
    //            label.text = [[key lastPathComponent] stringByDeletingPathExtension];
    //        }
    //        i = i + 1;
    //    }
    //
    //    [cell.contentView addSubview:label];
}

//// 터치 시 색상 변경
//- (void)collectionView:(UICollectionView *)collectionView didHighlightItemAtIndexPath:(NSIndexPath *)indexPath
//{
//    UICollectionViewCell* cell = [collectionView cellForItemAtIndexPath:indexPath];
//
//    cell.layer.borderColor = [UIColor cyanColor].CGColor;
//    cell.layer.borderWidth = 3.0f;
//}
//
//// 터치 시 색상 해제
//- (void)collectionView:(UICollectionView *)collectionView didUnhighlightItemAtIndexPath:(NSIndexPath *)indexPath
//{
//    UICollectionViewCell* cell = [collectionView cellForItemAtIndexPath:indexPath];
//
//    cell.layer.borderColor = nil;
//    cell.layer.borderWidth = 0.0f;
//}
//
//-(BOOL)collectionView:(UICollectionView *)collectionView shouldSelectItemAtIndexPath:(NSIndexPath *)indexPath{
//    return YES;
//}

- (void)didReceiveMemoryWarning {
    [self didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)hideBar: (id)sender{
    //    NSString *bundleIdentifier = [[NSBundle mainBundle] bundleIdentifier];
    //    NSLog(@"bundleIdentifier = %@", bundleIdentifier);
    
    penPopup = NO;
    inkPopup = NO;
    eraserPopup = NO;
    NSArray* outlines = self.DocumentViewController.document.outlines;
    for(int i = 0; i < outlines.count; i++){
        PlugPDFOutlineItem* getItem = outlines[i];
        NSLog(@"getItem Idx = %ld", getItem.idx);
        NSLog(@"getItem PageIdx = %ld", (long)getItem.pageIdx);
    }
    
    [self.penPopoverController dismissPopoverAnimated:NO];
    [self.inkPopoverController dismissPopoverAnimated:NO];
    [self.eraserPopoverController dismissPopoverAnimated:NO];
    [self.BMpopoverController dismissPopoverAnimated:NO];
    [self.displayPopoverController dismissPopoverAnimated:NO];
    
    isHidden = YES;
    self.displayBtnView = [[UIView alloc] initWithFrame: CGRectMake(CGRectGetWidth(self.window.frame)-45, 50, 30, 30)];
    self.displayBtnView.backgroundColor = [UIColor colorWithRed:0.09 green:0.27 blue:0.48 alpha:0.70];
    self.displayBtnView.layer.cornerRadius = 3.0f;
    
    self.displayBarGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(displayBar:)];
    [self.displayBtnView addGestureRecognizer:self.displayBarGesture];
    
    self.displayBtn = [[UIButton alloc] initWithFrame: CGRectMake(5, 5, 20, 20)];
    [self.displayBtn setImage:[UIImage imageNamed:@"viewer-icon/tap-down.png"] forState:UIControlStateNormal];
    [self.displayBtn addTarget: self action: @selector(displayBar:) forControlEvents: UIControlEventTouchUpInside];
    [self.displayBtnView addSubview:self.displayBtn];
    //    UITapGestureRecognizer* displayBtnTap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(displayBar:)];
    //    [self.closeBtnView addGestureRecognizer:displayBtnTap];
    
    self.closeBtnView = [[UIView alloc] initWithFrame: CGRectMake(25, 50, 30, 30)];
    self.closeBtnView.backgroundColor = [UIColor colorWithRed:0.09 green:0.27 blue:0.48 alpha:0.70];
    self.closeBtnView.layer.cornerRadius = 3.0f;
    
    self.closeBtn = [[UIButton alloc] initWithFrame: CGRectMake(5, 5, 20, 20)];
    [self.closeBtn setImage:[UIImage imageNamed:@"viewer-icon/tap-close-01.png"] forState:UIControlStateNormal];
    [self.closeBtn addTarget: self action: @selector(CloseTap:) forControlEvents: UIControlEventTouchUpInside];
    [self.closeBtnView addSubview:self.closeBtn];
    self.cellTap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(CloseTap:)];
    [self.closeBtnView addGestureRecognizer:self.cellTap];
    
    [self.AD.navigationController.view addSubview:self.displayBtnView];
    [self.AD.navigationController.view addSubview:self.closeBtnView];
    
    [self.navbar setHidden:YES];
    [self.tapBar setHidden:YES];
    //    [self.beforePageView setHidden:YES];
    //    [self.nextPageView setHidden:YES];
    //    [self.DocumentViewController setEnableBottomBar:YES];
    [self.DocumentViewController setNavigationToolBarHidden:YES];
    [self.DocumentViewController setEnableAlwaysVisible:NO];
    //    [self.DocumentViewController setEnableBottomBar:NO];
}

- (void)displayBar: (id)sender{
    [self.penPopoverController dismissPopoverAnimated:NO];
    [self.inkPopoverController dismissPopoverAnimated:NO];
    [self.eraserPopoverController dismissPopoverAnimated:NO];
    [self.BMpopoverController dismissPopoverAnimated:NO];
    [self.displayPopoverController dismissPopoverAnimated:NO];
    
    isHidden = NO;
    [self.displayBtnView setHidden:YES];
    [self.closeBtnView setHidden:YES];
    [self.navbar setHidden:NO];
    //    [self.beforePageView setHidden:NO];
    [self.tapBar setHidden:NO];
    //    [self.nextPageView setHidden:NO];
    //    [self.beforePage setHidden:NO];
    //    [self.DocumentViewController setEnableBottomBar:YES];
    [self.DocumentViewController setNavigationToolBarHidden:NO];
    //    [self.DocumentViewController setEnableBottomBar:NO];
    [self.DocumentViewController setEnableAlwaysVisible:YES];
    
}

- (void) fileSave {
    if(UsingNote){
        UsingNote = NO;
        activateNoteMode = NO;
        [self.handButton sendActionsForControlEvents:UIControlEventTouchUpInside];
    }
    
    [self.penPopoverController dismissPopoverAnimated:NO];
    [self.inkPopoverController dismissPopoverAnimated:NO];
    [self.eraserPopoverController dismissPopoverAnimated:NO];
    penPopup = NO;
    inkPopup = NO;
    eraserPopup = NO;
    
    UIAlertController * alert=   [UIAlertController
                                  alertControllerWithTitle:@"저장하시겠습니까?"
                                  message:@""
                                  preferredStyle:UIAlertControllerStyleAlert];
    
    UIAlertAction* ok = [UIAlertAction
                         actionWithTitle:@"OK"
                         style:UIAlertActionStyleDefault
                         handler:^(UIAlertAction * action)
                         {
                             [alert dismissViewControllerAnimated:YES completion:nil];
                             
                             if(self.DocumentViewController.modifyContentPermission || self.DocumentViewController.modifyAnnotPermission){

                             [self.DocumentViewController saveAsFile:[[NSURL alloc] initFileURLWithPath: self.pdfPath]];
                             
                             NSDate *nsDate = [NSDate date];
                             NSCalendar *nsCalendar = [NSCalendar currentCalendar];
                             unsigned int unitFlags = NSCalendarUnitYear | NSCalendarUnitMonth | NSCalendarUnitDay | NSCalendarUnitHour | NSCalendarUnitMinute | NSCalendarUnitSecond;
                             NSDateComponents *nsDateComponents = [nsCalendar components:unitFlags fromDate:nsDate];
                             
                             NSString *currentTime = @"";
                             NSString *month = @"";
                             NSString *day = @"";
                             NSString *hour = @"";
                             NSString *minute = @"";
                             NSString *second = @"";
                             if([nsDateComponents month] < 10) {
                                 month = @"0";
                                 month = [month stringByAppendingString:[@((long)[nsDateComponents month]) stringValue]];
                             } else {
                                 month = [month stringByAppendingString:[@((long)[nsDateComponents month]) stringValue]];
                             }
                             if([nsDateComponents day] < 10) {
                                 day = @"0";
                                 day = [day stringByAppendingString:[@((long)[nsDateComponents day]) stringValue]];
                             } else {
                                 day = [day stringByAppendingString:[@((long)[nsDateComponents day]) stringValue]];
                             }
                             if([nsDateComponents hour] < 10) {
                                 hour = @"0";
                                 hour = [hour stringByAppendingString:[@((long)[nsDateComponents hour]) stringValue]];
                             } else {
                                 hour = [hour stringByAppendingString:[@((long)[nsDateComponents hour]) stringValue]];
                             }
                             if([nsDateComponents minute] < 10) {
                                 minute = @"0";
                                 minute = [minute stringByAppendingString:[@((long)[nsDateComponents minute]) stringValue]];
                             } else {
                                 minute = [minute stringByAppendingString:[@((long)[nsDateComponents minute]) stringValue]];
                             }
                             if([nsDateComponents second] < 10) {
                                 second = @"0";
                                 second = [second stringByAppendingString:[@((long)[nsDateComponents second]) stringValue]];
                             } else {
                                 second = [second stringByAppendingString:[@((long)[nsDateComponents second]) stringValue]];
                             }
                             currentTime = [currentTime stringByAppendingString:[@((long)[nsDateComponents year]) stringValue]];
                             currentTime = [currentTime stringByAppendingString:month];
                             currentTime = [currentTime stringByAppendingString:day];
                             //                                 currentTime = [currentTime stringByAppendingString:hour];
                             //                                 currentTime = [currentTime stringByAppendingString:minute];
                             //                                 currentTime = [currentTime stringByAppendingString:second];
                             
                             NSRange twoCut = {2,6};
                             currentTime = [currentTime substringWithRange:twoCut];
                             
                             NSString* uploadFilePath = self.pdfPath;
                             NSString* appendTime = currentTime;
                             appendTime = [appendTime stringByAppendingString:@"_"];
                             
                             NSRange cutTime = {0,7};
                             if(self.title.length >= 7){
                                 NSString* comparePath = [self.title substringWithRange:cutTime];
                                 
                                 //                                     NSRange range = [comparePath rangeOfString:appendTime];
                                 //                                     if (range.location != NSNotFound)
                                 //                                         appendTime = @"";
                             } else {
                                 //                                     appendTime = @"";
                             }
                             appendTime = [appendTime stringByAppendingString:self.title];
                             
                             uploadFilePath = [uploadFilePath stringByReplacingOccurrencesOfString:self.title withString:appendTime];
                             
                             //                                 self.title = [appendTime stringByAppendingString:self.title];
                             //                                 NSString* getList = [[NSUserDefaults standardUserDefaults] objectForKey:@"param"];
                             //                                 NSArray* getFile = [getList componentsSeparatedByString:@"\r\n"];
                             //                                 NSString* tmpPath = [[uploadFilePath lastPathComponent] stringByDeletingPathExtension];
                             //
                             //                                 BOOL convertPath = NO;
                             //
                             //                                 for(int i = 0; i < getFile.count; i++){
                             //                                     NSRange range2 = [getFile[i] rangeOfString:tmpPath];
                             //                                     if (range2.location != NSNotFound){
                             //                                         NSString* tmpExtension = @"(";
                             //                                         tmpExtension = [tmpExtension stringByAppendingString:[NSString stringWithFormat:@"%d",i+1]];
                             //                                         tmpExtension = [tmpExtension stringByAppendingString:@")"];
                             //                                         tmpPath = [[uploadFilePath lastPathComponent] stringByDeletingPathExtension];
                             //                                         tmpPath = [tmpPath stringByAppendingString:tmpExtension];
                             //                                         tmpPath = [tmpPath stringByAppendingString:@".pdf"];
                             //                                         convertPath = YES;
                             //                                     } else {
                             //                                         break;
                             //                                     }
                             //                                 }
                             //
                             //                                 if(convertPath) uploadFilePath = tmpPath;
                             
                             //                                 PlugPDFDocumentViewController* newController = [self.AD.VCDic objectForKey:self.pdfPath];
                             //                                 [self.AD.VCDic insertObject:newController forKey:uploadFilePath atIndex:index];
                             //                                 [self.AD.VCDic removeObjectForKey:self.pdfPath];
                             
                             BOOL fileExists = [[NSFileManager defaultManager] fileExistsAtPath:uploadFilePath];
                             if(fileExists) [[NSFileManager defaultManager] removeItemAtPath:uploadFilePath error:nil];
                             
                             [[NSFileManager defaultManager] copyItemAtPath:self.pdfPath toPath:uploadFilePath error:nil];
                             //                                 self.pdfPath = uploadFilePath;
                             NSLog(@"uploadFilePath = %@", uploadFilePath);
                             
                             [[NSUserDefaults standardUserDefaults] setValue:uploadFilePath forKey:@"pdfPath"];
                             
                             NSNotificationCenter *notificationCenter = [NSNotificationCenter defaultCenter];
                             NSDictionary *dic = [NSDictionary dictionaryWithObject:@"test2" forKey:@"secondKey"];
                             [notificationCenter postNotificationName:@"secondNotification" object:self userInfo:dic];
                             
                             
                             //                                 click = 0;
                             //                                 [self initCollectionView];
                             
                             
                             PlugPDFDocumentViewController* newController = [[PlugPDFDocumentViewController alloc] init];
                             newController = [self.AD.VCDic objectForKey:self.pdfPath];
                             NSLog(@"self.pdfPath = %@", self.pdfPath);
                             MutableOrderedDictionary* tmpDic = [[MutableOrderedDictionary alloc] init];
                             for (id key in self.AD.VCDic) {
                                 if([key isEqualToString:self.pdfPath]){
                                     
                                 } else {
                                     [tmpDic setObject:[self.AD.VCDic objectForKey:key] forKey:key];
                                 }
                             }
                             
                             [self.AD.VCDic removeAllObjects];
                             int i= 0;
                             for (id key in tmpDic) {
                                 if(i == index){
                                     [self.AD.VCDic setObject:newController forKey:self.pdfPath];
                                     [self.AD.VCDic setObject:[tmpDic objectForKey:key] forKey:key];
                                 } else {
                                     [self.AD.VCDic setObject:[tmpDic objectForKey:key] forKey:key];
                                 }
                                 i++;
                             }
                             
                             if(self.AD.VCDic.count == tmpDic.count)
                                 [self.AD.VCDic setObject:newController forKey:self.pdfPath];
                             
                             
                             // 파일 저장 후 새 파일에 북마크 다시 붙이기
                             NSMutableArray *arr = [[NSMutableArray alloc] init];
                             for (int i = 0; i < self.pagedata.count; i++) {
                                 NSLog(@"(long)[self.pagedata[i] integerValue] = %ld", (long)[self.pagedata[i] integerValue]);
                                 PlugPDFOutlineItem* outlineItem = [[PlugPDFOutlineItem alloc] initWithParent:nil
                                                                                                          idx: i
                                                                                                        title: self.tabledata[i]
                                                                                                      pageIdx: (long)[self.pagedata[i] integerValue]-1
                                                                                                        depth: 0];
                                 [arr addObject: outlineItem];
                             }
                             
                             [self.DocumentViewController.document updatePdfOutlineTree: arr];
                             
                             [self.DocumentViewController refreshView];
                             
                             [self.AD.navigationController.view makeToast:@"저장되었습니다." duration:1.0 position:[NSValue valueWithCGPoint:CGPointMake(self.AD.navigationController.view.frame.size.width/2, self.AD.navigationController.view.frame.size.height-150)]];
                             
                             dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1.3 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                                 self.AD.viewController.view.frame =  CGRectMake(0,-20,self.AD.viewController.view.window.frame.size.width,self.AD.viewController.view.window.frame.size.height+20);
                             });
                                 
                             } else {
                                 UIAlertController * alert=   [UIAlertController
                                                               alertControllerWithTitle:@"권한이 없어 파일을 저장할 수 없습니다."
                                                               message:@""
                                                               preferredStyle:UIAlertControllerStyleAlert];
                                 
                                 UIAlertAction* ok = [UIAlertAction
                                                      actionWithTitle:@"OK"
                                                      style:UIAlertActionStyleDefault
                                                      handler:^(UIAlertAction * action)
                                                      {
                                                          [alert dismissViewControllerAnimated:YES completion:nil];
                                                      }];
                                 
                                 [alert addAction:ok];
                                 
                                 [self.DocumentViewController presentViewController:alert animated:YES completion:nil];
                             }
                                 
                         }];
    
    UIAlertAction* cancel = [UIAlertAction
                             actionWithTitle:@"Cancel"
                             style:UIAlertActionStyleDefault
                             handler:^(UIAlertAction * action)
                             {
                                 [alert dismissViewControllerAnimated:YES completion:nil];
                             }];
    
    [alert addAction:ok];
    [alert addAction:cancel];
    
    [self.DocumentViewController presentViewController:alert animated:YES completion:nil];
}

- (void) onDisplayMode {
    displayPopup = YES;
    
    [self.penPopoverController dismissPopoverAnimated:NO];
    [self.inkPopoverController dismissPopoverAnimated:NO];
    [self.eraserPopoverController dismissPopoverAnimated:NO];
    [self.BMpopoverController dismissPopoverAnimated:NO];
    [self.displayPopoverController dismissPopoverAnimated:NO];
    //        [self releaseAnnots];
    penPopup = NO;
    inkPopup = NO;
    eraserPopup = NO;
    
    self.displayPopoverContent = [[UIViewController alloc] init]; //ViewController
    self.displayPopoverView = [[UIView alloc] init];   //view
    
    UIButton *button1 = [[UIButton alloc] initWithFrame: CGRectMake(5, 5, 30, 30)];
    [button1 setImage:[UIImage imageNamed:@"viewer-icon/top-icon-03-01.png"] forState:UIControlStateNormal];
    [button1 addTarget: self action: @selector(horizontalMode) forControlEvents: UIControlEventTouchUpInside];
    button1.tag = 1;
    
    UIButton *button2 = [[UIButton alloc] initWithFrame: CGRectMake(5, 40, 30, 30)];
    [button2 setImage:[UIImage imageNamed:@"viewer-icon/top-icon-03-02.png"] forState:UIControlStateNormal];
    [button2 addTarget: self action: @selector(verticalMode) forControlEvents: UIControlEventTouchUpInside];
    button2.tag = 2;
    
    UIButton *button3 = [[UIButton alloc] initWithFrame: CGRectMake(5, 75, 30, 30)];
    [button3 setImage:[UIImage imageNamed:@"viewer-icon/top-icon-03-03.png"] forState:UIControlStateNormal];
    [button3 addTarget: self action: @selector(ebookMode) forControlEvents: UIControlEventTouchUpInside];
    button3.tag = 3;
    
    UIButton *button22 = [[UIButton alloc] initWithFrame: CGRectMake(5, 110, 30, 30)];
    [button22 setImage:[UIImage imageNamed:@"viewer-icon/top-icon-03-04.png"] forState:UIControlStateNormal];
    [button22 addTarget: self action: @selector(thumbnailMode) forControlEvents: UIControlEventTouchUpInside];
    button22.tag = 22;
    
    [self.displayPopoverView addSubview:button1];
    [self.displayPopoverView addSubview:button2];
    [self.displayPopoverView addSubview:button3];
    [self.displayPopoverView addSubview:button22];
    
    self.displayPopoverContent.view = self.displayPopoverView;
    
    self.displayPopoverController = [[UIPopoverController alloc] initWithContentViewController:self.displayPopoverContent];
    self.displayPopoverController.delegate=self;
    self.displayPopoverController.backgroundColor = [UIColor colorWithRed:0.03 green:0.14 blue:0.27 alpha:0.5];
    
    //        UIView *view = [sender valueForKey:@"imageView"];
    UIView *view = [self.displayModeButton valueForKey:@"imageView"];
    self.tmpView = view;
    
    self.displayPopoverController.popoverContentSize = CGSizeMake(40, 145);
    [self.displayPopoverController presentPopoverFromRect:CGRectMake(CGRectGetWidth(view.frame)/2, 40, 0, 0) inView:view permittedArrowDirections:UIPopoverArrowDirectionUp animated:YES];
}

- (void) onBookmark {
    bookmarkPopup = YES;
    
    [self.penPopoverController dismissPopoverAnimated:NO];
    [self.inkPopoverController dismissPopoverAnimated:NO];
    [self.eraserPopoverController dismissPopoverAnimated:NO];
    [self.BMpopoverController dismissPopoverAnimated:NO];
    [self.displayPopoverController dismissPopoverAnimated:NO];
    //        [self releaseAnnots];
    penPopup = NO;
    inkPopup = NO;
    eraserPopup = NO;
    
    [self.tabledata removeAllObjects];
    [self.pagedata removeAllObjects];
    
    NSArray* outlines = self.DocumentViewController.document.outlines;
    NSLog(@"outlines = %@", outlines);
    for(int i = 0; i < outlines.count; i++){
        PlugPDFOutlineItem* getItem = outlines[i];
        NSLog(@"pageOdx = %ld", getItem.pageIdx);
        NSInteger currentPage = getItem.pageIdx+1;
        [self.tabledata addObject:getItem.title];
        [self.pagedata addObject:[NSString stringWithFormat:@"%d", (int)currentPage]];
    }
    
    //        NSSortDescriptor *highestToLowest = [NSSortDescriptor sortDescriptorWithKey:@"self" ascending:YES];
    //        [self.pagedata sortUsingDescriptors:[NSArray arrayWithObject:highestToLowest]];
    
    UIViewController* popoverContent = [[UIViewController alloc] init]; //ViewController
    self.BMpopoverView = [[UIView alloc] init];   //view
    
    popoverContent.view = self.BMpopoverView;
    
    self.BMpopoverController = [[UIPopoverController alloc] initWithContentViewController:popoverContent];
    self.BMpopoverController.delegate=self;
    self.BMpopoverController.backgroundColor = [UIColor colorWithRed:0.03 green:(0.14) blue:0.27 alpha:0.5];
    
    //        UIView *view = [sender valueForKey:@"imageView"];
    UIView *view = [self.bookMarkButton valueForKey:@"imageView"];
    
    self.BMnavcon = [[UINavigationBar alloc]initWithFrame:CGRectMake(5, 5, 290, 40)];
    self.BMnavItem = [[UINavigationItem alloc] init];
    
    UILabel* navTitle = [[UILabel alloc] init];
    navTitle.text = @"북마크 (목차)";
    navTitle.frame = CGRectMake(110, 15, 100, 10);
    navTitle.textColor = [UIColor whiteColor];
    
    
    self.addBMView = [[UIView alloc] initWithFrame:CGRectMake(210, 0, 40, 40)];
    UITapGestureRecognizer *addBookmark = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(addBookmark:)];
    [self.addBMView addGestureRecognizer:addBookmark];
    
    self.addBMbtn = [[UIButton alloc] initWithFrame: CGRectMake(10, 10, 25, 25)];
    [self.addBMbtn setImage:[UIImage imageNamed:@"viewer-icon/plus-01.png"] forState:UIControlStateNormal];
    [self.addBMbtn addTarget: self action: @selector(addBookmark:) forControlEvents: UIControlEventTouchUpInside];
    self.addBMbtn.tag = 13;
    [self.addBMView addSubview:self.addBMbtn];
    
    
    self.deleteBMView = [[UIView alloc] initWithFrame:CGRectMake(250, 0, 40, 40)];
    UITapGestureRecognizer *deleteBookmark = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(deleteBookmark:)];
    [self.deleteBMView addGestureRecognizer:deleteBookmark];
    
    self.deleteBMbtn = [[UIButton alloc] initWithFrame: CGRectMake(10, 10, 25, 25)];
    [self.deleteBMbtn setImage:[UIImage imageNamed:@"viewer-icon/minus-01.png"] forState:UIControlStateNormal];
    [self.deleteBMbtn addTarget: self action: @selector(deleteBookmark:) forControlEvents: UIControlEventTouchUpInside];
    self.deleteBMbtn.tag = 13;
    [self.deleteBMView addSubview:self.deleteBMbtn];
    
    
    //        [self.BMnavcon setBackgroundColor:[UIColor clearColor]];
    //        [self.BMnavcon setBarTintColor:[UIColor colorWithRed:0.03 green:(0.14) blue:0.27 alpha:0.1]];
    //        self.BMnavcon.translucent = NO;
    //        self.BMnavItem.title = @"북마크 (목차)";
    //        self.BMnavcon.tintColor = [UIColor whiteColor];
    //        [self.BMnavcon setTitleTextAttributes:@{NSForegroundColorAttributeName:[UIColor whiteColor]}];
    //        self.BMnavItem.titleView.alpha = 1.0;
    //
    //        UIImage *addBMImage = [UIImage imageNamed:@"viewer-icon/plus-01.png"];
    //        UIButton *addBMButton = [UIButton buttonWithType:UIButtonTypeCustom];
    //        [addBMButton setImage:addBMImage forState:UIControlStateNormal];
    //        addBMButton.frame = CGRectMake(0.0, 3.0, 25,25);
    //        [addBMButton addTarget:self action:@selector(openPlugPDF:) forControlEvents:UIControlEventTouchUpInside];
    //        addBMButton.tag = 23;
    //        UIBarButtonItem *addBM = [[UIBarButtonItem alloc] initWithCustomView:addBMButton];
    //
    //        UIImage *deleteBMImage = [UIImage imageNamed:@"viewer-icon/minus-01.png"];
    //        UIButton *deleteBMButton = [UIButton buttonWithType:UIButtonTypeCustom];
    //        [deleteBMButton setImage:deleteBMImage forState:UIControlStateNormal];
    //        deleteBMButton.frame = CGRectMake(0.0, 3.0, 25,25);
    //        [deleteBMButton addTarget:self action:@selector(openPlugPDF:) forControlEvents:UIControlEventTouchUpInside];
    //        deleteBMButton.tag = 24;
    //        UIBarButtonItem *delBM = [[UIBarButtonItem alloc] initWithCustomView:deleteBMButton];
    //
    //        self.BMnavItem.rightBarButtonItems = [NSArray arrayWithObjects:delBM,addBM,nil];
    //        [self.BMnavcon setItems:@[self.BMnavItem]];
    
    //        [popoverView addSubview:self.BMnavcon];
    [self.BMpopoverView addSubview:navTitle];
    [self.BMpopoverView addSubview:self.addBMView];
    [self.BMpopoverView addSubview:self.deleteBMView];
    
    self.BMtableView = [[UITableView alloc]initWithFrame:CGRectMake(5, 40, 290, 350)];
    self.BMtableView.delegate = self;
    self.BMtableView.dataSource = self;
    self.BMtableView.layer.cornerRadius = 10;
    [self.BMpopoverView addSubview:self.BMtableView];
    
    numberOfSection = 1;
    self.BMtableView.allowsSelectionDuringEditing = YES;
    self.BMtableView.contentInset = UIEdgeInsetsMake(0, -8, 0, 0);
    
    self.BMpopoverController.popoverContentSize = CGSizeMake(300, 400);
    [self.BMpopoverController presentPopoverFromRect:CGRectMake(CGRectGetWidth(view.frame)/2, 40, 0, 0) inView:view permittedArrowDirections:UIPopoverArrowDirectionUp animated:YES];
    
    [self.DocumentViewController.documentView removeGestureRecognizer:self.pan];
    [self.BMtableView reloadData];
}

- (void) onSearch {
    UsingSearch = YES;
    fromOnTapUp = NO;
    
    [self.penPopoverController dismissPopoverAnimated:NO];
    [self.inkPopoverController dismissPopoverAnimated:NO];
    [self.eraserPopoverController dismissPopoverAnimated:NO];
    penPopup = NO;
    inkPopup = NO;
    eraserPopup = NO;
    [self.DocumentViewController releaseTools];
    
    [self.navbar removeFromSuperview];
    self.searchNavbar = [[UINavigationBar alloc]initWithFrame:CGRectMake(0, 40, CGRectGetWidth(self.window.frame), 42)];
    self.navItem = [[UINavigationItem alloc] init];
    
    self.searchNavbar.translucent = NO;
    [self.searchNavbar setTintColor:[UIColor whiteColor]];
    [self.searchNavbar setBarTintColor:[UIColor colorWithRed:0.06 green:(0.27) blue:0.48 alpha:0.70]];
    
    UIImage *cancelSearchImage = [UIImage imageNamed:@"viewer-icon/search-defore.png"];
    UIView* cancelSearchView = [[UIView alloc] initWithFrame:CGRectMake(5, 0, 40,40)];
    UITapGestureRecognizer* cancelSearchGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(cancelSearch:)];
    [cancelSearchView addGestureRecognizer:cancelSearchGesture];
    UIButton *cancelSearchButton = [[UIButton alloc] initWithFrame: CGRectMake(5, 5, 35,35)];
    [cancelSearchButton setImage:cancelSearchImage forState:UIControlStateNormal];
    [cancelSearchButton addTarget: self action: @selector(cancelSearch:) forControlEvents: UIControlEventTouchUpInside];
    [cancelSearchView addSubview:cancelSearchButton];
    [self.searchNavbar addSubview:cancelSearchView];
    
    UIImage *backSearchImage = [UIImage imageNamed:@"viewer-icon/search-before.png"];
    self.backSearchView = [[UIView alloc] initWithFrame:CGRectMake(self.searchNavbar.frame.size.width-90, 0, 40, 40)];
    UITapGestureRecognizer* backSearchGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(backSearch:)];
    [cancelSearchView addGestureRecognizer:backSearchGesture];
    UIButton *backSearchButton = [[UIButton alloc] initWithFrame: CGRectMake(5, 5, 35, 35)];
    [backSearchButton setImage:backSearchImage forState:UIControlStateNormal];
    [backSearchButton addTarget: self action: @selector(backSearch:) forControlEvents: UIControlEventTouchUpInside];
    [self.backSearchView addSubview:backSearchButton];
    [self.searchNavbar addSubview:self.backSearchView];
    
    UIImage *forSearchImage = [UIImage imageNamed:@"viewer-icon/search-next.png"];
    self.forSearchView = [[UIView alloc] initWithFrame:CGRectMake(self.searchNavbar.frame.size.width-50, 0, 40, 40)];
    UITapGestureRecognizer* forSearchGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(forSearch:)];
    [self.forSearchView addGestureRecognizer:forSearchGesture];
    UIButton *forSearchButton = [[UIButton alloc] initWithFrame: CGRectMake(5, 5, 35, 35)];
    [forSearchButton setImage:forSearchImage forState:UIControlStateNormal];
    [forSearchButton addTarget: self action: @selector(forSearch:) forControlEvents: UIControlEventTouchUpInside];
    [self.forSearchView addSubview:forSearchButton];
    [self.searchNavbar addSubview:self.forSearchView];
    
    self.searchBar = [[UISearchBar alloc] initWithFrame:CGRectMake(60, 0, CGRectGetWidth(self.navbar.frame) - 160, 45)];
    self.searchBar.placeholder = @"단어 검색";
    self.searchBar.delegate = self;
    self.searchBar.tintColor = [UIColor blackColor];
    [self.searchNavbar addSubview:self.searchBar];
    
    //    self.navItem.leftBarButtonItems = [NSArray arrayWithObjects:backBtn,nil];
    //    self.navItem.rightBarButtonItems = [NSArray arrayWithObjects:forward,backward,nil];
    
    //    [self.searchNavbar setItems:@[self.navItem]];
    
    //do something like background color, title, etc you self
    [self.DocumentViewController.view addSubview:self.searchNavbar];
    [self.DocumentViewController.documentView removeGestureRecognizer:self.pan];
}
- (void) onAnnot {
    [self.penPopoverController dismissPopoverAnimated:NO];
    [self.inkPopoverController dismissPopoverAnimated:NO];
    [self.eraserPopoverController dismissPopoverAnimated:NO];
    
    if(inkPopup && !activateNoteMode){
        inkPopup = NO;
        penPopup = NO;
        eraserPopup = NO;
        return;
    } else {
        inkPopup = YES;
        penPopup = NO;
        eraserPopup = NO;
    }
    
    [self releaseAnnotBtn];
    [self releaseSubViews];
    
    //    self.highlightBtn = [[UIButton alloc] initWithFrame: CGRectMake(26.42, 10, 30, 30)];
    //    [self.highlightBtn setImage:[UIImage imageNamed:@"viewer-icon/pan-icon-04.png"] forState:UIControlStateNormal];
    //    [self.highlightBtn addTarget: self action: @selector(onHighlight) forControlEvents: UIControlEventTouchUpInside];
    //    self.highlightBtn.tag = 7;
    //
    //    self.underlineBtn = [[UIButton alloc] initWithFrame: CGRectMake(82.84, 10, 30, 30)];
    //    [self.underlineBtn setImage:[UIImage imageNamed:@"viewer-icon/pan-icon-05.png"] forState:UIControlStateNormal];
    //    [self.underlineBtn addTarget: self action: @selector(onUnderline) forControlEvents: UIControlEventTouchUpInside];
    //    self.underlineBtn.tag = 8;
    //
    //    self.cancleBtn = [[UIButton alloc] initWithFrame: CGRectMake(139.26, 10, 30, 30)];
    //    [self.cancleBtn setImage:[UIImage imageNamed:@"viewer-icon/pan-icon-06.png"] forState:UIControlStateNormal];
    //    [self.cancleBtn addTarget: self action: @selector(onStrikeOut) forControlEvents: UIControlEventTouchUpInside];
    //    self.cancleBtn.tag = 9;
    //
    //    self.squareBtn = [[UIButton alloc] initWithFrame: CGRectMake(195.68, 10, 30, 30)];
    //    [self.squareBtn setImage:[UIImage imageNamed:@"viewer-icon/pan-icon-02.png"] forState:UIControlStateNormal];
    //    [self.squareBtn addTarget: self action: @selector(onSquare) forControlEvents: UIControlEventTouchUpInside];
    //    self.squareBtn.tag = 5;
    //
    //    self.circleBtn = [[UIButton alloc] initWithFrame: CGRectMake(252.1, 10, 30, 30)];
    //    [self.circleBtn setImage:[UIImage imageNamed:@"viewer-icon/pan-icon-03.png"] forState:UIControlStateNormal];
    //    [self.circleBtn addTarget: self action: @selector(onCircle) forControlEvents: UIControlEventTouchUpInside];
    //    self.circleBtn.tag = 6;
    //
    //    self.noteBtn = [[UIButton alloc] initWithFrame: CGRectMake(308.52, 10, 30, 30)];
    //    [self.noteBtn setImage:[UIImage imageNamed:@"viewer-icon/pan-icon-07.png"] forState:UIControlStateNormal];
    //    [self.noteBtn addTarget: self action: @selector(onMemo) forControlEvents: UIControlEventTouchUpInside];
    //    self.noteBtn.tag = 10;
    
    self.highlightBtn = [[UIButton alloc] initWithFrame: CGRectMake(35.83, 10, 30, 30)];
    [self.highlightBtn setImage:[UIImage imageNamed:@"viewer-icon/pan-icon-04.png"] forState:UIControlStateNormal];
    [self.highlightBtn addTarget: self action: @selector(onHighlight) forControlEvents: UIControlEventTouchUpInside];
    self.highlightBtn.tag = 7;
    
    self.underlineBtn = [[UIButton alloc] initWithFrame: CGRectMake(101.66, 10, 30, 30)];
    [self.underlineBtn setImage:[UIImage imageNamed:@"viewer-icon/pan-icon-05.png"] forState:UIControlStateNormal];
    [self.underlineBtn addTarget: self action: @selector(onUnderline) forControlEvents: UIControlEventTouchUpInside];
    self.underlineBtn.tag = 8;
    
    self.cancleBtn = [[UIButton alloc] initWithFrame: CGRectMake(167.49, 10, 30, 30)];
    [self.cancleBtn setImage:[UIImage imageNamed:@"viewer-icon/pan-icon-06.png"] forState:UIControlStateNormal];
    [self.cancleBtn addTarget: self action: @selector(onStrikeOut) forControlEvents: UIControlEventTouchUpInside];
    self.cancleBtn.tag = 9;
    
    self.squareBtn = [[UIButton alloc] initWithFrame: CGRectMake(228.32, 10, 30, 30)];
    [self.squareBtn setImage:[UIImage imageNamed:@"viewer-icon/pan-icon-02.png"] forState:UIControlStateNormal];
    [self.squareBtn addTarget: self action: @selector(onSquare) forControlEvents: UIControlEventTouchUpInside];
    self.squareBtn.tag = 5;
    
    self.circleBtn = [[UIButton alloc] initWithFrame: CGRectMake(294.15, 10, 30, 30)];
    [self.circleBtn setImage:[UIImage imageNamed:@"viewer-icon/pan-icon-03.png"] forState:UIControlStateNormal];
    [self.circleBtn addTarget: self action: @selector(onCircle) forControlEvents: UIControlEventTouchUpInside];
    self.circleBtn.tag = 6;
    
    self.noteBtn = [[UIButton alloc] initWithFrame: CGRectMake(308.52, 10, 30, 30)];
    [self.noteBtn setImage:[UIImage imageNamed:@"viewer-icon/pan-icon-07.png"] forState:UIControlStateNormal];
    [self.noteBtn addTarget: self action: @selector(onMemo) forControlEvents: UIControlEventTouchUpInside];
    self.noteBtn.tag = 10;
    
    // [self.inkPopoverView addSubview:self.inkBtn];
    [self.inkPopoverView addSubview:self.squareBtn];
    [self.inkPopoverView addSubview:self.circleBtn];
    [self.inkPopoverView addSubview:self.highlightBtn];
    [self.inkPopoverView addSubview:self.underlineBtn];
    [self.inkPopoverView addSubview:self.cancleBtn];
    //    [self.inkPopoverView addSubview:self.noteBtn];
    // [self.inkPopoverView addSubview:self.eraserBtn];
    
    self.inkPopoverContent.view = self.inkPopoverView;
    
    self.inkPopoverController = [[UIPopoverController alloc] initWithContentViewController:self.inkPopoverContent];
    self.inkPopoverController.delegate=self;
    
    self.inkPopoverController.backgroundColor = [UIColor colorWithRed:0.03 green:(0.14) blue:0.27 alpha:0.5];
    
    //        self.annotPopupView = [sender valueForKey:@"imageView"];
    self.annotPopupView = [self.inkButton valueForKey:@"imageView"];
    
    self.inkPopoverController.popoverContentSize = CGSizeMake(365, 50);
    [self.inkPopoverController presentPopoverFromRect:CGRectMake(CGRectGetWidth(self.annotPopupView.frame)/2, 30, 0, 0) inView:self.annotPopupView permittedArrowDirections:UIPopoverArrowDirectionUp animated:NO];
    
    if(activateNoteMode){
        if(firstOnTapUp){
            dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.1 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                [self.noteBtn sendActionsForControlEvents:UIControlEventTouchUpInside];
            });
        } else {
            [self.noteBtn sendActionsForControlEvents:UIControlEventTouchUpInside];
        }
    } else {
        if(inkMode == 1){
            [self.highlightBtn sendActionsForControlEvents:UIControlEventTouchUpInside];
        } else if (inkMode == 2){
            [self.underlineBtn sendActionsForControlEvents:UIControlEventTouchUpInside];
        } else if(inkMode == 3){
            [self.cancleBtn sendActionsForControlEvents:UIControlEventTouchUpInside];
        } else if(inkMode == 4){
            [self.squareBtn sendActionsForControlEvents:UIControlEventTouchUpInside];
        } else if(inkMode == 5){
            [self.circleBtn sendActionsForControlEvents:UIControlEventTouchUpInside];
        }
    }
    
    [self.DocumentViewController.documentView removeGestureRecognizer:self.pan];
}

//- (void) addBookmark {
//    //        UIImage *completeBMImage = [UIImage imageNamed:@"viewer-icon/check-01.png"];
//    //        UIButton *completeBMButton = [UIButton buttonWithType:UIButtonTypeCustom];
//    //        [completeBMButton setImage:completeBMImage forState:UIControlStateNormal];
//    //        completeBMButton.frame = CGRectMake(0.0, 3.0, 25,25);
//    //        [completeBMButton addTarget:self action:@selector(openPlugPDF:) forControlEvents:UIControlEventTouchUpInside];
//    //        completeBMButton.tag = 25;
//    //        UIBarButtonItem *completeBM = [[UIBarButtonItem alloc] initWithCustomView:completeBMButton];
//    //
//    //        self.BMnavItem.rightBarButtonItems = [NSArray arrayWithObjects:completeBM,nil];
//    //        [self.BMnavcon setItems:@[self.BMnavItem]];
//    //
//    //        EditMode = 1;
//    //        //we are not in edit mode yet
//    //        if([self.BMtableView isEditing] == NO){
//    //            //IMPORTANT:
//    //            //we are using a custom buttom to enter edit mode therefore we must
//    //            //call setEditing: manually.
//    //            //if we use apple's edit button, it will automatatically called method
//    //            //apple's EDIT BUTTON, could add in viewDidLoad: self.navigationItem.leftBarButtonItem = self.editButtonItem;
//    //            //            [self setEditing:YES];
//    //
//    //            //up the button so that the user knows to click it when they
//    //            //are done
//    //            //[self.editBtn setTitle:@"Done"];
//    //            //set the table to editing mode
//    //            [self.BMtableView setEditing:YES animated:YES];
//    //        }else{
//    //            //            [self setEditing:NO];
//    //            //we are currently in editing mode
//    //            //change the button text back to Edit
//    //            //[self.editBtn setTitle:@"Edit"];
//    //            //take the table out of edit mode
//    //            [self.BMtableView setEditing:NO animated:YES];
//    //        }
//    //
//    //        if((unsigned long)self.tabledata.count == 0){
//    NSNumber *currentPage = [NSNumber numberWithInteger:self.DocumentViewController.pageIdx+1];
//    //        [self.tabledata addObject:@"새 북마크"];
//    //        [self.pagedata addObject:[currentPage stringValue]];
//
//    int insertIndex = 0;
//    if(self.pagedata.count == 0) {
//        [self.tabledata addObject:@"새 북마크"];
//        [self.pagedata addObject:[currentPage stringValue]];
//    } else {
//        for (int i = 0; i < self.pagedata.count; i++) {
//            NSLog(@"%d, %d", (int)self.DocumentViewController.pageIdx+1, (int)[self.pagedata[i] integerValue]);
//            if(self.DocumentViewController.pageIdx+1 < (int)[self.pagedata[i] integerValue]){
//                [self.tabledata insertObject:@"새 북마크" atIndex:i];
//                [self.pagedata insertObject:[currentPage stringValue] atIndex:i];
//                break;
//            } else if(i == self.pagedata.count-1){
//                [self.tabledata addObject:@"새 북마크"];
//                [self.pagedata addObject:[currentPage stringValue]];
//                break;
//            }
//        }
//    }
//
//    NSMutableArray *arr = [[NSMutableArray alloc] init];
//    for (int i = 0; i < self.pagedata.count; i++) {
//        //            NSLog(@" i = %d", i);
//        NSLog(@"(long)[self.pagedata[i] integerValue] = %ld", (long)[self.pagedata[i] integerValue]);
//        PlugPDFOutlineItem* outlineItem = [[PlugPDFOutlineItem alloc] initWithParent:nil
//                                                                                 idx: i
//                                                                               title: self.tabledata[i]
//                                                                             pageIdx: (long)[self.pagedata[i] integerValue]-1
//                                                                               depth: 0];
//        [arr addObject: outlineItem];
//    }
//
//    NSLog(@"arr = %@", arr);
//
//    for (int i = 0; i < arr.count; i++){
//        PlugPDFOutlineItem* outline = arr[i];
//        [self.DocumentViewController.document removeOutlineItem:outline];
//    }
//
//    [self.DocumentViewController.document updatePdfOutlineTree: arr];
//
//
//    //        NSArray* testarr = [[NSArray alloc] initWithObjects:@"0", nil];
//
//    //        NSInteger getBMPage = self.DocumentViewController.pageIdx;
//    //        [self.DocumentViewController.document addOutlineItemWithTitle:@"새 북마크" pageIdx:getBMPage parent:nil after:nil];
//    //        [self.DocumentViewController.document updatePdfOutlineTree:testarr];
//
//    //        NSSortDescriptor *highestToLowest = [NSSortDescriptor sortDescriptorWithKey:@"self" ascending:YES];
//    //        [self.pagedata sortUsingDescriptors:[NSArray arrayWithObject:highestToLowest]];
//
//    [self.BMtableView reloadData];
//    EditMode = 3;
//    //            if([self.BMtableView isEditing] == NO){
//    //                //            [self setEditing:YES];
//    //                [self.BMtableView setEditing:YES animated:YES];
//    //            }else{
//    //                //            [self setEditing:NO];
//    //                [self.BMtableView setEditing:NO animated:YES];
//    //            }
//    //            UIImage *addBMImage = [UIImage imageNamed:@"viewer-icon/plus-01.png"];
//    //            UIButton *addBMButton = [UIButton buttonWithType:UIButtonTypeCustom];
//    //            [addBMButton setImage:addBMImage forState:UIControlStateNormal];
//    //            addBMButton.frame = CGRectMake(0.0, 3.0, 25,25);
//    //            [addBMButton addTarget:self action:@selector(openPlugPDF:) forControlEvents:UIControlEventTouchUpInside];
//    //            addBMButton.tag = 23;
//    //            UIBarButtonItem *addBM = [[UIBarButtonItem alloc] initWithCustomView:addBMButton];
//    //
//    //            UIImage *deleteBMImage = [UIImage imageNamed:@"viewer-icon/minus-01.png"];
//    //            UIButton *deleteBMButton = [UIButton buttonWithType:UIButtonTypeCustom];
//    //            [deleteBMButton setImage:deleteBMImage forState:UIControlStateNormal];
//    //            deleteBMButton.frame = CGRectMake(0.0, 3.0, 25,25);
//    //            [deleteBMButton addTarget:self action:@selector(openPlugPDF:) forControlEvents:UIControlEventTouchUpInside];
//    //            deleteBMButton.tag = 24;
//    //            UIBarButtonItem *delBM = [[UIBarButtonItem alloc] initWithCustomView:deleteBMButton];
//    //
//    //            self.BMnavItem.rightBarButtonItems = [NSArray arrayWithObjects:delBM,addBM,nil];
//    //            [self.BMnavcon setItems:@[self.BMnavItem]];
//    //        }
//    NSLog(@"%lu",(unsigned long)self.tabledata.count);
//    //        [popoverView addSubview:self.BMnavcon];
//}
//
//- (void) deleteBookmark {
//    EditMode = 2;
//    //we are not in edit mode yet
//    if([self.BMtableView isEditing] == NO){
//        //            [self setEditing:YES];
//        [self.BMtableView setEditing:YES animated:YES];
//    }else{
//        //            [self setEditing:NO];
//        [self.BMtableView setEditing:NO animated:YES];
//    }
//    UIImage *completeBMImage = [UIImage imageNamed:@"viewer-icon/check-01.png"];
//    UIButton *completeBMButton = [UIButton buttonWithType:UIButtonTypeCustom];
//    [completeBMButton setImage:completeBMImage forState:UIControlStateNormal];
//    completeBMButton.frame = CGRectMake(0.0, 3.0, 25,25);
//    [completeBMButton addTarget:self action:@selector(completeBookmark) forControlEvents:UIControlEventTouchUpInside];
//    completeBMButton.tag = 25;
//    UIBarButtonItem *completeBM = [[UIBarButtonItem alloc] initWithCustomView:completeBMButton];
//
//    self.BMnavItem.rightBarButtonItems = [NSArray arrayWithObjects:completeBM,nil];
//    [self.BMnavcon setItems:@[self.BMnavItem]];
//}
//
//- (void) completeBookmark {
//    EditMode = 3;
//    if([self.BMtableView isEditing] == NO){
//        //            [self setEditing:YES];
//        [self.BMtableView setEditing:YES animated:YES];
//    }else{
//        //            [self setEditing:NO];
//        [self.BMtableView setEditing:NO animated:YES];
//    }
//
//    UIImage *addBMImage = [UIImage imageNamed:@"viewer-icon/plus-01.png"];
//    UIButton *addBMButton = [UIButton buttonWithType:UIButtonTypeCustom];
//    [addBMButton setImage:addBMImage forState:UIControlStateNormal];
//    addBMButton.frame = CGRectMake(0.0, 3.0, 25,25);
//    [addBMButton addTarget:self action:@selector(addBookmark) forControlEvents:UIControlEventTouchUpInside];
//    addBMButton.tag = 23;
//    UIBarButtonItem *addBM = [[UIBarButtonItem alloc] initWithCustomView:addBMButton];
//
//    UIImage *deleteBMImage = [UIImage imageNamed:@"viewer-icon/minus-01.png"];
//    UIButton *deleteBMButton = [UIButton buttonWithType:UIButtonTypeCustom];
//    [deleteBMButton setImage:deleteBMImage forState:UIControlStateNormal];
//    deleteBMButton.frame = CGRectMake(0.0, 3.0, 25,25);
//    [deleteBMButton addTarget:self action:@selector(deleteBookmark) forControlEvents:UIControlEventTouchUpInside];
//    deleteBMButton.tag = 24;
//    UIBarButtonItem *delBM = [[UIBarButtonItem alloc] initWithCustomView:deleteBMButton];
//
//    self.BMnavItem.rightBarButtonItems = [NSArray arrayWithObjects:delBM,addBM,nil];
//    [self.BMnavcon setItems:@[self.BMnavItem]];
//}

- (void) onHand {
    [self.penPopoverController dismissPopoverAnimated:NO];
    [self.inkPopoverController dismissPopoverAnimated:NO];
    [self.eraserPopoverController dismissPopoverAnimated:NO];
    
    penPopup = NO;
    inkPopup = NO;
    eraserPopup = NO;
    
    [self.DocumentViewController releaseTools];
    self.DocumentViewController.toolOption = 0;
    //        [self.DocumentViewController releaseTool:PlugPDFEraserTool];
    [self releaseAnnots];
    
    [self.handButton setImage:[UIImage imageNamed:@"viewer-icon/hand-on.png"] forState:UIControlStateNormal];
    if(inkMode == 1) [self.inkButton setImage:[UIImage imageNamed:@"viewer-icon/pan-icon-04.png"] forState:UIControlStateNormal];
    else if(inkMode == 2) [self.inkButton setImage:[UIImage imageNamed:@"viewer-icon/pan-icon-05.png"] forState:UIControlStateNormal];
    else if(inkMode == 3) [self.inkButton setImage:[UIImage imageNamed:@"viewer-icon/pan-icon-06.png"] forState:UIControlStateNormal];
    else if(inkMode == 4) [self.inkButton setImage:[UIImage imageNamed:@"viewer-icon/pan-icon-02.png"] forState:UIControlStateNormal];
    else if(inkMode == 5) [self.inkButton setImage:[UIImage imageNamed:@"viewer-icon/pan-icon-03.png"] forState:UIControlStateNormal];
    
    [self.DocumentViewController.documentView addGestureRecognizer:self.longPress];
    [self.DocumentViewController.documentView removeGestureRecognizer:self.pan];
    
}

- (void)openPlugPDF: (id)sender {
    //    [self.DocumentViewController.documentView removeGestureRecognizer:self.pan];
    //    NSLog(@"%ld", (long)[sender tag]);
    //    if([sender tag] == 15){
    //        [self.DocumentViewController.documentView addGestureRecognizer:self.longPress];
    //        [self.DocumentViewController releaseTools];
    //        [self releaseAnnots];
    //
    //    } else if([sender tag] == 16){
    //
    //    } else if([sender tag] == 17){
    //        if(isRotate == YES){
    //            isRotate = NO;
    //            UIImage *rotateImage = [UIImage imageNamed:@"viewer-icon/top-icon-02-02.png"];
    //            [self.displayRotateButton setImage:rotateImage forState:UIControlStateNormal];
    //            [self.DocumentViewController setRotationLock:NO];
    //            [[NSUserDefaults standardUserDefaults] setValue:@"no" forKey:@"rotate"];
    //        } else {
    //            isRotate = YES;
    //            UIImage *rotateImage = [UIImage imageNamed:@"viewer-icon/top-icon-02-01.png"];
    //            [self.displayRotateButton setImage:rotateImage forState:UIControlStateNormal];
    //            [self.DocumentViewController setRotationLock:YES];
    //            [[NSUserDefaults standardUserDefaults] setValue:@"yes" forKey:@"rotate"];
    //        }
    //    } else if([sender tag] == 18){
    //
    //    } else if([sender tag] == 19){
    //
    //    } else if([sender tag] == 20){
    //
    //    } else if([sender tag] == 21){
    //
    //    }  else if([sender tag] == 23){
    //
    //    } else if([sender tag] == 24){
    //
    //
    //    } else if([sender tag] == 25){
    //
    //    } else if([sender tag] == 29){
    //
    //    }
}

-(void) addBookmark:(id)sender{
    NSNumber *currentPage = [NSNumber numberWithInteger:self.DocumentViewController.pageIdx+1];
    
    int insertIndex = 0;
    if(self.pagedata.count == 0) {
        [self.tabledata addObject:@"새 북마크"];
        [self.pagedata addObject:[currentPage stringValue]];
    } else {
        for (int i = 0; i < self.pagedata.count; i++) {
            NSLog(@"%d, %d", (int)self.DocumentViewController.pageIdx+1, (int)[self.pagedata[i] integerValue]);
            if(self.DocumentViewController.pageIdx+1 < (int)[self.pagedata[i] integerValue]){
                [self.tabledata insertObject:@"새 북마크" atIndex:i];
                [self.pagedata insertObject:[currentPage stringValue] atIndex:i];
                break;
            } else if(i == self.pagedata.count-1){
                [self.tabledata addObject:@"새 북마크"];
                [self.pagedata addObject:[currentPage stringValue]];
                break;
            }
        }
    }
    
    NSMutableArray *arr = [[NSMutableArray alloc] init];
    for (int i = 0; i < self.pagedata.count; i++) {
        NSLog(@"(long)[self.pagedata[i] integerValue] = %ld", (long)[self.pagedata[i] integerValue]);
        PlugPDFOutlineItem* outlineItem = [[PlugPDFOutlineItem alloc] initWithParent:nil
                                                                                 idx: i
                                                                               title: self.tabledata[i]
                                                                             pageIdx: (long)[self.pagedata[i] integerValue]-1
                                                                               depth: 0];
        [arr addObject: outlineItem];
    }
    
    NSLog(@"arr = %@", arr);
    
    for (int i = 0; i < arr.count; i++){
        PlugPDFOutlineItem* outline = arr[i];
        [self.DocumentViewController.document removeOutlineItem:outline];
    }
    
    [self.DocumentViewController.document updatePdfOutlineTree: arr];
    
    [self.BMtableView reloadData];
    EditMode = 3;
    
    NSLog(@"%lu",(unsigned long)self.tabledata.count);
}

-(void) deleteBookmark:(id)sender{
    EditMode = 2;
    //we are not in edit mode yet
    if([self.BMtableView isEditing] == NO){
        //            [self setEditing:YES];
        [self.BMtableView setEditing:YES animated:YES];
    }else{
        //            [self setEditing:NO];
        [self.BMtableView setEditing:NO animated:YES];
    }
    
    self.completeBMView = [[UIView alloc] initWithFrame:CGRectMake(250, 0, 40, 40)];
    UITapGestureRecognizer *completeBookmark = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(completeBookmark:)];
    [self.completeBMView addGestureRecognizer:completeBookmark];
    
    self.completeBMbtn = [[UIButton alloc] initWithFrame: CGRectMake(10, 10, 25, 25)];
    [self.completeBMbtn setImage:[UIImage imageNamed:@"viewer-icon/check-01.png"] forState:UIControlStateNormal];
    [self.completeBMbtn addTarget: self action: @selector(completeBookmark:) forControlEvents: UIControlEventTouchUpInside];
    [self.completeBMView addSubview:self.completeBMbtn];
    
    [self.addBMView removeFromSuperview];
    [self.deleteBMView removeFromSuperview];
    
    [self.BMpopoverView addSubview:self.completeBMView];
    
    //
    //    UIImage *completeBMImage = [UIImage imageNamed:@"viewer-icon/check-01.png"];
    //    UIButton *completeBMButton = [UIButton buttonWithType:UIButtonTypeCustom];
    //    [completeBMButton setImage:completeBMImage forState:UIControlStateNormal];
    //    completeBMButton.frame = CGRectMake(0.0, 3.0, 25,25);
    //    [completeBMButton addTarget:self action:@selector(openPlugPDF:) forControlEvents:UIControlEventTouchUpInside];
    //    completeBMButton.tag = 25;
    //    UIBarButtonItem *completeBM = [[UIBarButtonItem alloc] initWithCustomView:completeBMButton];
    
    //    self.BMnavItem.rightBarButtonItems = [NSArray arrayWithObjects:completeBM,nil];
    //    [self.BMnavcon setItems:@[self.BMnavItem]];
}

-(void) completeBookmark:(id)sender{
    EditMode = 3;
    if([self.BMtableView isEditing] == NO){
        //            [self setEditing:YES];
        [self.BMtableView setEditing:YES animated:YES];
    }else{
        //            [self setEditing:NO];
        [self.BMtableView setEditing:NO animated:YES];
    }
    
    self.addBMView = [[UIView alloc] initWithFrame:CGRectMake(210, 0, 40, 40)];
    UITapGestureRecognizer *addBookmark = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(addBookmark:)];
    [self.addBMView addGestureRecognizer:addBookmark];
    
    self.addBMbtn = [[UIButton alloc] initWithFrame: CGRectMake(10, 10, 25, 25)];
    [self.addBMbtn setImage:[UIImage imageNamed:@"viewer-icon/plus-01.png"] forState:UIControlStateNormal];
    [self.addBMbtn addTarget: self action: @selector(addBookmark:) forControlEvents: UIControlEventTouchUpInside];
    [self.addBMView addSubview:self.addBMbtn];
    
    
    self.deleteBMView = [[UIView alloc] initWithFrame:CGRectMake(250, 0, 40, 40)];
    UITapGestureRecognizer *deleteBookmark = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(deleteBookmark:)];
    [self.deleteBMView addGestureRecognizer:deleteBookmark];
    
    self.deleteBMbtn = [[UIButton alloc] initWithFrame: CGRectMake(10, 10, 25, 25)];
    [self.deleteBMbtn setImage:[UIImage imageNamed:@"viewer-icon/minus-01.png"] forState:UIControlStateNormal];
    [self.deleteBMbtn addTarget: self action: @selector(deleteBookmark:) forControlEvents: UIControlEventTouchUpInside];
    [self.deleteBMView addSubview:self.deleteBMbtn];
    
    [self.completeBMView removeFromSuperview];
    
    [self.BMpopoverView addSubview:self.addBMView];
    [self.BMpopoverView addSubview:self.deleteBMView];
}

-(void)cancelSearch: (id)sender{
    [self.DocumentViewController stopSearch];
    
    UsingSearch = NO;
    [self.DocumentViewController releaseTools];
    [self releaseAnnots];
    
    [self.DocumentViewController.documentView addGestureRecognizer:self.longPress];
    [self.DocumentViewController.documentView removeGestureRecognizer:self.pan];
    
    [self.searchNavbar removeFromSuperview];
    [self initNavigationBar];
    
    [self.hideView removeFromSuperview];
    [self.handView removeFromSuperview];
    [self.inkView removeFromSuperview];
    [self.eraserView removeFromSuperview];
    [self.penView removeFromSuperview];
    [self.searchView removeFromSuperview];
    [self.bookMarkView removeFromSuperview];
    [self.displayModeView removeFromSuperview];
    [self.saveView removeFromSuperview];

    if(self.DocumentViewController.modifyContentPermission || self.DocumentViewController.modifyAnnotPermission){
        [self.navbar addSubview:self.hideView];
        [self.navbar addSubview:self.handView];
        [self.navbar addSubview:self.inkView];
        [self.navbar addSubview:self.eraserView];
        [self.navbar addSubview:self.penView];
        [self.navbar addSubview:self.searchView];
        [self.navbar addSubview:self.bookMarkView];
        [self.navbar addSubview:self.displayModeView];
        [self.navbar addSubview:self.saveView];
        
        [self.searchView setFrame:CGRectMake(self.navbar.frame.size.width-240, 0, 40, 40)];
        [self.displayModeView setFrame:CGRectMake(self.navbar.frame.size.width-320, 0, 40, 40)];
    } else {
        [self.navbar addSubview:self.hideView];
        [self.navbar addSubview:self.handView];
        [self.navbar addSubview:self.searchView];
        [self.navbar addSubview:self.displayModeView];
        
        [self.searchView setFrame:CGRectMake(self.navbar.frame.size.width-120, 0, 40, 40)];
        [self.displayModeView setFrame:CGRectMake(self.navbar.frame.size.width-160, 0, 40, 40)];
        
        [self.handButton sendActionsForControlEvents:UIControlEventTouchUpInside];
    }
}

-(void)backSearch: (id)sender{
    [self.DocumentViewController search:self.searchBar.text pageIdx:self.DocumentViewController.pageIdx direction:PlugPDFDocumentSearchDirectionBackwardOnly];
}

-(void)forSearch: (id)sender{
    [self.DocumentViewController search:self.searchBar.text pageIdx:self.DocumentViewController.pageIdx direction:PlugPDFDocumentSearchDirectionForwardOnly];
}

- (void) horizontalMode {
    displayPopup = NO;
    isEbook = NO;
    displayHorizontal = YES;
    displayVertical = NO;
    NSLog(@"Horizontal Mode");
    
    //        if(self.DocumentViewController.pageIdx+1 == self.DocumentViewController.pageCount)
    //            [self.DocumentViewController gotoPage:self.DocumentViewController.pageIdx-1 fitToScreen:YES];
    
    int orientation = [[UIApplication sharedApplication] statusBarOrientation];
    CGFloat widthSize = CGRectGetWidth(self.window.frame);
    NSLog(@"%d", (int)orientation);
    if((int)orientation == 3 || (int)orientation == 4) {
        [self.DocumentViewController setEnablePageFlipEffect:NO];
    } else {
        [self.DocumentViewController setEnablePageFlipEffect:YES];
    }
    
    [self.DocumentViewController setDisplayMode:PlugPDFDocumentDisplayModeHorizontal];
    [self.displayPopoverController dismissPopoverAnimated:NO];
    [self.displayModeButton setImage:[UIImage imageNamed:@"viewer-icon/top-icon-03-01.png"] forState:UIControlStateNormal];
    [self.DocumentViewController refreshView];
}

- (void) verticalMode {
    displayPopup = NO;
    isEbook = NO;
    displayHorizontal = NO;
    displayVertical = YES;
    NSLog(@"Vertical Mode");
    [self.DocumentViewController setEnablePageFlipEffect:NO];
    [self.DocumentViewController setDisplayMode:PlugPDFDocumentDisplayModeVertical];
    [self.displayPopoverController dismissPopoverAnimated:NO];
    [self.displayModeButton setImage:[UIImage imageNamed:@"viewer-icon/top-icon-03-02.png"] forState:UIControlStateNormal];
    NSLog(@"page  = %ld", (long)self.DocumentViewController.pageIdx);
    [self.DocumentViewController refreshView];
}

- (void) ebookMode {
    displayPopup = NO;
    int orientation = [[UIApplication sharedApplication] statusBarOrientation];
    if((int)orientation != 3 && (int)orientation != 4){
        [self.displayPopoverController dismissPopoverAnimated:NO];
        UIAlertController * alert=   [UIAlertController
                                      alertControllerWithTitle:@"세로보기에서는 양면보기를 \n지원하지 않습니다."
                                      message:@""
                                      preferredStyle:UIAlertControllerStyleAlert];
        
        UIAlertAction* ok = [UIAlertAction
                             actionWithTitle:@"OK"
                             style:UIAlertActionStyleDefault
                             handler:^(UIAlertAction * action)
                             {
                                 [alert dismissViewControllerAnimated:YES completion:nil];
                             }];
        [alert addAction:ok];
        
        [self.AD.navigationController presentViewController:alert animated:YES completion:nil];
        
    } else {
        //            if(self.DocumentViewController.pageIdx+1 == self.DocumentViewController.pageCount)
        //                [self.DocumentViewController gotoPage:self.DocumentViewController.pageCount-2 fitToScreen:YES];
        
        if(displayHorizontal){
            if(self.DocumentViewController.pageCount == 1)
                [self.DocumentViewController setEnablePageFlipEffect:NO];
            else
                [self.DocumentViewController setEnablePageFlipEffect:YES];
        } else if (displayVertical){
            [self.DocumentViewController setDisplayMode:PlugPDFDocumentDisplayModeHorizontal];
            if(self.DocumentViewController.pageCount == 1)
                [self.DocumentViewController setEnablePageFlipEffect:NO];
            else
                [self.DocumentViewController setEnablePageFlipEffect:YES];
        } else {
            if(self.DocumentViewController.pageCount == 1)
                [self.DocumentViewController setEnablePageFlipEffect:NO];
            else
                [self.DocumentViewController setEnablePageFlipEffect:YES];
            [self.DocumentViewController setDisplayMode:PlugPDFDocumentDisplayModeHorizontal];
        }
        
        isEbook = YES;
        displayVertical = NO;
        displayHorizontal = NO;
        NSLog(@"EBook Mode");
        //            [self.DocumentViewController setDisplayMode:PlugPDFDocumentDisplayModeHorizontal];
        [self.DocumentViewController refreshView];
        //            [self.DocumentViewController setDisplayMode:PlugPDFDocumentDisplayModeEBook];
        [self.displayPopoverController dismissPopoverAnimated:NO];
        [self.displayModeButton setImage:[UIImage imageNamed:@"viewer-icon/top-icon-03-03.png"] forState:UIControlStateNormal];
    }
}

- (void) thumbnailMode {
    displayPopup = NO;
    CGFloat windowWidth = CGRectGetWidth(self.window.frame);
    if(windowWidth < 400){
        [self.displayPopoverController dismissPopoverAnimated:NO];
        UIAlertController * alert=   [UIAlertController
                                      alertControllerWithTitle:@"현재 모드에서는\n지원하지 않습니다."
                                      message:@""
                                      preferredStyle:UIAlertControllerStyleAlert];
        
        UIAlertAction* ok = [UIAlertAction
                             actionWithTitle:@"OK"
                             style:UIAlertActionStyleDefault
                             handler:^(UIAlertAction * action)
                             {
                                 [alert dismissViewControllerAnimated:YES completion:nil];
                             }];
        [alert addAction:ok];
        
        [self.AD.navigationController presentViewController:alert animated:YES completion:nil];
    } else {
        NSLog(@"Thumbnail Mode");
        [self.DocumentViewController setDisplayMode:PlugPDFDocumentDisplayModeThumbnail];
        [self.displayPopoverController dismissPopoverAnimated:NO];
        [self.displayModeButton setImage:[UIImage imageNamed:@"viewer-icon/top-icon-03-04.png"] forState:UIControlStateNormal];
        fromThumbnail = YES;
    }
}

- (void) onPen {
    fromOnTapUp = NO;
    
    [self.penPopoverController dismissPopoverAnimated:NO];
    [self.inkPopoverController dismissPopoverAnimated:NO];
    [self.eraserPopoverController dismissPopoverAnimated:NO];
    [self releaseSubViews];
    
    if(penPopup){
        penPopup = NO;
        eraserPopup = NO;
        inkPopup = NO;
        return;
    } else {
        penPopup = YES;
        eraserPopup = NO;
        inkPopup = NO;
    }
    
    self.penPopoverContent = [[UIViewController alloc] init]; //ViewController
    self.penPopoverView = [[UIView alloc] init];   //view
    
    [self.DocumentViewController.documentView removeGestureRecognizer:self.longPress];
    [self.DocumentViewController releaseTools];
    [self releaseAnnots];
    
    isAnnot = YES;
    UsingInk = YES;
    
    [self.inkBtn setImage:[UIImage imageNamed:@"viewer-icon/pan-icon-01-on.png"] forState:UIControlStateNormal];
    [self.handButton setImage:[UIImage imageNamed:@"viewer-icon/hand.png"] forState:UIControlStateNormal];
    
    if(inkMode == 1) [self.inkButton setImage:[UIImage imageNamed:@"viewer-icon/pan-icon-04.png"] forState:UIControlStateNormal];
    else if(inkMode == 2) [self.inkButton setImage:[UIImage imageNamed:@"viewer-icon/pan-icon-05.png"] forState:UIControlStateNormal];
    else if(inkMode == 3) [self.inkButton setImage:[UIImage imageNamed:@"viewer-icon/pan-icon-06.png"] forState:UIControlStateNormal];
    else if(inkMode == 4) [self.inkButton setImage:[UIImage imageNamed:@"viewer-icon/pan-icon-02.png"] forState:UIControlStateNormal];
    else if(inkMode == 5) [self.inkButton setImage:[UIImage imageNamed:@"viewer-icon/pan-icon-03.png"] forState:UIControlStateNormal];
    
    self.colorLabel = [[UILabel alloc] initWithFrame:CGRectMake(10, 5, 40, 40)];
    self.colorLabel.text = @"색상";
    self.colorLabel.textColor = [UIColor whiteColor];
    
    self.exampleInkColorView = [[UIView alloc] initWithFrame:CGRectMake(325, 15, 20, 20)];
    self.exampleInkColorView.backgroundColor = self.exampleInkColor;
    self.exampleInkColorView.layer.cornerRadius = 10;
    
    self.ColorPickerView = [[UIView alloc] initWithFrame:CGRectMake(10, 40, 345, 95)];
    self.ColorPickerView.backgroundColor = [UIColor colorWithRed:0.03 green:(0.14) blue:0.27 alpha:0];
    self.ColorPickerView.layer.cornerRadius = 3.0f;
    [self inputColorButton:@"ink"];
    
    self.opacityLabel = [[UILabel alloc] initWithFrame:CGRectMake(10, 150, 100, 40)];
    self.opacityLabel.textColor = [UIColor whiteColor];
    self.opacityLabel.text = [NSString stringWithFormat:@"투명도 %d%%",inkOpacityValue];
    
    self.opacityView = [[UIView alloc] initWithFrame:CGRectMake(10, 185, 345, 50)];
    self.opacityView.backgroundColor = [UIColor colorWithRed:0.03 green:(0.14) blue:0.27 alpha:0];
    self.opacityView.layer.cornerRadius = 3.0f;
    
    self.opacitySlider = [[UISlider alloc] initWithFrame:CGRectMake(5, 5, 335, 40)];
    [self.opacitySlider addTarget:self action:@selector(getInkOpacity:) forControlEvents:UIControlEventValueChanged];
    [self.opacitySlider setBackgroundColor:[UIColor clearColor]];
    self.opacitySlider.minimumValue = 10;
    self.opacitySlider.maximumValue = 100;
    self.opacitySlider.continuous = YES;
    self.opacitySlider.value = inkOpacityValue;
    [self.opacityView addSubview:self.opacitySlider];
    self.opacitySlider.minimumTrackTintColor = self.exampleInkColor;
    
    self.boldLabel = [[UILabel alloc] initWithFrame:CGRectMake(10, 260, 100, 40)];
    self.boldLabel.textColor = [UIColor whiteColor];
    NSString *widthText;
    
    if(inkBoldValue == 0.5) { widthText = @"굵기 1"; }
    else if(inkBoldValue == 1.0) { widthText = @"굵기 2"; }
    else if(inkBoldValue == 1.5) { widthText = @"굵기 3"; }
    else if(inkBoldValue == 2.0) { widthText = @"굵기 4"; }
    else if(inkBoldValue == 2.5) { widthText = @"굵기 5"; }
    else if(inkBoldValue == 3.0) { widthText = @"굵기 6"; }
    else if(inkBoldValue == 3.5) { widthText = @"굵기 7"; }
    else if(inkBoldValue == 4.0) { widthText = @"굵기 8"; }
    else if(inkBoldValue == 4.5) { widthText = @"굵기 9"; }
    else if(inkBoldValue == 5.0) { widthText = @"굵기 10"; }
    else if(inkBoldValue == 5.5) { widthText = @"굵기 11"; }
    else if(inkBoldValue == 6.0) { widthText = @"굵기 12"; }
    else if(inkBoldValue == 6.5) { widthText = @"굵기 13"; }
    else if(inkBoldValue == 7.0) { widthText = @"굵기 14"; }
    else if(inkBoldValue == 7.5) { widthText = @"굵기 15"; }
    else if(inkBoldValue == 8.0) { widthText = @"굵기 16"; }
    else if(inkBoldValue == 8.5) { widthText = @"굵기 17"; }
    else if(inkBoldValue == 9.0) { widthText = @"굵기 18"; }
    else if(inkBoldValue == 9.5) { widthText = @"굵기 19"; }
    else { widthText = @"굵기 20"; }
    self.boldLabel.text = [NSString stringWithFormat:@"%@",widthText];
    
    self.boldView = [[UIView alloc] initWithFrame:CGRectMake(10, 285, 345, 50)];
    self.boldView.backgroundColor = [UIColor colorWithRed:0.03 green:(0.14) blue:0.27 alpha:0];
    self.boldView.layer.cornerRadius = 3.0f;
    
    //        CGRect ovalRect = CGRectMake(0, 0, 460, 115);
    //        UIBezierPath* ovalPath = [UIBezierPath bezierPath];
    //        [ovalPath addArcWithCenter: CGPointMake(0, 0) radius: ovalRect.size.width / 2 startAngle: -22 * M_PI/180 endAngle: 21 * M_PI/180 clockwise: YES];
    //        [ovalPath addLineToPoint: CGPointMake(0, 0)];
    //        [ovalPath closePath];
    //
    //        CGAffineTransform ovalTransform = CGAffineTransformMakeTranslation(CGRectGetMidX(ovalRect), CGRectGetMidY(ovalRect));
    //        ovalTransform = CGAffineTransformScale(ovalTransform, 1, ovalRect.size.height / ovalRect.size.width);
    //        [ovalPath applyTransform: ovalTransform];
    //
    //        [UIColor.grayColor setFill];
    //        [ovalPath fill];
    //
    //        CAShapeLayer *layer = [CAShapeLayer layer];
    //        [layer setPath:[ovalPath CGPath]];
    //
    //        [self.boldView.layer addSublayer:layer];
    
    self.boldSlider = [[UISlider alloc] initWithFrame:CGRectMake(5, 5, 335, 40)];
    [self.boldSlider addTarget:self action:@selector(getInkBold:) forControlEvents:UIControlEventValueChanged];
    [self.boldSlider setBackgroundColor:[UIColor clearColor]];
    self.boldSlider.minimumValue = 0.5;
    self.boldSlider.maximumValue = 10.0;
    self.boldSlider.continuous = YES;
    self.boldSlider.value = inkBoldValue;
    self.boldSlider.minimumTrackTintColor = self.exampleInkColor;
    
    //        UIImage * sliderBarImage1 = [[UIImage imageNamed:@"viewer-icon/Canvas_1.png"] resizableImageWithCapInsets:UIEdgeInsetsMake(0, 10, 0, 10)];
    //        UIImage * sliderBarImage2 = [[UIImage imageNamed:@"viewer-icon/Canvas_2.png"] resizableImageWithCapInsets:UIEdgeInsetsMake(0, 10, 0, 10)];
    //
    ////        UIImage *sliderLeftTrackImage = [sliderBarImage1 stretchableImageWithLeftCapWidth: 9 topCapHeight: 0];
    ////        UIImage *sliderRightTrackImage = [sliderBarImage1 stretchableImageWithLeftCapWidth: 9 topCapHeight: 0];
    //
    //        [self.boldSlider setMinimumTrackImage:sliderBarImage1 forState:UIControlStateNormal];
    //        [self.boldSlider setMaximumTrackImage:sliderBarImage2 forState:UIControlStateNormal];
    
    // 슬라이더 thumb 사이즈 조절
    //        CGSize newSize = CGSizeMake(inkBoldValue+10, inkBoldValue+10);
    //        UIImage* image = self.boldSlider.currentThumbImage;
    //        UIGraphicsBeginImageContextWithOptions(newSize, NO, 0.0);
    //        [image drawInRect:CGRectMake(0, 0, newSize.width, newSize.height)];
    //        UIImage *newImage = UIGraphicsGetImageFromCurrentImageContext();
    //        UIGraphicsEndImageContext();
    //        [self.boldSlider setThumbImage:newImage forState:UIControlStateNormal];
    
    [self.boldView addSubview:self.boldSlider];
    
    //        [self.penPopoverView addSubview:self.lineView];
    [self.penPopoverView addSubview:self.colorLabel];
    [self.penPopoverView addSubview:self.exampleInkColorView];
    [self.penPopoverView addSubview:self.ColorPickerView];
    [self.penPopoverView addSubview:self.opacityLabel];
    [self.penPopoverView addSubview:self.opacityView];
    [self.penPopoverView addSubview:self.boldLabel];
    [self.penPopoverView addSubview:self.boldView];
    
    self.penPopoverContent.view = self.penPopoverView;
    
    self.penPopoverController = [[UIPopoverController alloc] initWithContentViewController:self.penPopoverContent];
    self.penPopoverController.delegate=self;
    self.penPopoverController.backgroundColor = [UIColor colorWithRed:0.03 green:(0.14) blue:0.27 alpha:0.5];
    
    //        UIView *view = [sender valueForKey:@"imageView"];
    UIView *view = [self.inkBtn valueForKey:@"imageView"];
    self.tmpView = view;
    
    self.penPopoverController.popoverContentSize = CGSizeMake(365, 365);
    [self.penPopoverController presentPopoverFromRect:CGRectMake(CGRectGetWidth(view.frame)/2, 40, 0, 0) inView:view permittedArrowDirections:UIPopoverArrowDirectionUp animated:YES];
    
    //        if(isEbook && (self.DocumentViewController.pageIdx+1 == self.DocumentViewController.pageCount) && self.DocumentViewController.pageCount%2 == 1){
    //            if(fromPageFlip){
    //                [self.DocumentViewController setTool:PlugPDFInkTool];
    //
    //            } else {
    //                [[self.DocumentViewController.documentView pageView:self.DocumentViewController.pageIdx-1] setTool:PlugPDFInkTool];
    //                [[self.DocumentViewController.documentView pageView:self.DocumentViewController.pageIdx] setTool:PlugPDFInkTool];
    //            }
    //            [self.DocumentViewController setTool:PlugPDFInkTool];
    //        } else {
    //        [self.DocumentViewController releaseTool:PlugPDFInkTool];
    [self.DocumentViewController setTool:PlugPDFInkTool];
    //        }
    
    CGFloat red;
    CGFloat green;
    CGFloat blue;
    CGFloat alpha = inkOpacityValue*0.01;
    CGFloat tmpAlpha;
    [self.exampleInkColor getRed:&red green:&green blue:&blue alpha:&tmpAlpha];
    [self.DocumentViewController setInkToolLineColor:[UIColor colorWithRed:red green:green blue:blue alpha:alpha]];
    [self.DocumentViewController setInkToolLineWidth:inkBoldValue];
    
    //        UITapGestureRecognizer *aaaa = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(aaaa:)];
    //        [self.penPopoverView addGestureRecognizer:aaaa];
    
    self.penPopoverController.passthroughViews = self.viewArray;
    
    [self.DocumentViewController.documentView removeGestureRecognizer:self.pan];
    NSLog(@"inkmode = %d", inkMode);
}

- (void) onSquare {
    fromOnTapUp = NO;
    inkMode = 4;
    [[NSUserDefaults standardUserDefaults] setInteger:inkMode forKey:@"inkMode"];
    
    [self.DocumentViewController.documentView removeGestureRecognizer:self.longPress];
    [self releaseAnnots];
    [self releaseSubViews];
    isAnnot = YES;
    UsingSquare = YES;
    
    [self.squareBtn setImage:[UIImage imageNamed:@"viewer-icon/pan-icon-02-on.png"] forState:UIControlStateNormal];
    [self.handButton setImage:[UIImage imageNamed:@"viewer-icon/hand.png"] forState:UIControlStateNormal];
    [self.eraserBtn setImage:[UIImage imageNamed:@"viewer-icon/pan-icon-08.png"] forState:UIControlStateNormal];
    [self.inkBtn setImage:[UIImage imageNamed:@"viewer-icon/pan-icon-01.png"] forState:UIControlStateNormal];
    [self.inkButton setImage:[UIImage imageNamed:@"viewer-icon/pan-icon-02-on.png"] forState:UIControlStateNormal];
    
    self.lineView = [[UIView alloc] initWithFrame:CGRectMake(0,55, self.window.frame.size.width, 2)];
    self.lineView.backgroundColor = [UIColor colorWithRed:0.09 green:(0.20) blue:0.35 alpha:1.00];
    
    self.colorLabel = [[UILabel alloc] initWithFrame:CGRectMake(10, 60, 100, 40)];
    self.colorLabel.text = @"채우기";
    self.colorLabel.textColor = [UIColor whiteColor];
    
    self.exampleColorView = [[UIView alloc] initWithFrame:CGRectMake(325, 70, 20, 20)];
    self.exampleColorView.backgroundColor = self.exampleSquareColor;
    self.exampleColorView.layer.cornerRadius = 10;
    
    self.ColorPickerView = [[UIView alloc] initWithFrame:CGRectMake(10, 95, 345, 95)];
    self.ColorPickerView.backgroundColor = [UIColor colorWithRed:0.83 green:0.88 blue:1.00 alpha:0];
    self.ColorPickerView.layer.cornerRadius = 3.0f;
    [self inputColorButton:@"square"];
    
    self.secondLineView = [[UIView alloc] initWithFrame:CGRectMake(20, 200, 330, 2)];
    self.secondLineView.backgroundColor = self.exampleSquareColor;
    
    self.squareColorLabel = [[UILabel alloc] initWithFrame:CGRectMake(10, 215, 100, 40)];
    self.squareColorLabel.text = @"선 색상";
    self.squareColorLabel.textColor = [UIColor whiteColor];
    
    self.exampleSquareCornerColorView = [[UIView alloc] initWithFrame:CGRectMake(325, 225, 20, 20)];
    self.exampleSquareCornerColorView.backgroundColor = self.exampleSquareCornerColor;
    self.exampleSquareCornerColorView.layer.cornerRadius = 10;
    
    self.squareColorPickerView = [[UIView alloc] initWithFrame:CGRectMake(10, 250, 345, 95)];
    self.squareColorPickerView.backgroundColor = [UIColor colorWithRed:0.83 green:0.88 blue:1.00 alpha:0];
    self.squareColorPickerView.layer.cornerRadius = 3.0f;
    [self inputColorButton:@"squareCorner"];
    
    self.boldLabel = [[UILabel alloc] initWithFrame:CGRectMake(10, 345, 100, 40)];
    self.boldLabel.textColor = [UIColor whiteColor];
    self.boldLabel.text = [NSString stringWithFormat:@"선 굵기 %d",squareBoldValue];
    
    self.boldView = [[UIView alloc] initWithFrame:CGRectMake(10, 375, 345, 50)];
    self.boldView.backgroundColor = [UIColor colorWithRed:0.83 green:0.88 blue:1.00 alpha:0];
    self.boldView.layer.cornerRadius = 3.0f;
    
    self.boldSlider = [[UISlider alloc] initWithFrame:CGRectMake(5, 5, 335, 40)];
    [self.boldSlider addTarget:self action:@selector(getSquareBold:) forControlEvents:UIControlEventValueChanged];
    [self.boldSlider setBackgroundColor:[UIColor clearColor]];
    self.boldSlider.minimumValue = 1;
    self.boldSlider.maximumValue = 40;
    self.boldSlider.continuous = YES;
    self.boldSlider.value = squareBoldValue;
    [self.boldView addSubview:self.boldSlider];
    self.boldSlider.minimumTrackTintColor = self.exampleSquareCornerColor;
    
    [self.inkPopoverView addSubview:self.lineView];
    [self.inkPopoverView addSubview:self.secondLineView];
    [self.inkPopoverView addSubview:self.colorLabel];
    [self.inkPopoverView addSubview:self.ColorPickerView];
    [self.inkPopoverView addSubview:self.exampleColorView];
    [self.inkPopoverView addSubview:self.squareColorLabel];
    [self.inkPopoverView addSubview:self.squareColorPickerView];
    [self.inkPopoverView addSubview:self.exampleSquareCornerColorView];
    [self.inkPopoverView addSubview:self.boldLabel];
    [self.inkPopoverView addSubview:self.boldView];
    
    self.inkPopoverController.popoverContentSize = CGSizeMake(365, 435);
    [self.inkPopoverController presentPopoverFromRect:CGRectMake(CGRectGetWidth(self.annotPopupView.frame)/2, 30, 0, 0) inView:self.annotPopupView permittedArrowDirections:UIPopoverArrowDirectionUp animated:YES];
    
    if(isEbook){
        if(self.DocumentViewController.pageIdx+1 == self.DocumentViewController.pageCount){
            [self.DocumentViewController setTool:PlugPDFSquareTool];
        }
    }
    //        if(isEbook && (self.DocumentViewController.pageIdx+1 == self.DocumentViewController.pageCount) && self.DocumentViewController.pageCount%2 == 1){
    //            if(fromPageFlip){
    //                [self.DocumentViewController setTool:PlugPDFSquareTool];
    //
    //            } else {
    //                [[self.DocumentViewController.documentView pageView:self.DocumentViewController.pageIdx-1] setTool:PlugPDFSquareTool];
    //                [[self.DocumentViewController.documentView pageView:self.DocumentViewController.pageIdx] setTool:PlugPDFSquareTool];
    //            }
    //            [self.DocumentViewController setTool:PlugPDFSquareTool];
    //        } else {
    [self.DocumentViewController setTool:PlugPDFSquareTool];
    //        }
    [self.DocumentViewController setShapeWidth:squareBoldValue];
    [self.DocumentViewController setSquareAnnotColor:self.exampleSquareColor];
    [self.DocumentViewController setShapeColor:self.exampleSquareCornerColor];
    [self.DocumentViewController setSquareAnnotOpacity:1.0];
    if([[UIColor clearColor] isEqual:self.exampleSquareColor]){
        [self.DocumentViewController setSquareAnnotTransparent:YES];
    } else {
        [self.DocumentViewController setSquareAnnotTransparent:NO];
    }
    self.inkPopoverController.passthroughViews = self.viewArray;
}

- (void) onCircle {
    fromOnTapUp = NO;
    inkMode = 5;
    [[NSUserDefaults standardUserDefaults] setInteger:inkMode forKey:@"inkMode"];
    
    [self.DocumentViewController.documentView removeGestureRecognizer:self.longPress];
    [self releaseAnnots];
    [self releaseSubViews];
    isAnnot = YES;
    UsingCircle = YES;
    
    [self.circleBtn setImage:[UIImage imageNamed:@"viewer-icon/pan-icon-03-on.png"] forState:UIControlStateNormal];
    [self.handButton setImage:[UIImage imageNamed:@"viewer-icon/hand.png"] forState:UIControlStateNormal];
    [self.eraserBtn setImage:[UIImage imageNamed:@"viewer-icon/pan-icon-08.png"] forState:UIControlStateNormal];
    [self.inkBtn setImage:[UIImage imageNamed:@"viewer-icon/pan-icon-01.png"] forState:UIControlStateNormal];
    [self.inkButton setImage:[UIImage imageNamed:@"viewer-icon/pan-icon-03-on.png"] forState:UIControlStateNormal];
    
    self.lineView = [[UIView alloc] initWithFrame:CGRectMake(0,55, self.window.frame.size.width, 2)];
    self.lineView.backgroundColor = [UIColor colorWithRed:0.09 green:(0.20) blue:0.35 alpha:1.0];
    
    self.colorLabel = [[UILabel alloc] initWithFrame:CGRectMake(10, 60, 100, 40)];
    self.colorLabel.text = @"채우기";
    self.colorLabel.textColor = [UIColor whiteColor];
    
    self.exampleColorView = [[UIView alloc] initWithFrame:CGRectMake(325, 70, 20, 20)];
    self.exampleColorView.backgroundColor = self.exampleCircleColor;
    self.exampleColorView.layer.cornerRadius = 10;
    
    self.ColorPickerView = [[UIView alloc] initWithFrame:CGRectMake(10, 95, 345, 95)];
    self.ColorPickerView.backgroundColor = [UIColor colorWithRed:0.83 green:0.88 blue:1.00 alpha:0];
    self.ColorPickerView.layer.cornerRadius = 3.0f;
    [self inputColorButton:@"circle"];
    
    self.secondLineView = [[UIView alloc] initWithFrame:CGRectMake(20, 200, 330, 2)];
    self.secondLineView.backgroundColor = self.exampleCircleColor;
    
    self.circleColorLabel = [[UILabel alloc] initWithFrame:CGRectMake(10, 215, 100, 40)];
    self.circleColorLabel.text = @"선 색상";
    self.circleColorLabel.textColor = [UIColor whiteColor];
    
    self.exampleCircleCornerColorView = [[UIView alloc] initWithFrame:CGRectMake(325, 225, 20, 20)];
    self.exampleCircleCornerColorView.backgroundColor = self.exampleCircleCornerColor;
    self.exampleCircleCornerColorView.layer.cornerRadius = 10;
    
    self.circleColorPickerView = [[UIView alloc] initWithFrame:CGRectMake(10, 250, 345, 95)];
    self.circleColorPickerView.backgroundColor = [UIColor colorWithRed:0.83 green:0.88 blue:1.00 alpha:0];
    self.circleColorPickerView.layer.cornerRadius = 3.0f;
    [self inputColorButton:@"circleCorner"];
    
    self.boldLabel = [[UILabel alloc] initWithFrame:CGRectMake(10, 345, 100, 40)];
    self.boldLabel.textColor = [UIColor whiteColor];
    self.boldLabel.text = [NSString stringWithFormat:@"선 굵기 %d",circleBoldValue];
    
    self.boldView = [[UIView alloc] initWithFrame:CGRectMake(10, 375, 345, 50)];
    self.boldView.backgroundColor = [UIColor colorWithRed:0.83 green:0.88 blue:1.00 alpha:0];
    self.boldView.layer.cornerRadius = 3.0f;
    
    self.boldSlider = [[UISlider alloc] initWithFrame:CGRectMake(5, 5, 335, 40)];
    [self.boldSlider addTarget:self action:@selector(getCircleBold:) forControlEvents:UIControlEventValueChanged];
    [self.boldSlider setBackgroundColor:[UIColor clearColor]];
    self.boldSlider.minimumValue = 1;
    self.boldSlider.maximumValue = 40;
    self.boldSlider.continuous = YES;
    self.boldSlider.value = circleBoldValue;
    [self.boldView addSubview:self.boldSlider];
    self.boldSlider.minimumTrackTintColor = self.exampleCircleCornerColor;
    
    [self.inkPopoverView addSubview:self.lineView];
    [self.inkPopoverView addSubview:self.secondLineView];
    [self.inkPopoverView addSubview:self.colorLabel];
    [self.inkPopoverView addSubview:self.ColorPickerView];
    [self.inkPopoverView addSubview:self.exampleColorView];
    [self.inkPopoverView addSubview:self.circleColorLabel];
    [self.inkPopoverView addSubview:self.circleColorPickerView];
    [self.inkPopoverView addSubview:self.exampleCircleCornerColorView];
    [self.inkPopoverView addSubview:self.boldLabel];
    [self.inkPopoverView addSubview:self.boldView];
    
    self.inkPopoverController.popoverContentSize = CGSizeMake(365, 435);
    [self.inkPopoverController presentPopoverFromRect:CGRectMake(CGRectGetWidth(self.annotPopupView.frame)/2, 30, 0, 0) inView:self.annotPopupView permittedArrowDirections:UIPopoverArrowDirectionUp animated:YES];
    
    //        if(isEbook && (self.DocumentViewController.pageIdx+1 == self.DocumentViewController.pageCount) && self.DocumentViewController.pageCount%2 == 1){
    //            if(fromPageFlip){
    //                [self.DocumentViewController setTool:PlugPDFCircleTool];
    //
    //            } else {
    //                [[self.DocumentViewController.documentView pageView:self.DocumentViewController.pageIdx-1] setTool:PlugPDFCircleTool];
    //                [[self.DocumentViewController.documentView pageView:self.DocumentViewController.pageIdx] setTool:PlugPDFCircleTool];
    //            }
    //            [self.DocumentViewController setTool:PlugPDFCircleTool];
    //        } else {
    [self.DocumentViewController setTool:PlugPDFCircleTool];
    //        }
    [self.DocumentViewController setShapeWidth:circleBoldValue];
    [self.DocumentViewController setCircleAnnotColor:self.exampleCircleColor];
    [self.DocumentViewController setShapeColor:self.exampleCircleCornerColor];
    [self.DocumentViewController setCircleAnnotOpacity:1.0];
    if([[UIColor clearColor] isEqual:self.exampleCircleColor]){
        [self.DocumentViewController setCircleAnnotTransparent:YES];
    } else {
        [self.DocumentViewController setCircleAnnotTransparent:NO];
    }
    self.inkPopoverController.passthroughViews = self.viewArray;
}

- (void) onHighlight {
    fromOnTapUp = NO;
    [self.DocumentViewController.documentView removeGestureRecognizer:self.longPress];
    [self releaseAnnots];
    [self releaseSubViews];
    isAnnot = YES;
    UsingHighlight = YES;
    inkMode = 1;
    [[NSUserDefaults standardUserDefaults] setInteger:inkMode forKey:@"inkMode"];
    
    [self.highlightBtn setImage:[UIImage imageNamed:@"viewer-icon/pan-icon-04-on.png"] forState:UIControlStateNormal];
    [self.handButton setImage:[UIImage imageNamed:@"viewer-icon/hand.png"] forState:UIControlStateNormal];
    [self.eraserBtn setImage:[UIImage imageNamed:@"viewer-icon/pan-icon-08.png"] forState:UIControlStateNormal];
    [self.inkBtn setImage:[UIImage imageNamed:@"viewer-icon/pan-icon-01.png"] forState:UIControlStateNormal];
    [self.inkButton setImage:[UIImage imageNamed:@"viewer-icon/pan-icon-04-on.png"] forState:UIControlStateNormal];
    
    self.lineView = [[UIView alloc] initWithFrame:CGRectMake(0,55, self.window.frame.size.width, 2)];
    self.lineView.backgroundColor = [UIColor colorWithRed:0.09 green:(0.20) blue:0.35 alpha:1.00];
    
    self.colorLabel = [[UILabel alloc] initWithFrame:CGRectMake(10, 60, 40, 40)];
    self.colorLabel.text = @"색상";
    self.colorLabel.textColor = [UIColor whiteColor];
    
    self.exampleHighlightColorView = [[UIView alloc] initWithFrame:CGRectMake(325, 70, 20, 20)];
    self.exampleHighlightColorView.backgroundColor = self.exampleHighlightColor;
    self.exampleHighlightColorView.layer.cornerRadius = 10;
    
    self.ColorPickerView = [[UIView alloc] initWithFrame:CGRectMake(10, 95, 345, 95)];
    self.ColorPickerView.backgroundColor = [UIColor colorWithRed:0.83 green:0.88 blue:1.00 alpha:0];
    self.ColorPickerView.layer.cornerRadius = 3.0f;
    [self inputColorButton:@"highlight"];
    
    self.opacityLabel = [[UILabel alloc] initWithFrame:CGRectMake(10, 205, 100, 40)];
    self.opacityLabel.textColor = [UIColor whiteColor];
    self.opacityLabel.text = [NSString stringWithFormat:@"투명도 %d%%",highlightOpacityValue];
    
    self.opacityView = [[UIView alloc] initWithFrame:CGRectMake(10, 240, 345, 50)];
    self.opacityView.backgroundColor = [UIColor colorWithRed:0.83 green:0.88 blue:1.00 alpha:0];
    self.opacityView.layer.cornerRadius = 3.0f;
    
    self.opacitySlider = [[UISlider alloc] initWithFrame:CGRectMake(5, 5, 335, 40)];
    [self.opacitySlider addTarget:self action:@selector(getHighlightOpacity:) forControlEvents:UIControlEventValueChanged];
    [self.opacitySlider setBackgroundColor:[UIColor clearColor]];
    self.opacitySlider.minimumValue = 10;
    self.opacitySlider.maximumValue = 100;
    self.opacitySlider.continuous = YES;
    self.opacitySlider.value = highlightOpacityValue;
    [self.opacityView addSubview:self.opacitySlider];
    self.opacitySlider.minimumTrackTintColor = self.exampleHighlightColor;
    
    [self.inkPopoverView addSubview:self.lineView];
    [self.inkPopoverView addSubview:self.colorLabel];
    [self.inkPopoverView addSubview:self.exampleHighlightColorView];
    [self.inkPopoverView addSubview:self.ColorPickerView];
    [self.inkPopoverView addSubview:self.opacityLabel];
    [self.inkPopoverView addSubview:self.opacityView];
    
    self.inkPopoverController.popoverContentSize = CGSizeMake(365, 300);
    [self.inkPopoverController presentPopoverFromRect:CGRectMake(CGRectGetWidth(self.annotPopupView.frame)/2, 30, 0, 0) inView:self.annotPopupView permittedArrowDirections:UIPopoverArrowDirectionUp animated:YES];
    
    //        if(isEbook && (self.DocumentViewController.pageIdx+1 == self.DocumentViewController.pageCount) && self.DocumentViewController.pageCount%2 == 1){
    //            if(fromPageFlip){
    //                [self.DocumentViewController setTool:PlugPDFTextHighlightTool];
    //
    //            } else {
    //                [[self.DocumentViewController.documentView pageView:self.DocumentViewController.pageIdx-1] setTool:PlugPDFTextHighlightTool];
    //                [[self.DocumentViewController.documentView pageView:self.DocumentViewController.pageIdx] setTool:PlugPDFTextHighlightTool];
    //            }
    //            [self.DocumentViewController setTool:PlugPDFTextHighlightTool];
    //        } else {
    [self.DocumentViewController setTool:PlugPDFTextHighlightTool];
    //        }
    [self.DocumentViewController setTextHighlightToolColor:self.exampleHighlightColor];
    self.inkPopoverController.passthroughViews = self.viewArray;
}

- (void) onUnderline {
    fromOnTapUp = NO;
    [self.DocumentViewController.documentView removeGestureRecognizer:self.longPress];
    [self releaseAnnots];
    [self releaseSubViews];
    isAnnot = YES;
    UsingUnderline = YES;
    inkMode = 2;
    [[NSUserDefaults standardUserDefaults] setInteger:inkMode forKey:@"inkMode"];
    
    [self.underlineBtn setImage:[UIImage imageNamed:@"viewer-icon/pan-icon-05-on.png"] forState:UIControlStateNormal];
    [self.handButton setImage:[UIImage imageNamed:@"viewer-icon/hand.png"] forState:UIControlStateNormal];
    [self.eraserBtn setImage:[UIImage imageNamed:@"viewer-icon/pan-icon-08.png"] forState:UIControlStateNormal];
    [self.inkBtn setImage:[UIImage imageNamed:@"viewer-icon/pan-icon-01.png"] forState:UIControlStateNormal];
    [self.inkButton setImage:[UIImage imageNamed:@"viewer-icon/pan-icon-05-on.png"] forState:UIControlStateNormal];
    
    self.lineView = [[UIView alloc] initWithFrame:CGRectMake(0,55, self.window.frame.size.width, 2)];
    self.lineView.backgroundColor = [UIColor colorWithRed:0.09 green:(0.20) blue:0.35 alpha:1.00];
    
    self.colorLabel = [[UILabel alloc] initWithFrame:CGRectMake(10, 60, 40, 40)];
    self.colorLabel.text = @"색상";
    self.colorLabel.textColor = [UIColor whiteColor];
    
    self.exampleUnderlineColorView = [[UIView alloc] initWithFrame:CGRectMake(325, 70, 20, 20)];
    self.exampleUnderlineColorView.backgroundColor = self.exampleUnderlineColor;
    self.exampleUnderlineColorView.layer.cornerRadius = 10;
    
    self.ColorPickerView = [[UIView alloc] initWithFrame:CGRectMake(10, 95, 345, 95)];
    self.ColorPickerView.backgroundColor = [UIColor colorWithRed:0.83 green:0.88 blue:1.00 alpha:0];
    self.ColorPickerView.layer.cornerRadius = 3.0f;
    [self inputColorButton:@"underline"];
    
    self.secondLineView = [[UIView alloc] initWithFrame:CGRectMake(20, 200, 330, 2)];
    self.secondLineView.backgroundColor = self.exampleUnderlineColor;
    
    self.underLineLabel = [[UILabel alloc] initWithFrame:CGRectMake(10, 245, 100, 40)];
    self.underLineLabel.textColor = [UIColor whiteColor];
    self.underLineLabel.text = [NSString stringWithFormat:@"물결 무늬"];
    
    self.underLineView = [[UIView alloc] initWithFrame:CGRectMake(10, 240, 345, 50)];
    self.underLineView.backgroundColor = [UIColor colorWithRed:0.83 green:0.88 blue:1.00 alpha:0];
    self.underLineView.layer.cornerRadius = 3.0f;
    
    self.underLineUseLabel = [[UILabel alloc] initWithFrame:CGRectMake(70, 10, 100, 30)];
    if(useUnderline == 0){
        self.underLineUseLabel.textColor = [UIColor whiteColor];
        self.underLineUseLabel.text = [NSString stringWithFormat:@"사용 안함"];
    } else if(useUnderline == 1){
        self.underLineUseLabel.textColor = [UIColor colorWithRed:0.08 green:0.46 blue:0.98 alpha:1.00];
        self.underLineUseLabel.text = [NSString stringWithFormat:@"사용"];
    }
    
    self.underLineSwitch = [[UISwitch alloc] initWithFrame:CGRectMake(275, 10, 60, 30)];
    
    [self.underLineSwitch addTarget: self action: @selector(getUnderLineSwitch:) forControlEvents:UIControlEventValueChanged];
    
    [self.underLineView addSubview:self.underLineUseLabel];
    [self.underLineView addSubview:self.underLineSwitch];
    
    [self.inkPopoverView addSubview:self.lineView];
    [self.inkPopoverView addSubview:self.secondLineView];
    [self.inkPopoverView addSubview:self.colorLabel];
    [self.inkPopoverView addSubview:self.exampleUnderlineColorView];
    [self.inkPopoverView addSubview:self.ColorPickerView];
    [self.inkPopoverView addSubview:self.underLineLabel];
    [self.inkPopoverView addSubview:self.underLineView];
    
    self.inkPopoverController.popoverContentSize = CGSizeMake(365, 300);
    [self.inkPopoverController presentPopoverFromRect:CGRectMake(CGRectGetWidth(self.annotPopupView.frame)/2, 30, 0, 0) inView:self.annotPopupView permittedArrowDirections:UIPopoverArrowDirectionUp animated:YES];
    
    //        if(isEbook && (self.DocumentViewController.pageIdx+1 == self.DocumentViewController.pageCount) && self.DocumentViewController.pageCount%2 == 1){
    //            if(fromPageFlip){
    //                [self.DocumentViewController setTool:PlugPDFTextUnderlineTool];
    //
    //            } else {
    //                [[self.DocumentViewController.documentView pageView:self.DocumentViewController.pageIdx-1] setTool:PlugPDFTextUnderlineTool];
    //                [[self.DocumentViewController.documentView pageView:self.DocumentViewController.pageIdx] setTool:PlugPDFTextUnderlineTool];
    //            }
    //            [self.DocumentViewController setTool:PlugPDFTextUnderlineTool];
    //        } else {
    [self.DocumentViewController setTool:PlugPDFTextUnderlineTool];
    //        }
    [self.DocumentViewController setTextUnderlineToolColor:self.exampleUnderlineColor];
    if(useUnderline == 0){
        [self.underLineSwitch setOn:NO];
        [self.DocumentViewController setTextUnderlineToolSquiggly:NO];
    } else if(useUnderline == 1){
        [self.underLineSwitch setOn:YES];
        [self.DocumentViewController setTextUnderlineToolSquiggly:YES];
    }
    self.inkPopoverController.passthroughViews = self.viewArray;
}

- (void) onStrikeOut {
    fromOnTapUp = NO;
    [self.DocumentViewController.documentView removeGestureRecognizer:self.longPress];
    [self releaseAnnots];
    [self releaseSubViews];
    isAnnot = YES;
    UsingCancle = YES;
    inkMode = 3;
    [[NSUserDefaults standardUserDefaults] setInteger:inkMode forKey:@"inkMode"];
    
    [self.cancleBtn setImage:[UIImage imageNamed:@"viewer-icon/pan-icon-06-on.png"] forState:UIControlStateNormal];
    [self.handButton setImage:[UIImage imageNamed:@"viewer-icon/hand.png"] forState:UIControlStateNormal];
    [self.eraserBtn setImage:[UIImage imageNamed:@"viewer-icon/pan-icon-08.png"] forState:UIControlStateNormal];
    [self.inkBtn setImage:[UIImage imageNamed:@"viewer-icon/pan-icon-01.png"] forState:UIControlStateNormal];
    [self.inkButton setImage:[UIImage imageNamed:@"viewer-icon/pan-icon-06-on.png"] forState:UIControlStateNormal];
    
    self.lineView = [[UIView alloc] initWithFrame:CGRectMake(0,55, self.window.frame.size.width, 2)];
    self.lineView.backgroundColor = [UIColor colorWithRed:0.09 green:(0.20) blue:0.35 alpha:1.00];
    
    self.colorLabel = [[UILabel alloc] initWithFrame:CGRectMake(10, 60, 40, 40)];
    self.colorLabel.text = @"색상";
    self.colorLabel.textColor = [UIColor whiteColor];
    
    self.exampleCanclelineColorView = [[UIView alloc] initWithFrame:CGRectMake(325, 70, 20, 20)];
    self.exampleCanclelineColorView.backgroundColor = self.exampleCanclelineColor;
    self.exampleCanclelineColorView.layer.cornerRadius = 10;
    
    self.ColorPickerView = [[UIView alloc] initWithFrame:CGRectMake(10, 95, 345, 95)];
    self.ColorPickerView.backgroundColor = [UIColor colorWithRed:0.83 green:0.88 blue:1.00 alpha:0];
    self.ColorPickerView.layer.cornerRadius = 3.0f;
    [self inputColorButton:@"cancleline"];
    
    self.secondLineView = [[UIView alloc] initWithFrame:CGRectMake(20, 200, 330, 2)];
    self.secondLineView.backgroundColor = self.exampleCanclelineColor;
    
    [self.inkPopoverView addSubview:self.lineView];
    [self.inkPopoverView addSubview:self.secondLineView];
    [self.inkPopoverView addSubview:self.colorLabel];
    [self.inkPopoverView addSubview:self.exampleCanclelineColorView];
    [self.inkPopoverView addSubview:self.ColorPickerView];
    
    self.inkPopoverController.popoverContentSize = CGSizeMake(365, 220);
    [self.inkPopoverController presentPopoverFromRect:CGRectMake(CGRectGetWidth(self.annotPopupView.frame)/2, 30, 0, 0) inView:self.annotPopupView permittedArrowDirections:UIPopoverArrowDirectionUp animated:YES];
    
    //        if(isEbook && (self.DocumentViewController.pageIdx+1 == self.DocumentViewController.pageCount) && self.DocumentViewController.pageCount%2 == 1){
    //            if(fromPageFlip){
    //                [self.DocumentViewController setTool:PlugPDFTextStrikeoutTool];
    //
    //            } else {
    //                [[self.DocumentViewController.documentView pageView:self.DocumentViewController.pageIdx-1] setTool:PlugPDFTextStrikeoutTool];
    //                [[self.DocumentViewController.documentView pageView:self.DocumentViewController.pageIdx] setTool:PlugPDFTextStrikeoutTool];
    //            }
    //            [self.DocumentViewController setTool:PlugPDFTextStrikeoutTool];
    //        } else {
    [self.DocumentViewController setTool:PlugPDFTextStrikeoutTool];
    //        }
    [self.DocumentViewController setTextStrikeoutToolColor:self.exampleCanclelineColor];
    self.inkPopoverController.passthroughViews = self.viewArray;
}

- (void) onMemo {
    [self.DocumentViewController releaseTools];
    [self.DocumentViewController.documentView removeGestureRecognizer:self.longPress];
    //        [self.DocumentViewController.documentView addGestureRecognizer:self.longPress];
    [self.DocumentViewController.documentView addGestureRecognizer:self.pan];
    [self releaseAnnots];
    [self releaseSubViews];
    isAnnot = YES;
    UsingNote = YES;
    
    [self.noteBtn setImage:[UIImage imageNamed:@"viewer-icon/pan-icon-07-on.png"] forState:UIControlStateNormal];
    [self.handButton setImage:[UIImage imageNamed:@"viewer-icon/hand.png"] forState:UIControlStateNormal];
    [self.eraserBtn setImage:[UIImage imageNamed:@"viewer-icon/pan-icon-08.png"] forState:UIControlStateNormal];
    [self.inkBtn setImage:[UIImage imageNamed:@"viewer-icon/pan-icon-01.png"] forState:UIControlStateNormal];
    [self.inkButton setImage:[UIImage imageNamed:@"viewer-icon/pan-icon-07-on.png"] forState:UIControlStateNormal];
    
    if(activateNoteMode){
        if(self.inkPopoverController.popoverContentSize.height > 200){
            self.memoTextView.text = self.tmpNote.contents;
            [self.noteIconBtn setImage:self.noteIcon forState:UIControlStateNormal];
        } else {
            self.lineView = [[UIView alloc] initWithFrame:CGRectMake(0,55, self.window.frame.size.width, 2)];
            self.lineView.backgroundColor = [UIColor colorWithRed:0.09 green:(0.20) blue:0.35 alpha:1.00];
            
            self.memoTextView = [[UITextView alloc] initWithFrame:CGRectMake(0,60, self.inkPopoverView.frame.size.width, 200)];
            self.memoTextView.backgroundColor = [UIColor colorWithRed:1.00 green:0.95 blue:0.74 alpha:1.00];
            [self.memoTextView setFont:[UIFont systemFontOfSize:15]];
            
            self.memoBtnView = [[UIView alloc] initWithFrame:CGRectMake(0,260, self.inkPopoverView.frame.size.width, 40)];
            self.memoBtnView.backgroundColor = [UIColor colorWithRed:0.94 green:0.92 blue:0.94 alpha:1.00];
            
            self.noteIconBtn = [[UIButton alloc] initWithFrame: CGRectMake(10, 7.5, 25, 25)];
            [self.noteIconBtn setImage:self.noteIcon forState:UIControlStateNormal];
            [self.noteIconBtn addTarget: self action: @selector(memo) forControlEvents: UIControlEventTouchUpInside];
            self.noteIconBtn.tag = 30;
            
            UILabel* memoOK = [[UILabel alloc] initWithFrame:CGRectMake(275, 5, 30, 30)];
            memoOK.text = @"확인";
            memoOK.userInteractionEnabled = YES;
            UITapGestureRecognizer *OKGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(MemoOk)];
            [memoOK addGestureRecognizer:OKGesture];
            
            UILabel* memoCancel = [[UILabel alloc] initWithFrame:CGRectMake(320, 5, 30, 30)];
            memoCancel.text = @"취소";
            memoCancel.userInteractionEnabled = YES;
            UITapGestureRecognizer *CancelGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(MemoCancel)];
            [memoCancel addGestureRecognizer:CancelGesture];
            
            [self.memoBtnView addSubview:self.noteIconBtn];
            [self.memoBtnView addSubview:memoOK];
            [self.memoBtnView addSubview:memoCancel];
            
            [self.inkPopoverView addSubview:self.lineView];
            [self.inkPopoverView addSubview:self.memoTextView];
            [self.inkPopoverView addSubview:self.memoBtnView];
            activateNoteMode = NO;
            
            self.inkPopoverController.popoverContentSize = CGSizeMake(365, 300);
            [self.inkPopoverController presentPopoverFromRect:CGRectMake(CGRectGetWidth(self.annotPopupView.frame)/2, 30, 0, 0) inView:self.annotPopupView permittedArrowDirections:UIPopoverArrowDirectionUp animated:YES];
        }
        NSLog(@"1");
    } else {
        NSLog(@"2");
        self.inkPopoverController.popoverContentSize = CGSizeMake(365, 50);
        [self.inkPopoverController presentPopoverFromRect:CGRectMake(CGRectGetWidth(self.annotPopupView.frame)/2, 30, 0, 0) inView:self.annotPopupView permittedArrowDirections:UIPopoverArrowDirectionUp animated:YES];
    }
    //        if(fromOnTapUp){
    //            [self.noteBtn setImage:[UIImage imageNamed:@"viewer-icon/pan-icon-07.png"] forState:UIControlStateNormal];
    //            [self.handButton setImage:[UIImage imageNamed:@"viewer-icon/hand-on.png"] forState:UIControlStateNormal];
    //            [self.inkButton setImage:[UIImage imageNamed:@"viewer-icon/top-icon-06.png"] forState:UIControlStateNormal];
    //        }
    
    self.inkPopoverController.passthroughViews = self.viewArray;
    
    firstOnTapUp = NO;
}

- (void) onEraser {
    [self.penPopoverController dismissPopoverAnimated:NO];
    [self.inkPopoverController dismissPopoverAnimated:NO];
    [self.eraserPopoverController dismissPopoverAnimated:NO];
    [self.BMpopoverController dismissPopoverAnimated:NO];
    [self.displayPopoverController dismissPopoverAnimated:NO];
    
    if(eraserPopup){
        eraserPopup = NO;
        penPopup = NO;
        inkPopup = NO;
        return;
    } else {
        eraserPopup = YES;
        penPopup = NO;
        inkPopup = NO;
    }
    
    [self.DocumentViewController.documentView removeGestureRecognizer:self.longPress];
    [self releaseAnnots];
    
    isAnnot = YES;
    UsingEraser = YES;
    
    self.eraserPopoverContent = [[UIViewController alloc] init]; //ViewController
    self.eraserPopoverView = [[UIView alloc] init];   //view
    
    [self.handButton setImage:[UIImage imageNamed:@"viewer-icon/hand.png"] forState:UIControlStateNormal];
    if(inkMode == 1) [self.inkButton setImage:[UIImage imageNamed:@"viewer-icon/pan-icon-04.png"] forState:UIControlStateNormal];
    else if(inkMode == 2) [self.inkButton setImage:[UIImage imageNamed:@"viewer-icon/pan-icon-05.png"] forState:UIControlStateNormal];
    else if(inkMode == 3) [self.inkButton setImage:[UIImage imageNamed:@"viewer-icon/pan-icon-06.png"] forState:UIControlStateNormal];
    else if(inkMode == 4) [self.inkButton setImage:[UIImage imageNamed:@"viewer-icon/pan-icon-02.png"] forState:UIControlStateNormal];
    else if(inkMode == 5) [self.inkButton setImage:[UIImage imageNamed:@"viewer-icon/pan-icon-03.png"] forState:UIControlStateNormal];
    
    self.defaultEraserBtn = [[UIButton alloc] initWithFrame: CGRectMake(10, 10, 30, 30)];
    [self.defaultEraserBtn setImage:[UIImage imageNamed:@"viewer-icon/pan-icon-08-01.png"] forState:UIControlStateNormal];
    [self.defaultEraserBtn addTarget: self action: @selector(onEraserDefault) forControlEvents: UIControlEventTouchUpInside];
    self.defaultEraserBtn.tag = 26;
    
    self.blockEraserBtn = [[UIButton alloc] initWithFrame: CGRectMake(50, 10, 30, 30)];
    [self.blockEraserBtn setImage:[UIImage imageNamed:@"viewer-icon/pan-icon-08-02.png"] forState:UIControlStateNormal];
    [self.blockEraserBtn addTarget: self action: @selector(onBlockEraser) forControlEvents: UIControlEventTouchUpInside];
    self.blockEraserBtn.tag = 27;
    
    self.allEraserBtn = [[UIButton alloc] initWithFrame: CGRectMake(90, 10, 30, 30)];
    [self.allEraserBtn setImage:[UIImage imageNamed:@"viewer-icon/pan-icon-08-03.png"] forState:UIControlStateNormal];
    [self.allEraserBtn addTarget: self action: @selector(onAllEraser) forControlEvents: UIControlEventTouchUpInside];
    self.allEraserBtn.tag = 28;
    
    [self.eraserBtn setImage:[UIImage imageNamed:@"viewer-icon/pan-icon-08-on.png"] forState:UIControlStateNormal];
    
    [self.eraserPopoverView addSubview:self.defaultEraserBtn];
    [self.eraserPopoverView addSubview:self.blockEraserBtn];
    [self.eraserPopoverView addSubview:self.allEraserBtn];
    
    self.eraserPopoverContent.view = self.eraserPopoverView;
    
    self.eraserPopoverController = [[UIPopoverController alloc] initWithContentViewController:self.eraserPopoverContent];
    self.eraserPopoverController.delegate=self;
    self.eraserPopoverController.backgroundColor = [UIColor colorWithRed:0.03 green:(0.14) blue:0.27 alpha:0.5];
    
    //        UIView *view = [sender valueForKey:@"imageView"];
    UIView *view = [self.eraserBtn valueForKey:@"imageView"];
    
    self.eraserPopoverController.popoverContentSize = CGSizeMake(130, 50);
    [self.eraserPopoverController presentPopoverFromRect:CGRectMake(CGRectGetWidth(view.frame)/2, 40, 0, 0) inView:view permittedArrowDirections:UIPopoverArrowDirectionUp animated:YES];
    
    if(eraserMode == 1){
        [self.defaultEraserBtn sendActionsForControlEvents:UIControlEventTouchUpInside];
    } else if (eraserMode == 2) {
        [self.blockEraserBtn sendActionsForControlEvents:UIControlEventTouchUpInside];
    }
    
    [self.DocumentViewController.documentView removeGestureRecognizer:self.pan];
}

- (void) onEraserDefault {
    fromOnTapUp = NO;
    [self.defaultEraserBtn setImage:[UIImage imageNamed:@"viewer-icon/pan-icon-08-01-on.png"] forState:UIControlStateNormal];
    [self.blockEraserBtn setImage:[UIImage imageNamed:@"viewer-icon/pan-icon-08-02.png"] forState:UIControlStateNormal];
    [self.DocumentViewController releaseTools];
    [self.DocumentViewController setEraserType:PlugPDFDocumentEraserTypeClickWithDrag];
    //        if(isEbook && (self.DocumentViewController.pageIdx+1 == self.DocumentViewController.pageCount) && self.DocumentViewController.pageCount%2 == 1){
    //            if(fromPageFlip){
    //                [self.DocumentViewController setTool:PlugPDFEraserTool];
    //
    //            } else {
    //                [[self.DocumentViewController.documentView pageView:self.DocumentViewController.pageIdx-1] setTool:PlugPDFEraserTool];
    //                [[self.DocumentViewController.documentView pageView:self.DocumentViewController.pageIdx] setTool:PlugPDFEraserTool];
    //            }
    //            [self.DocumentViewController setTool:PlugPDFEraserTool];
    //        } else {
    [self.DocumentViewController setTool:PlugPDFEraserTool];
    //        }
    eraserMode = 1;
    [[NSUserDefaults standardUserDefaults] setInteger:eraserMode forKey:@"eraserMode"];
    self.eraserPopoverController.passthroughViews = self.viewArray;
}

- (void)onBlockEraser {
    fromOnTapUp = NO;
    [self.blockEraserBtn setImage:[UIImage imageNamed:@"viewer-icon/pan-icon-08-02-on.png"] forState:UIControlStateNormal];
    [self.defaultEraserBtn setImage:[UIImage imageNamed:@"viewer-icon/pan-icon-08-01.png"] forState:UIControlStateNormal];
    [self.DocumentViewController releaseTools];
    [self.DocumentViewController setEraserType:PlugPDFDocumentEraserTypeSelectedArea];
    //        if(isEbook && (self.DocumentViewController.pageIdx+1 == self.DocumentViewController.pageCount) && self.DocumentViewController.pageCount%2 == 1){
    //            if(fromPageFlip){
    //                [self.DocumentViewController setTool:PlugPDFEraserTool];
    //
    //            } else {
    //                [[self.DocumentViewController.documentView pageView:self.DocumentViewController.pageIdx-1] setTool:PlugPDFEraserTool];
    //                [[self.DocumentViewController.documentView pageView:self.DocumentViewController.pageIdx] setTool:PlugPDFEraserTool];
    //            }
    //            [self.DocumentViewController setTool:PlugPDFEraserTool];
    //        } else {
    [self.DocumentViewController setTool:PlugPDFEraserTool];
    //        }
    eraserMode = 2;
    [[NSUserDefaults standardUserDefaults] setInteger:eraserMode forKey:@"eraserMode"];
    self.eraserPopoverController.passthroughViews = self.viewArray;
}

- (void) onAllEraser {
    fromOnTapUp = NO;
    penPopup = NO;
    inkPopup = NO;
    eraserPopup = NO;
    
    [self.eraserPopoverController dismissPopoverAnimated:NO];
    UIAlertController * alert=   [UIAlertController
                                  alertControllerWithTitle:@"현재 페이지의 모든 필기를 \n삭제하시겠습니까?"
                                  message:@""
                                  preferredStyle:UIAlertControllerStyleAlert];
    
    UIAlertAction* ok = [UIAlertAction
                         actionWithTitle:@"OK"
                         style:UIAlertActionStyleDefault
                         handler:^(UIAlertAction * action)
                         {
                             [alert dismissViewControllerAnimated:YES completion:nil];
                             
                             [self.DocumentViewController releaseTools];
                             
                             if(isEbook){
                                 if(self.DocumentViewController.pageCount%2 == 1){ // 짝수 페이지 문서
                                     if(self.DocumentViewController.pageIdx%2 == 1){ // 현재 페이지가 짝수 일 때
                                         [self.DocumentViewController removePageAnnot];
                                         self.DocumentViewController.documentView.pageIdx = self.DocumentViewController.documentView.pageIdx - 1;
                                         [self.DocumentViewController removePageAnnot];
                                         self.DocumentViewController.documentView.pageIdx = self.DocumentViewController.documentView.pageIdx + 1;
                                     } else { // 현재 페이지가 홀수 일 때
                                         [self.DocumentViewController removePageAnnot];
                                         self.DocumentViewController.documentView.pageIdx = self.DocumentViewController.documentView.pageIdx + 1;
                                         [self.DocumentViewController removePageAnnot];
                                         self.DocumentViewController.documentView.pageIdx = self.DocumentViewController.documentView.pageIdx - 1;
                                     }
                                 } else { // 홀수 페이지 문서
                                     if(self.DocumentViewController.pageIdx%2 == 1){ // 현재 페이지가 짝수 일 때
                                         [self.DocumentViewController removePageAnnot];
                                         self.DocumentViewController.documentView.pageIdx = self.DocumentViewController.documentView.pageIdx - 1;
                                         [self.DocumentViewController removePageAnnot];
                                         self.DocumentViewController.documentView.pageIdx = self.DocumentViewController.documentView.pageIdx + 1;
                                     } else { // 현재 페이지가 홀수 일 때
                                         if(self.DocumentViewController.pageIdx+1 == self.DocumentViewController.pageCount){ // 현재 페이지가 마지막 페이지 일 때
                                             [self.DocumentViewController removePageAnnot];
                                         } else {
                                             [self.DocumentViewController removePageAnnot];
                                             self.DocumentViewController.documentView.pageIdx = self.DocumentViewController.documentView.pageIdx + 1;
                                             [self.DocumentViewController removePageAnnot];
                                             self.DocumentViewController.documentView.pageIdx = self.DocumentViewController.documentView.pageIdx - 1;
                                         }
                                     }
                                 }
                             } else {
                                 [self.DocumentViewController removePageAnnot];
                             }
                             
                             [self.inkPopoverController dismissPopoverAnimated:NO];
                             
                             [self.handButton sendActionsForControlEvents:UIControlEventTouchUpInside];
                         }];
    UIAlertAction* cancel = [UIAlertAction
                             actionWithTitle:@"Cancel"
                             style:UIAlertActionStyleDefault
                             handler:^(UIAlertAction * action)
                             {
                                 [alert dismissViewControllerAnimated:YES completion:nil];
                                 
                             }];
    
    [alert addAction:ok];
    [alert addAction:cancel];
    
    [self.DocumentViewController presentViewController:alert animated:YES completion:nil];
}

- (void) memo {
    self.lineView2 = [[UIView alloc] initWithFrame:CGRectMake(0,300, self.window.frame.size.width, 1)];
    self.lineView2.backgroundColor = [UIColor colorWithRed:0.09 green:(0.20) blue:0.35 alpha:1.00];
    
    self.memoIconView = [[UIView alloc] initWithFrame:CGRectMake(0, 301, self.inkPopoverView.frame.size.width, 149)];
    self.memoIconView.backgroundColor = [UIColor colorWithRed:0.94 green:0.92 blue:0.94 alpha:1.00];
    
    UIButton *icon1 = [[UIButton alloc] initWithFrame:CGRectMake(30, 20, 30, 30)];
    [icon1 setImage:[UIImage imageNamed:@"viewer-icon/icon-memo-01"] forState:UIControlStateNormal];
    icon1.tag = 1;
    [icon1 addTarget:self action:@selector(getNoteIcon:) forControlEvents:UIControlEventTouchUpInside];
    
    UIButton *icon2 = [[UIButton alloc] initWithFrame:CGRectMake(100, 20, 30, 30)];
    [icon2 setImage:[UIImage imageNamed:@"viewer-icon/icon-memo-02"] forState:UIControlStateNormal];
    icon2.tag = 2;
    [icon2 addTarget:self action:@selector(getNoteIcon:) forControlEvents:UIControlEventTouchUpInside];
    
    UIButton *icon3 = [[UIButton alloc] initWithFrame:CGRectMake(170, 20, 30, 30)];
    [icon3 setImage:[UIImage imageNamed:@"viewer-icon/icon-memo-03"] forState:UIControlStateNormal];
    icon3.tag = 3;
    [icon3 addTarget:self action:@selector(getNoteIcon:) forControlEvents:UIControlEventTouchUpInside];
    
    UIButton *icon4 = [[UIButton alloc] initWithFrame:CGRectMake(240, 20, 30, 30)];
    [icon4 setImage:[UIImage imageNamed:@"viewer-icon/icon-memo-04"] forState:UIControlStateNormal];
    icon4.tag = 4;
    [icon4 addTarget:self action:@selector(getNoteIcon:) forControlEvents:UIControlEventTouchUpInside];
    
    UIButton *icon5 = [[UIButton alloc] initWithFrame:CGRectMake(310, 20, 30, 30)];
    [icon5 setImage:[UIImage imageNamed:@"viewer-icon/icon-memo-05"] forState:UIControlStateNormal];
    icon5.tag = 5;
    [icon5 addTarget:self action:@selector(getNoteIcon:) forControlEvents:UIControlEventTouchUpInside];
    
    UIButton *icon6 = [[UIButton alloc] initWithFrame:CGRectMake(30, 80, 30, 30)];
    [icon6 setImage:[UIImage imageNamed:@"viewer-icon/icon-memo-06"] forState:UIControlStateNormal];
    icon6.tag = 6;
    [icon6 addTarget:self action:@selector(getNoteIcon:) forControlEvents:UIControlEventTouchUpInside];
    
    UIButton *icon7 = [[UIButton alloc] initWithFrame:CGRectMake(100, 80, 30, 30)];
    [icon7 setImage:[UIImage imageNamed:@"viewer-icon/icon-memo-07"] forState:UIControlStateNormal];
    icon7.tag = 7;
    [icon7 addTarget:self action:@selector(getNoteIcon:) forControlEvents:UIControlEventTouchUpInside];
    
    UIButton *icon8 = [[UIButton alloc] initWithFrame:CGRectMake(170, 80, 30, 30)];
    [icon8 setImage:[UIImage imageNamed:@"viewer-icon/icon-memo-08"] forState:UIControlStateNormal];
    icon8.tag = 8;
    [icon8 addTarget:self action:@selector(getNoteIcon:) forControlEvents:UIControlEventTouchUpInside];
    
    UIButton *icon9 = [[UIButton alloc] initWithFrame:CGRectMake(240, 80, 30, 30)];
    [icon9 setImage:[UIImage imageNamed:@"viewer-icon/icon-memo-09"] forState:UIControlStateNormal];
    icon9.tag = 9;
    [icon9 addTarget:self action:@selector(getNoteIcon:) forControlEvents:UIControlEventTouchUpInside];
    
    UIButton *icon10 = [[UIButton alloc] initWithFrame:CGRectMake(310, 80, 30, 30)];
    [icon10 setImage:[UIImage imageNamed:@"viewer-icon/icon-memo-10"] forState:UIControlStateNormal];
    icon10.tag = 10;
    [icon10 addTarget:self action:@selector(getNoteIcon:) forControlEvents:UIControlEventTouchUpInside];
    
    
    [self.memoIconView addSubview:icon1];
    [self.memoIconView addSubview:icon2];
    [self.memoIconView addSubview:icon3];
    [self.memoIconView addSubview:icon4];
    [self.memoIconView addSubview:icon5];
    [self.memoIconView addSubview:icon6];
    [self.memoIconView addSubview:icon7];
    [self.memoIconView addSubview:icon8];
    [self.memoIconView addSubview:icon9];
    [self.memoIconView addSubview:icon10];
    
    [self.inkPopoverView addSubview:self.memoIconView];
    
    self.inkPopoverController.popoverContentSize = CGSizeMake(365, 430);
    [self.inkPopoverController presentPopoverFromRect:CGRectMake(CGRectGetWidth(self.annotPopupView.frame)/2, 30, 0, 0) inView:self.annotPopupView permittedArrowDirections:UIPopoverArrowDirectionUp animated:YES];
}

- (void)openPlugPDF3: (id)sender {
    //    NSLog(@"%ld", (long)[sender tag]);
    //    if([sender tag] == 1){
    //
    //    } else if([sender tag] == 2){
    //
    //    } else if([sender tag] == 3){
    //
    //    } else if([sender tag] == 22){
    //
    //    } else if([sender tag] == 4){
    //
    //    } else if([sender tag] == 5){
    //
    //    } else if([sender tag] == 6){
    //
    //    } else if([sender tag] == 7){
    //
    //    } else if([sender tag] == 8){
    //
    //    } else if([sender tag] == 9){
    //
    //    } else if([sender tag] == 10){
    //
    //    } else if([sender tag] == 11){
    //
    //    } else if([sender tag] == 12){
    //
    //    } else if([sender tag] == 26){
    //
    //    } else if([sender tag] == 27){
    //
    //    } else if([sender tag] == 28){
    //
    //    } else if([sender tag] == 30){
    //
    //    }
}

//-(BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldRequireFailureOfGestureRecognizer:(UIGestureRecognizer *)otherGestureRecognizer{
////    NSLog(@"test1");
//    return YES;
//}
//-(BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldReceiveTouch:(UITouch *)touch{
////    NSLog(@"test1");
//    return YES;
//}
//-(BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldBeRequiredToFailByGestureRecognizer:(UIGestureRecognizer *)otherGestureRecognizer{
////    NSLog(@"test1");
//    return YES;
//}
//-(BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldRecognizeSimultaneouslyWithGestureRecognizer:(UIGestureRecognizer *)otherGestureRecognizer{
////    NSLog(@"test1");
//    return YES;
//}

- (void)popoverControllerDidDismissPopover:(UIPopoverController *)popoverController {
    if(displayPopup) displayPopup = NO;
    else if(bookmarkPopup) bookmarkPopup = NO;
}

-(IBAction)getNoteIcon:(id)sender{
    if([sender tag] == 1){
        self.noteIcon = [UIImage imageNamed:@"viewer-icon/icon-memo-01"];
        [self.noteIconBtn setImage:[UIImage imageNamed:@"viewer-icon/icon-memo-01"] forState:UIControlStateNormal];
    } else if([sender tag] == 2){
        self.noteIcon = [UIImage imageNamed:@"viewer-icon/icon-memo-02"];
        [self.noteIconBtn setImage:[UIImage imageNamed:@"viewer-icon/icon-memo-02"] forState:UIControlStateNormal];
    } else if([sender tag] == 3){
        self.noteIcon = [UIImage imageNamed:@"viewer-icon/icon-memo-03"];
        [self.noteIconBtn setImage:[UIImage imageNamed:@"viewer-icon/icon-memo-03"] forState:UIControlStateNormal];
    } else if([sender tag] == 4){
        self.noteIcon = [UIImage imageNamed:@"viewer-icon/icon-memo-04"];
        [self.noteIconBtn setImage:[UIImage imageNamed:@"viewer-icon/icon-memo-04"] forState:UIControlStateNormal];
    } else if([sender tag] == 5){
        self.noteIcon = [UIImage imageNamed:@"viewer-icon/icon-memo-05"];
        [self.noteIconBtn setImage:[UIImage imageNamed:@"viewer-icon/icon-memo-05"] forState:UIControlStateNormal];
    } else if([sender tag] == 6){
        self.noteIcon = [UIImage imageNamed:@"viewer-icon/icon-memo-06"];
        [self.noteIconBtn setImage:[UIImage imageNamed:@"viewer-icon/icon-memo-06"] forState:UIControlStateNormal];
    } else if([sender tag] == 7){
        self.noteIcon = [UIImage imageNamed:@"viewer-icon/icon-memo-07"];
        [self.noteIconBtn setImage:[UIImage imageNamed:@"viewer-icon/icon-memo-07"] forState:UIControlStateNormal];
    } else if([sender tag] == 8){
        self.noteIcon = [UIImage imageNamed:@"viewer-icon/icon-memo-08"];
        [self.noteIconBtn setImage:[UIImage imageNamed:@"viewer-icon/icon-memo-08"] forState:UIControlStateNormal];
    } else if([sender tag] == 9){
        self.noteIcon = [UIImage imageNamed:@"viewer-icon/icon-memo-09"];
        [self.noteIconBtn setImage:[UIImage imageNamed:@"viewer-icon/icon-memo-09"] forState:UIControlStateNormal];
    } else if([sender tag] == 10){
        self.noteIcon = [UIImage imageNamed:@"viewer-icon/icon-memo-10"];
        [self.noteIconBtn setImage:[UIImage imageNamed:@"viewer-icon/icon-memo-10"] forState:UIControlStateNormal];
    }
}

-(void)MemoOk
{
    NSLog(@"MemoOK");
    if(fromOnTapUp){
        NSLog(@"fromOnTapUp");
        self.tmpNote.contents = self.memoTextView.text;
        [self.DocumentViewController.documentView removeAnnot:self.tmpBaseNote];
        NoteAnnot* newNote = [[NoteAnnot alloc] initWithTitle:@"" contents:self.memoTextView.text date:@"" icon:self.noteIcon rect:self.tmpNote.rect pageIdx:self.tmpNote.pageIdx];
        [self.DocumentViewController.documentView removeAnnot:self.tmpNote];
        [self.DocumentViewController removeAnnot:self.tmpNote];
        [self.DocumentViewController setNoteIcon:self.noteIcon];
        [self.DocumentViewController.documentView saveNote:newNote];
        [self.DocumentViewController releaseTools];
    } else {
        PlugPDFPageView* pageView = [self.DocumentViewController.documentView pageView:self.DocumentViewController.pageIdx];
        //    float zoomScale = [pageView pageScale];
        float zoomScale = pageView.minScale;
        NSLog(@"%f", pageView.minScale);
        
        NSLog(@"note point(%.f, %.f)", self.point.x, self.point.y);
        NSLog(@"zoom scale = %f", zoomScale);
        CGSize documentSize = [self.DocumentViewController.documentView.document pageSize:0];
        
        float pageIdx;
        float pointX;
        
        if(isEbook){
            if(self.point.x > 1366) {
                pageIdx = self.DocumentViewController.pageIdx+1;
                pointX = self.point.x - 1366;
            } else {
                pageIdx = self.DocumentViewController.pageIdx;
                pointX = self.point.x;
            }
        } else {
            pageIdx = self.DocumentViewController.pageIdx;
            pointX = self.point.x;
        }
        
        NSLog(@"11 = %f", pageIdx);
        NoteAnnot* note1 = [[NoteAnnot alloc] initWithTitle:@"title" contents:self.memoTextView.text date:@"date" icon:self.noteIcon rect:CGRectMake(pointX/zoomScale, self.point.y/zoomScale, 30, 30) pageIdx:pageIdx];
        
        [self.DocumentViewController setNoteIcon:self.noteIcon];
        
        [self.DocumentViewController.documentView saveNote:note1];
    }
    
    fromOnTapUp = NO;
    [self.handButton sendActionsForControlEvents:UIControlEventTouchUpInside];
    
    [self.inkPopoverController dismissPopoverAnimated:YES];
}

-(void)MemoCancel
{
    NSLog(@"MemoCancel");
    [self.inkPopoverController dismissPopoverAnimated:YES];
    [self.handButton sendActionsForControlEvents:UIControlEventTouchUpInside];
    fromOnTapUp = NO;
}

- (void)dealloc {
    //    [_testview release];
    //    [self dealloc];
}


- (void)registerDeviceOrientationNotification
{
    // 화면 회전 노티 등록
    [[UIDevice currentDevice] beginGeneratingDeviceOrientationNotifications];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(orientationChanged:)name:UIDeviceOrientationDidChangeNotification object:nil];
    
    // 뷰 리로드 노티 등록
    NSNotificationCenter *sendNotification = [NSNotificationCenter defaultCenter];
    [sendNotification addObserver:self selector:@selector(firstMethod:) name:@"firstNotification" object: nil];
}

// 스플릿 뷰어 이벤트 처리
- (void)firstMethod:(NSNotification *)notification {
    viewLoad = YES;
    
    //    [self.displayPopoverController dismissPopoverAnimated:NO];
    //    [self.BMpopoverController dismissPopoverAnimated:NO];
    //    [self.inkPopoverController dismissPopoverAnimated:NO];
    //    [self.eraserPopoverController dismissPopoverAnimated:NO];
    //    [self.penPopoverController dismissPopoverAnimated:NO];
    //    penPopup = NO;
    //    inkPopup = NO;
    //    eraserPopup = NO;
    
    int orientation = [[UIApplication sharedApplication] statusBarOrientation];
    CGFloat widthSize = CGRectGetWidth(self.window.frame);
    //    if((int)orientation == 3 || (int)orientation == 4){
    //        if(isEbook){
    //            [self.DocumentViewController setEnablePageFlipEffect:YES];
    ////            [self.DocumentViewController setDisplayMode:PlugPDFDocumentDisplayModeEBook];
    //        } else {
    //            [self.DocumentViewController setEnablePageFlipEffect:NO];
    //            [self.DocumentViewController setDisplayMode:PlugPDFDocumentDisplayModeHorizontal];
    //        }
    //    }
    
    if(openViewer){
        NSRange strRange1 = [urlpath rangeOfString:@".xlsx"];
        NSRange strRange2 = [urlpath rangeOfString:@".xls"];
        NSRange strRange3 = [urlpath rangeOfString:@".docx"];
        NSRange strRange4 = [urlpath rangeOfString:@".doc"];
        NSRange strRange5 = [urlpath rangeOfString:@".hwp"];
        NSRange strRange6 = [urlpath rangeOfString:@".pptx"];
        NSRange strRange7 = [urlpath rangeOfString:@".ppt"];
        NSRange strRange8 = [urlpath rangeOfString:@".pdf"];
        
        BOOL exist = NO;
        if (strRange1.location != NSNotFound || strRange2.location != NSNotFound || strRange3.location != NSNotFound || strRange4.location != NSNotFound || strRange5.location != NSNotFound || strRange6.location != NSNotFound || strRange7.location != NSNotFound || strRange8.location != NSNotFound) {
            exist = YES;
        }
        
        if(exist){
            dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.1 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                //                [self.DocumentViewController refreshView];
                CGSize documentSize = [self.DocumentViewController.documentView.document pageSize:0];
                CGFloat documentHeight = documentSize.height;
                CGFloat documentWidth = documentSize.width;
                CGFloat windowHeight = CGRectGetHeight(self.window.frame);
                CGFloat windowWidth = CGRectGetWidth(self.window.frame);
                
                UIWindow* window = [UIApplication sharedApplication].keyWindow;
                self.window.frame = window.frame;
                [self.navbar setFrame:CGRectMake(0, 40, CGRectGetWidth(window.bounds), 41)];
                
                [self.navbar setFrame: CGRectMake(0, 40, CGRectGetWidth(window.bounds), 41)];
                [self.hideView setFrame: CGRectMake(self.navbar.frame.size.width-40, 0, 40, 40)];
                [self.handView setFrame: CGRectMake(self.navbar.frame.size.width-82.5, 0, 40, 40)];
                [self.inkView setFrame: CGRectMake(self.navbar.frame.size.width-120, 0, 40, 40)];
                [self.eraserView setFrame:CGRectMake(self.navbar.frame.size.width-160, 0, 40, 40)];
                [self.penView setFrame:CGRectMake(self.navbar.frame.size.width-200, 0, 40, 40)];
                [self.searchView setFrame:CGRectMake(self.navbar.frame.size.width-240, 0, 40, 40)];
                [self.bookMarkView setFrame:CGRectMake(self.navbar.frame.size.width-280, 0, 40, 40)];
                [self.displayModeView setFrame:CGRectMake(self.navbar.frame.size.width-320, 0, 40, 40)];
                [self.saveView setFrame:CGRectMake(self.navbar.frame.size.width-360, 0, 40, 40)];
                
                [self.backSearchView setFrame:CGRectMake(self.window.frame.size.width-90, 0, 40, 40)];
                [self.forSearchView setFrame:CGRectMake(self.window.frame.size.width-50, 0, 40, 40)];
                
                [self.searchNavbar setFrame:CGRectMake(0, 40, CGRectGetWidth(window.bounds), 40)];
                [self.searchBar setFrame:CGRectMake(60, 0, CGRectGetWidth(window.bounds) - 160, 40)];
                if(windowWidth > 400){
                    [self.pageMoveView setFrame:CGRectMake(CGRectGetWidth(self.window.frame) - 203, CGRectGetHeight(self.window.frame) - 42, 186, 40)];
                } else {
                    [self.pageMoveView setFrame:CGRectMake(CGRectGetWidth(self.window.frame) - 203, CGRectGetHeight(self.window.frame) - 42, 186, 40)];
                }
                [self.displayBtnView setFrame: CGRectMake(CGRectGetWidth(self.window.frame)-45, 50, 30, 30)];
                [self.closeBtnView setFrame: CGRectMake(25, 50, 30, 30)];
                [self.tapBar setFrame:CGRectMake(0, 0, CGRectGetWidth(self.window.frame), 40)];
                self.backgroundTapView = [[UIView alloc] initWithFrame:CGRectMake(self.tapBar.frame.size.width-80, 0, 40, 40)];
                self.closeAllTapView = [[UIView alloc] initWithFrame:CGRectMake(self.tapBar.frame.size.width-40, 0, 40, 40)];
                [_collectionView setFrame:CGRectMake(0, 0, CGRectGetWidth(self.tapBar.frame)-100, 40)];
                
                if(windowWidth > 1000) self.backBtn.title = self.title;
                else self.backBtn.title = self.backBtn.title = @"";
                
                int orientation = [[UIApplication sharedApplication] statusBarOrientation];
                
                UICollectionViewLayout* collectionViewLayout = [[UICollectionViewLayout alloc] init];
                [self collectionView:_collectionView layout:collectionViewLayout sizeForItemAtIndexPath:[NSIndexPath indexPathForRow:index inSection:0]];
                NSLog(@"documentHeight = %f, documentWidth = %f", windowHeight, windowWidth);
                
                [self.tapBar removeFromSuperview];
                NSLog(@"initCollectionView");
                self.tapBar = [[UIView alloc] initWithFrame:CGRectMake(0, 0, CGRectGetWidth(self.window.frame), 40)];
                self.tapBar.backgroundColor = [UIColor colorWithRed:0.03 green:0.16 blue:0.32 alpha:0.70];
                UICollectionViewFlowLayout *layout=[[UICollectionViewFlowLayout alloc] init];
                _collectionView=[[UICollectionView alloc] initWithFrame:CGRectMake(0, 0, CGRectGetWidth(self.tapBar.frame)-100, 40) collectionViewLayout:layout];
                [_collectionView setDataSource:self];
                [_collectionView setDelegate:self];
                
                NSLog(@"windowWidth = %f", windowWidth);
                
                if(windowWidth > 1200){
                    cellSize = (CGRectGetWidth(self.tapBar.frame)-100)/4;
                } else if (windowWidth < 1200 && windowWidth > 700) {
                    cellSize = (CGRectGetWidth(self.tapBar.frame)-100)/3;
                } else {
                    cellSize = (CGRectGetWidth(self.tapBar.frame)-100)/3;
                }
                
                
                [_collectionView registerClass:[UICollectionViewCell class] forCellWithReuseIdentifier:@"cellIdentifier"];
                [_collectionView setBackgroundColor:[UIColor colorWithRed:0.03 green:0.16 blue:0.32 alpha:0.70]];
                [_collectionView setShowsHorizontalScrollIndicator:YES];
                
                ((UICollectionViewFlowLayout *)_collectionView.collectionViewLayout).scrollDirection = UICollectionViewScrollDirectionHorizontal;
                [_collectionView setAlwaysBounceHorizontal:YES];
                ((UICollectionViewFlowLayout *)_collectionView.collectionViewLayout).minimumLineSpacing = 0; // 셀 간격
                [_collectionView setAllowsMultipleSelection:NO];
                
                self.backgroundTapView = [[UIView alloc] initWithFrame:CGRectMake(self.tapBar.frame.size.width-80, 0, 40, 40)];
                self.backGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(BackgroundTap:)];
                [self.backgroundTapView addGestureRecognizer:self.backGesture];
                
                self.backgroundTap = [[UIButton alloc] initWithFrame: CGRectMake(0, 10, 20, 20)];
                [self.backgroundTap setImage:[UIImage imageNamed:@"viewer-icon/home.png"] forState:UIControlStateNormal];
                [self.backgroundTap addTarget: self action: @selector(BackgroundTap:) forControlEvents: UIControlEventTouchUpInside];
                [self.backgroundTapView addSubview:self.backgroundTap];
                [self.tapBar addSubview:self.backgroundTapView];
                
                self.closeAllTapView = [[UIView alloc] initWithFrame:CGRectMake(self.tapBar.frame.size.width-40, 0, 40, 40)];
                self.allCloseGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(CloseAllTap:)];
                [self.closeAllTapView addGestureRecognizer:self.allCloseGesture];
                
                self.closeAllTap = [[UIButton alloc] initWithFrame: CGRectMake(0, 10, 20, 20)];
                [self.closeAllTap setImage:[UIImage imageNamed:@"viewer-icon/tap-close-03.png"] forState:UIControlStateNormal];
                [self.closeAllTap addTarget: self action: @selector(CloseAllTap:) forControlEvents: UIControlEventTouchUpInside];
                [self.closeAllTapView addSubview:self.closeAllTap];
                [self.tapBar addSubview:self.closeAllTapView];
                
                [self.tapBar addSubview:_collectionView];
                [self.AD.navigationController.view addSubview:self.tapBar];
                
                if(isHidden) [self.tapBar setHidden:YES];
                else [self.tapBar setHidden:NO];
                //            });
                
                //            dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.5 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                if(isHidden){
                    [self.DocumentViewController setEnableAlwaysVisible:NO];
                } else {
                    [self.DocumentViewController setEnableAlwaysVisible:YES];
                }
                
                //                [self.DocumentViewController releaseTools];
                if(UsingInk == YES){ [self.DocumentViewController setTool:PlugPDFInkTool]; }
                else if(UsingSquare == YES){
                    [self.DocumentViewController setTool:PlugPDFSquareTool];
                    [self.DocumentViewController setShapeWidth:squareBoldValue];
                    [self.DocumentViewController setSquareAnnotColor:self.exampleSquareColor];
                    [self.DocumentViewController setShapeColor:self.exampleSquareCornerColor];
                    [self.DocumentViewController setSquareAnnotOpacity:1.0];
                    if([[UIColor clearColor] isEqual:self.exampleSquareColor]){
                        [self.DocumentViewController setSquareAnnotTransparent:YES];
                    } else {
                        [self.DocumentViewController setSquareAnnotTransparent:NO];
                    }
                } else if(UsingCircle == YES){
                    [self.DocumentViewController setTool:PlugPDFCircleTool];
                    [self.DocumentViewController setShapeWidth:circleBoldValue];
                    [self.DocumentViewController setCircleAnnotColor:self.exampleCircleColor];
                    [self.DocumentViewController setShapeColor:self.exampleCircleCornerColor];
                    [self.DocumentViewController setCircleAnnotOpacity:1.0];
                    if([[UIColor clearColor] isEqual:self.exampleCircleColor]){
                        [self.DocumentViewController setCircleAnnotTransparent:YES];
                    } else {
                        [self.DocumentViewController setCircleAnnotTransparent:NO];
                    }
                } else if(UsingHighlight == YES){ [self.DocumentViewController setTool:PlugPDFTextHighlightTool]; }
                else if(UsingUnderline == YES){ [self.DocumentViewController setTool:PlugPDFTextUnderlineTool]; }
                else if(UsingCancle == YES){ [self.DocumentViewController setTool:PlugPDFTextStrikeoutTool]; }
                else if(UsingNote == YES){ [self.DocumentViewController setTool:PlugPDFNoteTool]; }
                else if(UsingEraser == YES){ [self.DocumentViewController setTool:PlugPDFEraserTool]; }
                
                //                CGSize documentSize = [self.DocumentViewController.documentView.document pageSize:0];
                //                CGFloat documentHeight = documentSize.height;
                //                CGFloat documentWidth = documentSize.width;
                //                CGFloat windowHeight = CGRectGetHeight(self.window.frame);
                //                CGFloat windowWidth = CGRectGetWidth(self.window.frame);
                //
                //                int orientation = [[UIApplication sharedApplication] statusBarOrientation];
                
                // 탭 자동 이동
                int i = 1;
                for (id key in self.AD.VCDic) {
                    if([key isEqualToString:self.pdfPath]){
                        break;
                    }
                    i = i + 1;
                }
                
                if(windowWidth > 1200){
                    if(self.AD.VCDic.count > 4){
                        long movePoint = (long)(i-4)*cellSize;
                        if(movePoint < 1) movePoint = 0;
                        [_collectionView setContentOffset:CGPointMake(movePoint, 0) animated:YES];
                    }
                } else if (windowWidth < 1200 && windowWidth > 700) {
                    if(self.AD.VCDic.count > 3){
                        long movePoint = (long)(i-3)*cellSize;
                        if(movePoint < 1) movePoint = 0;
                        [_collectionView setContentOffset:CGPointMake(movePoint, 0) animated:YES];
                    }
                } else {
                    if(self.AD.VCDic.count > 3){
                        long movePoint = (long)(i-3)*cellSize;
                        if(movePoint < 1) movePoint = 0;
                        [_collectionView setContentOffset:CGPointMake(movePoint, 0) animated:YES];
                    }
                }
                //            });
                //셀 강제 선택
                
                //            dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1.0 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                click = 0;
                [self collectionView:_collectionView didSelectItemAtIndexPath:[NSIndexPath indexPathForRow:index inSection:0]];
                
                [self.DocumentViewController refreshView];
            });
        }
    }
}

// 화면 가로/세로 전환 이벤트 처리
- (void) orientationChanged:(NSNotification *)notification
{
    fromOrientation = YES;
}

-(BOOL)textFieldShouldReturn:(UITextField *)textField
{
    //    [self callYourCodeWantToExecute];
    //return YES; // want to hide keyboard
    //return NO; // want keyboard
    return NO;
}

- (void)searchBarSearchButtonClicked:(UISearchBar *)searchBar
{
    [searchBar resignFirstResponder];
    [self.forwardButton sendActionsForControlEvents:UIControlEventTouchUpInside];
    
    // Do the search...
    NSLog(@"test");
}

- (void)searchBar:(UISearchBar *)searchBar textDidChange:(NSString *)searchText{
    
}

- (BOOL)viewController:(UIViewController*)viewController
               onTapUp: (BaseAnnot*)annot
{
    NSLog(@"onTapUP");
    if ([annot isMemberOfClass: NoteAnnot.class]) {
        if(isHidden) [self.displayBtn sendActionsForControlEvents:UIControlEventTouchUpInside];
        NSLog(@"Note TapUp");
        activateNoteMode = YES;
        //        [self.noteBtn sendActionsForControlEvents:UIControlEventTouchUpInside];
        self.tmpNote = (NoteAnnot*)annot;
        //        [self.noteIconBtn setImage:self.tmpNote.icon forState:UIControlStateNormal];
        fromOnTapUp = YES;
        self.tmpBaseNote = annot;
        self.noteIcon = self.tmpNote.icon;
        [self.inkButton sendActionsForControlEvents:UIControlEventTouchUpInside];
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.1 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            self.memoTextView.text = self.tmpNote.contents;
        });
    }
    return NO;
}


#pragma mark - PlugPDFDocumentViewEventDelegate

- (BOOL)pageWillChange:(PlugPDFDocumentView *)documentView pageIdx:(NSInteger)pageIdx
{
    self.DocumentViewController.enablePageIndicatorButton = NO;
    pagedidchange = NO;
    if(UsingNote){
        UsingNote = NO;
        activateNoteMode = NO;
        [self.handButton sendActionsForControlEvents:UIControlEventTouchUpInside];
    }
    
    NSLog(@"pageWillChange");
    if(isHidden){
        NSLog(@"Hidden YES");
        //            [self.DocumentViewController setEnableBottomBar:YES];
        [self.DocumentViewController setEnableAlwaysVisible:NO];
        [self.DocumentViewController setNavigationToolBarHidden:YES];
        //            [self.DocumentViewController setEnableBottomBar:NO];
    } else {
        NSLog(@"Hidden NO");
        //        [self.DocumentViewController setEnableBottomBar:YES];
        [self.DocumentViewController setEnableAlwaysVisible:YES];
        [self.DocumentViewController setNavigationToolBarHidden:NO];
        //        [self.DocumentViewController setEnableBottomBar:NO];
    }
    
    //    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.5 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
    //        [self.inkPopoverController dismissPopoverAnimated:NO];
    //        [self.penPopoverController dismissPopoverAnimated:NO];
    //        [self.DocumentViewController releaseTools];
    //        if(UsingInk == YES){ [self.DocumentViewController setTool:PlugPDFInkTool]; }
    //        else if(UsingSquare == YES){ [self.DocumentViewController setTool:PlugPDFSquareTool]; }
    //        else if(UsingCircle == YES){ [self.DocumentViewController setTool:PlugPDFCircleTool]; }
    //        else if(UsingHighlight == YES){ [self.DocumentViewController setTool:PlugPDFTextHighlightTool]; }
    //        else if(UsingUnderline == YES){ [self.DocumentViewController setTool:PlugPDFTextUnderlineTool]; }
    //        else if(UsingCancle == YES){ [self.DocumentViewController setTool:PlugPDFTextStrikeoutTool]; }
    //        else if(UsingNote == YES){ [self.DocumentViewController setTool:PlugPDFNoteTool]; }
    //        else if(UsingEraser == YES){ [self.DocumentViewController setTool:PlugPDFEraserTool]; }
    //    });
    return NO;
}

- (void)pageDidChange:(PlugPDFDocumentView *)documentView pageIdx:(NSInteger)pageIdx
{
    self.DocumentViewController.enablePageIndicatorButton = YES;
    if(UsingInk == YES || UsingSquare == YES || UsingCircle == YES || UsingHighlight == YES || UsingUnderline == YES || UsingCancle == YES || UsingNote == YES || UsingEraser == YES){
        [self.DocumentViewController releaseTools];
    }
    
    CGSize documentSize = [self.DocumentViewController.documentView.document pageSize:0];
    CGFloat documentHeight = documentSize.height;
    CGFloat documentWidth = documentSize.width;
    CGFloat windowHeight = CGRectGetHeight(self.window.frame);
    CGFloat windowWidth = CGRectGetWidth(self.window.frame);
    
    if([[[NSUserDefaults standardUserDefaults] valueForKey:@"documentPreview"] isEqualToString:@"use"])
    {
        if(windowWidth < 1000) {    // 썸네일
            [self.DocumentViewController setEnableThumbnailMultiplePagePreview:NO];
            [self.DocumentViewController setEnableThumbnailPagePreview:YES];
            
            if(documentWidth > documentHeight){
                [self.DocumentViewController setPagePreviewRect:CGRectMake(0.01, (windowHeight-documentHeight*(windowWidth/documentWidth))/2, windowWidth, documentHeight*(windowWidth/documentWidth))];
            } else {
                if(windowWidth < 700)
                    [self.DocumentViewController setPagePreviewRect:CGRectMake(0.01, (windowHeight-documentHeight*(windowWidth/documentWidth))/2, windowWidth, documentHeight*(windowWidth/documentWidth))];
                else
                    [self.DocumentViewController setPagePreviewRect:CGRectMake((windowWidth-(documentWidth*(windowHeight/documentHeight)))/2, 0.01, documentWidth*(windowHeight/documentHeight), windowHeight)];
            }
        } else {    // 썸네일
            [self.DocumentViewController setEnableThumbnailMultiplePagePreview:YES];
            [self.DocumentViewController setEnableThumbnailPagePreview:NO];
            
            // 하단 스크롤 바 섬네일 사이즈 조정
            [self.DocumentViewController setPagePreviewSize: CGSizeMake(windowWidth/5-1, (windowWidth/5-1)*(documentSize.height/documentSize.width))];
        }
    }
    else
    {
        [self.DocumentViewController setEnableThumbnailMultiplePagePreview:NO];
        [self.DocumentViewController setEnableThumbnailPagePreview:YES];
        
        if(documentWidth > documentHeight){
            [self.DocumentViewController setPagePreviewRect:CGRectMake(0.01, (windowHeight-documentHeight*(windowWidth/documentWidth))/2, windowWidth, documentHeight*(windowWidth/documentWidth))];
        } else {
            if(windowWidth < 700)
                [self.DocumentViewController setPagePreviewRect:CGRectMake(0.01, (windowHeight-documentHeight*(windowWidth/documentWidth))/2, windowWidth, documentHeight*(windowWidth/documentWidth))];
            else
                [self.DocumentViewController setPagePreviewRect:CGRectMake((windowWidth-(documentWidth*(windowHeight/documentHeight)))/2, 0.01, documentWidth*(windowHeight/documentHeight), windowHeight)];
        }
    }
    

    NSLog(@"pageDidChange pageIdx = %d", (int)pageIdx);
    //    if(isEbook){
    //        if((pageIdx%2 == 1 && pageIdx != 0)) {
    //            [self.DocumentViewController gotoPage:self.DocumentViewController.pageIdx-1 fitToScreen:YES];
    //        }
    //    }
    
    NSLog(@"pageDidChanged");
    NSString* pageIndex = [NSString stringWithFormat:@"%d", (int)self.DocumentViewController.pageIdx+1];
    pageIndex = [pageIndex stringByAppendingString:@" / "];
    pageIndex = [pageIndex stringByAppendingString:[NSString stringWithFormat:@"%d", (int)self.DocumentViewController.pageCount]];
    self.pageIndicator.text = pageIndex;
    //    int orientation = [[UIApplication sharedApplication] statusBarOrientation];
    //    CGFloat windowWidth = CGRectGetWidth(self.window.frame);
    //    if(((int)orientation == 3 || (int)orientation == 4)){
    //    if(isEbook){
    //        if((pageIdx%2 == 1 && pageIdx != 0)) {
    //            NSLog(@"go");
    //            [self.DocumentViewController gotoPage:self.DocumentViewController.pageIdx-1 fitToScreen:YES];
    //        }
    //    }
    
    if(self.DocumentViewController.displayMode != PlugPDFDocumentDisplayModeThumbnail){
        if(isEbook){
            [self.displayModeButton setImage:[UIImage imageNamed:@"viewer-icon/top-icon-03-03.png"] forState:UIControlStateNormal];
        } else if(displayHorizontal){
            [self.displayModeButton setImage:[UIImage imageNamed:@"viewer-icon/top-icon-03-01.png"] forState:UIControlStateNormal];
        } else if(displayVertical) {
            [self.displayModeButton setImage:[UIImage imageNamed:@"viewer-icon/top-icon-03-02.png"] forState:UIControlStateNormal];
        }
    } else {
        //        if(displayVertical) verticalThumbnailToEbook = YES;
        int orientation = [[UIApplication sharedApplication] statusBarOrientation];
        if((int)orientation == 3 || (int)orientation == 4){
            NSLog(@"pagedidchanged Flip YES");
            if(self.DocumentViewController.pageCount == 1){
                //                [self.DocumentViewController setEnablePageFlipEffect:NO];
                isEbook = YES;
                displayVertical = NO;
                displayHorizontal = NO;
            } else {
                [self.DocumentViewController setEnablePageFlipEffect:YES];
                isEbook = YES;
                displayVertical = NO;
                displayHorizontal = NO;
            }
        } else {
            NSLog(@"pagedidchanged Flip NO");
            [self.DocumentViewController setEnablePageFlipEffect:YES];
            isEbook = NO;
            displayVertical = NO;
            displayHorizontal = YES;
        }
        CGFloat windowWidth = CGRectGetWidth(self.window.frame);
        
        UIWindow* window = [UIApplication sharedApplication].keyWindow;
        self.window.frame = window.frame;
        self.DocumentViewController.view.frame = window.frame;
        [self.navbar setFrame:CGRectMake(0, 40, CGRectGetWidth(window.bounds), 41)];
        [self.searchNavbar setFrame:CGRectMake(0, 40, CGRectGetWidth(window.bounds), 40)];
        [self.searchBar setFrame:CGRectMake(60, 0, CGRectGetWidth(window.bounds) - 160, 40)];
        if(windowWidth > 400){
            [self.pageMoveView setFrame:CGRectMake(CGRectGetWidth(self.window.frame) - 203, CGRectGetHeight(self.window.frame) - 42, 186, 40)];
        } else {
            [self.pageMoveView setFrame:CGRectMake(CGRectGetWidth(self.window.frame) - 203, CGRectGetHeight(self.window.frame) - 42, 186, 40)];
        }
        
        [self.displayBtnView setFrame: CGRectMake(CGRectGetWidth(self.window.frame)-45, 50, 30, 30)];
        [self.closeBtnView setFrame: CGRectMake(25, 50, 30, 30)];
        [self.tapBar setFrame:CGRectMake(0, 0, CGRectGetWidth(self.window.frame), 40)];
        self.backgroundTapView = [[UIView alloc] initWithFrame:CGRectMake(self.tapBar.frame.size.width-80, 0, 40, 40)];
        self.closeAllTapView = [[UIView alloc] initWithFrame:CGRectMake(self.tapBar.frame.size.width-40, 0, 40, 40)];
        [_collectionView setFrame:CGRectMake(0, 0, CGRectGetWidth(self.tapBar.frame)-100, 40)];
    }
    
    if(isEbook && pageIdx+1 == self.DocumentViewController.pageCount){
        if(UsingInk == YES || UsingSquare == YES || UsingCircle == YES || UsingHighlight == YES || UsingUnderline == YES || UsingCancle == YES || UsingNote == YES || UsingEraser == YES){
            [self.DocumentViewController.documentView removeGestureRecognizer:self.longPress];
            [self.DocumentViewController releaseTools];
        } else {
            [self.DocumentViewController.documentView addGestureRecognizer:self.longPress];
        }
        if(UsingInk == YES){
            NSLog(@"pagedidchanged inkTool Using");
            //            [[self.DocumentViewController.documentView pageView:self.DocumentViewController.pageIdx-1] setTool:PlugPDFInkTool];
            [self.DocumentViewController setTool:PlugPDFInkTool];
        } else if(UsingSquare == YES){
            //            [[self.DocumentViewController.documentView pageView:self.DocumentViewController.pageIdx-1] setTool:PlugPDFSquareTool];
            [self.DocumentViewController setTool:PlugPDFSquareTool];
            [self.DocumentViewController setShapeWidth:squareBoldValue];
            [self.DocumentViewController setSquareAnnotColor:self.exampleSquareColor];
            [self.DocumentViewController setShapeColor:self.exampleSquareCornerColor];
            [self.DocumentViewController setSquareAnnotOpacity:1.0];
            if([[UIColor clearColor] isEqual:self.exampleSquareColor]){
                [self.DocumentViewController setSquareAnnotTransparent:YES];
            } else {
                [self.DocumentViewController setSquareAnnotTransparent:NO];
            }
        } else if(UsingCircle == YES){
            //            [[self.DocumentViewController.documentView pageView:self.DocumentViewController.pageIdx-1] setTool:PlugPDFCircleTool];
            [self.DocumentViewController setTool:PlugPDFCircleTool];
            [self.DocumentViewController setShapeWidth:circleBoldValue];
            [self.DocumentViewController setCircleAnnotColor:self.exampleCircleColor];
            [self.DocumentViewController setShapeColor:self.exampleCircleCornerColor];
            [self.DocumentViewController setCircleAnnotOpacity:1.0];
            if([[UIColor clearColor] isEqual:self.exampleCircleColor]){
                [self.DocumentViewController setCircleAnnotTransparent:YES];
            } else {
                [self.DocumentViewController setCircleAnnotTransparent:NO];
            }
        } else if(UsingHighlight == YES){
            //            [[self.DocumentViewController.documentView pageView:self.DocumentViewController.pageIdx-1] setTool:PlugPDFTextHighlightTool];
            [self.DocumentViewController setTool:PlugPDFTextHighlightTool];
        } else if(UsingUnderline == YES){
            //            [[self.DocumentViewController.documentView pageView:self.DocumentViewController.pageIdx-1] setTool:PlugPDFTextUnderlineTool];
            [self.DocumentViewController setTool:PlugPDFTextUnderlineTool];
        } else if(UsingCancle == YES){
            //            [[self.DocumentViewController.documentView pageView:self.DocumentViewController.pageIdx-1] setTool:PlugPDFTextStrikeoutTool];
            [self.DocumentViewController setTool:PlugPDFTextStrikeoutTool];
        } else if(UsingNote == YES){
            //            [[self.DocumentViewController.documentView pageView:self.DocumentViewController.pageIdx-1] setTool:PlugPDFNoteTool];
            [self.DocumentViewController setTool:PlugPDFNoteTool];
        } else if(UsingEraser == YES){
            //            [[self.DocumentViewController.documentView pageView:self.DocumentViewController.pageIdx-1] setTool:PlugPDFEraserTool];
            [self.DocumentViewController setTool:PlugPDFEraserTool];
        }
    } else {
        if(UsingInk == YES || UsingSquare == YES || UsingCircle == YES || UsingHighlight == YES || UsingUnderline == YES || UsingCancle == YES || UsingNote == YES || UsingEraser == YES){
            [self.DocumentViewController.documentView removeGestureRecognizer:self.longPress];
            [self.DocumentViewController releaseTools];
        } else {
            [self.DocumentViewController.documentView addGestureRecognizer:self.longPress];
        }
        if(UsingInk == YES){ NSLog(@"pagedidchanged inkTool Using"); [self.DocumentViewController setTool:PlugPDFInkTool]; }
        else if(UsingSquare == YES){
            [self.DocumentViewController setTool:PlugPDFSquareTool];
            [self.DocumentViewController setShapeWidth:squareBoldValue];
            [self.DocumentViewController setSquareAnnotColor:self.exampleSquareColor];
            [self.DocumentViewController setShapeColor:self.exampleSquareCornerColor];
            [self.DocumentViewController setSquareAnnotOpacity:1.0];
            if([[UIColor clearColor] isEqual:self.exampleSquareColor]){
                [self.DocumentViewController setSquareAnnotTransparent:YES];
            } else {
                [self.DocumentViewController setSquareAnnotTransparent:NO];
            }
        } else if(UsingCircle == YES){
            [self.DocumentViewController setTool:PlugPDFCircleTool];
            [self.DocumentViewController setShapeWidth:circleBoldValue];
            [self.DocumentViewController setCircleAnnotColor:self.exampleCircleColor];
            [self.DocumentViewController setShapeColor:self.exampleCircleCornerColor];
            [self.DocumentViewController setCircleAnnotOpacity:1.0];
            if([[UIColor clearColor] isEqual:self.exampleCircleColor]){
                [self.DocumentViewController setCircleAnnotTransparent:YES];
            } else {
                [self.DocumentViewController setCircleAnnotTransparent:NO];
            }
        } else if(UsingHighlight == YES){
            [self.DocumentViewController setTool:PlugPDFTextHighlightTool];
        } else if(UsingUnderline == YES){
            [self.DocumentViewController setTool:PlugPDFTextUnderlineTool];
        } else if(UsingCancle == YES){
            [self.DocumentViewController setTool:PlugPDFTextStrikeoutTool];
        } else if(UsingNote == YES){
            [self.DocumentViewController setTool:PlugPDFNoteTool];
        } else if(UsingEraser == YES){
            [self.DocumentViewController setTool:PlugPDFEraserTool];
        }
    }
    
    if(isHidden){
        [[self.DocumentViewController navigationController] setToolbarHidden:YES animated: NO];
    }
    
    pagedidchange = YES;
}

-(void)pageDidLoad:(PlugPDFDocumentView *)documentView pageIdx:(NSInteger)pageIdx{
    if(UsingInk == YES || UsingSquare == YES || UsingCircle == YES || UsingHighlight == YES || UsingUnderline == YES || UsingCancle == YES || UsingNote == YES || UsingEraser == YES){
        [self.DocumentViewController releaseTools];
    }
    
    NSLog(@"pageDidLoad %d", (int)pageIdx);
    NSString* pageIndex = [NSString stringWithFormat:@"%d", (int)self.DocumentViewController.pageIdx+1];
    pageIndex = [pageIndex stringByAppendingString:@" / "];
    pageIndex = [pageIndex stringByAppendingString:[NSString stringWithFormat:@"%d", (int)self.DocumentViewController.pageCount]];
    self.pageIndicator.text = pageIndex;
    
    CGSize documentSize = [self.DocumentViewController.documentView.document pageSize:0];
    CGFloat documentHeight = documentSize.height;
    CGFloat documentWidth = documentSize.width;
    CGFloat windowHeight = CGRectGetHeight(self.window.frame);
    CGFloat windowWidth = CGRectGetWidth(self.window.frame);
    
    if([[[NSUserDefaults standardUserDefaults] valueForKey:@"documentPreview"] isEqualToString:@"use"])
    {
        if(windowWidth < 1000) {    // 썸네일
            [self.DocumentViewController setEnableThumbnailMultiplePagePreview:NO];
            [self.DocumentViewController setEnableThumbnailPagePreview:YES];
            
            if(documentWidth > documentHeight){
                [self.DocumentViewController setPagePreviewRect:CGRectMake(0.01, (windowHeight-documentHeight*(windowWidth/documentWidth))/2, windowWidth, documentHeight*(windowWidth/documentWidth))];
            } else {
                if(windowWidth < 700)
                    [self.DocumentViewController setPagePreviewRect:CGRectMake(0.01, (windowHeight-documentHeight*(windowWidth/documentWidth))/2, windowWidth, documentHeight*(windowWidth/documentWidth))];
                else
                    [self.DocumentViewController setPagePreviewRect:CGRectMake((windowWidth-(documentWidth*(windowHeight/documentHeight)))/2, 0.01, documentWidth*(windowHeight/documentHeight), windowHeight)];
            }
        } else {    // 썸네일
            [self.DocumentViewController setEnableThumbnailMultiplePagePreview:YES];
            [self.DocumentViewController setEnableThumbnailPagePreview:NO];
            
            // 하단 스크롤 바 섬네일 사이즈 조정
            [self.DocumentViewController setPagePreviewSize: CGSizeMake(windowWidth/5-1, (windowWidth/5-1)*(documentSize.height/documentSize.width))];
        }
    }
    else
    {
        [self.DocumentViewController setEnableThumbnailMultiplePagePreview:NO];
        [self.DocumentViewController setEnableThumbnailPagePreview:YES];
        
        if(documentWidth > documentHeight){
            [self.DocumentViewController setPagePreviewRect:CGRectMake(0.01, (windowHeight-documentHeight*(windowWidth/documentWidth))/2, windowWidth, documentHeight*(windowWidth/documentWidth))];
        } else {
            if(windowWidth < 700)
                [self.DocumentViewController setPagePreviewRect:CGRectMake(0.01, (windowHeight-documentHeight*(windowWidth/documentWidth))/2, windowWidth, documentHeight*(windowWidth/documentWidth))];
            else
                [self.DocumentViewController setPagePreviewRect:CGRectMake((windowWidth-(documentWidth*(windowHeight/documentHeight)))/2, 0.01, documentWidth*(windowHeight/documentHeight), windowHeight)];
        }
    }

    if(windowWidth > 1000) self.backBtn.title = self.title;
    else self.backBtn.title = self.backBtn.title = @"";
    
    if(hiddenClose) {
        [self.tapBar setHidden:YES];
        hiddenClose = NO;
    }
    
    if(fromOrientation){
        
        int orientation = [[UIApplication sharedApplication] statusBarOrientation];
        //        if((int)orientation == 3 || (int)orientation == 4){
        //            if(isEbook){
        //                if(self.DocumentViewController.pageIdx+1 == self.DocumentViewController.pageCount)
        //                    [self.DocumentViewController gotoPage:self.DocumentViewController.pageIdx-1 fitToScreen:YES];
        //            }
        //        }
        
        if(openViewer){
            NSRange strRange1 = [urlpath rangeOfString:@".xlsx"];
            NSRange strRange2 = [urlpath rangeOfString:@".xls"];
            NSRange strRange3 = [urlpath rangeOfString:@".docx"];
            NSRange strRange4 = [urlpath rangeOfString:@".doc"];
            NSRange strRange5 = [urlpath rangeOfString:@".hwp"];
            NSRange strRange6 = [urlpath rangeOfString:@".pptx"];
            NSRange strRange7 = [urlpath rangeOfString:@".ppt"];
            NSRange strRange8 = [urlpath rangeOfString:@".pdf"];
            
            BOOL exist = NO;
            if (strRange1.location != NSNotFound || strRange2.location != NSNotFound || strRange3.location != NSNotFound || strRange4.location != NSNotFound || strRange5.location != NSNotFound || strRange6.location != NSNotFound || strRange7.location != NSNotFound || strRange8.location != NSNotFound) {
                exist = YES;
            }
            if(exist){
                AppDelegate *AD = [[UIApplication sharedApplication] delegate];
                [AD application:[UIApplication sharedApplication] supportedInterfaceOrientationsForWindow:self.window];
                int orientation = [[UIApplication sharedApplication] statusBarOrientation];
                NSLog(@"orientationChanged:%d", (int)orientation);
                
                if((int)orientation == 3 || (int)orientation == 4) isHorizontal = YES;
                else isHorizontal = NO;
                
                
                
                //        if((int)orientation == 3 || (int)orientation == 4){
                //            if(self.DocumentViewController.pageIdx%2 == 1 && self.DocumentViewController.pageIdx != 0) {
                //                [self.DocumentViewController gotoPage:self.DocumentViewController.pageIdx-1 fitToScreen:YES];
                //            }
                //        }
            }
            //        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.01 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            CGSize documentSize = [self.DocumentViewController.documentView.document pageSize:0];
            CGFloat documentHeight = documentSize.height;
            CGFloat documentWidth = documentSize.width;
            CGFloat windowHeight = CGRectGetHeight(self.window.frame);
            CGFloat windowWidth = CGRectGetWidth(self.window.frame);
            
            UIWindow* window = [UIApplication sharedApplication].keyWindow;
            self.window.frame = window.frame;
            self.DocumentViewController.view.frame = window.frame;
            
            [self.navbar setFrame: CGRectMake(0, 40, CGRectGetWidth(window.bounds), 41)];
            [self.hideView setFrame: CGRectMake(self.navbar.frame.size.width-40, 0, 40, 40)];
            [self.handView setFrame: CGRectMake(self.navbar.frame.size.width-82.5, 0, 40, 40)];
            [self.inkView setFrame: CGRectMake(self.navbar.frame.size.width-120, 0, 40, 40)];
            [self.eraserView setFrame:CGRectMake(self.navbar.frame.size.width-160, 0, 40, 40)];
            [self.penView setFrame:CGRectMake(self.navbar.frame.size.width-200, 0, 40, 40)];
            [self.searchView setFrame:CGRectMake(self.navbar.frame.size.width-240, 0, 40, 40)];
            [self.bookMarkView setFrame:CGRectMake(self.navbar.frame.size.width-280, 0, 40, 40)];
            [self.displayModeView setFrame:CGRectMake(self.navbar.frame.size.width-320, 0, 40, 40)];
            [self.saveView setFrame:CGRectMake(self.navbar.frame.size.width-360, 0, 40, 40)];
            
            [self.backSearchView setFrame:CGRectMake(self.window.frame.size.width-90, 0, 40, 40)];
            [self.forSearchView setFrame:CGRectMake(self.window.frame.size.width-50, 0, 40, 40)];
            
            
            
            [self.searchNavbar setFrame:CGRectMake(0, 40, CGRectGetWidth(window.bounds), 40)];
            [self.searchBar setFrame:CGRectMake(60, 0, CGRectGetWidth(window.bounds) - 160, 40)];
            if(windowWidth > 400){
                [self.pageMoveView setFrame:CGRectMake(CGRectGetWidth(self.window.frame) - 203, CGRectGetHeight(self.window.frame) - 42, 186, 40)];
            } else {
                [self.pageMoveView setFrame:CGRectMake(CGRectGetWidth(self.window.frame) - 203, CGRectGetHeight(self.window.frame) - 42, 186, 40)];
            }
            
            [self.displayBtnView setFrame: CGRectMake(CGRectGetWidth(self.window.frame)-45, 50, 30, 30)];
            [self.closeBtnView setFrame: CGRectMake(25, 50, 30, 30)];
            [self.tapBar setFrame:CGRectMake(0, 0, CGRectGetWidth(self.window.frame), 40)];
            self.backgroundTapView = [[UIView alloc] initWithFrame:CGRectMake(self.tapBar.frame.size.width-80, 0, 40, 40)];
            self.closeAllTapView = [[UIView alloc] initWithFrame:CGRectMake(self.tapBar.frame.size.width-40, 0, 40, 40)];
            [_collectionView setFrame:CGRectMake(0, 0, CGRectGetWidth(self.tapBar.frame)-100, 40)];
            
            [self.tapBar removeFromSuperview];
            [_collectionView removeFromSuperview];
            NSLog(@"initCollectionView");
            self.tapBar = [[UIView alloc] initWithFrame:CGRectMake(0, 0, CGRectGetWidth(self.window.frame), 40)];
            self.tapBar.backgroundColor = [UIColor colorWithRed:0.03 green:0.16 blue:0.32 alpha:0.70];
            UICollectionViewFlowLayout *layout=[[UICollectionViewFlowLayout alloc] init];
            _collectionView=[[UICollectionView alloc] initWithFrame:CGRectMake(0, 0, CGRectGetWidth(self.tapBar.frame)-100, 40) collectionViewLayout:layout];
            [_collectionView setDataSource:self];
            [_collectionView setDelegate:self];
            
            int orientation = [[UIApplication sharedApplication] statusBarOrientation];
            NSLog(@"windowWidth = %f", windowWidth);
            if(windowWidth > 1200){
                cellSize = (CGRectGetWidth(self.tapBar.frame)-100)/4;
            } else if (windowWidth < 1200 && windowWidth > 700) {
                cellSize = (CGRectGetWidth(self.tapBar.frame)-100)/3;
            } else {
                cellSize = (CGRectGetWidth(self.tapBar.frame)-100)/3;
            }
            
            [_collectionView registerClass:[UICollectionViewCell class] forCellWithReuseIdentifier:@"cellIdentifier"];
            [_collectionView setBackgroundColor:[UIColor colorWithRed:0.03 green:0.16 blue:0.32 alpha:0.70]];
            [_collectionView setShowsHorizontalScrollIndicator:YES];
            
            ((UICollectionViewFlowLayout *)_collectionView.collectionViewLayout).scrollDirection = UICollectionViewScrollDirectionHorizontal;
            [_collectionView setAlwaysBounceHorizontal:YES];
            ((UICollectionViewFlowLayout *)_collectionView.collectionViewLayout).minimumLineSpacing = 0; // 셀 간격
            [_collectionView setAllowsMultipleSelection:NO];
            
            self.backgroundTapView = [[UIView alloc] initWithFrame:CGRectMake(self.tapBar.frame.size.width-80, 0, 40, 40)];
            self.backGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(BackgroundTap:)];
            [self.backgroundTapView addGestureRecognizer:self.backGesture];
            
            self.backgroundTap = [[UIButton alloc] initWithFrame: CGRectMake(0, 10, 20, 20)];
            [self.backgroundTap setImage:[UIImage imageNamed:@"viewer-icon/home.png"] forState:UIControlStateNormal];
            [self.backgroundTap addTarget: self action: @selector(BackgroundTap:) forControlEvents: UIControlEventTouchUpInside];
            [self.backgroundTapView addSubview:self.backgroundTap];
            [self.tapBar addSubview:self.backgroundTapView];
            
            self.closeAllTapView = [[UIView alloc] initWithFrame:CGRectMake(self.tapBar.frame.size.width-40, 0, 40, 40)];
            self.allCloseGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(CloseAllTap:)];
            [self.closeAllTapView addGestureRecognizer:self.allCloseGesture];
            
            self.closeAllTap = [[UIButton alloc] initWithFrame: CGRectMake(0, 10, 20, 20)];
            [self.closeAllTap setImage:[UIImage imageNamed:@"viewer-icon/tap-close-03.png"] forState:UIControlStateNormal];
            [self.closeAllTap addTarget: self action: @selector(CloseAllTap:) forControlEvents: UIControlEventTouchUpInside];
            [self.closeAllTapView addSubview:self.closeAllTap];
            [self.tapBar addSubview:self.closeAllTapView];
            
            [self.tapBar addSubview:_collectionView];
            [self.AD.navigationController.view addSubview:self.tapBar];
            
            if(isHidden) [self.tapBar setHidden:YES];
            else [self.tapBar setHidden:NO];
            
            // 탭 자동 이동
            int i = 1;
            for (id key in self.AD.VCDic) {
                if([key isEqualToString:self.pdfPath]){
                    break;
                }
                i = i + 1;
            }
            
            if(windowWidth > 1200){
                if(self.AD.VCDic.count > 4){
                    long movePoint = (long)(i-4)*cellSize;
                    if(movePoint < 1) movePoint = 0;
                    [_collectionView setContentOffset:CGPointMake(movePoint, 0) animated:YES];
                }
            } else if (windowWidth < 1200 && windowWidth > 700) {
                if(self.AD.VCDic.count > 3){
                    long movePoint = (long)(i-3)*cellSize;
                    if(movePoint < 1) movePoint = 0;
                    [_collectionView setContentOffset:CGPointMake(movePoint, 0) animated:YES];
                }
            } else {
                if(self.AD.VCDic.count > 3){
                    long movePoint = (long)(i-3)*cellSize;
                    if(movePoint < 1) movePoint = 0;
                    [_collectionView setContentOffset:CGPointMake(movePoint, 0) animated:YES];
                }
            }
            
            click = 0;
            [self collectionView:_collectionView didSelectItemAtIndexPath:[NSIndexPath indexPathForRow:index inSection:0]];
        }
        fromOrientation = NO;
    }
    //    });
    
    
    
    if(isEbook && pageIdx+1 == self.DocumentViewController.pageCount){
        if(UsingInk == YES || UsingSquare == YES || UsingCircle == YES || UsingHighlight == YES || UsingUnderline == YES || UsingCancle == YES || UsingNote == YES || UsingEraser == YES){
            [self.DocumentViewController.documentView removeGestureRecognizer:self.longPress];
            [self.DocumentViewController releaseTools];
        } else {
            [self.DocumentViewController.documentView addGestureRecognizer:self.longPress];
        }
        if(UsingInk == YES){
            NSLog(@"pagedidload inkTool Using");
            //            [[self.DocumentViewController.documentView pageView:self.DocumentViewController.pageIdx-1] setTool:PlugPDFInkTool];
            [self.DocumentViewController setTool:PlugPDFInkTool];
        } else if(UsingSquare == YES){
            //            [[self.DocumentViewController.documentView pageView:self.DocumentViewController.pageIdx-1] setTool:PlugPDFSquareTool];
            [self.DocumentViewController setTool:PlugPDFSquareTool];
            [self.DocumentViewController setShapeWidth:squareBoldValue];
            [self.DocumentViewController setSquareAnnotColor:self.exampleSquareColor];
            [self.DocumentViewController setShapeColor:self.exampleSquareCornerColor];
            [self.DocumentViewController setSquareAnnotOpacity:1.0];
            if([[UIColor clearColor] isEqual:self.exampleSquareColor]){
                [self.DocumentViewController setSquareAnnotTransparent:YES];
            } else {
                [self.DocumentViewController setSquareAnnotTransparent:NO];
            }
        } else if(UsingCircle == YES){
            //            [[self.DocumentViewController.documentView pageView:self.DocumentViewController.pageIdx-1] setTool:PlugPDFCircleTool];
            [self.DocumentViewController setTool:PlugPDFCircleTool];
            [self.DocumentViewController setShapeWidth:circleBoldValue];
            [self.DocumentViewController setCircleAnnotColor:self.exampleCircleColor];
            [self.DocumentViewController setShapeColor:self.exampleCircleCornerColor];
            [self.DocumentViewController setCircleAnnotOpacity:1.0];
            if([[UIColor clearColor] isEqual:self.exampleCircleColor]){
                [self.DocumentViewController setCircleAnnotTransparent:YES];
            } else {
                [self.DocumentViewController setCircleAnnotTransparent:NO];
            }
        } else if(UsingHighlight == YES){
            //            [[self.DocumentViewController.documentView pageView:self.DocumentViewController.pageIdx-1] setTool:PlugPDFTextHighlightTool];
            [self.DocumentViewController setTool:PlugPDFTextHighlightTool];
        } else if(UsingUnderline == YES){
            //            [[self.DocumentViewController.documentView pageView:self.DocumentViewController.pageIdx-1] setTool:PlugPDFTextUnderlineTool];
            [self.DocumentViewController setTool:PlugPDFTextUnderlineTool];
        } else if(UsingCancle == YES){
            //            [[self.DocumentViewController.documentView pageView:self.DocumentViewController.pageIdx-1] setTool:PlugPDFTextStrikeoutTool];
            [self.DocumentViewController setTool:PlugPDFTextStrikeoutTool];
        } else if(UsingNote == YES){
            //            [[self.DocumentViewController.documentView pageView:self.DocumentViewController.pageIdx-1] setTool:PlugPDFNoteTool];
            [self.DocumentViewController setTool:PlugPDFNoteTool];
        } else if(UsingEraser == YES){
            //            [[self.DocumentViewController.documentView pageView:self.DocumentViewController.pageIdx-1] setTool:PlugPDFEraserTool];
            [self.DocumentViewController setTool:PlugPDFEraserTool];
        }
    } else {
        if(UsingInk == YES || UsingSquare == YES || UsingCircle == YES || UsingHighlight == YES || UsingUnderline == YES || UsingCancle == YES || UsingNote == YES || UsingEraser == YES){
            [self.DocumentViewController.documentView removeGestureRecognizer:self.longPress];
            [self.DocumentViewController releaseTools];
        } else {
            [self.DocumentViewController.documentView addGestureRecognizer:self.longPress];
        }
        if(UsingInk == YES){ NSLog(@"pagedidload inkTool Using"); [self.DocumentViewController setTool:PlugPDFInkTool]; }
        else if(UsingSquare == YES){
            [self.DocumentViewController setTool:PlugPDFSquareTool];
            [self.DocumentViewController setShapeWidth:squareBoldValue];
            [self.DocumentViewController setSquareAnnotColor:self.exampleSquareColor];
            [self.DocumentViewController setShapeColor:self.exampleSquareCornerColor];
            [self.DocumentViewController setSquareAnnotOpacity:1.0];
            if([[UIColor clearColor] isEqual:self.exampleSquareColor]){
                [self.DocumentViewController setSquareAnnotTransparent:YES];
            } else {
                [self.DocumentViewController setSquareAnnotTransparent:NO];
            }
        } else if(UsingCircle == YES){
            [self.DocumentViewController setTool:PlugPDFCircleTool];
            [self.DocumentViewController setShapeWidth:circleBoldValue];
            [self.DocumentViewController setCircleAnnotColor:self.exampleCircleColor];
            [self.DocumentViewController setShapeColor:self.exampleCircleCornerColor];
            [self.DocumentViewController setCircleAnnotOpacity:1.0];
            if([[UIColor clearColor] isEqual:self.exampleCircleColor]){
                [self.DocumentViewController setCircleAnnotTransparent:YES];
            } else {
                [self.DocumentViewController setCircleAnnotTransparent:NO];
            }
        } else if(UsingHighlight == YES){
            [self.DocumentViewController setTool:PlugPDFTextHighlightTool];
        }
        else if(UsingUnderline == YES){
            [self.DocumentViewController setTool:PlugPDFTextUnderlineTool];
        }
        else if(UsingCancle == YES){
            [self.DocumentViewController setTool:PlugPDFTextStrikeoutTool];
        }
        else if(UsingNote == YES){
            [self.DocumentViewController setTool:PlugPDFNoteTool];
        }
        else if(UsingEraser == YES){
            [self.DocumentViewController setTool:PlugPDFEraserTool];
            NSLog(@"pageDidLoad eraser");
        }
    }
    
    if(fromCellClick){
        NSLog(@"refreshView");
        fromCellClick = NO;
        //        [self.DocumentViewController refreshView];
    }
    
    //화면 돌아갈 때 popup 위치 다시 잡아주기
    if(penPopup){
        [self.penPopoverController dismissPopoverAnimated:NO];
        //        [self.penPopoverController presentPopoverFromRect:CGRectMake(CGRectGetWidth(self.inkBtn.imageView.frame)/2, 40, 0, 0) inView:self.inkBtn.imageView permittedArrowDirections:UIPopoverArrowDirectionUp animated:YES];
        //        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.5 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        //        self.penPopoverController.passthroughViews = self.viewArray;
        //        });
        penPopup = NO;
    } else if (eraserPopup) {
        [self.eraserPopoverController dismissPopoverAnimated:NO];
        eraserPopup = NO;
        //        [self.eraserPopoverController presentPopoverFromRect:CGRectMake(CGRectGetWidth(self.eraserBtn.imageView.frame)/2, 40, 0, 0) inView:self.eraserBtn.imageView permittedArrowDirections:UIPopoverArrowDirectionUp animated:YES];
        //        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.5 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        //        self.eraserPopoverController.passthroughViews = self.viewArray;
        //        });
    } else if (inkPopup) {
        [self.inkPopoverController dismissPopoverAnimated:NO];
        inkPopup = NO;
        //        [self.inkPopoverController presentPopoverFromRect:CGRectMake(CGRectGetWidth(self.inkButton.imageView.frame)/2, 40, 0, 0) inView:self.inkButton.imageView permittedArrowDirections:UIPopoverArrowDirectionUp animated:YES];
        //        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.5 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        //        if(activateNoteMode){
        //            if(firstOnTapUp){
        //                    [self.noteBtn sendActionsForControlEvents:UIControlEventTouchUpInside];
        //            } else {
        //                [self.noteBtn sendActionsForControlEvents:UIControlEventTouchUpInside];
        //            }
        //        } else {
        //            if(inkMode == 1){
        //                [self.highlightBtn sendActionsForControlEvents:UIControlEventTouchUpInside];
        //            } else if (inkMode == 2){
        //                [self.underlineBtn sendActionsForControlEvents:UIControlEventTouchUpInside];
        //            } else if(inkMode == 3){
        //                [self.cancleBtn sendActionsForControlEvents:UIControlEventTouchUpInside];
        //            } else if(inkMode == 4){
        //                [self.squareBtn sendActionsForControlEvents:UIControlEventTouchUpInside];
        //            } else if(inkMode == 5){
        //                [self.circleBtn sendActionsForControlEvents:UIControlEventTouchUpInside];
        //            }
        //        }
        //            });
    } else if (displayPopup) {
        [self.displayPopoverController dismissPopoverAnimated:NO];
        displayPopup = NO;
        //        [self.displayPopoverController presentPopoverFromRect:CGRectMake(CGRectGetWidth(self.displayModeButton.imageView.frame)/2, 40, 0, 0) inView:self.displayModeButton.imageView permittedArrowDirections:UIPopoverArrowDirectionUp animated:YES];
    } else if (bookmarkPopup) {
        [self.BMpopoverController dismissPopoverAnimated:NO];
        bookmarkPopup = NO;
        //        [self.BMpopoverController presentPopoverFromRect:CGRectMake(CGRectGetWidth(self.bookMarkButton.imageView.frame)/2, 40, 0, 0) inView:self.bookMarkButton.imageView permittedArrowDirections:UIPopoverArrowDirectionUp animated:YES];
    }
    
    if((int)self.DocumentViewController.pageIdx == (int)pageIdx)
    {
        loadcount++;
        if(loadcount == 1)
            [self.DocumentViewController refreshView];
        else if (loadcount == 2)
            loadcount = 0;
    }
}

// 손으로 페이지 넘길 때 받는 콜백
- (void)pageWillChangeWithPageFlipEffect:(PlugPDFDocumentView *)documentView pageIdx:(NSInteger)pageIdx{
    if(UsingNote){
        UsingNote = NO;
        activateNoteMode = NO;
        [self.handButton sendActionsForControlEvents:UIControlEventTouchUpInside];
    }
    NSLog(@"pageWillChangeWithPageFlipEffect");
    if(pageIdx+1 == self.DocumentViewController.pageCount){
        fromPageFlip = YES;
    }
}

-(BOOL)onSwipe:(UISwipeGestureRecognizer *)swipe{
    NSLog(@"onSwipe");
    return NO;
}

#pragma mark - UITableViewDataSource
// number of section(s), now I assume there is only 1 section
- (NSInteger)numberOfSectionsInTableView:(UITableView *)theTableView
{
    return numberOfSection;
}

// number of row in the section, I assume there is only 1 row
- (NSInteger)tableView:(UITableView *)theTableView numberOfRowsInSection:(NSInteger)section
{
    //if the current view is in editing mode
    //add an extra row
    //    int addRow = [self.BMtableView isEditing] ? 1 : 0;
    return self.tabledata.count;
    //    return 1;
}

#pragma mark - UITableViewDelegate
// when user tap the row, what action you want to perform
- (void)tableView:(UITableView *)theTableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    //deselect the selected row with animatiion
    [self.BMtableView deselectRowAtIndexPath:indexPath animated:YES];
    
    //if the selected  row was the "Add Row" row call tableView:commitEditingStyle:
    //to add a new row
    if (indexPath.row >= self.tabledata.count && [self.BMtableView isEditing]) {
        [self tableView:self.BMtableView commitEditingStyle:UITableViewCellEditingStyleInsert forRowAtIndexPath:indexPath];
    }
    
    UITableViewCell *cell = [self.BMtableView cellForRowAtIndexPath:indexPath];
    NSLog(@"BookMark Page : %@", cell.detailTextLabel.text);
    NSInteger getPage = [cell.detailTextLabel.text intValue];
    [self.DocumentViewController gotoPage:getPage-1 fitToScreen:YES];
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    //    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"cell"];
    //    if(cell == nil){
    //        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"cell"];
    //    }
    
    NSString *CellIdentifier = @"Cell";
    BOOL b_addCell = (indexPath.row == self.tabledata.count);
    if (b_addCell){ // set identifier for add row
        CellIdentifier = @"AddCell";
        NSLog(@"AddCell");
    }
    
    UITableViewCell *cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleValue1
                                                   reuseIdentifier:CellIdentifier];
    
    //    if (cell == nil) {
    //        cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier] autorelease];
    //        if (!b_addCell) {
    //            cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
    //        }
    //    }
    
    //if number of rows is greater than the total number of rows in the data set
    //and this view is in editing mode.
    //Initialize the cell for "Add Row"
    //there will be an extra row once SetEditing: is called
    NSLog(@"indexPath2.row = %ld", (long)indexPath.row);
    //    if(indexPath.row == 0 && [self.BMtableView isEditing]){
    //        cell.textLabel.text = @"북마크 리스트 제목00";
    //        cell.detailTextLabel.text = [self.pagedata[indexPath.row] stringValue];
    //    }else{
    NSString* detailStr = self.pagedata[indexPath.row];
    UILabel *tempLabel=[[UILabel alloc]initWithFrame:CGRectMake(15,0,230,35)];
    tempLabel.text = self.tabledata[indexPath.row];
    [[cell contentView] addSubview:tempLabel];
    
    //            cell.textLabel.text = self.tabledata[indexPath.row];
    cell.detailTextLabel.text = self.pagedata[indexPath.row];
    //    }
    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 35;
}

-(void) setEditing:(BOOL)editing animated:(BOOL)animated{
    //call parent
    editing = YES;
    animated = YES;
    [self setEditing:editing animated:animated];
    if(isSwipeDeleting == NO){
        NSLog(@"1");
        //.. our existing code here
    }else {
        NSLog(@"2");
    }
    
    //if editing mode
    if(editing){
        //batch the table view changes so that everything happens at once
        [self.BMtableView beginUpdates];
        //for each section, insert a row at the end of the table
        for(int i = 0; i < numberOfSection; i++){
            //create an index path for the new row
            NSIndexPath *path = [NSIndexPath indexPathForRow:self.tabledata.count inSection:i];
            //insert the NSIndexPath to create a new row. NOTE: this method takes an array of paths
            [self.BMtableView insertRowsAtIndexPaths:@[path] withRowAnimation:UITableViewRowAnimationAutomatic];
        }
        //animate the changes now
        [self.BMtableView endUpdates];
    }else{
        //batch the table view changes so that everything happens at once
        [self.BMtableView beginUpdates];
        //for each section, insert a row at the end of the table
        for(int i = 0; i < numberOfSection; i++){
            //create an index path for the new row
            NSIndexPath *path = [NSIndexPath indexPathForRow:self.tabledata.count inSection:i];
            //insert the NSIndexPath to create a new row. NOTE: this method takes an array of paths
            [self.BMtableView deleteRowsAtIndexPaths:@[path] withRowAnimation:UITableViewRowAnimationAutomatic];
        }
        
        //animate the changes now
        [self.BMtableView endUpdates];
    }
}


-(UITableViewCellEditingStyle) tableView:(UITableView *)tableView editingStyleForRowAtIndexPath:(NSIndexPath *)indexPath{
    if(EditMode == 1) {
        return UITableViewCellEditingStyleInsert;
    } else if(EditMode == 2) {
        return UITableViewCellEditingStyleDelete;
    } else if(EditMode == 3) {
        return UITableViewCellEditingStyleNone;
    }
}

// 북마크 추가, 제거
- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
    NSString *appendCellName = [@(indexPath.row+1) stringValue];
    NSString *defaultCellName = nil;
    NSString *CellName = nil;
    NSIndexPath *myIP = [NSIndexPath indexPathForRow:indexPath.row+1 inSection:0] ;
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        //remove row from datasource
        [self.tabledata removeObjectAtIndex:indexPath.row];
        [self.pagedata removeObjectAtIndex:indexPath.row];
        [self.BMtableView reloadData];
        NSMutableArray *arr = [[NSMutableArray alloc] init];
        for (int i = 0; i < self.pagedata.count; i++) {
            //            NSLog(@" i = %d", i);
            PlugPDFOutlineItem* outlineItem = [[PlugPDFOutlineItem alloc] initWithParent:nil
                                                                                     idx: i
                                                                                   title: self.tabledata[i]
                                                                                 pageIdx: (long)[self.pagedata[i] integerValue]-1
                                                                                   depth: 0];
            [arr addObject: outlineItem];
        }
        NSLog(@"arr = %@", arr);
        for (int i = 0; i < arr.count; i++){
            PlugPDFOutlineItem* outline = arr[i];
            [self.DocumentViewController.document removeOutlineItem:outline];
        }
        
        [self.DocumentViewController.document updatePdfOutlineTree: arr];
        
        //remove the row in the tableView because the deleteIcon was clicked
        //        [self.BMtableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationAutomatic];
    }
    else if (editingStyle == UITableViewCellEditingStyleInsert) {
        if(indexPath.row < 10){
            defaultCellName = @"북마크 리스트 제목0";
            CellName = [NSString stringWithFormat:@"%@%@",defaultCellName,appendCellName];
        } else {
            defaultCellName = @"북마크 리스트 제목";
            CellName = [NSString stringWithFormat:@"%@%@",defaultCellName,appendCellName];
        }
        //add a new row to the datasource
        [self.tabledata insertObject:CellName atIndex:indexPath.row+1];
        NSString *currentPage = [@(self.DocumentViewController.pageIdx+1) stringValue];
        [self.pagedata insertObject:currentPage atIndex:indexPath.row+1];
        //insert a row in the tableView because the plusIcon was clicked.
        [self.BMtableView insertRowsAtIndexPaths:@[myIP]
                                withRowAnimation:UITableViewRowAnimationAutomatic];
    }
    //셀 추가 시 가장 마지막으로 스크롤 이동 (활성화하면 화면 깜빡이는 버그 있음)
    //    [self.BMtableView setContentOffset:CGPointMake(0.0, self.BMtableView.contentSize.height - self.BMtableView.rowHeight)];
}

- (BOOL)shouldPerformSegueWithIdentifier:(NSString *)identifier sender:(id)sender {
    if ([identifier isEqualToString:@"MyDetailView"] && [self.BMtableView isEditing]) {
        return NO;
    }
    return YES;
}


//this method is called when the user swipes to delete a row.
- (void)tableView:(UITableView *)tableView willBeginEditingRowAtIndexPath:(NSIndexPath *)indexPath{
    isSwipeDeleting = YES;//user just swipe to delete a row
}
//when the user cancel the swipe or click the delete button
//this method is call
- (void)tableView:(UITableView *)tableView didEndEditingRowAtIndexPath:(NSIndexPath *)indexPath{
    isSwipeDeleting = NO;//swipe to delete ended. No longer showing the DELETE button in cell
}

-(void)inputColorButton:(NSString*)buttonType {
    if(![buttonType isEqualToString:@"squareCorner"] && ![buttonType isEqualToString:@"circleCorner"]){
        UIButton *color1 = [[UIButton alloc] initWithFrame:CGRectMake(15, 10, 30, 30)];
        color1.backgroundColor = [UIColor blackColor];
        color1.layer.cornerRadius = 15;
        color1.tag = 1;
        
        UIButton *color2 = [[UIButton alloc] initWithFrame:CGRectMake(60, 10, 30, 30)];
        color2.backgroundColor = [UIColor redColor];
        color2.layer.cornerRadius = 15;
        color2.tag = 2;
        
        UIButton *color3 = [[UIButton alloc] initWithFrame:CGRectMake(108, 10, 30, 30)];
        color3.backgroundColor = [UIColor brownColor];
        color3.layer.cornerRadius = 15;
        color3.tag = 3;
        
        UIButton *color4 = [[UIButton alloc] initWithFrame:CGRectMake(156, 10, 30, 30)];
        color4.backgroundColor = [UIColor orangeColor];
        color4.layer.cornerRadius = 15;
        
        UIButton *color5 = [[UIButton alloc] initWithFrame:CGRectMake(204, 10, 30, 30)];
        color5.backgroundColor = [UIColor colorWithRed:1.00 green:0.73 blue:0.00 alpha:1.00];
        color5.layer.cornerRadius = 15;
        
        UIButton *color6 = [[UIButton alloc] initWithFrame:CGRectMake(252, 10, 30, 30)];
        color6.backgroundColor = [UIColor colorWithRed:1.00 green:0.89 blue:0.00 alpha:1.00];
        color6.layer.cornerRadius = 15;
        
        UIButton *color7 = [[UIButton alloc] initWithFrame:CGRectMake(300, 10, 30, 30)];
        color7.backgroundColor = [UIColor colorWithRed:1.00 green:1.00 blue:0.00 alpha:1.00];
        color7.layer.cornerRadius = 15;
        
        UIButton *color8 = [[UIButton alloc] initWithFrame:CGRectMake(15, 55, 30, 30)];
        color8.backgroundColor = [UIColor colorWithRed:0.87 green:1.00 blue:0.00 alpha:1.00];
        color8.layer.cornerRadius = 15;
        
        UIButton *color9 = [[UIButton alloc] initWithFrame:CGRectMake(60, 55, 30, 30)];
        color9.backgroundColor = [UIColor colorWithRed:0.00 green:0.76 blue:0.00 alpha:1.00];
        color9.layer.cornerRadius = 15;
        
        UIButton *color10 = [[UIButton alloc] initWithFrame:CGRectMake(108, 55, 30, 30)];
        color10.backgroundColor = [UIColor colorWithRed:0.00 green:0.76 blue:0.68 alpha:1.00];
        color10.layer.cornerRadius = 15;
        
        UIButton *color11 = [[UIButton alloc] initWithFrame:CGRectMake(156, 55, 30, 30)];
        color11.backgroundColor = [UIColor blueColor];
        color11.layer.cornerRadius = 15;
        
        UIButton *color12 = [[UIButton alloc] initWithFrame:CGRectMake(204, 55, 30, 30)];
        color12.backgroundColor = [UIColor colorWithRed:0.42 green:0.00 blue:0.78 alpha:1.00];
        color12.layer.cornerRadius = 15;
        
        UIButton *color13 = [[UIButton alloc] initWithFrame:CGRectMake(252, 55, 30, 30)];
        color13.backgroundColor = [UIColor colorWithRed:0.61 green:0.00 blue:0.78 alpha:1.00];
        color13.layer.cornerRadius = 15;
        
        UIButton *color14 = [[UIButton alloc] initWithFrame:CGRectMake(300, 55, 30, 30)];
        color14.backgroundColor = [UIColor colorWithRed:0.78 green:0.02 blue:0.65 alpha:1.00];
        color14.layer.cornerRadius = 15;
        
        if([buttonType isEqualToString:@"ink"]){
            [color1 addTarget:self action:@selector(GetInkBackgroundColor:) forControlEvents:UIControlEventTouchUpInside];
            [color2 addTarget:self action:@selector(GetInkBackgroundColor:) forControlEvents:UIControlEventTouchUpInside];
            [color3 addTarget:self action:@selector(GetInkBackgroundColor:) forControlEvents:UIControlEventTouchUpInside];
            [color4 addTarget:self action:@selector(GetInkBackgroundColor:) forControlEvents:UIControlEventTouchUpInside];
            [color5 addTarget:self action:@selector(GetInkBackgroundColor:) forControlEvents:UIControlEventTouchUpInside];
            [color6 addTarget:self action:@selector(GetInkBackgroundColor:) forControlEvents:UIControlEventTouchUpInside];
            [color7 addTarget:self action:@selector(GetInkBackgroundColor:) forControlEvents:UIControlEventTouchUpInside];
            [color8 addTarget:self action:@selector(GetInkBackgroundColor:) forControlEvents:UIControlEventTouchUpInside];
            [color9 addTarget:self action:@selector(GetInkBackgroundColor:) forControlEvents:UIControlEventTouchUpInside];
            [color10 addTarget:self action:@selector(GetInkBackgroundColor:) forControlEvents:UIControlEventTouchUpInside];
            [color11 addTarget:self action:@selector(GetInkBackgroundColor:) forControlEvents:UIControlEventTouchUpInside];
            [color12 addTarget:self action:@selector(GetInkBackgroundColor:) forControlEvents:UIControlEventTouchUpInside];
            [color13 addTarget:self action:@selector(GetInkBackgroundColor:) forControlEvents:UIControlEventTouchUpInside];
            [color14 addTarget:self action:@selector(GetInkBackgroundColor:) forControlEvents:UIControlEventTouchUpInside];
        } else if([buttonType isEqualToString:@"highlight"]){
            [color1 addTarget:self action:@selector(GetHighlightBackgroundColor:) forControlEvents:UIControlEventTouchUpInside];
            [color2 addTarget:self action:@selector(GetHighlightBackgroundColor:) forControlEvents:UIControlEventTouchUpInside];
            [color3 addTarget:self action:@selector(GetHighlightBackgroundColor:) forControlEvents:UIControlEventTouchUpInside];
            [color4 addTarget:self action:@selector(GetHighlightBackgroundColor:) forControlEvents:UIControlEventTouchUpInside];
            [color5 addTarget:self action:@selector(GetHighlightBackgroundColor:) forControlEvents:UIControlEventTouchUpInside];
            [color6 addTarget:self action:@selector(GetHighlightBackgroundColor:) forControlEvents:UIControlEventTouchUpInside];
            [color7 addTarget:self action:@selector(GetHighlightBackgroundColor:) forControlEvents:UIControlEventTouchUpInside];
            [color8 addTarget:self action:@selector(GetHighlightBackgroundColor:) forControlEvents:UIControlEventTouchUpInside];
            [color9 addTarget:self action:@selector(GetHighlightBackgroundColor:) forControlEvents:UIControlEventTouchUpInside];
            [color10 addTarget:self action:@selector(GetHighlightBackgroundColor:) forControlEvents:UIControlEventTouchUpInside];
            [color11 addTarget:self action:@selector(GetHighlightBackgroundColor:) forControlEvents:UIControlEventTouchUpInside];
            [color12 addTarget:self action:@selector(GetHighlightBackgroundColor:) forControlEvents:UIControlEventTouchUpInside];
            [color13 addTarget:self action:@selector(GetHighlightBackgroundColor:) forControlEvents:UIControlEventTouchUpInside];
            [color14 addTarget:self action:@selector(GetHighlightBackgroundColor:) forControlEvents:UIControlEventTouchUpInside];
        } else if([buttonType isEqualToString:@"underline"]){
            [color1 addTarget:self action:@selector(GetUnderlineBackgroundColor:) forControlEvents:UIControlEventTouchUpInside];
            [color2 addTarget:self action:@selector(GetUnderlineBackgroundColor:) forControlEvents:UIControlEventTouchUpInside];
            [color3 addTarget:self action:@selector(GetUnderlineBackgroundColor:) forControlEvents:UIControlEventTouchUpInside];
            [color4 addTarget:self action:@selector(GetUnderlineBackgroundColor:) forControlEvents:UIControlEventTouchUpInside];
            [color5 addTarget:self action:@selector(GetUnderlineBackgroundColor:) forControlEvents:UIControlEventTouchUpInside];
            [color6 addTarget:self action:@selector(GetUnderlineBackgroundColor:) forControlEvents:UIControlEventTouchUpInside];
            [color7 addTarget:self action:@selector(GetUnderlineBackgroundColor:) forControlEvents:UIControlEventTouchUpInside];
            [color8 addTarget:self action:@selector(GetUnderlineBackgroundColor:) forControlEvents:UIControlEventTouchUpInside];
            [color9 addTarget:self action:@selector(GetUnderlineBackgroundColor:) forControlEvents:UIControlEventTouchUpInside];
            [color10 addTarget:self action:@selector(GetUnderlineBackgroundColor:) forControlEvents:UIControlEventTouchUpInside];
            [color11 addTarget:self action:@selector(GetUnderlineBackgroundColor:) forControlEvents:UIControlEventTouchUpInside];
            [color12 addTarget:self action:@selector(GetUnderlineBackgroundColor:) forControlEvents:UIControlEventTouchUpInside];
            [color13 addTarget:self action:@selector(GetUnderlineBackgroundColor:) forControlEvents:UIControlEventTouchUpInside];
            [color14 addTarget:self action:@selector(GetUnderlineBackgroundColor:) forControlEvents:UIControlEventTouchUpInside];
        } else if([buttonType isEqualToString:@"cancleline"]){
            [color1 addTarget:self action:@selector(GetCanclelineBackgroundColor:) forControlEvents:UIControlEventTouchUpInside];
            [color2 addTarget:self action:@selector(GetCanclelineBackgroundColor:) forControlEvents:UIControlEventTouchUpInside];
            [color3 addTarget:self action:@selector(GetCanclelineBackgroundColor:) forControlEvents:UIControlEventTouchUpInside];
            [color4 addTarget:self action:@selector(GetCanclelineBackgroundColor:) forControlEvents:UIControlEventTouchUpInside];
            [color5 addTarget:self action:@selector(GetCanclelineBackgroundColor:) forControlEvents:UIControlEventTouchUpInside];
            [color6 addTarget:self action:@selector(GetCanclelineBackgroundColor:) forControlEvents:UIControlEventTouchUpInside];
            [color7 addTarget:self action:@selector(GetCanclelineBackgroundColor:) forControlEvents:UIControlEventTouchUpInside];
            [color8 addTarget:self action:@selector(GetCanclelineBackgroundColor:) forControlEvents:UIControlEventTouchUpInside];
            [color9 addTarget:self action:@selector(GetCanclelineBackgroundColor:) forControlEvents:UIControlEventTouchUpInside];
            [color10 addTarget:self action:@selector(GetCanclelineBackgroundColor:) forControlEvents:UIControlEventTouchUpInside];
            [color11 addTarget:self action:@selector(GetCanclelineBackgroundColor:) forControlEvents:UIControlEventTouchUpInside];
            [color12 addTarget:self action:@selector(GetCanclelineBackgroundColor:) forControlEvents:UIControlEventTouchUpInside];
            [color13 addTarget:self action:@selector(GetCanclelineBackgroundColor:) forControlEvents:UIControlEventTouchUpInside];
            [color14 addTarget:self action:@selector(GetCanclelineBackgroundColor:) forControlEvents:UIControlEventTouchUpInside];
        } else if([buttonType isEqualToString:@"square"]){
            [color1 addTarget:self action:@selector(GetSquareBackgroundColor:) forControlEvents:UIControlEventTouchUpInside];
            [color2 addTarget:self action:@selector(GetSquareBackgroundColor:) forControlEvents:UIControlEventTouchUpInside];
            [color3 addTarget:self action:@selector(GetSquareBackgroundColor:) forControlEvents:UIControlEventTouchUpInside];
            [color4 addTarget:self action:@selector(GetSquareBackgroundColor:) forControlEvents:UIControlEventTouchUpInside];
            [color5 addTarget:self action:@selector(GetSquareBackgroundColor:) forControlEvents:UIControlEventTouchUpInside];
            [color6 addTarget:self action:@selector(GetSquareBackgroundColor:) forControlEvents:UIControlEventTouchUpInside];
            [color7 addTarget:self action:@selector(GetSquareBackgroundColor:) forControlEvents:UIControlEventTouchUpInside];
            [color8 addTarget:self action:@selector(GetSquareBackgroundColor:) forControlEvents:UIControlEventTouchUpInside];
            [color9 addTarget:self action:@selector(GetSquareBackgroundColor:) forControlEvents:UIControlEventTouchUpInside];
            [color10 addTarget:self action:@selector(GetSquareBackgroundColor:) forControlEvents:UIControlEventTouchUpInside];
            [color11 addTarget:self action:@selector(GetSquareBackgroundColor:) forControlEvents:UIControlEventTouchUpInside];
            [color12 addTarget:self action:@selector(GetSquareBackgroundColor:) forControlEvents:UIControlEventTouchUpInside];
            [color13 addTarget:self action:@selector(GetSquareBackgroundColor:) forControlEvents:UIControlEventTouchUpInside];
            [color14 addTarget:self action:@selector(GetSquareBackgroundColor:) forControlEvents:UIControlEventTouchUpInside];
            color14.backgroundColor = [UIColor clearColor];
            [color14.layer setBorderColor:[UIColor colorWithRed:1.00 green:1.00 blue:1.00 alpha:1.00].CGColor];
            [color14.layer setBorderWidth:1.00];
        } else if([buttonType isEqualToString:@"circle"]){
            [color1 addTarget:self action:@selector(GetCircleBackgroundColor:) forControlEvents:UIControlEventTouchUpInside];
            [color2 addTarget:self action:@selector(GetCircleBackgroundColor:) forControlEvents:UIControlEventTouchUpInside];
            [color3 addTarget:self action:@selector(GetCircleBackgroundColor:) forControlEvents:UIControlEventTouchUpInside];
            [color4 addTarget:self action:@selector(GetCircleBackgroundColor:) forControlEvents:UIControlEventTouchUpInside];
            [color5 addTarget:self action:@selector(GetCircleBackgroundColor:) forControlEvents:UIControlEventTouchUpInside];
            [color6 addTarget:self action:@selector(GetCircleBackgroundColor:) forControlEvents:UIControlEventTouchUpInside];
            [color7 addTarget:self action:@selector(GetCircleBackgroundColor:) forControlEvents:UIControlEventTouchUpInside];
            [color8 addTarget:self action:@selector(GetCircleBackgroundColor:) forControlEvents:UIControlEventTouchUpInside];
            [color9 addTarget:self action:@selector(GetCircleBackgroundColor:) forControlEvents:UIControlEventTouchUpInside];
            [color10 addTarget:self action:@selector(GetCircleBackgroundColor:) forControlEvents:UIControlEventTouchUpInside];
            [color11 addTarget:self action:@selector(GetCircleBackgroundColor:) forControlEvents:UIControlEventTouchUpInside];
            [color12 addTarget:self action:@selector(GetCircleBackgroundColor:) forControlEvents:UIControlEventTouchUpInside];
            [color13 addTarget:self action:@selector(GetCircleBackgroundColor:) forControlEvents:UIControlEventTouchUpInside];
            [color14 addTarget:self action:@selector(GetCircleBackgroundColor:) forControlEvents:UIControlEventTouchUpInside];
            color14.backgroundColor = [UIColor clearColor];
            [color14.layer setBorderColor:[UIColor colorWithRed:1.00 green:1.00 blue:1.00 alpha:1.00].CGColor];
            [color14.layer setBorderWidth:1.00];
        }
        
        [self.ColorPickerView addSubview:color1];
        [self.ColorPickerView addSubview:color2];
        [self.ColorPickerView addSubview:color3];
        [self.ColorPickerView addSubview:color4];
        [self.ColorPickerView addSubview:color5];
        [self.ColorPickerView addSubview:color6];
        [self.ColorPickerView addSubview:color7];
        [self.ColorPickerView addSubview:color8];
        [self.ColorPickerView addSubview:color9];
        [self.ColorPickerView addSubview:color10];
        [self.ColorPickerView addSubview:color11];
        [self.ColorPickerView addSubview:color12];
        [self.ColorPickerView addSubview:color13];
        [self.ColorPickerView addSubview:color14];
    } else {
        UIButton *color1 = [[UIButton alloc] initWithFrame:CGRectMake(15, 10, 30, 30)];
        color1.backgroundColor = [UIColor blackColor];
        color1.layer.cornerRadius = 15;
        
        UIButton *color2 = [[UIButton alloc] initWithFrame:CGRectMake(60, 10, 30, 30)];
        color2.backgroundColor = [UIColor redColor];
        color2.layer.cornerRadius = 15;
        
        UIButton *color3 = [[UIButton alloc] initWithFrame:CGRectMake(108, 10, 30, 30)];
        color3.backgroundColor = [UIColor brownColor];
        color3.layer.cornerRadius = 15;
        
        UIButton *color4 = [[UIButton alloc] initWithFrame:CGRectMake(156, 10, 30, 30)];
        color4.backgroundColor = [UIColor orangeColor];
        color4.layer.cornerRadius = 15;
        
        UIButton *color5 = [[UIButton alloc] initWithFrame:CGRectMake(204, 10, 30, 30)];
        color5.backgroundColor = [UIColor colorWithRed:1.00 green:0.73 blue:0.00 alpha:1.00];
        color5.layer.cornerRadius = 15;
        
        UIButton *color6 = [[UIButton alloc] initWithFrame:CGRectMake(252, 10, 30, 30)];
        color6.backgroundColor = [UIColor colorWithRed:1.00 green:0.89 blue:0.00 alpha:1.00];
        color6.layer.cornerRadius = 15;
        
        UIButton *color7 = [[UIButton alloc] initWithFrame:CGRectMake(300, 10, 30, 30)];
        color7.backgroundColor = [UIColor colorWithRed:1.00 green:1.00 blue:0.00 alpha:1.00];
        color7.layer.cornerRadius = 15;
        
        UIButton *color8 = [[UIButton alloc] initWithFrame:CGRectMake(15, 55, 30, 30)];
        color8.backgroundColor = [UIColor colorWithRed:0.87 green:1.00 blue:0.00 alpha:1.00];
        color8.layer.cornerRadius = 15;
        
        UIButton *color9 = [[UIButton alloc] initWithFrame:CGRectMake(60, 55, 30, 30)];
        color9.backgroundColor = [UIColor colorWithRed:0.00 green:0.76 blue:0.00 alpha:1.00];
        color9.layer.cornerRadius = 15;
        
        UIButton *color10 = [[UIButton alloc] initWithFrame:CGRectMake(108, 55, 30, 30)];
        color10.backgroundColor = [UIColor colorWithRed:0.00 green:0.76 blue:0.68 alpha:1.00];
        color10.layer.cornerRadius = 15;
        
        UIButton *color11 = [[UIButton alloc] initWithFrame:CGRectMake(156, 55, 30, 30)];
        color11.backgroundColor = [UIColor blueColor];
        color11.layer.cornerRadius = 15;
        
        UIButton *color12 = [[UIButton alloc] initWithFrame:CGRectMake(204, 55, 30, 30)];
        color12.backgroundColor = [UIColor colorWithRed:0.42 green:0.00 blue:0.78 alpha:1.00];
        color12.layer.cornerRadius = 15;
        
        UIButton *color13 = [[UIButton alloc] initWithFrame:CGRectMake(252, 55, 30, 30)];
        color13.backgroundColor = [UIColor colorWithRed:0.61 green:0.00 blue:0.78 alpha:1.00];
        color13.layer.cornerRadius = 15;
        
        UIButton *color14 = [[UIButton alloc] initWithFrame:CGRectMake(300, 55, 30, 30)];
        color14.backgroundColor = [UIColor colorWithRed:0.78 green:0.02 blue:0.65 alpha:1.00];
        color14.layer.cornerRadius = 15;
        
        if([buttonType isEqualToString:@"squareCorner"]){
            [color1 addTarget:self action:@selector(GetSquareCornerBackgroundColor:) forControlEvents:UIControlEventTouchUpInside];
            [color2 addTarget:self action:@selector(GetSquareCornerBackgroundColor:) forControlEvents:UIControlEventTouchUpInside];
            [color3 addTarget:self action:@selector(GetSquareCornerBackgroundColor:) forControlEvents:UIControlEventTouchUpInside];
            [color4 addTarget:self action:@selector(GetSquareCornerBackgroundColor:) forControlEvents:UIControlEventTouchUpInside];
            [color5 addTarget:self action:@selector(GetSquareCornerBackgroundColor:) forControlEvents:UIControlEventTouchUpInside];
            [color6 addTarget:self action:@selector(GetSquareCornerBackgroundColor:) forControlEvents:UIControlEventTouchUpInside];
            [color7 addTarget:self action:@selector(GetSquareCornerBackgroundColor:) forControlEvents:UIControlEventTouchUpInside];
            [color8 addTarget:self action:@selector(GetSquareCornerBackgroundColor:) forControlEvents:UIControlEventTouchUpInside];
            [color9 addTarget:self action:@selector(GetSquareCornerBackgroundColor:) forControlEvents:UIControlEventTouchUpInside];
            [color10 addTarget:self action:@selector(GetSquareCornerBackgroundColor:) forControlEvents:UIControlEventTouchUpInside];
            [color11 addTarget:self action:@selector(GetSquareCornerBackgroundColor:) forControlEvents:UIControlEventTouchUpInside];
            [color12 addTarget:self action:@selector(GetSquareCornerBackgroundColor:) forControlEvents:UIControlEventTouchUpInside];
            [color13 addTarget:self action:@selector(GetSquareCornerBackgroundColor:) forControlEvents:UIControlEventTouchUpInside];
            [color14 addTarget:self action:@selector(GetSquareCornerBackgroundColor:) forControlEvents:UIControlEventTouchUpInside];
            
            [self.squareColorPickerView addSubview:color1];
            [self.squareColorPickerView addSubview:color2];
            [self.squareColorPickerView addSubview:color3];
            [self.squareColorPickerView addSubview:color4];
            [self.squareColorPickerView addSubview:color5];
            [self.squareColorPickerView addSubview:color6];
            [self.squareColorPickerView addSubview:color7];
            [self.squareColorPickerView addSubview:color8];
            [self.squareColorPickerView addSubview:color9];
            [self.squareColorPickerView addSubview:color10];
            [self.squareColorPickerView addSubview:color11];
            [self.squareColorPickerView addSubview:color12];
            [self.squareColorPickerView addSubview:color13];
            [self.squareColorPickerView addSubview:color14];
        } else if([buttonType isEqualToString:@"circleCorner"]){
            [color1 addTarget:self action:@selector(GetCircleCornerBackgroundColor:) forControlEvents:UIControlEventTouchUpInside];
            [color2 addTarget:self action:@selector(GetCircleCornerBackgroundColor:) forControlEvents:UIControlEventTouchUpInside];
            [color3 addTarget:self action:@selector(GetCircleCornerBackgroundColor:) forControlEvents:UIControlEventTouchUpInside];
            [color4 addTarget:self action:@selector(GetCircleCornerBackgroundColor:) forControlEvents:UIControlEventTouchUpInside];
            [color5 addTarget:self action:@selector(GetCircleCornerBackgroundColor:) forControlEvents:UIControlEventTouchUpInside];
            [color6 addTarget:self action:@selector(GetCircleCornerBackgroundColor:) forControlEvents:UIControlEventTouchUpInside];
            [color7 addTarget:self action:@selector(GetCircleCornerBackgroundColor:) forControlEvents:UIControlEventTouchUpInside];
            [color8 addTarget:self action:@selector(GetCircleCornerBackgroundColor:) forControlEvents:UIControlEventTouchUpInside];
            [color9 addTarget:self action:@selector(GetCircleCornerBackgroundColor:) forControlEvents:UIControlEventTouchUpInside];
            [color10 addTarget:self action:@selector(GetCircleCornerBackgroundColor:) forControlEvents:UIControlEventTouchUpInside];
            [color11 addTarget:self action:@selector(GetCircleCornerBackgroundColor:) forControlEvents:UIControlEventTouchUpInside];
            [color12 addTarget:self action:@selector(GetCircleCornerBackgroundColor:) forControlEvents:UIControlEventTouchUpInside];
            [color13 addTarget:self action:@selector(GetCircleCornerBackgroundColor:) forControlEvents:UIControlEventTouchUpInside];
            [color14 addTarget:self action:@selector(GetCircleCornerBackgroundColor:) forControlEvents:UIControlEventTouchUpInside];
            
            [self.circleColorPickerView addSubview:color1];
            [self.circleColorPickerView addSubview:color2];
            [self.circleColorPickerView addSubview:color3];
            [self.circleColorPickerView addSubview:color4];
            [self.circleColorPickerView addSubview:color5];
            [self.circleColorPickerView addSubview:color6];
            [self.circleColorPickerView addSubview:color7];
            [self.circleColorPickerView addSubview:color8];
            [self.circleColorPickerView addSubview:color9];
            [self.circleColorPickerView addSubview:color10];
            [self.circleColorPickerView addSubview:color11];
            [self.circleColorPickerView addSubview:color12];
            [self.circleColorPickerView addSubview:color13];
            [self.circleColorPickerView addSubview:color14];
        }
    }
}

-(IBAction)getInkOpacity:(id)sender{
    inkOpacityValue = (int)self.opacitySlider.value;
    [[NSUserDefaults standardUserDefaults] setInteger:inkOpacityValue forKey:@"inkOpacityValue"];
    NSLog(@"opacity = %f", (CGFloat)inkOpacityValue);
    CGFloat red;
    CGFloat green;
    CGFloat blue;
    CGFloat alpha = inkOpacityValue*0.01;
    CGFloat tmpAlpha;
    [self.exampleInkColor getRed:&red green:&green blue:&blue alpha:&tmpAlpha];
    [self.DocumentViewController setInkToolLineColor:[UIColor colorWithRed:red green:green blue:blue alpha:alpha]];
    self.opacityLabel.text = [NSString stringWithFormat:@"투명도 %d%%",inkOpacityValue];
}

-(CGRect)trackRectForBounds:(CGRect)bounds
{
    bounds.origin.x=15;
    bounds.origin.y=bounds.size.height/3;
    bounds.size.height=bounds.size.height/5;
    bounds.size.width=bounds.size.width-30;
    return bounds;
}

-(IBAction)getInkBold:(id)sender{
    UISlider *slider = (UISlider *)sender;
    
    //Round the value to the a target interval
    CGFloat roundedValue = [self roundValue:slider.value];
    
    //Snap to the final value
    [slider setValue:roundedValue animated:NO];
    NSLog(@"inkBoldValue = %f", roundedValue);
    NSString *widthText;
    inkBoldValue = self.boldSlider.value;
    [[NSUserDefaults standardUserDefaults] setFloat:inkBoldValue forKey:@"inkBoldValue"];
    
    [self.DocumentViewController setInkToolLineWidth:self.boldSlider.value];
    if(inkBoldValue == 0.5) { widthText = @"굵기 1"; }
    else if(inkBoldValue == 1.0) { widthText = @"굵기 2"; }
    else if(inkBoldValue == 1.5) { widthText = @"굵기 3"; }
    else if(inkBoldValue == 2.0) { widthText = @"굵기 4"; }
    else if(inkBoldValue == 2.5) { widthText = @"굵기 5"; }
    else if(inkBoldValue == 3.0) { widthText = @"굵기 6"; }
    else if(inkBoldValue == 3.5) { widthText = @"굵기 7"; }
    else if(inkBoldValue == 4.0) { widthText = @"굵기 8"; }
    else if(inkBoldValue == 4.5) { widthText = @"굵기 9"; }
    else if(inkBoldValue == 5.0) { widthText = @"굵기 10"; }
    else if(inkBoldValue == 5.5) { widthText = @"굵기 11"; }
    else if(inkBoldValue == 6.0) { widthText = @"굵기 12"; }
    else if(inkBoldValue == 6.5) { widthText = @"굵기 13"; }
    else if(inkBoldValue == 7.0) { widthText = @"굵기 14"; }
    else if(inkBoldValue == 7.5) { widthText = @"굵기 15"; }
    else if(inkBoldValue == 8.0) { widthText = @"굵기 16"; }
    else if(inkBoldValue == 8.5) { widthText = @"굵기 17"; }
    else if(inkBoldValue == 9.0) { widthText = @"굵기 18"; }
    else if(inkBoldValue == 9.5) { widthText = @"굵기 19"; }
    else { widthText = @"굵기 20"; }
    
    self.boldLabel.text = [NSString stringWithFormat:@"%@",widthText];
    
    //    CGSize newSize = CGSizeMake(inkBoldValue+10, inkBoldValue+10);
    //    UIImage* image = self.boldSlider.currentThumbImage;
    //    UIGraphicsBeginImageContextWithOptions(newSize, NO, 0.0);
    //    [image drawInRect:CGRectMake(0, 0, newSize.width, newSize.height)];
    //    UIImage *newImage = UIGraphicsGetImageFromCurrentImageContext();
    //    UIGraphicsEndImageContext();
    //    [self.boldSlider setThumbImage:newImage forState:UIControlStateNormal];
}

- (float)roundValue:(float)value
{
    //get the remainder of value/interval
    //make sure that the remainder is positive by getting its absolute value
    float tempValue = fabsf(fmodf(value, 0.5)); //need to import <math.h>
    
    //if the remainder is greater than or equal to the half of the interval then return the higher interval
    //otherwise, return the lower interval
    if(tempValue >= (0.5 / 2.0)){
        return value - tempValue + 0.5;
    }
    else{
        return value - tempValue;
    }
}


float RoundValue(UISlider * slider) {
    return roundf(slider.value * 2.0) * 0.5;
}

-(IBAction)getSquareBold:(id)sender{
    squareBoldValue = (int)self.boldSlider.value;
    [[NSUserDefaults standardUserDefaults] setInteger:squareBoldValue forKey:@"squareBoldValue"];
    NSLog(@"bold = %d", squareBoldValue);
    [self.DocumentViewController setShapeWidth:self.boldSlider.value];
    self.boldLabel.text = [NSString stringWithFormat:@"선 굵기 %d",squareBoldValue];
}

-(IBAction)getCircleBold:(id)sender{
    circleBoldValue = (int)self.boldSlider.value;
    [[NSUserDefaults standardUserDefaults] setInteger:circleBoldValue forKey:@"circleBoldValue"];
    NSLog(@"bold = %d", circleBoldValue);
    [self.DocumentViewController setShapeWidth:self.boldSlider.value];
    self.boldLabel.text = [NSString stringWithFormat:@"선 굵기 %d",circleBoldValue];
}

-(IBAction)getpageSlider:(id)sender{
    int rounded = self.pageSlider.value;  //Casting to an int will truncate, round down
    [sender setValue:rounded animated:NO];
    NSLog(@"%d",(int)self.pageSlider.value);
    currentSliderValue = rounded;
    if(beforeSliderValue != currentSliderValue){
        NSLog(@"gotopage");
        [self.DocumentViewController gotoPage:currentSliderValue fitToScreen:YES];
        beforeSliderValue = currentSliderValue;
    }
    
}

-(IBAction)getHighlightOpacity:(id)sender{
    highlightOpacityValue = (int)self.opacitySlider.value;
    [[NSUserDefaults standardUserDefaults] setInteger:highlightOpacityValue forKey:@"highlightOpacityValue"];
    NSLog(@"opacity = %d", highlightOpacityValue);
    CGFloat red;
    CGFloat green;
    CGFloat blue;
    CGFloat alpha = highlightOpacityValue*0.01;
    CGFloat tmpAlpha;
    [self.exampleHighlightColor getRed:&red green:&green blue:&blue alpha:&tmpAlpha];
    [self.DocumentViewController setTextHighlightToolColor:[UIColor colorWithRed:red green:green blue:blue alpha:alpha]];
    self.opacityLabel.text = [NSString stringWithFormat:@"투명도 %d%%",highlightOpacityValue];
}

- (IBAction)GetInkBackgroundColor:(UIButton *)sender
{
    NSLog(@"%ld", (long)sender.tag);
    CGFloat red;
    CGFloat green;
    CGFloat blue;
    CGFloat alpha = inkOpacityValue*0.01;
    CGFloat tmpAlpha;
    [sender.backgroundColor getRed:&red green:&green blue:&blue alpha:&tmpAlpha];
    [self.DocumentViewController setInkToolLineColor:[UIColor colorWithRed:red green:green blue:blue alpha:alpha]];
    self.exampleInkColor = sender.backgroundColor;
    NSData *colorData = [NSKeyedArchiver archivedDataWithRootObject:self.exampleInkColor];
    [[NSUserDefaults standardUserDefaults] setObject:colorData forKey:@"exampleInkColor"];
    self.exampleInkColorView.backgroundColor = sender.backgroundColor;
    self.boldSlider.minimumTrackTintColor = self.exampleInkColor;
    self.opacitySlider.minimumTrackTintColor = self.exampleInkColor;
}

- (IBAction)GetHighlightBackgroundColor:(UIButton *)sender
{
    CGFloat red;
    CGFloat green;
    CGFloat blue;
    CGFloat alpha = highlightOpacityValue*0.01;
    CGFloat tmpAlpha;
    [sender.backgroundColor getRed:&red green:&green blue:&blue alpha:&tmpAlpha];
    [self.DocumentViewController setTextHighlightToolColor:[UIColor colorWithRed:red green:green blue:blue alpha:alpha]];
    self.exampleHighlightColor = sender.backgroundColor;
    NSData *colorData = [NSKeyedArchiver archivedDataWithRootObject:self.exampleHighlightColor];
    [[NSUserDefaults standardUserDefaults] setObject:colorData forKey:@"exampleHighlightColor"];
    self.exampleHighlightColorView.backgroundColor = sender.backgroundColor;
    self.opacitySlider.minimumTrackTintColor = self.exampleHighlightColor;
}

- (BOOL)prefersStatusBarHidden {
    return YES;
}

- (IBAction)GetUnderlineBackgroundColor:(UIButton *)sender
{
    [self.DocumentViewController setTextUnderlineToolColor:sender.backgroundColor];
    self.exampleUnderlineColor = sender.backgroundColor;
    NSData *colorData = [NSKeyedArchiver archivedDataWithRootObject:self.exampleUnderlineColor];
    [[NSUserDefaults standardUserDefaults] setObject:colorData forKey:@"exampleUnderlineColor"];
    self.exampleUnderlineColorView.backgroundColor = sender.backgroundColor;
    self.opacitySlider.minimumTrackTintColor = self.exampleHighlightColor;
    self.secondLineView.backgroundColor = self.exampleUnderlineColor;
}

- (IBAction)GetCanclelineBackgroundColor:(UIButton *)sender
{
    [self.DocumentViewController setTextStrikeoutToolColor:sender.backgroundColor];
    self.exampleCanclelineColor = sender.backgroundColor;
    NSData *colorData = [NSKeyedArchiver archivedDataWithRootObject:self.exampleCanclelineColor];
    [[NSUserDefaults standardUserDefaults] setObject:colorData forKey:@"exampleCanclelineColor"];
    self.exampleCanclelineColorView.backgroundColor = sender.backgroundColor;
    self.secondLineView.backgroundColor = self.exampleCanclelineColor;
}

- (IBAction)GetSquareBackgroundColor:(UIButton *)sender
{
    [self.DocumentViewController setSquareAnnotColor:sender.backgroundColor];
    self.exampleSquareColor = sender.backgroundColor;
    if([[UIColor clearColor] isEqual:self.exampleSquareColor]){
        [self.DocumentViewController setSquareAnnotTransparent:YES];
    } else {
        [self.DocumentViewController setSquareAnnotTransparent:NO];
    }
    NSData *colorData = [NSKeyedArchiver archivedDataWithRootObject:self.exampleSquareColor];
    [[NSUserDefaults standardUserDefaults] setObject:colorData forKey:@"exampleSquareColor"];
    self.exampleColorView.backgroundColor = sender.backgroundColor;
    self.secondLineView.backgroundColor = self.exampleSquareColor;
}

- (IBAction)GetCircleBackgroundColor:(UIButton *)sender
{
    [self.DocumentViewController setCircleAnnotColor:sender.backgroundColor];
    self.exampleCircleColor = sender.backgroundColor;
    if([[UIColor clearColor] isEqual:self.exampleCircleColor]){
        [self.DocumentViewController setCircleAnnotTransparent:YES];
    } else {
        [self.DocumentViewController setCircleAnnotTransparent:NO];
    }
    NSData *colorData = [NSKeyedArchiver archivedDataWithRootObject:self.exampleCircleColor];
    [[NSUserDefaults standardUserDefaults] setObject:colorData forKey:@"exampleCircleColor"];
    self.exampleColorView.backgroundColor = sender.backgroundColor;
    self.secondLineView.backgroundColor = self.exampleCircleColor;
}

- (IBAction)GetSquareCornerBackgroundColor:(UIButton *)sender
{
    [self.DocumentViewController setShapeColor:sender.backgroundColor];
    self.exampleSquareCornerColor = sender.backgroundColor;
    NSData *colorData = [NSKeyedArchiver archivedDataWithRootObject:self.exampleSquareCornerColor];
    [[NSUserDefaults standardUserDefaults] setObject:colorData forKey:@"exampleSquareCornerColor"];
    self.exampleSquareCornerColorView.backgroundColor = sender.backgroundColor;
    self.boldSlider.minimumTrackTintColor = self.exampleSquareCornerColor;
}

- (IBAction)GetCircleCornerBackgroundColor:(UIButton *)sender
{
    [self.DocumentViewController setShapeColor:sender.backgroundColor];
    self.exampleCircleCornerColor = sender.backgroundColor;
    NSData *colorData = [NSKeyedArchiver archivedDataWithRootObject:self.exampleCircleCornerColor];
    [[NSUserDefaults standardUserDefaults] setObject:colorData forKey:@"exampleCircleCornerColor"];
    self.exampleCircleCornerColorView.backgroundColor = sender.backgroundColor;
    self.boldSlider.minimumTrackTintColor = self.exampleCircleCornerColor;
}

- (IBAction)getUnderLineSwitch:(id)sender {
    UISwitch *mySwitch = (UISwitch *)sender;
    
    if ([mySwitch isOn]) {
        useUnderline = 1;
        [[NSUserDefaults standardUserDefaults] setInteger:useUnderline forKey:@"useUnderline"];
        self.underLineUseLabel.textColor = [UIColor colorWithRed:0.08 green:0.46 blue:0.98 alpha:1.00];
        self.underLineUseLabel.text = [NSString stringWithFormat:@"사용"];
        [self.DocumentViewController setTextUnderlineToolSquiggly:YES];
    } else {
        useUnderline = 0;
        [[NSUserDefaults standardUserDefaults] setInteger:useUnderline forKey:@"useUnderline"];
        self.underLineUseLabel.textColor = [UIColor whiteColor];
        self.underLineUseLabel.text = [NSString stringWithFormat:@"사용 안함"];
        [self.DocumentViewController setTextUnderlineToolSquiggly:NO];
    }
}

// 노트 이벤트
- (BOOL) showNoteContents:(UIViewController *)controller annot: (UIControl *)annot{
    //    NSLog(@"showNoteContents");
    //    activateNoteMode = YES;
    //    [self.inkButton sendActionsForControlEvents:UIControlEventTouchUpInside];
    //    self.memoTextView.text = [(NoteAnnot*)annot contents];
    return YES;
}

- (BOOL) showNoteAnnotEditView:(UIViewController *)controller annot: (UIControl *)annot{
    NSLog(@"showNoteAnnotEditView");
    if(fromOnTapUp){
        NSLog(@"fromOnTapUp");
        self.tmpNote.contents = self.memoTextView.text;
        [self.DocumentViewController.documentView removeAnnot:self.tmpBaseNote];
        NoteAnnot* newNote = [[NoteAnnot alloc] initWithTitle:@"" contents:self.memoTextView.text date:@"" icon:self.noteIcon rect:self.tmpNote.rect pageIdx:self.tmpNote.pageIdx];
        [self.DocumentViewController.documentView removeAnnot:self.tmpNote];
        [self.DocumentViewController removeAnnot:self.tmpNote];
        [self.DocumentViewController setNoteIcon:self.noteIcon];
        [self.DocumentViewController.documentView saveNote:newNote];
        [self.DocumentViewController releaseTools];
    } else {
        PlugPDFPageView* pageView = [self.DocumentViewController.documentView pageView:self.DocumentViewController.pageIdx];
        //    float zoomScale = [pageView pageScale];
        float zoomScale = pageView.minScale;
        NSLog(@"%f", pageView.minScale);
        
        NSLog(@"note point(%.f, %.f)", self.point.x, self.point.y);
        NSLog(@"zoom scale = %f", zoomScale);
        CGSize documentSize = [self.DocumentViewController.documentView.document pageSize:0];
        CGFloat documentHeight = documentSize.height;
        CGFloat documentWidth = documentSize.width;
        CGFloat windowHeight = CGRectGetHeight(self.window.frame);
        CGFloat windowWidth = CGRectGetWidth(self.window.frame);
        
        float pageIdx;
        float pointX;
        
        if(isEbook){
            if(self.point.x > 1366) {
                pageIdx = self.DocumentViewController.pageIdx+1;
                pointX = self.point.x - 1366;
            } else {
                pageIdx = self.DocumentViewController.pageIdx;
                pointX = self.point.x;
            }
        } else {
            pageIdx = self.DocumentViewController.pageIdx;
            pointX = self.point.x;
        }
        
        NSLog(@"11 = %f", pageIdx);
        NoteAnnot* note1 = [[NoteAnnot alloc] initWithTitle:@"title" contents:self.memoTextView.text date:@"date" icon:self.noteIcon rect:CGRectMake(pointX/zoomScale, self.point.y/zoomScale, 30, 30) pageIdx:pageIdx];
        
        [self.DocumentViewController setNoteIcon:self.noteIcon];
        
        [self.DocumentViewController.documentView saveNote:note1];
    }
    
    fromOnTapUp = NO;
    [self.handButton sendActionsForControlEvents:UIControlEventTouchUpInside];
    
    [self.inkPopoverController dismissPopoverAnimated:YES];
}

- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
{
    UITouch *myTouch = [[touches allObjects] objectAtIndex: 0];
    CGPoint currentPos = [myTouch locationInView: self.DocumentViewController.view];
    NSLog(@"Point in myView: (%f,%f)", currentPos.x, currentPos.y);
}

- (void)releaseAnnots{
    UsingInk = NO;
    UsingSquare = NO;
    UsingCircle = NO;
    UsingHighlight = NO;
    UsingUnderline = NO;
    UsingCancle = NO;
    UsingNote = NO;
    UsingEraser = NO;
    
    [self.inkBtn setImage:[UIImage imageNamed:@"viewer-icon/pan-icon-01.png"] forState:UIControlStateNormal];
    [self.squareBtn setImage:[UIImage imageNamed:@"viewer-icon/pan-icon-02.png"] forState:UIControlStateNormal];
    [self.circleBtn setImage:[UIImage imageNamed:@"viewer-icon/pan-icon-03.png"] forState:UIControlStateNormal];
    [self.highlightBtn setImage:[UIImage imageNamed:@"viewer-icon/pan-icon-04.png"] forState:UIControlStateNormal];
    [self.underlineBtn setImage:[UIImage imageNamed:@"viewer-icon/pan-icon-05.png"] forState:UIControlStateNormal];
    [self.cancleBtn setImage:[UIImage imageNamed:@"viewer-icon/pan-icon-06.png"] forState:UIControlStateNormal];
    [self.noteBtn setImage:[UIImage imageNamed:@"viewer-icon/pan-icon-07.png"] forState:UIControlStateNormal];
    [self.eraserBtn setImage:[UIImage imageNamed:@"viewer-icon/pan-icon-08.png"] forState:UIControlStateNormal];
}

- (void)releaseAnnotBtn{
    //    [self.inkBtn removeFromSuperview];
    [self.squareBtn removeFromSuperview];
    [self.circleBtn removeFromSuperview];
    [self.highlightBtn removeFromSuperview];
    [self.underlineBtn removeFromSuperview];
    [self.cancleBtn removeFromSuperview];
    [self.noteBtn removeFromSuperview];
    //    [self.eraserBtn removeFromSuperview];
}

- (void)releaseSubViews{
    [self.lineView removeFromSuperview];
    [self.colorLabel removeFromSuperview];
    [self.ColorPickerView removeFromSuperview];
    [self.opacityLabel removeFromSuperview];
    [self.opacityView removeFromSuperview];
    [self.boldLabel removeFromSuperview];
    [self.boldView removeFromSuperview];
    [self.underLineLabel removeFromSuperview];
    [self.underLineView removeFromSuperview];
    [self.underLineSwitch removeFromSuperview];
    [self.exampleCanclelineColorView removeFromSuperview];
    [self.squareColorLabel removeFromSuperview];
    [self.squareColorPickerView removeFromSuperview];
    [self.exampleColorView removeFromSuperview];
    [self.exampleSquareCornerColorView removeFromSuperview];
    [self.circleColorLabel removeFromSuperview];
    [self.circleColorPickerView removeFromSuperview];
    [self.exampleCircleCornerColorView removeFromSuperview];
    [self.defaultEraserBtn removeFromSuperview];
    [self.blockEraserBtn removeFromSuperview];
    [self.allEraserBtn removeFromSuperview];
    [self.exampleInkColorView removeFromSuperview];
    [self.exampleHighlightColorView removeFromSuperview];
    [self.exampleUnderlineColorView removeFromSuperview];
    [self.memoTextView removeFromSuperview];
    [self.memoBtnView removeFromSuperview];
    [self.lineView2 removeFromSuperview];
    [self.secondLineView removeFromSuperview];
    [self.memoIconView removeFromSuperview];
    [self.displayBtnView removeFromSuperview];
    [self.closeBtnView removeFromSuperview];
}

















- (void)openInInAppBrowser:(NSURL*)url withOptions:(NSString*)options
{
    CDVInAppBrowserOptions* browserOptions = [CDVInAppBrowserOptions parseOptions:options];
    
    if (browserOptions.clearcache) {
        NSHTTPCookie *cookie;
        NSHTTPCookieStorage *storage = [NSHTTPCookieStorage sharedHTTPCookieStorage];
        for (cookie in [storage cookies])
        {
            if (![cookie.domain isEqual: @".^filecookies^"]) {
                [storage deleteCookie:cookie];
            }
        }
    }
    
    if (browserOptions.clearsessioncache) {
        NSHTTPCookie *cookie;
        NSHTTPCookieStorage *storage = [NSHTTPCookieStorage sharedHTTPCookieStorage];
        for (cookie in [storage cookies])
        {
            if (![cookie.domain isEqual: @".^filecookies^"] && cookie.isSessionOnly) {
                [storage deleteCookie:cookie];
            }
        }
    }
    
    if (self.inAppBrowserViewController == nil) {
        NSString* originalUA = [CDVUserAgentUtil originalUserAgent];
        self.inAppBrowserViewController = [[CDVInAppBrowserViewController alloc] initWithUserAgent:originalUA prevUserAgent:[self.commandDelegate userAgent] browserOptions: browserOptions];
        self.inAppBrowserViewController.navigationDelegate = self;
        
        if ([self.viewController conformsToProtocol:@protocol(CDVScreenOrientationDelegate)]) {
            self.inAppBrowserViewController.orientationDelegate = (UIViewController <CDVScreenOrientationDelegate>*)self.viewController;
        }
    }
    
    [self.inAppBrowserViewController showLocationBar:browserOptions.location];
    [self.inAppBrowserViewController showToolBar:browserOptions.toolbar :browserOptions.toolbarposition];
    if (browserOptions.closebuttoncaption != nil) {
        [self.inAppBrowserViewController setCloseButtonTitle:browserOptions.closebuttoncaption];
    }
    // Set Presentation Style
    UIModalPresentationStyle presentationStyle = UIModalPresentationFullScreen; // default
    if (browserOptions.presentationstyle != nil) {
        if ([[browserOptions.presentationstyle lowercaseString] isEqualToString:@"pagesheet"]) {
            presentationStyle = UIModalPresentationPageSheet;
        } else if ([[browserOptions.presentationstyle lowercaseString] isEqualToString:@"formsheet"]) {
            presentationStyle = UIModalPresentationFormSheet;
        }
    }
    self.inAppBrowserViewController.modalPresentationStyle = presentationStyle;
    
    // Set Transition Style
    UIModalTransitionStyle transitionStyle = UIModalTransitionStyleCoverVertical; // default
    if (browserOptions.transitionstyle != nil) {
        if ([[browserOptions.transitionstyle lowercaseString] isEqualToString:@"fliphorizontal"]) {
            transitionStyle = UIModalTransitionStyleFlipHorizontal;
        } else if ([[browserOptions.transitionstyle lowercaseString] isEqualToString:@"crossdissolve"]) {
            transitionStyle = UIModalTransitionStyleCrossDissolve;
        }
    }
    self.inAppBrowserViewController.modalTransitionStyle = transitionStyle;
    
    // prevent webView from bouncing
    if (browserOptions.disallowoverscroll) {
        if ([self.inAppBrowserViewController.webView respondsToSelector:@selector(scrollView)]) {
            ((UIScrollView*)[self.inAppBrowserViewController.webView scrollView]).bounces = NO;
        } else {
            for (id subview in self.inAppBrowserViewController.webView.subviews) {
                if ([[subview class] isSubclassOfClass:[UIScrollView class]]) {
                    ((UIScrollView*)subview).bounces = NO;
                }
            }
        }
    }
    
    // UIWebView options
    self.inAppBrowserViewController.webView.scalesPageToFit = browserOptions.enableviewportscale;
    self.inAppBrowserViewController.webView.mediaPlaybackRequiresUserAction = browserOptions.mediaplaybackrequiresuseraction;
    self.inAppBrowserViewController.webView.allowsInlineMediaPlayback = browserOptions.allowinlinemediaplayback;
    if (IsAtLeastiOSVersion(@"6.0")) {
        self.inAppBrowserViewController.webView.keyboardDisplayRequiresUserAction = browserOptions.keyboarddisplayrequiresuseraction;
        self.inAppBrowserViewController.webView.suppressesIncrementalRendering = browserOptions.suppressesincrementalrendering;
    }
    
    [self.inAppBrowserViewController navigateTo:url];
    if (!browserOptions.hidden) {
        [self show:nil];
    }
    
}

- (void)show:(CDVInvokedUrlCommand*)command
{
    if (self.inAppBrowserViewController == nil) {
        NSLog(@"Tried to show IAB after it was closed.");
        return;
    }
    if (_previousStatusBarStyle != -1) {
        NSLog(@"Tried to show IAB while already shown");
        return;
    }
    
    _previousStatusBarStyle = [UIApplication sharedApplication].statusBarStyle;
    
    __block CDVInAppBrowserNavigationController* nav = [[CDVInAppBrowserNavigationController alloc]
                                                        initWithRootViewController:self.inAppBrowserViewController];
    nav.orientationDelegate = self.inAppBrowserViewController;
    nav.navigationBarHidden = YES;
    
    CDVInAppBrowser* weakSelf = self;
    
    // Run later to avoid the "took a long time" log message.
    dispatch_async(dispatch_get_main_queue(), ^{
        if (weakSelf.inAppBrowserViewController != nil) {
            [weakSelf.viewController presentViewController:nav animated:YES completion:nil];
        }
    });
}

- (void)openInCordovaWebView:(NSURL*)url withOptions:(NSString*)options
{
    NSURLRequest* request = [NSURLRequest requestWithURL:url];
    
#ifdef __CORDOVA_4_0_0
    // the webview engine itself will filter for this according to <allow-navigation> policy
    // in config.xml for cordova-ios-4.0
    [self.webViewEngine loadRequest:request];
#else
    if ([self.commandDelegate URLIsWhitelisted:url]) {
        [self.webView loadRequest:request];
    } else { // this assumes the InAppBrowser can be excepted from the white-list
        [self openInInAppBrowser:url withOptions:options];
    }
#endif
}

- (void)openInSystem:(NSURL*)url
{
    if ([[UIApplication sharedApplication] canOpenURL:url]) {
        [[UIApplication sharedApplication] openURL:url];
    } else { // handle any custom schemes to plugins
        [[NSNotificationCenter defaultCenter] postNotification:[NSNotification notificationWithName:CDVPluginHandleOpenURLNotification object:url]];
    }
}

// This is a helper method for the inject{Script|Style}{Code|File} API calls, which
// provides a consistent method for injecting JavaScript code into the document.
//
// If a wrapper string is supplied, then the source string will be JSON-encoded (adding
// quotes) and wrapped using string formatting. (The wrapper string should have a single
// '%@' marker).
//
// If no wrapper is supplied, then the source string is executed directly.

- (void)injectDeferredObject:(NSString*)source withWrapper:(NSString*)jsWrapper
{
    // Ensure an iframe bridge is created to communicate with the CDVInAppBrowserViewController
    [self.inAppBrowserViewController.webView stringByEvaluatingJavaScriptFromString:@"(function(d){_cdvIframeBridge=d.getElementById('_cdvIframeBridge');if(!_cdvIframeBridge) {var e = _cdvIframeBridge = d.createElement('iframe');e.id='_cdvIframeBridge'; e.style.display='none';d.body.appendChild(e);}})(document)"];
    
    if (jsWrapper != nil) {
        NSData* jsonData = [NSJSONSerialization dataWithJSONObject:@[source] options:0 error:nil];
        NSString* sourceArrayString = [[NSString alloc] initWithData:jsonData encoding:NSUTF8StringEncoding];
        if (sourceArrayString) {
            NSString* sourceString = [sourceArrayString substringWithRange:NSMakeRange(1, [sourceArrayString length] - 2)];
            NSString* jsToInject = [NSString stringWithFormat:jsWrapper, sourceString];
            [self.inAppBrowserViewController.webView stringByEvaluatingJavaScriptFromString:jsToInject];
        }
    } else {
        [self.inAppBrowserViewController.webView stringByEvaluatingJavaScriptFromString:source];
    }
}

- (void)injectScriptCode:(CDVInvokedUrlCommand*)command
{
    NSString* jsWrapper = nil;
    
    if ((command.callbackId != nil) && ![command.callbackId isEqualToString:@"INVALID"]) {
        jsWrapper = [NSString stringWithFormat:@"_cdvIframeBridge.src='gap-iab://%@/'+encodeURIComponent(JSON.stringify([eval(%%@)]));", command.callbackId];
    }
    [self injectDeferredObject:[command argumentAtIndex:0] withWrapper:jsWrapper];
}

- (void)injectScriptFile:(CDVInvokedUrlCommand*)command
{
    NSString* jsWrapper;
    
    if ((command.callbackId != nil) && ![command.callbackId isEqualToString:@"INVALID"]) {
        jsWrapper = [NSString stringWithFormat:@"(function(d) { var c = d.createElement('script'); c.src = %%@; c.onload = function() { _cdvIframeBridge.src='gap-iab://%@'; }; d.body.appendChild(c); })(document)", command.callbackId];
    } else {
        jsWrapper = @"(function(d) { var c = d.createElement('script'); c.src = %@; d.body.appendChild(c); })(document)";
    }
    [self injectDeferredObject:[command argumentAtIndex:0] withWrapper:jsWrapper];
}

- (void)injectStyleCode:(CDVInvokedUrlCommand*)command
{
    NSString* jsWrapper;
    
    if ((command.callbackId != nil) && ![command.callbackId isEqualToString:@"INVALID"]) {
        jsWrapper = [NSString stringWithFormat:@"(function(d) { var c = d.createElement('style'); c.innerHTML = %%@; c.onload = function() { _cdvIframeBridge.src='gap-iab://%@'; }; d.body.appendChild(c); })(document)", command.callbackId];
    } else {
        jsWrapper = @"(function(d) { var c = d.createElement('style'); c.innerHTML = %@; d.body.appendChild(c); })(document)";
    }
    [self injectDeferredObject:[command argumentAtIndex:0] withWrapper:jsWrapper];
}

- (void)injectStyleFile:(CDVInvokedUrlCommand*)command
{
    NSString* jsWrapper;
    
    if ((command.callbackId != nil) && ![command.callbackId isEqualToString:@"INVALID"]) {
        jsWrapper = [NSString stringWithFormat:@"(function(d) { var c = d.createElement('link'); c.rel='stylesheet'; c.type='text/css'; c.href = %%@; c.onload = function() { _cdvIframeBridge.src='gap-iab://%@'; }; d.body.appendChild(c); })(document)", command.callbackId];
    } else {
        jsWrapper = @"(function(d) { var c = d.createElement('link'); c.rel='stylesheet', c.type='text/css'; c.href = %@; d.body.appendChild(c); })(document)";
    }
    [self injectDeferredObject:[command argumentAtIndex:0] withWrapper:jsWrapper];
}

- (BOOL)isValidCallbackId:(NSString *)callbackId
{
    NSError *err = nil;
    // Initialize on first use
    if (self.callbackIdPattern == nil) {
        self.callbackIdPattern = [NSRegularExpression regularExpressionWithPattern:@"^InAppBrowser[0-9]{1,10}$" options:0 error:&err];
        if (err != nil) {
            // Couldn't initialize Regex; No is safer than Yes.
            return NO;
        }
    }
    if ([self.callbackIdPattern firstMatchInString:callbackId options:0 range:NSMakeRange(0, [callbackId length])]) {
        return YES;
    }
    return NO;
}

/**
 * The iframe bridge provided for the InAppBrowser is capable of executing any oustanding callback belonging
 * to the InAppBrowser plugin. Care has been taken that other callbacks cannot be triggered, and that no
 * other code execution is possible.
 *
 * To trigger the bridge, the iframe (or any other resource) should attempt to load a url of the form:
 *
 * gap-iab://<callbackId>/<arguments>
 *
 * where <callbackId> is the string id of the callback to trigger (something like "InAppBrowser0123456789")
 *
 * If present, the path component of the special gap-iab:// url is expected to be a URL-escaped JSON-encoded
 * value to pass to the callback. [NSURL path] should take care of the URL-unescaping, and a JSON_EXCEPTION
 * is returned if the JSON is invalid.
 */
- (BOOL)webView:(UIWebView*)theWebView shouldStartLoadWithRequest:(NSURLRequest*)request navigationType:(UIWebViewNavigationType)navigationType
{
    NSURL* url = request.URL;
    BOOL isTopLevelNavigation = [request.URL isEqual:[request mainDocumentURL]];
    
    // See if the url uses the 'gap-iab' protocol. If so, the host should be the id of a callback to execute,
    // and the path, if present, should be a JSON-encoded value to pass to the callback.
    if ([[url scheme] isEqualToString:@"gap-iab"]) {
        NSString* scriptCallbackId = [url host];
        CDVPluginResult* pluginResult = nil;
        
        if ([self isValidCallbackId:scriptCallbackId]) {
            NSString* scriptResult = [url path];
            NSError* __autoreleasing error = nil;
            
            // The message should be a JSON-encoded array of the result of the script which executed.
            if ((scriptResult != nil) && ([scriptResult length] > 1)) {
                scriptResult = [scriptResult substringFromIndex:1];
                NSData* decodedResult = [NSJSONSerialization JSONObjectWithData:[scriptResult dataUsingEncoding:NSUTF8StringEncoding] options:kNilOptions error:&error];
                if ((error == nil) && [decodedResult isKindOfClass:[NSArray class]]) {
                    pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK messageAsArray:(NSArray*)decodedResult];
                } else {
                    pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_JSON_EXCEPTION];
                }
            } else {
                pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK messageAsArray:@[]];
            }
            [self.commandDelegate sendPluginResult:pluginResult callbackId:scriptCallbackId];
            return NO;
        }
    }
    //if is an app store link, let the system handle it, otherwise it fails to load it
    else if ([[ url scheme] isEqualToString:@"itms-appss"] || [[ url scheme] isEqualToString:@"itms-apps"]) {
        [theWebView stopLoading];
        [self openInSystem:url];
        return NO;
    }
    else if ((self.callbackId != nil) && isTopLevelNavigation) {
        // Send a loadstart event for each top-level navigation (includes redirects).
        CDVPluginResult* pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK
                                                      messageAsDictionary:@{@"type":@"loadstart", @"url":[url absoluteString]}];
        [pluginResult setKeepCallback:[NSNumber numberWithBool:YES]];
        
        [self.commandDelegate sendPluginResult:pluginResult callbackId:self.callbackId];
    }
    
    return YES;
}

- (void)webViewDidStartLoad:(UIWebView*)theWebView
{
}

- (void)webViewDidFinishLoad:(UIWebView*)theWebView
{
    if (self.callbackId != nil) {
        // TODO: It would be more useful to return the URL the page is actually on (e.g. if it's been redirected).
        NSString* url = [self.inAppBrowserViewController.currentURL absoluteString];
        CDVPluginResult* pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK
                                                      messageAsDictionary:@{@"type":@"loadstop", @"url":url}];
        [pluginResult setKeepCallback:[NSNumber numberWithBool:YES]];
        
        // 클립보드 복사 금지
        [self.inAppBrowserViewController.webView stringByEvaluatingJavaScriptFromString:@"document.documentElement.style.webkitUserSelect='none';"];
        [self.inAppBrowserViewController.webView stringByEvaluatingJavaScriptFromString:@"document.documentElement.style.webkitTouchCallout='none';"];
        
        UILongPressGestureRecognizer* longPress = [[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(handleLongPressGestures:)]; // allocating the UILongPressGestureRecognizer
        
        longPress.allowableMovement=100; // Making sure the allowable movement isn't too narrow
        
        longPress.minimumPressDuration=0.3; // This is important - the duration must be long enough to allow taps but not longer than the period in which the scroll view opens the magnifying glass
        
        longPress.delegate=self; // initialization stuff
        longPress.delaysTouchesBegan=YES;
        longPress.delaysTouchesEnded=YES;
        
        longPress.cancelsTouchesInView=YES; // That's when we tell the gesture recognizer to block the gestures we want
        
        [self.inAppBrowserViewController.webView addGestureRecognizer:longPress]; // Add the gesture recognizer to the view and scroll view then release
        [[self.inAppBrowserViewController.webView scrollView] addGestureRecognizer:longPress];
        
        
        [self.commandDelegate sendPluginResult:pluginResult callbackId:self.callbackId];
    }
}

- (void)handleLongPressGestures:(UILongPressGestureRecognizer*)sender
{
    
}


- (void)webView:(UIWebView*)theWebView didFailLoadWithError:(NSError*)error
{
    if (self.callbackId != nil) {
        NSString* url = [self.inAppBrowserViewController.currentURL absoluteString];
        CDVPluginResult* pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_ERROR
                                                      messageAsDictionary:@{@"type":@"loaderror", @"url":url, @"code": [NSNumber numberWithInteger:error.code], @"message": error.localizedDescription}];
        [pluginResult setKeepCallback:[NSNumber numberWithBool:YES]];
        
        [self.commandDelegate sendPluginResult:pluginResult callbackId:self.callbackId];
    }
}

- (void)browserExit
{
    if (self.callbackId != nil) {
        CDVPluginResult* pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK
                                                      messageAsDictionary:@{@"type":@"exit"}];
        [self.commandDelegate sendPluginResult:pluginResult callbackId:self.callbackId];
        self.callbackId = nil;
    }
    // Set navigationDelegate to nil to ensure no callbacks are received from it.
    self.inAppBrowserViewController.navigationDelegate = nil;
    // Don't recycle the ViewController since it may be consuming a lot of memory.
    // Also - this is required for the PDF/User-Agent bug work-around.
    self.inAppBrowserViewController = nil;
    
    if (IsAtLeastiOSVersion(@"7.0")) {
        if (_previousStatusBarStyle != -1) {
            [[UIApplication sharedApplication] setStatusBarStyle:_previousStatusBarStyle];
        }
    }
    
    _previousStatusBarStyle = -1; // this value was reset before reapplying it. caused statusbar to stay black on ios7
}

@end

#pragma mark CDVInAppBrowserViewController

@implementation CDVInAppBrowserViewController

@synthesize currentURL;

- (id)initWithUserAgent:(NSString*)userAgent prevUserAgent:(NSString*)prevUserAgent browserOptions: (CDVInAppBrowserOptions*) browserOptions
{
    self = [super init];
    if (self != nil) {
        _userAgent = userAgent;
        _prevUserAgent = prevUserAgent;
        _browserOptions = browserOptions;
#ifdef __CORDOVA_4_0_0
        _webViewDelegate = [[CDVUIWebViewDelegate alloc] initWithDelegate:self];
#else
        _webViewDelegate = [[CDVWebViewDelegate alloc] initWithDelegate:self];
#endif
        
        [self createViews];
    }
    
    return self;
}

// Prevent crashes on closing windows
-(void)dealloc {
    self.webView.delegate = nil;
}

- (void)createViews
{
    // We create the views in code for primarily for ease of upgrades and not requiring an external .xib to be included
    
    CGRect webViewBounds = self.view.bounds;
    BOOL toolbarIsAtBottom = ![_browserOptions.toolbarposition isEqualToString:kInAppBrowserToolbarBarPositionTop];
    webViewBounds.size.height -= _browserOptions.location ? FOOTER_HEIGHT : TOOLBAR_HEIGHT;
    self.webView = [[UIWebView alloc] initWithFrame:webViewBounds];
    
    self.webView.autoresizingMask = (UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight);
    
    [self.view addSubview:self.webView];
    [self.view sendSubviewToBack:self.webView];
    
    self.webView.delegate = _webViewDelegate;
    self.webView.backgroundColor = [UIColor whiteColor];
    
    self.webView.clearsContextBeforeDrawing = YES;
    self.webView.clipsToBounds = YES;
    self.webView.contentMode = UIViewContentModeScaleToFill;
    self.webView.multipleTouchEnabled = YES;
    self.webView.opaque = YES;
    self.webView.scalesPageToFit = NO;
    self.webView.userInteractionEnabled = YES;
    
    self.spinner = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
    self.spinner.alpha = 1.000;
    self.spinner.autoresizesSubviews = YES;
    self.spinner.autoresizingMask = (UIViewAutoresizingFlexibleLeftMargin | UIViewAutoresizingFlexibleTopMargin | UIViewAutoresizingFlexibleBottomMargin | UIViewAutoresizingFlexibleRightMargin);
    self.spinner.clearsContextBeforeDrawing = NO;
    self.spinner.clipsToBounds = NO;
    self.spinner.contentMode = UIViewContentModeScaleToFill;
    self.spinner.frame = CGRectMake(CGRectGetMidX(self.webView.frame), CGRectGetMidY(self.webView.frame), 20.0, 20.0);
    self.spinner.hidden = NO;
    self.spinner.hidesWhenStopped = YES;
    self.spinner.multipleTouchEnabled = NO;
    self.spinner.opaque = NO;
    self.spinner.userInteractionEnabled = NO;
    [self.spinner stopAnimating];
    
    self.closeButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemDone target:self action:@selector(close)];
    self.closeButton.enabled = YES;
    
    UIBarButtonItem* flexibleSpaceButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace target:nil action:nil];
    
    UIBarButtonItem* fixedSpaceButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFixedSpace target:nil action:nil];
    fixedSpaceButton.width = 20;
    
    float toolbarY = toolbarIsAtBottom ? self.view.bounds.size.height - TOOLBAR_HEIGHT : 0.0;
    CGRect toolbarFrame = CGRectMake(0.0, toolbarY, self.view.bounds.size.width, TOOLBAR_HEIGHT);
    
    self.toolbar = [[UIToolbar alloc] initWithFrame:toolbarFrame];
    self.toolbar.alpha = 1.000;
    self.toolbar.autoresizesSubviews = YES;
    self.toolbar.autoresizingMask = toolbarIsAtBottom ? (UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleTopMargin) : UIViewAutoresizingFlexibleWidth;
    self.toolbar.barStyle = UIBarStyleBlackOpaque;
    self.toolbar.clearsContextBeforeDrawing = NO;
    self.toolbar.clipsToBounds = NO;
    self.toolbar.contentMode = UIViewContentModeScaleToFill;
    self.toolbar.hidden = NO;
    self.toolbar.multipleTouchEnabled = NO;
    self.toolbar.opaque = NO;
    self.toolbar.userInteractionEnabled = YES;
    
    CGFloat labelInset = 5.0;
    float locationBarY = toolbarIsAtBottom ? self.view.bounds.size.height - FOOTER_HEIGHT : self.view.bounds.size.height - LOCATIONBAR_HEIGHT;
    
    self.addressLabel = [[UILabel alloc] initWithFrame:CGRectMake(labelInset, locationBarY, self.view.bounds.size.width - labelInset, LOCATIONBAR_HEIGHT)];
    self.addressLabel.adjustsFontSizeToFitWidth = NO;
    self.addressLabel.alpha = 1.000;
    self.addressLabel.autoresizesSubviews = YES;
    self.addressLabel.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleRightMargin | UIViewAutoresizingFlexibleTopMargin;
    self.addressLabel.backgroundColor = [UIColor clearColor];
    self.addressLabel.baselineAdjustment = UIBaselineAdjustmentAlignCenters;
    self.addressLabel.clearsContextBeforeDrawing = YES;
    self.addressLabel.clipsToBounds = YES;
    self.addressLabel.contentMode = UIViewContentModeScaleToFill;
    self.addressLabel.enabled = YES;
    self.addressLabel.hidden = NO;
    self.addressLabel.lineBreakMode = NSLineBreakByTruncatingTail;
    
    if ([self.addressLabel respondsToSelector:NSSelectorFromString(@"setMinimumScaleFactor:")]) {
        [self.addressLabel setValue:@(10.0/[UIFont labelFontSize]) forKey:@"minimumScaleFactor"];
    } else if ([self.addressLabel respondsToSelector:NSSelectorFromString(@"setMinimumFontSize:")]) {
        [self.addressLabel setValue:@(10.0) forKey:@"minimumFontSize"];
    }
    
    self.addressLabel.multipleTouchEnabled = NO;
    self.addressLabel.numberOfLines = 1;
    self.addressLabel.opaque = NO;
    self.addressLabel.shadowOffset = CGSizeMake(0.0, -1.0);
    self.addressLabel.text = NSLocalizedString(@"Loading...", nil);
    self.addressLabel.textAlignment = NSTextAlignmentLeft;
    self.addressLabel.textColor = [UIColor colorWithWhite:1.000 alpha:1.000];
    self.addressLabel.userInteractionEnabled = NO;
    
    NSString* frontArrowString = NSLocalizedString(@"변환", nil); // create arrow from Unicode char
    self.forwardButton = [[UIBarButtonItem alloc] initWithTitle:frontArrowString style:UIBarButtonItemStylePlain target:self action:@selector(goBack:)];
    self.forwardButton.enabled = YES;
    self.forwardButton.imageInsets = UIEdgeInsetsZero;
    
    NSString* backArrowString = NSLocalizedString(@"", nil); // create arrow from Unicode char
    self.backButton = [[UIBarButtonItem alloc] initWithTitle:backArrowString style:UIBarButtonItemStylePlain target:self action:@selector(goForward:)];
    self.backButton.enabled = YES;
    self.backButton.imageInsets = UIEdgeInsetsZero;
    
    
    [self.toolbar setItems:@[self.closeButton, flexibleSpaceButton, self.backButton, fixedSpaceButton, self.forwardButton]];
    
    self.view.backgroundColor = [UIColor grayColor];
    [self.view addSubview:self.toolbar];
    [self.view addSubview:self.addressLabel];
    [self.view addSubview:self.spinner];
}

- (void) setWebViewFrame : (CGRect) frame {
    NSLog(@"Setting the WebView's frame to %@", NSStringFromCGRect(frame));
    [self.webView setFrame:frame];
}

- (void)setCloseButtonTitle:(NSString*)title
{
    // the advantage of using UIBarButtonSystemItemDone is the system will localize it for you automatically
    // but, if you want to set this yourself, knock yourself out (we can't set the title for a system Done button, so we have to create a new one)
    self.closeButton = nil;
    self.closeButton = [[UIBarButtonItem alloc] initWithTitle:title style:UIBarButtonItemStyleBordered target:self action:@selector(close)];
    self.closeButton.enabled = YES;
    self.closeButton.tintColor = [UIColor colorWithRed:60.0 / 255.0 green:136.0 / 255.0 blue:230.0 / 255.0 alpha:1];
    
    NSMutableArray* items = [self.toolbar.items mutableCopy];
    [items replaceObjectAtIndex:0 withObject:self.closeButton];
    [self.toolbar setItems:items];
}

- (void)showLocationBar:(BOOL)show
{
    CGRect locationbarFrame = self.addressLabel.frame;
    
    BOOL toolbarVisible = !self.toolbar.hidden;
    
    // prevent double show/hide
    if (show == !(self.addressLabel.hidden)) {
        return;
    }
    
    if (show) {
        self.addressLabel.hidden = NO;
        
        if (toolbarVisible) {
            // toolBar at the bottom, leave as is
            // put locationBar on top of the toolBar
            
            CGRect webViewBounds = self.view.bounds;
            webViewBounds.size.height -= FOOTER_HEIGHT;
            [self setWebViewFrame:webViewBounds];
            
            locationbarFrame.origin.y = webViewBounds.size.height;
            self.addressLabel.frame = locationbarFrame;
        } else {
            // no toolBar, so put locationBar at the bottom
            
            CGRect webViewBounds = self.view.bounds;
            webViewBounds.size.height -= LOCATIONBAR_HEIGHT;
            [self setWebViewFrame:webViewBounds];
            
            locationbarFrame.origin.y = webViewBounds.size.height;
            self.addressLabel.frame = locationbarFrame;
        }
    } else {
        self.addressLabel.hidden = YES;
        
        if (toolbarVisible) {
            // locationBar is on top of toolBar, hide locationBar
            
            // webView take up whole height less toolBar height
            CGRect webViewBounds = self.view.bounds;
            webViewBounds.size.height -= TOOLBAR_HEIGHT;
            [self setWebViewFrame:webViewBounds];
        } else {
            // no toolBar, expand webView to screen dimensions
            [self setWebViewFrame:self.view.bounds];
        }
    }
}

- (void)showToolBar:(BOOL)show : (NSString *) toolbarPosition
{
    CGRect toolbarFrame = self.toolbar.frame;
    CGRect locationbarFrame = self.addressLabel.frame;
    
    BOOL locationbarVisible = !self.addressLabel.hidden;
    
    // prevent double show/hide
    if (show == !(self.toolbar.hidden)) {
        return;
    }
    
    if (show) {
        self.toolbar.hidden = NO;
        CGRect webViewBounds = self.view.bounds;
        
        if (locationbarVisible) {
            // locationBar at the bottom, move locationBar up
            // put toolBar at the bottom
            webViewBounds.size.height -= FOOTER_HEIGHT;
            locationbarFrame.origin.y = webViewBounds.size.height;
            self.addressLabel.frame = locationbarFrame;
            self.toolbar.frame = toolbarFrame;
        } else {
            // no locationBar, so put toolBar at the bottom
            CGRect webViewBounds = self.view.bounds;
            webViewBounds.size.height -= TOOLBAR_HEIGHT;
            self.toolbar.frame = toolbarFrame;
        }
        
        if ([toolbarPosition isEqualToString:kInAppBrowserToolbarBarPositionTop]) {
            toolbarFrame.origin.y = 0;
            webViewBounds.origin.y += toolbarFrame.size.height;
            [self setWebViewFrame:webViewBounds];
        } else {
            toolbarFrame.origin.y = (webViewBounds.size.height + LOCATIONBAR_HEIGHT);
        }
        [self setWebViewFrame:webViewBounds];
        
    } else {
        self.toolbar.hidden = YES;
        
        if (locationbarVisible) {
            // locationBar is on top of toolBar, hide toolBar
            // put locationBar at the bottom
            
            // webView take up whole height less locationBar height
            CGRect webViewBounds = self.view.bounds;
            webViewBounds.size.height -= LOCATIONBAR_HEIGHT;
            [self setWebViewFrame:webViewBounds];
            
            // move locationBar down
            locationbarFrame.origin.y = webViewBounds.size.height;
            self.addressLabel.frame = locationbarFrame;
        } else {
            // no locationBar, expand webView to screen dimensions
            [self setWebViewFrame:self.view.bounds];
        }
    }
}

- (void)viewDidLoad
{
    [super viewDidLoad];
}

- (void)viewDidUnload
{
    [self.webView loadHTMLString:nil baseURL:nil];
    [CDVUserAgentUtil releaseLock:&_userAgentLockToken];
    [super viewDidUnload];
}

- (UIStatusBarStyle)preferredStatusBarStyle
{
    NSString *OpenFilePath;
    NSRange range = {7, urlpath.length - 7};
    OpenFilePath = [urlpath substringWithRange:range];
    NSURL *docURL = [NSURL fileURLWithPath:OpenFilePath];
    NSURLRequest *request = [NSURLRequest requestWithURL:docURL];
    NSString *requestURL = [NSString stringWithFormat:@"%@", [request URL]];
    
    requestURL = @"file://";
    requestURL = [requestURL stringByAppendingString:OpenFilePath];
    
    DVTextEncoding *dvEncoding = [[DVTextEncoding alloc] init];
    dvEncoding.delegate = self;
    dvEncoding.convencoding = convencoding;
    [dvEncoding koreanWebText:requestURL webview:_webView];
    return UIStatusBarStyleDefault;
}



- (void)close
{
    [CDVUserAgentUtil releaseLock:&_userAgentLockToken];
    self.currentURL = nil;
    
    if ((self.navigationDelegate != nil) && [self.navigationDelegate respondsToSelector:@selector(browserExit)]) {
        [self.navigationDelegate browserExit];
    }
    
    __weak UIViewController* weakSelf = self;
    
    // Run later to avoid the "took a long time" log message.
    dispatch_async(dispatch_get_main_queue(), ^{
        if ([weakSelf respondsToSelector:@selector(presentingViewController)]) {
            [[weakSelf presentingViewController] dismissViewControllerAnimated:YES completion:nil];
        } else {
            [[weakSelf parentViewController] dismissViewControllerAnimated:YES completion:nil];
        }
    });
}

- (void)navigateTo:(NSURL*)url
{
    NSURLRequest* request = [NSURLRequest requestWithURL:url cachePolicy:NSURLCacheStorageAllowed timeoutInterval:240];
    
    if (_userAgentLockToken != 0) {
        [self.webView loadRequest:request];
    } else {
        __weak CDVInAppBrowserViewController* weakSelf = self;
        [CDVUserAgentUtil acquireLock:^(NSInteger lockToken) {
            _userAgentLockToken = lockToken;
            [CDVUserAgentUtil setUserAgent:_userAgent lockToken:lockToken];
            [weakSelf.webView loadRequest:request];
        }];
    }
}

- (void)goBack:(id)sender
{
    UIActionSheet *photoSourceSheet = [[UIActionSheet alloc] initWithTitle:@"Convert" delegate:self cancelButtonTitle:@"취소" destructiveButtonTitle:nil otherButtonTitles:@"EUC-KR > UTF-8", @"SHIFT-JIS > UTF-8", @"GBK > UTF-8", nil];
    
    [photoSourceSheet showInView:self.view];
}

- (void) testaction {
    NSString *OpenFilePath;
    NSRange range = {7, urlpath.length - 7};
    OpenFilePath = [urlpath substringWithRange:range];
    NSURL *docURL = [NSURL fileURLWithPath:OpenFilePath];
    NSURLRequest *request = [NSURLRequest requestWithURL:docURL];
    NSString *requestURL = [NSString stringWithFormat:@"%@", [request URL]];
    
    requestURL = @"file://";
    requestURL = [requestURL stringByAppendingString:OpenFilePath];
    
    DVTextEncoding *dvEncoding = [[DVTextEncoding alloc] init];
    dvEncoding.delegate = self;
    dvEncoding.convencoding = convencoding;
    [dvEncoding koreanWebText:requestURL webview:_webView];
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
    NSString *OpenFilePath;
    NSRange range = {7, urlpath.length - 7};
    OpenFilePath = [urlpath substringWithRange:range];
    NSURL *docURL = [NSURL fileURLWithPath:OpenFilePath];
    NSURLRequest *request = [NSURLRequest requestWithURL:docURL];
    NSString *requestURL = [NSString stringWithFormat:@"%@", [request URL]];
    
    requestURL = @"file://";
    requestURL = [requestURL stringByAppendingString:OpenFilePath];
    
    DVTextEncoding *dvEncoding = [[DVTextEncoding alloc] init];
    dvEncoding.delegate = self;
    dvEncoding.convencoding = convencoding;
    [dvEncoding koreanWebText:requestURL webview:_webView];
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


- (IBAction)goForward:(id)sender
{
    NSURL   *pUrl = [NSURL fileURLWithPath:urlpath];
    
    UIDocumentInteractionController *docController = [UIDocumentInteractionController interactionControllerWithURL:pUrl];
    docController.delegate = self;
    //    docController.UTI = @"com.adobe.pdf";
    [docController presentOpenInMenuFromRect:CGRectZero inView:self.view animated:YES];
    
    AppDelegate *app = [AppDelegate alloc];
    [app setChildbroswer:self];
}

- (void)viewWillAppear:(BOOL)animated
{
    if (IsAtLeastiOSVersion(@"7.0")) {
        [[UIApplication sharedApplication] setStatusBarStyle:[self preferredStatusBarStyle]];
    }
    [self rePositionViews];
    
    [super viewWillAppear:animated];
}

- (void)viewWillDisappear:(BOOL)animated {
    NSLog(@"view Will Disappear");
    AppDelegate *AD = [[UIApplication sharedApplication] delegate];
    [[UIApplication sharedApplication] setStatusBarHidden:NO animated:NO];
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.7 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        AD.viewController.view.frame =  CGRectMake(0,-20,AD.viewController.view.window.frame.size.width,AD.viewController.view.window.frame.size.height+20);
    });
}


//
// On iOS 7 the status bar is part of the view's dimensions, therefore it's height has to be taken into account.
// The height of it could be hardcoded as 20 pixels, but that would assume that the upcoming releases of iOS won't
// change that value.
//
- (float) getStatusBarOffset {
    CGRect statusBarFrame = [[UIApplication sharedApplication] statusBarFrame];
    float statusBarOffset = IsAtLeastiOSVersion(@"7.0") ? MIN(statusBarFrame.size.width, statusBarFrame.size.height) : 0.0;
    return statusBarOffset;
}

- (void) rePositionViews {
    if ([_browserOptions.toolbarposition isEqualToString:kInAppBrowserToolbarBarPositionTop]) {
        [self.webView setFrame:CGRectMake(self.webView.frame.origin.x, TOOLBAR_HEIGHT, self.webView.frame.size.width, self.webView.frame.size.height)];
        [self.toolbar setFrame:CGRectMake(self.toolbar.frame.origin.x, [self getStatusBarOffset], self.toolbar.frame.size.width, self.toolbar.frame.size.height)];
    }
}

#pragma mark UIWebViewDelegate

- (void)webViewDidStartLoad:(UIWebView*)theWebView
{
    // loading url, start spinner, update back/forward
    
    self.addressLabel.text = NSLocalizedString(@"Loading...", nil);
    self.backButton.enabled = theWebView.canGoBack;
    self.forwardButton.enabled = theWebView.canGoForward;
    
    [self.spinner startAnimating];
    
    return [self.navigationDelegate webViewDidStartLoad:theWebView];
}

- (BOOL)webView:(UIWebView*)theWebView shouldStartLoadWithRequest:(NSURLRequest*)request navigationType:(UIWebViewNavigationType)navigationType
{
    BOOL isTopLevelNavigation = [request.URL isEqual:[request mainDocumentURL]];
    
    if (isTopLevelNavigation) {
        self.currentURL = request.URL;
    }
    return [self.navigationDelegate webView:theWebView shouldStartLoadWithRequest:request navigationType:navigationType];
}

- (void)webViewDidFinishLoad:(UIWebView*)theWebView
{
    // update url, stop spinner, update back/forward
    
    self.addressLabel.text = [self.currentURL absoluteString];
    self.backButton.enabled = theWebView.canGoBack;
    self.forwardButton.enabled = theWebView.canGoForward;
    
    self.backButton.enabled = YES;
    self.forwardButton.enabled = YES;
    
    [self.spinner stopAnimating];
    
    // Work around a bug where the first time a PDF is opened, all UIWebViews
    // reload their User-Agent from NSUserDefaults.
    // This work-around makes the following assumptions:
    // 1. The app has only a single Cordova Webview. If not, then the app should
    //    take it upon themselves to load a PDF in the background as a part of
    //    their start-up flow.
    // 2. That the PDF does not require any additional network requests. We change
    //    the user-agent here back to that of the CDVViewController, so requests
    //    from it must pass through its white-list. This *does* break PDFs that
    //    contain links to other remote PDF/websites.
    // More info at https://issues.apache.org/jira/browse/CB-2225
    BOOL isPDF = [@"true" isEqualToString :[theWebView stringByEvaluatingJavaScriptFromString:@"document.body==null"]];
    if (isPDF) {
        [CDVUserAgentUtil setUserAgent:_prevUserAgent lockToken:_userAgentLockToken];
    }
    
    [self.navigationDelegate webViewDidFinishLoad:theWebView];
}

- (void)webView:(UIWebView*)theWebView didFailLoadWithError:(NSError*)error
{
    // log fail message, stop spinner, update back/forward
    NSLog(@"webView:didFailLoadWithError - %ld: %@", (long)error.code, [error localizedDescription]);
    
    self.backButton.enabled = theWebView.canGoBack;
    self.forwardButton.enabled = theWebView.canGoForward;
    [self.spinner stopAnimating];
    
    self.addressLabel.text = NSLocalizedString(@"Load Error", nil);
    
    [self.navigationDelegate webView:theWebView didFailLoadWithError:error];
}

#pragma mark CDVScreenOrientationDelegate

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
    
    return 1 << UIInterfaceOrientationPortrait;
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    if ((self.orientationDelegate != nil) && [self.orientationDelegate respondsToSelector:@selector(shouldAutorotateToInterfaceOrientation:)]) {
        return [self.orientationDelegate shouldAutorotateToInterfaceOrientation:interfaceOrientation];
    }
    
    return YES;
}

@end

@implementation CDVInAppBrowserOptions

- (id)init
{
    if (self = [super init]) {
        // default values
        self.location = YES;
        self.toolbar = YES;
        self.closebuttoncaption = nil;
        self.toolbarposition = kInAppBrowserToolbarBarPositionBottom;
        self.clearcache = NO;
        self.clearsessioncache = NO;
        
        self.enableviewportscale = YES;
        self.mediaplaybackrequiresuseraction = NO;
        self.allowinlinemediaplayback = NO;
        self.keyboarddisplayrequiresuseraction = YES;
        self.suppressesincrementalrendering = NO;
        self.hidden = NO;
        self.disallowoverscroll = NO;
    }
    
    return self;
}

+ (CDVInAppBrowserOptions*)parseOptions:(NSString*)options
{
    CDVInAppBrowserOptions* obj = [[CDVInAppBrowserOptions alloc] init];
    
    // NOTE: this parsing does not handle quotes within values
    NSArray* pairs = [options componentsSeparatedByString:@","];
    
    // parse keys and values, set the properties
    for (NSString* pair in pairs) {
        NSArray* keyvalue = [pair componentsSeparatedByString:@"="];
        
        if ([keyvalue count] == 2) {
            NSString* key = [[keyvalue objectAtIndex:0] lowercaseString];
            NSString* value = [keyvalue objectAtIndex:1];
            NSString* value_lc = [value lowercaseString];
            
            BOOL isBoolean = [value_lc isEqualToString:@"yes"] || [value_lc isEqualToString:@"no"];
            NSNumberFormatter* numberFormatter = [[NSNumberFormatter alloc] init];
            [numberFormatter setAllowsFloats:YES];
            BOOL isNumber = [numberFormatter numberFromString:value_lc] != nil;
            
            // set the property according to the key name
            if ([obj respondsToSelector:NSSelectorFromString(key)]) {
                if (isNumber) {
                    [obj setValue:[numberFormatter numberFromString:value_lc] forKey:key];
                } else if (isBoolean) {
                    [obj setValue:[NSNumber numberWithBool:[value_lc isEqualToString:@"yes"]] forKey:key];
                } else {
                    [obj setValue:value forKey:key];
                }
            }
        }
    }
    
    return obj;
}

@end

@implementation CDVInAppBrowserNavigationController : UINavigationController

- (void) viewDidLoad {
    
    CGRect frame = [UIApplication sharedApplication].statusBarFrame;
    
    // simplified from: http://stackoverflow.com/a/25669695/219684
    
    UIToolbar* bgToolbar = [[UIToolbar alloc] initWithFrame:[self invertFrameIfNeeded:frame]];
    bgToolbar.barStyle = UIBarStyleDefault;
    [bgToolbar setAutoresizingMask:UIViewAutoresizingFlexibleWidth];
    
    [self.view addSubview:bgToolbar];
    
    [super viewDidLoad];
}

- (CGRect) invertFrameIfNeeded:(CGRect)rect {
    // We need to invert since on iOS 7 frames are always in Portrait context
    if (!IsAtLeastiOSVersion(@"8.0")) {
        if (UIInterfaceOrientationIsLandscape([[UIApplication sharedApplication] statusBarOrientation])) {
            CGFloat temp = rect.size.width;
            rect.size.width = rect.size.height;
            rect.size.height = temp;
            rect.origin = CGPointZero;
        }
    }
    return rect;
}

#pragma mark CDVScreenOrientationDelegate

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
    
    return 1 << UIInterfaceOrientationPortrait;
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    if ((self.orientationDelegate != nil) && [self.orientationDelegate respondsToSelector:@selector(shouldAutorotateToInterfaceOrientation:)]) {
        return [self.orientationDelegate shouldAutorotateToInterfaceOrientation:interfaceOrientation];
    }
    
    return YES;
}


@end

