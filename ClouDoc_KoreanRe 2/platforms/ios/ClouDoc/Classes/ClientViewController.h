//
//  ClientViewController.h
//  CentralECM
//
//  Created by HeungKyoo Han on 10. 04. 18.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "FolderViewController.h"

@interface ClientViewController : FolderViewController
{
	// 문서 뷰어에서 보고 있는 파일
	// 문서 뷰어에서 Save를 누르면 이 파일을 서버로 업로드한다.
	NSString	* m_filePath;
	
	// 폴더에 있는 파일 리스트를 얻을 때 요청 폴더 이름
	NSString	* m_folderName;
}

//-(NSString *) getEuckr: (NSString *) s;

-(void) didFinishGetList: (NSString *) errmsg 
			fileInfoArray: (NSMutableArray *) fileInfoArray;

-(void) didFinishDeleteFile: (NSString *) errmsg 
				   filePath: (NSString *) filePath;

-(void) onSave:(id) sender;

-(void) pushFolder:(NSInteger) row;

-(BOOL) copyFile:(NSString *)srcPath 
		  toPath:(NSString *)dstPath;

-(BOOL) moveFile:(NSString *)srcPath 
		  toPath:(NSString *)dstPath;

-(BOOL) fileExistsAtPath:(NSString *)fileName;
-(void)onPaste: (NSMutableArray *) sourceData;
@end

 
