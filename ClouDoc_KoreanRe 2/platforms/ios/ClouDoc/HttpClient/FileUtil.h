//
//  FileUtil.h
//  CentralECM
//
//  Created by HeungKyoo Han on 10. 06. 06.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "ServerCmd.h"
@interface FileUtil : NSObject {

}

- (NSString *) getFilename: (NSString *)fileName;

- (NSString *) getFormattedSpeed: (long long) totalBytesWritten 
							time: (int) elapsedTime;

- (NSString *) getFormattedSize: (long long) size;

- (BOOL) isExist: (NSString *) filePath;

- (BOOL) isFolder: (NSString *) filePath;

- (NSString *) getTmpFolder;

- (NSString *) getLocalUserFolder: (NSString *)UserFolderPath;

- (NSString *) getDocumentFolder;

- (BOOL) deleteFile: (NSString *) filePath;

- (BOOL) moveFile: (NSString *) srcPath 
		  dstPath: (NSString *) dstPath;

- (BOOL) copyFile: (NSString *) srcPath 
		  dstPath: (NSString *) dstPath;

- (long long) getLength: (NSString *) filePath;

- (long long) getLength: (NSString *) filePath 
				modDate: (NSDate **) modDate;

- (NSData *) getData: (NSString *) fileName;

- (CFileInfo *) getFileInfo: (NSString *) filePath;

@end

extern FileUtil	* g_FileUtil;