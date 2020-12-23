//
//  UploadFiles.m
//  CECMPad
//
//  Created by 넷아이디 on 12. 1. 18..
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "UploadFiles.h"
#import "NIInterfaceUtil.h"
#import "ServerCmd.h"
#import "Util.h"
#import	"FileUtil.h"

//#import "PhotoViewController.h"
//#import "WebThree20ViewController.h"
BOOL		g_bFileOpEnd;
// 현재 복사/이동 중인 파일 정보
CFileInfo	*g_fileInfo;
int         m_nSelectedDrive = 0;
@implementation UploadFiles

- (NSString *)   UploadFiles: (CentralECMAppDelegate *) g_appDelegate
                     ActView: (ActivityViewController *) ActViewCtl{
    m_bGetFile = TRUE;
    
	NSString	*fileName;
	NSString	*srcPath;
	NSString    *retVal = @"complete";
	g_bFileOpEnd = FALSE;
    BOOL	allYes = NO;
	BOOL	b3G = NO;
	m_bCancel = NO;
	m_bError = NO;
    int g_nSourceDrive = 0;

    ServerCmd	*serverCmd = [[ServerCmd alloc] init];
    FileUtil *fileUtil = [[FileUtil alloc] init];
    // client to server의 경우 폴더를 파일 리스트로 바꾼다.
    NSMutableArray *sourceData = [[NSMutableArray alloc] initWithArray:g_appDelegate.sourceData];
    [g_appDelegate.sourceData removeAllObjects];
    NSFileManager *fileMgr = [NSFileManager defaultManager];
    NSString *filename;
		
    NIDriveInfo *info = [g_appDelegate.m_arrDriveInfo objectAtIndex:g_nSourceDrive];
    NICookieInfo *cookieinfo = [g_appDelegate.m_arrCookieInfo objectAtIndex:g_nSourceDrive];
    NSString *currentFolder = info->m_strCurrentPath;

    for (int i=0; i<sourceData.count; i++)
    {
        CFileInfo *fileInfo = (CFileInfo *)[sourceData objectAtIndex:i];
			
        srcPath = [g_appDelegate.sourceFolder stringByAppendingPathComponent:fileInfo.m_strName];
		NSLog(@"srcPath is %@", srcPath);
        
        if ([fileUtil isFolder: srcPath])
        {
            NSDirectoryEnumerator *dirEnum = [fileMgr enumeratorAtPath:srcPath];
            int	cnt = 0;
                
            while ((filename = [dirEnum nextObject]) != nil)
            {
                filename = [fileUtil getFilename:filename];
                NSString *filePath = [NSString stringWithFormat:@"%@/%@", [srcPath lastPathComponent], filename];
                NSLog(@"onPaste:%@", filePath);
                CFileInfo *fileInfo2 = [CFileInfo alloc];
                fileInfo2.m_strName = [NSString stringWithString:filePath];
                [g_appDelegate.sourceData addObject:fileInfo2];
                cnt++;
            }
				
            // 폴더안에 파일이 없는 경우
            if (cnt == 0)
            {
                NSLog(@"onPaste:%@", [srcPath lastPathComponent]);
                CFileInfo *fileInfo2 = [CFileInfo alloc];
                fileInfo2.m_strName = [NSString stringWithString:[srcPath lastPathComponent]];
                [g_appDelegate.sourceData addObject:fileInfo2];
            }
        }
        else
        {
            CFileInfo *fileInfo2 = [CFileInfo alloc];
            fileInfo2.m_strName = [NSString stringWithString:fileInfo.m_strName];
            [g_appDelegate.sourceData addObject:fileInfo2];
        }
    }
    
    [sourceData release];
	
    
	//[m_folderInfoArray removeAllObjects];
    
    for (int i=0; i<g_appDelegate.sourceData.count; i++)
	{
		g_fileInfo = (CFileInfo *)[g_appDelegate.sourceData objectAtIndex:i];
		fileName = g_fileInfo.m_strName;
        
		srcPath = [g_appDelegate.sourceFolder stringByAppendingPathComponent:fileName];
        
        NSLog(@"srcPath is %@", srcPath);
        NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
        [dateFormatter setDateFormat:@"yyyy"];
        NSString *year = [dateFormatter stringFromDate:[NSDate date]] ;
        [dateFormatter setDateFormat:@"MM"];
        NSString *month = [dateFormatter stringFromDate:[NSDate date]];
        [dateFormatter setDateFormat:@"dd"];
        NSString *day = [dateFormatter stringFromDate:[NSDate date]];
        [dateFormatter setDateFormat:@"HH"];
        NSString *hour = [dateFormatter stringFromDate:[NSDate date]];
        [dateFormatter setDateFormat:@"mm"];
        NSString *minute = [dateFormatter stringFromDate:[NSDate date]];
        [dateFormatter setDateFormat:@"ss"];
        NSString *second = [dateFormatter stringFromDate:[NSDate date]];
        
        NSString *extension = nil;
        NSArray *extenArr = [fileName componentsSeparatedByString:@"."];
        NSLog(@"size = %lu", (unsigned long)[extenArr count]);
        if([extenArr count] > 1){
            extension = [extenArr objectAtIndex:1];
        }
        if( [extension isEqualToString:@"jpg"] )
        {
            NSRange Camera = [srcPath rangeOfString:@"/tmp/cdv_photo_"];
            if( Camera.location != NSNotFound )
            {
                fileName = @"photo_";
                fileName = [fileName stringByAppendingString:year];
                fileName = [fileName stringByAppendingString:month];
                fileName = [fileName stringByAppendingString:day];
                fileName = [fileName stringByAppendingString:hour];
                fileName = [fileName stringByAppendingString:minute];
                fileName = [fileName stringByAppendingString:second];
                fileName = [fileName stringByAppendingString:@".jpg"];
            }
        }
        else if( [extension isEqualToString:@"MOV"]  )
        {
            NSRange Video = [srcPath rangeOfString:@"/tmp/capture"];
            if( Video.location != NSNotFound )
            {
                fileName = @"video_";
                fileName = [fileName stringByAppendingString:year];
                fileName = [fileName stringByAppendingString:month];
                fileName = [fileName stringByAppendingString:day];
                fileName = [fileName stringByAppendingString:hour];
                fileName = [fileName stringByAppendingString:minute];
                fileName = [fileName stringByAppendingString:second];
                fileName = [fileName stringByAppendingString:@".MOV"];
            }
        }
        
        
        NSLog(@"fileName is %@", fileName);
        
        // 폴더이면 폴더를 만든다.
        if ([g_FileUtil isFolder: srcPath])
        {
            m_bFinished = NO;
            g_fileInfo.m_dwAttrib |= FA_FOLDER;
            
            [serverCmd CreateDir: m_nSelectedDrive 
                         srcName: [currentFolder stringByAppendingPathComponent:fileName] 
                        fileInfo: nil 
                       sharePath: cookieinfo->m_strSharePath  
                          sender: self 
                        selector: @selector(didFinishCreateDir:fileInfo:)
                   g_appDelegate: g_appDelegate];
        }
        else
        {
         
            NSString	*errmsg = nil;
            NSInteger	filesize = 0;
            
            if (![serverCmd PutFileCheck: m_nSelectedDrive 
                                 srcName: [currentFolder stringByAppendingPathComponent: fileName] 
                                 srcPath: srcPath 
                                fileInfo: nil 
                               sharePath: cookieinfo->m_strSharePath  
                                  sender: self
                                  errmsg: &errmsg 
                                filesize: &filesize
                           g_appDelegate: g_appDelegate])
            {
//                UIAlertView	*av = [[[UIAlertView alloc] initWithTitle:nil message:NSLocalizedString(errmsg, nil) delegate:nil cancelButtonTitle:NSLocalizedString(@"OK", nil) otherButtonTitles:nil] autorelease];
//                [av show];
                m_bError = YES;
            }
            
            if (filesize != -1 && allYes == NO)
            {
                int index = [g_appDelegate checkOverwrite:fileName allYes:YES];
                m_bOverwrite = NO;
                // cancel
                if (index == 3)
                    break;
                // no
                else if (index == 2)
                    continue;
                // all yes
                else if (index == 1){
                    m_bOverwrite = YES;
                    allYes = YES;   
                }
                // yes
                else if (index == 0){
                    m_bOverwrite = YES;
                    allYes = YES;   
                }
                
            }
            
            m_bFinished = NO;
            
            // 파일을 업로드한다.
            [serverCmd PutFile: m_nSelectedDrive
                       srcName: [[currentFolder stringByAppendingPathComponent: fileName]precomposedStringWithCanonicalMapping] 
                       srcPath: srcPath			 
                      fileInfo: nil
                     sharePath: cookieinfo->m_strSharePath
//                          view: g_appDelegate.navServerController.view
                         order: (i+1) 
                     totalfile: g_appDelegate.sourceData.count
                        sender: self 
                      selector: @selector(didFinishPutFile:fileInfo:)
                 g_appDelegate: g_appDelegate
             ActView: (ActivityViewController *) ActViewCtl];
        }
        
    while (!m_bFinished && !m_bCancel)
            [[NSRunLoop currentRunLoop] runMode:NSDefaultRunLoopMode beforeDate:[NSDate distantFuture]];
        
        if (m_bCancel)
            break;
    
    }
    
	
    
    g_appDelegate.pasteStatus = NO;
	g_appDelegate.isRecursive = 0;
    return retVal;
}

- (NSString *)   UploadFiles_phone:(CentralECMAppDelegate *)g_appDelegate ActView:(ActivityViewController_phone *)ActViewCtl{
    m_bGetFile = TRUE;
    
	NSString	*fileName;
	NSString	*srcPath;
	NSString    *retVal = @"complete";
	g_bFileOpEnd = FALSE;
    BOOL	allYes = NO;
	BOOL	b3G = NO;
	m_bCancel = NO;
	m_bError = NO;
    int g_nSourceDrive = 0;
    
    ServerCmd	*serverCmd = [[ServerCmd alloc] init];
    FileUtil *fileUtil = [[FileUtil alloc] init];
    // client to server의 경우 폴더를 파일 리스트로 바꾼다.
    NSMutableArray *sourceData = [[NSMutableArray alloc] initWithArray:g_appDelegate.sourceData];
    [g_appDelegate.sourceData removeAllObjects];
    NSFileManager *fileMgr = [NSFileManager defaultManager];
    NSString *filename;
    
    NIDriveInfo *info = [g_appDelegate.m_arrDriveInfo objectAtIndex:g_nSourceDrive];
    NICookieInfo *cookieinfo = [g_appDelegate.m_arrCookieInfo objectAtIndex:g_nSourceDrive];
    NSString *currentFolder = info->m_strCurrentPath;
    
    for (int i=0; i<sourceData.count; i++)
    {
        CFileInfo *fileInfo = (CFileInfo *)[sourceData objectAtIndex:i];
        
        srcPath = [g_appDelegate.sourceFolder stringByAppendingPathComponent:fileInfo.m_strName];
		NSLog(@"srcPath is %@", srcPath);
        if ([fileUtil isFolder: srcPath])
        {
            NSDirectoryEnumerator *dirEnum = [fileMgr enumeratorAtPath:srcPath];
            int	cnt = 0;
            
            while ((filename = [dirEnum nextObject]) != nil)
            {
                filename = [fileUtil getFilename:filename];
                NSString *filePath = [NSString stringWithFormat:@"%@/%@", [srcPath lastPathComponent], filename];
                NSLog(@"onPaste:%@", filePath);
                CFileInfo *fileInfo2 = [CFileInfo alloc];
                fileInfo2.m_strName = [NSString stringWithString:filePath];
                [g_appDelegate.sourceData addObject:fileInfo2];
                cnt++;
            }
            
            // 폴더안에 파일이 없는 경우
            if (cnt == 0)
            {
                NSLog(@"onPaste:%@", [srcPath lastPathComponent]);
                CFileInfo *fileInfo2 = [CFileInfo alloc];
                fileInfo2.m_strName = [NSString stringWithString:[srcPath lastPathComponent]];
                [g_appDelegate.sourceData addObject:fileInfo2];
            }
        }
        else
        {
            CFileInfo *fileInfo2 = [CFileInfo alloc];
            fileInfo2.m_strName = [NSString stringWithString:fileInfo.m_strName];
            [g_appDelegate.sourceData addObject:fileInfo2];
        }
    }
    
    [sourceData release];
	
    
	//[m_folderInfoArray removeAllObjects];
    
    for (int i=0; i<g_appDelegate.sourceData.count; i++)
	{
		g_fileInfo = (CFileInfo *)[g_appDelegate.sourceData objectAtIndex:i];
		fileName = g_fileInfo.m_strName;
        
		srcPath = [g_appDelegate.sourceFolder stringByAppendingPathComponent:fileName];
        
        NSLog(@"srcPath is %@", srcPath);
        NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
        [dateFormatter setDateFormat:@"yyyy"];
        NSString *year = [dateFormatter stringFromDate:[NSDate date]] ;
        [dateFormatter setDateFormat:@"MM"];
        NSString *month = [dateFormatter stringFromDate:[NSDate date]];
        [dateFormatter setDateFormat:@"dd"];
        NSString *day = [dateFormatter stringFromDate:[NSDate date]];
        [dateFormatter setDateFormat:@"HH"];
        NSString *hour = [dateFormatter stringFromDate:[NSDate date]];
        [dateFormatter setDateFormat:@"mm"];
        NSString *minute = [dateFormatter stringFromDate:[NSDate date]];
        [dateFormatter setDateFormat:@"ss"];
        NSString *second = [dateFormatter stringFromDate:[NSDate date]];
        
        NSArray *extenArr = [fileName componentsSeparatedByString:@"."];
        NSString *extension = [extenArr objectAtIndex:1];
        if( [extension isEqualToString:@"jpg"] )
        {
            NSRange Camera = [srcPath rangeOfString:@"/tmp/cdv_photo_"];
            if( Camera.location != NSNotFound )
            {
                fileName = @"photo_";
                fileName = [fileName stringByAppendingString:year];
                fileName = [fileName stringByAppendingString:month];
                fileName = [fileName stringByAppendingString:day];
                fileName = [fileName stringByAppendingString:hour];
                fileName = [fileName stringByAppendingString:minute];
                fileName = [fileName stringByAppendingString:second];
                fileName = [fileName stringByAppendingString:@".jpg"];
            }
        }
        else if( [extension isEqualToString:@"MOV"]  )
        {
            NSRange Video = [srcPath rangeOfString:@"/tmp/capture"];
            if( Video.location != NSNotFound )
            {
                fileName = @"video_";
                fileName = [fileName stringByAppendingString:year];
                fileName = [fileName stringByAppendingString:month];
                fileName = [fileName stringByAppendingString:day];
                fileName = [fileName stringByAppendingString:hour];
                fileName = [fileName stringByAppendingString:minute];
                fileName = [fileName stringByAppendingString:second];
                fileName = [fileName stringByAppendingString:@".MOV"];
            }
        }
        
        
        NSLog(@"fileName is %@", fileName);
        // 폴더이면 폴더를 만든다.
        if ([g_FileUtil isFolder: srcPath])
        {
            m_bFinished = NO;
            g_fileInfo.m_dwAttrib |= FA_FOLDER;
            
            [serverCmd CreateDir: m_nSelectedDrive
                         srcName: [currentFolder stringByAppendingPathComponent:fileName]
                        fileInfo: nil
                       sharePath: cookieinfo->m_strSharePath
                          sender: self
                        selector: @selector(didFinishCreateDir:fileInfo:)
                   g_appDelegate: g_appDelegate];
        }
        else
        {
            NSString	*errmsg = nil;
            NSInteger	filesize = 0;
            
            if (![serverCmd PutFileCheck: m_nSelectedDrive
                                 srcName: [currentFolder stringByAppendingPathComponent: fileName]
                                 srcPath: srcPath
                                fileInfo: nil
                               sharePath: cookieinfo->m_strSharePath
                                  sender: self
                                  errmsg: &errmsg
                                filesize: &filesize
                           g_appDelegate: g_appDelegate])
            {
                UIAlertView	*av = [[[UIAlertView alloc] initWithTitle:nil message:NSLocalizedString(errmsg, nil) delegate:nil cancelButtonTitle:NSLocalizedString(@"OK", nil) otherButtonTitles:nil] autorelease];
//                [av show];
                m_bError = YES;
            }
            
            if (filesize != -1 && allYes == NO)
            {
                int index = [g_appDelegate checkOverwrite:fileName allYes:YES];
                m_bOverwrite = NO;
                // cancel
                if (index == 3)
                    break;
                // no
                else if (index == 2)
                    continue;
                // all yes
                else if (index == 1){
                    m_bOverwrite = YES;
                    allYes = YES;
                }
                // yes
                else if (index == 0){
                    m_bOverwrite = YES;
                    allYes = YES;
                }
                
            }
            
            m_bFinished = NO;
            
            // 파일을 업로드한다.
            [serverCmd PutFile: m_nSelectedDrive
                       srcName: [[currentFolder stringByAppendingPathComponent: fileName]precomposedStringWithCanonicalMapping]
                       srcPath: srcPath
                      fileInfo: nil
                     sharePath: cookieinfo->m_strSharePath
             //                          view: g_appDelegate.navServerController.view
                         order: (i+1)
                     totalfile: g_appDelegate.sourceData.count
                        sender: self
                      selector: @selector(didFinishPutFile:fileInfo:)
                 g_appDelegate: g_appDelegate
                       ActView: (ActivityViewController *) ActViewCtl];
        }
        
        while (!m_bFinished && !m_bCancel)
            [[NSRunLoop currentRunLoop] runMode:NSDefaultRunLoopMode beforeDate:[NSDate distantFuture]];
        
        if (m_bCancel)
            break;
    }
    
	
    
    g_appDelegate.pasteStatus = NO;
	g_appDelegate.isRecursive = 0;
    return retVal;
}

// 파일 업로드 후 결과 처리
- (void) didFinishPutFile: (NSString *) errmsg 
                 fileInfo: (CFileInfo *) recvFileInfo
{
	if (errmsg)
	{
		UIAlertView	*av = [[[UIAlertView alloc] initWithTitle:nil message:NSLocalizedString(errmsg, nil) delegate:nil cancelButtonTitle:NSLocalizedString(@"OK",nil) otherButtonTitles:nil] autorelease];
//		[av show];
		m_bError = YES;
	}
	else
	{
		NSLog(@"didFinishPutFile:%@", g_fileInfo.m_strName);
        
		// 폴더에 있는 파일의 경우 현재 테이블에는 폴더만 나오면 된다.
		NSRange range = [g_fileInfo.m_strName rangeOfString:@"/"];
		
		BOOL	bFound = NO;
        
		if (range.location != NSNotFound)
		{
			g_fileInfo.m_strName = [NSString stringWithString:[g_fileInfo.m_strName substringToIndex:range.location]];
			g_fileInfo.m_dwAttrib |= FA_FOLDER;
			NSLog(@"didFinishPutFile:%@", g_fileInfo.m_strName);
			
			for (int i=0; i<[m_folderInfoArray count]; i++)
			{
				NSString	*folderName = [m_folderInfoArray objectAtIndex:i];
				
				if ([g_fileInfo.m_strName isEqualToString:folderName])
				{
					bFound = YES;
					break;
				}
			}
			
			// 폴더 이름이 처음이면 m_folderInfoArray에 추가한다.
			if (bFound == NO)
				[m_folderInfoArray addObject:g_fileInfo.m_strName];
		}
		
//		if (bFound == NO)
//		{
//			// 같은 이름의 파일이 m_fileInfoArray에 있다면 overwrite인 경우이므로 m_fileInfoArray에서 삭제한다.
//			for (int i=0; i<[m_fileInfoArray count]; i++)
//			{
//				CFileInfo	*fileInfo = [m_fileInfoArray objectAtIndex:i];
//				
//				if ([g_fileInfo.m_strName isEqualToString:fileInfo.m_strName])
//				{
//					[self removeItem:i];
//					break;
//				}
//			}
//			
//			CFileInfo	*fileInfo = [[CFileInfo alloc] initWithCFileInfo:g_fileInfo];
//			fileInfo.m_dwACL = recvFileInfo.m_dwACL;
//			fileInfo.m_dtLastWriteTime = [NSString stringWithString:recvFileInfo.m_dtLastWriteTime];
//			[self addToCellData:fileInfo];
//            
//			m_addCount++;
//		}
	}
    
	m_bFinished = YES;
//    UIAlertController * alert=   [UIAlertController
//                                  alertControllerWithTitle:@"파일을 저장하였습니다."
//                                  message:@""
//                                  preferredStyle:UIAlertControllerStyleAlert];
//    
//    UIAlertAction* ok = [UIAlertAction
//                         actionWithTitle:@"OK"
//                         style:UIAlertActionStyleDefault
//                         handler:^(UIAlertAction * action)
//                         {
//                             [alert dismissViewControllerAnimated:YES completion:nil];
//                         }];
//    
//    [alert addAction:ok];
//    AppDelegate *AD = [[UIApplication sharedApplication] delegate];
//    [AD.navigationController presentViewController:alert animated:YES completion:nil];
}

// 폴더 생성 후 ServerCmd에서 호출한다.
- (void) didFinishCreateDir: (NSString *) errmsg
				   fileInfo: (CFileInfo *) recvFileInfo
{
	if (errmsg == nil)
	{
        // 파일을 업로드하다가 생성한 경우
		
        NSLog(@"didFinishCreateDir:%@", g_fileInfo.m_strName);
        NSRange range = [g_fileInfo.m_strName rangeOfString:@"/"];
			
        // "/"가 있는 경우는 하위 폴더이다. 이때는 테이블 셀에 추가하면 안된다.
        if (range.location == NSNotFound)
        {
            CFileInfo	*fileInfo = [[CFileInfo alloc] initWithCFileInfo:g_fileInfo];
            fileInfo.m_dwACL = recvFileInfo.m_dwACL;
            fileInfo.m_dtLastWriteTime = [NSString stringWithString:recvFileInfo.m_dtLastWriteTime];
//            [self addToCellData:fileInfo];
				
            m_addCount++;
        }
	}
//	else
//	{
//		// 업로드하다가 폴더를 만들때 이미 있다면 테이블 셀에 이펙트를 주기 위해 m_fileInfoArray에서 지웠다가 추가한다.
//		if ([errmsg length] >= 7 && [[errmsg substringToIndex:7] isEqualToString:@"Already"])
//		{
//			NSLog(@"Already Forder:%@", g_fileInfo.m_strName);
//			NSRange range = [g_fileInfo.m_strName rangeOfString:@"/"];
//			
//			// "/"가 있는 경우는 하위 폴더이다. 이때는 테이블 셀에 추가하면 안된다.
//			if (range.location == NSNotFound)
//			{
//				CFileInfo	*fileInfo = [[CFileInfo alloc] initWithCFileInfo:g_fileInfo];
//				
//				for (int i=0; i<[m_fileInfoArray count]; i++)
//				{
//					CFileInfo	*fileInfo2 = [m_fileInfoArray objectAtIndex:i];
//					
//					NSLog(@"fileInfo2.m_strName:%@, fileInfo.m_strName:%@", fileInfo2.m_strName, fileInfo.m_strName);
//					
//					if ([fileInfo2.m_strName isEqualToString:fileInfo.m_strName])
//					{
//						fileInfo.m_dwACL = fileInfo2.m_dwACL;
//						fileInfo.m_dtLastWriteTime = [NSString stringWithString:fileInfo2.m_dtLastWriteTime];
//                        
//						[self removeFromCellData:fileInfo.m_strName];
//						[self addToCellData:fileInfo];
//						m_addCount++;
//						break;
//					}
//				}
//			}
//		}
//	}
	m_nCmdType = -1;
	m_bFinished = TRUE;
}

-(void) cancel
{
	UIAlertView	*av = [[[UIAlertView alloc] initWithTitle:nil message:NSLocalizedString(@"업로드를 실패했습니다.", nil) delegate:nil cancelButtonTitle:NSLocalizedString(@"OK",nil) otherButtonTitles:nil] autorelease];
	[av show];
	
	//[table deselectRowAtIndexPath:m_selectedIndexPath animated:YES];
    
	m_bCancel = TRUE;
	m_bGetFile = FALSE;
    //	g_appDelegate.m_bServerTab = TRUE;
}

- (void) dealloc
{
	[m_folderInfoArray release];
    [super dealloc];
}
@end
