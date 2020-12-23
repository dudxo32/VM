//
//  UploadFiles.h
//  CECMPad
//
//  Created by 넷아이디 on 12. 1. 18..
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "FolderViewController.h"
#import "CentralECMAppDelegate.h"
#import "AppDelegate.h"
#import "ActivityViewController.h"
#import "ActivityViewController_phone.h"
@interface UploadFiles : NSObject{
    // rename과 folder 생성을 구별하기 위하여 사용 (folder 생성의 경우 가상의 폴더를 테이블 뷰에 생성한 후 rename을 하게 된다.
	// rename후 실제 rename인지 folder 생성인지를 m_nCmdType을 보고 판단한다.
	NSUInteger		m_nCmdType;
	// 공유 폴더 1 레벨 정보
	NSString		*m_filePath;
	
	// 업로드시 이펙트가 들어가는 폴더 이름들
	// 폴더가 업로드되거나 폴더 안에 있는 파일이 업로드 되는 경우
	NSMutableArray	*m_folderInfoArray;
    
    BOOL					m_bFinished;
    BOOL					m_bGetFile;
    BOOL					m_bCancel;
    BOOL                    m_bError;
    BOOL                    m_bOverwrite;
    CentralECMAppDelegate    *appDelegate;
    
    NSUInteger	m_addCount;
}

- (NSString *)   UploadFiles: (CentralECMAppDelegate *) g_appDelegate
                     ActView: (ActivityViewController *) ActViewCtl;
- (NSString *)   UploadFiles_phone: (CentralECMAppDelegate *) g_appDelegate
                     ActView: (ActivityViewController_phone *) ActViewCtl;
-(void) cancel;
@end
