//
//  DownLoadFiles.m
//  CECMPad
//
//  Created by 넷아이디 on 12. 1. 18..
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "DownLoadFiles.h"
#import "ClientViewController.h"
#import "NIInterfaceUtil.h"
#import "ServerCmd.h"
#import "Util.h"
#import	"FileUtil.h"
//FileUtil				*g_FileUtil;
@implementation DownLoadFiles

// 파일 다운로드 후 결과 처리
- (void) didFinishGetFile: (NSString *) errmsg 
				 filePath: (NSString *) filePath
{
    NSLog(@"didFinishGetFile");
	if (errmsg)
	{
		UIAlertView	*av = [[[UIAlertView alloc] initWithTitle:nil message:NSLocalizedString(errmsg, nil) delegate:nil cancelButtonTitle:NSLocalizedString(@"OK",nil) otherButtonTitles:nil] autorelease];
		[av show];
		m_bError = YES;
	}
	else
	{
 		NSLog(@"didFinishGetFile: filePath is %@", filePath);
	}
	
	m_bFinished = YES;
}


// 다운로드시 서버 폴더내에 있는 파일 목록을 얻는다.
- (void) didFinishGetList: (NSString *) errmsg 
			fileInfoArray: (NSMutableArray *) fileInfoArray
{
	if (errmsg)
	{
		UIAlertView	*av = [[[UIAlertView alloc] initWithTitle:nil message:NSLocalizedString(errmsg, nil) delegate:nil cancelButtonTitle:NSLocalizedString(@"Confirm",nil) otherButtonTitles:nil] autorelease];
		[av show];
		m_bError = YES;
	}
	else
	{
		// 폴더는 만들고 파일만 리스트에 추가한다.
		for (int i=0; i<[fileInfoArray count]; i++)
		{
			CFileInfo *fileInfo = [fileInfoArray objectAtIndex:i];
			
			fileInfo.m_strName = [NSString stringWithFormat:@"%@/%@", m_folderName, fileInfo.m_strName];
			
			// 폴더는 만든다.
			if (fileInfo.m_dwAttrib & FA_FOLDER)
			{
				NSLog(@"didFinishGetList:folder:%@", fileInfo.m_strName);
				
				NSString *tmpFolder = [NSString stringWithFormat:@"%@/xxx/%@", [g_FileUtil getTmpFolder], fileInfo.m_strName];
				
				NSLog(@"didFinishGetList:tmpFolder:%@", tmpFolder);
				
				NSFileManager *fileMgr = [NSFileManager defaultManager];
				[fileMgr createDirectoryAtPath:tmpFolder withIntermediateDirectories:YES attributes:nil error:nil];
			}
			else
			{
				NSLog(@"didFinishGetList:file:%@", fileInfo.m_strName);
				[appDelegate.sourceData addObject:fileInfo];
			}
		}
		
		[fileInfoArray release];
	}
	
	m_bFinished = YES;
}

- (NSString *) downloadFile: (CentralECMAppDelegate *) g_appDelegate 
                    ActView: (ActivityViewController *) ActViewCtl{
    
    NSLog(@"downloadfile");
    appDelegate = [[CentralECMAppDelegate alloc]init];
    appDelegate = g_appDelegate;
    NSString *tmpRetValue;
    FileUtil *fileUtil = [[FileUtil alloc] init];
    NSString *tmpFolder = [NSString stringWithFormat:@"%@/xxx", [fileUtil getTmpFolder]];
    NSFileManager *fileMgr = [NSFileManager defaultManager];
    [fileMgr removeItemAtPath:tmpFolder error:nil];
    [fileMgr createDirectoryAtPath:tmpFolder withIntermediateDirectories:YES attributes:nil error:nil];
    
    int i = 0;
	NSString *fileName;
	NSString *filePath;
    
    BOOL allYes = NO;
    int g_nSourceDrive = 0;
    
    m_bError = NO;
    ServerCmd	*serverCmd = [[ServerCmd alloc] init];
    
    ClientViewController *clientcontroller = [[ClientViewController alloc] init];
    NIDriveInfo *info = [appDelegate.m_arrDriveInfo objectAtIndex:g_nSourceDrive];
    NICookieInfo *cookieinfo = [appDelegate.m_arrCookieInfo objectAtIndex:g_nSourceDrive];
    NSString *currentfolder = info->m_strCurrentPath;
    if( [currentfolder isEqualToString:@"/Documents/ECM/data"] ){
        NSString * tmpLocalRootPath = [NSString stringWithFormat:[g_FileUtil getDocumentFolder]];
        currentfolder = [tmpLocalRootPath stringByAppendingFormat:currentfolder];
    }
    
    
    NSMutableArray *sourceData = [[NSMutableArray alloc] initWithArray:appDelegate.sourceData];
    [appDelegate.sourceData removeAllObjects];
    
    for (i=0; i<sourceData.count; i++)
    {
        CFileInfo	*fileInfo = (CFileInfo *)[sourceData objectAtIndex:i];
        
        // 폴더의 경우 .tmp폴더에 폴더를 만들고 파일 리스트로 만든다.
        if (fileInfo.m_dwAttrib & FA_FOLDER)
        {
            // 공유 폴더이면 공유 폴더 관련 변수를 셋팅한다.
            filePath = [NSString stringWithFormat:@"%@/xxx/%@", [fileUtil getTmpFolder], fileInfo.m_strName];
            m_folderName = fileInfo.m_strName;
            
            NSFileManager *fileMgr = [NSFileManager defaultManager];
            [fileMgr createDirectoryAtPath:filePath withIntermediateDirectories:YES attributes:nil error:nil];
            
            m_bFinished = NO;
            //            if ( info->m_nDiskType == DT_SHARE)
            //                [serverCmd GetList: g_nSourceDrive 
            //                        folderName: [appDelegate.sourceFolder stringByAppendingPathComponent:fileInfo.m_strName] 
            //                          fileInfo: [ShareFolderList objectAtIndex:controller.m_nShareFolder] 
            //                         sharePath: controller.m_sharePath 
            //                         recursive: YES 
            //                            sender: self 
            //                          selector: @selector(didFinishGetList:fileInfoArray:)];
            //            else
            [serverCmd GetList: g_nSourceDrive 
                    folderName: [appDelegate.sourceFolder stringByAppendingPathComponent:fileInfo.m_strName] 
                      fileInfo: nil 
                     sharePath: cookieinfo->m_strSharePath 
                     recursive: YES 
                        sender: self 
                      selector: @selector(didFinishGetList:fileInfoArray:)
                 g_appDelegate: appDelegate];
            
            
            while (!m_bFinished)
                [[NSRunLoop currentRunLoop] runMode:NSDefaultRunLoopMode beforeDate:[NSDate distantFuture]];
            
            // HTTP Request cancel
            if (m_bCancel)
                break;
        }
        else
            [appDelegate.sourceData addObject:fileInfo];
    }
    
    for (i=0; i<appDelegate.sourceData.count; i++)
    {
        CFileInfo	*fileInfo = (CFileInfo *)[appDelegate.sourceData objectAtIndex:i];
        fileName = fileInfo.m_strName;
        
        NSString *tmpDir = @"xxx";
        NSString *lastPathComponent = [fileName lastPathComponent];
        
        if (![lastPathComponent isEqualToString: fileName])
        {
            tmpDir = [tmpDir stringByAppendingPathComponent:[fileName substringToIndex:[fileName length]-[lastPathComponent length]]];
        }
        
        filePath = [appDelegate.sourceFolder stringByAppendingPathComponent:fileName];
        //        filePath = fileInfo.m_strName;
        NSLog(@"before tmpDir:%@,GetFile:%@", tmpDir, filePath);
        
        int index = -1;
        
        if (allYes == YES 
            || [clientcontroller fileExistsAtPath:fileName] == NO 
           // || (index = [appDelegate checkOverwrite:fileName allYes:YES]) > -1) 
            || [info->m_strOverwrite isEqual:@"yes"])
        {
            if (index == 3)
                break;
            else if (index == 2)
                continue;
            else if (index == 1)
                allYes = YES;
            
            m_bFinished = NO;
            [serverCmd GetFile: g_nSourceDrive 
                        tmpDir: tmpDir 
                       srcName: filePath 
                      fileInfo: fileInfo
                     sharePath: cookieinfo->m_strSharePath
                          view: nil
                         order: (i+1) 
                     totalfile: appDelegate.sourceData.count
                        sender: self 
                      selector: @selector(didFinishGetFile:filePath:)
                 g_appDelegate: appDelegate
                       ActView:ActViewCtl];
            
            
            while (!m_bFinished && !m_bCancel)
                [[NSRunLoop currentRunLoop] runMode:NSDefaultRunLoopMode beforeDate:[NSDate distantFuture]];
            
            // HTTP Request cancel
            if (m_bCancel)
                break;
        }
    }
    
    m_addCount = 0;
    
    for (i=0; i<sourceData.count; i++)
    {
        CFileInfo *fileInfo = [sourceData objectAtIndex:i];
        
        filePath = [NSString stringWithFormat:@"%@/xxx/%@", [fileUtil getTmpFolder], fileInfo.m_strName];
        NSLog(@"currentfolder is %@", currentfolder);
        NSString *dstPath = [currentfolder stringByAppendingPathComponent:fileInfo.m_strName];
        NSLog(@"onPaste:filePath:%@,dstPath:%@", filePath, dstPath);
        
        // 파일이 있으면 m_fileInfoArray에서 삭제한다.
        if ([fileUtil isExist:dstPath])
        {
            for (int i=0; i<[sourceData count]; i++)
            {
                CFileInfo	*fileInfo = [sourceData objectAtIndex:i];
                
                //                if ([fileInfo.m_strName isEqualToString:[dstPath lastPathComponent]])
                //                    [clientcontroller removeItem:i];
            }
        }
        
        // .tmp/xxx 폴더 아래 있는 파일을 currentFolder로 이동한다.
        if ([fileUtil moveFile:filePath dstPath:dstPath])
        {
            CFileInfo	*fileInfo = [fileUtil getFileInfo:dstPath];
            [clientcontroller addToCellData:fileInfo];
            m_addCount++;
            
            // cut이면 서버에 있는 파일을 삭제한다.
            if (!m_bError && appDelegate.pasteStatus == CUT)
            {
                ServerViewController *controller = (ServerViewController *)appDelegate.sourceServerViewController;
                
                NSString *fileName = [appDelegate.sourceFolder stringByAppendingPathComponent:[dstPath lastPathComponent]];
                
                m_bFinished = NO;
                
                ServerCmd	*serverCmd = [[ServerCmd alloc] init];
                [serverCmd DeleteFile:g_nSourceDrive fileName:fileName fileInfo:[controller getShareFolder] sharePath:[controller getSharePath] sender:self selector:@selector(didFinishDeleteFile:filePath:)];
                
                while (!m_bFinished)
                    [[NSRunLoop currentRunLoop] runMode:NSDefaultRunLoopMode beforeDate:[NSDate distantFuture]];
            }
            tmpRetValue = @"complete";
        }
    }
    
    m_bGetFile = FALSE;
    appDelegate.m_bClientTab = TRUE;
    return tmpRetValue;
    
}

- (NSString *) downloadFile_phone:(CentralECMAppDelegate *)g_appDelegate ActView:(ActivityViewController_phone *)ActViewCtl{
    
    appDelegate = [[CentralECMAppDelegate alloc]init];
    appDelegate = g_appDelegate;
    NSString *tmpRetValue;
    FileUtil *fileUtil = [[FileUtil alloc] init];
    NSString *tmpFolder = [NSString stringWithFormat:@"%@/xxx", [fileUtil getTmpFolder]];
    NSFileManager *fileMgr = [NSFileManager defaultManager];
    [fileMgr removeItemAtPath:tmpFolder error:nil];
    [fileMgr createDirectoryAtPath:tmpFolder withIntermediateDirectories:YES attributes:nil error:nil];
    
    int i = 0;
	NSString *fileName;
	NSString *filePath;
    
    BOOL allYes = NO;
    int g_nSourceDrive = 0;
    
    m_bError = NO;
    ServerCmd	*serverCmd = [[ServerCmd alloc] init];
    
    ClientViewController *clientcontroller = [[ClientViewController alloc] init];
    NIDriveInfo *info = [appDelegate.m_arrDriveInfo objectAtIndex:g_nSourceDrive];
    NICookieInfo *cookieinfo = [appDelegate.m_arrCookieInfo objectAtIndex:g_nSourceDrive];
    NSString *currentfolder = info->m_strCurrentPath;
    
    if( [currentfolder isEqualToString:@"/Documents/ECM/data"] ){
        NSString * tmpLocalRootPath = [NSString stringWithFormat:[g_FileUtil getDocumentFolder]];
        currentfolder = [tmpLocalRootPath stringByAppendingFormat:currentfolder];
    }
    
    NSMutableArray *sourceData = [[NSMutableArray alloc] initWithArray:appDelegate.sourceData];
    [appDelegate.sourceData removeAllObjects];
    
    for (i=0; i<sourceData.count; i++)
    {
        CFileInfo	*fileInfo = (CFileInfo *)[sourceData objectAtIndex:i];
        
        // 폴더의 경우 .tmp폴더에 폴더를 만들고 파일 리스트로 만든다.
        if (fileInfo.m_dwAttrib & FA_FOLDER)
        {
            // 공유 폴더이면 공유 폴더 관련 변수를 셋팅한다.
            filePath = [NSString stringWithFormat:@"%@/xxx/%@", [fileUtil getTmpFolder], fileInfo.m_strName];
            m_folderName = fileInfo.m_strName;
            
            NSFileManager *fileMgr = [NSFileManager defaultManager];
            [fileMgr createDirectoryAtPath:filePath withIntermediateDirectories:YES attributes:nil error:nil];
            
            m_bFinished = NO;
            //            if ( info->m_nDiskType == DT_SHARE)
            //                [serverCmd GetList: g_nSourceDrive
            //                        folderName: [appDelegate.sourceFolder stringByAppendingPathComponent:fileInfo.m_strName]
            //                          fileInfo: [ShareFolderList objectAtIndex:controller.m_nShareFolder]
            //                         sharePath: controller.m_sharePath
            //                         recursive: YES
            //                            sender: self
            //                          selector: @selector(didFinishGetList:fileInfoArray:)];
            //            else
            [serverCmd GetList: g_nSourceDrive
                    folderName: [appDelegate.sourceFolder stringByAppendingPathComponent:fileInfo.m_strName]
                      fileInfo: nil
                     sharePath: cookieinfo->m_strSharePath
                     recursive: YES
                        sender: self
                      selector: @selector(didFinishGetList:fileInfoArray:)
                 g_appDelegate: appDelegate];
            
            
            while (!m_bFinished)
                [[NSRunLoop currentRunLoop] runMode:NSDefaultRunLoopMode beforeDate:[NSDate distantFuture]];
            
            // HTTP Request cancel
            if (m_bCancel)
                break;
        }
        else
            [appDelegate.sourceData addObject:fileInfo];
    }
    
    for (i=0; i<appDelegate.sourceData.count; i++)
    {
        CFileInfo	*fileInfo = (CFileInfo *)[appDelegate.sourceData objectAtIndex:i];
        fileName = fileInfo.m_strName;
        
        NSString *tmpDir = @"xxx";
        NSString *lastPathComponent = [fileName lastPathComponent];
        
        if (![lastPathComponent isEqualToString: fileName])
        {
            tmpDir = [tmpDir stringByAppendingPathComponent:[fileName substringToIndex:[fileName length]-[lastPathComponent length]]];
        }
        
        filePath = [appDelegate.sourceFolder stringByAppendingPathComponent:fileName];
        //        filePath = fileInfo.m_strName;
        NSLog(@"before tmpDir:%@,GetFile:%@", tmpDir, filePath);
        
        int index = -1;
        
        if (allYes == YES
            || [clientcontroller fileExistsAtPath:fileName] == NO
            // || (index = [appDelegate checkOverwrite:fileName allYes:YES]) > -1)
            || [info->m_strOverwrite isEqual:@"yes"])
        {
            if (index == 3)
                break;
            else if (index == 2)
                continue;
            else if (index == 1)
                allYes = YES;
            
            m_bFinished = NO;
            [serverCmd GetFile: g_nSourceDrive
                        tmpDir: tmpDir
                       srcName: filePath
                      fileInfo: fileInfo
                     sharePath: cookieinfo->m_strSharePath
                          view: nil
                         order: (i+1)
                     totalfile: appDelegate.sourceData.count
                        sender: self
                      selector: @selector(didFinishGetFile:filePath:)
                 g_appDelegate: appDelegate
                       ActView:ActViewCtl];
            
            
            while (!m_bFinished && !m_bCancel)
                [[NSRunLoop currentRunLoop] runMode:NSDefaultRunLoopMode beforeDate:[NSDate distantFuture]];
            
            // HTTP Request cancel
            if (m_bCancel)
                break;
        }
    }
    
    m_addCount = 0;
    
    for (i=0; i<sourceData.count; i++)
    {
        CFileInfo *fileInfo = [sourceData objectAtIndex:i];
        
        filePath = [NSString stringWithFormat:@"%@/xxx/%@", [fileUtil getTmpFolder], fileInfo.m_strName];
        NSString *dstPath = [currentfolder stringByAppendingPathComponent:fileInfo.m_strName];
        NSLog(@"currentfolder is %@", currentfolder);
        NSLog(@"onPaste:filePath:%@,dstPath:%@", filePath, dstPath);
        
        // 파일이 있으면 m_fileInfoArray에서 삭제한다.
        if ([fileUtil isExist:dstPath])
        {
            for (int i=0; i<[sourceData count]; i++)
            {
                CFileInfo	*fileInfo = [sourceData objectAtIndex:i];
                
                //                if ([fileInfo.m_strName isEqualToString:[dstPath lastPathComponent]])
                //                    [clientcontroller removeItem:i];
            }
        }
        
        // .tmp/xxx 폴더 아래 있는 파일을 currentFolder로 이동한다.
        if ([fileUtil moveFile:filePath dstPath:dstPath])
        {
            CFileInfo	*fileInfo = [fileUtil getFileInfo:dstPath];
            [clientcontroller addToCellData:fileInfo];
            m_addCount++;
            
            // cut이면 서버에 있는 파일을 삭제한다.
            if (!m_bError && appDelegate.pasteStatus == CUT)
            {
                ServerViewController *controller = (ServerViewController *)appDelegate.sourceServerViewController;
                
                NSString *fileName = [appDelegate.sourceFolder stringByAppendingPathComponent:[dstPath lastPathComponent]];
                
                m_bFinished = NO;
                
                ServerCmd	*serverCmd = [[ServerCmd alloc] init];
                [serverCmd DeleteFile:g_nSourceDrive fileName:fileName fileInfo:[controller getShareFolder] sharePath:[controller getSharePath] sender:self selector:@selector(didFinishDeleteFile:filePath:)];
                
                while (!m_bFinished)
                    [[NSRunLoop currentRunLoop] runMode:NSDefaultRunLoopMode beforeDate:[NSDate distantFuture]];
            }
            tmpRetValue = @"complete";
        }
    }
    
    m_bGetFile = FALSE;
    appDelegate.m_bClientTab = TRUE;
    return tmpRetValue;
    
}

-(void) cancel
{
	UIAlertView	*av = [[[UIAlertView alloc] initWithTitle:nil message:NSLocalizedString(@"다운로드를 실패했습니다.", nil) delegate:nil cancelButtonTitle:NSLocalizedString(@"OK",nil) otherButtonTitles:nil] autorelease];
	[av show];
	
	//[table deselectRowAtIndexPath:m_selectedIndexPath animated:YES];
    
	m_bCancel = TRUE;
	m_bGetFile = FALSE;
//	g_appDelegate.m_bServerTab = TRUE;
}

- (void)dealloc {
    [super dealloc];
}
@end
