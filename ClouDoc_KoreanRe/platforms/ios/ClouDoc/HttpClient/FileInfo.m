//
//  FileInfo.m
//  CentralECM
//
//  Created by HeungKyoo Han on 10. 05. 24.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

// CFileInfo 선언은 ServerCmd.h에 있습니다.
#import "ServerCmd.h"

@implementation CFileInfo

@synthesize m_strName;
@synthesize m_n64Size;
@synthesize m_dwACL;
@synthesize m_dwAttrib;
@synthesize	m_dtLastWriteTime;

@synthesize m_strDiskType;
@synthesize m_diskType;
@synthesize	m_strOwner;
@synthesize	m_strFileServer;
@synthesize	m_strPartition;
@synthesize	m_stShare;

// CFileInfo 복사
- (CFileInfo *) initWithCFileInfo: (CFileInfo *) fileInfo
{
	self = [super init];
	
	if (self)
	{
		if (fileInfo.m_strName)
			m_strName = [[NSString alloc] initWithString: fileInfo.m_strName];
		
		m_n64Size = fileInfo.m_n64Size;
		m_dwACL = fileInfo.m_dwACL;
		m_dwAttrib = fileInfo.m_dwAttrib;
		
		if (fileInfo.m_dtLastWriteTime)
			m_dtLastWriteTime = [[NSString alloc] initWithString: fileInfo.m_dtLastWriteTime];
		
		if (m_strDiskType)
			m_strDiskType = [[NSString alloc] initWithString: fileInfo.m_strDiskType];
		
		m_diskType = fileInfo.m_diskType;
		
		if (fileInfo.m_strName)
			m_strOwner = [[NSString alloc] initWithString:fileInfo.m_strName];
	
		if (fileInfo.m_strFileServer)
			m_strFileServer = [[NSString alloc] initWithString:fileInfo.m_strFileServer];
		
		if (fileInfo.m_strPartition)
			m_strPartition = [[NSString alloc] initWithString:fileInfo.m_strPartition];
		
		if (m_stShare)
			m_stShare = [[NSString alloc] initWithString:fileInfo.m_stShare];
	}
	
	return self;
}

@end
