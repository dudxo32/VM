#import "CentralECMAppDelegate.h"
#import "NIInterfaceUtil.h"
#import "NSData+AES256.h"
#import "ActivityViewController.h"

enum FileAttrib
{
	FA_SYSTEM			= 0x00000001,
	FA_SPECIAL			= 0x00000002,
	FA_HASACL			= 0x00000004,
	FA_SHARED			= 0x00000008,
	FA_HASSUBFOLDER		= 0x00000010,
	FA_FOLDER			= 0x00000020,
	FA_HIDDEN			= 0x00000040,
	FA_ROOT				= 0x00000080,		// 클라이언트에서 지정됨		
	FA_ORGCHART			= 0x00000100,		// 조직도 폴더인지?
	FA_HASCOWORK		= 0x00000200,		// 코웍을 가지고 있는지?
	FA_PROPERTYMASK		= 0x000003FF,
	
	FA_ORGCOWORKFOLDER	= 0x00200000,		// 클라이언트에서 지정됨
	FA_SHAREFOLDER		= 0x00400000,		// 클라이언트에서 지정됨
	FA_COWORKTYPEMASK	= 0x00200000,
	FA_FOLDERTYPEMASK	= 0x00600000,
	
	FA_PARAM			= 0x00800000,		// 클라이언트에서 지정됨(PIDLDATA에 부가정보가 있음)
	
	FA_MAIL				= 0x01000000,		// 클라이언트에서 지정됨, FA_WEBLINKFOLDER가 설정되어 있을 경우에만 유효.
	FA_WEBCOPY			= 0x02000000,		// 클라이언트에서 지정됨, FA_WEBLINKFOLDER가 설정되어 있을 경우에만 유효.
	FA_WEBLINKMASK		= 0x03000000,
	
	GL_SHARE_LEVEL1		= 0x10000000,		// 공유 목록 LVL1: ...\tDiskType\tOwner\tShareUser\tServer\tPartition\r\n. 파싱 후 FA_ORDERMASK 로 교체됨.
	GL_SHARE_LEVEL2		= 0x20000000,		// 공유 목록 LVL2: ...\tSharePath\r\n. 파싱 후 FA_ORDERMASK 로 교체됨.
	
	FA_ORDERMASK		= 0xF0000000		// 클라이언트에서 지정됨
};

enum FileAccess
{
	ACL_READ			= 0x00000001,
	ACL_WRITE			= 0x00000002,		// Folder에 항목 추가 가능.
	ACL_EDIT			= 0x00000004,		// File에서 수정 권한(= 기존의 WRITE 개념)
	ACL_DELETEFILE		= 0x00000008,
	ACL_LIST			= 0x00000010,
	ACL_MKDIR			= 0x00000020,
	
	ACL_NOREAD			= 0x00000100,
	ACL_NOWRITE			= 0x00000200,
	ACL_NOEDIT			= 0x00000400,
	ACL_NODELETE		= 0x00000800,
	ACL_NOLIST			= 0x00001000,
	ACL_NOMKDIR			= 0x00002000,
	
	ACL_PERMISSION		= 0x00010000,
	ACL_SPECIAL			= 0x00020000,		// 특수 파일, desktop.ini 파일과 같은..아이콘을 달리 표시하기 위한
	
	ACL_EDITACCESSMASK	= 0x00003F3F,
	ACL_ACCESSMASK		= 0x00033F3F,
	ACL_FILEACCESSMASK	= 0x00000D0D
};

typedef enum _CommandType
{
	ST_LOGIN,
	ST_GET_SERVER_INFO,
	ST_GET_DRIVE_LIST,
	ST_GET_DISK_INFO,
	ST_GET_LIST,
	ST_DELETE_FILE,
	ST_RENAME_FILE,
	ST_RESTORE_FILE,
	ST_EMPTY_RECYCLED,
	ST_CREATE_DIR,
	ST_COPY_FILE,
	ST_MOVE_FILE,
	ST_PUT_FILE_CHECK,
	ST_PUT_FILE,
	ST_GET_FILE,
	ST_ACCOUNT,
    ST_SEND_DEVICE_INFO
	
} CommandType;

typedef enum _LoginUserType
{
	LUT_NORMAL		= 0x00,
	LUT_ADMIN,
	LUT_GUEST,
} LoginUserType;


typedef struct _SC_LIST
{
	int			dwACL;
	__unsafe_unretained NSArray		* folders;
	__unsafe_unretained NSArray		* files;
	
} SC_LIST;

typedef struct _SC_LOGIN
{
	__unsafe_unretained NSString		*strSiteID;
	__unsafe_unretained NSString		*strUserName;
	__unsafe_unretained NSString		*strFileServerIP;
	__unsafe_unretained NSString		*strPartition;
	__unsafe_unretained NSString		*strStartPath;
	__unsafe_unretained NSString		*ks;
	__unsafe_unretained NSString		*strOwner;
	__unsafe_unretained NSString		*strOwnerPath;
	LoginUserType	nLoginUserType;
	int				nHttpPort;
	int				nSSLPort;
	__unsafe_unretained NSString		*strDomainID;
	__unsafe_unretained NSString		*strSessionID;
	int				nFlags;
	__unsafe_unretained NSString		*strPolicyUserID;
	
} SC_LOGIN;

typedef struct _CDriveInfo
{
	__unsafe_unretained NSString		*m_strName;
	__unsafe_unretained NSString		*m_strAssignedDrive;
	__unsafe_unretained NSString		*m_strOwner;
	__unsafe_unretained NSString		*m_strOwnerType;
	__unsafe_unretained NSString		*m_strFileServer;
	__unsafe_unretained NSString		*m_strPartition;
	__unsafe_unretained NSString		*m_strStartPath;
	__unsafe_unretained NSString		*m_strOrgName;
	__unsafe_unretained NSString		*m_strOrgCode;
	DiskType		m_diskType;		// Home Drive/Orgcowork Drive/Share Drive...
	long long		m_nTotalSpace;
	long long		m_nAvailableSpace;
	
} CDriveInfo;


@interface CFileInfo : NSObject 
{
	NSMutableString	* m_strName;
	long long		m_n64Size;
	int				m_dwACL;
	int				m_dwAttrib;
	NSMutableString	* m_dtLastWriteTime;
	
	NSMutableString	* m_strDiskType;
	DiskType		m_diskType;
	NSMutableString	* m_strOwner;
	NSMutableString	* m_strFileServer;
	NSMutableString	* m_strPartition;
	NSMutableString	* m_stShare;		// SHARE LVL1인 경우에는 ShareUser, LV2인 경우에는 SharePath
}

@property (nonatomic, retain) NSMutableString	* m_strName;
@property (nonatomic, assign) long 	long		m_n64Size;
@property (nonatomic, assign) int				m_dwACL;
@property (nonatomic, assign) int				m_dwAttrib;
@property (nonatomic, retain) NSMutableString	* m_dtLastWriteTime;
@property (nonatomic, retain) NSMutableString	* m_strDiskType;
@property (nonatomic, assign) DiskType			m_diskType;
@property (nonatomic, retain) NSMutableString	* m_strOwner;
@property (nonatomic, retain) NSMutableString	* m_strFileServer;
@property (nonatomic, retain) NSMutableString	* m_strPartition;
@property (nonatomic, retain) NSMutableString	* m_stShare;
@property (nonatomic, retain) NSMutableString   * m_strPath;

- (CFileInfo *) initWithCFileInfo: (CFileInfo *) fileInfo;

@end

#import "ActivityViewController.h"

@interface ServerCmd : NSObject
{
	NSString			*m_initialKey;
	id					m_sender;
	SEL					m_selector;
	NSUInteger			m_nDrive;
	NSString			*m_folderName;
	// 아이폰에 저장되는 다운로드 파일의 핸들
	NSFileHandle		*m_fileHandle;
	// 아이폰에 저장되는 다운로드 파일의 이름 (/tmp/filename.txt)
	NSString			*m_fileName;
	// 파일 저장중
	BOOL				m_bFirst;
	NSString			*m_langID;
	
	CommandType	commandType;
	
	NSMutableData		*receiveData;
	long long			m_length;
	NSURLConnection		*m_connection;

	ActivityViewController	*m_activityViewController;
	
	long long  lastTime;
    NSString            *m_strKey;
    NSString            *m_strFlag;

}
@property (nonatomic, retain) ActivityViewController	*m_activityViewController;

- (id) init;
- (void) dealloc;

- (NSString *) encode: (NSString *) str 
			  withKey: (NSString *) key;

- (NSString *) decode: (NSString *) str 
			  withKey: (NSString *) key;

- (int) GetACL: (NSString *) szAccess;

- (int) GetOption: (DiskType) nDiskType;

- (NSString *) GetCookie: (int) nDrive 
                fileInfo: (CFileInfo *) fileInfo 
               sharePath: (NSString *) sharePath;

- (NSString *) GetCookie: (int) nDrive 
					 fileInfo: (CFileInfo *) fileInfo 
					sharePath: (NSString *) sharePath
                    g_appDelegate: (CentralECMAppDelegate *) g_appDelegate;
- (void) sendResult: (NSString *) errmsg 
		 withObject: (NSObject *) object;

- (void) sendRequest:(NSMutableURLRequest *) request;
- (BOOL) processData: (NSURLConnection *) connection;
-(BOOL)connection:(NSURLConnection *)connection canAuthenticateAgainstProtectionSpace:(NSURLProtectionSpace *)protectionSpace;
-(void)connection:(NSURLConnection *)connection didReceiveAuthenticationChallenge:(NSURLAuthenticationChallenge *)challenge;
// Web Server
- (void) Login: (NSString *) serverName
	   loginID: (NSString *) loginID
   loginPasswd: (NSString *) loginPasswd
 loginUserType: (LoginUserType) nLoginUserType
		sender: (id) sender 
	  selector: (SEL) selector;

- (void) processLogin:(NSArray *)lines;

- (void) GetServerInfo;
- (void) processGetServerInfo:(NSArray *)lines;

- (void) GetDriveList;
- (void) GetDriveList: (id) sender 
			 selector: (SEL) selector;
- (void) processGetDriveList:(NSArray *)lines;


// File Server
- (void) GetList: (int) nDrive 
	  folderName: (NSString *) folderName 
		fileInfo: (CFileInfo *) fileInfo 
	   sharePath: (NSString *) sharePath 
	   recursive: (BOOL) isRecursive 
		  sender: (id) sender 
		selector: (SEL) selector
   g_appDelegate: (CentralECMAppDelegate *) g_appDelegate;
 - (void) processGetList:(NSArray *)lines;

- (void) DeleteFile: (int) nDrive 
		   fileName: (NSString *) fileName 
		   fileInfo: (CFileInfo *) fileInfo 
		  sharePath: (NSString *) sharePath
			 sender: (id) sender 
		   selector: (SEL) selector;
- (void) processDeleteFile:(NSArray *)lines;

- (void) RenameFile: (int) nDrive 
			srcName: (NSString *) srcPath 
			dstName: (NSString *) dstPath 
		   fileInfo: (CFileInfo *) fileInfo 
		  sharePath: (NSString *) sharePath
			 sender: (id) sender 
		   selector: (SEL) selector;
- (void) processRenameFile:(NSArray *)lines;

- (BOOL) RestoreFile: (int) nDrive 
			 srcName: (NSString *) srcPath 
			  sender: (id) sender
			  errmsg: (NSString **) errmsg;

- (void) EmptyRecycled: (int) nDrive 
				sender: (id) sender 
			  selector: (SEL) selector;
- (void) processEmptyRecycled:(NSArray *)lines;

- (void) CreateDir: (int) nDrive 
		   srcName: (NSString *) srcPath 
		  fileInfo: (CFileInfo *) fileInfo 
		 sharePath: (NSString *) sharePath
			sender: (id) sender 
		  selector: (SEL) selector
     g_appDelegate: (CentralECMAppDelegate *) g_appDelegate;
- (void) processCreateDir:(NSArray *)lines;

- (BOOL) sendCopyCutRequest: (NSMutableURLRequest *) request 
					 errmsg: (NSString **) errmsg 
			  lastWriteTime: (NSString **) lastWriteTime;

- (BOOL) CopyFile: (int) nDrive 
		  srcName: (NSString *) srcPath 
		  dstName: (NSString *) dstPath
		 fileInfo: (CFileInfo *) fileInfo 
		sharePath: (NSString *) sharePath 
		overWrite: (BOOL) overWrite 
		   sender: (id) sender
	lastWriteTime: (NSString **) lastWriteTime
		   errmsg: (NSString **) errmsg;

- (BOOL) MoveFile: (int) nDrive 
		  srcName: (NSString *) srcPath 
		  dstName: (NSString *) dstPath
		 fileInfo: (CFileInfo *) fileInfo 
		sharePath: (NSString *) sharePath
		overWrite: (BOOL) overWrite 
		   sender: (id) sender
	lastWriteTime: (NSString **) lastWriteTime 
		   errmsg: (NSString **) errmsg;

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

- (void) processPutFile: (NSArray *) lines;

- (BOOL) PutFileCheck: (int) nDrive 
			  srcName: (NSString *) srcPath 
			  srcPath: (NSString *) srcPath 
			 fileInfo: (CFileInfo *) fileInfo 
			sharePath: (NSString *) sharePath 
			   sender: (id) sender
			   errmsg: (NSString **) errmsg 
			 filesize: (NSInteger *) filesize
        g_appDelegate: (CentralECMAppDelegate *) g_appDelegate;

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


- (BOOL) GetDiskInfo: (int) nDrive;

- (void) cancel;


// New Coding Style

////////////////////////////////////////////
#pragma mark -
#pragma mark Common Utils
// Common Utils
- (NSString*) intEncode:(int)nValue;

- (NSString*) strEncode:(NSString*)nValue;
- (NSString*) strEncode:(NSString*)strValue withKey:(NSString *)strKey;

- (void) setRequest:(NSMutableURLRequest*)request
		 withCookie:(NICookieInfo*)valueCookie;

- (void) setRequest:(NSMutableURLRequest*)request
		 withServer:(NSString*)strServer;


#pragma mark -
#pragma mark Protocol
// WebServer Protocol
- (void) CreateAccountOfID: (NSString *) strID
				  withName: (NSString *) strName
			  withPassword: (NSString *) strPassword
				 withEmail: (NSString *) strEmail
					sender: (id) sender 
				  selector: (SEL) selector;

- (void) getDriveListofUserID:(NSString*)strUserID
				withLoginType:(LoginUserType)nUserLoginType;
- (void) DeviceGPS: (NSString *) gps
          DeviceID: (NSString *) deviceid
         WebServer: (NSString *) webserver
            SiteID: (NSString *) siteid;


// FileServer Protocol


#pragma mark -
#pragma mark Request Process
// WebServer Request Process
- (void) processAccount:(NSArray *)lines;
- (void) processNewGetDriveList:(NSArray *)lines;


// FileServer Request Process

//- (char *) getEuckr: (char *) utf8str;


@end

