//
//  DownLoadFiles.h
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
@interface DownLoadFiles : NSObject{
    
    // 문서 뷰어에서 보고 있는 파일
    // 문서 뷰어에서 Save를 누르면 이 파일을 서버로 업로드한다.
    NSString	* m_filePath;
    
    // 폴더에 있는 파일 리스트를 얻을 때 요청 폴더 이름
    NSString	* m_folderName;
    
    BOOL					m_bFinished;
    BOOL					m_bGetFile;
    BOOL					m_bCancel;
    BOOL                    m_bError;
    CentralECMAppDelegate    *appDelegate;
    
    NSUInteger	m_addCount;

}
- (void) didFinishGetFile: (NSString *) errmsg 
				 filePath: (NSString *) filePath;
- (NSString *)   downloadFile: (CentralECMAppDelegate *) g_appDelegate
                      ActView: (ActivityViewController *) ActViewCtl;
- (NSString *)   downloadFile_phone: (CentralECMAppDelegate *) g_appDelegate
                      ActView: (ActivityViewController_phone *) ActViewCtl;
- (void) cancel;
@end
