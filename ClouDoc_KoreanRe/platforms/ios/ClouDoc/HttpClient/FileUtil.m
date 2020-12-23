//
//  FileUtil.m
//  CentralECM
//
//  Created by HeungKyoo Han on 10. 06. 06.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import "FileUtil.h"

@implementation FileUtil

- (NSString *) getFilename: (NSString *)fileName
{
	const char *utf8str = [fileName UTF8String];
	NSString * str = [NSString stringWithUTF8String:utf8str];
	NSData * data = [str dataUsingEncoding: CFStringConvertEncodingToNSStringEncoding(kCFStringEncodingEUC_KR)];

	char euckr[1024];
	memset(euckr, 0x00, 1024);
	memcpy(euckr, [data bytes], [data length]);
	
	NSString *filename = [NSString stringWithCString:euckr encoding:0x80000003]; 
	
	return filename;
}

- (NSString *) getFormattedSpeed: (long long) totalBytesWritten 
							time: (int) elapsedTime
{
	long long	cps = totalBytesWritten*1000/elapsedTime;
	
	NSString	*string1;
	NSString	*scale[2] = {@"CPS", @"K CPS"};
	int			idx = 0;
	
	// B
	if (cps < 1024)
	{
		idx = 0;
		string1 = [NSString stringWithFormat:@"%d", cps];
	}
	// KB
	else
	{
		idx = 1;
		string1 = [NSString stringWithFormat:@"%.2f", cps/1024.0];
	}
	
	NSNumberFormatter *formatter = [[NSNumberFormatter alloc] init]; 
	[formatter setNumberStyle:NSNumberFormatterDecimalStyle];
	NSNumber *number = [[NSNumber alloc] initWithFloat:[string1 floatValue]];
	NSString *string2 = [NSString stringWithFormat:@"%@%@", [formatter stringFromNumber:number], scale[idx]];
	[formatter release];
	
	return string2;
}

- (NSString *) getFormattedSize: (long long) size
{
	NSString	*string1;
	NSString	*scale[5] = {@"B", @"KB", @"MB", @"GB", @"TB"};
	int			idx = 0;
	
	// B
	if (size < 1024)
	{
		idx = 0;
		string1 = [NSString stringWithFormat:@"%d", size];
	}
	// KB
	else if (size < 1024 * 1024)
	{
		idx = 1;
		string1 = [NSString stringWithFormat:@"%.2f", size/1024.0];
	}
	// MB
	else if (size < 1024 * 1024 * 1024)
	{
		idx = 2;
		string1 = [NSString stringWithFormat:@"%.2f", size/(1024.0*1024.0)];
	}
	// GB
	else if (size / 1024 < 1024 * 1024 * 1024)
	{
		idx = 3;
		string1 = [NSString stringWithFormat:@"%.2f", size/(1024.0*1024.0*1024.0)];
	}
	// TB
	else
	{
		idx = 4;
		string1 = [NSString stringWithFormat:@"%.2f", size/(1024.0*1024.0*1024.0*1024.0)];
	}

	NSNumberFormatter *formatter = [[NSNumberFormatter alloc] init]; 
	[formatter setNumberStyle:NSNumberFormatterDecimalStyle];
	NSNumber *number = [[NSNumber alloc] initWithFloat:[string1 floatValue]];
	NSString *string2 = [NSString stringWithFormat:@"%@%@", [formatter stringFromNumber:number], scale[idx]];
	[formatter release];
		
	return string2;
}

- (BOOL) isExist: (NSString *) filePath
{
	NSLog(@"isFolder %@", filePath);
	
	NSFileManager *fileMgr = [NSFileManager defaultManager];
	
	BOOL	isDir;
	return [fileMgr fileExistsAtPath:filePath isDirectory: &isDir];
}

- (BOOL) isFolder: (NSString *) filePath
{
	NSLog(@"isFolder %@", filePath);
	
	NSFileManager *fileMgr = [NSFileManager defaultManager];
	
	BOOL	isDir;
	
	[fileMgr fileExistsAtPath:filePath isDirectory: &isDir];
	
	return isDir;
}

- (NSString *) getTmpFolder
{
	NSArray * DocumentDirectories = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
	NSString * tmpFolder = [[DocumentDirectories objectAtIndex:0] stringByAppendingPathComponent:@".tmp"];
	NSLog(@"tmpFolder is %@", tmpFolder);
	NSFileManager *fileMgr = [NSFileManager defaultManager];
	
	BOOL	isDir;
	
	if ([fileMgr fileExistsAtPath:tmpFolder isDirectory: &isDir])
	{
		if (!isDir)
			[fileMgr removeItemAtPath:tmpFolder error:nil];
	}
	
	[fileMgr createDirectoryAtPath:tmpFolder withIntermediateDirectories:YES attributes:nil error:nil];
	
	return tmpFolder;
}

- (NSString *) getLocalUserFolder: (NSString *)UserFolderPath {
    //NSArray * DocumentDirectories = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
	//NSString * UserFolder = [[DocumentDirectories objectAtIndex:0] stringByAppendingPathComponent:@"/"];
    //UserFolder = [[DocumentDirectories objectAtIndex:0] stringByAppendingPathComponent:User];
	NSLog(@"UserFolderPath is %@", UserFolderPath);
	NSFileManager *fileMgr = [NSFileManager defaultManager];
	
	BOOL	isDir;
	
	if ([fileMgr fileExistsAtPath:UserFolderPath isDirectory: &isDir])
	{
		if (!isDir)
			[fileMgr removeItemAtPath:UserFolderPath error:nil];
	}
	
	[fileMgr createDirectoryAtPath:UserFolderPath withIntermediateDirectories:YES attributes:nil error:nil];
	
	return UserFolderPath;
}

- (CFileInfo *) getFileInfo: (NSString *)filePath
{
	NSLog(@"getFileInfo: %@", filePath);
	CFileInfo * fileInfo = [CFileInfo alloc];
	
	fileInfo.m_strName = [NSMutableString stringWithString: [filePath lastPathComponent]];
	
	NSDate * modDate = nil;
	fileInfo.m_n64Size = [self getLength:filePath modDate:&modDate];

	if (modDate)
		fileInfo.m_dtLastWriteTime = [NSString stringWithString:[modDate description]];
	
	return fileInfo;
}

- (NSData *) getData: (NSString *) filePath
{
	NSLog(@"getData: %@", filePath);
	NSFileManager * fileManager = [NSFileManager defaultManager];
	NSData * data = [[NSData alloc] initWithData:[fileManager contentsAtPath:filePath]]; 
	
	return data;
}

- (long long) getLength: (NSString *) filePath 
{
	NSUInteger length = 0;
	NSError *fileError = NULL;
	
	NSFileManager * fileManager = [NSFileManager defaultManager];
	NSDictionary * fileAttributes = [fileManager attributesOfItemAtPath:filePath error:&fileError];
	
	if ( fileError != NULL )
	{
#ifdef DEBUG
		NSLog(@"FileUtil.getLength(Error) : %s", fileError);
#endif
	}
	
	if (fileAttributes != nil)
	{
		NSNumber * fileSize = [fileAttributes objectForKey:NSFileSize];
		length = [fileSize longLongValue];
	}
	
	NSLog(@"getLength: filePath: %@,%qi", filePath, length);
	
	return length; 
}

- (long long) getLength: (NSString *) filePath 
				modDate: (NSDate **) modDate
{
	NSUInteger		length = 0;
	NSError			*fileError = NULL;
	
	NSFileManager	*fileManager = [NSFileManager defaultManager];
	NSDictionary	*fileAttributes = [fileManager attributesOfItemAtPath:filePath error:&fileError];
	
	if ( fileError != NULL )
	{
#ifdef DEBUG
		NSLog(@"Error : fileUtil.getLength.modDate : %s", fileError);
#endif
	}
	
	if (fileAttributes != nil)
	{
		NSNumber * fileSize = [fileAttributes objectForKey:NSFileSize];
		length = [fileSize longLongValue];
		
		*modDate = [fileAttributes objectForKey:NSFileModificationDate];
	}
	
	NSLog(@"filePath: %@:%qi", filePath, length);
	
	return length; 
}

- (NSString *) getDocumentFolder
{
	NSArray		* paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
	NSString	* documentFolder = [[NSString alloc] initWithString:[paths objectAtIndex:0]];
	
	return documentFolder;
}

- (BOOL) deleteFile: (NSString *) filePath
{
	NSLog(@"deleteFile: %@", filePath);
	
	if (filePath == nil)
		return FALSE;
	
	NSFileManager * fileMgr = [NSFileManager defaultManager];
	
	NSError	*error;
	
	BOOL bret = [fileMgr removeItemAtPath:filePath error:&error];
	
	NSLog(@"deleteFile: bret: %d", bret);
	
	return bret;
}

- (BOOL) moveFile: (NSString *) srcPath 
		  dstPath: (NSString *) dstPath
{
	NSFileManager * fileMgr = [NSFileManager defaultManager];
	
	NSLog(@"moveFile: srcPath:%@, dstPath:%@", srcPath, dstPath);
	
	BOOL bStat = NO;
	int dwError = 0;
	
	if ([fileMgr fileExistsAtPath:srcPath])
	{
		bStat = YES;
		
		if ([fileMgr fileExistsAtPath:dstPath] )
			bStat = [fileMgr removeItemAtPath:dstPath  error: NULL];
		
		if (bStat)
			bStat = [fileMgr moveItemAtPath:srcPath toPath:dstPath error: NULL];
		
		if (bStat == NO)
			dwError = errno;
	}
	
	return bStat;
}

- (BOOL) copyFile: (NSString *) srcPath 
		  dstPath: (NSString *) dstPath
{
	NSFileManager * fileMgr = [NSFileManager defaultManager];

	// 같은 이름의 파일이 있으면 이름을 수정한다.
	while (YES)
	{
		if ([fileMgr fileExistsAtPath:dstPath] )
		{
			if ([[dstPath pathExtension] isEqual:@""] )
				dstPath = [NSString stringWithFormat: NSLocalizedString(@"%@_copy", nil), dstPath];
			else
				dstPath = [NSString stringWithFormat: NSLocalizedString(@"%@_copy.%@", nil), [dstPath stringByDeletingPathExtension], [dstPath pathExtension]];
		}
		else
			break;
	}

	NSLog(@"srcPath:%@, dstPath:%@", srcPath, dstPath);
	
	BOOL bStat = NO;
	int dwError = 0;

	if ([fileMgr fileExistsAtPath:srcPath])
	{
		bStat = YES;
		
		if ([fileMgr fileExistsAtPath:dstPath] )
			bStat = [fileMgr removeItemAtPath:dstPath  error: NULL];
	
		if (bStat)
			bStat = [fileMgr copyItemAtPath:srcPath toPath:dstPath error: NULL];

		if (bStat == NO)
			dwError = errno;
	}

	return bStat;
}

@end
