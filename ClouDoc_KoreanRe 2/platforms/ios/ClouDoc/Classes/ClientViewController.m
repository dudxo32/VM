//
//  ClientViewController.m
//  CentralECM
//
//  Created by HeungKyoo Han on 10. 04. 18
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import "ClientViewController.h"
#import "CentralECMAppDelegate.h"
#import "ServerCmd.h"
//#import "PhotoViewController.h"
//#import "WebThree20ViewController.h"
#import "FileUtil.h"
#import "ActivityViewController.h"
#import "ServerViewController.h"

//extern	CDriveInfo		g_driveInfo[3];
extern	FileUtil		*g_FileUtil;
extern	int				g_nSourceDrive;
extern NSMutableArray	*g_ShareFolderList;

@implementation ClientViewController

#pragma mark -
#pragma mark server command response handler

// 파일 업로드 후 결과 처리
- (void) didFinishPutFile: (NSString *) errmsg 
				 fileInfo: (CFileInfo *) fileInfo
{
	if (!errmsg)
		errmsg = NSLocalizedString(@"file saved", nil);

	UIAlertView	*av = [[[UIAlertView alloc] initWithTitle:nil message:errmsg delegate:nil cancelButtonTitle:NSLocalizedString(@"OK", nil) otherButtonTitles:nil] autorelease];
	[av show];
	
	m_bFinished = YES;
}

// 파일 뷰어에서 Save를 누르면 개인문서함의 루트로 파일을 업로드한다.
- (void) onSave: (id) sender
{
	m_bGetFile = TRUE;
	g_appDelegate.m_bClientTab = FALSE;
	
	NSString *fileName = [m_filePath lastPathComponent];
	
	NSLog(@"onSave: filePath: %@", m_filePath);
	
	NSString *srcName = [NSString stringWithFormat:@"/%@", fileName];

	NSString	*errmsg;
	NSInteger	filesize;
	
	ServerCmd	*serverCmd = [[ServerCmd alloc] init];
	if (![serverCmd PutFileCheck:0 srcName:srcName srcPath:m_filePath fileInfo:nil sharePath:nil sender: self errmsg:&errmsg filesize:&filesize])
	{
		UIAlertView	*av = [[[UIAlertView alloc] initWithTitle:nil message:NSLocalizedString(errmsg, nil) delegate:nil cancelButtonTitle:NSLocalizedString(@"OK", nil) otherButtonTitles:nil] autorelease];
		[av show];
		return;
	}
	
	if (filesize != -1)
	{
		int index = [g_appDelegate checkOverwrite:fileName allYes:NO];
		
		// 예가 아니면
		if (index != 0)
		{
			return;
		}
	}

	if (![g_appDelegate check3G:UPLOAD])
	{
		return;
	}
	
	m_bFinished = NO;
	
	// 파일을 업로드한다.
	[serverCmd PutFile: 0
			   srcName: srcName 
			   srcPath: m_filePath
			  fileInfo: nil
			 sharePath: nil 
				  view: g_appDelegate.navClientController.view 
				 order: 1 
			 totalfile: 1
				sender: self 
			  selector: @selector(didFinishPutFile:fileInfo:)];

	while (!m_bFinished && !m_bCancel)
		[[NSRunLoop currentRunLoop] runMode:NSDefaultRunLoopMode beforeDate:[NSDate distantFuture]];

	m_bGetFile = FALSE;
	g_appDelegate.m_bClientTab = TRUE;
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
				[g_appDelegate.sourceData addObject:fileInfo];
			}
		}
		
		[fileInfoArray release];
	}
	
	m_bFinished = YES;
}

// 파일 삭제후 결과 처리
- (void) didFinishDeleteFile: (NSString *) errmsg filePath: (NSString *) filePath
{
	if (errmsg)
	{
		UIAlertView	*av = [[[UIAlertView alloc] initWithTitle:nil message:NSLocalizedString(errmsg, nil) delegate:nil cancelButtonTitle:NSLocalizedString(@"OK",nil) otherButtonTitles:nil] autorelease];
		[av show];
	}
	// m_fileInfoArray에서 fileInfo를 삭제한다.
	else
	{
		ServerViewController *controller = (ServerViewController *)g_appDelegate.sourceServerViewController;
		NSMutableArray *fileInfoArray = (NSMutableArray *)controller.m_fileInfoArray;
		
		NSString *fileName = [filePath lastPathComponent] ;

		for (int i=0; i<[fileInfoArray count]; i++)
		{
			CFileInfo	*fileInfo = [fileInfoArray objectAtIndex:i];
			
			if ([fileName isEqualToString:fileInfo.m_strName])
				[controller removeItem:i];
		}
	}
	
	m_bFinished = YES;
}

// 파일 다운로드 후 결과 처리
- (void) didFinishGetFile: (NSString *) errmsg 
				 filePath: (NSString *) filePath
{
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

#pragma mark -
#pragma mark overide methods

-(BOOL) copyFile:(NSString *)srcPath 
		  toPath:(NSString *)dstPath
{
	BOOL bStat = YES;
	int dwError = 0;
 	NSFileManager *fileMgr = [NSFileManager defaultManager];
	
	if ([fileMgr fileExistsAtPath:srcPath])
	{
		if ([fileMgr fileExistsAtPath:dstPath])
		{
			bStat = [fileMgr removeItemAtPath:dstPath  error: nil];
		}
		
		bStat = [fileMgr copyItemAtPath:srcPath toPath:dstPath error: nil];
	}
	
	if (bStat == NO)
	{
		dwError = errno;
	}
	
	return bStat;
}

-(BOOL) moveFile:(NSString *)srcPath 
		  toPath:(NSString *)dstPath
{
	BOOL bStat = YES;
	int dwError = 0;
	
 	NSFileManager *fileMgr = [NSFileManager defaultManager];
	
	if ([fileMgr fileExistsAtPath:srcPath])
	{
		if ([srcPath isEqualToString:dstPath])
		{
			return YES;
		}
		
		if ([fileMgr fileExistsAtPath:dstPath])
		{
			bStat =[fileMgr removeItemAtPath:dstPath  error: NULL];
 		}
		
		//bStat = [fileMgr moveItemAtPath:srcPath toPath:dstPath error: NULL];
	}
	
	if (bStat == NO)
	{
		dwError =errno;
	}
	
	return bStat;
}

-(void) pushFolder:(NSInteger) row
{
	ClientViewController * clientViewController = [[ClientViewController alloc] init]; 
	[clientViewController setTitle: [self getFileName:m_fileInfoArray row:row]];
	[clientViewController setCurrentFolder : [currentFolder stringByAppendingPathComponent:[self getFileName:m_fileInfoArray row:row]]];
	[clientViewController setFolderDepth: self.folderDepth+1];
	[g_appDelegate.navClientController pushViewController:clientViewController animated:YES];
	[clientViewController release];
}	

-(BOOL) isFolder:(NSInteger) row
{
 	NSString * filePath = [self getFilePath:m_fileInfoArray row:row];
	NSFileManager * fileManager = [[NSFileManager alloc] init];
	
	BOOL	isDir;
 	
	return ([fileManager fileExistsAtPath:filePath isDirectory:&isDir] && isDir);
}	

-(BOOL) renameFile:(NSString *)srcPath 
			toPath:(NSString *)dstPath
{
	return [self moveFile:srcPath toPath:dstPath];
}

-(BOOL) deleteFile:(NSInteger)row
{
	NSString * srcPath = [self getFilePath:m_fileInfoArray row:row];
	
	BOOL bStat = YES;
	int dwError = 0;

 	NSFileManager *fileMgr = [NSFileManager defaultManager];
 	
	if ([fileMgr fileExistsAtPath:srcPath])
	{
 		bStat = [fileMgr removeItemAtPath:srcPath  error: NULL];
 	}
	
	if (bStat == NO)
	{
		dwError =errno;
	}

	return bStat;
}

-(void) refreshListData
{
	[super refreshListData];
 	NSFileManager *fileManager = [NSFileManager defaultManager];
	
	//NSArray *fileList = [fileManager directoryContentsAtPath:currentFolder];

	NSError *fileError = NULL;
	NSArray *fileList = [fileManager contentsOfDirectoryAtPath:currentFolder error:&fileError];
	if ( fileError != NULL )
	{
#ifdef DEBUG
		NSLog(@"fileList Error : %s", fileError);
#endif
	}
	
	
	BOOL	isDir;
	
	// add folders
	for (NSString *s in fileList)
	{
		s = [g_FileUtil getFilename:s];
		
		NSString *filePath = [currentFolder stringByAppendingPathComponent:s];

 		if ([fileManager fileExistsAtPath:filePath isDirectory:&isDir] && isDir)
		{
			CFileInfo	* fileInfo = [CFileInfo alloc];
			fileInfo.m_strName = [[NSString alloc] initWithString:s];
		
			// .tmp 폴더는 서버에서 다운로드 받은 파일을 저장하는 폴더이다. .tmp 폴더는 안보이게 한다.
			if (![s isEqualToString:@".tmp"])
				[self addToCellData: fileInfo];
		}
 	}
	
	// add files
	for (NSString *s in fileList)
	{
		s = [g_FileUtil getFilename:s];

		NSString *filePath = [currentFolder stringByAppendingPathComponent:s];

 		if ([fileManager fileExistsAtPath:filePath isDirectory:&isDir] && !isDir)
		{
			CFileInfo	* fileInfo = [CFileInfo alloc];
			fileInfo.m_strName = [[NSString alloc] initWithString:s];
			
			[self addToCellData:fileInfo];
		}
 	}
}

-(BOOL)  fileExistsAtPath:(NSString *)fileName
{	
	NSFileManager *fileMgr = [NSFileManager defaultManager];
	return [fileMgr fileExistsAtPath:[currentFolder stringByAppendingPathComponent:fileName]] ;
}	

#pragma mark -
#pragma mark overide event handler

// paste, cancel 버튼 클릭시 호출
-(void)onPaste: (NSMutableArray *) sourceData
{
	// rename버튼이 활성되면서 paste가 cancel로 바뀐경우 onRename에서 처리한다.
	if (g_appDelegate.pasteStatus == RENAMES)
	{
		g_appDelegate.pasteStatus  = CANCEL;
		[self onRename];
		return;
	}
 	
	m_bGetFile = TRUE;
	g_appDelegate.m_bClientTab = FALSE;

	int i = 0;
	NSString *fileName;
	NSString *filePath;
	NSFileManager *fileMgr = [NSFileManager defaultManager];
	m_addCount = 0;
	BOOL allYes = NO;
	
	// server to client (download)
	if (g_appDelegate.sourceType == SERVER)
	{
//		if (![g_appDelegate check3G:DOWNLOAD])
//			return;

		ServerViewController *controller = (ServerViewController *)g_appDelegate.sourceServerViewController;
		
		// .tmp/xxx 폴더를 삭제하고 다시 만든다.
		NSString *tmpFolder = [NSString stringWithFormat:@"%@/xxx", [g_FileUtil getTmpFolder]];
		NSFileManager *fileMgr = [NSFileManager defaultManager];
		[fileMgr removeItemAtPath:tmpFolder error:nil];
		[fileMgr createDirectoryAtPath:tmpFolder withIntermediateDirectories:YES attributes:nil error:nil];
		
		NSMutableArray *sourceData = [[NSMutableArray alloc] initWithArray:g_appDelegate.sourceData];
		[g_appDelegate.sourceData removeAllObjects];

		ServerCmd	*serverCmd = [[ServerCmd alloc] init];

		m_bError = NO;
		
		for (i=0; i<sourceData.count; i++)
		{
			CFileInfo	*fileInfo = (CFileInfo *)[sourceData objectAtIndex:i];
			
			// 폴더의 경우 .tmp폴더에 폴더를 만들고 파일 리스트로 만든다.
			if (fileInfo.m_dwAttrib & FA_FOLDER)
			{
				// 공유 폴더이면 공유 폴더 관련 변수를 셋팅한다.
				filePath = [NSString stringWithFormat:@"%@/xxx/%@", [g_FileUtil getTmpFolder], fileInfo.m_strName];
				m_folderName = fileInfo.m_strName;

				NSFileManager *fileMgr = [NSFileManager defaultManager];
				[fileMgr createDirectoryAtPath:filePath withIntermediateDirectories:YES attributes:nil error:nil];
				
				m_bFinished = NO;
				
				NIDriveInfo *info = [g_appDelegate.m_arrDriveInfo objectAtIndex:g_nSourceDrive];
				
				if ( info->m_nDiskType == DT_SHARE)
					[serverCmd GetList: g_nSourceDrive 
							folderName: [g_appDelegate.sourceFolder stringByAppendingPathComponent:fileInfo.m_strName] 
							  fileInfo: [g_ShareFolderList objectAtIndex:controller.m_nShareFolder] 
							 sharePath: controller.m_sharePath 
							 recursive: YES 
								sender: self 
							  selector: @selector(didFinishGetList:fileInfoArray:)];
				else
					[serverCmd GetList: g_nSourceDrive 
							folderName: [g_appDelegate.sourceFolder stringByAppendingPathComponent:fileInfo.m_strName] 
							  fileInfo: nil 
							 sharePath: nil 
							 recursive: YES 
								sender: self 
							  selector: @selector(didFinishGetList:fileInfoArray:)];
				
				while (!m_bFinished)
					[[NSRunLoop currentRunLoop] runMode:NSDefaultRunLoopMode beforeDate:[NSDate distantFuture]];

				// HTTP Request cancel
				if (m_bCancel)
					break;
			}
			else
				[g_appDelegate.sourceData addObject:fileInfo];
		}
		
		for (i=0; i<g_appDelegate.sourceData.count; i++)
		{
			CFileInfo	*fileInfo = (CFileInfo *)[g_appDelegate.sourceData objectAtIndex:i];
			fileName = fileInfo.m_strName;
			
			NSString *tmpDir = @"xxx";
			NSString *lastPathComponent = [fileName lastPathComponent];
			
			if (![lastPathComponent isEqualToString: fileName])
			{
				tmpDir = [tmpDir stringByAppendingPathComponent:[fileName substringToIndex:[fileName length]-[lastPathComponent length]]];
			}
			
			filePath = [g_appDelegate.sourceFolder stringByAppendingPathComponent:fileName];

			NSLog(@"before tmpDir:%@,GetFile:%@", tmpDir, filePath);
			
			int index = -1;
			
			if (allYes == YES 
				|| [self fileExistsAtPath:fileName] == NO
				|| (index = [g_appDelegate checkOverwrite:fileName allYes:YES]) > -1) 
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
						  fileInfo: [controller getShareFolder] 
						 sharePath: [controller getSharePath] 
//							  view: g_appDelegate.navClientController.view 
							 order: (i+1) 
						 totalfile: g_appDelegate.sourceData.count
							sender: self 
						  selector: @selector(didFinishGetFile:filePath:)
                g_appDelegate:g_appDelegate];
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
			
			filePath = [NSString stringWithFormat:@"%@/xxx/%@", [g_FileUtil getTmpFolder], fileInfo.m_strName];
			NSString *dstPath = [currentFolder stringByAppendingPathComponent:fileInfo.m_strName];

			NSLog(@"onPaste:filePath:%@,dstPath:%@", filePath, dstPath);
			
			// 파일이 있으면 m_fileInfoArray에서 삭제한다.
			if ([g_FileUtil isExist:dstPath])
			{
				for (int i=0; i<[m_fileInfoArray count]; i++)
				{
					CFileInfo	*fileInfo = [m_fileInfoArray objectAtIndex:i];
					
					if ([fileInfo.m_strName isEqualToString:[dstPath lastPathComponent]])
						[self removeItem:i];
				}
			}
			
			// .tmp/xxx 폴더 아래 있는 파일을 currentFolder로 이동한다.
			if ([g_FileUtil moveFile:filePath dstPath:dstPath])
			{
				CFileInfo	*fileInfo = [g_FileUtil getFileInfo:dstPath];
				[self addToCellData:fileInfo];
				m_addCount++;
				
				// cut이면 서버에 있는 파일을 삭제한다.
				if (!m_bError && g_appDelegate.pasteStatus == CUT)
				{
					ServerViewController *controller = (ServerViewController *)g_appDelegate.sourceServerViewController;
					
					NSString *fileName = [g_appDelegate.sourceFolder stringByAppendingPathComponent:[dstPath lastPathComponent]];
					
					m_bFinished = NO;
					
					ServerCmd	*serverCmd = [[ServerCmd alloc] init];
					[serverCmd DeleteFile:g_nSourceDrive fileName:fileName fileInfo:[controller getShareFolder] sharePath:[controller getSharePath] sender:self selector:@selector(didFinishDeleteFile:filePath:)];
					
					while (!m_bFinished)
						[[NSRunLoop currentRunLoop] runMode:NSDefaultRunLoopMode beforeDate:[NSDate distantFuture]];
					
					[controller.table reloadData];
				}
			}
		}
		
		m_bGetFile = FALSE;
		g_appDelegate.m_bClientTab = TRUE;
	}
	// client to client
	else
	{
		for (i=0; i<g_appDelegate.sourceData.count; i++)
		{
			CFileInfo	*fileInfo = (CFileInfo *)[g_appDelegate.sourceData objectAtIndex:i];
			fileName = fileInfo.m_strName;
			filePath = [g_appDelegate.sourceFolder stringByAppendingPathComponent:fileName];
			
			NSLog(@"onPaste: filePath is %@", filePath);
			
			// 동일한 폴더인경우
			// copy이면 복제를 하고
			// cut이면 바로 바꾼다.
			if ([g_appDelegate.sourceFolder localizedCompare:currentFolder ] == 0)
			{
				if (g_appDelegate.pasteStatus == COPY)
				{
					while (YES)
					{
						if ([fileMgr fileExistsAtPath:[currentFolder stringByAppendingPathComponent:fileName]] )
						{
							if ([[fileName pathExtension] isEqual:@""])
							{
								fileName = [NSString stringWithFormat: NSLocalizedString(@"%@_copy", nil), fileName];
							}
							else
							{
								fileName = [NSString stringWithFormat: NSLocalizedString(@"%@_copy.%@", nil), [fileName stringByDeletingPathExtension],[fileName pathExtension]];
							}
						}
						else
						{
							break;
						}
					}
					
					if ([self copyFile:filePath toPath:[currentFolder stringByAppendingPathComponent:fileName]])
					{
						CFileInfo	*fileInfo = [g_FileUtil getFileInfo:[currentFolder stringByAppendingPathComponent:fileName]];
						[self addToCellData:fileInfo];
						m_addCount++;
					}
				}
				// CUT
				else
				{
					if ([self moveFile:filePath toPath: [currentFolder stringByAppendingPathComponent:fileName]])
					{
						// 테이블 셀 select->deselect 이펙트를 보여주기 위해 m_fileInfoArray에서 fileInfo를 삭제하고 다시 추가한다. 
						for (int i=0; i<[m_fileInfoArray count]; i++)
						{
							CFileInfo	*fileInfo = [m_fileInfoArray objectAtIndex:i];
							
							if ([fileInfo.m_strName isEqualToString:fileName])
								[self removeItem:i];
						}
						
						CFileInfo	*fileInfo = [g_FileUtil getFileInfo:[currentFolder stringByAppendingPathComponent:fileName]];
						[self addToCellData:fileInfo];
						m_addCount++;
					}
				}
			}
			// 다른 폴더인경우
			// self or child 폴더로 이동인 경우는 이동이 취소된다.
			else
			{
				if (g_appDelegate.isRecursive)
				{
//					NSLog(@"isRecursive.....");
//					[ModalActionSheet ask:NSLocalizedString(@"You cannot copy on your own folder.", nil)
//							   withCancel:nil 
//						  withDestructive:NSLocalizedString(@"Confirm",nil) 
//							  withButtons: nil
//									where:g_appDelegate.rootViewController.tabBar
//					 ];
				
//					break;
				}
				
				int index = -1;
				
				if (allYes == YES 
				   || [self fileExistsAtPath:fileName] == NO
					|| (index = [g_appDelegate checkOverwrite:fileName allYes:YES]) > -1) 
				{
					if (index == 3)
						break;
					else if (index == 2)
						continue;
					else if (index == 1)
						allYes = YES;
					
					NSString *dstPath = [currentFolder stringByAppendingPathComponent:fileName];
					
					// 파일이 있으면 삭제한다.
					if ([g_FileUtil isExist:dstPath])
					{
						for (int i=0; i<[m_fileInfoArray count]; i++)
						{
							CFileInfo	*fileInfo = [m_fileInfoArray objectAtIndex:i];
							
							if ([fileInfo.m_strName isEqualToString:[dstPath lastPathComponent]])
							{
								if ([g_FileUtil deleteFile:dstPath])
									[self removeItem:i];
							}
						}
					}

					if (g_appDelegate.pasteStatus == COPY)
					{
						if ([self copyFile:filePath toPath:dstPath])
						{
							CFileInfo	*fileInfo = [g_FileUtil getFileInfo:dstPath];
							[self addToCellData:fileInfo];
							m_addCount++;
						}
					}
					// CUT
					else
					{
						if ([self moveFile:filePath toPath:[currentFolder stringByAppendingPathComponent:fileName]])
						{
							CFileInfo	*fileInfo = [g_FileUtil getFileInfo:dstPath];
							[self addToCellData:fileInfo];
							m_addCount++;
						}
					}
				}
			}
		}	
	}
	
	[self renderCopyCutPasteButton:@"onPaste"];
	
	g_appDelegate.pasteStatus = NO;
	g_appDelegate.isRecursive = 0;
	
 	[self clearSelectedButton];
	[self clearSelectedIndexPath];
	
	[table reloadData];

	// 중복되지 않은 파일만큼 하이라이트 처리한다.
	if (m_addCount > 0)
		[self select:m_addCount];
}

-(void) onCopy
{
	[super onCopy];
 	
	CentralECMAppDelegate *appDelegate = (CentralECMAppDelegate *)[[UIApplication sharedApplication] delegate];
	appDelegate.sourceType = CART;
}

-(void) onCut
{
	[super onCut];
 	
	CentralECMAppDelegate *appDelegate = (CentralECMAppDelegate *)[[UIApplication sharedApplication] delegate];
	appDelegate.sourceType = CART;
	appDelegate.sourceClientViewController = self;
}

// 폴더생성시 기본값을 폴더이고 중복되면 폴더1,2,3... 이렇게 추가된다. 
-(void) onCreateFolder 
{
 	if ([self  isRenaming])
		return;
 	
	NSFileManager *fileMgr = [NSFileManager defaultManager];
	NSString *folderName=NSLocalizedString(@"Folder",nil);
	
	int count=1;
	
	while (YES)
	{
		if ([fileMgr fileExistsAtPath:[currentFolder stringByAppendingPathComponent:folderName]])
			folderName = [NSString stringWithFormat: NSLocalizedString(@"Folder%d",nil), count++];
		else
			break;
	}
	
	[fileMgr createDirectoryAtPath:[currentFolder stringByAppendingPathComponent:folderName] withIntermediateDirectories:YES attributes:nil error:nil];
	
	// 데이타를 추가하고 화면을 갱신한다.
	CFileInfo	* fileInfo = [CFileInfo alloc];
	fileInfo.m_strName = [NSMutableString stringWithString:folderName];
	
	[self addToCellData:fileInfo];

	[table reloadData];
	
	// 맨아래 추가되고 스크롤을 위로 올린다.
	[table scrollToRowAtIndexPath:[NSIndexPath indexPathForRow:2 inSection:1] 
						  atScrollPosition:UITableViewScrollPositionTop
								  animated:NO
	 ];
	
	[self select:1];
	
	[m_selectedInfoArray replaceObjectAtIndex: [m_selectedInfoArray count] -1 withObject:[NSNumber numberWithBool:YES]];
	UITableViewCell *cell =[table  cellForRowAtIndexPath:[NSIndexPath indexPathForRow:(m_fileInfoArray.count-1) inSection:0] ];
	UIButton *button = (UIButton  *)[cell.contentView viewWithTag:kCellButtonTag];
	[button setBackgroundImage:selectedImage forState:UIControlStateNormal];
	[button setBackgroundImage:selectedImage  forState:UIControlStateHighlighted];

	// rename과 동일한 로직을 탄다.
 	[self onRename];
 	[self performSelector:@selector(focusAfterDelay:) withObject:[NSNumber numberWithInt:([m_selectedInfoArray count] -1 )] afterDelay:0.5f];  
}

#pragma mark -
#pragma mark event handler

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
	if (indexPath.section == 1)
		return;
	
 	if ([self isRenaming])
	{
		[table deselectRowAtIndexPath:indexPath animated:YES];
		return;
	}
	
	if (m_bGetFile)
	{
		[tableView deselectRowAtIndexPath:indexPath animated:YES];
		return;
	}
	
	NSUInteger row = [indexPath row];
 	CentralECMAppDelegate *appDelegate = (CentralECMAppDelegate *)[[UIApplication sharedApplication] delegate];
	
	// if dir, show the disclosure indicator
	if ([self isFolder:row]) 	
	{
		// copy, cut후 자기, 자기 자식으로 이동하는 경우 recursive설정을 하여 paste시 문제가 없게한다.
		if ([self isSelectedIndexPath:row] && 
			(appDelegate.pasteStatus == COPY || appDelegate.pasteStatus == CUT) )
		{
			appDelegate.isRecursive =self.folderDepth;
			//NSLog(@"isrecursive");
		}
		
		[self pushFolder:row];
 	}
	else
	{
 		NSString *ext = [[self getFileName:m_fileInfoArray row:row] pathExtension];
		NSDictionary *imageDic = [NSDictionary dictionaryWithObjectsAndKeys:
								 @"", @"png", @"", @"jpg", @"", @"gif", 
								 nil];
		m_filePath = [[NSString alloc] initWithString:[self getFilePath:m_fileInfoArray row:row]];
		
		NSLog(@"didSelectRowAtIndexPath: %@", m_filePath);

		appDelegate.isRotate = YES;
		m_bRefresh = false;
		
//		if ([imageDic objectForKey:[ext lowercaseString]] == nil)
//		{
//			WebThree20ViewController *controller = [[WebThree20ViewController alloc] init];
// 	 		controller.title = [self getFileName:m_fileInfoArray row:row];
// 			UIBarButtonItem *barItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemSave target:self action:@selector(onSave:)];
//			barItem.tag = row;
//			[barItem release];
//			controller.docUrl = [NSURL fileURLWithPath:m_filePath];
//			
//			[appDelegate.navClientController pushViewController:controller animated:YES];
//			[controller release];
//		}
//		else
//		{
//			int	index = [self createSourceImage:row]-1;
//			PhotoViewController *p = [[ PhotoViewController alloc] init];
//			p.m_nPhotoIndex = index;
//			
//	  		[appDelegate.navClientController pushViewController:p animated:YES];
//	 		[p release];
//		}
	}
	
	m_selectedIndexPath = indexPath;
}

- (void)imagePickerController:(UIImagePickerController *)picker 
didFinishPickingMediaWithInfo:(NSDictionary *)info
{
	[picker dismissModalViewControllerAnimated:YES];

	NSString *mediaType = [info objectForKey:UIImagePickerControllerMediaType];
	
	// 파일 이름 생성
	NSDateFormatter	*dateFormat = [[NSDateFormatter alloc] init];
	[dateFormat setDateFormat:@"yyyyMMddHHmmss"];
	NSString *fileName = [dateFormat stringFromDate:[NSDate date]];
	NSString *filePath = nil;

	if ([mediaType isEqualToString:@"public.image"])
	{
		UIImage	*image = [info objectForKey:@"UIImagePickerControllerOriginalImage"];
		filePath = [fileName stringByAppendingString:@".jpg"];
		NSString *imagePath = [currentFolder stringByAppendingPathComponent:filePath];
 
		// 이미지를 보정한다.
		// 이미지를 그대로 읽은후 저장해서 image.imageOrientation=>UIImageOrientationUp로 강제로 수정한다.
		CGRect rect = CGRectMake(0.0, 0.0, image.size.width, image.size.height);
		UIGraphicsBeginImageContext(rect.size);
		[image drawInRect:rect];
		NSData *imageData = UIImageJPEGRepresentation(UIGraphicsGetImageFromCurrentImageContext(), 0.5);
		UIGraphicsEndImageContext();  
		
		[imageData writeToFile:imagePath atomically:YES];
	}
	else if ([mediaType isEqualToString:@"public.movie"])
	{
		NSURL *videoURL = [info objectForKey:UIImagePickerControllerMediaURL];
		NSData *webData = [NSData dataWithContentsOfURL:videoURL];
		
		filePath = [fileName stringByAppendingString:@".mov"];
		NSString *videoPath = [currentFolder stringByAppendingPathComponent:filePath];
		[webData writeToFile:videoPath atomically:YES];
	}

	if (filePath)
	{
		CFileInfo * fileInfo = [CFileInfo alloc];
		fileInfo.m_strName = [NSMutableString stringWithString:filePath];
		
		[self addToCellData:fileInfo];
	}
	
	m_bRefresh = false;
	
 	[table reloadData];
	[self select:1];
}
 
#pragma mark -
#pragma mark common

-(void) cancel
{
	UIAlertView	*av = [[[UIAlertView alloc] initWithTitle:nil message:NSLocalizedString(@"Canceled", nil) delegate:nil cancelButtonTitle:NSLocalizedString(@"OK",nil) otherButtonTitles:nil] autorelease];
	[av show];
	
	[table deselectRowAtIndexPath:m_selectedIndexPath animated:YES];
	
	m_bCancel = TRUE;
	m_bGetFile = FALSE;
	g_appDelegate.m_bClientTab = TRUE;
}

- (void)viewDidLoad
{
	[super viewDidLoad];
	
	m_fileInfoArray = [ [ NSMutableArray alloc] init ];
 	CentralECMAppDelegate *appDelegate = (CentralECMAppDelegate *)[[UIApplication sharedApplication] delegate];
	appDelegate.targetType = CART;
 
	if (currentFolder == nil)
	{
		NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
		currentFolder = [[NSString alloc] initWithString:[paths objectAtIndex:0]];
		
		for (int i =0;  i < [paths count]; i++)
		{
			NSLog(@"%@", [paths objectAtIndex:i]);
		}
	}
	
	m_bRefresh = true;
	[self refreshListData];
	
	// create a toolbar to have two buttons in the right
	UIToolbar *toolBar = [[UIToolbar alloc] initWithFrame:CGRectMake(0, 0, 42, 44.01)];

#ifdef KDISK
	toolBar.tintColor = [UIColor colorWithRed:153.0/255.0 green:51.0/255.0 blue:153.0/255.0 alpha:1];
	toolBar.backgroundColor = [UIColor colorWithRed:153.0/255.0 green:51.0/255.0 blue:153.0/255.0 alpha:1];
#endif
	
	// create the array to hold the buttons, which then gets added to the toolbar
	NSMutableArray * buttons = [[NSMutableArray alloc] initWithCapacity:2];
	
	// create a standard "camera" button
	UIBarButtonItem	* cameraButton = [[UIBarButtonItem alloc]
									  initWithBarButtonSystemItem:UIBarButtonSystemItemCamera target:self action:@selector(photoClicked)];
	cameraButton.style = UIBarButtonItemStylePlain;
	[buttons addObject:cameraButton];
	[cameraButton release];
	
	// stick the buttons in the toolbar
	[toolBar setItems:buttons animated:NO];
	[buttons release];
	
	UIBarButtonItem * buttonItem = [[UIBarButtonItem alloc] initWithCustomView:toolBar];
	[toolBar release];
	
	// and put the toolbar in the nav bar
	self.navigationItem.rightBarButtonItem = buttonItem;
}

// 보여질떄 마다 파일을 읽고 화면을 refresh하는 일을 수행한다.
- (void)viewWillAppear:(BOOL)animated
{
	[super viewWillAppear:animated];
	
	g_appDelegate.targetType = CART;
	
	// 포토 뷰나 파일 뷰에서 돌아올 때는 리프레쉬 하지 않는다.
	// 리프레쉬하면 파일 리스트가 알파벳 순으로 변동된다.
	if (m_bRefresh)
		[self refreshData];
	
	m_bRefresh = true;
	
	[self renderCopyCutPasteButton:@"viewDidAppear"];
}

// 사라질 때는 모든값을 초기화 한다.
- (void)viewWillDisappear:(BOOL)animated
{
	[super viewWillDisappear:animated];
	
	[self clearSelectedIndexPath];
	[self clearSelectedButton];
	[self clearSelectedTextField];
	[self clearRenameButton];
}

- (void)didReceiveMemoryWarning {
	// Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
	
	// Release any cached data, images, etc that aren't in use.
}

- (void)viewDidUnload {
	// Release any retained subviews of the main view.
	// e.g. self.myOutlet = nil;
}

- (void)dealloc {
    [super dealloc];
}

@end

