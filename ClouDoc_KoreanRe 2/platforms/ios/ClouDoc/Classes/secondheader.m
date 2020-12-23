//
//  ViewController.m
//  sample
//
//  Created by ePapyrus on 23/12/15.
//  Copyright © 2015 plugpdf. All rights reserved.
//

#import "secondheader.h"
#import "PlugPDF/DocumentViewController.h"

@interface secondheader ()

@end

@implementation secondheader

- (void)viewDidLoad {
    [super viewDidLoad];
    UIButton *button = [[UIButton alloc] initWithFrame: CGRectMake(240, 80, 250, 50)];
    [button setBackgroundColor: [UIColor grayColor]];
    [button setTitle: @"사용설명.PDF" forState: UIControlStateNormal];
    [button addTarget: self action: @selector(openPlugPDF:) forControlEvents: UIControlEventTouchUpInside];
    [self.view addSubview: button];
    //    UINavigationBar *bar = [self.navigationController navigationBar];
    //    [bar setTintColor:[UIColor colorWithRed:0.5 green:0.5 blue:0.5 alpha:1.0]];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)openPlugPDF: (id)sender {
    NSString *path = [[NSBundle mainBundle] pathForResource: @"epapyrus" ofType: @"pdf"];
    NSString *password = @"";
    NSString *title = [[path lastPathComponent] stringByDeletingPathExtension];
    
    PlugPDFDocumentViewController *DocumentViewController = nil;
    
    @try {
        DocumentViewController = [PlugPDFDocumentViewController initWithPath: path
                                                                    password: password
                                                                       title: title];
        
//        [DocumentViewController setRotationLock:NO];
    }
    @catch (NSException *exception) {
        NSLog(@"Exception %@ %@", exception.name, exception.description);
    }
    
    if (DocumentViewController) {
//        [self.view addSubview:DocumentViewController.view];
//        [self addChildViewController:DocumentViewController];
//        [DocumentViewController didMoveToParentViewController:self];
        
//                [self presentViewController: DocumentViewController animated: NO completion: nil];
        [self.navigationController pushViewController: DocumentViewController animated: YES];
        [[[[UIApplication sharedApplication] delegate] window] setRootViewController: self.navigationController];
        
        
//                AppDelegate *AD = [[UIApplication sharedApplication] delegate];
//                AD.window.rootViewController = DocumentViewController;
        
        if ([[UIDevice currentDevice].systemVersion hasPrefix:@"7"] ||
            [[UIDevice currentDevice].systemVersion hasPrefix:@"8"]) {
            [DocumentViewController setAutomaticallyAdjustsScrollViewInsets: NO];
        }
    }
}


@end
