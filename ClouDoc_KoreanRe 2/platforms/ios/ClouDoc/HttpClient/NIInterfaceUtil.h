//
//  NIInterfaceUtil.h
//  CentralECM
//
//  Created by Rusa on 10. 11. 26..
//  Copyright 2010 NetID ., Ltd. All rights reserved.
//


typedef enum _OPTION
{
	COOKIE_OPT_PERSONAL				= 0X00000001,	// 개인
	COOKIE_OPT_USER_GUESTID			= 0x00000002,	// 게스트아이디 (개인)
	COOKIE_OPT_ORGCOWORK_GUESTID	= 0x00000004,	// 게스트아이디 (부서코웍)
} OPTION;


typedef enum _DiskType
{
	DT_PERSONAL		= 0x00,			// 개인
	DT_COWORK,						// Reserved
	DT_ORGCOWORK,					// 부서
	DT_SHARE,						// 공유
	DT_ORGCOWORKSHARE,				// Reserved 코웍에 기반을 둔 공유
	DT_USERGUEST,					// Reserved
	DT_COWORKGUEST,					// Reserved
	DT_ORGCOWORKGUEST,				// Reserved
	DT_MESSENGER,					// Reserved
	DT_EMAIL,						// Reserved
	DT_HOMEPARTITION,				// 개인(관리자용)
	
} DiskType;





@interface NIInterfaceUtil : NSObject {

}

@end


@interface NIDriveInfo : NSObject
{
@public
	NSString	*m_strName;
	NSString	*m_strAssignedDrive;
	NSString	*m_strOwner;
	NSString	*m_strOwnerType;
	NSString	*m_strFileServer;
    NSString    *m_strFileServerPort;
	NSString	*m_strPartition;
	NSString	*m_strStartPath;
	NSString	*m_strOrgName;
	NSString	*m_strOrgCode;
    NSString    *m_strOverwrite;
    NSString    *m_strFileServerProtocol;
    NSString    *m_strFlag;
	DiskType	m_nDiskType;
//	NSString    *m_strDiskType;
    
	// DiskInfo
	long long	m_nTotalSpace;
	long long	m_nAvailableSpace;
    
    //localcurrentpath
    NSString    *m_strCurrentPath;
    
}

@property (nonatomic, retain) NSString	*m_strName;
@property (nonatomic, retain) NSString	*m_strAssignedDrive;
@property (nonatomic, retain) NSString	*m_strOwner;
@property (nonatomic, retain) NSString	*m_strOwnerType;
@property (nonatomic, retain) NSString	*m_strFileServer;
@property (nonatomic, retain) NSString	*m_strFileServerProtocol;
@property (nonatomic, retain) NSString  *m_strFileServerPort;
@property (nonatomic, retain) NSString	*m_strPartition;
@property (nonatomic, retain) NSString	*m_strStartPath;
@property (nonatomic, retain) NSString	*m_strOrgName;
@property (nonatomic, retain) NSString	*m_strOrgCode;
@property (nonatomic, retain) NSString	*m_strOverwrite;
@property (nonatomic, retain) NSString  *m_strCurrentPath;
@property DiskType m_nDiskType;

@property long long m_nTotalSpace;
@property long long m_nAvailableSpace;

- (DiskType) getDiskType:(NSString*)strValue;
- (NSString*) getCmdDiskType;

@end


@interface NICookieInfo : NSObject
{
@public
	// Essential
	DiskType	m_nDiskType;
	NSString	*m_strDomainID;
	NSString	*m_strUser;
	NSString	*m_strPartition;
	NSString	*m_strRealIP;
	NSString	*m_strWebServer;
	NSString	*m_strAgent;
    NSString    *m_strShareUser;
    NSString    *m_strSharePath;
    NSString    *m_strSiteID;
	OPTION		m_nOption;
	
	// Option
	NSString	*m_strInstallVersion;
	NSString	*m_strLangID;
    NSString    *m_useProxy;
    NSString    *m_strDiskType;
    NSString    *m_strOption;
}

@property DiskType	m_nDiskType;
@property (nonatomic, retain) NSString	*m_strDomainID;
@property (nonatomic, retain) NSString	*m_strUser;
@property (nonatomic, retain) NSString	*m_strPartition;
@property (nonatomic, retain) NSString	*m_strRealIP;
@property (nonatomic, retain) NSString	*m_strWebServer;
@property (nonatomic, retain) NSString	*m_strAgent;
@property (nonatomic, retain) NSString	*m_strShareUser;
@property (nonatomic, retain) NSString	*m_strSharePath;
@property (nonatomic, retain) NSString  *m_strSiteID;
@property OPTION	m_nOption;

@property (nonatomic, retain) NSString	*m_strInstallVersion;
@property (nonatomic, retain) NSString	*m_strLangID;
- (OPTION) getOption:(NSString*)strValue;
@end

