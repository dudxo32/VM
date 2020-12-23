//
//  ServerViewController.h
//  CentralECM
//
//  Created by HeungKyoo Han on 10. 04. 18.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <Cordova/CDVViewController.h>
#import "FolderViewController.h"
#import "ServerCmd.h"
#import "AppDelegate.h"
#import "ActivityViewController.h"
#import "ActivityViewController_phone.h"
@interface ServerViewController : FolderViewController 
{
	// rename과 folder 생성을 구별하기 위하여 사용 (folder 생성의 경우 가상의 폴더를 테이블 뷰에 생성한 후 rename을 하게 된다.
	// rename후 실제 rename인지 folder 생성인지를 m_nCmdType을 보고 판단한다.
	NSUInteger		m_nCmdType;
	// 공유 폴더 1 레벨 정보
	NSString		*m_filePath;
	
	// 업로드시 이펙트가 들어가는 폴더 이름들
	// 폴더가 업로드되거나 폴더 안에 있는 파일이 업로드 되는 경우
	NSMutableArray	*m_folderInfoArray;
    
    CentralECMAppDelegate    *appDelegate;
}

//@property (nonatomic, retain) CFileInfo	*m_fileInfo;

// 서버에 folder 목록 등을 요청한 후 ServerCmd에서 호출한다.
- (void) didFinishGetList: (NSString *) errmsg 
			fileInfoArray: (NSMutableArray *) fileInfoArray;
- (void) didFinishRefresh: (NSString *) errmsg 
			fileInfoArray: (NSMutableArray *) fileInfoArray;
- (void) didFinishRenameFile: (NSString *) errmsg;
- (void) didFinishCreateDir: (NSString *) errmsg 
				   fileInfo: (CFileInfo *) fileInfo;
- (void) didFinishDeleteFile: (NSString *) errmsg
					filePath: (NSString *) filePath;
- (void) didFinishFileOp: (NSString *) errmsg
				fileInfo: (CFileInfo *) object;
- (void) didFinishGetImage: (NSString *) errmsg 
				 filePath: (NSString *)filePath;
- (void) didFinishGetFile: (NSString *) errmsg 
				 filePath: (NSString *)filePath;
- (void) didFinishPutFile: (NSString *) errmsg 
				 fileInfo: (CFileInfo *) object;

- (BOOL) deleteFile: (NSInteger) row;

- (BOOL) renameFile: (NSString *)srcPath 
			 toPath: (NSString *)dstPath;

- (void) refreshClicked;

- (int) findFileInfo: (NSString *) fileName;

- (NSString *) downFileOpen: (CentralECMAppDelegate *) g_appDelegate
                    ActView: (ActivityViewController *) ActViewCtl;
- (NSString *) downFileOpen_phone: (CentralECMAppDelegate *) g_appDelegate
                    ActView: (ActivityViewController_phone *) ActViewCtl;

@end
