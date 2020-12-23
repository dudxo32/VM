//
//  FolderViewController.h
//  CentralECM
//
//  Created by HeungKyoo Han 10. 04. 21.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <MobileCoreServices/UTCoreTypes.h>
#import "ServerCmd.h"

#define	kCellHeight						50

#define kCellButtonTag					1001
#define kCellImageTag					1002
#define kCellFileNameTag				1003
#define kCellFileInfoTag				1004

#define kCellButtonRect					CGRectMake(5.0, 5.0, 40.0, 40.0)
#define kCellImageRect					CGRectMake(50.0, 5.0, 40.0, 40.0)
#define kCellFileNameRect				CGRectMake(100.0, 3.0, 200.0, 25.0) 
#define kCellFileInfoRect				CGRectMake(100.0, 30.0, 200.0, 15.0)

@class TTPhotoViewController;
 
// Super Class of Server View and Client View Class
@interface FolderViewController : UIViewController 
	<UITextFieldDelegate, UIActionSheetDelegate, UIImagePickerControllerDelegate, UINavigationControllerDelegate>
{
	UITableView		*table;
	
 	UIImage			*selectedImage;  
	UIImage			*unselectedImage;
 	UIImage			*folderImage; 
	UIImage			*recyclerImage;
	NSDictionary	*fileImage;				// image 클릭시 보여질 image list
	UIAlertView		*alert;

	BOOL			isOn;
	BOOL			m_bRefresh;
	
	// 현재 폴더에 있는 폴더와 파일 목록
	NSMutableArray		*m_fileInfoArray;
	// 선택된 파일 리스트
	NSMutableArray		*m_selectedInfoArray;
	
	// 현재 드라이브 인덱스 (서버)
	NSUInteger			m_nSelectedDrive;
	// 선택된 인덱스
	NSIndexPath			*m_selectedIndexPath;
	NSMutableArray		*selectedButton;
 	NSString			*currentFolder;
	NSInteger			folderDepth;
	
	IBOutlet UIToolbar			*toolbar;
	IBOutlet UIBarButtonItem	*copyBtn;
	IBOutlet UIBarButtonItem	*cutBtn;
	IBOutlet UIBarButtonItem	*pasteBtn;
	IBOutlet UIBarButtonItem	*renameBtn;
	IBOutlet UIBarButtonItem	*folderBtn;

 	// 테이블 뷰에서 사용자가 클릭한 row
	NSUInteger				m_nSelectedRow;
	// 현재 공유 폴더 인덱스
	NSUInteger				m_nShareFolder;
	// 공유 폴더 2 레벨 공유 Path
	NSString				* m_sharePath;

	// 파일 복사/이동 숫자
	NSUInteger	m_addCount;
	// Synchronization object
	NSCondition				* m_condition;
	BOOL					m_bFinished;
	BOOL					m_bGetFile;
	BOOL					m_bCancel;
	BOOL					m_bError;
    NSString                *m_strFilePath;
}

-(void) cancel;

-(id) init;

-(BOOL) isRecycler:(NSInteger) row;
-(BOOL) isFolder:(NSInteger) row;
-(void) pushFolder:(NSInteger) row;
-(BOOL) deleteFile:(NSInteger)row;
-(void) refreshListData;
-(NSString *) getFileName: (NSMutableArray *) fileInfoList 
					  row: (NSUInteger) row;
-(NSString *) getFilePath: (NSMutableArray *) fileInfoList 
					  row: (NSUInteger) row;

-(IBAction) onCreateFolder;
-(IBAction) onCopy;
-(IBAction) onCut;
-(IBAction) onPaste;
-(IBAction) onRename;

- (void) doneRename:(NSInteger) row;
- (BOOL) renameFile:(NSString *)srcPath 
		  toPath:(NSString *)dstPath;
- (NSInteger) getSelectedCount ;
- (void) focusAfterDelay:(id) row;
- (void) deselect: (NSNumber *) rownum ;
- (void) select:(int)count;
- (void) removeFromCellData:(NSString *)fileName;
- (void) addToCellData:(CFileInfo *)fileInfo;
- (void) removeItem: (NSUInteger) index;
- (void) clearRenameButton;
- (void) renderCopyCutPasteButton:(NSString *)which;
- (void) clearSelectedButton;
- (void) clearSelectedIndexPath ;
- (void) clearSelectedTextField;
- (void) refreshData;
- (BOOL) isRenaming;
- (BOOL) isSelectedIndexPath:(NSInteger) row;
- (void) imagePickerControllerDidCancel:(UIImagePickerController *)picker;
- (void) photoClicked;
- (void) actionSheet:(UIActionSheet *)actionSheet
   didDismissWithButtonIndex:(NSInteger)buttonIndex;
- (void) tableView: (UITableView *) tableView 
commitEditingStyle: (UITableViewCellEditingStyle) editingStyle 
 forRowAtIndexPath: (NSIndexPath *) indexPath;
- (NSInteger) createSourceImage:(NSInteger) row;
- (CFileInfo *) getShareFolder;
- (NSString *) getSharePath;

@property (nonatomic, assign) BOOL				m_bRefresh;
@property (nonatomic, assign) BOOL				m_bFinished;
@property (nonatomic, retain) IBOutlet UITableView *table;
@property (nonatomic, retain) UIImage			*selectedImage;
@property (nonatomic, retain) UIImage			*unselectedImage;
@property (nonatomic, retain) UIImage			*recyclerImage;
@property (nonatomic, retain) UIImage			*folderImage;
@property (nonatomic, retain) NSDictionary		*fileImage;
@property (nonatomic, retain) UIBarButtonItem	*copyBtn;
@property (nonatomic, retain) UIBarButtonItem	*cutBtn;
@property (nonatomic, retain) UIBarButtonItem	*pasteBtn;
@property (nonatomic, retain) UIBarButtonItem	*renameBtn;
@property (nonatomic, retain) UIBarButtonItem	*folderBtn;
@property (nonatomic, retain) NSArray			*m_fileInfoArray;
@property (nonatomic, retain) NSMutableArray	*m_selectedInfoArray;
@property (nonatomic, retain) NSMutableArray	*selectedButton;
@property (nonatomic, retain) NSString			*currentFolder;
@property (nonatomic, assign) NSInteger			folderDepth;
@property (nonatomic, assign) NSUInteger		m_nSelectedDrive;

@property (nonatomic, assign) NSUInteger	m_nShareFolder;
@property (nonatomic, retain) NSString		* m_sharePath;

@property (nonatomic, retain) NSString		* m_strFilePath;

@end
