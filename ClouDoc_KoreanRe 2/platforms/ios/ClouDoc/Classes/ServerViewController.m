//
//  ServerViewController.m
//  CentralECM
//
//  Created by HeungKyoo Han on 10. 04. 18.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import "ServerCmd.h"
#import "ServerViewController.h"
#import "ClientViewController.h"
#import "CentralECMAppDelegate.h"
//#import "PhotoViewController.h"
//#import "WebThree20ViewController.h"
#import "FileUtil.h"
#import "ActivityViewController.h"
#import "TabBarController.h"


//extern CDriveInfo			g_driveInfo[3];
extern FileUtil				*g_FileUtil;
extern NSMutableArray		*g_ShareFolderList;
extern UIProgressView		*g_progressView;
extern NSString				*g_dtLastWriteTime;
extern int					g_dwACL;

// Copy/Cut을 한 드라이브
NSUInteger	g_nSourceDrive;
// Copy 또는 Move의 경우 여러개의 파일을 사용할 수 있다.
// Copy 나 Move가 완료되었는지에 대한 플래그이다.
BOOL		g_bFileOpEnd;
// 현재 복사/이동 중인 파일 정보
CFileInfo	*g_fileInfo;

@implementation ServerViewController

#pragma mark -
#pragma mark Utility Functions

// m_fileInfoArray에 fileName이 있는지 찾는다.
- (int) findFileInfo: (NSString *) fileName
{
	int	i;
	
	for (i=0; i<[m_fileInfoArray count]; i++)
	{
		CFileInfo	*fileInfo = [m_fileInfoArray objectAtIndex:i];
		
		if ([fileInfo.m_strName isEqualToString: fileName])
			break;
	}
	
	if (i == [m_fileInfoArray count])
		return -1;
	else
		return i;
}

#pragma mark -
#pragma mark overide methods

// 현재 row가 휴지통인지 폴더의 이름을 보고 판단한다.
- (BOOL) isRecycler: (NSInteger) row
{
	CFileInfo	* fileInfo = [m_fileInfoArray objectAtIndex:row];
	NSString *fileName = [currentFolder stringByAppendingPathComponent:fileInfo.m_strName];
	
	if ([fileName isEqualToString:@"/RECYCLER"])
		return true;
	else
		return false;
}

// 현재 row가 폴더인지 판단한다.
- (BOOL) isFolder:(NSInteger) row
{
	CFileInfo * fileInfo = [m_fileInfoArray objectAtIndex:row];

	// if dir, show the disclosure indicator
	return (fileInfo.m_dwAttrib & FA_FOLDER);
}	

// 폴더 또는 파일의 이름을 변경한다.
// 폴더를 테이블 뷰에서 생성한 후에도 이 함수를 호출하기 때문에 m_nCmdType으로 구분하여 서버로 커맨드를 보낸다. 
- (BOOL) renameFile:(NSString *)srcPath 
			toPath:(NSString *)dstPath
{
	NSLog(@"srcPath: %@, dstPath: %@", srcPath, dstPath);
	
	ServerCmd	*serverCmd = [[ServerCmd alloc] init];

	// 폴더 생성시 가상의 폴더 생성 후 이름을 수정하는 UI를 갖게 된다. 
	if (m_nCmdType == ST_CREATE_DIR)
	{
		CFileInfo * fileInfo = [m_fileInfoArray lastObject];
		fileInfo.m_strName = [NSString stringWithString: [dstPath lastPathComponent]];
		[serverCmd CreateDir:m_nSelectedDrive srcName:dstPath fileInfo:[self getShareFolder] sharePath:[self getSharePath] sender:self selector:@selector(didFinishCreateDir:fileInfo:)];
	}
	else
	{
		if ([srcPath isEqualToString:dstPath])
			return true;
		
		[serverCmd RenameFile:m_nSelectedDrive srcName:srcPath dstName:dstPath fileInfo:[self getShareFolder] sharePath:[self getSharePath] sender:self selector:@selector(didFinishRenameFile:)];
	}
	
	return true;
}

// 폴더 또는 파일을 삭제한다. 휴지통의 경우 휴지통을 비운다. 사용자가 Delete 버튼을 클릭하면 호출된다.
-(BOOL) deleteFile:(NSInteger) row
{
	// 휴지통 비우기
	if ([self isRecycler:row])
	{
		ServerCmd	*serverCmd = [[ServerCmd alloc] init];
		[serverCmd EmptyRecycled:m_nSelectedDrive sender:self selector:@selector(didFinishEmptyRecycled:)];
		return true;
	}
	// 폴더/파일 삭제
	else
	{
		CFileInfo *fileInfo = [m_fileInfoArray objectAtIndex:row];
		
		if (fileInfo.m_dwACL & ACL_DELETEFILE)
		{
			NSString *fileName = [currentFolder stringByAppendingPathComponent:fileInfo.m_strName];
			
			ServerCmd	*serverCmd = [[ServerCmd alloc] init];
			m_bFinished = NO;
			
			[serverCmd DeleteFile: m_nSelectedDrive 
						 fileName: fileName 
						 fileInfo: [self getShareFolder] 
						sharePath: [self getSharePath] 
						   sender: self 
						 selector: @selector(didFinishDeleteFile:filePath:)];
			
			while (!m_bFinished && !m_bCancel)
				[[NSRunLoop currentRunLoop] runMode:NSDefaultRunLoopMode beforeDate:[NSDate distantFuture]];
			
			return true;
		}
		else
		{
			UIAlertView	*av = [[[UIAlertView alloc] initWithTitle:nil message:NSLocalizedString(@"Access Denied",nil) delegate:nil cancelButtonTitle:NSLocalizedString(@"Confirm",nil) otherButtonTitles:nil] autorelease];
			[av show];
			return false;
		}
	}
}

// 폴더 목록을 리프레쉬한다. 상단 오른쪽의 리프레쉬 버튼을 클릭하면 호출된다.
- (void) refreshClicked
{
	ServerCmd	*serverCmd = [[ServerCmd alloc] init];
	
	[serverCmd GetList: m_nSelectedDrive 
			folderName: currentFolder 
			  fileInfo: [self getShareFolder] 
			 sharePath: [self getSharePath] 
		     recursive: NO 
				sender: self 
			  selector: @selector(didFinishRefresh:fileInfoArray:)];
}

// 폴더 / 휴지통 / 파일 순으로 정렬한다.
- (void) refreshData
{
	[m_selectedInfoArray removeAllObjects];

	NSMutableArray * fileArray = [[NSMutableArray alloc] initWithCapacity:[m_fileInfoArray count]];

	// add folders
	for (int i=0; i<[m_fileInfoArray count]; i++)
	{
		CFileInfo * fileInfo = [m_fileInfoArray objectAtIndex:i];
		
		if (fileInfo.m_dwAttrib & FA_FOLDER && ![fileInfo.m_strName isEqualToString:@"RECYCLER"])
		{
			NSLog(@"folder: %@", fileInfo.m_strName);
			[fileArray addObject:fileInfo];
			[m_selectedInfoArray addObject:[NSNumber numberWithBool:NO]];
		}
	}
	
	// add Recycler
	for (int i=0; i<[m_fileInfoArray count]; i++)
	{
		CFileInfo * fileInfo = [m_fileInfoArray objectAtIndex:i];
		
		if (fileInfo.m_dwAttrib & FA_FOLDER && [fileInfo.m_strName isEqualToString:@"RECYCLER"])
		{
			NSLog(@"recycler: %@", fileInfo.m_strName);
			[fileArray addObject:fileInfo];
			[m_selectedInfoArray addObject:[NSNumber numberWithBool:NO]];
		}
	}
	
	// add files
	for (int i=0; i<[m_fileInfoArray count]; i++)
	{
		CFileInfo * fileInfo = [m_fileInfoArray objectAtIndex:i];
		
		if (!(fileInfo.m_dwAttrib & FA_FOLDER))
		{
			NSLog(@"file: %@", fileInfo.m_strName);
			[fileArray addObject:fileInfo];
			[m_selectedInfoArray addObject:[NSNumber numberWithBool:NO]];
		}
	}
	
	[m_fileInfoArray release];
	m_fileInfoArray = fileArray;
}

#pragma mark -
#pragma mark overide event handler

- (void) onRename
{
	// 휴지통이면 복원한다.
	if ([currentFolder length] >= 9 && [[currentFolder substringToIndex:9] isEqualToString:@"/RECYCLER"])
	{
		ServerCmd	*serverCmd = [[ServerCmd alloc] init];
		
		for (int i=0; i<m_selectedInfoArray.count; i++)
		{   
			BOOL	selected = [[m_selectedInfoArray objectAtIndex:i] boolValue];

			if (selected)
			{
				CFileInfo	*fileInfo = (CFileInfo *)[m_fileInfoArray objectAtIndex:i];
				NSString	*srcPath = [currentFolder stringByAppendingPathComponent:fileInfo.m_strName];
				NSString	*errmsg;
					
				if (![serverCmd RestoreFile:m_nSelectedDrive srcName:srcPath sender: self errmsg:&errmsg])
				{
					UIAlertView	*av = [[[UIAlertView alloc] initWithTitle:nil message:NSLocalizedString(errmsg, nil) delegate:nil cancelButtonTitle:NSLocalizedString(@"OK",nil) otherButtonTitles:nil] autorelease];
					[av show];
				}
			}
		}
		
		[self clearSelectedButton];
		[self clearSelectedIndexPath];
		
		// 상단 툴바 처리
		[self renderCopyCutPasteButton:@"onPaste"];
		[self refreshClicked];
	}
	// 이름을 수정한다.
	else
		[super onRename];
}

- (void) onSave: (id) sender
{
	NSLog(@"filePath is1 %@", m_filePath);

	NSString * dstPath = [[NSString alloc] initWithFormat:@"%@/%@", [g_FileUtil getDocumentFolder], [m_filePath lastPathComponent]];
	
	NSString * errmsg;

	if ([g_FileUtil copyFile:m_filePath dstPath:dstPath])
		errmsg = NSLocalizedString(@"file saved", nil);
	else
		errmsg = NSLocalizedString(@"file save failed", nil);
	
	UIAlertView	*av = [[[UIAlertView alloc] initWithTitle:nil message:NSLocalizedString(errmsg, nil) delegate:nil cancelButtonTitle:NSLocalizedString(@"OK",nil) otherButtonTitles:nil] autorelease];
	[av show];
}

// Copy 버튼 터치했을 때
- (IBAction) onCopy
{
	[super onCopy];
	
 	CentralECMAppDelegate *appDelegate = (CentralECMAppDelegate *)[[UIApplication sharedApplication] delegate];
	appDelegate.sourceType = SERVER ;
	appDelegate.sourceServerViewController = self;
	
	g_nSourceDrive = m_nSelectedDrive;
}

// Cut 버튼 터치했을 때
- (IBAction) onCut
{
	[super onCut];
 	
	CentralECMAppDelegate *appDelegate = (CentralECMAppDelegate *)[[UIApplication sharedApplication] delegate];
	appDelegate.sourceType = SERVER ;
	appDelegate.sourceServerViewController = self;

	g_nSourceDrive = m_nSelectedDrive;
}

// Paset 버튼 터치했을 때
- (IBAction) onPaste
{
	if (g_appDelegate.pasteStatus == RENAMES)
	{
		g_appDelegate.pasteStatus = CANCEL;
		[self onRename];
		return;
	}
 	
	m_bGetFile = TRUE;
	g_appDelegate.m_bServerTab = FALSE;

	NSString	*fileName;
	NSString	*srcPath;
	
	g_bFileOpEnd = FALSE;

	// 복사/이동한 파일의 수
	m_addCount = 0;
	// HTTP Request Cancel 플래그
	m_bCancel = NO;
	
	BOOL	allYes = NO;
	BOOL	b3G = NO;
	m_bCancel = NO;
	m_bError = NO;
	
	ServerCmd	*serverCmd = [[ServerCmd alloc] init];

	// client to server의 경우 폴더를 파일 리스트로 바꾼다.
	if (g_appDelegate.sourceType == CART)
	{
		NSMutableArray *sourceData = [[NSMutableArray alloc] initWithArray:g_appDelegate.sourceData];
		[g_appDelegate.sourceData removeAllObjects];
		NSFileManager *fileMgr = [NSFileManager defaultManager];
		NSString *filename;
		
		for (int i=0; i<sourceData.count; i++)
		{
			CFileInfo *fileInfo = (CFileInfo *)[sourceData objectAtIndex:i];
			
			srcPath = [g_appDelegate.sourceFolder stringByAppendingPathComponent:fileInfo.m_strName];
			
			if ([g_FileUtil isFolder: srcPath])
			{
				NSDirectoryEnumerator *dirEnum = [fileMgr enumeratorAtPath:srcPath];
				int	cnt = 0;
			
				while (filename = [dirEnum nextObject])
				{
					filename = [g_FileUtil getFilename:filename];

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
	}

	[m_folderInfoArray removeAllObjects];
	
	for (int i=0; i<g_appDelegate.sourceData.count; i++)
	{
		g_fileInfo = (CFileInfo *)[g_appDelegate.sourceData objectAtIndex:i];
		fileName = g_fileInfo.m_strName;
		
		srcPath = [g_appDelegate.sourceFolder stringByAppendingPathComponent:fileName];

		// Server to Server
		if (g_appDelegate.sourceType == SERVER)
		{
			m_bFinished = NO;

			NSString	*errmsg;
			NSString	*lastWriteTime;
			
			// 같은 폴더인 경우
			if ([g_appDelegate.sourceFolder localizedCompare:currentFolder ] == 0)
			{
//				[ModalActionSheet ask: NSLocalizedString(@"You cannot copy on your own folder.", nil)
//						   withCancel: nil 
//					  withDestructive: NSLocalizedString(@"Confirm", nil) 
//						  withButtons: nil
//								where: g_appDelegate.rootViewController.tabBar];
				
				m_bCancel = YES;
			}
			// 다른 폴더인 경우
			else
			{
				BOOL bOverwrite = allYes;
				
				while (YES)
				{
					// fileInfo를 ServerCmd.m_fileInfo에 복사한 후 성공하면 파일 생성 시간을 설정한 후 m_fileInfoArray에 추가한다.
					if (g_appDelegate.pasteStatus == COPY)
					{
						if ([serverCmd CopyFile:m_nSelectedDrive srcName:srcPath dstName:currentFolder fileInfo:[self getShareFolder] sharePath:[self getSharePath] overWrite: bOverwrite sender: self lastWriteTime:&lastWriteTime errmsg:&errmsg])
						{
							if (bOverwrite)
							{
								// 테이블 셀 select->deselect 이펙트를 보여주기 위해 m_fileInfoArray에서 fileInfo를 삭제하고 다시 추가한다. 
								for (int i=0; i<[m_fileInfoArray count]; i++)
								{
									CFileInfo	*fileInfo = [m_fileInfoArray objectAtIndex:i];
									
									if ([fileInfo.m_strName isEqualToString:fileName])
										[self removeItem:i];
								}
							}
							
							CFileInfo	*fileInfo = [[CFileInfo alloc] initWithCFileInfo:g_fileInfo];
							fileInfo.m_dtLastWriteTime = [NSString stringWithString:lastWriteTime];
							[self addToCellData:fileInfo];
							m_addCount++;
							break;
						}
						else
						{
							// 파일이 이미 존재하는 경우
							if (!bOverwrite && [errmsg length] >= 7 && [[errmsg substringToIndex:7] isEqualToString:@"Already"])
							{
								int index = [g_appDelegate checkOverwrite:fileName allYes:YES];
							
								// cancel
								if (index == 3)
									m_bCancel = YES;
								// all yes
								else if (index == 1)
									allYes = bOverwrite = YES;
								// yes
								else if (index == 0)
									bOverwrite = YES;
								
								if (bOverwrite)
									continue;
							}
							else
							{
								UIAlertView	*av = [[[UIAlertView alloc] initWithTitle:nil message:NSLocalizedString(errmsg, nil) delegate:nil cancelButtonTitle:NSLocalizedString(@"OK",nil) otherButtonTitles:nil] autorelease];
								[av show];
							}

							break;
						}
					}
					// CUT
					else
					{
						if ([serverCmd MoveFile: m_nSelectedDrive 
										srcName: srcPath 
										dstName: currentFolder 
									   fileInfo: [self getShareFolder] 
									  sharePath: [self getSharePath] 
									  overWrite: bOverwrite 
										 sender: self 
								  lastWriteTime: &lastWriteTime 
										 errmsg: &errmsg])
						{
							if (bOverwrite)
							{
								// 테이블 셀 select->deselect 이펙트를 보여주기 위해 m_fileInfoArray에서 fileInfo를 삭제하고 다시 추가한다. 
								for (int i=0; i<[m_fileInfoArray count]; i++)
								{
									CFileInfo	*fileInfo = [m_fileInfoArray objectAtIndex:i];
									
									if ([fileInfo.m_strName isEqualToString:fileName])
										[self removeItem:i];
								}
							}

							CFileInfo	*fileInfo = [[CFileInfo alloc] initWithCFileInfo:g_fileInfo];
							fileInfo.m_dtLastWriteTime = [NSString stringWithString:lastWriteTime];
							[self addToCellData:fileInfo];
							m_addCount++;
							
							// 이동의 경우 파일 리스트에서 파일 정보를 삭제한다.
							if (g_appDelegate.sourceType == SERVER && g_appDelegate.pasteStatus == CUT)
							{
								ServerViewController *controller = (ServerViewController *)g_appDelegate.sourceServerViewController;
								NSMutableArray *fileInfoArray = (NSMutableArray *)controller.m_fileInfoArray;
								
								for (int i=0; i<[fileInfoArray count]; i++)
								{
									CFileInfo	*fileInfo2 = [fileInfoArray objectAtIndex:i];
									
									if ([fileInfo.m_strName isEqualToString:fileInfo2.m_strName])
									{
										[controller removeItem:i];
									}
								}
								
								[controller.table reloadData];
							}
							
							break;
						}
						else
						{
							// 파일이 이미 존재하는 경우
							if (!bOverwrite && [errmsg length] >= 7 && [[errmsg substringToIndex:7] isEqualToString:@"Already"])
							{
								int index = [g_appDelegate checkOverwrite:fileName allYes:YES];
								
								// cancel
								if (index == 3)
									m_bCancel = YES;
								// all yes
								else if (index == 1)
									allYes = bOverwrite = YES;
								// yes
								else if (index == 0)
									bOverwrite = YES;
								
								if (bOverwrite)
									continue;
							}
							else
							{
								UIAlertView	*av = [[[UIAlertView alloc] initWithTitle:nil message:NSLocalizedString(errmsg, nil) delegate:nil cancelButtonTitle:NSLocalizedString(@"OK",nil) otherButtonTitles:nil] autorelease];
								[av show];
							}
							
							break;
						}
					}
				}
			}
		}
		// Client to Server upload
		else
		{
			// 폴더이면 폴더를 만든다.
			if ([g_FileUtil isFolder: srcPath])
			{
				m_bFinished = NO;
				g_fileInfo.m_dwAttrib |= FA_FOLDER;
				
				[serverCmd CreateDir: m_nSelectedDrive 
							 srcName: [currentFolder stringByAppendingPathComponent:fileName] 
							fileInfo: [self getShareFolder] 
						   sharePath: [self getSharePath] 
							  sender: self 
							selector: @selector(didFinishCreateDir:fileInfo:)];
			}
			else
			{
				NSString	*errmsg = nil;
				NSInteger	filesize = 0;
				
				if (![serverCmd PutFileCheck: m_nSelectedDrive 
									 srcName: [currentFolder stringByAppendingPathComponent: fileName] 
									 srcPath: srcPath 
									fileInfo: [self getShareFolder] 
								   sharePath: [self getSharePath] 
									  sender: self
									  errmsg: &errmsg 
									filesize: &filesize])
				{
					UIAlertView	*av = [[[UIAlertView alloc] initWithTitle:nil message:NSLocalizedString(errmsg, nil) delegate:nil cancelButtonTitle:NSLocalizedString(@"OK", nil) otherButtonTitles:nil] autorelease];
					[av show];
					m_bError = YES;
				}
				
				if (filesize != -1 && allYes == NO)
				{
					int index = [g_appDelegate checkOverwrite:fileName allYes:YES];
					
					// cancel
					if (index == 3)
						break;
					// no
					else if (index == 2)
						continue;
					// all yes
					else if (index == 1)
						allYes = YES;
				}

				if (!b3G)
				{
					if ([g_appDelegate check3G:UPLOAD])
						b3G = YES;
					else
						break;
				}
				
				m_bFinished = NO;

				// 파일을 업로드한다.
				[serverCmd PutFile: m_nSelectedDrive
						   srcName: [currentFolder stringByAppendingPathComponent: fileName] 
						   srcPath: srcPath			 
						  fileInfo: [self getShareFolder] 
						 sharePath: [self getSharePath] 
							  view: g_appDelegate.navServerController.view
							 order: (i+1) 
						 totalfile: g_appDelegate.sourceData.count
							sender: self 
						  selector: @selector(didFinishPutFile:fileInfo:)];
			}
			
			while (!m_bFinished && !m_bCancel)
				[[NSRunLoop currentRunLoop] runMode:NSDefaultRunLoopMode beforeDate:[NSDate distantFuture]];
		}

		// HTTP Request cancel
		if (m_bCancel)
			break;
	}
	
	// client 에서 cut/paste한 경우
	// 1. client에서 해당 파일을 삭제
	// 2. 클라이언트 테이블 뷰의 m_fileInfoArray에서 해당 파일을 삭제
	// 3. 클라이언트 테이블 뷰 리로드
	if (!m_bError && g_appDelegate.sourceType == CART && g_appDelegate.pasteStatus == CUT)
	{	
		ClientViewController *controller = (ClientViewController *)g_appDelegate.sourceClientViewController;
		NSMutableArray *fileInfoArray = (NSMutableArray *)controller.m_fileInfoArray;
		
		for (int i=g_appDelegate.sourceData.count-1; i>=0; i--)
		{
			CFileInfo *fileInfo = (CFileInfo *)[g_appDelegate.sourceData objectAtIndex:i];
			
			for (int i=0; i<[fileInfoArray count]; i++)
			{
				CFileInfo	*fileInfo2 = [fileInfoArray objectAtIndex:i];
				
				if ([fileInfo.m_strName isEqualToString:fileInfo2.m_strName])
				{
					if ([g_FileUtil deleteFile:[controller.currentFolder stringByAppendingPathComponent:fileInfo.m_strName]])
					{
						[controller removeItem:i];
					}
				}
			}
//			[controller.table reloadData];
		}
	}
	
	g_appDelegate.pasteStatus = NO;
	g_appDelegate.isRecursive = 0;
	
	[self clearSelectedButton];
	[self clearSelectedIndexPath];

	[table reloadData];
	
	// 중복되지 않은 파일만큼 하이라이트 처리한다.
	if (m_addCount > 0)
		[self select:m_addCount];
	
	// 상단 툴바 처리
	[self renderCopyCutPasteButton:@"onPaste"];

	m_bGetFile = FALSE;
	g_appDelegate.m_bServerTab = TRUE;
}

// 폴더 생성 버튼을 클릭하면 호출된다.
// 먼저 테이블 뷰에 더미 폴더를 생성한 후 사용자는 rename을 하게 한다.
// rename이 완료되면 renameFile 이 호출된다.
- (void) onCreateFolder
{
 	if ([self  isRenaming])
		return;

	[self clearSelectedButton];
	[self clearSelectedIndexPath];

	NSString * folderName = NSLocalizedString(@"Folder", nil);
	
	int count = 1;
	int	i = 0;
	
	while (YES)
	{
		for (i=0; i<[m_fileInfoArray count]; i++)
		{
			CFileInfo *fileInfo = [m_fileInfoArray objectAtIndex:i];
			
			if ([fileInfo.m_strName isEqualToString:folderName])
			{
				folderName = [NSString stringWithFormat: NSLocalizedString(@"Folder%d", nil), count++];
				break;
			}
		}
		
		if (i == [m_fileInfoArray count])
			break;
	}

	// 더미 파일을 만든다.
	CFileInfo	* fileInfo = [CFileInfo new];
	fileInfo.m_strName = [[NSString alloc] initWithString:folderName];
	fileInfo.m_dwAttrib = FA_FOLDER;
	[self addToCellData:fileInfo];

	[table reloadData];

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
 	[self onRename];
 	[self performSelector:@selector(focusAfterDelay:) withObject:[NSNumber numberWithInt:([m_selectedInfoArray count] -1 )] afterDelay:0.5f];  

	m_nCmdType = ST_CREATE_DIR;
}

- (void) renderCopyCutPasteButton: (NSString *) which
{
	[super renderCopyCutPasteButton: which];
	
	if (g_appDelegate.sourceType == SERVER && g_appDelegate.targetType == SERVER)
	{
		// 드라이브가 다르면 복사나 이동을 할 수 없다.
		if (g_nSourceDrive != m_nSelectedDrive)
		{
			pasteBtn.enabled = NO;
		}
		
		// 공유 폴더에서는
		NIDriveInfo *info = [g_appDelegate.m_arrDriveInfo objectAtIndex:m_nSelectedDrive];
		if (info->m_nDiskType == DT_SHARE)
		{
			// 공유 폴더에서는 Paste를 지원하지 않는다.
			pasteBtn.enabled = NO;

			// 폴더 2레벨까지는 사용하지 않는다.
			if (folderDepth <= 2)
			{
				copyBtn.enabled = NO;
				cutBtn.enabled = NO;
				renameBtn.enabled = NO;
				folderBtn.enabled = NO;
			}	
		}
	}
}

// 포토 앨범에서 사진 / 동영상 또는 그림 파일을 선택하면 호출된다.
- (void)imagePickerController:(UIImagePickerController *)picker 
didFinishPickingMediaWithInfo:(NSDictionary *)info
{
	[picker dismissModalViewControllerAnimated:YES];

	NSString *mediaType = [info objectForKey:UIImagePickerControllerMediaType];
	
	// 파일 이름 생성
	NSDateFormatter	*dateFormat = [[NSDateFormatter alloc] init];
	[dateFormat setDateFormat:@"yyyyMMddHHmmss"];
	NSString *fileName = [dateFormat stringFromDate:[NSDate date]];
	NSString *filePath;
	NSString *imagePath;
	
	if ([mediaType isEqualToString:@"public.image"])
	{
		filePath = [fileName stringByAppendingString:@".jpg"];
		imagePath = [NSString stringWithFormat:@"%@/%@", [g_FileUtil getTmpFolder], filePath];
		NSLog(@"imagePickerController: %@", imagePath);
		
		// 이미지를 보정한다.
		// 이미지를 그대로 읽은후 저장해서 image.imageOrientation=>UIImageOrientationUp로 강제로 수정한다.
		UIImage	*image = [info objectForKey:@"UIImagePickerControllerOriginalImage"];
		CGRect rect = CGRectMake(0.0, 0.0, image.size.width, image.size.height);
		UIGraphicsBeginImageContext(rect.size);
		[image drawInRect:rect];
		NSData *imageData = UIImageJPEGRepresentation(UIGraphicsGetImageFromCurrentImageContext(), 0.5);
		UIGraphicsEndImageContext();  
		
		[imageData writeToFile:imagePath atomically:YES];
	}
	else if ([mediaType isEqualToString:@"public.movie"])
	{
		NSURL	*videoURL = [info objectForKey:UIImagePickerControllerMediaURL];
		NSData	*webData = [NSData dataWithContentsOfURL:videoURL];
		
		filePath = [fileName stringByAppendingString:@".mov"];
		imagePath = [NSString stringWithFormat:@"%@/%@", [g_FileUtil getTmpFolder], filePath];
		
		[webData writeToFile:imagePath atomically:YES];
	}

	g_fileInfo = [CFileInfo alloc];
	
	g_fileInfo.m_strName = [NSString stringWithString:filePath];
	g_fileInfo.m_n64Size = [g_FileUtil getLength:imagePath];
	
	m_addCount = 0;
	
	NSString	*errmsg = nil;
	NSInteger	filesize = 0;
	
	ServerCmd	*serverCmd = [[ServerCmd alloc] init];
	if (![serverCmd PutFileCheck: m_nSelectedDrive 
						 srcName: [currentFolder stringByAppendingPathComponent: filePath] 
						 srcPath: imagePath 
						fileInfo: [self getShareFolder] 
					   sharePath: [self getSharePath] 
						  sender: self
						  errmsg: &errmsg 
						filesize: &filesize])
	{
		UIAlertView	*av = [[[UIAlertView alloc] initWithTitle:nil message:NSLocalizedString(errmsg, nil) delegate:nil cancelButtonTitle:NSLocalizedString(@"OK", nil) otherButtonTitles:nil] autorelease];
		[av show];
		return;
	}
	
	if (filesize != -1)
	{
		int index = [g_appDelegate checkOverwrite:filePath allYes:NO];

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
	[serverCmd PutFile: m_nSelectedDrive
			   srcName: [currentFolder stringByAppendingPathComponent: filePath] 
			   srcPath: imagePath
			  fileInfo: [self getShareFolder]
			 sharePath: [self getSharePath] 
				  view: g_appDelegate.navServerController.view 
				 order: 1 
			 totalfile: 1
				sender: self 
			  selector: @selector(didFinishPutFile:fileInfo:)];
	
	while (!m_bFinished && !m_bCancel)
		[[NSRunLoop currentRunLoop] runMode:NSDefaultRunLoopMode beforeDate:[NSDate distantFuture]];

	[table reloadData];
	
	// 중복되지 않은 파일만큼 하이라이트 처리한다.
	if (m_addCount > 0)
		[self select:m_addCount];
}

// 뷰가 로딩된 후 호출된다. 테이블 뷰에 들어갈 목록을 만들고 우측 상단 리프레쉬/카메라 버튼을 만든다.
- (void) viewDidLoad 
{
	[super viewDidLoad];
	
	m_folderInfoArray = [ [ NSMutableArray alloc] init ];

	// 테이블 로우를 두번 이상 선택하는 것을 방지한다.
	m_bGetFile = FALSE;
	// 다운로드 중 서버탭이 루트로 이동하는 것을 방지한다.
	g_appDelegate.m_bServerTab = TRUE;

	CentralECMAppDelegate *appDelegate = (CentralECMAppDelegate *)[[UIApplication sharedApplication] delegate];
	appDelegate.targetType = SERVER;
	
	recyclerImage = [UIImage imageNamed:@"recycler.png"];
	
	if (currentFolder == nil)
	{
		currentFolder = [[NSString alloc] initWithString:@"/"];
	}

	// 왼쪽 컨트롤을 만든다.
	for (int i=0; i<[m_fileInfoArray count]; i++)
		[m_selectedInfoArray addObject:[NSNumber numberWithBool:NO]];
	
	// 폴더, 휴지통, 파일 순으로 나오게 만든다.
	[self refreshData];
	
	NIDriveInfo *info = [g_appDelegate.m_arrDriveInfo objectAtIndex:m_nSelectedDrive];
	
	// 공유 폴더 목록을 저장한다.
	if ( info->m_nDiskType == DT_SHARE && folderDepth == 1)
	{
		if (g_ShareFolderList)
			[g_ShareFolderList release];
		
		g_ShareFolderList = [[NSMutableArray alloc] initWithArray:m_fileInfoArray];
	}
	
	// create a toolbar to have two buttons in the right
	UIToolbar *toolBar = [[UIToolbar alloc] initWithFrame:CGRectMake(0, 0, 70, 44.01)];
	
#ifdef KDISK
	toolBar.tintColor = [UIColor colorWithRed:153.0/255.0 green:51.0/255.0 blue:153.0/255.0 alpha:1];
	toolBar.backgroundColor = [UIColor colorWithRed:153.0/255.0 green:51.0/255.0 blue:153.0/255.0 alpha:1];
#endif
	
	// create the array to hold the buttons, which then gets added to the toolbar
	NSMutableArray *buttons = [[NSMutableArray alloc] initWithCapacity:2];
	
	// create a standard "refresh" button
	UIBarButtonItem	*refreshButton = [[UIBarButtonItem alloc]
									   initWithBarButtonSystemItem:UIBarButtonSystemItemRefresh target:self action:@selector(refreshClicked)];
	refreshButton.style = UIBarButtonItemStylePlain;
	[buttons addObject:refreshButton];
	[refreshButton release];
	
	// create a standard "camera" button
	UIBarButtonItem	*cameraButton = [[UIBarButtonItem alloc]
									  initWithBarButtonSystemItem:UIBarButtonSystemItemCamera target:self action:@selector(photoClicked)];
	cameraButton.style = UIBarButtonItemStylePlain;
	[buttons addObject:cameraButton];
	[cameraButton release];
	
	// stick the buttons in the toolbar
	[toolBar setItems:buttons animated:NO];
	[buttons release];
	
	UIBarButtonItem *buttonItem = [[UIBarButtonItem alloc] initWithCustomView:toolBar];
	[toolBar release];
	
	// and put the toolbar in the nav bar
	self.navigationItem.rightBarButtonItem = buttonItem;
}

// 뷰가 나타날 때 호출된다.
- (void)viewWillAppear:(BOOL)animated
{
	[super viewWillAppear:animated];
	[self renderCopyCutPasteButton:@"viewDidAppear"];
	
	CentralECMAppDelegate *appDelegate = (CentralECMAppDelegate *)[[UIApplication sharedApplication] delegate];
	appDelegate.targetType = SERVER;
	
	NIDriveInfo *info = [g_appDelegate.m_arrDriveInfo objectAtIndex:m_nSelectedDrive];
	
	// 공유 폴더에서는 복사나 이동을 지원하지 않는다.
	if ( info->m_nDiskType == DT_SHARE)
	{
		copyBtn.enabled    = NO;
		cutBtn.enabled     = NO;
		
		// 업로드는 지원한다.
		if (g_appDelegate.sourceType == SERVER || folderDepth <= 2)
			pasteBtn.enabled = NO;
	}
	
	// 휴지통에서는 rename을 recover로 바꾼다.
	if ([currentFolder length] >= 9 && [[currentFolder substringToIndex:9] isEqualToString:@"/RECYCLER"])
		[renameBtn setTitle:NSLocalizedString(@"Recover", nil)];
	else
		[renameBtn setTitle:NSLocalizedString(@"Rename", nil)];
}

// 뷰가 사라지기 전에 호출된다.
- (void)viewWillDisappear:(BOOL)animated
{
	[super viewWillDisappear:animated];

	[self clearSelectedIndexPath];
	[self clearSelectedButton];
	[self clearSelectedTextField];
	[self clearRenameButton];
}

- (void)viewDidDisappear:(BOOL)animated {
	[super viewDidDisappear:animated];
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

#pragma mark -
#pragma mark server command response handler

// 파일 업로드 후 결과 처리
- (void) didFinishPutFile: (NSString *) errmsg 
			   fileInfo: (CFileInfo *) recvFileInfo
{
	if (errmsg)
	{
		UIAlertView	*av = [[[UIAlertView alloc] initWithTitle:nil message:NSLocalizedString(errmsg, nil) delegate:nil cancelButtonTitle:NSLocalizedString(@"OK",nil) otherButtonTitles:nil] autorelease];
		[av show];
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
		
		if (bFound == NO)
		{
			// 같은 이름의 파일이 m_fileInfoArray에 있다면 overwrite인 경우이므로 m_fileInfoArray에서 삭제한다.
			for (int i=0; i<[m_fileInfoArray count]; i++)
			{
				CFileInfo	*fileInfo = [m_fileInfoArray objectAtIndex:i];
				
				if ([g_fileInfo.m_strName isEqualToString:fileInfo.m_strName])
				{
					[self removeItem:i];
					break;
				}
			}
			
			CFileInfo	*fileInfo = [[CFileInfo alloc] initWithCFileInfo:g_fileInfo];
			fileInfo.m_dwACL = recvFileInfo.m_dwACL;
			fileInfo.m_dtLastWriteTime = [NSString stringWithString:recvFileInfo.m_dtLastWriteTime];
			[self addToCellData:fileInfo];

			m_addCount++;
		}
	}

	m_bFinished = YES;
}

-(void) cancel
{
	// UIAlertView	*av = [[[UIAlertView alloc] initWithTitle:nil message:NSLocalizedString(@"Request Canceld.", nil) delegate:nil cancelButtonTitle:NSLocalizedString(@"OK",nil) otherButtonTitles:nil] autorelease];
	// [av show];
	
	[table deselectRowAtIndexPath:m_selectedIndexPath animated:YES];

	m_bCancel = TRUE;
	m_bGetFile = FALSE;
	g_appDelegate.m_bServerTab = TRUE;
}

- (void) didFinishGetImage: (NSString *) errmsg 
				  filePath: (NSString *)filePath
{
	m_bFinished = TRUE;

	if (errmsg)
	{
		UIAlertView	*av = [[[UIAlertView alloc] initWithTitle:nil message:NSLocalizedString(errmsg, nil) delegate:nil cancelButtonTitle:NSLocalizedString(@"OK",nil) otherButtonTitles:nil] autorelease];
		[av show];
	}
}

// 파일 다운로드 후 결과 처리
- (void) didFinishGetFile: (NSString *) errmsg 
				 filePath: (NSString *) filePath
{
	[table deselectRowAtIndexPath:m_selectedIndexPath animated:YES];
	
	if (errmsg)
	{
		UIAlertView	*av = [[[UIAlertView alloc] initWithTitle:nil message:NSLocalizedString(errmsg, nil) delegate:nil cancelButtonTitle:NSLocalizedString(@"OK",nil) otherButtonTitles:nil] autorelease];
		[av show];
	}
	// Success이면 다큐먼트를 본다.
	else
	{
		NSString * ext = [filePath pathExtension];
		NSDictionary * imageDic= [NSDictionary dictionaryWithObjectsAndKeys:
                                @"", @"png", @"", @"jpg", @"", @"gif", 
								 nil];
		m_filePath = [filePath copy];
		m_strFilePath = m_filePath;
		NSLog(@"filePath is2 %@", filePath);
        m_bFinished = TRUE;
		g_appDelegate.isRotate = YES;

//  		if ( [imageDic objectForKey:[ext lowercaseString]] == nil )
//		{
//            WebThree20ViewController *controller = [[WebThree20ViewController alloc] init];
//
//	 		controller.title = [filePath lastPathComponent];
// 			UIBarButtonItem *barItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemSave target:self action:@selector(onSave:)];
//			controller.navigationItem.rightBarButtonItem = barItem;
// 			[barItem release];
//			controller.docUrl = [NSURL fileURLWithPath:filePath];
//			[g_appDelegate.navServerController presentModalViewController:controller animated:YES];
//			//[gl_appDelegate.navServerController pushViewController:controller animated:YES];
//            [controller release];
//		}
	}

	m_bGetFile = FALSE;
	g_appDelegate.m_bServerTab = TRUE;
}

// 폴더 생성 후 ServerCmd에서 호출한다.
- (void) didFinishCreateDir: (NSString *) errmsg 
				   fileInfo: (CFileInfo *) recvFileInfo
{
	if (errmsg == nil)
	{
		// 폴더 생성 버튼을 눌러서 생성한 경우
		if (m_nCmdType == ST_CREATE_DIR)
		{
			CFileInfo *fileInfo = [m_fileInfoArray lastObject];
		
			fileInfo.m_dwACL = recvFileInfo.m_dwACL;
			fileInfo.m_dtLastWriteTime = [NSString stringWithString:recvFileInfo.m_dtLastWriteTime];
		}
		// 파일을 업로드하다가 생성한 경우
		else
		{
			NSLog(@"didFinishCreateDir:%@", g_fileInfo.m_strName);
			NSRange range = [g_fileInfo.m_strName rangeOfString:@"/"];
			
			// "/"가 있는 경우는 하위 폴더이다. 이때는 테이블 셀에 추가하면 안된다.
			if (range.location == NSNotFound)
			{
				CFileInfo	*fileInfo = [[CFileInfo alloc] initWithCFileInfo:g_fileInfo];
				fileInfo.m_dwACL = recvFileInfo.m_dwACL;
				fileInfo.m_dtLastWriteTime = [NSString stringWithString:recvFileInfo.m_dtLastWriteTime];
				[self addToCellData:fileInfo];
				
				m_addCount++;
			}
		}
	}
	else
	{
		// 실패하면 가상으로 생성한 폴더를 삭제해야 한다.
		// 업로드할 때는 가상으로 폴더를 만들지 않았기 때문에 삭제하면 안된다.
		if (m_nCmdType == ST_CREATE_DIR)
		{
			UIAlertView	*av = [[[UIAlertView alloc] initWithTitle:nil message:NSLocalizedString(errmsg, nil) delegate:nil cancelButtonTitle:NSLocalizedString(@"OK",nil) otherButtonTitles:nil] autorelease];
			[av show];
			
			[m_fileInfoArray removeLastObject];
			[m_selectedInfoArray removeLastObject];
		}
		// 업로드하다가 폴더를 만들때 이미 있다면 테이블 셀에 이펙트를 주기 위해 m_fileInfoArray에서 지웠다가 추가한다.
		else if ([errmsg length] >= 7 && [[errmsg substringToIndex:7] isEqualToString:@"Already"])
		{
			NSLog(@"Already Forder:%@", g_fileInfo.m_strName);
			NSRange range = [g_fileInfo.m_strName rangeOfString:@"/"];
			
			// "/"가 있는 경우는 하위 폴더이다. 이때는 테이블 셀에 추가하면 안된다.
			if (range.location == NSNotFound)
			{
				CFileInfo	*fileInfo = [[CFileInfo alloc] initWithCFileInfo:g_fileInfo];
				
				for (int i=0; i<[m_fileInfoArray count]; i++)
				{
					CFileInfo	*fileInfo2 = [m_fileInfoArray objectAtIndex:i];
					
					NSLog(@"fileInfo2.m_strName:%@, fileInfo.m_strName:%@", fileInfo2.m_strName, fileInfo.m_strName);
					
					if ([fileInfo2.m_strName isEqualToString:fileInfo.m_strName])
					{
						fileInfo.m_dwACL = fileInfo2.m_dwACL;
						fileInfo.m_dtLastWriteTime = [NSString stringWithString:fileInfo2.m_dtLastWriteTime];

						[self removeFromCellData:fileInfo.m_strName];
						[self addToCellData:fileInfo];
						m_addCount++;
						break;
					}
				}
			}
		}
	}

	if (m_nCmdType == ST_CREATE_DIR)
		[table reloadData];

	m_nCmdType = -1;
	m_bFinished = TRUE;
}

// 파일/폴더 복사/옮기기 후 결과 처리
- (void) didFinishFileOp: (NSString *) errmsg 
			  fileInfo: (CFileInfo *) recvFileInfo
{
	if (errmsg)
	{
		UIAlertView	*av = [[[UIAlertView alloc] initWithTitle:nil message:NSLocalizedString(errmsg, nil) delegate:nil cancelButtonTitle:NSLocalizedString(@"OK",nil) otherButtonTitles:nil] autorelease];
		[av show];
	}
	else
	{
		CFileInfo	*fileInfo = [[CFileInfo alloc] initWithCFileInfo:g_fileInfo];
		fileInfo.m_dtLastWriteTime = [NSString stringWithString:recvFileInfo.m_dtLastWriteTime];
		
		[self addToCellData:fileInfo];
		
		m_addCount++;
		
		// 이동의 경우 파일 리스트에서 파일 정보를 삭제한다.
		if (g_appDelegate.sourceType == SERVER && g_appDelegate.pasteStatus == CUT)
		{
			ServerViewController *controller = (ServerViewController *)g_appDelegate.sourceServerViewController;
			NSMutableArray *fileInfoArray = (NSMutableArray *)controller.m_fileInfoArray;
			
			for (int i=0; i<[fileInfoArray count]; i++)
			{
				CFileInfo	*fileInfo2 = [fileInfoArray objectAtIndex:i];
				
				if ([fileInfo.m_strName isEqualToString:fileInfo2.m_strName])
				{
					[controller removeItem:i];
				}
			}

			[controller.table reloadData];
		}
	}
	
	m_bFinished = YES;
}

// 파일/폴더 삭제 후 결과 처리
- (void) didFinishDeleteFile: (NSString *) errmsg 
					filePath: (NSString *) filePath
{
	m_bFinished = TRUE;
	
	if (errmsg)
	{
		UIAlertView	*av = [[[UIAlertView alloc] initWithTitle:nil message:NSLocalizedString(errmsg, nil) delegate:nil cancelButtonTitle:NSLocalizedString(@"OK",nil) otherButtonTitles:nil] autorelease];
		[av show];
	}
	// Success이면 리프레쉬한다.
	else
	{
		[self refreshClicked];
	}
}

// 휴지통을 비운 후 ServerCmd에서 호출한다.
- (void) didFinishEmptyRecycled:(NSString *) errmsg
{
	if (errmsg)
	{
		UIAlertView	*av = [[[UIAlertView alloc] initWithTitle:nil message:NSLocalizedString(errmsg, nil) delegate:nil cancelButtonTitle:NSLocalizedString(@"OK",nil) otherButtonTitles:nil] autorelease];
		[av show];
	}
	else
	{
	}
}

// 이름 변경 후 ServerCmd에서 호출한다.
- (void) didFinishRenameFile:(NSString *) errmsg
{
	if (errmsg)
	{
		UIAlertView	*av = [[[UIAlertView alloc] initWithTitle:nil message:NSLocalizedString(errmsg, nil) delegate:nil cancelButtonTitle:NSLocalizedString(@"Confirm",nil) otherButtonTitles:nil] autorelease];
		[av show];

		// 에러 발생시 리프레쉬한다.
		[self refreshClicked];
	}
	else
	{
	}
}

// 리프레쉬 후 ServerCmd에서 호출한다.
- (void) didFinishRefresh: (NSString *) errmsg 
			fileInfoArray: (NSMutableArray *) fileInfoArray
{
	if (errmsg)
	{
		UIAlertView	*av = [[[UIAlertView alloc] initWithTitle:nil message:NSLocalizedString(errmsg, nil) delegate:nil cancelButtonTitle:NSLocalizedString(@"Confirm",nil) otherButtonTitles:nil] autorelease];
		[av show];
	}
	else
	{
		[m_fileInfoArray release];
		[m_selectedInfoArray release];

		m_fileInfoArray = [[NSMutableArray alloc] initWithArray:fileInfoArray];
		m_selectedInfoArray = [[NSMutableArray alloc] initWithCapacity:[fileInfoArray count]];;

		for (int i=0; i<[m_fileInfoArray count]; i++)
			[m_selectedInfoArray addObject:[NSNumber numberWithBool:NO]];
		
		[self refreshData];
		[table reloadData];
	}
}

// GetList 후 ServerCmd에서 호출한다.
- (void) didFinishGetList: (NSString *) errmsg 
			fileInfoArray: (NSMutableArray *) fileInfoArray
{
	if (errmsg)
	{
		UIAlertView	*av = [[[UIAlertView alloc] initWithTitle:nil message:NSLocalizedString(errmsg, nil) delegate:nil cancelButtonTitle:NSLocalizedString(@"Confirm",nil) otherButtonTitles:nil] autorelease];
		[av show];
	}
	else
	{
		NSString *pStrFolderViewController = @"FolderViewController";
		
//#ifdef KDISK
//		pStrFolderViewController = @"FolderViewControllerKDisk";
//#endif
		
		ServerViewController * serverViewController = [[ServerViewController alloc] initWithNibName:pStrFolderViewController bundle:nil ]; 
		
		CFileInfo *fileInfo = [m_fileInfoArray objectAtIndex:m_nSelectedRow];
		serverViewController.m_fileInfoArray = [[NSMutableArray alloc] initWithArray:fileInfoArray];
		serverViewController.title = fileInfo.m_strName;
		serverViewController.m_nSelectedDrive = m_nSelectedDrive;
		serverViewController.m_nShareFolder = m_nShareFolder;
		serverViewController.m_sharePath = m_sharePath;
		serverViewController.currentFolder = [currentFolder stringByAppendingPathComponent:serverViewController.title];
//		serverViewController.m_fileInfo = [m_fileInfoArray objectAtIndex:m_nSelectedRow];
		serverViewController.folderDepth = folderDepth+1;
		
		[g_appDelegate.navServerController pushViewController:serverViewController animated:YES];
		[serverViewController release];
	}
}

#pragma mark -
#pragma mark Table view methods

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
	return 2;
}

// Customize the number of rows in the table view.
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
	if (section == 0)
		return [m_fileInfoArray count];
	
	return 4;
}

// 파일 리스트에서 n번째 파일의 이름을 얻는다.
-(NSString *) getFileName: (NSMutableArray *) fileInfoList 
					  row: (NSUInteger) row
{
	CFileInfo	* fileInfo = (CFileInfo *)[fileInfoList objectAtIndex: row];
	
	return fileInfo.m_strName;
}

// 파일 리스트에서 n번째 파일의 Full Path를 얻는다.
-(NSString *) getFilePath: (NSMutableArray *) fileInfoList 
					  row: (NSUInteger) row
{
	CFileInfo	*fileInfo = (CFileInfo *)[fileInfoList objectAtIndex: row];
	NSString	*filePath = [currentFolder stringByAppendingPathComponent: fileInfo.m_strName];
	
	return filePath;
}

// 테이블 뷰에서 목록을 클릭하면 호출된다.
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
	
	m_nSelectedRow = [indexPath row];
	
	CFileInfo	*fileInfo = [m_fileInfoArray objectAtIndex:m_nSelectedRow];
	NSString	*filePath = [currentFolder stringByAppendingPathComponent:fileInfo.m_strName];
	
	ServerCmd	*serverCmd = [[ServerCmd alloc] init];

	if ([self isFolder:m_nSelectedRow]) 	
	{
		NSLog(@"didSelecRowAtIndexPath: m_nSelectedDrive:%d, folderDepth:%d", m_nSelectedDrive, folderDepth);

		NIDriveInfo *info = [g_appDelegate.m_arrDriveInfo objectAtIndex:m_nSelectedDrive];
		
		// 공유 폴더이면
		if ( info->m_nDiskType == DT_SHARE)
		{
			// 공유 폴더 설정
			if (folderDepth == 1)
			{
				m_nShareFolder = m_nSelectedRow;
				[m_sharePath release];
			}
			// 공유 Path 설정
			else if (folderDepth == 2)
			{
				CFileInfo * fileInfo = [m_fileInfoArray objectAtIndex:m_nSelectedRow];
				m_sharePath = fileInfo.m_stShare;
			}
			
			[serverCmd GetList: m_nSelectedDrive 
					folderName: filePath 
					  fileInfo: [g_ShareFolderList objectAtIndex:m_nShareFolder] 
					 sharePath: m_sharePath 
				     recursive: NO 
						sender: self 
					  selector: @selector(didFinishGetList:fileInfoArray:)];
		}
		else
			[serverCmd GetList: m_nSelectedDrive 
					folderName: filePath 
					  fileInfo: nil 
					 sharePath: nil 
				     recursive: NO 
						sender: self 
					  selector: @selector(didFinishGetList:fileInfoArray:)];
 	}
	// 파일 다운로드
	else
	{
		if (![g_appDelegate check3G:DOWNLOAD])
		{
			[tableView deselectRowAtIndexPath:indexPath animated:YES];
			return;
		}
		
		g_appDelegate.sourceServerViewController = self;
		m_bGetFile = TRUE;
		g_appDelegate.m_bServerTab = FALSE;
		
		NSString * ext = [filePath pathExtension];
		NSDictionary * imageDic = [NSDictionary dictionaryWithObjectsAndKeys:
								  @"", @"png", @"", @"jpg", @"", @"gif", 
								  nil];
		
		g_appDelegate.isRotate = YES;
		m_selectedIndexPath = indexPath;
		
  		if ( [imageDic objectForKey:[ext lowercaseString]] == nil )
		{
			m_bFinished = FALSE;
			m_bCancel = FALSE;
			
			[serverCmd GetFile: m_nSelectedDrive 
						tmpDir: nil 
					   srcName: filePath 
					  fileInfo: [self getShareFolder] 
					 sharePath: [self getSharePath] 
						  view: g_appDelegate.navServerController.view 
						 order: 1 
					 totalfile: 1
						sender: self 
					  selector: @selector(didFinishGetFile:filePath:)];
		}
		else
		{
			int	index = [self createSourceImage:m_nSelectedRow]-1;
			int	start = index-1;
			int	end = index+1;
			
			if (start < 0)
				start = 0;
			
			if (end > [g_appDelegate.sourceImage count]-1)
				end = [g_appDelegate.sourceImage count]-1;
			
			for (int i=start; i<=end; i++)
			{
				filePath = [currentFolder stringByAppendingPathComponent:
							[[g_appDelegate.sourceImage objectAtIndex:i] lastPathComponent]];
				
				m_bFinished = FALSE;
				m_bCancel = FALSE;
				
				[serverCmd GetFile: m_nSelectedDrive 
							tmpDir: nil 
						   srcName: filePath
						  fileInfo: [self getShareFolder] 
						 sharePath: [self getSharePath] 
							  view: g_appDelegate.navServerController.view 
							 order: (i-start+1) 
						 totalfile: (end-start+1)
							sender: self 
						  selector: @selector(didFinishGetImage:filePath:)];
				
				while (!m_bFinished && !m_bCancel)
					[[NSRunLoop currentRunLoop] runMode:NSDefaultRunLoopMode beforeDate:[NSDate distantFuture]];
				
				if (m_bCancel)
				{
					return;
				}
			}
			
			[table deselectRowAtIndexPath:m_selectedIndexPath animated:YES];
			
//			PhotoViewController *p = [[ PhotoViewController alloc] init];
//			p.m_nPhotoIndex = index;
			
//			[p preLoad];
//	  		[g_appDelegate.navServerController pushViewController:p animated:YES];
//	 		[p release];

			m_bGetFile = FALSE;
			g_appDelegate.m_bServerTab = TRUE;
		}
		
	}
	
	m_selectedIndexPath = indexPath;
}

// 테이블 뷰에서 Delete 버튼을 클릭하면 호출된다.
- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{
	NSUInteger row = [indexPath row];
	
	if ([self isRecycler:row])
	{
//		CentralECMAppDelegate *appDelegate = (CentralECMAppDelegate *)[[UIApplication sharedApplication] delegate];
		
		if (editingStyle == UITableViewCellEditingStyleDelete)
		{
//			if ([ModalActionSheet ask:NSLocalizedString(@"Would you like to empty trash can?", nil)
//						   withCancel:NSLocalizedString(@"Cancel", nil) 
//					  withDestructive:NSLocalizedString(@"Empty", nil) 
//						  withButtons:nil
////								where:appDelegate.rootViewController.tabBar] == 0)
//			{
//				[self deleteFile:row];
//			}
			
			[self clearSelectedIndexPath];
			[self clearSelectedButton];
			[self renderCopyCutPasteButton:@"toggleButton"];
		}   
	}
	else
		[super tableView:tableView commitEditingStyle:editingStyle forRowAtIndexPath:indexPath];
}

// 서버문서함에서 목록을 클릭하면 호출된다.
- (NSString *) downFileOpen: (CentralECMAppDelegate *) g_appDelegate
                    ActView: (ActivityViewController *) ActViewCtl
{
    appDelegate = [[CentralECMAppDelegate alloc]init];
    appDelegate = g_appDelegate;
    
    NSLog(@"%@", m_strFilePath);
    
    NSMutableArray *sourceData = [[NSMutableArray alloc] initWithArray:appDelegate.sourceData];
    [appDelegate.sourceData removeAllObjects];
    
    //    NIDriveInfo *info = [appDelegate.m_arrDriveInfo objectAtIndex:g_nSourceDrive];
    NICookieInfo *cookieinfo = [appDelegate.m_arrCookieInfo objectAtIndex:g_nSourceDrive];
    //  NSString *currentfolder = info->m_strCurrentPath;
    
    NSString *tmpRetVal = nil;
    
    for (int i=0; i < sourceData.count; i++)    //@@
    {
        
        CFileInfo    *fileInfo = (CFileInfo *)[sourceData objectAtIndex:i];
        
        NSString    *filePath = [appDelegate.sourceFolder stringByAppendingPathComponent:fileInfo.m_strName];
        
        ServerCmd    *serverCmd = [[ServerCmd alloc] init];
        
        
        m_nSelectedDrive = i;
        
        //    if (![g_appDelegate check3G:DOWNLOAD])
        //        {
        //            //[tableView deselectRowAtIndexPath:indexPath animated:YES];
        //            return;
        //        }
        
        //g_appDelegate.sourceServerViewController = self;
        m_bGetFile = TRUE;
        g_appDelegate.m_bServerTab = FALSE;
        
        //NSString * ext = [filePath pathExtension];
        //NSDictionary * imageDic = [NSDictionary dictionaryWithObjectsAndKeys:
        //                           @"", @"png", @"", @"jpg", @"", @"gif",
        //                          nil];
        
        g_appDelegate.isRotate = YES;
        //m_selectedIndexPath = indexPath;
        //
        //          if ( [imageDic objectForKey:[ext lowercaseString]] == nil )
        //        {
        m_bFinished = FALSE;
        m_bCancel = FALSE;
        NICookieInfo *cookieinfo = [appDelegate.m_arrCookieInfo objectAtIndex:i];
        [serverCmd GetFile: m_nSelectedDrive
                    tmpDir: nil
                   srcName: fileInfo.m_strPath
                  fileInfo: fileInfo
                 sharePath: cookieinfo->m_strSharePath
                      view: g_appDelegate.navServerController.view
                     order: i+1
                 totalfile: (int)sourceData.count   //@
                    sender: self
                  selector: @selector(didFinishGetFile:filePath:)
             g_appDelegate: appDelegate
                   ActView:ActViewCtl];
        
        while (!m_bFinished && !m_bCancel)
        [[NSRunLoop currentRunLoop] runMode:NSDefaultRunLoopMode beforeDate:[NSDate distantFuture]];
        
        
        
        //        }
        //        else
        //        {
        ////            int    index = [self createSourceImage:m_nSelectedRow]-1;
        ////            int    start = index-1;
        ////            int    end = index+1;
        ////
        ////            if (start < 0)
        ////                start = 0;
        ////
        ////            if (end > [g_appDelegate.sourceImage count]-1)
        ////                end = [g_appDelegate.sourceImage count]-1;
        ////
        ////            for (int i=start; i<=end; i++)
        ////            {
        ////                filePath = [currentFolder stringByAppendingPathComponent:
        ////                            [[g_appDelegate.sourceImage objectAtIndex:i] lastPathComponent]];
        ////
        ////                m_bFinished = FALSE;
        ////                m_bCancel = FALSE;
        ////
        ////                [serverCmd GetFile: m_nSelectedDrive
        ////                            tmpDir: nil
        ////                           srcName: filePath
        ////                          fileInfo: fileInfo
        ////                         sharePath: cookieinfo->m_strSharePath
        ////                             // view: g_appDelegate.navServerController.view
        ////                 view: nil
        ////                             order: (i-start+1)
        ////                         totalfile: (end-start+1)
        ////                            sender: self
        ////                          selector: @selector(didFinishGetImage:filePath:)
        ////                     g_appDelegate: appDelegate];
        ////
        ////                while (!m_bFinished && !m_bCancel)
        ////                    [[NSRunLoop currentRunLoop] runMode:NSDefaultRunLoopMode beforeDate:[NSDate distantFuture]];
        ////
        ////                if (m_bCancel)
        ////                {
        ////                    return;
        ////                }
        ////            }
        //
        //            [serverCmd GetFile: m_nSelectedDrive
        //                        tmpDir: nil
        //                       srcName: filePath
        //                      fileInfo: fileInfo
        //                     sharePath: cookieinfo->m_strSharePath
        //                          view: g_appDelegate.navServerController.view
        //                         order: 1
        //                     totalfile: 1
        //                        sender: self
        //                      selector: @selector(didFinishGetImage:filePath:)
        //                 g_appDelegate: appDelegate];
        //
        //            //[table deselectRowAtIndexPath:m_selectedIndexPath animated:YES];
        //
        //            PhotoViewController *p = [[ PhotoViewController alloc] init];
        //            //p.m_nPhotoIndex = index;
        //
        //            //            [p preLoad];
        //              [g_appDelegate.navServerController pushViewController:p animated:YES];
        //             [p release];
        //
        //            m_bGetFile = FALSE;
        //            g_appDelegate.m_bServerTab = TRUE;
        //        }
        
        
        
        NSLog(@"FilePath is3 %@", tmpRetVal);
        //    AppDelegate *AD = [[UIApplication sharedApplication] delegate];
        //    if(!tmpRetVal){
        //        NSLog(@"retry");
        //        if(![AD.tmpFileInfo isEqualToString:@"no"]){
        //            NSLog(@"in if");
        //            [AD.viewController.webView stringByEvaluatingJavaScriptFromString:[NSString stringWithFormat:@"bookmarkOpenFile('%@')", AD.tmpFileInfo]];
        //        } else {
        //            NSLog(@"in else");
        //            [AD.viewController.webView stringByEvaluatingJavaScriptFromString:[NSString stringWithFormat:@"fileopen('%@','%@')", @"", @""]];
        //        }
        //        NSLog(@"tmpRetVal is NULL");
        //    }
        
        //m_selectedIndexPath = indexPath;
        
        
        if ( i >= 1 )
        {
            tmpRetVal = [tmpRetVal stringByAppendingString:@"\t"];
            tmpRetVal = [tmpRetVal stringByAppendingString:m_strFilePath];
        }
        else
        {
            tmpRetVal = m_strFilePath;
        }
        
        if(tmpRetVal == NULL) tmpRetVal = @"Canceled";
        
    }
    return tmpRetVal;
}
// 서버문서함에서 목록을 클릭하면 호출된다.
- (NSString *) downFileOpen_phone:(CentralECMAppDelegate *)g_appDelegate ActView:(ActivityViewController_phone *)ActViewCtl
{
    appDelegate = [[CentralECMAppDelegate alloc]init];
    appDelegate = g_appDelegate;
    
    NSMutableArray *sourceData = [[NSMutableArray alloc] initWithArray:appDelegate.sourceData];
    [appDelegate.sourceData removeAllObjects];
    
    //    NIDriveInfo *info = [appDelegate.m_arrDriveInfo objectAtIndex:g_nSourceDrive];
    NICookieInfo *cookieinfo = [appDelegate.m_arrCookieInfo objectAtIndex:g_nSourceDrive];
    //  NSString *currentfolder = info->m_strCurrentPath;
    
    CFileInfo	*fileInfo = (CFileInfo *)[sourceData objectAtIndex:0];
    
	NSString	*filePath = [appDelegate.sourceFolder stringByAppendingPathComponent:fileInfo.m_strName];
	
	ServerCmd	*serverCmd = [[ServerCmd alloc] init];
    
    NSString *tmpRetVal = nil;
    m_nSelectedDrive = 0;
    
    //	if (![g_appDelegate check3G:DOWNLOAD])
    //		{
    //			//[tableView deselectRowAtIndexPath:indexPath animated:YES];
    //			return;
    //		}
    
    //g_appDelegate.sourceServerViewController = self;
    m_bGetFile = TRUE;
    g_appDelegate.m_bServerTab = FALSE;
    
    //NSString * ext = [filePath pathExtension];
    //NSDictionary * imageDic = [NSDictionary dictionaryWithObjectsAndKeys:
    //                           @"", @"png", @"", @"jpg", @"", @"gif",
    //                          nil];
    
    g_appDelegate.isRotate = YES;
    //m_selectedIndexPath = indexPath;
    //
    //  		if ( [imageDic objectForKey:[ext lowercaseString]] == nil )
    //		{
    m_bFinished = FALSE;
    m_bCancel = FALSE;
    
    [serverCmd GetFile: m_nSelectedDrive
                tmpDir: nil
               srcName: filePath
              fileInfo: fileInfo
             sharePath: cookieinfo->m_strSharePath
                  view: g_appDelegate.navServerController.view
                 order: 1
             totalfile: 1
                sender: self
              selector: @selector(didFinishGetFile:filePath:)
         g_appDelegate: appDelegate
               ActView:ActViewCtl];
    
    while (!m_bFinished && !m_bCancel)
        [[NSRunLoop currentRunLoop] runMode:NSDefaultRunLoopMode beforeDate:[NSDate distantFuture]];
    
    //		}
    //		else
    //		{
    ////			int	index = [self createSourceImage:m_nSelectedRow]-1;
    ////			int	start = index-1;
    ////			int	end = index+1;
    ////
    ////			if (start < 0)
    ////				start = 0;
    ////
    ////			if (end > [g_appDelegate.sourceImage count]-1)
    ////				end = [g_appDelegate.sourceImage count]-1;
    ////
    ////			for (int i=start; i<=end; i++)
    ////			{
    ////				filePath = [currentFolder stringByAppendingPathComponent:
    ////							[[g_appDelegate.sourceImage objectAtIndex:i] lastPathComponent]];
    ////
    ////				m_bFinished = FALSE;
    ////				m_bCancel = FALSE;
    ////
    ////				[serverCmd GetFile: m_nSelectedDrive
    ////							tmpDir: nil
    ////                           srcName: filePath
    ////                          fileInfo: fileInfo
    ////                         sharePath: cookieinfo->m_strSharePath
    ////							 // view: g_appDelegate.navServerController.view
    ////                 view: nil
    ////							 order: (i-start+1)
    ////						 totalfile: (end-start+1)
    ////							sender: self
    ////						  selector: @selector(didFinishGetImage:filePath:)
    ////                     g_appDelegate: appDelegate];
    ////
    ////				while (!m_bFinished && !m_bCancel)
    ////					[[NSRunLoop currentRunLoop] runMode:NSDefaultRunLoopMode beforeDate:[NSDate distantFuture]];
    ////
    ////				if (m_bCancel)
    ////				{
    ////					return;
    ////				}
    ////			}
    //
    //            [serverCmd GetFile: m_nSelectedDrive
    //						tmpDir: nil
    //					   srcName: filePath
    //                      fileInfo: fileInfo
    //                     sharePath: cookieinfo->m_strSharePath
    //						  view: g_appDelegate.navServerController.view
    //						 order: 1
    //					 totalfile: 1
    //						sender: self
    //					  selector: @selector(didFinishGetImage:filePath:)
    //                 g_appDelegate: appDelegate];
    //
    //			//[table deselectRowAtIndexPath:m_selectedIndexPath animated:YES];
    //
    //			PhotoViewController *p = [[ PhotoViewController alloc] init];
    //			//p.m_nPhotoIndex = index;
    //
    //            //			[p preLoad];
    //	  		[g_appDelegate.navServerController pushViewController:p animated:YES];
    //	 		[p release];
    //            
    //			m_bGetFile = FALSE;
    //			g_appDelegate.m_bServerTab = TRUE;
    //		}
    
	
	tmpRetVal = m_strFilePath;
	//m_selectedIndexPath = indexPath;
    if(tmpRetVal == NULL) tmpRetVal = @"Canceled";
    return tmpRetVal;
    
}

- (void) dealloc
{
	[m_folderInfoArray release];
    [super dealloc];
}

@end

