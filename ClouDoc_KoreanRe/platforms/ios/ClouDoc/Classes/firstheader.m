//
//  ViewController.m
//  sample
//
//  Created by ePapyrus on 23/12/15.
//  Copyright © 2015 plugpdf. All rights reserved.
//

#import "firstheader.h"
#import "PlugPDF/DocumentViewController.h"

@interface firstheader ()

@end

@implementation firstheader

- (void)viewDidLoad {
    
//    // 탭바 숨기기
//    CGRect frame = self.tabBarController.view.superview.frame;
//    CGFloat offset = self.tabBarController.tabBar.frame.size.height;
//    
//    frame.size.height += offset;
//    
//    [UIView animateWithDuration:0.2
//                     animations:^{
//                         self.tabBarController.view.frame = frame;
//                     }];
    
    [super viewDidLoad];
//    UIButton *button = [[UIButton alloc] initWithFrame: CGRectMake(240, 80, 250, 50)];
//    [button setBackgroundColor: [UIColor grayColor]];
//    [button setTitle: @"사용설명.PDF" forState: UIControlStateNormal];
//    [button addTarget: self action: @selector(openPlugPDF:) forControlEvents: UIControlEventTouchUpInside];
//    [self.view addSubview: button];
//    //    UINavigationBar *bar = [self.navigationController navigationBar];
//    //    [bar setTintColor:[UIColor colorWithRed:0.5 green:0.5 blue:0.5 alpha:1.0]];
    
    NSString *path = [[NSBundle mainBundle] pathForResource: @"epapyrus" ofType: @"pdf"];

//    NSString *path = [[NSUserDefaults standardUserDefaults] stringForKey:@"testpath"];
    NSString *password = @"";
    NSString *title = [path lastPathComponent];

    
    NSLog(@"PDF path = %@", path);
    NSLog(@"PDF name = %@", title);
    
    PlugPDFDocumentViewController *DocumentViewController = nil;
    @try {
        DocumentViewController = [PlugPDFDocumentViewController initWithPath: path
                                                                    password: nil
                                                                       title: title];
        
    }
    @catch (NSException *exception) {
        NSLog(@"Exception %@ %@", exception.name, exception.description);
    }
    
    if (DocumentViewController) {
        
        [self.view addSubview:DocumentViewController.view];
        [self addChildViewController:DocumentViewController];
        [DocumentViewController didMoveToParentViewController:self];
        
        //        [self presentViewController: DocumentViewController animated: NO completion: nil];
        [self.navigationController pushViewController: DocumentViewController animated: YES];
        
        if ([[UIDevice currentDevice].systemVersion hasPrefix:@"7"] ||
            [[UIDevice currentDevice].systemVersion hasPrefix:@"8"]) {
            [DocumentViewController setAutomaticallyAdjustsScrollViewInsets: NO];
        }
    }
    
    [DocumentViewController setEnableStatusBar:YES];
    [DocumentViewController setEnableBottomBar:YES];
    [DocumentViewController setEnablePageFlipEffect:YES];
    [DocumentViewController enableAlwaysVisible];
    
//    HMSegmentedControl *segmentedControl = [[HMSegmentedControl alloc] initWithSectionTitles:@[@"One", @"Two", @"Three"]];
//    segmentedControl.frame = CGRectMake(10, 10, 300, 60);
//    [DocumentViewController.view addSubview:segmentedControl];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
/*
- (void)openPlugPDF: (id)sender {
    NSString *path = [[NSBundle mainBundle] pathForResource: @"epapyrus" ofType: @"pdf"];
    NSString *password = @"";
    NSString *title = [[path lastPathComponent] stringByDeletingPathExtension];
    
    PlugPDFDocumentViewController *DocumentViewController = nil;
    @try {
        DocumentViewController = [PlugPDFDocumentViewController initWithPath: path
                                                                    password: password
                                                                       title: title];
        
        [DocumentViewController setRotationLock:NO];
    }
    @catch (NSException *exception) {
        NSLog(@"Exception %@ %@", exception.name, exception.description);
    }
    
    if (DocumentViewController) {
        
        [self.view addSubview:DocumentViewController.view];
        [self addChildViewController:DocumentViewController];
        [DocumentViewController didMoveToParentViewController:self];
        
        //        [self presentViewController: DocumentViewController animated: NO completion: nil];
        [self.navigationController pushViewController: DocumentViewController animated: YES];
        
        if ([[UIDevice currentDevice].systemVersion hasPrefix:@"7"] ||
            [[UIDevice currentDevice].systemVersion hasPrefix:@"8"]) {
            [DocumentViewController setAutomaticallyAdjustsScrollViewInsets: NO];
        }
    }
}*/

@end
