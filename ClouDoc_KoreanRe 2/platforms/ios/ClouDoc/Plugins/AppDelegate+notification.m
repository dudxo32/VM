//
//  AppDelegate+notification.m
//  pushtest
//
//  Created by Robert Easterday on 10/26/12.
//
//

#import "AppDelegate+notification.h"
#import "PushNotification.h"
#import <objc/runtime.h>

static char launchNotificationKey;

@implementation AppDelegate (notification)

- (id) getCommandInstance:(NSString*)className
{
	return [self.viewController getCommandInstance:className];
}

// its dangerous to override a method from within a category.
// Instead we will use method swizzling. we set this up in the load call.
+ (void)load
{
    Method original, swizzled;
    
    original = class_getInstanceMethod(self, @selector(init));
    swizzled = class_getInstanceMethod(self, @selector(swizzled_init));
    method_exchangeImplementations(original, swizzled);
}

- (AppDelegate *)swizzled_init
{
	[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(createNotificationChecker:)
               name:@"UIApplicationDidFinishLaunchingNotification" object:nil];
	
	// This actually calls the original init method over in AppDelegate. Equivilent to calling super
	// on an overrided method, this is not recursive, although it appears that way. neat huh?
	return [self swizzled_init];
}

// This code will be called immediately after application:didFinishLaunchingWithOptions:. We need
// to process notifications in cold-start situations
- (void)createNotificationChecker:(NSNotification *)notification
{
	if (notification)
	{
		NSDictionary *launchOptions = [notification userInfo];
		if (launchOptions)
			self.launchNotification = [launchOptions objectForKey: @"UIApplicationLaunchOptionsRemoteNotificationKey"];
	}
}

- (void)application:(UIApplication *)application didRegisterForRemoteNotificationsWithDeviceToken:(NSData *)deviceToken {
    PushNotification *pushHandler = [self getCommandInstance:@"PushPlugin"];
    [pushHandler didRegisterForRemoteNotificationsWithDeviceToken:deviceToken];
}

- (void)application:(UIApplication *)application didFailToRegisterForRemoteNotificationsWithError:(NSError *)error {
    PushNotification *pushHandler = [self getCommandInstance:@"PushPlugin"];
    [pushHandler didFailToRegisterForRemoteNotificationsWithError:error];
}

- (void)application:(UIApplication *)application didReceiveRemoteNotification:(NSDictionary *)userInfo {
    NSLog(@"didReceiveNotification");
    
    // Get application state for iOS4.x+ devices, otherwise assume active
    UIApplicationState appState = UIApplicationStateActive;
    if ([application respondsToSelector:@selector(applicationState)]) {
        appState = application.applicationState;
    }
    
    if (appState == UIApplicationStateActive) {
        PushNotification *pushHandler = [self getCommandInstance:@"PushPlugin"];
        pushHandler.notificationMessage = userInfo;
        pushHandler.isInline = YES;
        [pushHandler notificationReceived];
    } else {
        //save it for later
        self.launchNotification = userInfo;
    }
}

- (void)applicationDidBecomeActive:(UIApplication *)application {
    
    NSLog(@"active");
    
    NSNotificationCenter *notificationCenter = [NSNotificationCenter defaultCenter];
    NSDictionary *dic = [NSDictionary dictionaryWithObject:@"test" forKey:@"firstKey"];
    [notificationCenter postNotificationName:@"firstNotification" object:self userInfo:dic];
    
    NSNotificationCenter *notificationCenter2 = [NSNotificationCenter defaultCenter];
    NSDictionary *dic2 = [NSDictionary dictionaryWithObject:@"test2" forKey:@"firstKey2"];
    [notificationCenter2 postNotificationName:@"firstNotification2" object:self userInfo:dic2];
    
    NSNotificationCenter *notificationCenter3 = [NSNotificationCenter defaultCenter];
    NSDictionary *dic3 = [NSDictionary dictionaryWithObject:@"test3" forKey:@"firstKey3"];
    [notificationCenter3 postNotificationName:@"firstNotification3" object:self userInfo:dic3];
    
    //zero badge
    application.applicationIconBadgeNumber = 0;

    if (self.launchNotification) {
        PushNotification *pushHandler = [self getCommandInstance:@"PushPlugin"];
		
        pushHandler.notificationMessage = self.launchNotification;
        self.launchNotification = nil;
        [pushHandler performSelectorOnMainThread:@selector(notificationReceived) withObject:pushHandler waitUntilDone:NO];
    }
    
    BOOL isRunningInFullScreen = CGRectEqualToRect([UIApplication sharedApplication].delegate.window.frame, [UIApplication sharedApplication].delegate.window.screen.bounds);
    if(isRunningInFullScreen){
        NSLog(@"NOT Split view");
    } else {
        NSLog(@"Split view");
    }
    
    
    [UIPasteboard generalPasteboard].string = @"";
    
//    NSLog(@"active width = %f", self.viewController.view.window.frame.size.width);
//    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.1 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
//        self.viewController.view.frame =  CGRectMake(0,-20,self.viewController.view.window.frame.size.width,self.viewController.view.window.frame.size.height+20);
//        AppDelegate *AD = [[UIApplication sharedApplication] delegate];
//        UIWindow* keyWindow = [UIApplication sharedApplication].keyWindow;
//        NSLog(@"active width = %f", self.viewController.view.window.frame.size.width);
//        self.viewController.view.frame = keyWindow.frame;
//        CGRect windowRect = self.window.frame;
//        CGRect screenRect = [[UIScreen mainScreen] bounds]; //스크린에 대한 모든 정보
//        NSInteger screenWidth = CGRectGetWidth(keyWindow.frame); //스크린의 넓이
//        NSInteger screenHeight = CGRectGetHeight(keyWindow.frame); //스크린의 길이
//        AD.window.frame =  CGRectMake(0,-20,screenWidth,screenHeight);
//    });
}

-(BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation{
    NSLog(@"test");
}

-(BOOL)shouldAutorotate{
    NSLog(@"test2");
    NSString *rotate = [[NSUserDefaults standardUserDefaults] stringForKey:@"rotate"];
    if([rotate isEqualToString:@"yes"]){
        return YES;
    } else {
        return NO;
    }
}

// The accessors use an Associative Reference since you can't define a iVar in a category
// http://developer.apple.com/library/ios/#documentation/cocoa/conceptual/objectivec/Chapters/ocAssociativeReferences.html
- (NSMutableArray *)launchNotification
{
   return objc_getAssociatedObject(self, &launchNotificationKey);
}

- (void)setLaunchNotification:(NSDictionary *)aDictionary
{
    objc_setAssociatedObject(self, &launchNotificationKey, aDictionary, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

- (void)dealloc
{
    self.launchNotification	= nil; // clear the association and release the object
}

@end
