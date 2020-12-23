//
//  NIInterfaceUtil.m
//  CentralECM
//
//  Created by Rusa on 10. 11. 26..
//  Copyright 2010 NetID ., Ltd. All rights reserved.
//

#import "NIInterfaceUtil.h"


@implementation NIInterfaceUtil

@end


@implementation NIDriveInfo

@synthesize m_strName;
@synthesize m_strAssignedDrive;
@synthesize m_strOwner;
@synthesize m_strOwnerType;
@synthesize m_strFileServer;
@synthesize m_strFileServerPort;
@synthesize m_strPartition;
@synthesize m_strStartPath;
@synthesize m_strOrgName;
@synthesize m_strOrgCode;
@synthesize m_strOverwrite;
@synthesize m_nDiskType;
@synthesize m_strFileServerProtocol;

@synthesize m_nTotalSpace;
@synthesize m_nAvailableSpace;
@synthesize m_strCurrentPath;
- (DiskType) getDiskType:(NSString *)strValue
{	
	if ( [strValue isEqualToString:@"personal"] )
		return DT_PERSONAL;
	
	else if ( [strValue isEqualToString:@"orgcowork"] )
		return DT_ORGCOWORK;
	
	else if ( [strValue isEqualToString:@"homepartition"] )
		return DT_HOMEPARTITION;
	
	else
		return DT_SHARE;
}

- (NSString*) getCmdDiskType
{
	NSString *strValue = @"";
	
	switch ( m_nDiskType )
	{
		case DT_PERSONAL:
		case DT_ORGCOWORK:
		case DT_HOMEPARTITION:
			strValue = @"OrgCowork";
			break;
					
		case DT_SHARE:
			strValue = @"OrgCoworkShare";
			break;
		
		default:
			break;
	}
	
	return strValue;
}

@end


@implementation NICookieInfo

@synthesize m_nDiskType;
@synthesize m_strDomainID;
@synthesize m_strUser;
@synthesize m_strPartition;
@synthesize m_strRealIP;
@synthesize m_strWebServer;
@synthesize m_strAgent;
@synthesize m_nOption;
@synthesize m_strShareUser;
@synthesize m_strSharePath;
@synthesize m_strSiteID;

@synthesize m_strInstallVersion;
@synthesize m_strLangID;
- (OPTION) getOption:(NSString*)strValue{
    if ( [strValue isEqualToString:@"0x01"] )
		return COOKIE_OPT_PERSONAL;
	
	else if ( [strValue isEqualToString:@"0x02"] )
		return COOKIE_OPT_USER_GUESTID;
	
	else if ( [strValue isEqualToString:@"0x03"] )
		return COOKIE_OPT_ORGCOWORK_GUESTID;
	
	else
		return COOKIE_OPT_PERSONAL;
}
@end

