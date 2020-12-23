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

//
//  AppDelegate.m
//  CentralECMTablet
//
//  Created by ___FULLUSERNAME___ on ___DATE___.
//  Copyright ___ORGANIZATIONNAME___ ___YEAR___. All rights reserved.
//

#import "AppDelegate.h"
#import "MainViewController.h"
#import <Cordova/CDVPlugin.h>
#import "ReceiveDataViewController.h"
#import "MQTTClient.h"
#import <MQTTWebsocketTransport.h>
#import "ASIHTTPRequest.h"

#import "PlugPDF/PlugPDF.h"
#import "PlugPDF/Version.h"
#import "PlugPDF/NavigationController.h"

#import "backtrace.hpp"
#import <CrashReporter/CrashReporter.h>

AppDelegate * g_appdelegate;
BOOL          g_openFlag = NO;
static NSString* invokeString = nil;
static NSString* logincheck = nil;
static NSString* loginblack = nil;
@implementation AppDelegate

@synthesize window, viewController, recviewer, chbroswer;
//@synthesize window;
//@synthesize viewController;
- (id)init
{
    /** If you need to do any extra app-specific initialization, you can do it here
     *  -jm
     **/
    NSHTTPCookieStorage* cookieStorage = [NSHTTPCookieStorage sharedHTTPCookieStorage];
    
    [cookieStorage setCookieAcceptPolicy:NSHTTPCookieAcceptPolicyAlways];
    
    self = [super init];
    return self;
}

#pragma UIApplicationDelegate implementation

- (void)handleCrashReport {
    PLCrashReporter *crashReporter = [PLCrashReporter sharedReporter];
    NSData *crashData;
    NSError *error;
    
    // Try loading the crash report
    crashData = [crashReporter loadPendingCrashReportDataAndReturnError:&error];
    if (crashData == nil) {
        NSLog(@"Could not load crash report: %@", error);
        [crashReporter purgePendingCrashReport];
        return;
    }
    
    // We could send the report from here, but we'll just print out some debugging info instead
    PLCrashReport *report = [[PLCrashReport alloc] initWithData:crashData error:&error];
    if (report == nil) {
        NSLog(@"Could not parse crash report");
        [crashReporter purgePendingCrashReport];
        return;
    }
    
    [crashReporter purgePendingCrashReport];
    
    //get the documents directory:
    NSArray *paths = NSSearchPathForDirectoriesInDomains
    (NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *documentsDirectory = [paths objectAtIndex:0];
    
    //make a file name to write the data to using the documents directory:
    NSString *fileName = [NSString stringWithFormat:@"%@/textfile.txt",
                          documentsDirectory];
    //save content to the documents directory
    [[PLCrashReportTextFormatter stringValueForCrashReport:report withTextFormat:PLCrashReportTextFormatiOS] writeToFile:fileName
                                                                                                              atomically:NO
                                                                                                                encoding:NSStringEncodingConversionAllowLossy
                                                                                                                   error:nil];
    
    return;
}

/**
 * This is main kick off after the app inits, the views and Settings are setup here. (preferred - iOS4 and up)
 */
- (BOOL)application:(UIApplication*)application didFinishLaunchingWithOptions:(NSDictionary*)launchOptions
{
    PLCrashReporter *crashReporter = [PLCrashReporter sharedReporter];
    NSError *error;
    // Check if we previously crashed
    if ([crashReporter hasPendingCrashReport]) {
        [self handleCrashReport];
    }
    // Enable the Crash Reporter
    if (![crashReporter enableCrashReporterAndReturnError: &error]) {
        NSLog(@"Warning: Could not enable crash reporter: %@", error);
    }
    
    self.VCDic = [[MutableOrderedDictionary alloc] init];
    self.tmpVCDic = [[MutableOrderedDictionary alloc] init];
    self.checkFile = [[NSMutableArray alloc] init];
    
    self.firstOpenView = NO;
    self.back_index = 0;
    
    
    @try {
        PlugPDFInit((char *)"4CA2FEFD2H7E7CBHEDB5HEFGDCE62B2B9DE5B3H74B5AEE9DE8F6FBF5");
        setFontMappingPath([[NSURL alloc] initFileURLWithPath:[[NSBundle mainBundle] pathForResource:@"NanumBarunGothic" ofType:@"ttf"]]);
    } @catch (NSException *exception) {
        NSLog(@"Exception %@", exception.description);
    }
    
    [self.window.subviews makeObjectsPerformSelector:@selector(removeFromSuperview)];
    
    NSURL* url = [launchOptions objectForKey:UIApplicationLaunchOptionsURLKey];
    NSString* invokeString = nil;
    
    if (url && [url isKindOfClass:[NSURL class]]) {
        invokeString = [url absoluteString];
        NSLog(@"CentralECMTablet launchOptions = %@", url);
    }
    
    CGRect screenBounds = [[UIScreen mainScreen] bounds];
    self.window = [[[UIWindow alloc] initWithFrame:screenBounds] autorelease];
    self.window.autoresizesSubviews = YES;
    
    self.viewController = [[[MainViewController alloc] init] autorelease];
    self.viewController.useSplashScreen = YES;
    self.viewController.wwwFolderName = @"www";
    
    /*
     * target 따라 웹페이지 접속 하도록 수정
     */
    NSString *bunddlePath = [[NSBundle mainBundle] bundlePath];
    NSString *appName = [[NSFileManager defaultManager] displayNameAtPath:bunddlePath];
    
    NSLog(@"appName is %@", appName);
    
    [self networkCheck];
    /*
    if( [[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPhone )
    {
        if( [appName isEqualToString:@"SJ Cloud.app"] )
            self.viewController.startPage = @"index_sjcloud_mobile.html";
        else if( [appName isEqualToString:@"Mobile Docs.app"] )
            self.viewController.startPage = @"index_mobile_lotte.html";
        else if( [appName isEqualToString:@"Astellas_kr.app"] )
            self.viewController.startPage = @"astellas_kr/index_mobile.html";
        else
            self.viewController.startPage = @"login.html";
    }
    else{
        if( [appName isEqualToString:@"SJ Cloud.app"] )
            self.viewController.startPage = @"index_sjcloud_pad.html";
        else if( [appName isEqualToString:@"Mobile Docs.app"] )
            self.viewController.startPage = @"index_pad_lotte.html";
        else if( [appName isEqualToString:@"Astellas_kr.app"] )
            self.viewController.startPage = @"astellas_kr/index_pad.html";
        else
            self.viewController.startPage = @"index_pad.html";
    }
*/
    
//    self.viewController.startPage = @"explorer.html#2001615&123123";
//    /*
//     * g_appdelegate = [[AppDelegate alloc] init];
//     * App간 상호 호출 후 뷰어 새로고침 위해 적용
//     */
//    g_appdelegate = [[AppDelegate alloc] init];
//    
//    // 다른 App에서 데이터 받은 후 서버 업로드 할 때 로그인 체크 ( 로그인 안된 경우 업로드 차단위함 )
//    ReceiveDataViewController *receivedatacontroller = [[[ReceiveDataViewController alloc] init] autorelease];
//    [receivedatacontroller setLoginFlag:NO SetUserID:@""];
//    
//    self.viewController.invokeString = invokeString;
//    
//    // NOTE: To control the view's frame size, override [self.viewController viewWillAppear:] in your view controller.
//    
//    // check whether the current orientation is supported: if it is, keep it, rather than forcing a rotation
//    BOOL forceStartupRotation = YES;
//    UIDeviceOrientation curDevOrientation = [[UIDevice currentDevice] orientation];
//    
//    if (UIDeviceOrientationUnknown == curDevOrientation) {
//        // UIDevice isn't firing orientation notifications yet… go look at the status bar
//        curDevOrientation = (UIDeviceOrientation)[[UIApplication sharedApplication] statusBarOrientation];
//    }
//    
//    if (UIDeviceOrientationIsValidInterfaceOrientation(curDevOrientation)) {
//        if ([self.viewController supportsOrientation:curDevOrientation]) {
//            forceStartupRotation = NO;
//        }
//    }
//    
//    if (forceStartupRotation) {
//        UIInterfaceOrientation newOrient;
//        if ([self.viewController supportsOrientation:UIInterfaceOrientationPortrait]) {
//            newOrient = UIInterfaceOrientationPortrait;
//        } else if ([self.viewController supportsOrientation:UIInterfaceOrientationLandscapeLeft]) {
//            newOrient = UIInterfaceOrientationLandscapeLeft;
//        } else if ([self.viewController supportsOrientation:UIInterfaceOrientationLandscapeRight]) {
//            newOrient = UIInterfaceOrientationLandscapeRight;
//        } else {
//            newOrient = UIInterfaceOrientationPortraitUpsideDown;
//        }
//    
//        NSLog(@"AppDelegate forcing status bar to: %d from: %d", newOrient, curDevOrientation);
//        [[UIApplication sharedApplication] setStatusBarOrientation:newOrient];
//    }
//    
//
//    // Overlapping
    if ([[[UIDevice currentDevice] systemVersion] floatValue] >= 7) {
//        [application setStatusBarStyle:UIStatusBarStyleLightContent];
        self.window.clipsToBounds =YES;
//        self.window.frame =  CGRectMake(0,20,self.window.frame.size.width,self.window.frame.size.height-20);
    }

    [[UIApplication sharedApplication] setStatusBarHidden:NO animated:NO];

//    [[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleLightContent animated:YES];
//
//    
//    self.window.rootViewController = self.viewController;
//    [self.window makeKeyAndVisible];
//    
//    
//    return YES;
//    
//    /*     update sample source     */
//    NSString *iTunesLink = @"itms://itunes.apple.com/us/app/apple-store/id375380948?mt=8";
//    [[UIApplication sharedApplication] openURL:[NSURL URLWithString:iTunesLink]];
    
    NSNotificationCenter *sendNotification = [NSNotificationCenter defaultCenter];
    [sendNotification addObserver:self selector:@selector(secondMethod:) name:@"secondNotification" object: nil];
    
    NSNotificationCenter *sendNotification2 = [NSNotificationCenter defaultCenter];
    [sendNotification2 addObserver:self selector:@selector(firstMethod2:) name:@"firstNotification2" object: nil];
    
    NSNotificationCenter *sendNotification3 = [NSNotificationCenter defaultCenter];
    [sendNotification3 addObserver:self selector:@selector(firstMethod3:) name:@"firstNotification3" object: nil];
    
    NSNotificationCenter *sendNotification4 = [NSNotificationCenter defaultCenter];
    [sendNotification4 addObserver:self selector:@selector(firstMethod4:) name:@"firstNotification4" object: nil];
    
    self.getAuth;
}

- (void)secondMethod:(NSNotification *)notification {
    NSString* pdfPath = [[NSUserDefaults standardUserDefaults] objectForKey:@"pdfPath"];
    
    NSRange strRange = [pdfPath rangeOfString:@"'"];
    NSString *convertPdfPath;
    
    if (strRange.location != NSNotFound) {
        pdfPath = [pdfPath stringByReplacingOccurrencesOfString:@"'" withString:@"NetID_apostrophe"];
    }

    [self.viewController.webView stringByEvaluatingJavaScriptFromString:[NSString stringWithFormat:@"UploadPDF('%@')", pdfPath]];
}

- (void)firstMethod2:(NSNotification *)notification {
    UIDeviceOrientation orientation = [[UIApplication sharedApplication] statusBarOrientation];
    CGFloat windowHeight = CGRectGetHeight(self.window.frame);
    CGFloat windowWidth = CGRectGetWidth(self.window.frame);
    NSLog(@"windowWidth = %f", windowWidth);
    if(windowWidth > 1000)
        [self.viewController.webView stringByEvaluatingJavaScriptFromString:@"isSplit=\"no\";"];
    else
        [self.viewController.webView stringByEvaluatingJavaScriptFromString:@"isSplit=\"yes\";"];
    
    if((int)orientation == 3 || (int)orientation == 4){
        if(windowWidth > 1000){
            [self.viewController.webView stringByEvaluatingJavaScriptFromString:@"$(\"head\").append(\"<link rel='stylesheet' type='text/css' href='css/size100_land.css'>\")"];
        } else if (windowWidth < 1000 && windowWidth > 700) {
            [self.viewController.webView stringByEvaluatingJavaScriptFromString:@"$(\"head\").append(\"<link rel='stylesheet' type='text/css' href='css/size70_land.css'>\")"];
        } else if (windowWidth < 700 && windowWidth > 400) {
            [self.viewController.webView stringByEvaluatingJavaScriptFromString:@"$(\"head\").append(\"<link rel='stylesheet' type='text/css' href='css/size50_land.css'>\")"];
        } else {
            [self.viewController.webView stringByEvaluatingJavaScriptFromString:@"$(\"head\").append(\"<link rel='stylesheet' type='text/css' href='css/size30_land.css'>\")"];
            [self.viewController.webView stringByEvaluatingJavaScriptFromString:@"closeLeftMenu()"];
        }
    } else {
        if(windowWidth > 900){
            [self.viewController.webView stringByEvaluatingJavaScriptFromString:@"$(\"head\").append(\"<link rel='stylesheet' type='text/css' href='css/size100.css'>\")"];
        } else if (windowWidth < 900 && windowWidth > 600) {
            [self.viewController.webView stringByEvaluatingJavaScriptFromString:@"$(\"head\").append(\"<link rel='stylesheet' type='text/css' href='css/size70.css'>\")"];
        } else {
            [self.viewController.webView stringByEvaluatingJavaScriptFromString:@"$(\"head\").append(\"<link rel='stylesheet' type='text/css' href='css/size30.css'>\")"];
            [self.viewController.webView stringByEvaluatingJavaScriptFromString:@"closeLeftMenu()"];
        }
    }
}

- (void)firstMethod3:(NSNotification *)notification {
    NSLog(@"Appdelegate - checkAuth");
    [self.viewController.webView stringByEvaluatingJavaScriptFromString:@"checkAuth()"];
}

- (void)firstMethod4:(NSNotification *)notification {
    NSString* test = [self.viewController.webView stringByEvaluatingJavaScriptFromString:@"downFolder2()"];
    NSLog(@"test = %@", test);
}


- (void)getAuth{
//    NSString * strURL = [NSString stringWithFormat:@"tmckoreanre://?schemes=netidcloudoc&ver=1.7&mode=get"];
//    
//    if (![[UIApplication sharedApplication] openURL:[NSURL URLWithString:strURL]]) {
//        NSLog(@"test");
//        UIAlertView *alert = [[UIAlertView alloc]initWithTitle:nil message:NSLocalizedString(@"모바일 통합인증 App이 설치되어 있지 않습니다. 모바일 통합인증 App을 설치해 주시기 바랍니다.",nil) delegate:self cancelButtonTitle:NSLocalizedString(@"확인",nil) otherButtonTitles:nil];
//        alert.tag = 0;
//        [alert show];
//    }
    dispatch_async(dispatch_get_main_queue(), ^{
        /* app Version */
        NSDictionary *infoDic = [[NSBundle mainBundle] infoDictionary];
        NSString *appVersion = [infoDic objectForKey:@"CFBundleShortVersionString"];

        NSString *UrlString = @"tmckoreanre://?schemes=netidcloudoc2&ver=";
        UrlString = [UrlString stringByAppendingString:appVersion];
        UrlString = [UrlString stringByAppendingString:@"&mode=get"];
    
        NSURL *authUrl = [NSURL URLWithString:UrlString];
        if([[UIApplication sharedApplication] canOpenURL:authUrl]) {
            [[UIApplication sharedApplication] openURL:authUrl];
        }
    });
}

 - (void)newMessage:(MQTTSession *)session
 data:(NSData *)data
 onTopic:(NSString *)topic
 qos:(MQTTQosLevel)qos
 retained:(BOOL)retained
 mid:(unsigned int)mid{
 NSString* tStr = [[[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding] autorelease];
 NSLog(@"receive MQTT data = %@", tStr);
 
 
 // UILocalNotification 객체 생성
 UILocalNotification *noti = [[UILocalNotification alloc]init];
 
 // 알람 발생 시각 설정. 5초후로 설정. NSDate 타입.
 noti.fireDate = [NSDate dateWithTimeIntervalSinceNow:5];
 
 // timeZone 설정.
 noti.timeZone = [NSTimeZone systemTimeZone];
 
 // 알림 메시지 설정
 noti.alertBody = tStr;
 
 // 알림 액션 설정
 noti.alertAction = @"GOGO";
 
 // 아이콘 뱃지 넘버 설정. 임의로 1 입력
 noti.applicationIconBadgeNumber = 1;
 
 // 알림 사운드 설정. 자체 제작 사운드도 가능. (if nil = no sound)
 noti.soundName = UILocalNotificationDefaultSoundName;
 
 // 임의의 사용자 정보 설정. 알림 화면엔 나타나지 않음
 noti.userInfo = [NSDictionary dictionaryWithObject:@"My User Info" forKey:@"User Info"];
 
 // UIApplication을 이용하여 알림을 등록.
 [[UIApplication sharedApplication] scheduleLocalNotification:noti];
 
 }



// this happens while we are running ( in the background, or from within our own app )
// only valid if CentralECMTablet-Info.plist specifies a protocol to handle
- (BOOL)application:(UIApplication*)application handleOpenURL:(NSURL*)url
{
    if (!url) {
        return NO;
    }
    
    // calls into javascript global function 'handleOpenURL'
    NSString* jsString = [NSString stringWithFormat:@"handleOpenURL(\"%@\");", url];
    [self.viewController.webView stringByEvaluatingJavaScriptFromString:jsString];
    
    // all plugins will get the notification, and their handlers will be called
    [[NSNotificationCenter defaultCenter] postNotification:[NSNotification notificationWithName:CDVPluginHandleOpenURLNotification object:url]];
    
    return YES;
}

- (NSUInteger)application:(UIApplication*)application supportedInterfaceOrientationsForWindow:(UIWindow*)window
{
    // iPhone doesn't support upside down by default, while the iPad does.  Override to allow all orientations always, and let the root view controller decide what's allowed (the supported orientations mask gets intersected).
    
    NSUInteger supportedInterfaceOrientations = (1 << UIInterfaceOrientationPortrait) | (1 << UIInterfaceOrientationLandscapeLeft) | (1 << UIInterfaceOrientationLandscapeRight) | (1 << UIInterfaceOrientationPortraitUpsideDown);
    
    return supportedInterfaceOrientations;
}

- (BOOL)shouldAutorotate{
    NSLog(@"test3");
}

// 회전하기 직전에 바로 회전이 시작됨을 알려줍니다 (회전 전 호출)
- (NSUInteger)application: (UIApplication*)application willChangeStatusBarOrientation:(UIInterfaceOrientation)newStatusBarOrientation duration:(NSTimeInterval)duration{
//    NSLog(@"active width = %f", self.viewController.view.window.frame.size.width);
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.1 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
//        UIWindow* keyWindow = [UIApplication sharedApplication].keyWindow;
//        NSLog(@"size = %f", CGRectGetWidth(keyWindow.frame));
////        self.viewController.view.frame = keyWindow.frame;
////        CGRect screenRect = [[UIScreen mainScreen] bounds]; //스크린에 대한 모든 정보
//        NSInteger screenWidth = CGRectGetWidth(keyWindow.frame); //스크린의 넓이
//        NSInteger screenHeight = CGRectGetHeight(keyWindow.frame); //스크린의 길이
        self.viewController.view.frame =  CGRectMake(0,-20,self.viewController.view.window.frame.size.width,self.viewController.view.window.frame.size.height+20);
    });
}
//
//// 회전 후에 회전이 완료됨을 알려줍니다 (회전 후 호출)
- (NSUInteger)application: (UIApplication*)application didChangeStatusBarOrientation:(UIInterfaceOrientation)oldStatusBarOrientation {
    NSLog(@"active width2 = %f", self.viewController.view.window.frame.size.width);
//    if ([[[UIDevice currentDevice] systemVersion] floatValue] >= 7) {
//        [application setStatusBarStyle:UIStatusBarStyleLightContent];
//        self.window.clipsToBounds =YES;
////        self.window.frame =  CGRectMake(20,0,self.window.frame.size.width,self.window.frame.size.height);
//        self.window.frame = CGRectMake(0, 20, CGRectGetWidth([[UIScreen mainScreen] bounds]), CGRectGetHeight([[UIScreen mainScreen] bounds])-20);
//    }
    UIDeviceOrientation orientation = [[UIApplication sharedApplication] statusBarOrientation];
    CGFloat windowHeight = CGRectGetHeight(self.window.frame);
    CGFloat windowWidth = CGRectGetWidth(self.window.frame);
    NSLog(@"windowWidth = %f", windowWidth);
    if((int)orientation == 3 || (int)orientation == 4){
        if(windowWidth > 1000){
            [self.viewController.webView stringByEvaluatingJavaScriptFromString:@"$(\"head\").append(\"<link rel='stylesheet' type='text/css' href='css/size100_land.css'>\")"];
        } else if (windowWidth < 1000 && windowWidth > 700) {
            [self.viewController.webView stringByEvaluatingJavaScriptFromString:@"$(\"head\").append(\"<link rel='stylesheet' type='text/css' href='css/size70_land.css'>\")"];
        } else if (windowWidth < 700 && windowWidth > 400) {
            [self.viewController.webView stringByEvaluatingJavaScriptFromString:@"$(\"head\").append(\"<link rel='stylesheet' type='text/css' href='css/size50_land.css'>\")"];
        } else {
            [self.viewController.webView stringByEvaluatingJavaScriptFromString:@"$(\"head\").append(\"<link rel='stylesheet' type='text/css' href='css/size30_land.css'>\")"];
            [self.viewController.webView stringByEvaluatingJavaScriptFromString:@"closeLeftMenu()"];
        }
    } else {
        if(windowWidth > 900){
            [self.viewController.webView stringByEvaluatingJavaScriptFromString:@"$(\"head\").append(\"<link rel='stylesheet' type='text/css' href='css/size100.css'>\")"];
        } else if (windowWidth < 900 && windowWidth > 600) {
            [self.viewController.webView stringByEvaluatingJavaScriptFromString:@"$(\"head\").append(\"<link rel='stylesheet' type='text/css' href='css/size70.css'>\")"];
        } else {
            [self.viewController.webView stringByEvaluatingJavaScriptFromString:@"$(\"head\").append(\"<link rel='stylesheet' type='text/css' href='css/size30.css'>\")"];
            [self.viewController.webView stringByEvaluatingJavaScriptFromString:@"closeLeftMenu()"];
        }
    }
}

/*
 * 다른 App에서 데이터 받을 때 호출되는 함수 적용
 */

-(BOOL) application:(UIApplication *)application openURL:(NSURL *)url sourceApplication:(NSString *)sourceApplication annotation:(id)annotation{
    
    
    @try {
    
    logincheck = @"true";

    
    
    NSString *UserID;
    NSString *authKey;
    NSString *mac;
//    NSString *authURL = @"explorer.html#";
    NSString *authURL = @"index.html#";
    NSString *mode;
    
    NSLog(@"success request");
    NSLog(@"url = %@", url);
    NSString *myurl = url.absoluteString;
        if([myurl isEqualToString:@"netidcloudoc://"]){
            return YES;
        } else {
            NSArray *params = [url.query componentsSeparatedByString:@"&"];
            for (NSString *param in params) {
                NSArray *components = [param componentsSeparatedByString:@"="];
                NSString *key = components[0];
                NSString *value = [components[1] stringByReplacingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
                if ([key isEqualToString:@"mode"]) {
                    if ([value isEqualToString:@"get"]){
                        mode = @"get";
                    }
                    else if([value isEqualToString:@"check"]){
                        
                    }
                } else if ([key isEqualToString:@"id"]) {
                    UserID = value;
                } else if ([key isEqualToString:@"key"]) {
                    authKey = value;
                } else if ([key isEqualToString:@"mac"]) {
                    mac = value;
                }
            }
    
            if([mode isEqualToString:@"get"]){
        
                /*
                 * target 따라 웹페이지 접속 하도록 수정
                 */
                NSString *bunddlePath = [[NSBundle mainBundle] bundlePath];
                NSString *appName = [[NSFileManager defaultManager] displayNameAtPath:bunddlePath];
                NSString *bundleIdentifier = [[NSBundle mainBundle] bundleIdentifier];
                NSLog(@"appName is %@", appName);
        
        
                authURL = [authURL stringByAppendingString:UserID];
                authURL = [authURL stringByAppendingString:@"&"];
                authURL = [authURL stringByAppendingString:authKey];
                authURL = [authURL stringByAppendingString:@"&"];
                authURL = [authURL stringByAppendingString:mac];
                authURL = [authURL stringByAppendingString:@"&"];
                authURL = [authURL stringByAppendingString:bundleIdentifier];
                NSLog(@"authURL = %@", authURL);
        
                self.viewController.startPage = authURL;

                /*
                 * g_appdelegate = [[AppDelegate alloc] init];
                 * App간 상호 호출 후 뷰어 새로고침 위해 적용
                 */
                g_appdelegate = [[AppDelegate alloc] init];
        
                // 다른 App에서 데이터 받은 후 서버 업로드 할 때 로그인 체크 ( 로그인 안된 경우 업로드 차단위함 )
                ReceiveDataViewController *receivedatacontroller = [[[ReceiveDataViewController alloc] init] autorelease];
                [receivedatacontroller setLoginFlag:NO SetUserID:@""];
        
                self.viewController.invokeString = invokeString;
        
                // NOTE: To control the view's frame size, override [self.viewController viewWillAppear:] in your view controller.
        
                // check whether the current orientation is supported: if it is, keep it, rather than forcing a rotation
//                BOOL forceStartupRotation = YES;
//                UIDeviceOrientation curDevOrientation = [[UIDevice currentDevice] orientation];
//        
//                if (UIDeviceOrientationUnknown == curDevOrientation) {
//                    // UIDevice isn't firing orientation notifications yet… go look at the status bar
//                    curDevOrientation = (UIDeviceOrientation)[[UIApplication sharedApplication] statusBarOrientation];
//                }
//        
//                if (UIDeviceOrientationIsValidInterfaceOrientation(curDevOrientation)) {
//                    if ([self.viewController supportsOrientation:curDevOrientation]) {
//                        forceStartupRotation = NO;
//                    }
//                }
//        
//                if (forceStartupRotation) {
//                    UIInterfaceOrientation newOrient;
//                    if ([self.viewController supportsOrientation:UIInterfaceOrientationPortrait]) {
//                        newOrient = UIInterfaceOrientationPortrait;
//                    } else if ([self.viewController supportsOrientation:UIInterfaceOrientationLandscapeLeft]) {
//                        newOrient = UIInterfaceOrientationLandscapeLeft;
//                    } else if ([self.viewController supportsOrientation:UIInterfaceOrientationLandscapeRight]) {
//                        newOrient = UIInterfaceOrientationLandscapeRight;
//                    } else {
//                        newOrient = UIInterfaceOrientationPortraitUpsideDown;
//                    }
//            
//                    NSLog(@"AppDelegate forcing status bar to: %d from: %d", newOrient, curDevOrientation);
//                    //              [[UIApplication sharedApplication] setStatusBarOrientation:newOrient];
//                }
                /*
                 UIWebView *webview = [[UIWebView alloc] init] ;
                 NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:[NSURL URLwithString:@""] cachePolicy:NSURLRequestReloadIgnoringCacheData timeoutInterval:10.0f];
                 [webview loadRequest:request];
                 */
        
        
                
                 // Overlapping
//                 if ([[[UIDevice currentDevice] systemVersion] floatValue] >= 7) {
                 [application setStatusBarStyle:UIStatusBarStyleLightContent];
//                 self.window.clipsToBounds =YES;
                
//                 self.window.frame =  CGRectMake(0,-20,self.window.frame.size.width,self.window.frame.size.height+20);
//                 }
                
                //        [[UIApplication sharedApplication] setStatusBarHidden:NO animated:NO];
                //        [[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleBlackTranslucent animated:YES];

        
        
                self.navigationController = [[UINavigationController alloc]initWithRootViewController:self.viewController];
                self.navigationController.delegate = self;
                [self.navigationController setNavigationBarHidden:YES animated:YES];
                self.navigationController.toolbarHidden = YES;
                
                NSNotificationCenter *sendNotification = [NSNotificationCenter defaultCenter];
                [sendNotification addObserver:self selector:@selector(firstMethod:) name:@"firstNotification" object: nil];
                
                self.window.rootViewController = self.navigationController;
//                self.window.rootViewController = self.viewController;
                
                [self.window makeKeyAndVisible];
                
                
                // 클립보드 복사 금지
                UILongPressGestureRecognizer* longPress = [[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(handleLongPressGestures:)]; // allocating the UILongPressGestureRecognizer
                
                longPress.allowableMovement=100; // Making sure the allowable movement isn't too narrow
                
                longPress.minimumPressDuration=0.3; // This is important - the duration must be long enough to allow taps but not longer than the period in which the scroll view opens the magnifying glass
                
                longPress.delegate=self; // initialization stuff
                longPress.delaysTouchesBegan=YES;
                longPress.delaysTouchesEnded=YES;
                
                longPress.cancelsTouchesInView=YES; // That's when we tell the gesture recognizer to block the gestures we want
                
                [self.viewController.view addGestureRecognizer:longPress]; // Add the gesture recognizer to the view and scroll view then release
//                [self.navigationController.view addGestureRecognizer:longPress];
//                [[self.viewController.view scrollView] addGestureRecognizer:longPress];

                return YES;
            }
        }
    return YES;
    }
    @catch (NSException * e) {
        NSLog(@"Error: %@%@", [e name], [e reason]);
    }
    @finally {
        NSLog(@"Finally executes no matter what");
    }
}
- (void)handleLongPressGestures:(UILongPressGestureRecognizer*)sender
    {
        
    }
    
    
    // 스플릿 뷰어 이벤트 처리
- (void)firstMethod:(NSNotification *)notification {
//    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.1 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        self.viewController.view.frame =  CGRectMake(0,-20,self.viewController.view.window.frame.size.width,self.viewController.view.window.frame.size.height+20);
//    });
}
    
- (void)dealloc
{
    [window release];
    [viewController release];
    //[g_appdelegate release];
    [super dealloc];
}

- (void)applicationWillResignActive:(UIApplication *)application
{
    /*
     Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
     Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
     */
}

/*
 * 다른 App으로 데이터 넘길때 백그라운드 진입시점에 호출
 * 기존 뷰어 종료위해 코드 추가
 */

- (void)applicationDidEnterBackground:(UIApplication *)application
{
    [UIPasteboard generalPasteboard].string = @"";
    loginblack = @"true";
    
    /*
     Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is -d later.
     If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
     */
    //if (g_openFlag) {
    [g_appdelegate.chbroswer closeBrowser];
    //}
    
}

- (void)applicationWillEnterForeground:(UIApplication *)application
{
    [self performSelector:@selector(runningAfter5Seconds) withObject:nil afterDelay:1.0];

    UIDeviceOrientation orientation = [[UIApplication sharedApplication] statusBarOrientation];
    CGFloat windowHeight = CGRectGetHeight(self.window.frame);
    CGFloat windowWidth = CGRectGetWidth(self.window.frame);
    NSLog(@"windowWidth = %f", windowWidth);
    NSLog(@"%d", (int)orientation);
    
    if((int)orientation == 3 || (int)orientation == 4){
        if(windowWidth > 1000){
            [self.viewController.webView stringByEvaluatingJavaScriptFromString:@"$(\"head\").append(\"<link rel='stylesheet' type='text/css' href='css/size100_land.css'>\")"];
        } else if (windowWidth < 1000 && windowWidth > 700) {
            [self.viewController.webView stringByEvaluatingJavaScriptFromString:@"$(\"head\").append(\"<link rel='stylesheet' type='text/css' href='css/size70_land.css'>\")"];
        } else if (windowWidth < 700 && windowWidth > 400) {
            [self.viewController.webView stringByEvaluatingJavaScriptFromString:@"$(\"head\").append(\"<link rel='stylesheet' type='text/css' href='css/size50_land.css'>\")"];
        } else {
            [self.viewController.webView stringByEvaluatingJavaScriptFromString:@"$(\"head\").append(\"<link rel='stylesheet' type='text/css' href='css/size30_land.css'>\")"];
            [self.viewController.webView stringByEvaluatingJavaScriptFromString:@"closeLeftMenu()"];
        }
    } else {
        if(windowWidth > 900){
            [self.viewController.webView stringByEvaluatingJavaScriptFromString:@"$(\"head\").append(\"<link rel='stylesheet' type='text/css' href='css/size100.css'>\")"];
        } else if (windowWidth < 900 && windowWidth > 600) {
            [self.viewController.webView stringByEvaluatingJavaScriptFromString:@"$(\"head\").append(\"<link rel='stylesheet' type='text/css' href='css/size70.css'>\")"];
        } else {
            [self.viewController.webView stringByEvaluatingJavaScriptFromString:@"$(\"head\").append(\"<link rel='stylesheet' type='text/css' href='css/size30.css'>\")"];
            [self.viewController.webView stringByEvaluatingJavaScriptFromString:@"closeLeftMenu()"];
        }
    }
    /*
     Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
     */
    //    [self.chbroswer closeBrowser];
    
}

- (void)runningAfter5Seconds {
    if (![logincheck isEqualToString:@"true"]) {
        
        NSDictionary *infoDic = [[NSBundle mainBundle] infoDictionary];
        NSString *appVersion = [infoDic objectForKey:@"CFBundleShortVersionString"];
        
        NSString *UrlString = @"tmckoreanre://?schemes=netidcloudoc&ver=";
        UrlString = [UrlString stringByAppendingString:appVersion];
        UrlString = [UrlString stringByAppendingString:@"&mode=get"];
        
        
        NSURL *authUrl = [NSURL URLWithString:UrlString];
        if([[UIApplication sharedApplication] canOpenURL:authUrl]) {
            [[UIApplication sharedApplication] openURL:authUrl];
        }
    }
}


- (void)applicationDidBecomeActive:(UIApplication *)application
{
    /*
    self.viewController = [[[MainViewController alloc] init] autorelease];
    self.viewController.useSplashScreen = YES;
    self.viewController.wwwFolderName = @"www";
    */
    
    
    
    /*
     Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
     */
}

- (void)applicationWillTerminate:(UIApplication *)application
{
    PlugPDFUninit();
    /*
     Called when the application is about to terminate.
     Save data if appropriate.
     See also applicationDidEnterBackground:.
     */
    
    
    /* app Version */
    /*
    NSDictionary *infoDic = [[NSBundle mainBundle] infoDictionary];
    NSString *appVersion = [infoDic objectForKey:@"CFBundleShortVersionString"];
    
    NSString *UrlString = @"tmckoreanre://?schemes=netidcloudoc&ver=";
    UrlString = [UrlString stringByAppendingString:appVersion];
    UrlString = [UrlString stringByAppendingString:@"&mode=logout"];
    
    
     NSURL *authUrl = [NSURL URLWithString:UrlString];
     if([[UIApplication sharedApplication] canOpenURL:authUrl]) {
     [[UIApplication sharedApplication] openURL:authUrl];
     }
    
    exit(0);
     */
}

/*
 * 다른 어플리케이션 호출할때 기존 뷰어 정보 저장
 * 백그라운드 진입 시 뷰어 종료 위해 사용
 */
- (void) setChildbroswer:(ChildBrowserViewController *)childbroswer
{
    g_openFlag = YES;
    g_appdelegate.chbroswer = childbroswer;
}

- (void)networkCheck
{
//    [[NSNotificationCenter defaultCenter] addObserver: self selector: @selector(reachabilityChanged:) name: kReachabilityChangedNotification object: nil];
//    
//    internetReach = [Reachability reachabilityForInternetConnection];
//    [internetReach startNotifier];
//    [self updateInterfaceWithReachability:internetReach];
}

// 네트워크 상태가 변경 될 경우 호출된다.
- (void)reachabilityChanged:(NSNotification *)note
{
//    Reachability *curReach = [note object];
//    NSParameterAssert([curReach isKindOfClass: [Reachability class]]);
//    [self updateInterfaceWithReachability:curReach];
}

// 네트워크 상태가 변경 될 경우 처리
- (void)updateInterfaceWithReachability:(Reachability *)curReach
{
//    if(curReach == internetReach)
//    {
//        NetworkStatus netStatus = [curReach currentReachabilityStatus];
//        
//        NSString *statusString = @"";
//        switch (netStatus)
//        {
//            case NotReachable:
//                statusString = @"Access Not Available";
//                break;
//            case ReachableViaWiFi:
//                statusString = @"Reachable WiFi";
//                break;
//            case ReachableViaWWAN:
//                statusString = @"Reachable WWAN";
//                break;
//                
//            default:
//                break;
//        }
//        
//        NSLog(@"Net Status changed. current status=%@ ", statusString);
//        
//        // 네트워크 상태에 따라 처리
//    }
//    
////    UIAlertView *alert = [[UIAlertView alloc]init];
////    alert.message = @"통신 상태가 불안정합니다.";
////    [alert addButtonWithTitle:@"확인"];
////    [alert show];
}

@end
