//
//  FolderViewController.m
//  CentralECM
//
//  Created by HeungKyoo Han on 10. 04. 21.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import "FolderViewController.h"
#import "CentralECMAppDelegate.h"
//#import "PhotoViewController.h"
//#import "WebThree20ViewController.h"
//#import <Three20/Three20.h>
#import "CentralECMAppDelegate.h"
#import "FileUtil.h"

#import "NIInterfaceUtil.h"

//extern	CDriveInfo	g_driveInfo[3];
NSMutableArray				*g_ShareFolderList;

@implementation FolderViewController

@synthesize m_nShareFolder;
@synthesize m_sharePath;
@synthesize m_bFinished;
@synthesize m_bRefresh;
@synthesize table;
@synthesize selectedImage;
@synthesize unselectedImage;
@synthesize folderImage;
@synthesize recyclerImage;
@synthesize fileImage;
@synthesize copyBtn;
@synthesize cutBtn;
@synthesize pasteBtn;
@synthesize renameBtn;
@synthesize folderBtn;
@synthesize	m_fileInfoArray;
@synthesize	m_selectedInfoArray;
@synthesize	selectedButton;
@synthesize	currentFolder;
@synthesize folderDepth;
@synthesize m_nSelectedDrive;
@synthesize m_strFilePath;
/*
 #pragma mark overide methods
 #pragma mark overide event handler
 는 ServierViewController, ClientViewController에 맞게 수정한다.
 
 0. data구조
 listData: 현재화면의 실제 파일이름
 editData: textfield에 출력되는 파일이름 
 m_selectedInfoArray: 현재 선택된 버튼의 값을 저장
 
 
 1. 버튼 액션은
 툴바:onCopy, onCut, onPaste(cancel,paste를 처리), onRename, onCreateFolder 
	 CentralECMAppDelegate 의 pasteStatus: COPY, CUT, RENAMES, CANCEL의 현재 상태를 저장
     CentralECMAppDelegate 의 sourceType: copy, cut시 설정  CART(보관함), SERVER(서버) 
     CentralECMAppDelegate 의 targetType: 화면이 로딩될때 설정하여 paste시 처리 CART(보관함), SERVER(서버)
     CentralECMAppDelegate 의 isRecursive:를 copy,cut후 폴더이동시 설정하여 자기, 자기자식에게 복사되서 무한반복이되는 현상을 맊는다.
 
 
 navigation :onSave : webview에서의 저장을 처리
 키보드 : textFieldDidEndEditing : done을 눌렀을때 rename, 다음 focus이동을 처리
  
 
 2.새로운 항목을 추가 할때 사용.
 addToCellData:(NSString *)data 
 
 3.table cell 초기화 case
 -delete, paste, rename시 체크박스 초기화
 [self clearSelectedIndexPath];
 [self clearSelectedButton];
 
 -controller이동간 초기화
 [self clearSelectedIndexPath];
 [self clearSelectedButton];
 [self clearSelectedTextField];
 [self clearRenameButton];
 
*/

#pragma mark -
#pragma mark overide methods

-(void) cancel
{
}

-(id) init 
{
	self = [super initWithNibName:@"FolderViewController" bundle:nil];
	
	return self;
}


- (CFileInfo *) getShareFolder
{
	NSLog(@"getShareFolder: m_nSelectedDrive:%d, folderDepth:%d", m_nSelectedDrive, folderDepth);
	
	NIDriveInfo *info = [g_appDelegate.m_arrDriveInfo objectAtIndex:m_nSelectedDrive];
	
	if ( info->m_nDiskType == DT_SHARE && folderDepth > 1)
	{
		// 공유 폴더 설정
		if (folderDepth == 2)
		{
			m_nShareFolder = m_nSelectedRow;
			[m_sharePath release];
		}
		
		return [g_ShareFolderList objectAtIndex:m_nShareFolder];
	}
	else
		return nil;
}

- (NSString *) getSharePath
{
	NIDriveInfo *info = [g_appDelegate.m_arrDriveInfo objectAtIndex:m_nSelectedDrive];
	
	if ( info->m_nDiskType == DT_SHARE && folderDepth > 1)
		return m_sharePath;
	else
		return nil;
}

-(void) pushFolder:(NSInteger) row {}

-(BOOL) isRecycler:(NSInteger) row
{
	return false;
}	

-(BOOL) isFolder:(NSInteger) row
{
	return false;
}	
 
-(BOOL) deleteFile:(NSInteger)row {
	return true;
}

-(void) refreshListData{
	[m_fileInfoArray removeAllObjects];
	[m_selectedInfoArray removeAllObjects];
}

-(BOOL) renameFile:(NSString *)srcPath 
			toPath:(NSString *)dstPath
{
	return true;
}

-(void)onCreateFolder {}

-(void)onCopy
{
	CentralECMAppDelegate *appDelegate = (CentralECMAppDelegate *)[[UIApplication sharedApplication] delegate];
	appDelegate.sourceFolder = currentFolder;
	appDelegate.pasteStatus	= COPY;
	NSMutableArray *sourceData = (NSMutableArray *  )appDelegate.sourceData;
	[sourceData removeAllObjects];
	
	int i = 0;
	BOOL selected;
    
	for (i = 0; i < m_selectedInfoArray.count; i++)
    {
 		selected = [[m_selectedInfoArray objectAtIndex:i] boolValue];
		
		if (selected == YES)
		{
			CFileInfo * fileInfo = [m_fileInfoArray objectAtIndex:i];
 			[sourceData addObject:fileInfo];
 		}
    }
	
	[self renderCopyCutPasteButton:@"onCopy"];
}

-(void)onCut
{
	[self onCopy];
	CentralECMAppDelegate *appDelegate = (CentralECMAppDelegate *)[[UIApplication sharedApplication] delegate];
 	appDelegate.pasteStatus	= CUT;
}

// 네비게이션바에서 저장을 선택하면 호출됨.
// 이곳에서 tag값에 해당되는 파일을 처리한다.
-(void)onSave:(id)sender
{
	NSLog(@"row=%d", [sender tag] );
}

#pragma mark -
#pragma mark event handler

-(void)onBackBarButtonItem:(id)sender
{
	NSLog(@"called");
}

// paste, cancel 버튼 클릭시 호출
-(IBAction)onPaste
{
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
	CFileInfo	* fileInfo = (CFileInfo *)[fileInfoList objectAtIndex: row];
	NSString * filePath = [currentFolder stringByAppendingPathComponent: fileInfo.m_strName];
	
	return filePath;
}

/*
 PhotoViewController에서 보여줄 이미지정보를 추츨하며
 리턴값은  sourceImage 배열에서 현재 row값과 일치되는 위치를 리턴한다.
*/
-(NSInteger)createSourceImage:(NSInteger) row
{
	CentralECMAppDelegate *appDelegate = (CentralECMAppDelegate *)[[UIApplication sharedApplication] delegate];
	NSMutableArray *sourceImage = (NSMutableArray *)appDelegate.sourceImage;
	[sourceImage removeAllObjects];
	
	NSDictionary *imageDic= [NSDictionary dictionaryWithObjectsAndKeys:
							 @"", @"png", @"", @"jpg", @"", @"gif", 
							 nil];
 	NSInteger index = 0;
	
	for ( int i = 0; i < [m_fileInfoArray count]; i++)
	{
 		NSString *ext = [[self getFileName: m_fileInfoArray row:i] pathExtension];

		if ( [imageDic objectForKey:[ext lowercaseString]] != nil )
		{
			NSString *filePath;
			
			if (g_appDelegate.targetType == CART)
				filePath = [self getFilePath: m_fileInfoArray row:i];
			else
			{
				NSLog(@"filepath: %@", [self getFileName:m_fileInfoArray row:i ]);
				filePath = [[g_FileUtil getTmpFolder] stringByAppendingPathComponent: [self getFileName:m_fileInfoArray row:i ]];
			}	 
			
			[sourceImage addObject: filePath];
		
			if (i == row)
			{
				index = [sourceImage count];
			}
		}
 	}
	
	return index;
}

//select된 갯수를 리턴
- (NSInteger) getSelectedCount {
 	
	int select = 0;
	for( int i = 0; i < m_selectedInfoArray.count; i++){
		if ( [[m_selectedInfoArray objectAtIndex:i] boolValue] ) select++;
 	}
	return select;
 	
}


// 데이타를 추가할때 addToCellData를 호출한다.
- (void) addToCellData:(CFileInfo *)fileInfo
{
	if (g_appDelegate.targetType == CART)
	{
		NSDate * modDate = nil;
		fileInfo.m_n64Size = [g_FileUtil getLength:[currentFolder stringByAppendingPathComponent:fileInfo.m_strName] modDate:&modDate];
		
		if (modDate)
			fileInfo.m_dtLastWriteTime = [NSString stringWithString:[modDate description]];
	}
	
	[m_fileInfoArray addObject:fileInfo];
	[m_selectedInfoArray addObject:[NSNumber numberWithBool:NO]];
}

-(void) clearRenameButton
{
	CentralECMAppDelegate *appDelegate = (CentralECMAppDelegate *)[[UIApplication sharedApplication] delegate];
	
	if (appDelegate.pasteStatus == RENAMES)
	{
		appDelegate.pasteStatus =NO;
	}
}

// 메소드에 따라 툴바의 속성값을 변경한다.
-(void) renderCopyCutPasteButton:(NSString *)which
{
	CentralECMAppDelegate *appDelegate = (CentralECMAppDelegate *)[[UIApplication sharedApplication] delegate];
 	
  	int cnt = 0;
	BOOL oneMore = NO;
	
	//NSLog(@"rendre=%d", appDelegate.pasteStatus);
	for ( int i = 0; i < m_selectedInfoArray.count; i++)
	{
		if ([[m_selectedInfoArray objectAtIndex:i] boolValue]==YES)
		{
			cnt++;
			oneMore =YES;
		}
	}
 
	if ([which localizedCompare: @"toggleButton_RENAME" ] == 0)
	{
		copyBtn.enabled    = NO;
		cutBtn.enabled     = NO;
		renameBtn.enabled  = YES;
 	}
	else if ([which localizedCompare: @"toggleButton" ] == 0)
	{
 		if (oneMore)
		{
			copyBtn.enabled    = YES;
			cutBtn.enabled     = YES;
			renameBtn.enabled  = YES;
			pasteBtn.enabled   = NO;
		}
		else
		{
			copyBtn.enabled    = NO;
			cutBtn.enabled     = NO;
			renameBtn.enabled  = NO;
			pasteBtn.enabled   = NO;
		}
	}
	else if ([which localizedCompare: @"onPaste" ] == 0)
	{
	 	copyBtn.enabled    = NO;
		cutBtn.enabled     = NO;
		pasteBtn.enabled   = NO;
		renameBtn.enabled  = NO;
		
	}
	else if ([which localizedCompare: @"viewDidAppear" ] == 0)
	{
 		if (appDelegate.pasteStatus == COPY)
		{
			//NSLog(@"here2");
			copyBtn.enabled    = NO;
			cutBtn.enabled     = NO;
			pasteBtn.enabled   = YES;
			renameBtn.enabled  = NO;
			
		}
		else if (appDelegate.pasteStatus == CUT)
		{
			copyBtn.enabled    = NO;
			cutBtn.enabled     = NO;
			pasteBtn.enabled   = YES;		
			renameBtn.enabled  = NO;
			
		}
		else
		{
			copyBtn.enabled    = NO;
			cutBtn.enabled     = NO;
			pasteBtn.enabled   = NO;
			renameBtn.enabled  = NO;
 		}
 	}
	else if ([which localizedCompare: @"onCopy" ] == 0)
	{
		copyBtn.enabled    = NO;
		cutBtn.enabled     = NO;
		pasteBtn.enabled   = YES;
		renameBtn.enabled  = NO;
 	}
	else if ([which localizedCompare: @"onRename" ] == 0)
	{
		copyBtn.enabled    = NO;
		cutBtn.enabled     = NO;
		pasteBtn.enabled   = NO;
	
		if (appDelegate.pasteStatus == RENAMES)
		{
			renameBtn.enabled  = YES;
		}
		else
		{
			renameBtn.enabled  = NO;
		}
 	}
	
	// TO DO : 다운로드, 업로드가 진행 중일 때 고려..
	/*
	[UIView beginAnimations:@"toolbar" context:nil];
	if ( oneMore )
	{
		if ( toolbar.hidden == YES || toolbar.alpha == 0 )
		{
			toolbar.hidden = NO;
			toolbar.frame = CGRectOffset(toolbar.frame, 0, +toolbar.frame.size.height);
			toolbar.alpha = 0.78;
		}
	}
	else
	{
		toolbar.frame = CGRectOffset(toolbar.frame, 0, -toolbar.frame.size.height);
		toolbar.alpha = 0;
		//toolbar.hidden = YES;
	}
	[UIView commitAnimations];
	 */
	//
	
	NSString *str;
	
	if (copyBtn.enabled)
	{
		str = [NSString stringWithFormat:NSLocalizedString(@"Copy(%d)",nil), cnt];
 
		[copyBtn setTitle:str];
	}
	else
		[copyBtn setTitle:NSLocalizedString(@"Copy",nil)];
	
	if (cutBtn.enabled)
	{
		str = [NSString stringWithFormat:NSLocalizedString(@"Cut(%d)",nil), cnt];
 
		[cutBtn setTitle:str];
	}
	else
		[cutBtn setTitle:NSLocalizedString(@"Cut",nil)];
	
	if (pasteBtn.enabled)
	{
		cnt = appDelegate.sourceData.count;

		if (cnt == 0)
		{
			pasteBtn.enabled = NO;
			[pasteBtn setTitle:NSLocalizedString(@"Paste",nil)];
		}
		else
		{
			str = [NSString stringWithFormat:NSLocalizedString(@"Paste(%d)",nil), cnt];
			[pasteBtn setTitle:str];
		}
	}
	else if(renameBtn.enabled == NO)
	{
		[appDelegate.sourceData removeAllObjects];
		[pasteBtn setTitle:NSLocalizedString(@"Paste",nil)];
	}
	
	if (renameBtn.enabled)
	{
		if (appDelegate.pasteStatus == RENAMES)
		{
			str = [NSString stringWithFormat:NSLocalizedString(@"Done(%d)",nil), cnt];
			//2개추가
			[pasteBtn setTitle: NSLocalizedString(@"Cancel",nil)];
			pasteBtn.enabled =YES;
		}
		else
		{
			if ([currentFolder length] >= 9 && [[currentFolder substringToIndex:9] isEqualToString:@"/RECYCLER"])
				str = [NSString stringWithFormat:NSLocalizedString(@"Recover(%d)",nil), cnt];
			else
				str = [NSString stringWithFormat:NSLocalizedString(@"Rename(%d)",nil), cnt];
		}
		
		[renameBtn setTitle:str];
	}
	else
	{
		// if 추가
		if (appDelegate.pasteStatus == CANCEL)
		{
			[pasteBtn setTitle: NSLocalizedString(@"Paste",nil)];
			pasteBtn.enabled = NO;
			appDelegate.pasteStatus = NO;
		}
		
		if ([currentFolder length] >= 9 && [[currentFolder substringToIndex:9] isEqualToString:@"/RECYCLER"])
			[renameBtn setTitle:NSLocalizedString(@"Recover",nil)];
		else
			[renameBtn setTitle:NSLocalizedString(@"Rename",nil)];
	}
	
	if ( cnt > 0 )
	{
		UIBarButtonItem *flexibleSpace1 = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace target:nil action:nil];
		UIBarButtonItem *flexibleSpace2 = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace target:nil action:nil];
		UIBarButtonItem *flexibleSpace3 = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace target:nil action:nil];
		
		[toolbar setItems:[NSArray arrayWithObjects:copyBtn, flexibleSpace1, cutBtn, flexibleSpace2, pasteBtn, flexibleSpace3, renameBtn, nil] animated:YES];
		
		[flexibleSpace1 release];
		[flexibleSpace2 release];
		[flexibleSpace3 release];
	}
	else
	{
		UIBarButtonItem *flexibleSpace1 = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace target:nil action:nil];
		UIBarButtonItem *flexibleSpace2 = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace target:nil action:nil];
		UIBarButtonItem *flexibleSpace3 = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace target:nil action:nil];
		UIBarButtonItem *flexibleSpace4 = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace target:nil action:nil];
		
		[toolbar setItems:[NSArray arrayWithObjects:copyBtn, flexibleSpace1, cutBtn, flexibleSpace2, pasteBtn, flexibleSpace3, renameBtn, flexibleSpace4, folderBtn, nil] animated:YES];
		
		[flexibleSpace1 release];
		[flexibleSpace2 release];
		[flexibleSpace3 release];
		[flexibleSpace4 release];
	}

}

- (void) clearSelectedButton
{
    UIButton * button;
	
	for ( int i = 0; i < selectedButton.count; i++)
	{
		button = (UIButton *)[selectedButton objectAtIndex:i];
 		[button setBackgroundImage:unselectedImage forState:UIControlStateNormal];
		[button setBackgroundImage:unselectedImage forState:UIControlStateHighlighted];
	}
}

- (void) clearSelectedIndexPath
{
 	for ( int i = 0; i < m_selectedInfoArray.count; i++)
	{
 		[m_selectedInfoArray replaceObjectAtIndex:i withObject:[NSNumber numberWithBool:NO]];
 	}
}


- (void)photoClicked
{
	CentralECMAppDelegate *appDelegate = (CentralECMAppDelegate *)[[UIApplication sharedApplication] delegate];
	
	if ([UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypeCamera])
	{
		UIActionSheet	*actionSheet = [[UIActionSheet alloc]
										initWithTitle:NSLocalizedString(@"What would you like to upload to Central ECM?",nil)
										delegate:self 
										cancelButtonTitle:NSLocalizedString(@"Cancel",nil)
										destructiveButtonTitle:nil
										otherButtonTitles:NSLocalizedString(@"Take Photo",nil), NSLocalizedString(@"Record Video",nil), NSLocalizedString(@"Existing Photo or Video",nil), nil];
		
//		[actionSheet showFromTabBar:appDelegate.rootViewController.tabBar];
		[actionSheet release];
	}
	else
	{
		UIImagePickerController *picker = [[UIImagePickerController alloc] init];
		picker.delegate = self;
		picker.sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
		[self presentModalViewController:picker animated:YES];
		[picker release];
	}
}

- (void)actionSheet:(UIActionSheet *)actionSheet
didDismissWithButtonIndex:(NSInteger)buttonIndex
{
	if (buttonIndex != [actionSheet cancelButtonIndex])
	{
		if (buttonIndex == 0)
		{
			UIImagePickerController *picker = [[UIImagePickerController alloc] init];
			picker.delegate = self;
			picker.sourceType = UIImagePickerControllerSourceTypeCamera;

			// For Take Picture or Video
			//			NSArray *mediaTypes = 
			//				[UIImagePickerController availableMediaTypesForSourceType:picker.sourceType];
			//			
			//			picker.mediaTypes = mediaTypes;
			
			[self presentModalViewController:picker animated:YES];
			[picker release];
		}
		else if (buttonIndex == 1)
		{
			UIImagePickerController *picker = [[UIImagePickerController alloc] init];
			picker.delegate = self;
			picker.sourceType = UIImagePickerControllerSourceTypeCamera;
			picker.mediaTypes = [NSArray arrayWithObject:(NSString *)kUTTypeMovie];
			[self presentModalViewController:picker animated:YES];
			[picker release];
		}
		else
		{
			UIImagePickerController *picker = [[UIImagePickerController alloc] init];
			
			NSArray *mediaTypes = 
			[UIImagePickerController availableMediaTypesForSourceType:picker.sourceType];
			
			picker.delegate = self;
			picker.sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
			picker.mediaTypes = mediaTypes;
			[self presentModalViewController:picker animated:YES];
			[picker release];
		}
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

// 파일 삭제시 호출
- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{
 	if ([self  isRenaming])
		return;
	
	if (indexPath.section == 1)
		return;
	
	NSUInteger row = [indexPath row];
  	CentralECMAppDelegate *appDelegate = (CentralECMAppDelegate *)[[UIApplication sharedApplication] delegate];
  	
	if (editingStyle == UITableViewCellEditingStyleDelete)
	{
//		if ([self isFolder:row] == NO
//		   ||  
//		   [ModalActionSheet ask:NSLocalizedString(@"All files in the folder will be deleted. Would you like to proceed?", nil)
//					  withCancel:NSLocalizedString(@"Cancel", nil)
//				 withDestructive:NSLocalizedString(@"Delete", nil) 
//					 withButtons: nil
//						   where:appDelegate.rootViewController.tabBar
//			] == 0)
// 		{
// 			[self deleteFile:row];
//			[self refreshData];
//			
//			//[table deleteRowsAtIndexPaths:[NSArray arrayWithObject:indexPath] withRowAnimation:YES];
//		}
		
		[self clearSelectedIndexPath];
		[self clearSelectedButton];
		[self renderCopyCutPasteButton:@"toggleButton"];
	}   
}

#pragma mark -
#pragma mark common

- (void)viewDidLoad 
{
    [super viewDidLoad];

	m_selectedInfoArray = [ [ NSMutableArray alloc] init ];
	selectedButton = [ [ NSMutableArray alloc] init ];

	if ( self.folderDepth == 0)
	{
 		self.folderDepth = 1;
	}

 	self.selectedImage	= [[[UIImage imageNamed:@"selected.png"] stretchableImageWithLeftCapWidth:40.0f topCapHeight:0.0f] retain];  
 	self.unselectedImage = [[[UIImage imageNamed:@"unselected.png"] stretchableImageWithLeftCapWidth:40.0f topCapHeight:0.0f] retain];  
 	self.folderImage = [UIImage imageNamed:@"folder.png"];
 	self.recyclerImage = [UIImage imageNamed:@"recycler.png"];
  	self.fileImage  = [NSDictionary dictionaryWithObjectsAndKeys:
					   [UIImage imageNamed:@"file_ai.png"],				@"ai",
					   [UIImage imageNamed:@"file_ais.png"],			@"ais",
					   [UIImage imageNamed:@"file_alz.png"],			@"alz",
					   [UIImage imageNamed:@"file_arj.png"],			@"arj",
					   [UIImage imageNamed:@"file_asf.png"],			@"asf",
					   [UIImage imageNamed:@"file_asp.png"],			@"asp",
					   [UIImage imageNamed:@"file_avi.png"],			@"avi",
					   [UIImage imageNamed:@"file_bak.png"],			@"bak",
					   [UIImage imageNamed:@"file_bat.png"],			@"bat",
					   [UIImage imageNamed:@"file_bmp.png"],			@"bmp",
					   [UIImage imageNamed:@"file_cab.png"],			@"cab",
					   [UIImage imageNamed:@"file_cda.png"],			@"cad",
					   [UIImage imageNamed:@"file_com.png"],			@"com",
					   [UIImage imageNamed:@"file_css.png"],			@"css",
					   [UIImage imageNamed:@"file_doc.png"],			@"doc",
					   [UIImage imageNamed:@"file_docx.png"],			@"docx",
					   [UIImage imageNamed:@"file_dwg.png"],			@"dwg",
					   [UIImage imageNamed:@"file_egg.png"],			@"egg",
					   [UIImage imageNamed:@"file_eml.png"],			@"eml",
					   [UIImage imageNamed:@"file_eps.png"],			@"eps",
					   [UIImage imageNamed:@"file_etc.png"],			@"unknown",
					   [UIImage imageNamed:@"file_exe.png"],			@"exe",
					   [UIImage imageNamed:@"file_fla.png"],			@"fla",
					   [UIImage imageNamed:@"file_flv.png"],			@"flv",
					   [UIImage imageNamed:@"file_fmp.png"],			@"fmp",
					   [UIImage imageNamed:@"file_fxg.png"],			@"fxg",
					   [UIImage imageNamed:@"file_gif.png"],			@"gif",
					   [UIImage imageNamed:@"file_gz.png"],				@"gz",
					   [UIImage imageNamed:@"file_htm.png"],			@"htm",
					   [UIImage imageNamed:@"file_html.png"],			@"html",
					   [UIImage imageNamed:@"file_hwp.png"],			@"hwp",
					   [UIImage imageNamed:@"file_ico.png"],			@"ico",
					   [UIImage imageNamed:@"file_iff.png"],			@"iff",
					   [UIImage imageNamed:@"file_ini.png"],			@"ini",
					   [UIImage imageNamed:@"file_ink.png"],			@"ink",
					   [UIImage imageNamed:@"file_jas.png"],			@"jas",
					   [UIImage imageNamed:@"file_jpg.png"],			@"jpg",
					   [UIImage imageNamed:@"file_js.png"],				@"js",
					   [UIImage imageNamed:@"file_jsp.png"],			@"jsp",
					   [UIImage imageNamed:@"file_k3g.png"],			@"k3g",
					   [UIImage imageNamed:@"file_kmp.png"],			@"kmp",
					   [UIImage imageNamed:@"file_md.png"],				@"md",
					   [UIImage imageNamed:@"file_mid.png"],			@"mid",
					   [UIImage imageNamed:@"file_mka.png"],			@"mka",
					   [UIImage imageNamed:@"file_mkv.png"],			@"mkv",
					   [UIImage imageNamed:@"file_mmf.png"],			@"mmf",
					   [UIImage imageNamed:@"file_mov.png"],			@"mov",
					   [UIImage imageNamed:@"file_mp3.png"],			@"mp3",
					   [UIImage imageNamed:@"file_mp4.png"],			@"mp4",
					   [UIImage imageNamed:@"file_mpeg.png"],			@"mpeg",
					   [UIImage imageNamed:@"file_mpg.png"],			@"mpg",
					   [UIImage imageNamed:@"file_ogg.png"],			@"ogg",
					   [UIImage imageNamed:@"file_pak.png"],			@"pak",
					   [UIImage imageNamed:@"file_pcx.png"],			@"pcx",
					   [UIImage imageNamed:@"file_pdd.png"],			@"pdd",
					   [UIImage imageNamed:@"file_pdf.png"],			@"pdf",
					   [UIImage imageNamed:@"file_pdp.png"],			@"pdp",
					   [UIImage imageNamed:@"file_php.png"],			@"php",
					   [UIImage imageNamed:@"file_pif.png"],			@"pif",
					   [UIImage imageNamed:@"file_png.png"],			@"png",
					   [UIImage imageNamed:@"file_ppt.png"],			@"ppt",
					   [UIImage imageNamed:@"file_pptx.png"],			@"pptx",
					   [UIImage imageNamed:@"file_psd.png"],			@"psd",
					   [UIImage imageNamed:@"file_pxr.png"],			@"pxr",
					   [UIImage imageNamed:@"file_ra.png"],				@"ra",
					   [UIImage imageNamed:@"file_rar.png"],			@"rar",
					   [UIImage imageNamed:@"file_raw.png"],			@"raw",
					   [UIImage imageNamed:@"file_s3m.png"],			@"s3m",
					   [UIImage imageNamed:@"file_skm.png"],			@"skm",
					   [UIImage imageNamed:@"file_smi.png"],			@"smi",
					   [UIImage imageNamed:@"file_swf.png"],			@"swf",
					   [UIImage imageNamed:@"file_tgz.png"],			@"tgz",
					   [UIImage imageNamed:@"file_tif.png"],			@"tif",
					   [UIImage imageNamed:@"file_tp.png"],				@"tp",
					   [UIImage imageNamed:@"file_ts.png"],				@"ts",
					   [UIImage imageNamed:@"file_ttf.png"],			@"ttf",
					   [UIImage imageNamed:@"file_txt.png"],			@"txt",
					   [UIImage imageNamed:@"file_vob.png"],			@"vob",
					   [UIImage imageNamed:@"file_wav.png"],			@"wav",
					   [UIImage imageNamed:@"file_wma.png"],			@"wma",
					   [UIImage imageNamed:@"file_wmv.png"],			@"wmv",
					   [UIImage imageNamed:@"file_xls.png"],			@"xls",
					   [UIImage imageNamed:@"file_xlsx.png"],			@"xlsx",
					   [UIImage imageNamed:@"file_xml.png"],			@"xml",
					   [UIImage imageNamed:@"file_zip.png"],			@"zip",
					   [UIImage imageNamed:@"file_zool.png"],			@"zool",
					   nil];
}

- (void)viewWillAppear:(BOOL)animated
{
	[super viewWillAppear:animated];
	
	[table deselectRowAtIndexPath:m_selectedIndexPath animated:YES];
}

- (void)viewDidDisappear:(BOOL)animated
{
	[super viewDidDisappear:NO];
}
 
- (void)didReceiveMemoryWarning
{
	// Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
	
	// Release any cached data, images, etc that aren't in use.
}

- (void)viewDidUnload {
	// Release any retained subviews of the main view.
	// e.g. self.myOutlet = nil;
}

- (void)dealloc {
 
	if (selectedImage != nil)
		selectedImage = nil;
	if (unselectedImage != nil)
		unselectedImage = nil;
 	if (folderImage != nil)
		folderImage = nil;
	if (recyclerImage != nil)
		recyclerImage = nil;
 	if (fileImage != nil)
		fileImage = nil;
	if (copyBtn != nil)
		copyBtn = nil;
	if (cutBtn != nil)
		cutBtn = nil;
	if (pasteBtn != nil)
		pasteBtn = nil;
	if (renameBtn != nil)
		renameBtn = nil;
 	if (m_fileInfoArray  != nil)
		m_fileInfoArray = nil;
	if (m_selectedInfoArray != nil)
		m_selectedInfoArray = nil;
	if (selectedButton != nil)
		selectedButton = nil;
 	if (currentFolder != nil)
		currentFolder = nil;
 	
    [super dealloc];
}


@end

