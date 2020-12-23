
#import "ServerCmd.h"
#import "Util.h"
#import	"FileUtil.h"

#import "NIInterfaceUtil.h"

#import "AppDelegate.h"


#import "Cordova/CDVViewController.h"



SC_LOGIN			scLogin;
SC_LIST				scList;
NSString			*g_serverName;
NSString			*g_serverPort;
NSString			*g_loginID;
LoginUserType		g_nLoginUserType;
NSArray				*WebServerItems; 
static NSString *testflag = @"1";

// TO DO : 삭제 대상
//CDriveInfo	g_driveInfo[3];


#define	KOR	@"0412"
#define	ENG	@"0409"
#define	JPN	@"0411"
#define	CHN	@"0804"

#define	INSTALL_VERSION	@"1.0"
#define AGENT_IPHONE 0x0040

@implementation ServerCmd

#pragma mark -
#pragma mark Utility Function

@synthesize m_activityViewController;

- (void) dealloc
{
	[super dealloc];
	
	[m_activityViewController release];
	[receiveData release];
}

- (id) init
{
	self = [super init];
	
	if (self)
	{
		NSArray	*preferredLangs = [NSLocale preferredLanguages];		
		NSLog(@"preferredLang: %@", [preferredLangs objectAtIndex:0]);

		if ([[preferredLangs objectAtIndex:0] isEqualToString:@"ko"])
			m_langID = KOR;
		else if ([[preferredLangs objectAtIndex:0] isEqualToString:@"ja"])
			m_langID = JPN;
		else if ([[preferredLangs objectAtIndex:0] isEqualToString:@"cs"])
			m_langID = CHN;
		else
			m_langID = ENG;
        
		//m_activityViewController = [ActivityViewController alloc];
	}
	
	return self;
}

- (void) cancel
{
	// [m_connection cancel];
	[m_activityViewController hideActivity];
	
	if ([m_sender respondsToSelector:@selector(cancel)])
		[m_sender performSelector:@selector(cancel)];
	else
		NSLog(@"selector is not responding.");
    
    
    //[m_activityViewController release];
}

// DES 암호화 후 BASE64 인코딩
- (NSString *) encode: (NSString *) str 
			  withKey: (NSString *) key
{
	if (str == nil)
		return nil;
	
	NSString * encoded = [Util doCipher:str key:key action: kCCEncrypt ];
	encoded = [Util urlencode:encoded];
	return encoded;
}

// BASE64 디코딩 후 DES 암호화
- (NSString *) decode: (NSString *) str 
			  withKey: (NSString *) key
{
	if (str == nil)
		return nil;
	
	NSString * decoded = [Util doCipher:str key:key action: kCCDecrypt ];
	return decoded;
}

// 폴더 권한
- (int) GetACL: (NSString *) strAccess
{
	int		dwAttrib = 0;
	char	ch;
	
	for (int i=0; i<[strAccess length]; i++)
	{	
		ch = [strAccess characterAtIndex:i];
		
		switch ( ch )
		{
			case 'r' :
				dwAttrib |= ACL_READ;
				break;
				
			case 'w' :
				dwAttrib |= ACL_WRITE;
				break;
				
			case 'e' :
				dwAttrib |= ACL_EDIT;
				break;
				
			case 'd' :
				dwAttrib |= ACL_DELETEFILE;
				break;
				
			case 'l' :
				dwAttrib |= ACL_LIST;
				break;
				
			case 'c' :
				dwAttrib |= ACL_MKDIR;
				break;
				
			case 'p' :
				dwAttrib |= ACL_PERMISSION;
				break;
				
			case 's' :
				dwAttrib |= ACL_SPECIAL;
				break;
				
			case 'R' :
				dwAttrib |= ACL_NOREAD;
				break;
				
			case 'W' :
				dwAttrib |= ACL_NOWRITE;
				break;
				
			case 'E' :
				dwAttrib |= ACL_NOEDIT;
				break;
				
			case 'D' :
				dwAttrib |= ACL_NODELETE;
				break;
				
			case 'L' :
				dwAttrib |= ACL_NOLIST;
				break;
				
			case 'C' :
				dwAttrib |= ACL_NOMKDIR;
				break;
		}
	}
	
	return dwAttrib;
}


- (int) GetOption: (DiskType)nDiskType
{
	OPTION	nRetValue = 0;
	
	if ( nDiskType == DT_PERSONAL )
	{
		nRetValue = COOKIE_OPT_PERSONAL;
		
		if ( scLogin.nLoginUserType == LUT_GUEST )
			nRetValue = COOKIE_OPT_USER_GUESTID;
	}
	else if ( nDiskType == DT_ORGCOWORK && scLogin.nLoginUserType == LUT_GUEST )
	{
		nRetValue = COOKIE_OPT_ORGCOWORK_GUESTID;
	}
	
	return nRetValue;
}

// 쿠키를 생성한다.
// fileInfo가 있고 sharePath가 없으면 공유 1레벨
// fileInfo가 있고 sharePath도 있으면 공유 2레벨 이하이다.

- (NSString *) GetCookie:(int) nDrive 
                fileInfo: (CFileInfo *) fileInfo 
               sharePath: (NSString *) sharePath;
{
	
	
    //	NSArray *arrayDiskType = [[NSArray alloc] initWithObjects:@"OrgCowork", @"OrgCowork", @"Share", nil];
    
	NSString *DiskType;
	NSString *strOption = @"";
	
	if (fileInfo == nil)
	{
		NIDriveInfo *info = [g_appDelegate.m_arrDriveInfo objectAtIndex:nDrive];
		
		DiskType = [self encode:[info getCmdDiskType] withKey:scLogin.ks];
		
		NSString *strTmp = [[NSString alloc] initWithFormat:@"%x", [self GetOption:info->m_nDiskType]];
		
		strOption = [self encode:strTmp withKey:scLogin.ks]; 
	}
	else
	{
		NSLog(@"DiskType is OrgCoworkShare");
		DiskType = [self encode:@"OrgCoworkShare" withKey:scLogin.ks];
	}
	
	NSLog(@"User is %@", g_loginID);
	NSLog(@"WebServer is %@", g_serverName);
	NSLog(@"DomainID is %@", scLogin.strDomainID);
	NSLog(@"PDSessionID is %@", scLogin.strSessionID);
	
	NSString *User = [self encode:g_loginID withKey:scLogin.ks];
	NSString *WebServer = [self encode:g_serverName withKey:scLogin.ks];
	NSString *DomainID = [self encode:scLogin.strDomainID withKey:scLogin.ks];
	NSString *InstallVersion = [self encode:INSTALL_VERSION withKey:scLogin.ks];
	NSString *LangID = [self encode:m_langID withKey:scLogin.ks];
	
	NSString *strAgent = [[NSString stringWithFormat:@"%x", AGENT_IPHONE] retain];
	NSString *Agent = [self encode:strAgent withKey:scLogin.ks];
	NSString *PDSessionID = [self encode:scLogin.strSessionID withKey:scLogin.ks];
	NSString *RealIP = [self encode:@"127.0.0.1" withKey:scLogin.ks];
	
	NSString * Cookie = [[NSString alloc] initWithFormat:@"DiskType=%@;User=%@;WebServer=%@;DomainID=%@;InstallVersion=%@;LangID=%@;Agent=%@;PDSessionID=%@;RealIP=%@;Option=%@;",
                         DiskType, User, WebServer, DomainID, InstallVersion, LangID, Agent, PDSessionID, RealIP, strOption];	
	
	if (fileInfo)
	{
		NSLog(@"Cowork is %@", fileInfo.m_strOwner);
		NSLog(@"Partition is %@", fileInfo.m_strPartition);
		NSLog(@"ShareUser is %@", fileInfo.m_stShare);
        
		NSString *Cowork = [self encode:fileInfo.m_strOwner withKey:scLogin.ks];
		NSString *Partition = [self encode:fileInfo.m_strPartition withKey:scLogin.ks];
		NSString *ShareUser = [self encode:fileInfo.m_stShare withKey:scLogin.ks];
		
		NSString *Str = [[NSString alloc] initWithFormat:@"Cowork=%@;Partition=%@;ShareUser=%@;", Cowork, Partition, ShareUser];
		Cookie = [Cookie stringByAppendingString:Str];
	}
	else
	{
		NIDriveInfo *info = [g_appDelegate.m_arrDriveInfo objectAtIndex:nDrive];
		NSLog(@"StartPath is %@", info->m_strStartPath);
		NSLog(@"Cowork is %@", info->m_strOwner);
		NSLog(@"Partition is %@", info->m_strPartition);
        
		NSString *StartPath = [self encode:info->m_strStartPath withKey:scLogin.ks];
		NSString *Cowork = [self encode:info->m_strOwner withKey:scLogin.ks];
		NSString *Partition = [self encode:info->m_strPartition withKey:scLogin.ks];
        
		NSString * Str = [[NSString alloc] initWithFormat:@"StartPath=%@;Cowork=%@;Partition=%@;", 
						  StartPath, Cowork, Partition];
		Cookie = [Cookie stringByAppendingString:Str];
	}
	
	if (sharePath)
	{
		NSLog(@"SharePath is %@", sharePath);
        
		NSString * SharePath = [self encode:sharePath withKey:scLogin.ks];
		
		NSString * Str = [[NSString alloc] initWithFormat:@"SharePath=%@;", SharePath];
		Cookie = [Cookie stringByAppendingString:Str];
	}
	
	NSLog(@"%@", Cookie);
	return Cookie;
}


// 쿠키를 생성한다.
// fileInfo가 있고 sharePath가 없으면 공유 1레벨
// fileInfo가 있고 sharePath도 있으면 공유 2레벨 이하이다.

- (NSString *) GetCookie:(int) nDrive 
               fileInfo: (CFileInfo *) fileInfo 
               sharePath: (NSString *) sharePath
           g_appDelegate: (CentralECMAppDelegate *) g_appDelegate;
{
	
	NSString *DiskType;
	NSString *strOption = @"";
	
    NIDriveInfo *info = [g_appDelegate.m_arrDriveInfo objectAtIndex:nDrive];
    NICookieInfo *cookieinfo = [g_appDelegate.m_arrCookieInfo objectAtIndex:nDrive];
    
    NSString *npass = [Util md5:cookieinfo->m_strSiteID];
    
    DiskType = [self encode:[info getCmdDiskType] withKey:npass];
	NSLog(@"DiskType is %@", [info getCmdDiskType]);	
    NSString *strTmp = [[NSString alloc] initWithFormat:@"%x", [self GetOption:info->m_nDiskType]];
		
    strOption = [self encode:strTmp withKey:npass]; 
    
   	NSLog(@"User is %@", cookieinfo->m_strUser);
	NSLog(@"WebServer is %@", cookieinfo->m_strWebServer);
	NSLog(@"DomainID is %@", cookieinfo->m_strDomainID);
	NSLog(@"PDSessionID is %@", cookieinfo->m_strUser);
	
	NSString *User = [self encode:cookieinfo->m_strUser withKey:npass];
	NSString *WebServer = [self encode:cookieinfo->m_strWebServer withKey:npass];
	NSString *DomainID = [self encode:cookieinfo->m_strDomainID withKey:npass];
	NSString *InstallVersion = [self encode:INSTALL_VERSION withKey:npass];
	NSString *LangID = [self encode:m_langID withKey:npass];
	
	//NSString *strAgent = [[NSString stringWithFormat:@"%x", AGENT_IPHONE] retain];
	NSString *Agent = [self encode:cookieinfo->m_strAgent withKey:npass];
	NSString *PDSessionID = [self encode:scLogin.strSessionID withKey:npass];
	NSString *RealIP = [self encode:cookieinfo->m_strRealIP withKey:npass];
	NSLog(@"RealIP is %@", cookieinfo->m_strRealIP);
    NSLog(@"Agent is %@", cookieinfo->m_strAgent);
	NSString * Cookie = [[NSString alloc] initWithFormat:@"DiskType=%@;User=%@;WebServer=%@;DomainID=%@;Agent=%@;RealIP=%@;Option=%@;",
			  DiskType, User, WebServer, DomainID, Agent, RealIP, strOption];	
	

		//NIDriveInfo *info = [g_appDelegate.m_arrDriveInfo objectAtIndex:nDrive];
		NSLog(@"StartPath is %@", info->m_strStartPath);
		NSLog(@"Cowork is %@", info->m_strOwner);
		NSLog(@"Partition is %@", info->m_strPartition);

		NSString *StartPath = [self encode:info->m_strStartPath withKey:npass];
		NSString *Cowork = [self encode:info->m_strOwner withKey:npass];
		NSString *Partition = [self encode:info->m_strPartition withKey:npass];

		NSString * Str = [[NSString alloc] initWithFormat:@"StartPath=%@;Cowork=%@;Partition=%@;", 
						  StartPath, Cowork, Partition];
		Cookie = [Cookie stringByAppendingString:Str];
	
	
	if (sharePath)
	{
		NSLog(@"SharePath is %@", sharePath);

		NSString * SharePath = [self encode:sharePath withKey:npass];
		NSString * ShareUser = [self encode:cookieinfo->m_strShareUser withKey:npass];
		NSString * Str = [[NSString alloc] initWithFormat:@"SharePath=%@;ShareUser=%@;", 
                          SharePath, ShareUser];
		Cookie = [Cookie stringByAppendingString:Str];
	}
	
	NSLog(@"%@", Cookie);
	return Cookie;
}

#pragma mark -
#pragma mark Server Command

// 파일 다운로드
- (void) GetFile: (int) nDrive 
		  tmpDir: (NSString *) tmpDir
		 srcName: (NSString *) srcPath 
		fileInfo: (CFileInfo *) fileInfo 
	   sharePath: (NSString *) sharePath 
			view: (UIView *) view 
		   order: (int) nOrder 
	   totalfile: (int) nTotal
		  sender: (id) sender 
		selector: (SEL) selector
   g_appDelegate: (CentralECMAppDelegate *) g_appDelegate
         ActView: (ActivityViewController *) ActViewCtl;
{
	commandType = ST_GET_FILE;
    m_activityViewController = ActViewCtl;
//    [ActViewCtl showActivity:ActViewCtl.view filename:[srcPath lastPathComponent] sender: self order: nOrder totalfile: nTotal];
    [m_activityViewController showActivity:m_activityViewController.view filename:[srcPath lastPathComponent] sender: self order: nOrder totalfile: nTotal];
     UIAlertView *progressAlert = [[UIAlertView alloc] initWithTitle:@"Progree" message:@"Please Wait..."delegate:self cancelButtonTitle:nil otherButtonTitles:nil, nil];
    UIProgressView *progressView = [[UIProgressView alloc] initWithFrame:CGRectMake(30.0f, 80.0f, 225.0f, 90.0f)];
    [progressAlert addSubview:progressView];
    [progressView setProgressViewStyle:UIProgressViewStyleBar];
    
	NSString	* requestURI;
	
	NIDriveInfo *info = [g_appDelegate.m_arrDriveInfo objectAtIndex:nDrive];
	NICookieInfo *cookieinfo = [g_appDelegate.m_arrCookieInfo objectAtIndex:nDrive];
    // 공유 폴더
    
    NSString* extenstion = [srcPath pathExtension];
    NSString* tmpSrcPath = srcPath;
    
    extenstion = [extenstion lowercaseString];
    
    srcPath = [srcPath stringByReplacingOccurrencesOfString:[srcPath pathExtension] withString:extenstion];
    
    BOOL Exist = NO;
    NSRange strRange1 = [srcPath rangeOfString:@".xlsx"];
    NSRange strRange2 = [srcPath rangeOfString:@".xls"];
    NSRange strRange3 = [srcPath rangeOfString:@".doc"];
    NSRange strRange4 = [srcPath rangeOfString:@".docx"];
    NSRange strRange5 = [srcPath rangeOfString:@".hwp"];
    NSRange strRange6 = [srcPath rangeOfString:@".ppt"];
    NSRange strRange7 = [srcPath rangeOfString:@".pptx"];
    
    if (strRange1.location != NSNotFound || strRange2.location != NSNotFound || strRange3.location != NSNotFound || strRange4.location != NSNotFound || strRange5.location != NSNotFound || strRange6.location != NSNotFound || strRange7.location != NSNotFound) {
        Exist = YES;
    }
    
    if(Exist){
        if (info->m_nDiskType == DT_SHARE && fileInfo)
            requestURI = [NSString stringWithFormat:@"%@://%@:%@/webapp/custom_file_download2_by_pdf.jsp", info->m_strFileServerProtocol, info->m_strFileServer, info->m_strFileServerPort];
        else
            requestURI = [NSString stringWithFormat:@"%@://%@:%@/webapp/custom_file_download2_by_pdf.jsp", info->m_strFileServerProtocol, info->m_strFileServer, info->m_strFileServerPort];
    } else {
        if (info->m_nDiskType == DT_SHARE && fileInfo)
            requestURI = [NSString stringWithFormat:@"%@://%@:%@/webapp/custom_file_download.jsp", info->m_strFileServerProtocol, info->m_strFileServer, info->m_strFileServerPort];
        else
            requestURI = [NSString stringWithFormat:@"%@://%@:%@/webapp/custom_file_download.jsp", info->m_strFileServerProtocol, info->m_strFileServer, info->m_strFileServerPort];
    }
	
//	NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:[ NSURL URLWithString: requestURI ]];
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:[ NSURL URLWithString: requestURI ] cachePolicy:NSURLRequestUseProtocolCachePolicy timeoutInterval:600];
	
	// method
	[request setHTTPMethod:@"POST"];
	
	// param
	NSMutableString *paramString=[NSMutableString string];
	
	m_bFirst = true;
	FileUtil *g_FileUtil = [[FileUtil alloc] init];
	if (tmpDir)
	{
		m_fileName = [[NSString alloc] initWithFormat:@"%@/%@/%@", [g_FileUtil getTmpFolder], tmpDir, [srcPath lastPathComponent]];
        
		NSString *tmpFolder = [NSString stringWithFormat:@"%@/%@", [g_FileUtil getTmpFolder], tmpDir];
		NSFileManager *fileMgr = [NSFileManager defaultManager];
		[fileMgr createDirectoryAtPath:tmpFolder withIntermediateDirectories:YES attributes:nil error:nil];
	}
	else
		m_fileName = [[NSString alloc] initWithFormat:@"%@/%@", [g_FileUtil getTmpFolder], [srcPath lastPathComponent]];
    
    m_fileName = [m_fileName stringByReplacingOccurrencesOfString:@"%" withString:@""];
    m_fileName = [m_fileName stringByReplacingOccurrencesOfString:@"#" withString:@""];
	NSLog(@"m_fileName is %@", m_fileName);
	
    
    
    NSString *npass = [Util md5:cookieinfo->m_strSiteID];
    
    NSString *key = NULL;
    key = cookieinfo->m_strSiteID;
    key = [key stringByAppendingString:cookieinfo->m_strUser];
    m_strKey = [Util md5:key];
    m_strFlag = info->m_strFlag;
    
	// 필수
	NSString * SrcName = [self encode:srcPath withKey:npass];
	NSString * FileServer;
	

    FileServer = [self encode:info->m_strFileServer withKey:npass];
	
	[paramString appendFormat:@"SrcName=%@", SrcName];
	[paramString appendFormat:@"&FileServer=%@", FileServer];
	
	NSLog(@"%@", paramString);
	
	NSData *paramData = [ NSData dataWithBytes: [ paramString UTF8String ] length: [ paramString length]];
	[request setHTTPBody: paramData ];
	
	// Header
	[request setValue:info->m_strFileServer forHTTPHeaderField:@"Host"];
	[request setValue:@"application/x-www-form-urlencoded" forHTTPHeaderField:@"Content-Type"];
	[request setValue:@"Net-ID Browser" forHTTPHeaderField:@"User-Agent"];
	[request setValue:@"Keep-Alive" forHTTPHeaderField:@"Connection"];
	[request setValue:@"utf8" forHTTPHeaderField:@"Accept-Charset"];
	
	[request setValue:[self GetCookie:nDrive fileInfo:fileInfo sharePath:sharePath  
                        g_appDelegate: g_appDelegate] forHTTPHeaderField:@"Cookie"];
	
    
	m_sender = sender;
	m_selector = selector;
	
	lastTime = [[NSDate date] timeIntervalSince1970] * 1000;
	
    
    if([cookieinfo->m_useProxy  isEqual: @"true"]){
        
        NSString* proxyHost = @"1.212.69.220";
        NSNumber* proxyPort = [NSNumber numberWithInt: 53334];
        
        // Create an NSURLSessionConfiguration that uses the proxy
        NSDictionary *proxyDict = @{
                                    @"HTTPEnable"  : [NSNumber numberWithInt:1],
                                    (NSString *)kCFStreamPropertyHTTPProxyHost  : proxyHost,
                                    (NSString *)kCFStreamPropertyHTTPProxyPort  : proxyPort,
                                    
                                    @"HTTPSEnable" : [NSNumber numberWithInt:1],
                                    (NSString *)kCFStreamPropertyHTTPSProxyHost : proxyHost,
                                    (NSString *)kCFStreamPropertyHTTPSProxyPort : proxyPort,
                                    };
        
        NSURLSessionConfiguration *configuration = [NSURLSessionConfiguration ephemeralSessionConfiguration];
        configuration.connectionProxyDictionary = proxyDict;
        //    protocol, port, Server, strMethod, strTarget, paraData, paraCookie)
        
        // Create a NSURLSession with our proxy aware configuration
        NSURLSession *session = [NSURLSession sessionWithConfiguration:configuration delegate:self delegateQueue:[NSOperationQueue mainQueue]];
        
        
        __block NSString *str = nil;
        __block NSArray *lines = nil;
        
        // Dispatch the request on our custom configured session
        NSURLSessionDataTask *task = [session dataTaskWithRequest:request completionHandler:
                                      ^(NSData *data, NSURLResponse *response, NSError *error) {
                                          
                                          NSLog(@"NSURLSession got the response [%@]", response);
                                          NSLog(@"GetFile!!Session got the data [%@]", [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding]);
                                          str = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
                                          
                                          receiveData = [[NSMutableData alloc] initWithData:data];
                                          
                                          lines = [str componentsSeparatedByString:@"\r\n"];
                                          
                                          NSLog(@"%d lines received.", [lines count]);
                                          
                                          for (int i=0; i<[lines count]; i++)
                                              NSLog(@"%@", [lines objectAtIndex:i]);
                                          
                                          switch (commandType)
                                          {
                                              case	ST_LOGIN:
                                                  [self processLogin:lines];
                                                  break;
                                              case	ST_GET_SERVER_INFO:
                                                  [self processGetServerInfo:lines];
                                                  break;
                                              case	ST_GET_DRIVE_LIST:
                                                  //[self processGetDriveList:lines];
                                                  [self processNewGetDriveList:lines];
                                                  break;
                                              case	ST_GET_LIST:
                                                  [self processGetList:lines];
                                                  break;
                                              case	ST_DELETE_FILE:
                                                  [self processDeleteFile:lines];
                                                  break;
                                              case	ST_RENAME_FILE:
                                                  [self processRenameFile:lines];
                                                  break;
                                              case	ST_EMPTY_RECYCLED:
                                                  [self processEmptyRecycled:lines];
                                                  break;
                                              case	ST_CREATE_DIR:
                                                  [self processCreateDir:lines];
                                                  break;
                                              case	ST_PUT_FILE:
                                                  [self processPutFile:lines];
                                                  break;
                                              case	ST_ACCOUNT:
                                                  [self processAccount:lines];
                                                  break;
                                              case ST_GET_FILE:{
                                                  // 데이터를 수신하면 append 한다.
                                                  NSLog(@"%d bytes received.", [data length]);
                                                  
                                                  // 파일 다운로드
                                                  if (commandType == ST_GET_FILE)
                                                  {
                                                      if (m_bFirst)
                                                      {
                                                          m_bFirst = false;
                                                          
                                                          char * bytes = malloc([data length]);
                                                          [data getBytes:bytes length:[data length]];
                                                          
                                                          NSMutableArray * lines = [[NSMutableArray alloc] initWithCapacity:3];
                                                          
                                                          char buffer[1024];
                                                          int offset = 0;
                                                          
                                                          for (int i=0; i<[data length]; i++)
                                                          {
                                                              //                NSLog(@"byte[%d] is %d %c", i, bytes[i],bytes[i]);
                                                              if (bytes[i] == 10)
                                                              {
                                                                  memset(buffer, 0x00, 1024);
                                                                  memcpy(buffer, bytes+offset, i-offset-1);
                                                                  NSString * line = [[NSString alloc] initWithBytes:buffer length:i-offset-1 encoding:NSUTF8StringEncoding];
                                                                  
                                                                  NSLog(@"line is %@", line);
                                                                  
                                                                  offset = i+1;
                                                                  NSLog(@"offset is %d", offset);
                                                                  
                                                                  [lines addObject:line];
                                                                  
                                                                  //if ([lines count] == 6)
                                                                  //if([retMsg rangeOfString: @"\r\n\r\n"].location > -1)
                                                                  if(bytes[i+2] == 10){
                                                                      offset = i + 3;
                                                                      break;
                                                                  }
                                                              }
                                                          }
                                                          
                                                          NSLog(@"%d lines received.", [lines count]);
                                                          
                                                          for (int i=0; i<[lines count]; i++)
                                                              NSLog(@"%@", [lines objectAtIndex:i]);
                                                          
                                                          if ([lines count] < 2)
                                                          {
                                                              NSString *errmsg = [[NSString alloc] initWithString:@"Network Error"];
                                                              [self sendResult:errmsg withObject: nil];
                                                          }
                                                          // Success 또는 SuccessReplace
                                                          else if ([[lines objectAtIndex:1] length] >= 7 && ![[[lines objectAtIndex:1] substringToIndex:7] isEqualToString:@"Success"])
                                                          {
                                                              NSString *errmsg = [[NSString alloc] initWithString:[lines objectAtIndex:1]];
                                                              [self sendResult:errmsg withObject: nil];
                                                          }
                                                          else
                                                          {
                                                              NSFileManager *fileMgr = [NSFileManager defaultManager];
                                                              [fileMgr createFileAtPath:m_fileName contents:nil attributes:nil];
                                                              NSLog(@"m_fileName is %@", m_fileName);
                                                              NSData * content = [NSData dataWithBytes:bytes+offset length:[data length]-offset];
                                                              NSLog(@"[data length] is %d", [data length]);
                                                              NSLog(@"offset is %d", offset);
                                                              NSLog(@"length is %u", [data length]-offset);
                                                              
                                                              
                                                              m_length = [[lines objectAtIndex:2] longLongValue];
                                                              
                                                              m_fileHandle = [NSFileHandle fileHandleForWritingAtPath:m_fileName];
                                                              
                                                              //                if(![m_strFlag isEqualToString:@"fileopen"])
                                                              //                    content = [content AES256EncryptWithKey:m_strKey];
                                                              [m_fileHandle writeData:content];
                                                              
                                                              if (m_length != 0)
                                                              {
                                                                  long long thisTime = [[NSDate date] timeIntervalSince1970] * 1000;
                                                                  m_activityViewController.m_progress.progress = [m_fileHandle offsetInFile]*1.0/m_length;
                                                                  [m_activityViewController setStatus:[m_fileHandle offsetInFile] totalsize: m_length time:thisTime-lastTime];
                                                              }
                                                              
                                                              //AppDelegate *test = [UIApplication sharedApplication].delegate;
                                                              
                                                              //test.mgmt_filename = [[NSString alloc] initWithString:@"test"];
                                                              
                                                              [m_fileHandle closeFile];
                                                          }
                                                      }
                                                      else 
                                                      {
                                                          m_fileHandle = [NSFileHandle fileHandleForWritingAtPath:m_fileName];
                                                          [m_fileHandle seekToEndOfFile];
                                                          
                                                          NSLog(@"strkey is %@", m_strKey);
                                                          //            
                                                          //           if(![m_strFlag isEqualToString:@"fileopen"])
                                                          //                data = [data AES256EncryptWithKey:m_strKey];
                                                          
                                                          [m_fileHandle writeData:data];			
                                                          if (m_length != 0)
                                                          {
                                                              long long thisTime = [[NSDate date] timeIntervalSince1970] * 1000;
                                                              m_activityViewController.m_progress.progress = [m_fileHandle offsetInFile]*1.0/m_length;
                                                              [m_activityViewController setStatus:[m_fileHandle offsetInFile] totalsize: m_length time:thisTime-lastTime];
                                                          }
                                                          
                                                          [m_fileHandle closeFile];
                                                      }
                                                  }
                                                  else
                                                  {
                                                      [receiveData appendData:data];
                                                  }
                                              }
                                          }
                                          
                                          [self sendResult:nil withObject: m_fileName];
                                          [m_activityViewController hideActivity];
                                      }];
        
        NSLog(@"Lets fire up the task!");
        [task resume];
        
    } else{
        [self sendRequest:request];
    }

}

// 파일 업로드
- (void) PutFile: (int) nDrive 
		 srcName: (NSString *) srcName 
		 srcPath: (NSString *) srcPath
		fileInfo: (CFileInfo *) fileInfo 
	   sharePath: (NSString *) sharePath 
//			view: (UIView *) view
		   order: (int) nOrder 
	   totalfile: (int) nTotal
		  sender: (id) sender 
		selector: (SEL) selector
   g_appDelegate: (CentralECMAppDelegate *) g_appDelegate
         ActView: (ActivityViewController *) ActViewCtl;
{
	commandType = ST_PUT_FILE;
	
    m_activityViewController = ActViewCtl;
    [m_activityViewController showActivity:m_activityViewController.view filename:[srcName lastPathComponent] sender: self order: nOrder totalfile: nTotal];
    
    
//	[m_activityViewController showActivity:view filename:[srcName lastPathComponent] sender: self order: nOrder totalfile: nTotal];
	
//	NSString *fileServer;
    FileUtil *g_FileUtil = [[FileUtil alloc] init];
	long long fileLength = [g_FileUtil getLength:srcPath];
	m_length = fileLength;
	
	NIDriveInfo *info = [g_appDelegate.m_arrDriveInfo objectAtIndex:nDrive];
	NICookieInfo *cookieinfo = [g_appDelegate.m_arrCookieInfo objectAtIndex:nDrive];	
	
    NSString *key = NULL;
    key = cookieinfo->m_strSiteID;
    key = [key stringByAppendingString:cookieinfo->m_strUser];
    m_strKey = [Util md5:key];
    
	NSString * requestURI = [NSString stringWithFormat:@"%@://%@:%@/webapp/custom_file_upload2.jsp", info->m_strFileServerProtocol, info->m_strFileServer, info->m_strFileServerPort];
//    NSString * requestURI = [NSString stringWithFormat:@"%@://%@:%@/PlusDrive/PutFile", info->m_strFileServerProtocol, info->m_strFileServer, info->m_strFileServerPort];
    
	// param
	NSMutableString *paramString = [NSMutableString string];
	
	NSLog(@"SrcName: %@", srcName);
	NSLog(@"FileLength: %qi", fileLength);
	
	NSString *strFileLength = [NSString stringWithFormat:@"%qi", fileLength];
    NSString *npass = [Util md5:cookieinfo->m_strSiteID];
	NSString * SrcName = [self encode:srcName withKey:npass];
	NSString * FileLength = [self encode:strFileLength withKey:npass];
	NSString * FileServer = [self encode:info->m_strFileServer withKey:npass];
	NSString * Overwrite = [self encode:@"yes" withKey:npass];
	
	[paramString appendFormat:@"?SrcName=%@", SrcName];
	[paramString appendFormat:@"&FileLength=%@", FileLength];
	[paramString appendFormat:@"&FileServer=%@", FileServer];
	[paramString appendFormat:@"&Overwrite=%@", Overwrite];
	
	NSLog(@"%@", paramString);
	
	requestURI = [requestURI stringByAppendingString:paramString];
	NSLog(@"requestURI is %@", requestURI);
	
	NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:[ NSURL URLWithString: requestURI ]];
	
	// method
	[request setHTTPMethod:@"POST"];
	
	NSData	* data = [NSData dataWithContentsOfMappedFile:srcPath];
    
	[request setHTTPBody:data];
	// header
	[request setValue:info->m_strFileServer forHTTPHeaderField:@"Host"];
	[request setValue:@"application/x-www-form-urlencoded" forHTTPHeaderField:@"Content-Type"];
	[request setValue:@"Net-ID Browser" forHTTPHeaderField:@"User-Agent"];
	[request setValue:@"Keep-Alive" forHTTPHeaderField:@"Connection"];
	[request setValue:@"utf8" forHTTPHeaderField:@"Accept-Charset"];
	
	[request setValue:[self GetCookie:nDrive fileInfo:fileInfo sharePath:sharePath
                       g_appDelegate: g_appDelegate] forHTTPHeaderField:@"Cookie"];
	
	m_sender = sender;
	m_selector = selector;

	lastTime = [[NSDate date] timeIntervalSince1970] * 1000;
    
    
    if([cookieinfo->m_useProxy  isEqual: @"true"]){
        
        NSString* proxyHost = @"1.212.69.220";
        NSNumber* proxyPort = [NSNumber numberWithInt: 53334];
        
        // Create an NSURLSessionConfiguration that uses the proxy
        NSDictionary *proxyDict = @{
                                    @"HTTPEnable"  : [NSNumber numberWithInt:1],
                                    (NSString *)kCFStreamPropertyHTTPProxyHost  : proxyHost,
                                    (NSString *)kCFStreamPropertyHTTPProxyPort  : proxyPort,
                                    
                                    @"HTTPSEnable" : [NSNumber numberWithInt:1],
                                    (NSString *)kCFStreamPropertyHTTPSProxyHost : proxyHost,
                                    (NSString *)kCFStreamPropertyHTTPSProxyPort : proxyPort,
                                    };
        
        NSURLSessionConfiguration *configuration = [NSURLSessionConfiguration ephemeralSessionConfiguration];
        configuration.connectionProxyDictionary = proxyDict;
        //    protocol, port, Server, strMethod, strTarget, paraData, paraCookie)
        
        // Create a NSURLSession with our proxy aware configuration
        NSURLSession *session = [NSURLSession sessionWithConfiguration:configuration delegate:self delegateQueue:[NSOperationQueue mainQueue]];
        
        
        __block NSString *str = nil;
        __block NSArray *lines = nil;
        __block NSString *errmsg = nil;
        
        // Dispatch the request on our custom configured session
        NSURLSessionDataTask *task = [session dataTaskWithRequest:request completionHandler:
                                      ^(NSData *data, NSURLResponse *response, NSError *error) {
                                          
                                          NSLog(@"NSURLSession got the response [%@]", response);
                                          NSLog(@"NSURL!!Session got the data [%@]", [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding]);
                                          str = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
                                          
                                          receiveData = [[NSMutableData alloc] initWithData:data];
                                          
                                          lines = [str componentsSeparatedByString:@"\r\n"];
                                          
                                          NSLog(@"%d lines received.", [lines count]);
                                          
                                          for (int i=0; i<[lines count]; i++)
                                          NSLog(@"%@", [lines objectAtIndex:i]);
                                          
                                          switch (commandType)
                                          {
                                              case	ST_LOGIN:
                                              [self processLogin:lines];
                                              break;
                                              case	ST_GET_SERVER_INFO:
                                              [self processGetServerInfo:lines];
                                              break;
                                              case	ST_GET_DRIVE_LIST:
                                              //[self processGetDriveList:lines];
                                              [self processNewGetDriveList:lines];
                                              break;
                                              case	ST_GET_LIST:
                                              [self processGetList:lines];
                                              break;
                                              case	ST_DELETE_FILE:
                                              [self processDeleteFile:lines];
                                              break;
                                              case	ST_RENAME_FILE:
                                              [self processRenameFile:lines];
                                              break;
                                              case	ST_EMPTY_RECYCLED:
                                              [self processEmptyRecycled:lines];
                                              break;
                                              case	ST_CREATE_DIR:
                                              [self processCreateDir:lines];
                                              break;
                                              case	ST_PUT_FILE:
                                              [self processPutFile:lines];
                                              break;
                                              case	ST_ACCOUNT:
                                              [self processAccount:lines];
                                              break;
                                          }
                                          
                                      }];
        
        NSLog(@"Lets fire up the task!");
        [task resume];
        
    } else{
        [self sendRequest:request];
    }
}

// 파일 업로드 전 체크
// TRUE: filesize가 -1이 아니면 Overwrite 창을 띄운다.
// FALSE: errmsg를 띄운다.
- (BOOL) PutFileCheck: (int) nDrive 
			  srcName: (NSString *) srcName 
			  srcPath: (NSString *) srcPath
			 fileInfo: (CFileInfo *) fileInfo 
			sharePath: (NSString *) sharePath 
			   sender: (id) sender
			   errmsg: (NSString **) errmsg
			 filesize: (NSInteger *) filesize
        g_appDelegate: (CentralECMAppDelegate *) g_appDelegate;
{
	commandType = ST_PUT_FILE_CHECK;
	
//	UIViewController	*controller = (UIViewController *)sender;
//	[m_activityViewController showActivity:controller.view];
	
	NSString	* requestURI;
	
	NIDriveInfo *info = [g_appDelegate.m_arrDriveInfo objectAtIndex:nDrive];
	NICookieInfo *cookieinfo = [g_appDelegate.m_arrCookieInfo objectAtIndex:nDrive];
	FileUtil *g_FileUtil = [[FileUtil alloc] init];
    
	// 공유 폴더
    requestURI = [NSString stringWithFormat:@"%@://%@:%@/PlusDrive/PutFileCheck", info->m_strFileServerProtocol, info->m_strFileServer, info->m_strFileServerPort];
	
	NSLog(@"requestURI is %@", requestURI);
	
	NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:[ NSURL URLWithString: requestURI ]];
	
	//method
	[request setHTTPMethod:@"POST"];
	
	//param
	NSMutableString *paramString=[NSMutableString string];
	
	long long fileLength = [g_FileUtil getLength:srcPath];

	NSLog(@"SrcName: %@", srcName);
	NSLog(@"FileLength: %qi", fileLength);
	
	NSString * strLength = [NSString stringWithFormat:@"%qi", fileLength];	
    NSString *npass = [Util md5:cookieinfo->m_strSiteID];
	// 필수
	NSString * SrcName = [self encode:srcName withKey:npass];
	NSString * FileLength = [self encode:strLength withKey:npass];
	
	[paramString appendFormat:@"SrcName=%@", SrcName];
	[paramString appendFormat:@"&FileLength=%@", FileLength];
	
	NSLog(@"%@", paramString);
	
	NSData *paramData = [ NSData dataWithBytes: [ paramString UTF8String ] length: [ paramString length]];
	[request setHTTPBody: paramData ];
	
	// Header
	[request setValue:info->m_strFileServer forHTTPHeaderField:@"Host"];
	[request setValue:@"application/x-www-form-urlencoded" forHTTPHeaderField:@"Content-Type"];
	[request setValue:@"Net-ID Browser" forHTTPHeaderField:@"User-Agent"];
	[request setValue:@"Keep-Alive" forHTTPHeaderField:@"Connection"];
	[request setValue:@"utf8" forHTTPHeaderField:@"Accept-Charset"];
	
	[request setValue:[self GetCookie:nDrive fileInfo:fileInfo sharePath:sharePath
                        g_appDelegate: g_appDelegate] forHTTPHeaderField:@"Cookie"];
	
	NSError        *error = nil;
	NSURLResponse  *response = nil;
	
    
    if([cookieinfo->m_useProxy  isEqual: @"true"]){
        
        NSString* proxyHost = @"1.212.69.220";
        NSNumber* proxyPort = [NSNumber numberWithInt: 53334];
        
        // Create an NSURLSessionConfiguration that uses the proxy
        NSDictionary *proxyDict = @{
                                    @"HTTPEnable"  : [NSNumber numberWithInt:1],
                                    (NSString *)kCFStreamPropertyHTTPProxyHost  : proxyHost,
                                    (NSString *)kCFStreamPropertyHTTPProxyPort  : proxyPort,
                                    
                                    @"HTTPSEnable" : [NSNumber numberWithInt:1],
                                    (NSString *)kCFStreamPropertyHTTPSProxyHost : proxyHost,
                                    (NSString *)kCFStreamPropertyHTTPSProxyPort : proxyPort,
                                    };
        
        NSURLSessionConfiguration *configuration = [NSURLSessionConfiguration ephemeralSessionConfiguration];
        configuration.connectionProxyDictionary = proxyDict;
        //    protocol, port, Server, strMethod, strTarget, paraData, paraCookie)
        
        // Create a NSURLSession with our proxy aware configuration
        NSURLSession *session = [NSURLSession sessionWithConfiguration:configuration delegate:self delegateQueue:[NSOperationQueue mainQueue]];
        
        
        __block NSString *str = nil;
        __block NSArray *lines = nil;
        __block NSString *errmsg = nil;
        
        // Dispatch the request on our custom configured session
        NSURLSessionDataTask *task = [session dataTaskWithRequest:request completionHandler:
                                      ^(NSData *data, NSURLResponse *response, NSError *error) {
                                          
                                          NSLog(@"NSURLSession got the response [%@]", response);
                                          NSLog(@"NSURL!!Session got the data [%@]", [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding]);
                                          str = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
                                          
                                          receiveData = [[NSMutableData alloc] initWithData:data];
                                          
                                          
                                          
                                          if (error)
                                          {
                                              [receiveData release];
                                              
                                              errmsg = [[NSString alloc] initWithString:[error localizedDescription]];
                                          }
                                          else
                                          {
                                              NSString *str = [[NSString alloc] initWithData:receiveData encoding:NSUTF8StringEncoding];
                                              NSArray *lines = [str componentsSeparatedByString:@"\r\n"];
                                              
                                              NSLog(@"%d lines received.", [lines count]);
                                              
                                              for (int i=0; i<[lines count]; i++)
                                              NSLog(@"PutFileCheck: %@", [lines objectAtIndex:i]);
                                              
                                              [receiveData release];
                                              
                                              if ([lines count] < 2)
                                              {
                                                  errmsg = [[NSString alloc] initWithString:NSLocalizedString(@"Network Error", nil)];
                                              }
                                              // Success 또는 SuccessReplace
                                              else if ([[lines objectAtIndex:1] length] >= 7 && ![[[lines objectAtIndex:1] substringToIndex:7] isEqualToString:@"Success"])
                                              {
                                                  errmsg = [[NSString alloc] initWithString:[lines objectAtIndex:1]];
                                              }
                                              else
                                              {
                                                  NSArray * arrayItems = [[lines objectAtIndex:2] componentsSeparatedByString:@"\t"];
                                                  
                                                  for (int i=0; i<[lines count]; i++)
                                                  NSLog(@"PutFileCheck: %@", [lines objectAtIndex:i]);
                                                  
                                                  *filesize = -1;
                                                  
                                                  if ([arrayItems count] >= 2)
                                                  *filesize = [[arrayItems objectAtIndex:0] intValue];
                                              }
                                          }
                                      }];
        
        NSLog(@"Lets fire up the task!");
        [task resume];
        
    } else{
        
        NSData * data = [NSURLConnection sendSynchronousRequest: request returningResponse: &response error: &error];
        receiveData = [[NSMutableData alloc] initWithData:data];
        
        	[m_activityViewController hideActivity];
        
        if (error)
        {
            [receiveData release];
            
            *errmsg = [[NSString alloc] initWithString:[error localizedDescription]];
            return FALSE;
        }
        else
        {
            NSString *str = [[NSString alloc] initWithData:receiveData encoding:NSUTF8StringEncoding];
            NSArray *lines = [str componentsSeparatedByString:@"\r\n"];
            
            NSLog(@"%d lines received.", [lines count]);
            
            for (int i=0; i<[lines count]; i++)
            NSLog(@"PutFileCheck: %@", [lines objectAtIndex:i]);
            
            [receiveData release];
            
            if ([lines count] < 2)
            {
                *errmsg = [[NSString alloc] initWithString:NSLocalizedString(@"Network Error", nil)];
                return FALSE;
            }
            // Success 또는 SuccessReplace
            else if ([[lines objectAtIndex:1] length] >= 7 && ![[[lines objectAtIndex:1] substringToIndex:7] isEqualToString:@"Success"])
            {
                *errmsg = [[NSString alloc] initWithString:[lines objectAtIndex:1]];
                return FALSE;
            }
            else
            {
                NSArray * arrayItems = [[lines objectAtIndex:2] componentsSeparatedByString:@"\t"];
                
                for (int i=0; i<[lines count]; i++)
                NSLog(@"PutFileCheck: %@", [lines objectAtIndex:i]);
                
                *filesize = -1;
                
                if ([arrayItems count] >= 2)
                *filesize = [[arrayItems objectAtIndex:0] intValue];
                
                return TRUE;
            }
        }

    }

    
    
    
    
   }

- (BOOL) sendCopyCutRequest: (NSMutableURLRequest *) request 
					 errmsg: (NSString **) errmsg 
			  lastWriteTime: (NSString **) lastWriteTime
{
	NSError        *error = nil;
	NSURLResponse  *response = nil;
	
	NSData * data = [NSURLConnection sendSynchronousRequest: request returningResponse: &response error: &error];
	receiveData = [[NSMutableData alloc] initWithData:data];
	
	[m_activityViewController hideActivity];

	if (error)
	{
		[receiveData release];
		
		*errmsg = [[NSString alloc] initWithString:[error localizedDescription]];
		return FALSE;
	}
	else
	{
		NSString *str = [[NSString alloc] initWithData:receiveData encoding:NSUTF8StringEncoding];
		NSArray *lines = [str componentsSeparatedByString:@"\r\n"];
		
		NSLog(@"%d lines received.", [lines count]);
		
		for (int i=0; i<[lines count]; i++)
			NSLog(@"sendCopyCutRequest: %@", [lines objectAtIndex:i]);
		
		[receiveData release];
		
		if ([lines count] < 2)
		{
			*errmsg = [[NSString alloc] initWithString:NSLocalizedString(@"Network Error", nil)];
			return FALSE;
		}
		// Success 또는 SuccessReplace
		else if ([[lines objectAtIndex:1] length] >= 7 && ![[[lines objectAtIndex:1] substringToIndex:7] isEqualToString:@"Success"])
		{
			*errmsg = [[NSString alloc] initWithString:[lines objectAtIndex:1]];
			return FALSE;
		}
		else
		{
			NSArray * arrayItems = [[lines objectAtIndex:2] componentsSeparatedByString:@"\t"];
			
			for (int i=0; i<[lines count]; i++)
				NSLog(@"sendCopyCutRequest: %@", [lines objectAtIndex:i]);
			
			if ([arrayItems count] >= 3)
				*lastWriteTime = [[NSString alloc] initWithString:[arrayItems objectAtIndex:2]];
			
			return TRUE;
		}
	}
}

// 파일/폴더 이동
- (BOOL) MoveFile: (int) nDrive 
		  srcName: (NSString *) srcPath 
		  dstName: (NSString *) dstPath
		 fileInfo: (CFileInfo *) fileInfo 
		sharePath: (NSString *) sharePath 
		overWrite: (BOOL) overWrite 
		   sender: (id) sender
	lastWriteTime: (NSString **) lastWriteTime 
		   errmsg: (NSString **) errmsg;
{
	commandType = ST_MOVE_FILE;
	
	UIViewController	*controller = (UIViewController *)sender;
	[m_activityViewController showActivity:controller.view];
	
	NSString	* requestURI;
	
	NIDriveInfo *info = [g_appDelegate.m_arrDriveInfo objectAtIndex:nDrive];
	
	// 공유 폴더
	if (info->m_nDiskType == DT_SHARE && fileInfo)
		requestURI = [NSString stringWithFormat:@"http://%@:%d/PlusDrive/MoveFile", fileInfo.m_strFileServer, scLogin.nHttpPort];
	else
		requestURI = [NSString stringWithFormat:@"http://%@:%d/PlusDrive/MoveFile", info->m_strFileServer, scLogin.nHttpPort];
	
	NSLog(@"requestURI is %@", requestURI);
	
	NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:[ NSURL URLWithString: requestURI ]];
	
	//method
	[request setHTTPMethod:@"POST"];
	
	//param
	NSMutableString *paramString=[NSMutableString string];
	
	NSLog(@"SrcName: %@", srcPath);
	NSLog(@"DstName: %@", dstPath);
	
	// 필수
	NSString * SrcName = [self encode:srcPath withKey:scLogin.ks];
	NSString * DstName = [self encode:dstPath withKey:scLogin.ks];
	
	// 옵션
	NSString * Overwrite;
	
	if (overWrite)
		Overwrite = [self encode:@"yes" withKey:scLogin.ks];
	else
		Overwrite = [self encode:@"no" withKey:scLogin.ks];
		
	NSString * DeleteShare = [self encode:@"yes" withKey:scLogin.ks];
	NSString * ReplaceShare = [self encode:@"yes" withKey:scLogin.ks];
	NSString * DeleteACL = [self encode:@"yes" withKey:scLogin.ks];
	NSString * ReplaceACL = [self encode:@"yes" withKey:scLogin.ks];
	NSString * IgnoreLock = [self encode:@"yes" withKey:scLogin.ks];
	NSString * FileServer = [self encode:info->m_strFileServer withKey:scLogin.ks];
	
	[paramString appendFormat:@"SrcName=%@", SrcName];
	[paramString appendFormat:@"&DstName=%@", DstName];
	[paramString appendFormat:@"&Overwrite=%@", Overwrite];
	[paramString appendFormat:@"&DeleteShare=%@", DeleteShare];
	[paramString appendFormat:@"&ReplaceShare=%@", ReplaceShare];
	[paramString appendFormat:@"&DeleteACL=%@", DeleteACL];
	[paramString appendFormat:@"&ReplaceACL=%@", ReplaceACL];
	[paramString appendFormat:@"&IgnoreLock=%@", IgnoreLock];
	[paramString appendFormat:@"&FileServer=%@", FileServer];
	
	NSLog(@"%@", paramString);
	
	NSData *paramData = [ NSData dataWithBytes: [ paramString UTF8String ] length: [ paramString length]];
	[request setHTTPBody: paramData ];
	
	// Header
	[request setValue:info->m_strFileServer forHTTPHeaderField:@"Host"];
	[request setValue:@"application/x-www-form-urlencoded" forHTTPHeaderField:@"Content-Type"];
	[request setValue:@"Net-ID Browser" forHTTPHeaderField:@"User-Agent"];
	[request setValue:@"Keep-Alive" forHTTPHeaderField:@"Connection"];
	[request setValue:@"utf8" forHTTPHeaderField:@"Accept-Charset"];
	
	[request setValue:[self GetCookie:nDrive fileInfo:fileInfo sharePath:sharePath] forHTTPHeaderField:@"Cookie"];
	
	return [self sendCopyCutRequest: request errmsg:errmsg lastWriteTime: lastWriteTime];
}

// 파일/폴더 복사
- (BOOL) CopyFile: (int) nDrive 
		  srcName: (NSString *) srcPath 
		  dstName: (NSString *) dstPath
		 fileInfo: (CFileInfo *) fileInfo 
		sharePath: (NSString *) sharePath 
		overWrite: (BOOL) overWrite 
		   sender: (id) sender
	lastWriteTime: (NSString **) lastWriteTime 
		   errmsg: (NSString **) errmsg;
{
	commandType = ST_COPY_FILE;
	
	UIViewController	*controller = (UIViewController *)sender;
	[m_activityViewController showActivity:controller.view];
	
	NSString	* requestURI;
	
	NIDriveInfo *info = [g_appDelegate.m_arrDriveInfo objectAtIndex:nDrive];
	
	// 공유 폴더
	if (info->m_nDiskType == DT_SHARE && fileInfo)
		requestURI = [NSString stringWithFormat:@"http://%@:%d/PlusDrive/CopyFile", fileInfo.m_strFileServer, scLogin.nHttpPort];
	else
		requestURI = [NSString stringWithFormat:@"http://%@:%d/PlusDrive/CopyFile", info->m_strFileServer, scLogin.nHttpPort];
	
	NSLog(@"requestURI is %@", requestURI);
	
	NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:[ NSURL URLWithString: requestURI ]];
	
	//method
	[request setHTTPMethod:@"POST"];
	
	//param
	NSMutableString *paramString=[NSMutableString string];
	
	NSLog(@"SrcName: %@", srcPath);
	NSLog(@"DstName: %@", dstPath);
	
	NSString * SrcName = [self encode:srcPath withKey:scLogin.ks];
	NSString * DstName = [self encode:dstPath withKey:scLogin.ks];
	NSString * CopyACL = [self encode:@"yes" withKey:scLogin.ks];
	NSString * CopyShare = [self encode:@"yes" withKey:scLogin.ks];
	
	NSString * Overwrite;
	
	if (overWrite)
		Overwrite = [self encode:@"yes" withKey:scLogin.ks];
	else
		Overwrite = [self encode:@"no" withKey:scLogin.ks];
	
	[paramString appendFormat:@"SrcName=%@", SrcName];
	[paramString appendFormat:@"&DstName=%@", DstName];
	[paramString appendFormat:@"&CopyACL=%@", CopyACL];
	[paramString appendFormat:@"&CopyShare=%@", CopyShare];
	[paramString appendFormat:@"&Overwrite=%@", Overwrite];
	
	NSLog(@"%@", paramString);
	
	NSData *paramData = [ NSData dataWithBytes: [ paramString UTF8String ] length: [ paramString length]];
	[request setHTTPBody: paramData ];
	
	// Header
	[request setValue:info->m_strFileServer forHTTPHeaderField:@"Host"];
	[request setValue:@"application/x-www-form-urlencoded" forHTTPHeaderField:@"Content-Type"];
	[request setValue:@"Net-ID Browser" forHTTPHeaderField:@"User-Agent"];
	[request setValue:@"Keep-Alive" forHTTPHeaderField:@"Connection"];
	[request setValue:@"utf8" forHTTPHeaderField:@"Accept-Charset"];
	
	[request setValue:[self GetCookie:nDrive fileInfo:fileInfo sharePath:sharePath] forHTTPHeaderField:@"Cookie"];
	
	return [self sendCopyCutRequest: request errmsg:errmsg lastWriteTime: lastWriteTime];
}

// 파일 서버에서 디렉토리 생성
- (void) CreateDir: (int) nDrive 
		   srcName: (NSString *) srcPath 
		  fileInfo: (CFileInfo *) fileInfo 
		 sharePath: (NSString *) sharePath
			sender: (id) sender 
		  selector: (SEL) selector
     g_appDelegate: (CentralECMAppDelegate *) g_appDelegate;
{
	commandType = ST_CREATE_DIR;

//	UIViewController	*controller = (UIViewController *)sender;
//	[m_activityViewController showActivity:controller.view];
	
	NSString	* requestURI;
	
	NIDriveInfo *info = [g_appDelegate.m_arrDriveInfo objectAtIndex:nDrive];
	NICookieInfo *cookieinfo = [g_appDelegate.m_arrCookieInfo objectAtIndex:nDrive];
	
	
    requestURI = [NSString stringWithFormat:@"%@://%@:%@/PlusDrive/CreateDir",info->m_strFileServerProtocol, info->m_strFileServer, info->m_strFileServerPort];

	NSLog(@"requestURI is %@", requestURI);
	NSLog(@"srcPath is %@", srcPath);

    
	NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:[ NSURL URLWithString: requestURI ]];
    
    
	//method
	[request setHTTPMethod:@"POST"];
	
	//param
	NSMutableString *paramString=[NSMutableString string];
    NSString * npass = [Util md5:cookieinfo->m_strSiteID];
	NSString * SrcName = [self encode:srcPath withKey:npass];
	NSString * Recursive = [self encode:@"yes" withKey:npass];
    
    [paramString appendFormat:@"SrcName=%@", SrcName];
    [paramString appendFormat:@"&Recursive=%@", Recursive];
    
    NSData *paramData = [ NSData dataWithBytes: [ paramString UTF8String ] length: [ paramString length]];

    
	[request setHTTPBody: paramData ];

	// Header
	[request setValue:info->m_strFileServer forHTTPHeaderField:@"Host"];
	[request setValue:@"application/x-www-form-urlencoded" forHTTPHeaderField:@"Content-Type"];
	[request setValue:@"Net-ID Browser" forHTTPHeaderField:@"User-Agent"];
	[request setValue:@"Keep-Alive" forHTTPHeaderField:@"Connection"];
	[request setValue:@"utf8" forHTTPHeaderField:@"Accept-Charset"];

	[request setValue:[self GetCookie:nDrive fileInfo:fileInfo sharePath:sharePath
                       g_appDelegate:g_appDelegate] forHTTPHeaderField:@"Cookie"];
	
	m_sender = sender;
	m_selector = selector;
        
    
    
    if([cookieinfo->m_useProxy  isEqual: @"true"]){
        
    NSString* proxyHost = @"1.212.69.220";
    NSNumber* proxyPort = [NSNumber numberWithInt: 53334];
    
    // Create an NSURLSessionConfiguration that uses the proxy
    NSDictionary *proxyDict = @{
                                @"HTTPEnable"  : [NSNumber numberWithInt:1],
                                (NSString *)kCFStreamPropertyHTTPProxyHost  : proxyHost,
                                (NSString *)kCFStreamPropertyHTTPProxyPort  : proxyPort,
                                
                                @"HTTPSEnable" : [NSNumber numberWithInt:1],
                                (NSString *)kCFStreamPropertyHTTPSProxyHost : proxyHost,
                                (NSString *)kCFStreamPropertyHTTPSProxyPort : proxyPort,
                                };
    
    NSURLSessionConfiguration *configuration = [NSURLSessionConfiguration ephemeralSessionConfiguration];
    configuration.connectionProxyDictionary = proxyDict;
    //    protocol, port, Server, strMethod, strTarget, paraData, paraCookie)
    
    // Create a NSURLSession with our proxy aware configuration
    NSURLSession *session = [NSURLSession sessionWithConfiguration:configuration delegate:self delegateQueue:[NSOperationQueue mainQueue]];

    
    __block NSString *str = nil;
        __block NSArray *lines = nil;
        __block NSString *errmsg = nil;
    // Dispatch the request on our custom configured session
    NSURLSessionDataTask *task = [session dataTaskWithRequest:request completionHandler:
                                  ^(NSData *data, NSURLResponse *response, NSError *error) {
                                      
                                      NSLog(@"NSURLSession got the response [%@]", response);
                                      NSLog(@"NSURL!!Session got the data [%@]", [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding]);
                                      str = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
                                      
                                      
                                      
                                      lines = [str componentsSeparatedByString:@"\r\n"];
                                      
                                      NSLog(@"%d lines received.", [lines count]);
                                      
                                      for (int i=0; i<[lines count]; i++)
                                      NSLog(@"%@", [lines objectAtIndex:i]);

                                          switch (commandType)
                                          {
                                              case	ST_LOGIN:
                                              [self processLogin:lines];
                                              break;
                                              case	ST_GET_SERVER_INFO:
                                              [self processGetServerInfo:lines];
                                              break;
                                              case	ST_GET_DRIVE_LIST:
                                              //[self processGetDriveList:lines];
                                              [self processNewGetDriveList:lines];
                                              break;
                                              case	ST_GET_LIST:
                                              [self processGetList:lines];
                                              break;
                                              case	ST_DELETE_FILE:
                                              [self processDeleteFile:lines];
                                              break;
                                              case	ST_RENAME_FILE:
                                              [self processRenameFile:lines];
                                              break;
                                              case	ST_EMPTY_RECYCLED:
                                              [self processEmptyRecycled:lines];
                                              break;
                                              case	ST_CREATE_DIR:
                                              [self processCreateDir:lines];
                                              break;
                                              case	ST_PUT_FILE:
                                              [self processPutFile:lines];
                                              break;
                                              case	ST_ACCOUNT:
                                              [self processAccount:lines];
                                              break;
                                          }
                                      
                                      
//                                      [self sendResult:nil withObject: nil];
                                      //[self sendRequest:request];
                                  }];
    
        NSLog(@"Lets fire up the task!");
        [task resume];
    } else{
        [self sendRequest:request];
    }
    
}

// 휴지통 복원
- (BOOL) RestoreFile: (int) nDrive 
			 srcName: (NSString *) srcPath 
			  sender: (id) sender
			  errmsg: (NSString **) errmsg;
{
	commandType = ST_RESTORE_FILE;
	
	UIViewController	*controller = (UIViewController *)sender;
	[m_activityViewController showActivity:controller.view];
	
	NIDriveInfo *info = [g_appDelegate.m_arrDriveInfo objectAtIndex:nDrive];
	
	NSString * requestURI = [NSString stringWithFormat:@"http://%@:%d/PlusDrive/RestoreFile", info->m_strFileServer, scLogin.nHttpPort];
	NSLog(@"requestURI is %@", requestURI);
	
	NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:[ NSURL URLWithString: requestURI ]];
	
	//method
	[request setHTTPMethod:@"POST"];
	
	//param
	NSMutableString *paramString=[NSMutableString string];
	
	NSString * SrcName = [self encode:srcPath withKey:scLogin.ks];
	
	[paramString appendFormat:@"SrcName=%@", SrcName];
	
	NSLog(@"%@", paramString);
	
	NSData *paramData = [ NSData dataWithBytes: [ paramString UTF8String ] length: [ paramString length]];
	[request setHTTPBody: paramData ];

	// Header
	[request setValue:info->m_strFileServer forHTTPHeaderField:@"Host"];
	[request setValue:@"application/x-www-form-urlencoded" forHTTPHeaderField:@"Content-Type"];
	[request setValue:@"Net-ID Browser" forHTTPHeaderField:@"User-Agent"];
	[request setValue:@"Keep-Alive" forHTTPHeaderField:@"Connection"];
	[request setValue:@"utf8" forHTTPHeaderField:@"Accept-Charset"];
	[request setValue:[self GetCookie: nDrive fileInfo:nil sharePath:nil] forHTTPHeaderField:@"Cookie"];
	
	NSError        *error = nil;
	NSURLResponse  *response = nil;
	
	NSData * data = [NSURLConnection sendSynchronousRequest: request returningResponse: &response error: &error];
	receiveData = [[NSMutableData alloc] initWithData:data];
	
	[m_activityViewController hideActivity];

	if (error)
	{
		[receiveData release];
		
		*errmsg = [[NSString alloc] initWithString:[error localizedDescription]];
		return FALSE;
	}
	else
	{
		NSString *str = [[NSString alloc] initWithData:receiveData encoding:NSUTF8StringEncoding];
		NSArray *lines = [str componentsSeparatedByString:@"\r\n"];
		
		NSLog(@"%d lines received.", [lines count]);
		
		for (int i=0; i<[lines count]; i++)
			NSLog(@"RestoreFile: %@", [lines objectAtIndex:i]);
		
		[receiveData release];
		
		if ([lines count] < 2)
		{
			*errmsg = [[NSString alloc] initWithString:NSLocalizedString(@"Network Error", nil)];
			return FALSE;
		}
		else if ([[lines objectAtIndex:1] length] >= 7 && ![[[lines objectAtIndex:1] substringToIndex:7] isEqualToString:@"Success"])
		{
			*errmsg = [[NSString alloc] initWithString:[lines objectAtIndex:1]];
			return FALSE;
		}
		else
		{
			return TRUE;
		}
	}
}

// 파일 서버에서 휴지통 비우기
- (void) EmptyRecycled: (int) nDrive
				sender: (id) sender
			  selector: (SEL) selector;
{
	commandType = ST_EMPTY_RECYCLED;
	
	UIViewController	*controller = (UIViewController *)sender;
	[m_activityViewController showActivity:controller.view];
	
	NIDriveInfo *info = [g_appDelegate.m_arrDriveInfo objectAtIndex:nDrive];
	
	NSString * requestURI = [NSString stringWithFormat:@"http://%@:%d/PlusDrive/EmptyRecycled", info->m_strFileServer, scLogin.nHttpPort];
	NSLog(@"requestURI is %@", requestURI);
	
	NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:[ NSURL URLWithString: requestURI ]];
	
	//method
	[request setHTTPMethod:@"POST"];
	
	// Header
	[request setValue:info->m_strFileServer forHTTPHeaderField:@"Host"];
	[request setValue:@"application/x-www-form-urlencoded" forHTTPHeaderField:@"Content-Type"];
	[request setValue:@"Net-ID Browser" forHTTPHeaderField:@"User-Agent"];
	[request setValue:@"Keep-Alive" forHTTPHeaderField:@"Connection"];
	[request setValue:@"utf8" forHTTPHeaderField:@"Accept-Charset"];
	[request setValue:[self GetCookie: nDrive fileInfo:nil sharePath:nil] forHTTPHeaderField:@"Cookie"];
	
	m_sender = sender;
	m_selector = selector;
	
	[self sendRequest:request];
}

// 파일 서버에서 파일 이름 수정하기
- (void) RenameFile: (int) nDrive 
			srcName: (NSString *) srcPath 
			dstName: (NSString *) dstPath 
		   fileInfo: (CFileInfo *) fileInfo 
		  sharePath: (NSString *) sharePath
			 sender: (id) sender 
		   selector: (SEL) selector;
{
	commandType = ST_RENAME_FILE;
	
	UIViewController	*controller = (UIViewController *)sender;
	[m_activityViewController showActivity:controller.view];

	NSString	* requestURI;
	
	NIDriveInfo *info = [g_appDelegate.m_arrDriveInfo objectAtIndex:nDrive];

	// 공유 폴더
	if (info->m_nDiskType == DT_SHARE && fileInfo)
		requestURI = [NSString stringWithFormat:@"http://%@:%d/PlusDrive/RenameFile", fileInfo.m_strFileServer, scLogin.nHttpPort];
	else
		requestURI = [NSString stringWithFormat:@"http://%@:%d/PlusDrive/RenameFile", info->m_strFileServer, scLogin.nHttpPort];

	NSLog(@"requestURI is %@", requestURI);
	
	NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:[ NSURL URLWithString: requestURI ]];
	
	//method
	[request setHTTPMethod:@"POST"];
	
	//param
	NSMutableString *paramString=[NSMutableString string];
	
	NSString * SrcName = [self encode:srcPath withKey:scLogin.ks];
	NSString * DstName = [self encode:dstPath withKey:scLogin.ks];
	NSString * DeleteShare = [self encode:@"yes" withKey:scLogin.ks];
	NSString * ReplaceShare = [self encode:@"yes" withKey:scLogin.ks];
	NSString * DeleteACL = [self encode:@"yes" withKey:scLogin.ks];
	NSString * ReplaceACL = [self encode:@"yes" withKey:scLogin.ks];
	NSString * ForceRename = [self encode:@"yes" withKey:scLogin.ks];
	NSString * IgnoreLock = [self encode:@"no" withKey:scLogin.ks];
	
	[paramString appendFormat:@"SrcName=%@", SrcName];
	[paramString appendFormat:@"&DstName=%@", DstName];
	[paramString appendFormat:@"&DeleteShare=%@", DeleteShare];
	[paramString appendFormat:@"&ReplaceShare=%@", ReplaceShare];
	[paramString appendFormat:@"&DeleteACL=%@", DeleteACL];
	[paramString appendFormat:@"&ReplaceACL=%@", ReplaceACL];
	[paramString appendFormat:@"&ForceRename=%@", ForceRename];
	[paramString appendFormat:@"&IgnoreLock=%@", IgnoreLock];
	
	NSLog(@"%@", paramString);
	
	NSData *paramData = [ NSData dataWithBytes: [ paramString UTF8String ] length: [ paramString length]];
	[request setHTTPBody: paramData ];
	
	[request setValue:info->m_strFileServer forHTTPHeaderField:@"Host"];
	[request setValue:@"application/x-www-form-urlencoded" forHTTPHeaderField:@"Content-Type"];
	[request setValue:@"Net-ID Browser" forHTTPHeaderField:@"User-Agent"];
	[request setValue:@"Keep-Alive" forHTTPHeaderField:@"Connection"];
	[request setValue:@"utf8" forHTTPHeaderField:@"Accept-Charset"];

	[request setValue:[self GetCookie:nDrive fileInfo:fileInfo sharePath:sharePath] forHTTPHeaderField:@"Cookie"];
	
	m_sender = sender;
	m_selector = selector;
	
	[self sendRequest:request];
}

// 파일서버에서 파일 지우기
- (void) DeleteFile: (int) nDrive  
		   fileName: (NSString *) fileName 
		   fileInfo: (CFileInfo *) fileInfo 
		  sharePath: (NSString *) sharePath
			 sender: (id) sender 
		   selector: (SEL) selector
{
	commandType = ST_DELETE_FILE;

	UIViewController	*controller = (UIViewController *)sender;
	[m_activityViewController showActivity:controller.view];
	
	NSString	* requestURI;
	
	NIDriveInfo *info = [g_appDelegate.m_arrDriveInfo objectAtIndex:nDrive];

	// 공유 폴더
	if (info->m_nDiskType == DT_SHARE && fileInfo)
		requestURI = [NSString stringWithFormat:@"http://%@:%d/PlusDrive/DeleteFile", fileInfo.m_strFileServer, scLogin.nHttpPort];
	else
		requestURI = [NSString stringWithFormat:@"http://%@:%d/PlusDrive/DeleteFile", info->m_strFileServer, scLogin.nHttpPort];

	NSLog(@"requestURI is %@", requestURI);
	
	m_fileName = [fileName copy];

	NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:[ NSURL URLWithString: requestURI ]];
	
	//method
	[request setHTTPMethod:@"POST"];
	
	//param
	NSMutableString *paramString=[NSMutableString string];
	
	NSLog(@"fileName is ...%@...", fileName);
	
	NSString * SrcName = [self encode:fileName withKey:scLogin.ks];
	NSString * FileServer = [self encode:info->m_strFileServer withKey:scLogin.ks];
	
	NSString * Subtree = [self encode:@"yes" withKey:scLogin.ks];
	NSString * Remove = [self encode:@"yes" withKey:scLogin.ks];
	NSString * DeleteShare = [self encode:@"yes" withKey:scLogin.ks];
	NSString * DeleteACL = [self encode:@"yes" withKey:scLogin.ks];
	NSString * IgnoreLock = [self encode:@"yes" withKey:scLogin.ks];
	NSString * RmDirIfEmpty = [self encode:@"yes" withKey:scLogin.ks];
	
	[paramString appendFormat:@"SrcName=%@", SrcName];
	[paramString appendFormat:@"&FileServer=%@", FileServer];
	[paramString appendFormat:@"&Subtree=%@", Subtree];
	[paramString appendFormat:@"&Remove=%@", Remove];
	[paramString appendFormat:@"&DeleteShare=%@", DeleteShare];
	[paramString appendFormat:@"&DeleteACL=%@", DeleteACL];
	[paramString appendFormat:@"&IgnoreLock=%@", IgnoreLock];
	[paramString appendFormat:@"&RmDirIfEmpty=%@", RmDirIfEmpty];
	
	NSLog(@"%@", paramString);
	
	NSData *paramData = [ NSData dataWithBytes: [ paramString UTF8String ] length: [ paramString length]];
	[request setHTTPBody: paramData ];
	
	[request setValue:info->m_strFileServer forHTTPHeaderField:@"Host"];
	[request setValue:@"application/x-www-form-urlencoded" forHTTPHeaderField:@"Content-Type"];
	[request setValue:@"Net-ID Browser" forHTTPHeaderField:@"User-Agent"];
	[request setValue:@"Keep-Alive" forHTTPHeaderField:@"Connection"];
	[request setValue:@"utf8" forHTTPHeaderField:@"Accept-Charset"];

	[request setValue:[self GetCookie:nDrive fileInfo:fileInfo sharePath:sharePath] forHTTPHeaderField:@"Cookie"];
	
	m_nDrive = nDrive;
	m_folderName = [[NSString alloc] initWithString:[fileName stringByDeletingLastPathComponent]];
	
	NSLog(@"folderName is %@", m_folderName);
	
	m_sender = sender;
	m_selector = selector;
	
	[self sendRequest:request];
}

// 파일서버에서 폴더 목록 얻기
- (void) GetList: (int) nDrive  
	  folderName: (NSString *) folderName 
		fileInfo: (CFileInfo *) fileInfo 
	   sharePath: (NSString *) sharePath 	   
	   recursive: (BOOL) isRecursive 
		  sender: (id) sender 
		selector: (SEL) selector
   g_appDelegate: (CentralECMAppDelegate *) g_appDelegate;
{
	commandType = ST_GET_LIST;
	
	NSString * requestURI;
	
	NIDriveInfo *info = [g_appDelegate.m_arrDriveInfo objectAtIndex:nDrive];
    NICookieInfo *cookieinfo = [g_appDelegate.m_arrCookieInfo objectAtIndex:nDrive];
    
	// 공유 폴더
	if (info->m_nDiskType == DT_SHARE && fileInfo)
		requestURI = [NSString stringWithFormat:@"%@://%@:%@/PlusDrive/GetList", info.m_strFileServerProtocol,fileInfo.m_strFileServer, info->m_strFileServerPort];
	else
		requestURI = [NSString stringWithFormat:@"%@://%@:%@/PlusDrive/GetList", info.m_strFileServerProtocol, info->m_strFileServer, info->m_strFileServerPort];
		
	NSLog(@"requestURI is %@", requestURI);
	
	
	
	//param
	NSMutableString *paramString=[NSMutableString string];
    NSMutableString *proxyParamString=[NSMutableString string];
	NSString *npass = [Util md5:cookieinfo->m_strSiteID];
    
	NSLog(@"folderName is ...%@...", folderName);
	
	NSString * SrcName = [self encode:folderName withKey:npass];
	NSString * Subtree;
	
	if (isRecursive)
		Subtree = [self encode:@"yes" withKey:npass];
	else
		Subtree = [self encode:@"no" withKey:npass];
	
	NSString * OnlyDir = [self encode:@"no" withKey:npass];
	NSString * Chunked = [self encode:@"yes" withKey:npass];
	
	[paramString appendFormat:@"SrcName=%@", SrcName];
	[paramString appendFormat:@"&Subtree=%@", Subtree];
	[paramString appendFormat:@"&OnlyDir=%@", OnlyDir];
	[paramString appendFormat:@"&Chunked=%@", Chunked];
	/*
    [proxyParamString appendFormat:@"?SrcName=%@", SrcName];
    [proxyParamString appendFormat:@"&Subtree=%@", Subtree];
    [proxyParamString appendFormat:@"&OnlyDir=%@", OnlyDir];
    [proxyParamString appendFormat:@"&Chunked=%@", Chunked];
    
    if([cookieinfo->m_useProxy  isEqual: @"true"]){
        requestURI = [requestURI stringByAppendingString:proxyParamString];
    }
    */
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:[ NSURL URLWithString: requestURI ]];
    
    //method
    [request setHTTPMethod:@"POST"];
    
    
	NSLog(@"%@", paramString);
	
	NSData *paramData = [ NSData dataWithBytes: [ paramString UTF8String ] length: [ paramString length]];
	[request setHTTPBody: paramData ];
	
	[request setValue:info->m_strFileServer forHTTPHeaderField:@"Host"];
	[request setValue:@"application/x-www-form-urlencoded" forHTTPHeaderField:@"Content-Type"];
	[request setValue:@"Net-ID Browser" forHTTPHeaderField:@"User-Agent"];
	[request setValue:@"Keep-Alive" forHTTPHeaderField:@"Connection"];
	[request setValue:@"utf8" forHTTPHeaderField:@"Accept-Charset"];
	
    [request setValue:[self GetCookie:nDrive fileInfo:fileInfo sharePath:sharePath  
                        g_appDelegate: g_appDelegate] forHTTPHeaderField:@"Cookie"];
	
	m_sender = sender;
	m_selector = selector;
	
    if([cookieinfo->m_useProxy  isEqual: @"true"]){

        NSString *protocol = info.m_strFileServerProtocol;
        NSString *port = info->m_strFileServerPort;
        NSString *server = info->m_strFileServer;
        NSString *strMethod = @"POST";
        NSString *strTarget = @"/webapp/protocal_mgmt.jsp";
        NSString *paraData = @"";
        NSString *paraCookie = @"";
        
        NSString *strTmp = [[NSString alloc] initWithFormat:@"%x", [self GetOption:info->m_nDiskType]];
        
        paraData = [paraData stringByAppendingFormat:@"Server=%@", server];
        paraData = [paraData stringByAppendingFormat:@"&Port=%@", port];
        paraData = [paraData stringByAppendingFormat:@"&Url=/PlusDrive/GetList&CookieData="];
        paraData = [paraData stringByAppendingFormat:@"DomainID=%@;", [self encode:cookieinfo->m_strDomainID withKey:npass]];
        paraData = [paraData stringByAppendingFormat:@"DiskType=%@;", [self encode:[info getCmdDiskType] withKey:npass]];
        paraData = [paraData stringByAppendingFormat:@"User=%@;", [self encode:cookieinfo->m_strUser withKey:npass]];
        paraData = [paraData stringByAppendingFormat:@"Partition=%@;", [self encode:info->m_strPartition withKey:npass]];
        paraData = [paraData stringByAppendingFormat:@"WebServer=%@;", [self encode:cookieinfo->m_strWebServer withKey:npass]];
        paraData = [paraData stringByAppendingFormat:@"Agent=%@;", [self encode:cookieinfo->m_strAgent withKey:npass]];
        paraData = [paraData stringByAppendingFormat:@"Option=%@;", [self encode:strTmp withKey:npass]];
        paraData = [paraData stringByAppendingFormat:@"Cowork=%@;", [self encode:info->m_strOwner withKey:npass]];
        paraData = [paraData stringByAppendingFormat:@"ShareUser=%@;", [self encode:cookieinfo->m_strShareUser withKey:npass]];
        paraData = [paraData stringByAppendingFormat:@"SharePath=%@;", [self encode:cookieinfo->m_strSharePath withKey:npass]];
        paraData = [paraData stringByAppendingFormat:@"StartPath=%@;", [self encode:info->m_strStartPath withKey:npass]];
        paraData = [paraData stringByAppendingFormat:@"RealIP=%@", [self encode:cookieinfo->m_strRealIP withKey:npass]];
        paraData = [paraData stringByAppendingFormat:@"&ParamData=SrcName=%@;", SrcName];
        paraData = [paraData stringByAppendingFormat:@"Subtree=%@;", Subtree];
        paraData = [paraData stringByAppendingFormat:@"OnlyDir=%@;", OnlyDir];
        paraData = [paraData stringByAppendingFormat:@"Chunked=%@", Chunked];

        NSData *postData = [paraData dataUsingEncoding:NSASCIIStringEncoding allowLossyConversion:YES];
        
        NSString* proxyHost = @"1.212.69.220";
        NSNumber* proxyPort = [NSNumber numberWithInt: 53334];
        
        // Create an NSURLSessionConfiguration that uses the proxy
        NSDictionary *proxyDict = @{
                                    @"HTTPEnable"  : [NSNumber numberWithInt:1],
                                    (NSString *)kCFStreamPropertyHTTPProxyHost  : proxyHost,
                                    (NSString *)kCFStreamPropertyHTTPProxyPort  : proxyPort,
                                    
                                    @"HTTPSEnable" : [NSNumber numberWithInt:1],
                                    (NSString *)kCFStreamPropertyHTTPSProxyHost : proxyHost,
                                    (NSString *)kCFStreamPropertyHTTPSProxyPort : proxyPort,
                                    };
        
        NSURLSessionConfiguration *configuration = [NSURLSessionConfiguration ephemeralSessionConfiguration];
        configuration.connectionProxyDictionary = proxyDict;
        //    protocol, port, Server, strMethod, strTarget, paraData, paraCookie)
        
        // Create a NSURLSession with our proxy aware configuration
        NSURLSession *session = [NSURLSession sessionWithConfiguration:configuration delegate:self delegateQueue:[NSOperationQueue mainQueue]];
        
        // Form the request
        NSMutableURLRequest *request = [[[NSMutableURLRequest alloc] init] autorelease];
        
        
        NSString *smsURL = @"http://";
        smsURL = [smsURL stringByAppendingString:server];
        smsURL = [smsURL stringByAppendingString:strTarget];
        
        
        [request setURL:[NSURL URLWithString:smsURL]];
        [request setHTTPMethod:strMethod];
        [request setValue:@"application/x-www-form-urlencoded" forHTTPHeaderField:@"Content-Type"];
        [request setHTTPBody:postData];
        
        
        
        
        
        /*
        NSString* proxyHost = @"1.212.69.220";
        NSNumber* proxyPort = [NSNumber numberWithInt: 53334];
        
        // Create an NSURLSessionConfiguration that uses the proxy
        NSDictionary *proxyDict = @{
                                    @"HTTPEnable"  : [NSNumber numberWithInt:1],
                                    (NSString *)kCFStreamPropertyHTTPProxyHost  : proxyHost,
                                    (NSString *)kCFStreamPropertyHTTPProxyPort  : proxyPort,
                                    
                                    @"HTTPSEnable" : [NSNumber numberWithInt:1],
                                    (NSString *)kCFStreamPropertyHTTPSProxyHost : proxyHost,
                                    (NSString *)kCFStreamPropertyHTTPSProxyPort : proxyPort,
                                    };
        
        NSURLSessionConfiguration *configuration = [NSURLSessionConfiguration ephemeralSessionConfiguration];
        configuration.connectionProxyDictionary = proxyDict;
        //    protocol, port, Server, strMethod, strTarget, paraData, paraCookie)
        
        // Create a NSURLSession with our proxy aware configuration
        NSURLSession *session = [NSURLSession sessionWithConfiguration:configuration delegate:self delegateQueue:[NSOperationQueue mainQueue]];
*/
        __block NSString *str = nil;
        __block NSArray *lines = nil;
        __block NSString *errmsg = nil;
        
        // Dispatch the request on our custom configured session
        NSURLSessionDataTask *task = [session dataTaskWithRequest:request completionHandler:
                                      ^(NSData *data, NSURLResponse *response, NSError *error) {
                                          
                                          NSLog(@"NSURLSession got the response [%@]", response);
                                          NSLog(@"NSURL!!Session got the data [%@]", [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding]);
                                          str = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
                                          
                                          receiveData = [[NSMutableData alloc] initWithData:data];
                                          
                                          lines = [str componentsSeparatedByString:@"\r\n"];
                                          
                                          NSLog(@"%lu lines received.", (unsigned long)[lines count]);
                                          
                                          for (int i=0; i<[lines count]; i++)
                                              NSLog(@"%@", [lines objectAtIndex:i]);
                                          
                                          switch (commandType)
                                          {
                                              case	ST_LOGIN:
                                                  [self processLogin:lines];
                                                  break;
                                              case	ST_GET_SERVER_INFO:
                                                  [self processGetServerInfo:lines];
                                                  break;
                                              case	ST_GET_DRIVE_LIST:
                                                  //[self processGetDriveList:lines];
                                                  [self processNewGetDriveList:lines];
                                                  break;
                                              case	ST_GET_LIST:
                                                  [self processGetList:lines];
                                                  break;
                                              case	ST_DELETE_FILE:
                                                  [self processDeleteFile:lines];
                                                  break;
                                              case	ST_RENAME_FILE:
                                                  [self processRenameFile:lines];
                                                  break;
                                              case	ST_EMPTY_RECYCLED:
                                                  [self processEmptyRecycled:lines];
                                                  break;
                                              case	ST_CREATE_DIR:
                                                  [self processCreateDir:lines];
                                                  break;
                                              case	ST_PUT_FILE:
                                                  [self processPutFile:lines];
                                                  break;
                                              case	ST_ACCOUNT:
                                                  [self processAccount:lines];
                                                  break;
                                          }
                                          
                                      }];
        
        NSLog(@"Lets fire up the task!");
        [task resume];
        
    } else{
        
        NSString *protocol = info.m_strFileServerProtocol;
        NSString *port = info->m_strFileServerPort;
        NSString *server = info->m_strFileServer;
        NSString *strMethod = @"POST";
        NSString *strTarget = @"/webapp/protocal_mgmt.jsp";
        NSString *paraData = @"";
        NSString *paraCookie = @"";
        
        NSString *strTmp = [[NSString alloc] initWithFormat:@"%x", [self GetOption:info->m_nDiskType]];
        
        paraData = [paraData stringByAppendingFormat:@"Server=%@", server];
        paraData = [paraData stringByAppendingFormat:@"&Port=%@", port];
        paraData = [paraData stringByAppendingFormat:@"&Url=/PlusDrive/GetList&CookieData="];
        paraData = [paraData stringByAppendingFormat:@"DomainID=%@;", [self encode:cookieinfo->m_strDomainID withKey:npass]];
        paraData = [paraData stringByAppendingFormat:@"DiskType=%@;", [self encode:[info getCmdDiskType] withKey:npass]];
        paraData = [paraData stringByAppendingFormat:@"User=%@;", [self encode:cookieinfo->m_strUser withKey:npass]];
        paraData = [paraData stringByAppendingFormat:@"Partition=%@;", [self encode:info->m_strPartition withKey:npass]];
        paraData = [paraData stringByAppendingFormat:@"WebServer=%@;", [self encode:cookieinfo->m_strWebServer withKey:npass]];
        paraData = [paraData stringByAppendingFormat:@"Agent=%@;", [self encode:cookieinfo->m_strAgent withKey:npass]];
        paraData = [paraData stringByAppendingFormat:@"Option=%@;", [self encode:strTmp withKey:npass]];
        paraData = [paraData stringByAppendingFormat:@"Cowork=%@;", [self encode:info->m_strOwner withKey:npass]];
        paraData = [paraData stringByAppendingFormat:@"ShareUser=%@;", [self encode:cookieinfo->m_strShareUser withKey:npass]];
        paraData = [paraData stringByAppendingFormat:@"SharePath=%@;", [self encode:cookieinfo->m_strSharePath withKey:npass]];
        paraData = [paraData stringByAppendingFormat:@"StartPath=%@;", [self encode:info->m_strStartPath withKey:npass]];
        paraData = [paraData stringByAppendingFormat:@"RealIP=%@", [self encode:cookieinfo->m_strRealIP withKey:npass]];
        paraData = [paraData stringByAppendingFormat:@"&ParamData=SrcName=%@;", SrcName];
        paraData = [paraData stringByAppendingFormat:@"Subtree=%@;", Subtree];
        paraData = [paraData stringByAppendingFormat:@"OnlyDir=%@;", OnlyDir];
        paraData = [paraData stringByAppendingFormat:@"Chunked=%@", Chunked];
        
        NSData *postData = [paraData dataUsingEncoding:NSASCIIStringEncoding allowLossyConversion:YES];
        
        /*
        // Create a NSURLSession with our proxy aware configuration
        NSURLSession *session = [NSURLSession sessionWithConfiguration:[NSURLSessionConfiguration defaultSessionConfiguration] delegate:self delegateQueue:[NSOperationQueue mainQueue]];
        */
        
        
        
        NSMutableURLRequest *request = [[[NSMutableURLRequest alloc] init] autorelease];
        
        /*
        NSString *smsURL = @"http://";
        smsURL = [smsURL stringByAppendingString:server];
        smsURL = [smsURL stringByAppendingString:strTarget];
        
        
        [request setURL:[NSURL URLWithString:smsURL]];
        [request setHTTPMethod:strMethod];
        [request setValue:@"application/x-www-form-urlencoded" forHTTPHeaderField:@"Content-Type"];
        [request setHTTPBody:postData];
*/
        
        
        
        
        NSString *smsURL = @"http://";
        smsURL = [smsURL stringByAppendingString:server];
        smsURL = [smsURL stringByAppendingString:strTarget];

        [request setURL:[NSURL URLWithString:smsURL]];
        [request setHTTPMethod:strMethod];
        [request setValue:@"application/x-www-form-urlencoded" forHTTPHeaderField:@"Content-Type"];
        [request setHTTPBody:postData];
        
        /*
//        [request setURL:[NSURL URLWithString:smsURL]];
        [request setHTTPMethod:strMethod];
        
        [request setValue:info->m_strFileServer forHTTPHeaderField:@"Host"];
        [request setValue:@"application/x-www-form-urlencoded" forHTTPHeaderField:@"Content-Type"];
        [request setValue:@"Net-ID Browser" forHTTPHeaderField:@"User-Agent"];
        [request setValue:@"Keep-Alive" forHTTPHeaderField:@"Connection"];
        [request setValue:@"utf8" forHTTPHeaderField:@"Accept-Charset"];
        
        [request setValue:[self GetCookie:nDrive fileInfo:fileInfo sharePath:sharePath
                            g_appDelegate: g_appDelegate] forHTTPHeaderField:@"Cookie"];
        
        [request setHTTPBody: paramData ];
        */
        
        [self sendRequest:request];
    }

}

- (BOOL) GetDiskInfo: (int) nDrive
{
	commandType = ST_GET_DISK_INFO;
	
	NIDriveInfo *info = [g_appDelegate.m_arrDriveInfo objectAtIndex:nDrive];

	NSString * requestURI = [NSString stringWithFormat:@"http://%@:%d/PlusDrive/GetDiskInfo", info->m_strFileServer, scLogin.nHttpPort];
	NSLog(@"requestURI is %@", requestURI);
	NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:[ NSURL URLWithString: requestURI ]];
	
	//method
	[request setHTTPMethod:@"POST"];
	
	[request setValue:info->m_strFileServer forHTTPHeaderField:@"Host"];
	[request setValue:@"application/x-www-form-urlencoded" forHTTPHeaderField:@"Content-Type"];
	[request setValue:@"Net-ID Browser" forHTTPHeaderField:@"User-Agent"];
	[request setValue:@"Keep-Alive" forHTTPHeaderField:@"Connection"];
	[request setValue:@"utf8" forHTTPHeaderField:@"Accept-Charset"];
	
	[request setValue:[self GetCookie:nDrive fileInfo:nil sharePath:nil] forHTTPHeaderField:@"Cookie"];
	
	NSError        *error = nil;
	NSURLResponse  *response = nil;

	NSData * data = [NSURLConnection sendSynchronousRequest: request returningResponse: &response error: &error];
	receiveData = [[NSMutableData alloc] initWithData:data];
	
	if (error)
	{
		[receiveData release];
		
//		*errmsg = [[NSString alloc] initWithString:[error localizedDescription]];
		return FALSE;
	}
	else
	{
		NSString *str = [[NSString alloc] initWithData:receiveData encoding:NSUTF8StringEncoding];
		NSArray *lines = [str componentsSeparatedByString:@"\r\n"];
		
		NSLog(@"%d lines received.", [lines count]);
		
		for (int i=0; i<[lines count]; i++)
			NSLog(@"GetDiskInfo: %@", [lines objectAtIndex:i]);
		
		[receiveData release];
		
		if ([lines count] < 2)
		{
//			*errmsg = [[NSString alloc] initWithString:NSLocalizedString(@"Network Error", nil)];
			return FALSE;
		}
		// Success 또는 SuccessReplace
		else if ([[lines objectAtIndex:1] length] >= 7 && ![[[lines objectAtIndex:1] substringToIndex:7] isEqualToString:@"Success"])
		{
//			*errmsg = [[NSString alloc] initWithString:[lines objectAtIndex:1]];
			return FALSE;
		}
		else
		{
			NSArray * arrayItems = [[lines objectAtIndex:2] componentsSeparatedByString:@"\t"];
			
			for (int i=0; i<[arrayItems count]; i++)
				NSLog(@"GetDiskInfo: %@", [arrayItems objectAtIndex:i]);

			NIDriveInfo *info = [g_appDelegate.m_arrDriveInfo objectAtIndex:nDrive];
			
			info->m_nTotalSpace = 0;
			info->m_nAvailableSpace = 0;
			
			if ([arrayItems count] >= 2)
			{
				info->m_nTotalSpace = [[arrayItems objectAtIndex:0] longLongValue];
				info->m_nAvailableSpace = [[arrayItems objectAtIndex:1] longLongValue];
			}
			
			return TRUE;
		}
	}
}

- (void) GetDriveList: (id) sender 
			 selector: (SEL) selector
{
	UIViewController	*controller = (UIViewController *)sender;
	[m_activityViewController showActivity:controller.view];

	m_sender = sender;
	m_selector = selector;
	
	[self GetDriveList];
}

// 웹서버에서 드라이브 목록 얻기
- (void) GetDriveList
{
	/*
	commandType = ST_GET_DRIVE_LIST;
	
	g_driveInfo[0].m_strName = nil;
	g_driveInfo[1].m_strName = nil;
	g_driveInfo[2].m_strName = nil;
	
	NSString * requestURI = [NSString stringWithFormat:@"http://%@/clientsvc/GetDriveList.jsp", g_serverName];
	NSLog(@"requestURI is %@", requestURI);
	NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:[ NSURL URLWithString: requestURI ]];
	
	//method
	[request setHTTPMethod:@"POST"];
	
	//param
	NSMutableString *paramString=[NSMutableString string];
	
	NSString * User = [self encode:g_loginID withKey:scLogin.ks];
	
	[paramString appendFormat:@"User=%@",      User ];
	
	NSLog(@"%@", paramString);
	
	NSData *paramData = [ NSData dataWithBytes: [ paramString UTF8String ] length: [ paramString length]];
	[request setHTTPBody: paramData ];
	
	NSString * DomainID = [self encode:scLogin.strDomainID withKey:scLogin.ks];
	NSString * LangID = [self encode:m_langID withKey:scLogin.ks];
	
	[request setValue:g_serverName forHTTPHeaderField:@"Host"];
	[request setValue:@"application/x-www-form-urlencoded" forHTTPHeaderField:@"Content-Type"];
	[request setValue:@"Net-ID Browser" forHTTPHeaderField:@"User-Agent"];
	[request setValue:@"Keep-Alive" forHTTPHeaderField:@"Connection"];
	[request setValue:@"utf8" forHTTPHeaderField:@"Accept-Charset"];
	[request setValue: [NSString stringWithFormat:@"DomainID=%@;LangID=%@;", DomainID, LangID] forHTTPHeaderField:@"Cookie"];
	
	[self sendRequest:request];
	 */
}

- (void) GetServerInfo
{
	commandType = ST_GET_SERVER_INFO;
	NSString * requestURI;
/*
	if ([WebServerItems count] >= 2) {
		NSLog(@"g_serverName is %@", g_serverName);
		NSLog(@"WebServerPort is %@", g_serverPort);
		//requestURI = [NSString stringWithFormat:@"http://%@:%@/clientsvc/GetServerInfo.jsp", g_serverName, g_serverPort];
	}
	else {
		requestURI = [NSString stringWithFormat:@"http://%@/clientsvc/GetServerInfo.jsp", g_serverName];
	}
*/	
	requestURI = [NSString stringWithFormat:@"http://%@/clientsvc/GetServerInfo.jsp", g_serverName];
	NSLog(@"requestURI is %@", requestURI);
	
	NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:[ NSURL URLWithString: requestURI ]];
	
	//method
	[request setHTTPMethod:@"POST"];
	
	NSString * InstallVersion = [self encode:INSTALL_VERSION withKey:scLogin.ks];
	NSString * LangID = [self encode:m_langID withKey:scLogin.ks];
	
	[request setValue:g_serverName forHTTPHeaderField:@"Host"];
	[request setValue:@"application/x-www-form-urlencoded" forHTTPHeaderField:@"Content-Type"];
	[request setValue:@"Net-ID Browser" forHTTPHeaderField:@"User-Agent"];
	[request setValue:@"Keep-Alive" forHTTPHeaderField:@"Connection"];
	[request setValue:@"utf8" forHTTPHeaderField:@"Accept-Charset"];
	[request setValue: [NSString stringWithFormat:@"InstallVersion=%@;LangID=%@", InstallVersion, LangID] forHTTPHeaderField:@"Cookie"];
	
	[self sendRequest:request];
}

- (void) Login: (NSString *) serverName
	   loginID: (NSString *) loginID
   loginPasswd: (NSString *) loginPasswd
 loginUserType: (LoginUserType) nLoginUserType
		sender: (id) sender 
	  selector: (SEL) selector
{
	commandType = ST_LOGIN;
	
	UIViewController	*controller = (UIViewController *)sender;
	[m_activityViewController showActivity:controller.view];
/*
	WebServerItems = [serverName componentsSeparatedByString:@":"];
	
	if ([WebServerItems count] >= 2) {
		g_serverName = [NSString stringWithString:[WebServerItems objectAtIndex:0]];
		g_serverPort = [NSString stringWithString:[WebServerItems objectAtIndex:1]];
	}
	else {
		g_serverName = [NSString stringWithString:serverName];
	}
*/
	g_serverName = [NSString stringWithString:serverName];
	g_loginID = [NSString stringWithString:loginID];
	g_nLoginUserType = nLoginUserType;
	NSLog(@"g_serverName: %@, g_loginID: %@, g_loginUserType: %d", g_serverName, g_loginID, g_nLoginUserType);
/*
NSString * requestURI;

if ([WebServerItems count] >= 2) {
		requestURI = [NSString stringWithFormat:@"http://%@:%@/clientsvc/Login.jsp", g_serverName, g_serverPort];
	}
	else {
		requestURI = [NSString stringWithFormat:@"http://%@/clientsvc/Login.jsp", g_serverName];
	}
*/
	NSString * requestURI = [NSString stringWithFormat:@"http://%@/clientsvc/Login.jsp", g_serverName];
	NSLog(@"requestURI is %@", requestURI);
	
	NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:[ NSURL URLWithString: requestURI ]];
	
	assert(request != nil);
	
	//method
	[request setHTTPMethod:@"POST"];
	NSDateFormatter	*dateFormat = [[NSDateFormatter alloc] init];
	[dateFormat setAMSymbol:@""];
	[dateFormat setPMSymbol:@""];
	[dateFormat setDateFormat:@"ddHHmmss"];
	m_initialKey = [[NSString alloc] initWithString:[dateFormat stringFromDate:[NSDate date]]];
	
	//param
	NSMutableString *paramString=[NSMutableString string];
	
	NSString * LoginType = [self encode:((nLoginUserType == LUT_NORMAL) ? @"Normal" : @"Guest") withKey:m_initialKey];
	NSString * User = [self encode:g_loginID withKey:m_initialKey];
	NSString * Password = [self encode:loginPasswd withKey:m_initialKey];
	NSString * AdminType = [self encode:@"no" withKey:m_initialKey];		// if Yes, OrgChart Editer used
	
	[paramString appendFormat:@"LoginType=%@",  LoginType ];
	[paramString appendFormat:@"&User=%@",      User ];
	[paramString appendFormat:@"&Password=%@",  Password ];
	[paramString appendFormat:@"&AdminType=%@", AdminType ];
	
	NSLog(@"%@", paramString);
	
	NSData *paramData = [ NSData dataWithBytes: [ paramString UTF8String ] length: [ paramString length]];
	[request setHTTPBody: paramData ];
	
	NSString * LoginSession = [self encode:m_initialKey withKey:@"PLUSDISK"];
	NSString * InstallVersion = [self encode:INSTALL_VERSION withKey:m_initialKey];
	NSString * LangID = [self encode:m_langID withKey:m_initialKey];
	
	[request setValue:g_serverName forHTTPHeaderField:@"Host"];
	[request setValue:@"application/x-www-form-urlencoded" forHTTPHeaderField:@"Content-Type"];
	[request setValue:@"Net-ID Browser" forHTTPHeaderField:@"User-Agent"];
	[request setValue:@"Keep-Alive" forHTTPHeaderField:@"Connection"];
	[request setValue:@"utf8" forHTTPHeaderField:@"Accept-Charset"];
	[request setValue: [NSString stringWithFormat:@"PlusVersion=1;LoginSession=%@;InstallVersion=%@;LangID=%@", LoginSession, InstallVersion, LangID] forHTTPHeaderField:@"Cookie"];
	
	m_sender = sender;
	m_selector = selector;
	[self sendRequest:request];
}

//GPS Info
- (void) DeviceGPS: (NSString *) gps
          DeviceID: (NSString *) deviceid
         WebServer: (NSString *) webserver
            SiteID: (NSString *) siteid
{
	commandType = ST_SEND_DEVICE_INFO;
	NSString * requestURI;

	requestURI = [NSString stringWithFormat:@"http://%@/webapp/mgmt_android.jsp", webserver];
	NSLog(@"requestURI is %@", requestURI);
	
	NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:[ NSURL URLWithString: requestURI ]];
	
    NSString *npass = [Util md5:siteid];
	//method
	[request setHTTPMethod:@"POST"];
	
	NSString * LocationInfo = [self encode:gps withKey:npass];
	NSString * DeviceID = [self encode:deviceid withKey:npass];
	
    NSLog(@"LocationInfo %@, %@", gps, LocationInfo);
    NSLog(@"DeviceID is %@, %@", deviceid, DeviceID);
    
    // param
	NSMutableString *paramString=[NSMutableString string];

    [paramString appendFormat:@"LocationInfo=%@", LocationInfo];
	[paramString appendFormat:@"&DeviceID=%@", DeviceID];
	
	NSLog(@"%@", paramString);
	
	NSData *paramData = [ NSData dataWithBytes: [ paramString UTF8String ] length: [ paramString length]];
	[request setHTTPBody: paramData ];
    
	[request setValue:g_serverName forHTTPHeaderField:@"Host"];
	[request setValue:@"application/x-www-form-urlencoded" forHTTPHeaderField:@"Content-Type"];
	[request setValue:@"Net-ID Browser" forHTTPHeaderField:@"User-Agent"];
	[request setValue:@"Keep-Alive" forHTTPHeaderField:@"Connection"];
	[request setValue:@"utf8" forHTTPHeaderField:@"Accept-Charset"];
	[request setValue: [NSString stringWithFormat:@""] forHTTPHeaderField:@"Cookie"];
	
	[self sendRequest:request];
}

#pragma mark -
#pragma mark Http Request

- (void) sendRequest:(NSMutableURLRequest *) request
{
	m_connection = [[NSURLConnection alloc] initWithRequest:request delegate:self];
	
	if (m_connection)
	{
		receiveData = [[NSMutableData data] retain];
	}
	else
	{
		NSString * errmsg = [[NSString alloc] initWithString:@"Connection Failed"];
		[self sendResult:errmsg withObject: nil];
	}
}

- (void)connection:(NSURLConnection *)connection didSendBodyData:(NSInteger)bytesWritten 
 totalBytesWritten:(NSInteger)totalBytesWritten 
totalBytesExpectedToWrite:(NSInteger)totalBytesExpectedToWrite
{
	NSLog(@"bytesWritten:%ld KB, totalBytesWritten:%ld KB, totalBytesExpectedToWrite:%ld KB", 
		  bytesWritten/1024, totalBytesWritten/1024, totalBytesExpectedToWrite/1024);
	
	if (commandType == ST_PUT_FILE)
	{
		if (m_length != 0)
		{
			long long thisTime = [[NSDate date] timeIntervalSince1970] * 1000;
			m_activityViewController.m_progress.progress = totalBytesWritten*1.0/m_length;
			[m_activityViewController setStatus:totalBytesWritten totalsize: m_length time:thisTime-lastTime];
		}
	}
}

- (void)connection:(NSURLConnection *)connection didReceiveResponse:(NSURLResponse *)response
{
	NSHTTPURLResponse* httpResponse = (NSHTTPURLResponse*)response;
	int responseStatusCode = [httpResponse statusCode];
	
	NSLog(@"response status code is %d", responseStatusCode);
	
	// response status code를 체크한다.
	if (responseStatusCode == 200)
	{
		[receiveData setLength:0];
	}
	else
	{
		NSString * errmsg = [[NSString alloc] initWithFormat:@"response status code is %d", responseStatusCode];
		[self sendResult:errmsg withObject: nil];
	}
    
    NSError *e;
    [[NSFileManager defaultManager] removeItemAtPath:[[NSUserDefaults standardUserDefaults] objectForKey:@"pdfPath"] error:&e];
}

- (void)connection:(NSURLConnection *)connection didReceiveData:(NSData *)data
{
	// 데이터를 수신하면 append 한다.
	NSLog(@"%d bytes received2.", [data length]);
    [m_activityViewController.m_spinner stopAnimating];
	// 파일 다운로드
	if (commandType == ST_GET_FILE)
	{
		if (m_bFirst)
		{
			m_bFirst = false;
            
			char * bytes = malloc([data length]);
			[data getBytes:bytes length:[data length]];

			NSMutableArray * lines = [[NSMutableArray alloc] initWithCapacity:3];            			

            char buffer[1024];
			int offset = 0;

			for (int i=0; i<[data length]; i++)
			{
//                NSLog(@"byte[%d] is %d %c", i, bytes[i],bytes[i]);
				if (bytes[i] == 10)
				{
					memset(buffer, 0x00, 1024);
					memcpy(buffer, bytes+offset, i-offset-1);
					NSString * line = [[NSString alloc] initWithBytes:buffer length:i-offset-1 encoding:NSUTF8StringEncoding];
					
					NSLog(@"line is %@", line);
                    
					offset = i+1;
					NSLog(@"offset is %d", offset);
					
					[lines addObject:line];
					                    
					//if ([lines count] == 6)
                    //if([retMsg rangeOfString: @"\r\n\r\n"].location > -1)
					if(bytes[i+2] == 10){
                        offset = i + 3;
                        break;
                    }
				}
			}

			NSLog(@"%d lines received.", [lines count]);
			
			for (int i=0; i<[lines count]; i++)
				NSLog(@"%@", [lines objectAtIndex:i]);
			
			if ([lines count] < 2)
			{
				NSString *errmsg = [[NSString alloc] initWithString:@"Network Error"];
				[self sendResult:errmsg withObject: nil];
			}
			// Success 또는 SuccessReplace
			else if ([[lines objectAtIndex:1] length] >= 7 && ![[[lines objectAtIndex:1] substringToIndex:7] isEqualToString:@"Success"])
			{
				NSString *errmsg = [[NSString alloc] initWithString:[lines objectAtIndex:1]];
				[self sendResult:errmsg withObject: nil];
			}
			else
			{
				NSFileManager *fileMgr = [NSFileManager defaultManager];
				[fileMgr createFileAtPath:m_fileName contents:nil attributes:nil];
				NSLog(@"m_fileName is %@", m_fileName);
				NSData * content = [NSData dataWithBytes:bytes+offset length:[data length]-offset];
				NSLog(@"[data length] is %d", [data length]);
                NSLog(@"offset is %d", offset);
                NSLog(@"length is %d", [data length]-offset);

                
				m_length = [[lines objectAtIndex:2] longLongValue];
				
				m_fileHandle = [NSFileHandle fileHandleForWritingAtPath:m_fileName];
                
//                if(![m_strFlag isEqualToString:@"fileopen"])
//                    content = [content AES256EncryptWithKey:m_strKey];
				[m_fileHandle writeData:content];

				if (m_length != 0)
				{
					long long thisTime = [[NSDate date] timeIntervalSince1970] * 1000;
                    
					m_activityViewController.m_progress.progress = [m_fileHandle offsetInFile]*1.0/m_length;
					[m_activityViewController setStatus:[m_fileHandle offsetInFile] totalsize: m_length time:thisTime-lastTime];
				}
                
                //AppDelegate *test = [UIApplication sharedApplication].delegate;
                
                //test.mgmt_filename = [[NSString alloc] initWithString:@"test"];
				
				[m_fileHandle closeFile];
			}
		}
		else
		{
//            if([testflag isEqualToString:@"1"]){
//                testflag = @"2";
//                m_fileName = [m_fileName stringByReplacingOccurrencesOfString:@"%" withString:@""];
//            }
            
//            @try{
//                m_fileName = [m_fileName stringByReplacingOccurrencesOfString:@"%" withString:@""];
//            }
//            @catch (NSException * e) {
//                NSLog(@"Error: %@%@", [e name], [e reason]);
//            }
//            @finally {
//
//            }
			m_fileHandle = [NSFileHandle fileHandleForWritingAtPath:m_fileName];
			[m_fileHandle seekToEndOfFile];
        
            NSLog(@"strkey is %@", m_strKey);
//            
//           if(![m_strFlag isEqualToString:@"fileopen"])
//                data = [data AES256EncryptWithKey:m_strKey];
            
			[m_fileHandle writeData:data];			
			if (m_length != 0)
			{
				long long thisTime = [[NSDate date] timeIntervalSince1970] * 1000;
				m_activityViewController.m_progress.progress = [m_fileHandle offsetInFile]*1.0/m_length;
				[m_activityViewController setStatus:[m_fileHandle offsetInFile] totalsize: m_length time:thisTime-lastTime];
			}
            
            
			
			[m_fileHandle closeFile];
		}
//        m_fileHandle = [NSFileHandle fileHandleForWritingAtPath:m_fileName];
//        [m_fileHandle seekToEndOfFile];
//        
//        NSString *tmppath = m_fileName;
//        if([testflag isEqualToString:@"1"]){
//            testflag = @"2";
//            tmppath = [tmppath stringByReplacingOccurrencesOfString:@"%" withString:@""];
//        }
//        if ([m_fileHandle moveItemAtPath:m_fileName toPath:tmppath error:NULL] == YES){
//            // 파일 이동/이름 변경 성공
//            NSLog(@"success");
//        } else {
//            // 파일 이동/이름 변경 실패
//            NSLog(@"fail");
//        }
        [m_fileHandle closeFile];
        
	}
	else
	{
		[receiveData appendData:data];
	}
}

- (void)connection:(NSURLConnection *)connection didFailWithError:(NSError *)error
{
	[connection release];
	[receiveData release];

	NSString * errmsg = [[NSString alloc] initWithString:[error localizedDescription]];
	// [self sendResult:errmsg withObject: nil];
    [m_activityViewController hideActivity];
    
    if ([m_sender respondsToSelector:@selector(cancel)])
        [m_sender performSelector:@selector(cancel)];
}

#pragma mark -
#pragma mark Http Response Process

// response 데이터를 모두 받은 후 호출된다.
- (void)connectionDidFinishLoading:(NSURLConnection *)connection
{
	if (commandType == ST_GET_FILE){
        [self sendResult:nil withObject: m_fileName];
        [m_activityViewController hideActivity];
    }
	else
		[self processData: connection];
}

- (BOOL)processData: (NSURLConnection *)connection
{
	NSString *str = [[NSString alloc] initWithData:receiveData encoding:NSUTF8StringEncoding];
	NSArray *lines = [str componentsSeparatedByString:@"\r\n"];

	NSLog(@"%lu lines received.", (unsigned long)[lines count]);

	for (int i=0; i<[lines count]; i++)
		NSLog(@"%@", [lines objectAtIndex:i]);
	
	[connection release];
	[receiveData release];

	if ([lines count] < 2)
	{
		NSString *errmsg = [[NSString alloc] initWithString:@"Network Error"];
		NSLog(@"%@", str);
		[self sendResult:errmsg withObject: nil];
		return FALSE;
	}
	// Success 또는 SuccessReplace
	// TO DO : 수정 필요!!
	else if ([[lines objectAtIndex:1] length] >= 7 && ![[[lines objectAtIndex:1] substringToIndex:7] isEqualToString:@"Success"])
	{
		NSString *errmsg = [[NSString alloc] initWithString:[lines objectAtIndex:1]];
		
		if ([lines count] >= 3)
			[self sendResult:errmsg withObject: [lines objectAtIndex:2]];
		else
			[self sendResult:errmsg withObject: nil];
			
		return FALSE;
	}
	else
	{
		switch (commandType)
		{
			case	ST_LOGIN:
				[self processLogin:lines];
				break;
			case	ST_GET_SERVER_INFO:
				[self processGetServerInfo:lines];
				break;
			case	ST_GET_DRIVE_LIST:
				//[self processGetDriveList:lines];
				[self processNewGetDriveList:lines];
				break;
			case	ST_GET_LIST:
				[self processGetList:lines];
				break;
			case	ST_DELETE_FILE:
				[self processDeleteFile:lines];
				break;
			case	ST_RENAME_FILE:
				[self processRenameFile:lines];
				break;
			case	ST_EMPTY_RECYCLED:
				[self processEmptyRecycled:lines];
				break;
			case	ST_CREATE_DIR:
				[self processCreateDir:lines];
				break;
			case	ST_PUT_FILE:
				[self processPutFile:lines];
				break;
			case	ST_ACCOUNT:
				[self processAccount:lines];
				break;
		}
		
		return TRUE;
	}
}

// SSL 처리 로직
-(BOOL)connection:(NSURLConnection *)connection canAuthenticateAgainstProtectionSpace:(NSURLProtectionSpace *)protectionSpace{
    return [protectionSpace.authenticationMethod isEqualToString:NSURLAuthenticationMethodServerTrust];
}

// Connection Error를 내지 않기 위한 조치
-(void)connection:(NSURLConnection *)connection didReceiveAuthenticationChallenge:(NSURLAuthenticationChallenge *)challenge{
    if([challenge.protectionSpace.authenticationMethod isEqualToString:NSURLAuthenticationMethodServerTrust])
        if([challenge previousFailureCount] == 0)
            [challenge.sender useCredential:[NSURLCredential credentialForTrust:challenge.protectionSpace.serverTrust] forAuthenticationChallenge:challenge];
}

// 업로드 결과 처리
- (void) processPutFile:(NSArray *)lines
{
	for (int j=0; j<[lines count]; j++)
		NSLog(@"processPutFile: %@", [lines objectAtIndex:j]);

	NSArray * arrayItems = [[lines objectAtIndex:2] componentsSeparatedByString:@"\t"];
	CFileInfo *fileInfo = nil;
	
	if ([arrayItems count] >= 3)
	{
		fileInfo = [CFileInfo alloc];	
		fileInfo.m_dwACL = [self GetACL:[arrayItems objectAtIndex:0]];
		fileInfo.m_dtLastWriteTime = [[NSString alloc] initWithString:[arrayItems objectAtIndex:2]];
	}
	[m_activityViewController hideActivity];
	[self sendResult:nil withObject: fileInfo];
}

// 디렉토리 생성 결과 처리 함수
- (void) processCreateDir:(NSArray *)lines
{
	NSArray * arrayItems = [[lines objectAtIndex:2] componentsSeparatedByString:@"\t"];
	
	if ([arrayItems count] >= 3)
	{
		for (int j=0; j<[arrayItems count]; j++)
			NSLog(@"%@", [arrayItems objectAtIndex:j]);
		
		CFileInfo *fileInfo = [CFileInfo alloc];
		
		fileInfo.m_dwACL = [self GetACL:[arrayItems objectAtIndex:0]];
		fileInfo.m_dtLastWriteTime = [[NSString alloc] initWithString:[arrayItems objectAtIndex:2]];

		[self sendResult:nil withObject: fileInfo];
	}
	else
	{
		NSString *errmsg = [[NSString alloc] initWithString:@"Protocol Error"];
		[self sendResult:errmsg withObject: nil];
	}
}

// 휴지통 비우기 결과 처리 함수
- (void) processEmptyRecycled:(NSArray *)lines
{
	NSString *errmsg = [[NSString alloc] initWithString:[lines objectAtIndex:1]];
	[self sendResult:errmsg withObject: nil];
}

// 파일 이름 수정 결과 처리 함수
- (void) processRenameFile:(NSArray *)lines
{
	[self sendResult:nil withObject: nil];
}

// 파일 삭제 결과 처리 함수
- (void) processDeleteFile:(NSArray *)lines
{
	[self sendResult:nil withObject: m_fileName];
}

// 폴더 목록 결과 처리 함수
- (void) processGetList:(NSArray *)lines
{
	NSLog(@"%@", [lines objectAtIndex:2]);
	
	scList.dwACL = [self GetACL:[lines objectAtIndex:2]];
	NSMutableArray	* fileInfoArray = [[NSMutableArray alloc] initWithCapacity:[lines count]-3];
	
	for (int i=3; i<[lines count]; i++)
	{
		NSArray * arrayItems = [[lines objectAtIndex:i] componentsSeparatedByString:@"\t"];
		
		if ([arrayItems count] < 5)
			continue;
		
		for (int j=0; j<[arrayItems count]; j++)
			NSLog(@"%@", [arrayItems objectAtIndex:j]);
		
		CFileInfo	* fileInfo = [CFileInfo new];
		fileInfo.m_strName = [[NSString alloc] initWithString:[arrayItems objectAtIndex:0]];
		
		if ([fileInfo.m_strName isEqualToString:@"/"] || [fileInfo.m_strName isEqualToString:@"Recycled"])
			continue;
		
		fileInfo.m_n64Size = [[arrayItems objectAtIndex:1] longLongValue];
		fileInfo.m_dwACL = [self GetACL:[arrayItems objectAtIndex:2]];
		fileInfo.m_dwAttrib = [[arrayItems objectAtIndex:3] integerValue];
		fileInfo.m_dtLastWriteTime = [[NSString alloc] initWithString:[arrayItems objectAtIndex:4]];
		
		// 공유 1 레벨
		if ([arrayItems count] >= 10)
		{
			fileInfo.m_strDiskType = [[NSString alloc] initWithString:[arrayItems objectAtIndex:5]];
			fileInfo.m_diskType = [[arrayItems objectAtIndex:5] isEqualToString:@"personal"] ? DT_PERSONAL : [[arrayItems objectAtIndex:9] isEqualToString:@"orgcowork"] ? DT_ORGCOWORK : [[arrayItems objectAtIndex:9] isEqualToString:@"homepartition"] ? DT_HOMEPARTITION : DT_SHARE;
			fileInfo.m_strOwner = [[NSString alloc] initWithString:[arrayItems objectAtIndex:6]];
			fileInfo.m_stShare = [[NSString alloc] initWithString:[arrayItems objectAtIndex:7]];
			fileInfo.m_strFileServer = [[NSString alloc] initWithString:[arrayItems objectAtIndex:8]];
			fileInfo.m_strPartition = [[NSString alloc] initWithString:[arrayItems objectAtIndex:9]];
		}
		// 공유 2 레벨
		else if ([arrayItems count] >= 6)
		{
			fileInfo.m_stShare = [[NSString alloc] initWithString:[arrayItems objectAtIndex:5]];
		}
		
		[fileInfoArray addObject:fileInfo];
	}
	
	[self sendResult:nil withObject: fileInfoArray];
}

// 드라이브 목록 결과 처리 함수
- (void) processGetDriveList:(NSArray *)lines
{
	/*
	for (int i=0; i<3 && i<[lines count]-2; i++)
	{
		NSLog(@"%d...%@", (i+1), [lines objectAtIndex:i+2]);
		
		NSArray * arrayItems = [[lines objectAtIndex:i+2] componentsSeparatedByString:@"\t"];
		
		for (int j=0; j<[arrayItems count]; j++)
			NSLog(@"%d:%@", (j+1), [arrayItems objectAtIndex:j]);
		
		if ([arrayItems count] < 10)
			continue;
		
		// Name
		g_driveInfo[i].m_strName = [[NSString alloc] initWithString:[arrayItems objectAtIndex:0]];
		
		if (g_driveInfo[i].m_strName == nil)
			continue;
		
		// Drive Letter
		g_driveInfo[i].m_strAssignedDrive = [[NSString alloc] initWithString:[arrayItems objectAtIndex:1]];
		// Owner
		g_driveInfo[i].m_strOwner = [[NSString alloc] initWithString:[arrayItems objectAtIndex:2]];
		// OwnerType
		g_driveInfo[i].m_strOwnerType = [[NSString alloc] initWithString:[arrayItems objectAtIndex:3]];
		// Filer Server IP
		g_driveInfo[i].m_strFileServer = [[NSString alloc] initWithString:[arrayItems objectAtIndex:4]];
		// Partition
		g_driveInfo[i].m_strPartition = [[NSString alloc] initWithString:[arrayItems objectAtIndex:5]];
		// Start Path
		g_driveInfo[i].m_strStartPath = [[NSString alloc] initWithString:[arrayItems objectAtIndex:6]];
		// OrgCode
		g_driveInfo[i].m_strOrgCode = [[NSString alloc] initWithString:[arrayItems objectAtIndex:7]];
		// OrgName
		g_driveInfo[i].m_strOrgName = [[NSString alloc] initWithString:[arrayItems objectAtIndex:8]];
		// Type(personal = 홈폴더, orgcowork = 부서공간, share = 공유공간,
		// homepartition = 관리자가 각 사용자 폴더 용량 제한이 아닌 사용자 용량 제한을 가능케 함.)
		g_driveInfo[i].m_diskType = [[arrayItems objectAtIndex:9] isEqualToString:@"personal"] ? DT_PERSONAL : [[arrayItems objectAtIndex:9] isEqualToString:@"orgcowork"] ? DT_ORGCOWORK : [[arrayItems objectAtIndex:9] isEqualToString:@"homepartition"] ? DT_HOMEPARTITION : DT_SHARE;
	
		[self GetDiskInfo:i];
	}

	[self sendResult:nil withObject: nil];
	 */
}

// 서버 정보 결과 처리 함수
- (void) processGetServerInfo:(NSArray *)lines
{
	for (int i=0; i<[lines count]; i++)
		NSLog(@"%d...%@", (i+1), [lines objectAtIndex:i]);
	
//	[self GetDriveList];
	
	[self getDriveListofUserID:g_loginID withLoginType:scLogin.nLoginUserType];
}

// 로그인 결과 처리 함수
- (void) processLogin:(NSArray *)lines
{
	for (int i=0; i<[lines count]; i++)
		NSLog(@"%@", [lines objectAtIndex:i]);
	
	for ( int i = 2; i < [lines count]; i++ )
	{		
		NSArray *arrItems = [[lines objectAtIndex:i] componentsSeparatedByString:@"\t"];
		NSEnumerator *enumerator = [arrItems objectEnumerator];
		
		// Name
		scLogin.strUserName = [[NSString alloc] initWithString:[enumerator nextObject]];
		
		// FileServerIP
		scLogin.strFileServerIP = [[NSString alloc] initWithString:[enumerator nextObject]];
		
		// Partition
		scLogin.strPartition = [[NSString alloc] initWithString:[enumerator nextObject]];
		
		// StartPath
		scLogin.strStartPath = [[NSString alloc] initWithString:[enumerator nextObject]];
		
		// Owner
		scLogin.strOwner = [[NSString alloc] initWithString:[enumerator nextObject]];
		
		// ks
		scLogin.ks = [[NSString alloc] initWithString:[self decode:[enumerator nextObject] withKey:m_initialKey]]; 
		
		// HttpPort
		scLogin.nHttpPort = [[enumerator nextObject] intValue];
			
		// SSL Port
		scLogin.nSSLPort = [[enumerator nextObject] intValue];
		
		// DomainID
		scLogin.strDomainID = [[NSString alloc] initWithString:[enumerator nextObject]];
		
		// SessionID
		scLogin.strSessionID = [[NSString alloc] initWithString:[enumerator nextObject]];
		
		// dwFlags (check ThinTech, etc.)
		scLogin.nFlags = [[enumerator nextObject] intValue];
		
		// ITM Policy (userid)
		NSString	*strTmp = [enumerator nextObject];
		if ( strTmp == nil )	strTmp = @"";
		scLogin.strPolicyUserID = [[NSString alloc] initWithString:strTmp];
		
		// UserType (0: Normal, 1: Admin, 2:Guest)
		LoginUserType	nTmpValue = [[enumerator nextObject] intValue];
		scLogin.nLoginUserType = nTmpValue;
		if ( g_nLoginUserType == LUT_GUEST )
			scLogin.nLoginUserType = LUT_GUEST;
	}
	[self GetServerInfo];
}

// 요청한 뷰 컨트롤러로 응답을 보낸다.
- (void) sendResult: (NSString *) errmsg 
		 withObject: (NSObject *) object
{
	[m_activityViewController hideActivity];
	
	if ([m_sender respondsToSelector:m_selector])
		[m_sender performSelector:m_selector withObject:errmsg withObject:object];
	else
		NSLog(@"selector is not responding.");
}



////////////////////////////////////////////
// TO DO : 변경 예정
// Common Utils
- (NSString*) intEncode:(int)nValue
{
	NSString *strValue = [NSString stringWithFormat:@"%d", nValue];
	NSString *strTmp = [Util doCipher:strValue key:scLogin.ks action:kCCEncrypt];
	strTmp = [Util urlencode:strTmp];
	
	return strTmp;
}


- (NSString*) strEncode:(NSString*)strValue
{
	if ( strValue == nil )
		return @"";
	
	NSString *strTmp = [Util doCipher:strValue key:scLogin.ks action:kCCEncrypt];
	strTmp = [Util urlencode:strTmp];
	return strTmp;	
}


- (NSString*) strEncode:(NSString*)strValue withKey:(NSString *)strKey
{
	if ( strValue == nil )
		return @"";
	
	NSString *strTmp = [Util doCipher:strValue key:strKey action:kCCEncrypt];
	strTmp = [Util urlencode:strTmp];
	return strTmp;	
}


- (void) setRequest:(NSMutableURLRequest*)request withCookie:(NICookieInfo*)valueCookie
{
	if ( request == nil || valueCookie == nil )
		return;
	
	NSMutableString *strCookie = [[NSMutableString alloc] init];
	
	// Essential
	[strCookie appendFormat:@"DiskType=%@;", [self intEncode:valueCookie->m_nDiskType]];
	[strCookie appendFormat:@"DomainID=%@;", [self strEncode:valueCookie->m_strDomainID]];
	[strCookie appendFormat:@"User=%@;", [self strEncode:valueCookie->m_strUser]];
	[strCookie appendFormat:@"Partition=%@;", [self strEncode:valueCookie->m_strPartition]];
	[strCookie appendFormat:@"RealIP=%@;", [self strEncode:valueCookie->m_strRealIP]];
	[strCookie appendFormat:@"WebServer=%@;", [self strEncode:valueCookie->m_strWebServer]];
	[strCookie appendFormat:@"Agent=%@;", [self strEncode:valueCookie->m_strAgent]];
	[strCookie appendFormat:@"Option=%@;", [self intEncode:valueCookie->m_nOption]];
		
	// Option
	[strCookie appendFormat:@"InstallVersion=%@;", [self strEncode:valueCookie->m_strInstallVersion]];
	[strCookie appendFormat:@"LangID=%@;", [self strEncode:valueCookie->m_strLangID]];
	
	[request setValue:strCookie forHTTPHeaderField:@"Cookie"];
}


- (void) setRequest:(NSMutableURLRequest*)request withServer:(NSString*)strServer
{
	// Init
	if ( request == nil )
		return;
	
	// Method ( Post, Get ... )
	[request setHTTPMethod:@"POST"];
	
	// Request
	[request setValue:strServer forHTTPHeaderField:@"Host"];
	[request setValue:@"application/x-www-form-urlencoded" forHTTPHeaderField:@"Content-Type"];
	[request setValue:@"Net-ID Browser" forHTTPHeaderField:@"User-Agent"];
	[request setValue:@"Keep-Alive" forHTTPHeaderField:@"Connection"];
	[request setValue:@"utf8" forHTTPHeaderField:@"Accept-Charset"];
}


///////////////////////////////////////////////////
// WebServer Protocol
- (void) CreateAccountOfID: (NSString *) strID
				  withName: (NSString *) strName
			  withPassword: (NSString *) strPassword
				 withEmail: (NSString *) strEmail
					sender: (id) sender 
				  selector: (SEL) selector
{
	commandType = ST_ACCOUNT;
	
	NSString *strKey = [[NSString alloc] initWithString:[strID MD5]];
	
	//NSString *strServer = [[NSString alloc] initWithString:@"192.168.1.178"];
	NSString *strServer = [[NSString alloc] initWithString:@"www.auhuh.com"];
	
	NSString *strUrl = [NSString stringWithFormat:@"http://%@/clientsvc/SignUp.jsp", strServer];
	NSLog(@"%@", strUrl);
	
	NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:[NSURL URLWithString: strUrl]];
	[self setRequest:request withServer:strServer];
		
	NSMutableString *strParameter = [[NSMutableString alloc] init];
	[strParameter appendFormat:@"UserID=%@", strID];
	[strParameter appendFormat:@"&Name=%@", [self strEncode:strName withKey:strKey]];
	[strParameter appendFormat:@"&Password=%@", [self strEncode:strPassword withKey:strKey]];
	[strParameter appendFormat:@"&Email=%@", [self strEncode:strEmail withKey:strKey]];
	NSLog(@"%@", strParameter);
	
	NSData *paramData = [NSData dataWithBytes:[strParameter UTF8String] length:[strParameter length]];
	[request setHTTPBody: paramData];
	
	m_sender = sender;
	m_selector = selector;
	
	[self sendRequest:request];
}

// FileServer Protocol
- (void) getDriveListofUserID:(NSString*)strUserID withLoginType:(LoginUserType)nUserLoginType
{
	commandType = ST_GET_DRIVE_LIST;
	
//	NSString *strUrl = [NSString stringWithFormat:@"http://%@:%d/clientsvc/GetDriveList.jsp", g_serverName, scLogin.nHttpPort];
	NSString *strUrl = [NSString stringWithFormat:@"http://%@/clientsvc/GetDriveList.jsp", g_serverName];
	NSLog(@"%@", strUrl);
	
	NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:[NSURL URLWithString: strUrl]];
	[self setRequest:request withServer:g_serverName];
		
	NICookieInfo *cookie = [[NICookieInfo alloc] init];
//	cookie->m_nDiskType = ;
	cookie->m_strDomainID = scLogin.strDomainID;
	cookie->m_strUser = strUserID;
//	cookie->m_strPartition = ;
	cookie->m_strRealIP = @"127.0.0.1";	// TO DO : !!
	cookie->m_strWebServer = g_serverName;
	cookie->m_strAgent = [[NSString stringWithFormat:@"%x", AGENT_IPHONE] retain];
//	cookie->m_nOption = ;
	cookie->m_strInstallVersion = INSTALL_VERSION;
	cookie->m_strLangID = m_langID;
	
	[self setRequest:request withCookie:cookie];

	NSString *strLogCookie = [request valueForHTTPHeaderField:@"Cookie"];
	NSLog(@"Cookie : %@", strLogCookie);
	
	NSMutableString *strParameter = [[NSMutableString alloc] init];
	[strParameter appendFormat:@"User=%@", [self strEncode:strUserID]];
	[strParameter appendFormat:@"&UserType=%@", [self strEncode:(nUserLoginType == LUT_NORMAL) ? @"Normal" : @"GuestID"]];
	NSLog(@"%@", strParameter);
	
	NSData *paramData = [NSData dataWithBytes:[strParameter UTF8String] length:[strParameter length]];
	[request setHTTPBody: paramData];
	
	[self sendRequest:request];
}
////////////////////////////////////////////



////////////////////////////////////////////
// Process
#pragma mark -
#pragma mark WebServer Protocol

- (void) processAccount:(NSArray *)lines
{
	// Success
	UIAlertView	*av = [[[UIAlertView alloc] initWithTitle:nil message:NSLocalizedString(@"Success Account", nil)
												 delegate:nil cancelButtonTitle:NSLocalizedString(@"Confirm",nil)
										otherButtonTitles:nil] autorelease];
	
	[av show];
}

// 드라이브 목록 결과 처리 함수
- (void) processNewGetDriveList:(NSArray *)lines
{
	if ( g_appDelegate.m_arrDriveInfo != nil )
		[g_appDelegate.m_arrDriveInfo removeAllObjects];
	
	// Init
	g_appDelegate.m_arrDriveInfo = [[NSMutableArray alloc] init];
	
	for ( int i = 2; i < [lines count]-1; i++ )
	{
		NIDriveInfo *info = [[NIDriveInfo alloc] init];
		
		NSArray *arrItems = [[lines objectAtIndex:i] componentsSeparatedByString:@"\t"];
		
		// Insert Information
		NSEnumerator *enumerator = [arrItems objectEnumerator];

		// Name
		info->m_strName = [[NSString alloc] initWithString:[enumerator nextObject]];
		
		// Drive
		info->m_strAssignedDrive = [[NSString alloc] initWithString:[enumerator nextObject]];
		
		// Owner (OrgCoworkID)
		info->m_strOwner = [[NSString alloc] initWithString:[enumerator nextObject]];
		
		// OwnerType
		info->m_strOwnerType = [[NSString alloc] initWithString:[enumerator nextObject]];
		
		// Server
		info->m_strFileServer = [[NSString alloc] initWithString:[enumerator nextObject]];
		
		// Partition
		info->m_strPartition = [[NSString alloc] initWithString:[enumerator nextObject]];
		
		// StartPath
		info->m_strStartPath = [[NSString alloc] initWithString:[enumerator nextObject]];
		
		// OrgCode
		info->m_strOrgCode = [[NSString alloc] initWithString:[enumerator nextObject]];
		
		// OrgName
		info->m_strOrgName = [[NSString alloc] initWithString:[enumerator nextObject]];
		
		// DriveType
		info->m_nDiskType = [info getDiskType:[enumerator nextObject]];
		
		[g_appDelegate.m_arrDriveInfo addObject:info];
	}
	
	// TO DO : 임시 처리!
	for ( int i = 0; i < [g_appDelegate.m_arrDriveInfo count]; i++ )
		[self GetDiskInfo:i];
	
	[self sendResult:nil withObject: nil];
}

#pragma mark FileServer Protocol



@end
