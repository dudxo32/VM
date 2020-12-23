//
//  UpDownManagerPlugin.m
//  CECMPad
//
//  Created by 넷아이디 on 12. 1. 10..
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "UpDownManagerPlugin.h"
#import "Util.h"
#import "DownLoadFiles.h"
#import "UploadFiles.h"
//#import "WebThree20ViewController.h"
#import "ServerViewController.h"
#import "ReceiveDataViewController.h"

#import <Cordova/CDVViewController.h>


@implementation UpDownManagerPlugin
    @synthesize callbackID,ActView, ActViewPhone;
    @synthesize cont;
    
- (void) download:(CDVInvokedUrlCommand*)command{
    //    self.callbackID = [arguments pop];
    //    self.callbackID = [arguments objectAtIndex:0];
    self.callbackID = self.callbackID;
    AppDelegate *AD = [[UIApplication sharedApplication] delegate];
    
    NSString* getPath = [command.arguments objectAtIndex:12];
    
    if([getPath isEqualToString:@"backViewer"]){
        if(AD.pdfCount == 0){
            NSString* retValue = @"열려있는 문서가 없습니다.";
            NSMutableString *stringToReturn = [NSMutableString stringWithString:retValue];
            
            //CDVPluginResult* pluginResult = [pluginResult resultWithStatus:CDVCommandStatus_OK messageAsString:[stringToReturn stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding]];
            CDVPluginResult* pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK messageAsString:stringToReturn];
            //    [self writeJavascript:[pluginResult toSuccessCallbackString:self.callbackID]];
            [self.commandDelegate sendPluginResult:pluginResult callbackId:command.callbackId];
            
            return;
        } else {
            //            getPath = AD.checkFile[AD.back_index];
            int i = 0;
            
            for (id key in AD.VCDic) {
                if(i == AD.back_index){
                    getPath = key;
                }
                i++;
            }
            
            AD.isOpened = YES;
            
            NSString* retValue = getPath;
            NSMutableString *stringToReturn = [NSMutableString stringWithString:retValue];
            
            //CDVPluginResult* pluginResult = [pluginResult resultWithStatus:CDVCommandStatus_OK messageAsString:[stringToReturn stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding]];
            CDVPluginResult* pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK messageAsString:stringToReturn];
            //    [self writeJavascript:[pluginResult toSuccessCallbackString:self.callbackID]];
            [self.commandDelegate sendPluginResult:pluginResult callbackId:command.callbackId];
            
            return;
        }
    }
    
    AD.tmpFileInfo = [command.arguments objectAtIndex:24];
    if( [[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPhone )
    {
        if(ActViewPhone == nil)
        {
            ActViewPhone = [[ActivityViewController_phone alloc] init];
            [ActViewPhone.view setBackgroundColor:[[[UIColor alloc] initWithWhite:0.0f alpha:0.6f] autorelease]];
            ActViewPhone.delegate = self;
            
            if (([[UIDevice currentDevice] orientation] == UIDeviceOrientationLandscapeLeft) ||
                ([[UIDevice currentDevice] orientation] == UIDeviceOrientationLandscapeRight))
            
            {
                ActViewPhone.view.frame = CGRectMake(0, 0, 640, 960);
                
            }
            else
            {
                ActViewPhone.view.frame = CGRectMake(0, 0, 960, 640);
            }
            
            [self.viewController.view addSubview:ActViewPhone.view];
        }
    }
    else{
        if(ActView == nil)
        {
            ActView = [[ActivityViewController alloc] init];
            [ActView.view setBackgroundColor:[[[UIColor alloc] initWithWhite:0.0f alpha:0.6f] autorelease]];
            ActView.delegate = self;
            
            if (([[UIDevice currentDevice] orientation] == UIDeviceOrientationLandscapeLeft) ||
                ([[UIDevice currentDevice] orientation] == UIDeviceOrientationLandscapeRight))
            
            {
                ActView.view.frame = CGRectMake(0, 0, 1024, 768);
                
            }
            else
            {
                ActView.view.frame = CGRectMake(0, 0, 768, 1024);
            }
            
            [self.viewController.view addSubview:ActView.view];
        }
    }
    
    
    /*
     NSString *tmp = [arguments objectAtIndex:0];
     NSMutableArray *mAr = [NSMutableArray arrayWithCapacity:arguments.count];
     
     if( [tmp rangeOfString:@"UpDownManagerPlugin"].location != NSNotFound )
     {
     for (int i = 1; i < arguments.count; i++) {
     //NSLog(@"object %d = %@", i, [arguments objectAtIndex:i]);
     [mAr insertObject: [ arguments objectAtIndex:i ] atIndex: i-1 ];
     }
     
     for (int i = 1; i < mAr.count; i++) {
     //NSLog(@"object %d = %@", i, [arguments objectAtIndex:i]);
     [arguments replaceObjectAtIndex:i withObject:[ mAr objectAtIndex:i ]];
     }
     }
     */
    
    appDelegate = [[CentralECMAppDelegate alloc]init];
    
    //쿠키 정보 셋팅
    if (appDelegate.m_arrCookieInfo != nil) {
        [appDelegate.m_arrDriveInfo removeAllObjects];
    }
    // Init
    appDelegate.m_arrCookieInfo = [[NSMutableArray alloc] init];
    
    //드라이브 정보 셋팅
    if ( appDelegate.m_arrDriveInfo != nil )
    [appDelegate.m_arrDriveInfo removeAllObjects];
    
    // Init
    appDelegate.m_arrDriveInfo = [[NSMutableArray alloc] init];
    
    
    NSArray *arrDiskType = [[command.arguments objectAtIndex:1] componentsSeparatedByString:@"\t"];
    NSArray *arrPartition = [[command.arguments objectAtIndex:3] componentsSeparatedByString:@"\t"];
    NSArray *arrStartPath = [[command.arguments objectAtIndex:10] componentsSeparatedByString:@"\t"];
    NSArray *arrOwner = [[command.arguments objectAtIndex:7] componentsSeparatedByString:@"\t"];
    NSArray *arrOption = [[command.arguments objectAtIndex:6] componentsSeparatedByString:@"\t"];
    //다운로드 파일 정보 셋팅
    for (int i= 0; i < arrDiskType.count; i++) {
        NICookieInfo *cookieinfo = [[NICookieInfo alloc] init];
        NIDriveInfo *info = [[NIDriveInfo alloc] init];
        
        // UseProxy
        cookieinfo->m_useProxy = [command.arguments objectAtIndex:23];
        
        // DomainID
        cookieinfo->m_strDomainID = [command.arguments objectAtIndex:0];
        
        //User
        cookieinfo->m_strUser = [command.arguments objectAtIndex:2];
        
        //RealIP
        cookieinfo->m_strRealIP = [Util getIPAddress];
        
        //Webserver
        cookieinfo->m_strWebServer = [command.arguments objectAtIndex:4];
        
        //Agent
        cookieinfo->m_strAgent = [command.arguments objectAtIndex:5];
        
        //Option
        cookieinfo->m_nOption = [cookieinfo getOption:[command.arguments objectAtIndex:6]];
        
        //Option
        if(arrOption.count-1 >= i) cookieinfo->m_strOption = [arrOption objectAtIndex:i];
        else cookieinfo->m_strOption = @"";
        
        //ShareUser
        cookieinfo->m_strShareUser = [command.arguments objectAtIndex:8];
        
        //SharePath
        cookieinfo->m_strSharePath  = [command.arguments objectAtIndex:9];
        
        //SiteID
        cookieinfo->m_strSiteID = [command.arguments objectAtIndex:17];
        
        
        
        
        
        // Owner (OrgCoworkID)
        info->m_strOwner = [arrOwner objectAtIndex:i];
        
        // OwnerType
        info->m_strOwnerType = [arrDiskType objectAtIndex:i];
        
        // FileServer
        info->m_strFileServer = [command.arguments objectAtIndex:13];
        
        //FileServer Port
        info->m_strFileServerPort = [command.arguments objectAtIndex:15];
        
        NSLog(@"fileserverport is %@", info->m_strFileServerPort);
        // Partition
        info->m_strPartition = [arrPartition objectAtIndex:i];
        
        // StartPath
        info->m_strStartPath = [arrStartPath objectAtIndex:i];
        
        // OrgCode
        info->m_strOrgCode = [command.arguments objectAtIndex:11];
        
        // DriveType
        info->m_nDiskType = [info getDiskType:[arrDiskType objectAtIndex:i]];
        
        // DriveType
        cookieinfo->m_strDiskType = [arrDiskType objectAtIndex:i];
        
        NSLog(@"disktype is %d", info->m_nDiskType);
        
        info->m_strOverwrite = [command.arguments objectAtIndex:21];
        //LocalCurrentPath
        info->m_strCurrentPath = [command.arguments objectAtIndex:20];
        
        NSString *useSSL = [command.arguments objectAtIndex:14];
        NSLog(@"uesSSL is %@", useSSL);
        
        if([useSSL isEqualToString:@"yes"]) info->m_strFileServerProtocol = @"https";
        else info->m_strFileServerProtocol = @"http";
        info->m_strFlag = [command.arguments objectAtIndex:16];
        NSLog(@"Flag is %@", info->m_strFlag);
        
        [appDelegate.m_arrDriveInfo addObject:info];
        [appDelegate.m_arrCookieInfo addObject:cookieinfo];
    }
    
    //NSString *Offeset = [arguments objectAtIndex:22];
    //NSLog(@"Offeset is %@", Offeset);
    
    appDelegate.sourceData = [[NSMutableArray alloc] init];
    
    NSString *Attribute = [command.arguments objectAtIndex:18];
    NSLog(@"Attribute is %@", Attribute);
    
    NSString *Size = [command.arguments objectAtIndex:19];
    NSLog(@"Size is %@", Size);
    
    NSString *Path = getPath;
    
    
    
//    AD.tmpFilePath = Path;
//
//    if(![AD.checkFile containsObject:Path]) {
//        AD.isOpened = NO;
//        [AD.checkFile addObject:Path];
//    } else {
//        AD.isOpened = YES;
//        NSLog(@"already exists file");
//    }
    
    
    NSArray *arrPathes = [Path componentsSeparatedByString:@"\t"];
    NSArray *arrAttributes = [Attribute componentsSeparatedByString:@"\t"];
    NSArray *Sizes = [Size componentsSeparatedByString:@"\t"];
    //다운로드 파일 정보 셋팅
    for (int i= 0; i < arrPathes.count; i++) {
        CFileInfo    * fileInfo = [[CFileInfo alloc] init];
        NSString    *lastPathComponent = [[arrPathes objectAtIndex:i] lastPathComponent];
        fileInfo.m_strName = [NSString stringWithString:lastPathComponent];
        fileInfo.m_dwAttrib =[[arrAttributes objectAtIndex:i] longLongValue];
        fileInfo.m_n64Size = [[Sizes objectAtIndex:i] integerValue];
        fileInfo.m_strPath = [arrPathes objectAtIndex:i];   //@
        
        [appDelegate.sourceData addObject: fileInfo];
        
        AD.tmpFilePath = [arrPathes objectAtIndex:i];
        
        if(![AD.checkFile containsObject:[arrPathes objectAtIndex:i]]) {
            AD.isOpened = NO;
            [AD.checkFile addObject:[arrPathes objectAtIndex:i]];
        } else {
            AD.isOpened = YES;
            NSLog(@"already exists file");
        }
    }
    appDelegate.sourceFolder = @"";
    
    NSString *tmpPath = [arrPathes objectAtIndex:0];
    appDelegate.sourceFolder = [appDelegate.sourceFolder  stringByAppendingPathComponent:[tmpPath substringToIndex:[tmpPath length]-[[tmpPath lastPathComponent] length]]];
    NSLog(@"sourceFolder is %@", appDelegate.sourceFolder);
    
    //    ReceiveDataViewController *receviedataviewcontroller = [[[ReceiveDataViewController alloc] init] autorelease];
    //    [receviedataviewcontroller DRiveInfo:info CookieInfo:cookieinfo dstpath:appDelegate.sourceFolder DownFlag:YES];
    
    NSString *retValue = nil;
    
    if( [[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPhone )
    {
        if ([[command.arguments objectAtIndex:16] isEqual:@"download"]) {
            DownLoadFiles *download = [[DownLoadFiles alloc] init];
            retValue = [download downloadFile_phone:appDelegate ActView:ActViewPhone];
        }
        else
        {
            ServerViewController *serverview = [[ServerViewController alloc] init];
            retValue = [serverview downFileOpen_phone:appDelegate ActView:ActViewPhone];
            
        }
        [ActViewPhone.view removeFromSuperview];
        [ActViewPhone release];
        [cont release];
        
        ActViewPhone = nil;
        cont = nil;
    }
    else{
        if ([[command.arguments objectAtIndex:16] isEqual:@"download"]) {
            DownLoadFiles *download = [[DownLoadFiles alloc] init];
            retValue = [download downloadFile:appDelegate ActView:ActView];
        }
        else
        {
            ServerViewController *serverview = [[ServerViewController alloc] init];
            retValue = [serverview downFileOpen:appDelegate ActView:ActView];
            
        }
        [ActView.view removeFromSuperview];
        [ActView release];
        [cont release];
        
        ActView = nil;
        cont = nil;
    }
    
    NSMutableString *stringToReturn = [NSMutableString stringWithString:retValue];
    
    //CDVPluginResult* pluginResult = [pluginResult resultWithStatus:CDVCommandStatus_OK messageAsString:[stringToReturn stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding]];
    CDVPluginResult* pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK messageAsString:stringToReturn];
    //    [self writeJavascript:[pluginResult toSuccessCallbackString:self.callbackID]];
    [self.commandDelegate sendPluginResult:pluginResult callbackId:command.callbackId];
    
}
- (void) upload:(CDVInvokedUrlCommand*)command{
    //self.callbackID = [arguments pop];
    //    self.callbackID = [arguments objectAtIndex:0];
    self.callbackID = self.callbackID;
    appDelegate = [[CentralECMAppDelegate alloc]init];
    
    
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
            [self.viewController.view addSubview:ActViewPhone.view];
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
            [self.viewController.view addSubview:ActView.view];
        }
        
    }
    
    
    //쿠키 정보 셋팅
    if (appDelegate.m_arrCookieInfo != nil) {
        [appDelegate.m_arrDriveInfo removeAllObjects];
    }
    // Init
    appDelegate.m_arrCookieInfo = [[NSMutableArray alloc] init];
    NICookieInfo *cookieinfo = [[NICookieInfo alloc] init];
    
    // UseProxy
    //    cookieinfo->m_useProxy = [command.arguments objectAtIndex:20];
    
    // DomainID
    cookieinfo->m_strDomainID = [command.arguments objectAtIndex:0];
    
    //User
    cookieinfo->m_strUser = [command.arguments objectAtIndex:2];
    
    //RealIP
    cookieinfo->m_strRealIP = [Util getIPAddress];
    
    //Webserver
    cookieinfo->m_strWebServer = [command.arguments objectAtIndex:4];
    
    //Agent
    cookieinfo->m_strAgent = [command.arguments objectAtIndex:5];
    
    //Option
    cookieinfo->m_nOption = [cookieinfo getOption:[command.arguments objectAtIndex:6]];
    
    //str_Option
    cookieinfo->m_strOption = [command.arguments objectAtIndex:6];
    
    //ShareUser
    cookieinfo->m_strShareUser = [command.arguments objectAtIndex:8];
    
    //SharePath
    cookieinfo->m_strSharePath  = [command.arguments objectAtIndex:9];
    
    //SiteID
    cookieinfo->m_strSiteID = [command.arguments objectAtIndex:16];
    
    [appDelegate.m_arrCookieInfo addObject:cookieinfo];
    
    //드라이브 정보 셋팅
    if ( appDelegate.m_arrDriveInfo != nil )
    [appDelegate.m_arrDriveInfo removeAllObjects];
    
    // Init
    appDelegate.m_arrDriveInfo = [[NSMutableArray alloc] init];
    NIDriveInfo *info = [[NIDriveInfo alloc] init];
    
    // Owner (OrgCoworkID)
    info->m_strOwner = [command.arguments objectAtIndex:7];
    
    // OwnerType(Disktype)
    info->m_strOwnerType = [command.arguments objectAtIndex:1];
    
    // str_OwnerType(Disktype)
    cookieinfo->m_strDiskType = [command.arguments objectAtIndex:1];
    
    // FileServer
    info->m_strFileServer = [command.arguments objectAtIndex:13];
    
    //FileServer Port
    info->m_strFileServerPort = [command.arguments objectAtIndex:15];
    
    // Partition
    info->m_strPartition = [command.arguments objectAtIndex:3];
    
    // StartPath
    info->m_strStartPath = [command.arguments objectAtIndex:10];
    
    // OrgCode
    info->m_strOrgCode = [command.arguments objectAtIndex:11];
    
    // DriveType
    info->m_nDiskType = [info getDiskType:[command.arguments objectAtIndex:1]];
    
    // DriveType
    cookieinfo->m_strDiskType = [command.arguments objectAtIndex:1];
    
    //LocalCurrentPath
    info->m_strCurrentPath = [command.arguments objectAtIndex:12];
    [appDelegate.m_arrDriveInfo addObject:info];
    
    NSString *useSSL = [command.arguments objectAtIndex:14];
    NSLog(@"uesSSL is %@", useSSL);
    
    if([useSSL isEqualToString:@"yes"]) info->m_strFileServerProtocol = @"https";
    else info->m_strFileServerProtocol = @"http";
    
    NSString *OverWrite = [command.arguments objectAtIndex:18];
    NSLog(@"OverWrite is %@", OverWrite);
    
    NSString *Offeset = [command.arguments objectAtIndex:19];
    NSLog(@"Offeset is %@", Offeset);
    
    appDelegate.sourceData = [[NSMutableArray alloc] init];
    
    NSString *Path = [command.arguments objectAtIndex:17];
    
    Path = [Path stringByReplacingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
    
    NSLog(@"path is %@", Path);
    
    
    
    /*
     NSString *fullPath = [command.arguments objectAtIndex:21];
     
     NSFileManager *fileManager;
     NSDirectoryEnumerator *directoryEnum;
     NSString* str;
     
     fileManager = [NSFileManager defaultManager];
     
     [fileManager changeCurrentDirectoryPath:fullPath];
     directoryEnum = [fileManager enumeratorAtPath:
     [fileManager currentDirectoryPath]];
     
     while ((str = [directoryEnum nextObject]) != nil) {
     NSDictionary *dic = [fileManager fileAttributesAtPath: str
     traverseLink: NO];
     
     NSLog(@"%@: %@, %@byte, %@", str,
     [dic objectForKey: NSFileType],
     [dic objectForKey: NSFileSize],
     [dic objectForKey: NSFileOwnerAccountName]);
     }
     */
    
    
    
    NSArray *arrPathes = [Path componentsSeparatedByString:@"\t"];
    //업로드 파일 정보 셋팅
    for (int i= 0; i < arrPathes.count; i++) {
        CFileInfo	* fileInfo = [[CFileInfo alloc] init];
        NSString    *lastPathComponent = [[arrPathes objectAtIndex:i] lastPathComponent];
        fileInfo.m_strName = [NSString stringWithString:lastPathComponent];
        
        [appDelegate.sourceData addObject: fileInfo];
    }
    appDelegate.sourceFolder = @"";
    
    NSString *tmpPath = [arrPathes objectAtIndex:0];
    appDelegate.sourceFolder = [appDelegate.sourceFolder  stringByAppendingPathComponent:[tmpPath substringToIndex:[tmpPath length]-[[tmpPath lastPathComponent] length]-1]];
    NSLog(@"sourceFolder is %@", appDelegate.sourceFolder);
    
    UploadFiles *upload = [[UploadFiles alloc] init];
    //    NSString *retValue = [upload UploadFiles:appDelegate];
    NSString *retValue = @"";
    
    if( [[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPhone )
    {
        retValue = [upload UploadFiles_phone:appDelegate ActView:ActViewPhone];
        [ActViewPhone.view removeFromSuperview];
        [ActViewPhone release];
        [cont release];
        
        ActViewPhone = nil;
        cont = nil;
        
    }
    else{
        retValue = [upload UploadFiles:appDelegate ActView:ActView];
        [ActView.view removeFromSuperview];
        [ActView release];
        [cont release];
        
        ActView = nil;
        cont = nil;
        
        
    }
    
    NSMutableString *stringToReturn = [NSMutableString stringWithString:retValue];
    
    //CDVPluginResult* pluginResult = [pluginResult resultWithStatus:CDVCommandStatus_OK messageAsString:[stringToReturn stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding]];
    CDVPluginResult* pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK messageAsString:stringToReturn];
    //    [self writeJavascript:[pluginResult toSuccessCallbackString:self.callbackID]];
    //    [self.commandDelegate sendPluginResult:pluginResult callbackId:command.callbackId];
    [self.commandDelegate sendPluginResult:pluginResult callbackId:command.callbackId];
}
    
- (void) setcookie:(CDVInvokedUrlCommand*)command{
    //self.callbackID = [arguments pop];
    //    self.callbackID = [arguments objectAtIndex:0];
    self.callbackID = self.callbackID;
    appDelegate = [[CentralECMAppDelegate alloc]init];
    
    //쿠키 정보 셋팅
    if (appDelegate.m_arrCookieInfo != nil) {
        [appDelegate.m_arrDriveInfo removeAllObjects];
    }
    // Init
    appDelegate.m_arrCookieInfo = [[NSMutableArray alloc] init];
    NICookieInfo *cookieinfo = [[NICookieInfo alloc] init];
    
    // DomainID
    cookieinfo->m_strDomainID = [command.arguments objectAtIndex:0];
    
    //User
    cookieinfo->m_strUser = [command.arguments objectAtIndex:2];
    
    //RealIP
    cookieinfo->m_strRealIP = [Util getIPAddress];
    
    //Webserver
    cookieinfo->m_strWebServer = [command.arguments objectAtIndex:4];
    
    //Agent
    cookieinfo->m_strAgent = [command.arguments objectAtIndex:5];
    
    //Option
    cookieinfo->m_nOption = [cookieinfo getOption:[command.arguments objectAtIndex:6]];
    
    //ShareUser
    cookieinfo->m_strShareUser = [command.arguments objectAtIndex:8];
    
    //SharePath
    cookieinfo->m_strSharePath  = [command.arguments objectAtIndex:9];
    
    //SiteID
    cookieinfo->m_strSiteID = [command.arguments objectAtIndex:16];
    
    [appDelegate.m_arrCookieInfo addObject:cookieinfo];
    
    //드라이브 정보 셋팅
    if ( appDelegate.m_arrDriveInfo != nil )
    [appDelegate.m_arrDriveInfo removeAllObjects];
    
    // Init
    appDelegate.m_arrDriveInfo = [[NSMutableArray alloc] init];
    NIDriveInfo *info = [[NIDriveInfo alloc] init];
    
    // Owner (OrgCoworkID)
    info->m_strOwner = [command.arguments objectAtIndex:7];
    
    // OwnerType(Disktype)
    info->m_strOwnerType = [command.arguments objectAtIndex:1];
    
    // FileServer
    info->m_strFileServer = [command.arguments objectAtIndex:13];
    
    //FileServer Port
    info->m_strFileServerPort = [command.arguments objectAtIndex:15];
    
    // Partition
    info->m_strPartition = [command.arguments objectAtIndex:3];
    
    // StartPath
    info->m_strStartPath = [command.arguments objectAtIndex:10];
    
    // OrgCode
    info->m_strOrgCode = [command.arguments objectAtIndex:11];
    
    // DriveType
    info->m_nDiskType = [info getDiskType:[command.arguments objectAtIndex:1]];
    
    //LocalCurrentPath
    info->m_strCurrentPath = [command.arguments objectAtIndex:12];
    [appDelegate.m_arrDriveInfo addObject:info];
    
    NSString *useSSL = [command.arguments objectAtIndex:14];
    NSLog(@"uesSSL is %@", useSSL);
    
    if([useSSL isEqualToString:@"yes"]) info->m_strFileServerProtocol = @"https";
    else info->m_strFileServerProtocol = @"http";
    
    NSString *OverWrite = [command.arguments objectAtIndex:18];
    NSLog(@"OverWrite is %@", OverWrite);
    
    NSString *Offeset = [command.arguments objectAtIndex:19];
    NSLog(@"Offeset is %@", Offeset);
    
    appDelegate.sourceData = [[NSMutableArray alloc] init];
    
    NSString *Path = [command.arguments objectAtIndex:17];
    
    NSLog(@"path is %@", Path);
    
    NSArray *arrPathes = [Path componentsSeparatedByString:@"\t"];
    //업로드 파일 정보 셋팅
    for (int i= 0; i < arrPathes.count; i++) {
        CFileInfo	* fileInfo = [[CFileInfo alloc] init];
        NSString    *lastPathComponent = [[arrPathes objectAtIndex:i] lastPathComponent];
        fileInfo.m_strName = [NSString stringWithString:lastPathComponent];
        
        [appDelegate.sourceData addObject: fileInfo];
    }
    appDelegate.sourceFolder = @"";
    
    NSString *tmpPath = [arrPathes objectAtIndex:0];
    appDelegate.sourceFolder = [appDelegate.sourceFolder  stringByAppendingPathComponent:[tmpPath substringToIndex:[tmpPath length]-[[tmpPath lastPathComponent] length]]];
    NSLog(@"sourceFolder is %@", appDelegate.sourceFolder);
    ReceiveDataViewController *receviedataviewcontroller = [[[ReceiveDataViewController alloc] init] autorelease];
    //[receviedataviewcontroller setCookie:appDelegate];
    
    //[receviedataviewcontroller DriveInfo:appDelegate.m_arrDriveInfo CookieInfo:appDelegate.m_arrCookieInfo];
    
    [receviedataviewcontroller DRiveInfo:info CookieInfo:cookieinfo dstpath:appDelegate.sourceFolder DownFlag:NO];
    
    //UploadFiles *upload = [[UploadFiles alloc] init];
    //    NSString *retValue = [upload UploadFiles:appDelegate];
    NSString *retValue = @"";
    
    NSMutableString *stringToReturn = [NSMutableString stringWithString:retValue];
    
    //CDVPluginResult* pluginResult = [pluginResult resultWithStatus:CDVCommandStatus_OK messageAsString:[stringToReturn stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding]];
    CDVPluginResult* pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK messageAsString:stringToReturn];
    //    [self writeJavascript:[pluginResult toSuccessCallbackString:self.callbackID]];
    [self.commandDelegate sendPluginResult:pluginResult callbackId:command.callbackId];
}
    
    
- (void)dealloc {
    [super dealloc];
}
    @end
