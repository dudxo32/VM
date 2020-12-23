///*
// 1. 문서 가로보기
// 2. 문서 세로보기
// 3. 문서 두장보기
// 4. 펜
// 5. 사각형 그리기
// 6. 원 그리기
// 7. 하이라이트
// 8. 밑줄
// 9. 취소선
// 10. 메모
// 11. 지우개
// 12. 이전페이지 이동
// 13. 다음페이지 이동
// 14.
// 15. 주석모드 취소 / 문서 종료
// 16. 저장
// 17. 화면 회전 허용/금지
// 18. 뷰어보기 팝업
// 19. 북마크
// 20. 검색
// 21. 판서 기능 팝업
// 22. 문서 썸네일보기
// 23. 북마크 추가
// 24. 북마크 제거
// 25. 북마크 편집 완료
// 26. 실시간 지우개
// 27. 블록 지우개
// 28. 전체 지우기
// */
//
//#import "third.h"
//
//
//@interface third ()
//@property (readonly) id target;
//@property (readonly) SEL selector;
//@end
//
//@implementation third {
//    int numberOfSection;
//    BOOL isSwipeDeleting;
//    int EditMode;
//    int counter;
//    int inkTag;
//    int inkOpacityValue;
//    float inkBoldValue;
//    int highlightOpacityValue;
//    int squareBoldValue;
//    int circleBoldValue;
//    int useUnderline;
//    int beforeSliderValue;
//    int currentSliderValue;
//    int eraserMode;
//    
//    BOOL isAnnot;
//    BOOL isRotate;
//    BOOL UsingInk;
//    BOOL UsingSquare;
//    BOOL UsingCircle;
//    BOOL UsingHighlight;
//    BOOL UsingUnderline;
//    BOOL UsingCancle;
//    BOOL UsingNote;
//    BOOL UsingEraser;
//}
//
//- (void)viewDidLoad {
//    [super viewDidLoad];
//    
//    self.tabledata = [[NSMutableArray alloc] init];
//    self.pagedata = [[NSMutableArray alloc] init];
//    inkOpacityValue = 100;
//    inkBoldValue = 0.5;
//    squareBoldValue = 1;
//    squareBoldValue = 1;
//    circleBoldValue = 1;
//    highlightOpacityValue = 100;
//    self.inkPopoverView = [[UIView alloc] init];   //view
//    self.inkPopoverContent = [[UIViewController alloc] init]; //ViewController
//    useUnderline = 0;
//    self.exampleInkColor = [UIColor blackColor];
//    self.exampleHighlightColor = [UIColor yellowColor];
//    self.exampleUnderlineColor = [UIColor blackColor];
//    self.exampleCanclelineColor = [UIColor blackColor];
//    self.exampleSquareColor = [UIColor clearColor];
//    self.exampleSquareCornerColor = [UIColor blackColor];
//    self.exampleCircleColor = [UIColor clearColor];
//    self.exampleCircleCornerColor = [UIColor blackColor];
//    isAnnot = NO;
//    isRotate = YES;
//    UsingInk = NO;
//    UsingSquare = NO;
//    UsingCircle = NO;
//    UsingHighlight = NO;
//    UsingUnderline = NO;
//    UsingCancle = NO;
//    UsingNote = NO;
//    UsingEraser = NO;
//    beforeSliderValue = 0;
//    eraserMode = 1;
//    
//    //    NSString *path = [[NSBundle mainBundle] pathForResource: @"테스트" ofType: @"pdf"];
//    NSString *path = [[NSUserDefaults standardUserDefaults] stringForKey:@"testpath"];
//    NSString *password = @"";
//    self.title = [[path lastPathComponent] stringByDeletingPathExtension];
//    NSLog(@"pdfPath = %@", path);
//    @try {
//        self.DocumentViewController = [PlugPDFDocumentViewController initWithPath: path
//                                                                         password: password
//                                                                            title: nil];
//    }
//    @catch (NSException *exception) {
//        NSLog(@"Exception %@ %@", exception.name, exception.description);
//    }
//    
//    if (self.DocumentViewController) {
//        [self.navigationController pushViewController: self.DocumentViewController animated: NO];
////        [[[[UIApplication sharedApplication] delegate] window] setRootViewController: self.navigationController];
//        
//        if ([[UIDevice currentDevice].systemVersion hasPrefix:@"7"] ||
//            [[UIDevice currentDevice].systemVersion hasPrefix:@"8"]) {
//            [self.DocumentViewController setAutomaticallyAdjustsScrollViewInsets: NO];
//        }
//        [self.DocumentViewController setRotationLock:YES];
//    }
//    NoteAnnot *test = nil;
//    [self initNavigationBar];
//    [self initMovePageButton];
//
//    // 화면 회전 감지 노티 등록
//    [self registerDeviceOrientationNotification];
//    [self.DocumentViewController setEnableTopBar:NO];
//    [self.DocumentViewController setEnablePageFlipEffect:YES];
//    
//    CGSize documentSize = [self.DocumentViewController.documentView.document pageSize:0];
//    CGFloat documentHeight = documentSize.height;
//    CGFloat documentWidth = documentSize.width;
//    CGFloat windowHeight = CGRectGetHeight(self.view.frame);
//    CGFloat windowWidth = CGRectGetWidth(self.view.frame);
//    CGFloat plusHeight;
//    CGFloat plusWidth;
//    if(documentHeight > documentWidth){
//        plusHeight = windowHeight - documentHeight;
//        plusWidth = documentWidth + plusHeight;
//        [self.DocumentViewController setPagePreviewSize:CGSizeMake(plusWidth, windowHeight)];
//    } else {
//        plusWidth = windowWidth - documentWidth;
//        plusHeight = documentHeight + plusWidth;
//        [self.DocumentViewController setPagePreviewSize:CGSizeMake(windowWidth, plusHeight)];
//    }
//    
//    [self.DocumentViewController setEnableThumbnailPageNumberIndicator:NO];
//    
//    // 다중 탭 구현 준비
//        UICollectionViewFlowLayout *layout=[[UICollectionViewFlowLayout alloc] init];
//        _collectionView=[[UICollectionView alloc] initWithFrame:CGRectMake(0, 50, CGRectGetWidth(self.view.frame), 50) collectionViewLayout:layout];
//        [_collectionView setDataSource:self];
//        [_collectionView setDelegate:self];
//    
//        [_collectionView registerClass:[UICollectionViewCell class] forCellWithReuseIdentifier:@"cellIdentifier"];
//        [_collectionView setBackgroundColor:[UIColor blackColor]];
//        [_collectionView setShowsHorizontalScrollIndicator:YES];
//    
//        ((UICollectionViewFlowLayout *)_collectionView.collectionViewLayout).scrollDirection = UICollectionViewScrollDirectionHorizontal;
//        [_collectionView setAlwaysBounceHorizontal:YES];
////    [self.navigationController.view addSubview:_collectionView];
//    
//    self.pageSlider = [[UISlider alloc] initWithFrame:CGRectMake(0, CGRectGetHeight(self.view.frame)-40, CGRectGetWidth(self.view.frame), 40)];
//    [self.pageSlider addTarget:self action:@selector(getpageSlider:) forControlEvents:UIControlEventValueChanged];
//    [self.pageSlider setBackgroundColor:[UIColor colorWithRed:0.09 green:0.27 blue:0.48 alpha:1.00]];
//    [self.pageSlider setTintColor:[UIColor whiteColor]];
//    self.pageSlider.minimumValue = 0;
//    self.pageSlider.maximumValue = [self.DocumentViewController pageCount]-1;
//    self.pageSlider.continuous = YES;
//    self.pageSlider.value = 0;
//    //    [self.DocumentViewController.view addSubview:self.pageSlider];
//    
//    UIDeviceOrientation deviceOrientation = [[UIDevice currentDevice] orientation];
//    NSLog(@"%d", (int)deviceOrientation);
//    
//    [self.DocumentViewController setNavigationBarImage:[[NSBundle mainBundle] pathForResource: @"viewer-icon/bottom-bar" ofType: @"png"]];
//    [self.DocumentViewController.navigationController.toolbar setBackgroundColor:[UIColor colorWithRed:0.09 green:0.27 blue:0.48 alpha:1.00]];
//    
//    [self.DocumentViewController setEnableAlwaysVisible:YES];
//    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.1 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
//        [self.DocumentViewController setNavigationToolBarHidden:NO];
////        [self.DocumentViewController setEnableBottomBar:NO];
//    });
//}
//
//-(void)callNote{
//    if (self.DocumentViewController && [self.DocumentViewController respondsToSelector:@selector(showNoteAnnotEditView: annot:)]){
//        //        if ([self.DocumentViewController showNoteAnnotEditView: self cannot: annot]) return;
//    }
//}
//
//-(void) initNavigationBar{
//    self.navbar = [[UINavigationBar alloc]initWithFrame:CGRectMake(0, 0, CGRectGetWidth(self.view.frame), 60)];
//    self.navItem = [[UINavigationItem alloc] init];
//    
//    self.navbar.translucent = NO;
//    [self.navbar setTintColor:[UIColor whiteColor]];
//    [self.navbar setBarTintColor:[UIColor colorWithRed:0.09 green:0.27 blue:0.48 alpha:1.00]];
//    
//    self.navItem.title = self.title;
//    [self.navbar setTitleTextAttributes:@{NSForegroundColorAttributeName : [UIColor whiteColor]}];
//    
//    //    UIBarButtonItem *backBtn = [[UIBarButtonItem alloc]
//    //                                initWithImage:[UIImage imageNamed:@"cont-lineup.png"]
//    //                                style:UIBarButtonItemStylePlain
//    //                                target:self
//    //                                action:@selector(openPlugPDF:)];
//    
//    UIImage *myImage = [UIImage imageNamed:@"viewer-icon/logo.png"];
//    UIButton *myButton = [UIButton buttonWithType:UIButtonTypeCustom];
//    [myButton setImage:myImage forState:UIControlStateNormal];
//    myButton.frame = CGRectMake(0.0, 3.0, 130,30);
//    [myButton addTarget:self action:@selector(openPlugPDF:) forControlEvents:UIControlEventTouchUpInside];
//    myButton.tag = 15;
//    UIBarButtonItem *backBtn = [[UIBarButtonItem alloc] initWithCustomView:myButton];
//    
//    UIImage *saveImage = [UIImage imageNamed:@"viewer-icon/top-icon-01.png"];
//    UIButton *saveButton = [UIButton buttonWithType:UIButtonTypeCustom];
//    [saveButton setImage:saveImage forState:UIControlStateNormal];
//    saveButton.frame = CGRectMake(0.0, 3.0, 30,30);
//    [saveButton addTarget:self action:@selector(openPlugPDF:) forControlEvents:UIControlEventTouchUpInside];
//    saveButton.tag = 16;
//    UIBarButtonItem *save = [[UIBarButtonItem alloc] initWithCustomView:saveButton];
//    
//    UIImage *displayRotateImage = [UIImage imageNamed:@"viewer-icon/top-icon-02-01.png"];
//    self.displayRotateButton = [UIButton buttonWithType:UIButtonTypeCustom];
//    [self.displayRotateButton setImage:displayRotateImage forState:UIControlStateNormal];
//    self.displayRotateButton.frame = CGRectMake(0.0, 3.0, 30,30);
//    [self.displayRotateButton addTarget:self action:@selector(openPlugPDF:) forControlEvents:UIControlEventTouchUpInside];
//    self.displayRotateButton.tag = 17;
//    UIBarButtonItem *displayRotate = [[UIBarButtonItem alloc] initWithCustomView:self.displayRotateButton];
//    
//    UIImage *displayModeImage = [UIImage imageNamed:@"viewer-icon/top-icon-03-01.png"];
//    UIButton *displayModeButton = [UIButton buttonWithType:UIButtonTypeCustom];
//    [displayModeButton setImage:displayModeImage forState:UIControlStateNormal];
//    displayModeButton.frame = CGRectMake(0.0, 3.0, 30,30);
//    [displayModeButton addTarget:self action:@selector(openPlugPDF:) forControlEvents:UIControlEventTouchUpInside];
//    displayModeButton.tag = 18;
//    UIBarButtonItem *displayMode = [[UIBarButtonItem alloc] initWithCustomView:displayModeButton];
//    
//    UIImage *bookMarkImage = [UIImage imageNamed:@"viewer-icon/top-icon-04.png"];
//    self.bookMarkButton = [UIButton buttonWithType:UIButtonTypeCustom];
//    [self.bookMarkButton setImage:bookMarkImage forState:UIControlStateNormal];
//    self.bookMarkButton.frame = CGRectMake(0.0, 3.0, 30,30);
//    [self.bookMarkButton addTarget:self action:@selector(openPlugPDF:) forControlEvents:UIControlEventTouchUpInside];
//    self.bookMarkButton.tag = 19;
//    UIBarButtonItem *bookMark = [[UIBarButtonItem alloc] initWithCustomView:self.bookMarkButton];
//    
//    UIImage *searchImage = [UIImage imageNamed:@"viewer-icon/top-icon-05.png"];
//    UIButton *searchButton = [UIButton buttonWithType:UIButtonTypeCustom];
//    [searchButton setImage:searchImage forState:UIControlStateNormal];
//    searchButton.frame = CGRectMake(0.0, 3.0, 30,30);
//    [searchButton addTarget:self action:@selector(openPlugPDF:) forControlEvents:UIControlEventTouchUpInside];
//    searchButton.tag = 20;
//    UIBarButtonItem *search = [[UIBarButtonItem alloc] initWithCustomView:searchButton];
//    
//    UIImage *inkImage = [UIImage imageNamed:@"viewer-icon/top-icon-06.png"];
//    self.inkButton = [UIButton buttonWithType:UIButtonTypeCustom];
//    [self.inkButton setImage:inkImage forState:UIControlStateNormal];
//    self.inkButton.frame = CGRectMake(0.0, 3.0, 30,30);
//    [self.inkButton addTarget:self action:@selector(openPlugPDF:) forControlEvents:UIControlEventTouchUpInside];
//    self.inkButton.tag = 21;
//    self.ink = [[UIBarButtonItem alloc] initWithCustomView:self.inkButton];
//    
//    UIImage *hideImage = [UIImage imageNamed:@"viewer-icon/tap-up.png"];
//    self.hideButton = [UIButton buttonWithType:UIButtonTypeCustom];
//    [self.hideButton setImage:hideImage forState:UIControlStateNormal];
//    self.hideButton.frame = CGRectMake(0.0, 3.0, 20,20);
//    [self.hideButton addTarget:self action:@selector(hideBar:) forControlEvents:UIControlEventTouchUpInside];
//    self.hide = [[UIBarButtonItem alloc] initWithCustomView:self.hideButton];
//    
//    self.navItem.leftBarButtonItems = [NSArray arrayWithObjects:backBtn,nil];
//    self.navItem.rightBarButtonItems = [NSArray arrayWithObjects:self.hide,self.ink,search,bookMark,displayMode,save,nil];
//    
//    [self.navbar setItems:@[self.navItem]];
//    
//    //do something like background color, title, etc you self
//    [self.DocumentViewController.view addSubview:self.navbar];
//}
//
//-(void)initMovePageButton{
//    self.beforePageView = [[UIView alloc] initWithFrame:CGRectMake(CGRectGetWidth(self.view.frame) - 100, CGRectGetHeight(self.view.frame) - 100, 40, 40)];
//    self.beforePageView.layer.cornerRadius = 20;
//    [self.beforePageView setBackgroundColor:[UIColor colorWithRed:0.09 green:0.27 blue:0.48 alpha:1.00]];
//    
//    self.beforePage = [[UIButton alloc] initWithFrame: CGRectMake(8, 8, 20, 25)];
//    [self.beforePage setImage:[UIImage imageNamed:@"viewer-icon/footer-arrow-before.png"] forState:UIControlStateNormal];
//    [self.beforePage addTarget: self action: @selector(openPlugPDF3:) forControlEvents: UIControlEventTouchUpInside];
//    self.beforePage.tag = 12;
//    [self.beforePageView addSubview:self.beforePage];
//    
//    self.nextPageView = [[UIView alloc] initWithFrame:CGRectMake(CGRectGetWidth(self.view.frame) - 50, CGRectGetHeight(self.view.frame) - 100, 40, 40)];
//    self.nextPageView.layer.cornerRadius = 20;
//    [self.nextPageView setBackgroundColor:[UIColor colorWithRed:0.09 green:0.27 blue:0.48 alpha:1.00]];
//    
//    self.nextPage = [[UIButton alloc] initWithFrame: CGRectMake(12, 8, 20, 25)];
//    [self.nextPage setImage:[UIImage imageNamed:@"viewer-icon/footer-arrow-next.png"] forState:UIControlStateNormal];
//    [self.nextPage addTarget: self action: @selector(openPlugPDF3:) forControlEvents: UIControlEventTouchUpInside];
//    self.nextPage.tag = 13;
//    [self.nextPageView addSubview:self.nextPage];
//    
//    [self.DocumentViewController.view addSubview:self.beforePageView];
//    [self.DocumentViewController.view addSubview:self.nextPageView];
//}
//
//- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section
//{
//    return 15;
//}
//
//// The cell that is returned must be retrieved from a call to -dequeueReusableCellWithReuseIdentifier:forIndexPath:
//- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
//{
//    UICollectionViewCell *cell=[collectionView dequeueReusableCellWithReuseIdentifier:@"cellIdentifier" forIndexPath:indexPath];
//    
//    cell.backgroundColor=[UIColor colorWithRed:0.03 green:(0.20) blue:0.39 alpha:1.00];
//    
//    UILabel *lable = [[UILabel alloc] initWithFrame:CGRectMake(10, CGRectGetHeight(cell.frame)/4, CGRectGetWidth(cell.frame), 30)];
//    [lable setText:[NSString stringWithFormat:@"[JW]%ld-%ld",(long)indexPath.section,(long)indexPath.row]];
//    
//    [cell.contentView addSubview:lable];
//    
//    return cell;
//}
//
//- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath
//{
//    NSLog(@"");
//}
//
//- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath
//{
//    return CGSizeMake(CGRectGetWidth(self.view.frame)/3, CGRectGetHeight(_collectionView.frame));
//}
//
//- (void)didReceiveMemoryWarning {
//    [super didReceiveMemoryWarning];
//    // Dispose of any resources that can be recreated.
//}
//
//- (void)hideBar: (id)sender{
//    
//    self.displayBtnView = [[UIView alloc] initWithFrame: CGRectMake(CGRectGetWidth(self.view.frame)-45, 25, 30, 30)];
//    self.displayBtnView.backgroundColor = [UIColor colorWithRed:0.09 green:0.27 blue:0.48 alpha:1.00];
//    self.displayBtnView.layer.cornerRadius = 3.0f;
//    
//    self.displayBtn = [[UIButton alloc] initWithFrame: CGRectMake(5, 5, 20, 20)];
//    [self.displayBtn setImage:[UIImage imageNamed:@"viewer-icon/tap-down.png"] forState:UIControlStateNormal];
//    [self.displayBtn addTarget: self action: @selector(displayBar:) forControlEvents: UIControlEventTouchUpInside];
//    [self.displayBtnView addSubview:self.displayBtn];
//    
//    [self.DocumentViewController.view addSubview:self.displayBtnView];
//    
//    [self.navbar setHidden:YES];
//    [self.beforePageView setHidden:YES];
//    [self.nextPageView setHidden:YES];
//    [[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleBlackTranslucent];
//    [self.DocumentViewController setEnableBottomBar:YES];
//    [self.DocumentViewController setNavigationToolBarHidden:YES];
//    [self.DocumentViewController setEnableBottomBar:NO];
//    [self.DocumentViewController setEnablePageIndicator:NO];
//    
//}
//
//- (void)displayBar: (id)sender{
//    [self.displayBtnView setHidden:YES];
//    [self.navbar setHidden:NO];
//    [self.beforePageView setHidden:NO];
//    [self.nextPageView setHidden:NO];
//    [self.beforePage setHidden:NO];
//    [[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleLightContent];
//    [self.DocumentViewController setEnableBottomBar:YES];
//    [self.DocumentViewController setEnablePageIndicator:YES];
//    [self.DocumentViewController setNavigationToolBarHidden:NO];
//    [self.DocumentViewController setEnableBottomBar:NO];
//    [self.DocumentViewController setEnablePageIndicator:NO];
//}
//
//- (void)openPlugPDF: (id)sender {
//    NSLog(@"%ld", (long)[sender tag]);
//    if([sender tag] == 15){
//        if(isAnnot){
//            isAnnot = NO;
//            [self releaseAnnotBtn];
//            [self releaseAnnots];
//            [self releaseSubViews];
//            [self.DocumentViewController releaseTools];
//        } else {
//            [self releaseAnnotBtn];
//            [self releaseAnnots];
//            [self releaseSubViews];
//            [self.DocumentViewController releaseTools];
////            [self dismissViewControllerAnimated:NO completion:nil];
////            AppDelegate *AD = [[UIApplication sharedApplication] delegate];
////            [self presentViewController:AD.viewController animated:NO completion:nil];
//        }
//    } else if([sender tag] == 16){
//        [self.DocumentViewController saveFile:NO];
//    } else if([sender tag] == 17){
//        if(isRotate == YES){
//            isRotate = NO;
//            UIImage *rotateImage = [UIImage imageNamed:@"viewer-icon/top-icon-02-02.png"];
//            [self.displayRotateButton setImage:rotateImage forState:UIControlStateNormal];
//            [self.DocumentViewController setRotationLock:NO];
//            [[NSUserDefaults standardUserDefaults] setValue:@"no" forKey:@"rotate"];
//        } else {
//            isRotate = YES;
//            UIImage *rotateImage = [UIImage imageNamed:@"viewer-icon/top-icon-02-01.png"];
//            [self.displayRotateButton setImage:rotateImage forState:UIControlStateNormal];
//            [self.DocumentViewController setRotationLock:YES];
//            [[NSUserDefaults standardUserDefaults] setValue:@"yes" forKey:@"rotate"];
//        }
//    } else if([sender tag] == 18){
//        self.displayPopoverContent = [[UIViewController alloc] init]; //ViewController
//        self.displayPopoverView = [[UIView alloc] init];   //view
//        
//        UIButton *button1 = [[UIButton alloc] initWithFrame: CGRectMake(5, 5, 30, 30)];
//        [button1 setImage:[UIImage imageNamed:@"viewer-icon/top-icon-03-01.png"] forState:UIControlStateNormal];
//        [button1 addTarget: self action: @selector(openPlugPDF3:) forControlEvents: UIControlEventTouchUpInside];
//        button1.tag = 1;
//        
//        UIButton *button2 = [[UIButton alloc] initWithFrame: CGRectMake(5, 40, 30, 30)];
//        [button2 setImage:[UIImage imageNamed:@"viewer-icon/top-icon-03-02.png"] forState:UIControlStateNormal];
//        [button2 addTarget: self action: @selector(openPlugPDF3:) forControlEvents: UIControlEventTouchUpInside];
//        button2.tag = 2;
//        
//        UIButton *button3 = [[UIButton alloc] initWithFrame: CGRectMake(5, 75, 30, 30)];
//        [button3 setImage:[UIImage imageNamed:@"viewer-icon/top-icon-03-03.png"] forState:UIControlStateNormal];
//        [button3 addTarget: self action: @selector(openPlugPDF3:) forControlEvents: UIControlEventTouchUpInside];
//        button3.tag = 3;
//        
//        UIButton *button22 = [[UIButton alloc] initWithFrame: CGRectMake(5, 110, 30, 30)];
//        [button22 setImage:[UIImage imageNamed:@"viewer-icon/top-icon-03-04.png"] forState:UIControlStateNormal];
//        [button22 addTarget: self action: @selector(openPlugPDF3:) forControlEvents: UIControlEventTouchUpInside];
//        button22.tag = 22;
//        
//        [self.displayPopoverView addSubview:button1];
//        [self.displayPopoverView addSubview:button2];
//        [self.displayPopoverView addSubview:button3];
//        [self.displayPopoverView addSubview:button22];
//        
//        self.displayPopoverContent.view = self.displayPopoverView;
//        
//        self.displayPopoverController = [[UIPopoverController alloc] initWithContentViewController:self.displayPopoverContent];
//        self.displayPopoverController.delegate=self;
//        self.displayPopoverController.backgroundColor = [UIColor colorWithRed:0.03 green:(0.14) blue:0.27 alpha:1.00];
//        
//        
//        UIView *view = [sender valueForKey:@"imageView"];
//        
//        self.displayPopoverController.popoverContentSize = CGSizeMake(40, 145);
//        [self.displayPopoverController presentPopoverFromRect:CGRectMake(CGRectGetWidth(view.frame)/2, 40, 0, 0) inView:view permittedArrowDirections:UIPopoverArrowDirectionUp animated:YES];
//    } else if([sender tag] == 19){
//        UIViewController* popoverContent = [[UIViewController alloc] init]; //ViewController
//        UIView *popoverView = [[UIView alloc] init];   //view
//        
//        popoverContent.view = popoverView;
//        //
//        self.BMpopoverController = [[UIPopoverController alloc] initWithContentViewController:popoverContent];
//        self.BMpopoverController.delegate=self;
//        self.BMpopoverController.backgroundColor = [UIColor colorWithRed:0.03 green:(0.14) blue:0.27 alpha:1.00];
//        
//        UIView *view = [sender valueForKey:@"imageView"];
//        self.BMnavcon = [[UINavigationBar alloc]initWithFrame:CGRectMake(5, 5, 290, 40)];
//        self.BMnavItem = [[UINavigationItem alloc] init];
//        
//        [self.BMnavcon setBarTintColor:[UIColor colorWithRed:0.03 green:(0.14) blue:0.27 alpha:1.00]];
//        self.BMnavcon.translucent = NO;
//        self.BMnavItem.title = @"북마크 (목차)";
//        self.BMnavcon.tintColor = [UIColor whiteColor];
//        [self.BMnavcon setTitleTextAttributes:@{NSForegroundColorAttributeName:[UIColor whiteColor]}];
//        
//        UIImage *addBMImage = [UIImage imageNamed:@"viewer-icon/plus-01.png"];
//        UIButton *addBMButton = [UIButton buttonWithType:UIButtonTypeCustom];
//        [addBMButton setImage:addBMImage forState:UIControlStateNormal];
//        addBMButton.frame = CGRectMake(0.0, 3.0, 25,25);
//        [addBMButton addTarget:self action:@selector(openPlugPDF:) forControlEvents:UIControlEventTouchUpInside];
//        addBMButton.tag = 23;
//        UIBarButtonItem *addBM = [[UIBarButtonItem alloc] initWithCustomView:addBMButton];
//        
//        UIImage *deleteBMImage = [UIImage imageNamed:@"viewer-icon/minus-01.png"];
//        UIButton *deleteBMButton = [UIButton buttonWithType:UIButtonTypeCustom];
//        [deleteBMButton setImage:deleteBMImage forState:UIControlStateNormal];
//        deleteBMButton.frame = CGRectMake(0.0, 3.0, 25,25);
//        [deleteBMButton addTarget:self action:@selector(openPlugPDF:) forControlEvents:UIControlEventTouchUpInside];
//        deleteBMButton.tag = 24;
//        UIBarButtonItem *delBM = [[UIBarButtonItem alloc] initWithCustomView:deleteBMButton];
//        
//        self.BMnavItem.rightBarButtonItems = [NSArray arrayWithObjects:delBM,addBM,nil];
//        [self.BMnavcon setItems:@[self.BMnavItem]];
//        
//        [popoverView addSubview:self.BMnavcon];
//        
//        
//        self.BMtableView = [[UITableView alloc]initWithFrame:CGRectMake(5, 40, 290, 350)];
//        self.BMtableView.delegate = self;
//        self.BMtableView.dataSource = self;
//        self.BMtableView.layer.cornerRadius = 10;
//        [popoverView addSubview:self.BMtableView];
//        
//        numberOfSection = 1;
//        self.BMtableView.allowsSelectionDuringEditing = YES;
//        self.BMtableView.contentInset = UIEdgeInsetsMake(0, -8, 0, 0);
//        
//        self.BMpopoverController.popoverContentSize = CGSizeMake(300, 400);
//        [self.BMpopoverController presentPopoverFromRect:CGRectMake(CGRectGetWidth(view.frame)/2, 40, 0, 0) inView:view permittedArrowDirections:UIPopoverArrowDirectionUp animated:YES];
//    } else if([sender tag] == 20){
//        [self.navbar removeFromSuperview];
//        self.searchNavbar = [[UINavigationBar alloc]initWithFrame:CGRectMake(0, 0, CGRectGetWidth(self.view.frame), 60)];
//        self.navItem = [[UINavigationItem alloc] init];
//        
//        self.searchNavbar.translucent = NO;
//        [self.searchNavbar setTintColor:[UIColor whiteColor]];
//        [self.searchNavbar setBarTintColor:[UIColor colorWithRed:0.06 green:(0.27) blue:0.48 alpha:1.00]];
//        
//        UIImage *cancleSearchImage = [UIImage imageNamed:@"viewer-icon/search-defore.png"];
//        UIButton *cancleSearchButton = [UIButton buttonWithType:UIButtonTypeCustom];
//        [cancleSearchButton setImage:cancleSearchImage forState:UIControlStateNormal];
//        cancleSearchButton.frame = CGRectMake(0.0, 3.0, 25,25);
//        [cancleSearchButton addTarget:self action:@selector(cancelSearch:) forControlEvents:UIControlEventTouchUpInside];
//        UIBarButtonItem *backBtn = [[UIBarButtonItem alloc] initWithCustomView:cancleSearchButton];
//        
//        UIImage *backwardImage = [UIImage imageNamed:@"viewer-icon/search-before.png"];
//        UIButton *backwardButton = [UIButton buttonWithType:UIButtonTypeCustom];
//        [backwardButton setImage:backwardImage forState:UIControlStateNormal];
//        backwardButton.frame = CGRectMake(0.0, 3.0, 25,25);
//        [backwardButton addTarget:self action:@selector(backSearch:) forControlEvents:UIControlEventTouchUpInside];
//        UIBarButtonItem *backward = [[UIBarButtonItem alloc] initWithCustomView:backwardButton];
//        
//        UIImage *forwardImage = [UIImage imageNamed:@"viewer-icon/search-next.png"];
//        UIButton *forwardButton = [UIButton buttonWithType:UIButtonTypeCustom];
//        [forwardButton setImage:forwardImage forState:UIControlStateNormal];
//        forwardButton.frame = CGRectMake(0.0, 3.0, 25,25);
//        [forwardButton addTarget:self action:@selector(forSearch:) forControlEvents:UIControlEventTouchUpInside];
//        UIBarButtonItem *forward = [[UIBarButtonItem alloc] initWithCustomView:forwardButton];
//        
//        self.searchBar = [[UISearchBar alloc] initWithFrame:CGRectMake(60, 20, CGRectGetWidth(self.navbar.frame) - 150, 40)];
//        self.searchBar.placeholder = @"단어 검색";
//        [self.searchNavbar addSubview:self.searchBar];
//        
//        self.navItem.leftBarButtonItems = [NSArray arrayWithObjects:backBtn,nil];
//        self.navItem.rightBarButtonItems = [NSArray arrayWithObjects:forward,backward,nil];
//        
//        [self.searchNavbar setItems:@[self.navItem]];
//        
//        //do something like background color, title, etc you self
//        [self.DocumentViewController.view addSubview:self.searchNavbar];
//    } else if([sender tag] == 21){
//        [self releaseAnnotBtn];
//        
//        self.inkBtn = [[UIButton alloc] initWithFrame: CGRectMake(10, 10, 30, 30)];
//        [self.inkBtn setImage:[UIImage imageNamed:@"viewer-icon/pan-icon-01.png"] forState:UIControlStateNormal];
//        [self.inkBtn addTarget: self action: @selector(openPlugPDF3:) forControlEvents: UIControlEventTouchUpInside];
//        self.inkBtn.tag = 4;
//        
//        self.squareBtn = [[UIButton alloc] initWithFrame: CGRectMake(55, 10, 30, 30)];
//        [self.squareBtn setImage:[UIImage imageNamed:@"viewer-icon/pan-icon-02.png"] forState:UIControlStateNormal];
//        [self.squareBtn addTarget: self action: @selector(openPlugPDF3:) forControlEvents: UIControlEventTouchUpInside];
//        self.squareBtn.tag = 5;
//        
//        self.circleBtn = [[UIButton alloc] initWithFrame: CGRectMake(100, 10, 30, 30)];
//        [self.circleBtn setImage:[UIImage imageNamed:@"viewer-icon/pan-icon-03.png"] forState:UIControlStateNormal];
//        [self.circleBtn addTarget: self action: @selector(openPlugPDF3:) forControlEvents: UIControlEventTouchUpInside];
//        self.circleBtn.tag = 6;
//        
//        self.highlightBtn = [[UIButton alloc] initWithFrame: CGRectMake(145, 10, 30, 30)];
//        [self.highlightBtn setImage:[UIImage imageNamed:@"viewer-icon/pan-icon-04.png"] forState:UIControlStateNormal];
//        [self.highlightBtn addTarget: self action: @selector(openPlugPDF3:) forControlEvents: UIControlEventTouchUpInside];
//        self.highlightBtn.tag = 7;
//        
//        self.underlineBtn = [[UIButton alloc] initWithFrame: CGRectMake(190, 10, 30, 30)];
//        [self.underlineBtn setImage:[UIImage imageNamed:@"viewer-icon/pan-icon-05.png"] forState:UIControlStateNormal];
//        [self.underlineBtn addTarget: self action: @selector(openPlugPDF3:) forControlEvents: UIControlEventTouchUpInside];
//        self.underlineBtn.tag = 8;
//        
//        self.cancleBtn = [[UIButton alloc] initWithFrame: CGRectMake(235, 10, 30, 30)];
//        [self.cancleBtn setImage:[UIImage imageNamed:@"viewer-icon/pan-icon-06.png"] forState:UIControlStateNormal];
//        [self.cancleBtn addTarget: self action: @selector(openPlugPDF3:) forControlEvents: UIControlEventTouchUpInside];
//        self.cancleBtn.tag = 9;
//        
//        self.noteBtn = [[UIButton alloc] initWithFrame: CGRectMake(280, 10, 30, 30)];
//        [self.noteBtn setImage:[UIImage imageNamed:@"viewer-icon/pan-icon-07.png"] forState:UIControlStateNormal];
//        [self.noteBtn addTarget: self action: @selector(openPlugPDF3:) forControlEvents: UIControlEventTouchUpInside];
//        self.noteBtn.tag = 10;
//        
//        self.eraserBtn = [[UIButton alloc] initWithFrame: CGRectMake(325, 10, 30, 30)];
//        [self.eraserBtn setImage:[UIImage imageNamed:@"viewer-icon/pan-icon-08.png"] forState:UIControlStateNormal];
//        [self.eraserBtn addTarget: self action: @selector(openPlugPDF3:) forControlEvents: UIControlEventTouchUpInside];
//        self.eraserBtn.tag = 11;
//        
//        [self.inkPopoverView addSubview:self.inkBtn];
//        [self.inkPopoverView addSubview:self.squareBtn];
//        [self.inkPopoverView addSubview:self.circleBtn];
//        [self.inkPopoverView addSubview:self.highlightBtn];
//        [self.inkPopoverView addSubview:self.underlineBtn];
//        [self.inkPopoverView addSubview:self.cancleBtn];
//        [self.inkPopoverView addSubview:self.noteBtn];
//        [self.inkPopoverView addSubview:self.eraserBtn];
//        
//        self.inkPopoverContent.view = self.inkPopoverView;
//        
//        self.inkPopoverController = [[UIPopoverController alloc] initWithContentViewController:self.inkPopoverContent];
//        self.inkPopoverController.delegate=self;
//        
//        self.inkPopoverController.backgroundColor = [UIColor colorWithRed:0.03 green:(0.14) blue:0.27 alpha:1.00];
//        
//        self.annotPopupView = [sender valueForKey:@"imageView"];
//        
//        self.inkPopoverController.popoverContentSize = CGSizeMake(365, 50);
//        [self.inkPopoverController presentPopoverFromRect:CGRectMake(CGRectGetWidth(self.annotPopupView.frame)/2, 30, 0, 0) inView:self.annotPopupView permittedArrowDirections:UIPopoverArrowDirectionUp animated:YES];
//        
//        if(UsingInk == YES){ [self.inkBtn sendActionsForControlEvents:UIControlEventTouchUpInside]; }
//        else if(UsingSquare == YES){ [self.squareBtn sendActionsForControlEvents:UIControlEventTouchUpInside]; }
//        else if(UsingCircle == YES){ [self.circleBtn sendActionsForControlEvents:UIControlEventTouchUpInside]; }
//        else if(UsingHighlight == YES){ [self.highlightBtn sendActionsForControlEvents:UIControlEventTouchUpInside]; }
//        else if(UsingUnderline == YES){ [self.underlineBtn sendActionsForControlEvents:UIControlEventTouchUpInside]; }
//        else if(UsingCancle == YES){ [self.cancleBtn sendActionsForControlEvents:UIControlEventTouchUpInside]; }
//        else if(UsingNote == YES){ [self.noteBtn sendActionsForControlEvents:UIControlEventTouchUpInside]; }
//        else if(UsingEraser == YES){ [self.eraserBtn sendActionsForControlEvents:UIControlEventTouchUpInside]; }
//        
//        
//    }  else if([sender tag] == 23){
////        UIImage *completeBMImage = [UIImage imageNamed:@"viewer-icon/check-01.png"];
////        UIButton *completeBMButton = [UIButton buttonWithType:UIButtonTypeCustom];
////        [completeBMButton setImage:completeBMImage forState:UIControlStateNormal];
////        completeBMButton.frame = CGRectMake(0.0, 3.0, 25,25);
////        [completeBMButton addTarget:self action:@selector(openPlugPDF:) forControlEvents:UIControlEventTouchUpInside];
////        completeBMButton.tag = 25;
////        UIBarButtonItem *completeBM = [[UIBarButtonItem alloc] initWithCustomView:completeBMButton];
////        
////        self.BMnavItem.rightBarButtonItems = [NSArray arrayWithObjects:completeBM,nil];
////        [self.BMnavcon setItems:@[self.BMnavItem]];
////        
////        EditMode = 1;
////        //we are not in edit mode yet
////        if([self.BMtableView isEditing] == NO){
////            //IMPORTANT:
////            //we are using a custom buttom to enter edit mode therefore we must
////            //call setEditing: manually.
////            //if we use apple's edit button, it will automatatically called method
////            //apple's EDIT BUTTON, could add in viewDidLoad: self.navigationItem.leftBarButtonItem = self.editButtonItem;
////            //            [self setEditing:YES];
////            
////            //up the button so that the user knows to click it when they
////            //are done
////            //[self.editBtn setTitle:@"Done"];
////            //set the table to editing mode
////            [self.BMtableView setEditing:YES animated:YES];
////        }else{
////            //            [self setEditing:NO];
////            //we are currently in editing mode
////            //change the button text back to Edit
////            //[self.editBtn setTitle:@"Edit"];
////            //take the table out of edit mode
////            [self.BMtableView setEditing:NO animated:YES];
////        }
////        
////        if((unsigned long)self.tabledata.count == 0){
//            NSNumber *currentPage = [NSNumber numberWithInteger:self.DocumentViewController.pageIdx+1];
//            [self.tabledata addObject:@"새 북마크"];
//            [self.pagedata addObject:currentPage];
//
//        NSSortDescriptor *highestToLowest = [NSSortDescriptor sortDescriptorWithKey:@"self" ascending:YES];
//        [self.pagedata sortUsingDescriptors:[NSArray arrayWithObject:highestToLowest]];
//        
//            [self.BMtableView reloadData];
//            EditMode = 3;
////            if([self.BMtableView isEditing] == NO){
////                //            [self setEditing:YES];
////                [self.BMtableView setEditing:YES animated:YES];
////            }else{
////                //            [self setEditing:NO];
////                [self.BMtableView setEditing:NO animated:YES];
////            }
////            UIImage *addBMImage = [UIImage imageNamed:@"viewer-icon/plus-01.png"];
////            UIButton *addBMButton = [UIButton buttonWithType:UIButtonTypeCustom];
////            [addBMButton setImage:addBMImage forState:UIControlStateNormal];
////            addBMButton.frame = CGRectMake(0.0, 3.0, 25,25);
////            [addBMButton addTarget:self action:@selector(openPlugPDF:) forControlEvents:UIControlEventTouchUpInside];
////            addBMButton.tag = 23;
////            UIBarButtonItem *addBM = [[UIBarButtonItem alloc] initWithCustomView:addBMButton];
////            
////            UIImage *deleteBMImage = [UIImage imageNamed:@"viewer-icon/minus-01.png"];
////            UIButton *deleteBMButton = [UIButton buttonWithType:UIButtonTypeCustom];
////            [deleteBMButton setImage:deleteBMImage forState:UIControlStateNormal];
////            deleteBMButton.frame = CGRectMake(0.0, 3.0, 25,25);
////            [deleteBMButton addTarget:self action:@selector(openPlugPDF:) forControlEvents:UIControlEventTouchUpInside];
////            deleteBMButton.tag = 24;
////            UIBarButtonItem *delBM = [[UIBarButtonItem alloc] initWithCustomView:deleteBMButton];
////            
////            self.BMnavItem.rightBarButtonItems = [NSArray arrayWithObjects:delBM,addBM,nil];
////            [self.BMnavcon setItems:@[self.BMnavItem]];
////        }
//        NSLog(@"%lu",(unsigned long)self.tabledata.count);
//        //        [popoverView addSubview:self.BMnavcon];
//    } else if([sender tag] == 24){
//        EditMode = 2;
//        //we are not in edit mode yet
//        if([self.BMtableView isEditing] == NO){
//            //            [self setEditing:YES];
//            [self.BMtableView setEditing:YES animated:YES];
//        }else{
//            //            [self setEditing:NO];
//            [self.BMtableView setEditing:NO animated:YES];
//        }
//        UIImage *completeBMImage = [UIImage imageNamed:@"viewer-icon/check-01.png"];
//        UIButton *completeBMButton = [UIButton buttonWithType:UIButtonTypeCustom];
//        [completeBMButton setImage:completeBMImage forState:UIControlStateNormal];
//        completeBMButton.frame = CGRectMake(0.0, 3.0, 25,25);
//        [completeBMButton addTarget:self action:@selector(openPlugPDF:) forControlEvents:UIControlEventTouchUpInside];
//        completeBMButton.tag = 25;
//        UIBarButtonItem *completeBM = [[UIBarButtonItem alloc] initWithCustomView:completeBMButton];
//        
//        self.BMnavItem.rightBarButtonItems = [NSArray arrayWithObjects:completeBM,nil];
//        [self.BMnavcon setItems:@[self.BMnavItem]];
//        
//    } else if([sender tag] == 25){
//        EditMode = 3;
//        if([self.BMtableView isEditing] == NO){
//            //            [self setEditing:YES];
//            [self.BMtableView setEditing:YES animated:YES];
//        }else{
//            //            [self setEditing:NO];
//            [self.BMtableView setEditing:NO animated:YES];
//        }
//        
//        UIImage *addBMImage = [UIImage imageNamed:@"viewer-icon/plus-01.png"];
//        UIButton *addBMButton = [UIButton buttonWithType:UIButtonTypeCustom];
//        [addBMButton setImage:addBMImage forState:UIControlStateNormal];
//        addBMButton.frame = CGRectMake(0.0, 3.0, 25,25);
//        [addBMButton addTarget:self action:@selector(openPlugPDF:) forControlEvents:UIControlEventTouchUpInside];
//        addBMButton.tag = 23;
//        UIBarButtonItem *addBM = [[UIBarButtonItem alloc] initWithCustomView:addBMButton];
//        
//        UIImage *deleteBMImage = [UIImage imageNamed:@"viewer-icon/minus-01.png"];
//        UIButton *deleteBMButton = [UIButton buttonWithType:UIButtonTypeCustom];
//        [deleteBMButton setImage:deleteBMImage forState:UIControlStateNormal];
//        deleteBMButton.frame = CGRectMake(0.0, 3.0, 25,25);
//        [deleteBMButton addTarget:self action:@selector(openPlugPDF:) forControlEvents:UIControlEventTouchUpInside];
//        deleteBMButton.tag = 24;
//        UIBarButtonItem *delBM = [[UIBarButtonItem alloc] initWithCustomView:deleteBMButton];
//        
//        self.BMnavItem.rightBarButtonItems = [NSArray arrayWithObjects:delBM,addBM,nil];
//        [self.BMnavcon setItems:@[self.BMnavItem]];
//    }
//    
//    NSLog(@"title = %@",[sender title]);
//    
//    
//}
//
//-(void)cancelSearch: (id)sender{
//    [self.searchNavbar removeFromSuperview];
//    [self initNavigationBar];
//}
//
//-(void)backSearch: (id)sender{
//    [self.DocumentViewController search:self.searchBar.text pageIdx:self.DocumentViewController.pageIdx direction:PlugPDFDocumentSearchDirectionBackwardOnly];
//}
//
//-(void)forSearch: (id)sender{
//    [self.DocumentViewController search:self.searchBar.text pageIdx:self.DocumentViewController.pageIdx direction:PlugPDFDocumentSearchDirectionForwardOnly];
//}
//
//- (void)openPlugPDF3: (id)sender {
//    NSLog(@"%ld", (long)[sender tag]);
//    if([sender tag] == 1){
//        [self.DocumentViewController setDisplayMode:PlugPDFDocumentDisplayModeHorizontal];
//        [self.displayPopoverController dismissPopoverAnimated:NO];
//    } else if([sender tag] == 2){
//        [self.DocumentViewController setDisplayMode:PlugPDFDocumentDisplayModeVertical];
//        [self.displayPopoverController dismissPopoverAnimated:NO];
//    } else if([sender tag] == 3){
//        [self.displayPopoverController dismissPopoverAnimated:NO];
//    } else if([sender tag] == 22){
//        [self.DocumentViewController setDisplayMode:PlugPDFDocumentDisplayModeThumbnail];
//        [self.displayPopoverController dismissPopoverAnimated:NO];
//    } else if([sender tag] == 4){
//        [self releaseAnnots];
//        [self releaseSubViews];
//        isAnnot = YES;
//        UsingInk = YES;
//        
//        [self.inkBtn setImage:[UIImage imageNamed:@"viewer-icon/pan-icon-01-on.png"] forState:UIControlStateNormal];
//        
//        self.lineView = [[UIView alloc] initWithFrame:CGRectMake(0,55, self.view.frame.size.width, 2)];
//        self.lineView.backgroundColor = [UIColor colorWithRed:0.09 green:(0.20) blue:0.35 alpha:1.00];
//        
//        self.colorLabel = [[UILabel alloc] initWithFrame:CGRectMake(10, 60, 40, 40)];
//        self.colorLabel.text = @"색상";
//        self.colorLabel.textColor = [UIColor whiteColor];
//        
//        self.exampleInkColorView = [[UIView alloc] initWithFrame:CGRectMake(325, 70, 20, 20)];
//        self.exampleInkColorView.backgroundColor = self.exampleInkColor;
//        self.exampleInkColorView.layer.cornerRadius = 10;
//        
//        self.ColorPickerView = [[UIView alloc] initWithFrame:CGRectMake(10, 95, 345, 95)];
//        self.ColorPickerView.backgroundColor = [UIColor whiteColor];
//        self.ColorPickerView.layer.cornerRadius = 3.0f;
//        [self inputColorButton:@"ink"];
//        
//        self.opacityLabel = [[UILabel alloc] initWithFrame:CGRectMake(10, 195, 100, 40)];
//        self.opacityLabel.textColor = [UIColor whiteColor];
//        self.opacityLabel.text = [NSString stringWithFormat:@"투명도 %d%%",inkOpacityValue];
//        
//        self.opacityView = [[UIView alloc] initWithFrame:CGRectMake(10, 240, 345, 50)];
//        self.opacityView.backgroundColor = [UIColor whiteColor];
//        self.opacityView.layer.cornerRadius = 3.0f;
//        
//        self.opacitySlider = [[UISlider alloc] initWithFrame:CGRectMake(5, 5, 335, 40)];
//        [self.opacitySlider addTarget:self action:@selector(getInkOpacity:) forControlEvents:UIControlEventValueChanged];
//        [self.opacitySlider setBackgroundColor:[UIColor clearColor]];
//        self.opacitySlider.minimumValue = 10;
//        self.opacitySlider.maximumValue = 100;
//        self.opacitySlider.continuous = YES;
//        self.opacitySlider.value = inkOpacityValue;
//        [self.opacityView addSubview:self.opacitySlider];
//        
//        self.boldLabel = [[UILabel alloc] initWithFrame:CGRectMake(10, 295, 100, 40)];
//        self.boldLabel.textColor = [UIColor whiteColor];
//        NSString *widthText;
//
//        if(inkBoldValue == 0.5) { widthText = @"굵기 1PX"; }
//        else if(inkBoldValue == 1.0) { widthText = @"굵기 2PX"; }
//        else if(inkBoldValue == 1.5) { widthText = @"굵기 3PX"; }
//        else if(inkBoldValue == 2.0) { widthText = @"굵기 4PX"; }
//        else if(inkBoldValue == 2.5) { widthText = @"굵기 5PX"; }
//        else if(inkBoldValue == 3.0) { widthText = @"굵기 6PX"; }
//        else if(inkBoldValue == 3.5) { widthText = @"굵기 7PX"; }
//        else if(inkBoldValue == 4.0) { widthText = @"굵기 8PX"; }
//        else if(inkBoldValue == 4.5) { widthText = @"굵기 9PX"; }
//        else { widthText = @"굵기 10PX"; }
//        self.boldLabel.text = [NSString stringWithFormat:@"%@",widthText];
//        
//        self.boldView = [[UIView alloc] initWithFrame:CGRectMake(10, 340, 345, 50)];
//        self.boldView.backgroundColor = [UIColor whiteColor];
//        self.boldView.layer.cornerRadius = 3.0f;
//        
//        self.boldSlider = [[UISlider alloc] initWithFrame:CGRectMake(5, 5, 335, 40)];
//        [self.boldSlider addTarget:self action:@selector(getInkBold:) forControlEvents:UIControlEventValueChanged];
//        [self.boldSlider setBackgroundColor:[UIColor clearColor]];
//        self.boldSlider.minimumValue = 0.5;
//        self.boldSlider.maximumValue = 5.0;
//        self.boldSlider.continuous = YES;
//        self.boldSlider.value = inkBoldValue;
//        [self.boldView addSubview:self.boldSlider];
//        
//        [self.inkPopoverView addSubview:self.lineView];
//        [self.inkPopoverView addSubview:self.colorLabel];
//        [self.inkPopoverView addSubview:self.exampleInkColorView];
//        [self.inkPopoverView addSubview:self.ColorPickerView];
//        [self.inkPopoverView addSubview:self.opacityLabel];
//        [self.inkPopoverView addSubview:self.opacityView];
//        [self.inkPopoverView addSubview:self.boldLabel];
//        [self.inkPopoverView addSubview:self.boldView];
//        
//        self.inkPopoverController.popoverContentSize = CGSizeMake(365, 400);
//        [self.inkPopoverController presentPopoverFromRect:CGRectMake(CGRectGetWidth(self.annotPopupView.frame)/2, 40, 0, 0) inView:self.annotPopupView permittedArrowDirections:UIPopoverArrowDirectionUp animated:YES];
//        
//        [self.DocumentViewController setTool:PlugPDFInkTool];
//        
//        CGFloat red;
//        CGFloat green;
//        CGFloat blue;
//        CGFloat alpha = inkOpacityValue*0.01;
//        CGFloat tmpAlpha;
//        [self.exampleInkColor getRed:&red green:&green blue:&blue alpha:&tmpAlpha];
//        [self.DocumentViewController setInkToolLineColor:[UIColor colorWithRed:red green:green blue:blue alpha:alpha]];
//        [self.DocumentViewController setInkToolLineWidth:inkBoldValue];
//    } else if([sender tag] == 5){
//        [self releaseAnnots];
//        [self releaseSubViews];
//        isAnnot = YES;
//        UsingSquare = YES;
//        
//        [self.squareBtn setImage:[UIImage imageNamed:@"viewer-icon/pan-icon-02-on.png"] forState:UIControlStateNormal];
//        
//        self.lineView = [[UIView alloc] initWithFrame:CGRectMake(0,55, self.view.frame.size.width, 2)];
//        self.lineView.backgroundColor = [UIColor colorWithRed:0.09 green:(0.20) blue:0.35 alpha:1.00];
//        
//        self.colorLabel = [[UILabel alloc] initWithFrame:CGRectMake(10, 60, 100, 40)];
//        self.colorLabel.text = @"채우기";
//        self.colorLabel.textColor = [UIColor whiteColor];
//        
//        self.exampleColorView = [[UIView alloc] initWithFrame:CGRectMake(325, 70, 20, 20)];
//        self.exampleColorView.backgroundColor = self.exampleSquareColor;
//        self.exampleColorView.layer.cornerRadius = 10;
//        
//        self.ColorPickerView = [[UIView alloc] initWithFrame:CGRectMake(10, 95, 345, 95)];
//        self.ColorPickerView.backgroundColor = [UIColor whiteColor];
//        self.ColorPickerView.layer.cornerRadius = 3.0f;
//        [self inputColorButton:@"square"];
//        
//        self.squareColorLabel = [[UILabel alloc] initWithFrame:CGRectMake(10, 195, 100, 40)];
//        self.squareColorLabel.text = @"선 색상";
//        self.squareColorLabel.textColor = [UIColor whiteColor];
//        
//        self.exampleSquareCornerColorView = [[UIView alloc] initWithFrame:CGRectMake(325, 205, 20, 20)];
//        self.exampleSquareCornerColorView.backgroundColor = self.exampleSquareCornerColor;
//        self.exampleSquareCornerColorView.layer.cornerRadius = 10;
//        
//        self.squareColorPickerView = [[UIView alloc] initWithFrame:CGRectMake(10, 230, 345, 95)];
//        self.squareColorPickerView.backgroundColor = [UIColor whiteColor];
//        self.squareColorPickerView.layer.cornerRadius = 3.0f;
//        [self inputColorButton:@"squareCorner"];
//        
//        self.boldLabel = [[UILabel alloc] initWithFrame:CGRectMake(10, 330, 100, 40)];
//        self.boldLabel.textColor = [UIColor whiteColor];
//        self.boldLabel.text = [NSString stringWithFormat:@"선 굵기 %dPX",squareBoldValue];
//        
//        self.boldView = [[UIView alloc] initWithFrame:CGRectMake(10, 375, 345, 50)];
//        self.boldView.backgroundColor = [UIColor whiteColor];
//        self.boldView.layer.cornerRadius = 3.0f;
//        
//        self.boldSlider = [[UISlider alloc] initWithFrame:CGRectMake(5, 5, 335, 40)];
//        [self.boldSlider addTarget:self action:@selector(getSquareBold:) forControlEvents:UIControlEventValueChanged];
//        [self.boldSlider setBackgroundColor:[UIColor clearColor]];
//        self.boldSlider.minimumValue = 1;
//        self.boldSlider.maximumValue = 40;
//        self.boldSlider.continuous = YES;
//        self.boldSlider.value = squareBoldValue;
//        [self.boldView addSubview:self.boldSlider];
//        
//        [self.inkPopoverView addSubview:self.lineView];
//        [self.inkPopoverView addSubview:self.colorLabel];
//        [self.inkPopoverView addSubview:self.ColorPickerView];
//        [self.inkPopoverView addSubview:self.exampleColorView];
//        [self.inkPopoverView addSubview:self.squareColorLabel];
//        [self.inkPopoverView addSubview:self.squareColorPickerView];
//        [self.inkPopoverView addSubview:self.exampleSquareCornerColorView];
//        [self.inkPopoverView addSubview:self.boldLabel];
//        [self.inkPopoverView addSubview:self.boldView];
//        
//        self.inkPopoverController.popoverContentSize = CGSizeMake(365, 435);
//        [self.inkPopoverController presentPopoverFromRect:CGRectMake(CGRectGetWidth(self.annotPopupView.frame)/2, 30, 0, 0) inView:self.annotPopupView permittedArrowDirections:UIPopoverArrowDirectionUp animated:YES];
//        [self.DocumentViewController setTool:PlugPDFSquareTool];
//        [self.DocumentViewController setSquareAnnotwidth:squareBoldValue];
//    } else if([sender tag] == 6){
//        [self releaseAnnots];
//        [self releaseSubViews];
//        isAnnot = YES;
//        UsingCircle = YES;
//        
//        [self.circleBtn setImage:[UIImage imageNamed:@"viewer-icon/pan-icon-03-on.png"] forState:UIControlStateNormal];
//        
//        self.lineView = [[UIView alloc] initWithFrame:CGRectMake(0,55, self.view.frame.size.width, 2)];
//        self.lineView.backgroundColor = [UIColor colorWithRed:0.09 green:(0.20) blue:0.35 alpha:1.00];
//        
//        self.colorLabel = [[UILabel alloc] initWithFrame:CGRectMake(10, 60, 100, 40)];
//        self.colorLabel.text = @"채우기";
//        self.colorLabel.textColor = [UIColor whiteColor];
//        
//        self.exampleColorView = [[UIView alloc] initWithFrame:CGRectMake(325, 70, 20, 20)];
//        self.exampleColorView.backgroundColor = self.exampleCircleColor;
//        self.exampleColorView.layer.cornerRadius = 10;
//        
//        self.ColorPickerView = [[UIView alloc] initWithFrame:CGRectMake(10, 95, 345, 95)];
//        self.ColorPickerView.backgroundColor = [UIColor whiteColor];
//        self.ColorPickerView.layer.cornerRadius = 3.0f;
//        [self inputColorButton:@"circle"];
//        
//        self.circleColorLabel = [[UILabel alloc] initWithFrame:CGRectMake(10, 195, 100, 40)];
//        self.circleColorLabel.text = @"선 색상";
//        self.circleColorLabel.textColor = [UIColor whiteColor];
//        
//        self.exampleCircleCornerColorView = [[UIView alloc] initWithFrame:CGRectMake(325, 205, 20, 20)];
//        self.exampleCircleCornerColorView.backgroundColor = self.exampleCircleCornerColor;
//        self.exampleCircleCornerColorView.layer.cornerRadius = 10;
//        
//        self.circleColorPickerView = [[UIView alloc] initWithFrame:CGRectMake(10, 230, 345, 95)];
//        self.circleColorPickerView.backgroundColor = [UIColor whiteColor];
//        self.circleColorPickerView.layer.cornerRadius = 3.0f;
//        [self inputColorButton:@"circleCorner"];
//        
//        self.boldLabel = [[UILabel alloc] initWithFrame:CGRectMake(10, 330, 100, 40)];
//        self.boldLabel.textColor = [UIColor whiteColor];
//        self.boldLabel.text = [NSString stringWithFormat:@"선 굵기 %dPX",circleBoldValue];
//        
//        self.boldView = [[UIView alloc] initWithFrame:CGRectMake(10, 375, 345, 50)];
//        self.boldView.backgroundColor = [UIColor whiteColor];
//        self.boldView.layer.cornerRadius = 3.0f;
//        
//        self.boldSlider = [[UISlider alloc] initWithFrame:CGRectMake(5, 5, 335, 40)];
//        [self.boldSlider addTarget:self action:@selector(getCircleBold:) forControlEvents:UIControlEventValueChanged];
//        [self.boldSlider setBackgroundColor:[UIColor clearColor]];
//        self.boldSlider.minimumValue = 1;
//        self.boldSlider.maximumValue = 40;
//        self.boldSlider.continuous = YES;
//        self.boldSlider.value = circleBoldValue;
//        [self.boldView addSubview:self.boldSlider];
//        
//        [self.inkPopoverView addSubview:self.lineView];
//        [self.inkPopoverView addSubview:self.colorLabel];
//        [self.inkPopoverView addSubview:self.ColorPickerView];
//        [self.inkPopoverView addSubview:self.exampleColorView];
//        [self.inkPopoverView addSubview:self.circleColorLabel];
//        [self.inkPopoverView addSubview:self.circleColorPickerView];
//        [self.inkPopoverView addSubview:self.exampleCircleCornerColorView];
//        [self.inkPopoverView addSubview:self.boldLabel];
//        [self.inkPopoverView addSubview:self.boldView];
//        
//        self.inkPopoverController.popoverContentSize = CGSizeMake(365, 435);
//        [self.inkPopoverController presentPopoverFromRect:CGRectMake(CGRectGetWidth(self.annotPopupView.frame)/2, 30, 0, 0) inView:self.annotPopupView permittedArrowDirections:UIPopoverArrowDirectionUp animated:YES];
//        [self.DocumentViewController setTool:PlugPDFCircleTool];
//        [self.DocumentViewController setCircleAnnotwidth:circleBoldValue];
//    } else if([sender tag] == 7){
//        [self releaseAnnots];
//        [self releaseSubViews];
//        isAnnot = YES;
//        UsingHighlight = YES;
//        
//        [self.highlightBtn setImage:[UIImage imageNamed:@"viewer-icon/pan-icon-04-on.png"] forState:UIControlStateNormal];
//        
//        self.lineView = [[UIView alloc] initWithFrame:CGRectMake(0,55, self.view.frame.size.width, 2)];
//        self.lineView.backgroundColor = [UIColor colorWithRed:0.09 green:(0.20) blue:0.35 alpha:1.00];
//        
//        self.colorLabel = [[UILabel alloc] initWithFrame:CGRectMake(10, 60, 40, 40)];
//        self.colorLabel.text = @"색상";
//        self.colorLabel.textColor = [UIColor whiteColor];
//        
//        self.exampleHighlightColorView = [[UIView alloc] initWithFrame:CGRectMake(325, 70, 20, 20)];
//        self.exampleHighlightColorView.backgroundColor = self.exampleHighlightColor;
//        self.exampleHighlightColorView.layer.cornerRadius = 10;
//        
//        self.ColorPickerView = [[UIView alloc] initWithFrame:CGRectMake(10, 95, 345, 95)];
//        self.ColorPickerView.backgroundColor = [UIColor whiteColor];
//        self.ColorPickerView.layer.cornerRadius = 3.0f;
//        [self inputColorButton:@"highlight"];
//        
//        self.opacityLabel = [[UILabel alloc] initWithFrame:CGRectMake(10, 195, 100, 40)];
//        self.opacityLabel.textColor = [UIColor whiteColor];
//        self.opacityLabel.text = [NSString stringWithFormat:@"투명도 %d%%",highlightOpacityValue];
//        
//        self.opacityView = [[UIView alloc] initWithFrame:CGRectMake(10, 240, 345, 50)];
//        self.opacityView.backgroundColor = [UIColor whiteColor];
//        self.opacityView.layer.cornerRadius = 3.0f;
//        
//        self.opacitySlider = [[UISlider alloc] initWithFrame:CGRectMake(5, 5, 335, 40)];
//        [self.opacitySlider addTarget:self action:@selector(getHighlightOpacity:) forControlEvents:UIControlEventValueChanged];
//        [self.opacitySlider setBackgroundColor:[UIColor clearColor]];
//        self.opacitySlider.minimumValue = 10;
//        self.opacitySlider.maximumValue = 100;
//        self.opacitySlider.continuous = YES;
//        self.opacitySlider.value = highlightOpacityValue;
//        [self.opacityView addSubview:self.opacitySlider];
//        
//        [self.inkPopoverView addSubview:self.lineView];
//        [self.inkPopoverView addSubview:self.colorLabel];
//        [self.inkPopoverView addSubview:self.exampleHighlightColorView];
//        [self.inkPopoverView addSubview:self.ColorPickerView];
//        [self.inkPopoverView addSubview:self.opacityLabel];
//        [self.inkPopoverView addSubview:self.opacityView];
//        
//        self.inkPopoverController.popoverContentSize = CGSizeMake(365, 300);
//        [self.inkPopoverController presentPopoverFromRect:CGRectMake(CGRectGetWidth(self.annotPopupView.frame)/2, 30, 0, 0) inView:self.annotPopupView permittedArrowDirections:UIPopoverArrowDirectionUp animated:YES];
//        [self.DocumentViewController setTool:PlugPDFTextHighlightTool];
//    } else if([sender tag] == 8){
//        [self releaseAnnots];
//        [self releaseSubViews];
//        isAnnot = YES;
//        UsingUnderline = YES;
//        
//        [self.underlineBtn setImage:[UIImage imageNamed:@"viewer-icon/pan-icon-05-on.png"] forState:UIControlStateNormal];
//        
//        self.lineView = [[UIView alloc] initWithFrame:CGRectMake(0,55, self.view.frame.size.width, 2)];
//        self.lineView.backgroundColor = [UIColor colorWithRed:0.09 green:(0.20) blue:0.35 alpha:1.00];
//        
//        self.colorLabel = [[UILabel alloc] initWithFrame:CGRectMake(10, 60, 40, 40)];
//        self.colorLabel.text = @"색상";
//        self.colorLabel.textColor = [UIColor whiteColor];
//        
//        self.exampleUnderlineColorView = [[UIView alloc] initWithFrame:CGRectMake(325, 70, 20, 20)];
//        self.exampleUnderlineColorView.backgroundColor = self.exampleUnderlineColor;
//        self.exampleUnderlineColorView.layer.cornerRadius = 10;
//        
//        self.ColorPickerView = [[UIView alloc] initWithFrame:CGRectMake(10, 95, 345, 95)];
//        self.ColorPickerView.backgroundColor = [UIColor whiteColor];
//        self.ColorPickerView.layer.cornerRadius = 3.0f;
//        [self inputColorButton:@"underline"];
//        
//        self.underLineLabel = [[UILabel alloc] initWithFrame:CGRectMake(10, 195, 100, 40)];
//        self.underLineLabel.textColor = [UIColor whiteColor];
//        self.underLineLabel.text = [NSString stringWithFormat:@"물결 무늬"];
//        
//        self.underLineView = [[UIView alloc] initWithFrame:CGRectMake(10, 240, 345, 50)];
//        self.underLineView.backgroundColor = [UIColor whiteColor];
//        self.underLineView.layer.cornerRadius = 3.0f;
//        
//        self.underLineUseLabel = [[UILabel alloc] initWithFrame:CGRectMake(10, 10, 100, 30)];
//        if(useUnderline == 0){
//            self.underLineUseLabel.textColor = [UIColor colorWithRed:0.89 green:0.89 blue:0.89 alpha:1.00];
//            self.underLineUseLabel.text = [NSString stringWithFormat:@"사용 안함"];
//        } else if(useUnderline == 1){
//            self.underLineUseLabel.textColor = [UIColor colorWithRed:0.08 green:0.46 blue:0.98 alpha:1.00];
//            self.underLineUseLabel.text = [NSString stringWithFormat:@"사용"];
//        }
//        
//        self.underLineSwitch = [[UISwitch alloc] initWithFrame:CGRectMake(275, 10, 60, 30)];
//        if(useUnderline == 0){
//            [self.underLineSwitch setOn:NO];
//        } else if(useUnderline == 1){
//            [self.underLineSwitch setOn:YES];
//        }
//        [self.underLineSwitch addTarget: self action: @selector(getUnderLineSwitch:) forControlEvents:UIControlEventValueChanged];
//        
//        [self.underLineView addSubview:self.underLineUseLabel];
//        [self.underLineView addSubview:self.underLineSwitch];
//        
//        [self.inkPopoverView addSubview:self.lineView];
//        [self.inkPopoverView addSubview:self.colorLabel];
//        [self.inkPopoverView addSubview:self.exampleUnderlineColorView];
//        [self.inkPopoverView addSubview:self.ColorPickerView];
//        [self.inkPopoverView addSubview:self.underLineLabel];
//        [self.inkPopoverView addSubview:self.underLineView];
//        
//        self.inkPopoverController.popoverContentSize = CGSizeMake(365, 300);
//        [self.inkPopoverController presentPopoverFromRect:CGRectMake(CGRectGetWidth(self.annotPopupView.frame)/2, 30, 0, 0) inView:self.annotPopupView permittedArrowDirections:UIPopoverArrowDirectionUp animated:YES];
//        [self.DocumentViewController setTool:PlugPDFTextUnderlineTool];
//    } else if([sender tag] == 9){
//        [self releaseAnnots];
//        [self releaseSubViews];
//        isAnnot = YES;
//        UsingCancle = YES;
//        
//        [self.cancleBtn setImage:[UIImage imageNamed:@"viewer-icon/pan-icon-06-on.png"] forState:UIControlStateNormal];
//        
//        self.lineView = [[UIView alloc] initWithFrame:CGRectMake(0,55, self.view.frame.size.width, 2)];
//        self.lineView.backgroundColor = [UIColor colorWithRed:0.09 green:(0.20) blue:0.35 alpha:1.00];
//        
//        self.colorLabel = [[UILabel alloc] initWithFrame:CGRectMake(10, 60, 40, 40)];
//        self.colorLabel.text = @"색상";
//        self.colorLabel.textColor = [UIColor whiteColor];
//        
//        self.exampleCanclelineColorView = [[UIView alloc] initWithFrame:CGRectMake(325, 70, 20, 20)];
//        self.exampleCanclelineColorView.backgroundColor = self.exampleCanclelineColor;
//        self.exampleCanclelineColorView.layer.cornerRadius = 10;
//        
//        self.ColorPickerView = [[UIView alloc] initWithFrame:CGRectMake(10, 95, 345, 95)];
//        self.ColorPickerView.backgroundColor = [UIColor whiteColor];
//        self.ColorPickerView.layer.cornerRadius = 3.0f;
//        [self inputColorButton:@"cancleline"];
//        
//        [self.inkPopoverView addSubview:self.lineView];
//        [self.inkPopoverView addSubview:self.colorLabel];
//        [self.inkPopoverView addSubview:self.exampleCanclelineColorView];
//        [self.inkPopoverView addSubview:self.ColorPickerView];
//        
//        self.inkPopoverController.popoverContentSize = CGSizeMake(365, 200);
//        [self.inkPopoverController presentPopoverFromRect:CGRectMake(CGRectGetWidth(self.annotPopupView.frame)/2, 30, 0, 0) inView:self.annotPopupView permittedArrowDirections:UIPopoverArrowDirectionUp animated:YES];
//        
//        [self.DocumentViewController setTool:PlugPDFTextStrikeoutTool];
//    } else if([sender tag] == 10){
//        [self releaseAnnots];
//        [self releaseSubViews];
//        isAnnot = YES;
//        UsingNote = YES;
//        
//        [self.noteBtn setImage:[UIImage imageNamed:@"viewer-icon/pan-icon-07-on.png"] forState:UIControlStateNormal];
//        
//        
//        
//        
//        
//        
//        
//        
//        self.inkPopoverController.popoverContentSize = CGSizeMake(365, 50);
//        [self.inkPopoverController presentPopoverFromRect:CGRectMake(CGRectGetWidth(self.annotPopupView.frame)/2, 30, 0, 0) inView:self.annotPopupView permittedArrowDirections:UIPopoverArrowDirectionUp animated:YES];
//        [self.DocumentViewController setTool:PlugPDFNoteTool];
//    } else if([sender tag] == 11){
//        [self releaseAnnots];
//        [self releaseSubViews];
//        isAnnot = YES;
//        UsingEraser = YES;
//        
//        self.lineView = [[UIView alloc] initWithFrame:CGRectMake(0,55, self.view.frame.size.width, 2)];
//        self.lineView.backgroundColor = [UIColor colorWithRed:0.09 green:(0.20) blue:0.35 alpha:1.00];
//        
//        self.defaultEraserBtn = [[UIButton alloc] initWithFrame: CGRectMake(255, 65, 30, 30)];
//        [self.defaultEraserBtn setImage:[UIImage imageNamed:@"viewer-icon/pan-icon-08-01.png"] forState:UIControlStateNormal];
//        [self.defaultEraserBtn addTarget: self action: @selector(openPlugPDF3:) forControlEvents: UIControlEventTouchUpInside];
//        self.defaultEraserBtn.tag = 26;
//        
//        self.blockEraserBtn = [[UIButton alloc] initWithFrame: CGRectMake(290, 65, 30, 30)];
//        [self.blockEraserBtn setImage:[UIImage imageNamed:@"viewer-icon/pan-icon-08-02.png"] forState:UIControlStateNormal];
//        [self.blockEraserBtn addTarget: self action: @selector(openPlugPDF3:) forControlEvents: UIControlEventTouchUpInside];
//        self.blockEraserBtn.tag = 27;
//        
//        self.allEraserBtn = [[UIButton alloc] initWithFrame: CGRectMake(325, 65, 30, 30)];
//        [self.allEraserBtn setImage:[UIImage imageNamed:@"viewer-icon/pan-icon-08-03.png"] forState:UIControlStateNormal];
//        [self.allEraserBtn addTarget: self action: @selector(openPlugPDF3:) forControlEvents: UIControlEventTouchUpInside];
//        self.allEraserBtn.tag = 28;
//        
//        [self.eraserBtn setImage:[UIImage imageNamed:@"viewer-icon/pan-icon-08-on.png"] forState:UIControlStateNormal];
//        
//        [self.inkPopoverView addSubview:self.lineView];
//        [self.inkPopoverView addSubview:self.defaultEraserBtn];
//        [self.inkPopoverView addSubview:self.blockEraserBtn];
//        [self.inkPopoverView addSubview:self.allEraserBtn];
//        
//        self.inkPopoverController.popoverContentSize = CGSizeMake(365, 105);
//        [self.inkPopoverController presentPopoverFromRect:CGRectMake(CGRectGetWidth(self.annotPopupView.frame)/2, 30, 0, 0) inView:self.annotPopupView permittedArrowDirections:UIPopoverArrowDirectionUp animated:YES];
//        if(eraserMode == 1){
//            [self.defaultEraserBtn sendActionsForControlEvents:UIControlEventTouchUpInside];
//        } else if (eraserMode == 2) {
//            [self.blockEraserBtn sendActionsForControlEvents:UIControlEventTouchUpInside];
//        }
//    } else if([sender tag] == 12){
//        if(self.DocumentViewController.pageIdx-1 >= 0){
//            [self.DocumentViewController gotoPage:self.DocumentViewController.pageIdx-1 fitToScreen:YES];
//            self.pageSlider.value = self.pageSlider.value-1;
//        }
//        
//        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.1 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
//        [self.DocumentViewController releaseTools];
//        if(UsingInk == YES){ [self.DocumentViewController setTool:PlugPDFInkTool]; }
//        else if(UsingSquare == YES){ [self.DocumentViewController setTool:PlugPDFSquareTool]; }
//        else if(UsingCircle == YES){ [self.DocumentViewController setTool:PlugPDFCircleTool]; }
//        else if(UsingHighlight == YES){ [self.DocumentViewController setTool:PlugPDFTextHighlightTool]; }
//        else if(UsingUnderline == YES){ [self.DocumentViewController setTool:PlugPDFTextUnderlineTool]; }
//        else if(UsingCancle == YES){ [self.DocumentViewController setTool:PlugPDFTextStrikeoutTool]; }
//        else if(UsingNote == YES){ [self.DocumentViewController setTool:PlugPDFNoteTool]; }
//        else if(UsingEraser == YES){ [self.DocumentViewController setTool:PlugPDFEraserTool]; }
//        });
//    } else if([sender tag] == 13){
//        if(self.DocumentViewController.pageIdx+1 < self.DocumentViewController.pageCount){
//            [self.DocumentViewController gotoPage:self.DocumentViewController.pageIdx+1 fitToScreen:YES];
//            self.pageSlider.value = self.pageSlider.value+1;
//        }
//        
//        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.1 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
//            [self.DocumentViewController releaseTools];
//            if(UsingInk == YES){ [self.DocumentViewController setTool:PlugPDFInkTool]; }
//            else if(UsingSquare == YES){ [self.DocumentViewController setTool:PlugPDFSquareTool]; }
//            else if(UsingCircle == YES){ [self.DocumentViewController setTool:PlugPDFCircleTool]; }
//            else if(UsingHighlight == YES){ [self.DocumentViewController setTool:PlugPDFTextHighlightTool]; }
//            else if(UsingUnderline == YES){ [self.DocumentViewController setTool:PlugPDFTextUnderlineTool]; }
//            else if(UsingCancle == YES){ [self.DocumentViewController setTool:PlugPDFTextStrikeoutTool]; }
//            else if(UsingNote == YES){ [self.DocumentViewController setTool:PlugPDFNoteTool]; }
//            else if(UsingEraser == YES){ [self.DocumentViewController setTool:PlugPDFEraserTool]; }
//        });
//
//    } else if([sender tag] == 26){
//        [self.defaultEraserBtn setImage:[UIImage imageNamed:@"viewer-icon/pan-icon-08-01-on.png"] forState:UIControlStateNormal];
//        [self.blockEraserBtn setImage:[UIImage imageNamed:@"viewer-icon/pan-icon-08-02.png"] forState:UIControlStateNormal];
//        [self.DocumentViewController releaseTools];
//        [self.DocumentViewController setEraserType:PlugPDFDocumentEraserTypeClickWithDrag];
//        [self.DocumentViewController setTool:PlugPDFEraserTool];
//        eraserMode = 1;
//    } else if([sender tag] == 27){
//        [self.blockEraserBtn setImage:[UIImage imageNamed:@"viewer-icon/pan-icon-08-02-on.png"] forState:UIControlStateNormal];
//        [self.defaultEraserBtn setImage:[UIImage imageNamed:@"viewer-icon/pan-icon-08-01.png"] forState:UIControlStateNormal];
//        [self.DocumentViewController releaseTools];
//        [self.DocumentViewController setEraserType:PlugPDFDocumentEraserTypeSelectedArea];
//        [self.DocumentViewController setTool:PlugPDFEraserTool];
//        eraserMode = 2;
//    } else if([sender tag] == 28){
//        [self.DocumentViewController removePageAnnot];
//        [self.inkPopoverController dismissPopoverAnimated:NO];
//        
//    }
//}
//
//- (void)dealloc {
//    [_testview release];
//    [super dealloc];
//}
//
//
//- (void)registerDeviceOrientationNotification
//{
//    // 화면 회전 노티 등록
//    [[UIDevice currentDevice] beginGeneratingDeviceOrientationNotifications];
//    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(orientationChanged:)name:UIDeviceOrientationDidChangeNotification object:nil];
//
//    // 뷰 리로드 노티 등록
//    NSNotificationCenter *sendNotification = [NSNotificationCenter defaultCenter];
//    [sendNotification addObserver:self selector:@selector(firstMethod:) name:@"firstNotification" object: nil];
//}
//
//// 스플릿 뷰어 이벤트 처리
//- (void)firstMethod:(NSNotification *)notification {
//    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.1 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
//        UIWindow* window = [UIApplication sharedApplication].keyWindow;
//        self.view.frame = window.frame;
//        [self.navbar setFrame:CGRectMake(0, 0, CGRectGetWidth(window.bounds), 60)];
//        [self.searchBar setFrame:CGRectMake(60, 20, CGRectGetWidth(window.bounds) - 150, 40)];
//        [self.beforePageView setFrame:CGRectMake(CGRectGetWidth(window.bounds) - 100, CGRectGetHeight(window.bounds) - 100, 40, 40)];
//        [self.nextPageView setFrame:CGRectMake(CGRectGetWidth(window.bounds) - 50, CGRectGetHeight(window.bounds) - 100, 40, 40)];
//        [self.displayBtnView setFrame: CGRectMake(CGRectGetWidth(self.view.frame)-45, 25, 30, 30)];
//        [self.DocumentViewController refreshView];
//        
//        
//        CGSize documentSize = [self.DocumentViewController.documentView.document pageSize:0];
//        CGFloat documentHeight = documentSize.height;
//        CGFloat documentWidth = documentSize.width;
//        CGFloat windowHeight = CGRectGetHeight(self.view.frame);
//        CGFloat windowWidth = CGRectGetWidth(self.view.frame);
//        CGFloat plusHeight;
//        CGFloat plusWidth;
//        if(documentHeight > documentWidth){
//            plusHeight = windowHeight - documentHeight;
//            plusWidth = documentWidth + plusHeight;
//            [self.DocumentViewController setPagePreviewSize:CGSizeMake(plusWidth, windowHeight)];
//        } else {
//            plusWidth = windowWidth - documentWidth;
//            plusHeight = documentHeight + plusWidth;
//            [self.DocumentViewController setPagePreviewSize:CGSizeMake(windowWidth, plusHeight)];
//        }
//    });
//    
//    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.5 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
//        [self.DocumentViewController setEnableBottomBar:YES];
//        [self.DocumentViewController setNavigationToolBarHidden:NO];
//        [self.DocumentViewController setEnableBottomBar:NO];
//    });
//}
//
//// 화면 가로/세로 전환 이벤트 처리
//- (void) orientationChanged:(NSNotification *)notification
//{
//    AppDelegate *AD = [[UIApplication sharedApplication] delegate];
//    [AD application:[UIApplication sharedApplication] supportedInterfaceOrientationsForWindow:self.window];
//    UIDeviceOrientation orientation = [[UIDevice currentDevice] orientation];
//    NSLog(@"orientationChanged:%d", (int)orientation);
//    
//    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.1 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
//        UIWindow* window = [UIApplication sharedApplication].keyWindow;
//        self.view.frame = window.frame;
//        self.DocumentViewController.view.frame = window.frame;
//        [self.navbar setFrame:CGRectMake(0, 0, CGRectGetWidth(window.bounds), 60)];
//        [self.searchBar setFrame:CGRectMake(60, 20, CGRectGetWidth(window.bounds) - 150, 40)];
//        [self.beforePageView setFrame:CGRectMake(CGRectGetWidth(window.bounds) - 100, CGRectGetHeight(window.bounds) - 100, 40, 40)];
//        [self.nextPageView setFrame:CGRectMake(CGRectGetWidth(window.bounds) - 50, CGRectGetHeight(window.bounds) - 100, 40, 40)];
//        [self.displayBtnView setFrame: CGRectMake(CGRectGetWidth(self.view.frame)-45, 25, 30, 30)];
////        if((int)orientation == 3 || (int)orientation == 4){
////            [self.DocumentViewController setPagePreviewSize:[self.DocumentViewController.documentView.document pageSize:0]];
////        } else if ((int)orientation == 1 || (int)orientation == 2){
////            [self.DocumentViewController setPagePreviewSize:[self.DocumentViewController.documentView.document pageSize:0]];
////        }
//        [self.DocumentViewController setEnableBottomBar:YES];
//        [self.DocumentViewController setNavigationToolBarHidden:NO];
//        [self.DocumentViewController setEnableBottomBar:NO];
//        
//        CGSize documentSize = [self.DocumentViewController.documentView.document pageSize:0];
//        CGFloat documentHeight = documentSize.height;
//        CGFloat documentWidth = documentSize.width;
//        CGFloat windowHeight = CGRectGetHeight(self.view.frame);
//        CGFloat windowWidth = CGRectGetWidth(self.view.frame);
//        CGFloat plusHeight;
//        CGFloat plusWidth;
//        if(documentHeight > documentWidth){
//            plusHeight = windowHeight - documentHeight;
//            plusWidth = documentWidth + plusHeight;
//            [self.DocumentViewController setPagePreviewSize:CGSizeMake(plusWidth, windowHeight)];
//        } else {
//            plusWidth = windowWidth - documentWidth;
//            plusHeight = documentHeight + plusWidth;
//            [self.DocumentViewController setPagePreviewSize:CGSizeMake(windowWidth, plusHeight)];
//        }
//    });
//    
//    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.5 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
//        [self.DocumentViewController setEnableBottomBar:YES];
//        [self.DocumentViewController setNavigationToolBarHidden:NO];
//        [self.DocumentViewController setEnableBottomBar:NO];
//    });
//}
//
//#pragma mark - UITableViewDataSource
//// number of section(s), now I assume there is only 1 section
//- (NSInteger)numberOfSectionsInTableView:(UITableView *)theTableView
//{
//    return numberOfSection;
//}
//
//// number of row in the section, I assume there is only 1 row
//- (NSInteger)tableView:(UITableView *)theTableView numberOfRowsInSection:(NSInteger)section
//{
//    //if the current view is in editing mode
//    //add an extra row
//    int addRow = [self isEditing] ? 1 : 0;
//    return self.tabledata.count + addRow;
//    //    return 1;
//}
//
//#pragma mark - UITableViewDelegate
//// when user tap the row, what action you want to perform
//- (void)tableView:(UITableView *)theTableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
//{
//    //deselect the selected row with animatiion
//    [self.BMtableView deselectRowAtIndexPath:indexPath animated:YES];
//    
//    //if the selected  row was the "Add Row" row call tableView:commitEditingStyle:
//    //to add a new row
//    if (indexPath.row >= self.tabledata.count && [self isEditing]) {
//        [self tableView:self.BMtableView commitEditingStyle:UITableViewCellEditingStyleInsert forRowAtIndexPath:indexPath];
//    }
//    
//    UITableViewCell *cell = [self.BMtableView cellForRowAtIndexPath:indexPath];
//    NSLog(@"BookMark Page : %@", cell.detailTextLabel.text);
//    NSInteger getPage = [cell.detailTextLabel.text intValue];
//    [self.DocumentViewController gotoPage:getPage-1 fitToScreen:YES];
//}
//
//-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
//{
//    //    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"cell"];
//    //    if(cell == nil){
//    //        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"cell"];
//    //    }
//    
//    NSString *CellIdentifier = @"Cell";
//    BOOL b_addCell = (indexPath.row == self.tabledata.count);
//    if (b_addCell) // set identifier for add row
//    CellIdentifier = @"AddCell";
//    
//    UITableViewCell *cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleValue1
//                                                    reuseIdentifier:CellIdentifier] autorelease];
//    
//    //    if (cell == nil) {
//    //        cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier] autorelease];
//    //        if (!b_addCell) {
//    //            cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
//    //        }
//    //    }
//    
//    //if number of rows is greater than the total number of rows in the data set
//    //and this view is in editing mode.
//    //Initialize the cell for "Add Row"
//    //there will be an extra row once SetEditing: is called
//    NSLog(@"indexPath2.row = %ld", (long)indexPath.row);
//    if(indexPath.row == 0 && [self isEditing]){
//        cell.textLabel.text = @"북마크 리스트 제목00";
//        cell.detailTextLabel.text = [self.pagedata[indexPath.row] stringValue];
//    }else{
//        cell.textLabel.text = self.tabledata[indexPath.row];
//        cell.detailTextLabel.text = [self.pagedata[indexPath.row] stringValue];
//    }
//    
//    return cell;
//}
//
//- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
//{
//    return 35;
//}
//
//-(void) setEditing:(BOOL)editing animated:(BOOL)animated{
//    //call parent
//    editing = YES;
//    animated = YES;
//    [super setEditing:editing animated:animated];
//    if(isSwipeDeleting == NO){
//        NSLog(@"1");
//        //.. our existing code here
//    }else {
//        NSLog(@"2");
//    }
//    
//    //if editing mode
//    if(editing){
//        //batch the table view changes so that everything happens at once
//        [self.BMtableView beginUpdates];
//        //for each section, insert a row at the end of the table
//        for(int i = 0; i < numberOfSection; i++){
//            //create an index path for the new row
//            NSIndexPath *path = [NSIndexPath indexPathForRow:self.tabledata.count inSection:i];
//            //insert the NSIndexPath to create a new row. NOTE: this method takes an array of paths
//            [self.BMtableView insertRowsAtIndexPaths:@[path] withRowAnimation:UITableViewRowAnimationAutomatic];
//        }
//        //animate the changes now
//        [self.BMtableView endUpdates];
//    }else{
//        //batch the table view changes so that everything happens at once
//        [self.BMtableView beginUpdates];
//        //for each section, insert a row at the end of the table
//        for(int i = 0; i < numberOfSection; i++){
//            //create an index path for the new row
//            NSIndexPath *path = [NSIndexPath indexPathForRow:self.tabledata.count inSection:i];
//            //insert the NSIndexPath to create a new row. NOTE: this method takes an array of paths
//            [self.BMtableView deleteRowsAtIndexPaths:@[path] withRowAnimation:UITableViewRowAnimationAutomatic];
//        }
//        
//        //animate the changes now
//        [self.BMtableView endUpdates];
//    }
//}
//
//
//-(UITableViewCellEditingStyle) tableView:(UITableView *)tableView editingStyleForRowAtIndexPath:(NSIndexPath *)indexPath{
//    if(EditMode == 1) {
//        return UITableViewCellEditingStyleInsert;
//    } else if(EditMode == 2) {
//        return UITableViewCellEditingStyleDelete;
//    } else if(EditMode == 3) {
//        return UITableViewCellEditingStyleNone;
//    }
//}
//
//
//- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
//    
//    NSString *appendCellName = [@(indexPath.row+1) stringValue];
//    NSString *defaultCellName = nil;
//    NSString *CellName = nil;
//    NSIndexPath *myIP = [NSIndexPath indexPathForRow:indexPath.row+1 inSection:indexPath.section] ;
//    
//    if (editingStyle == UITableViewCellEditingStyleDelete) {
//        //remove row from datasource
//        [self.tabledata removeObjectAtIndex:indexPath.row];
//        //remove the row in the tableView because the deleteIcon was clicked
//        [self.BMtableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationAutomatic];
//    }
//    else if (editingStyle == UITableViewCellEditingStyleInsert) {
//        if(indexPath.row < 10){
//            defaultCellName = @"북마크 리스트 제목0";
//            CellName = [NSString stringWithFormat:@"%@%@",defaultCellName,appendCellName];
//        } else {
//            defaultCellName = @"북마크 리스트 제목";
//            CellName = [NSString stringWithFormat:@"%@%@",defaultCellName,appendCellName];
//        }
//        //add a new row to the datasource
//        [self.tabledata insertObject:CellName atIndex:indexPath.row+1];
//        NSString *currentPage = [@(self.DocumentViewController.pageIdx+1) stringValue];
//        [self.pagedata insertObject:currentPage atIndex:indexPath.row+1];
//        //insert a row in the tableView because the plusIcon was clicked.
//        [self.BMtableView insertRowsAtIndexPaths:@[myIP]
//                                withRowAnimation:UITableViewRowAnimationAutomatic];
//    }
//    //셀 추가 시 가장 마지막으로 스크롤 이동 (화면 깜빡이는 버그 있음)
//    //    [self.BMtableView setContentOffset:CGPointMake(0.0, self.BMtableView.contentSize.height - self.BMtableView.rowHeight)];
//}
//
//- (BOOL)shouldPerformSegueWithIdentifier:(NSString *)identifier sender:(id)sender {
//    if ([identifier isEqualToString:@"MyDetailView"] && [self isEditing]) {
//        return NO;
//    }
//    return YES;
//}
//
//
////this method is called when the user swipes to delete a row.
//- (void)tableView:(UITableView *)tableView willBeginEditingRowAtIndexPath:(NSIndexPath *)indexPath{
//    isSwipeDeleting = YES;//user just swipe to delete a row
//}
////when the user cancel the swipe or click the delete button
////this method is call
//- (void)tableView:(UITableView *)tableView didEndEditingRowAtIndexPath:(NSIndexPath *)indexPath{
//    isSwipeDeleting = NO;//swipe to delete ended. No longer showing the DELETE button in cell
//}
//
//-(void)inputColorButton:(NSString*)buttonType {
//    if(![buttonType isEqualToString:@"squareCorner"] && ![buttonType isEqualToString:@"circleCorner"]){
//        UIButton *color1 = [[UIButton alloc] initWithFrame:CGRectMake(8, 5, 40, 40)];
//        color1.backgroundColor = [UIColor blackColor];
//        color1.layer.cornerRadius = 20;
//        color1.tag = 1;
//        
//        UIButton *color2 = [[UIButton alloc] initWithFrame:CGRectMake(53, 5, 40, 40)];
//        color2.backgroundColor = [UIColor redColor];
//        color2.layer.cornerRadius = 20;
//        color2.tag = 2;
//        
//        UIButton *color3 = [[UIButton alloc] initWithFrame:CGRectMake(101, 5, 40, 40)];
//        color3.backgroundColor = [UIColor brownColor];
//        color3.layer.cornerRadius = 20;
//        color3.tag = 3;
//        
//        UIButton *color4 = [[UIButton alloc] initWithFrame:CGRectMake(149, 5, 40, 40)];
//        color4.backgroundColor = [UIColor orangeColor];
//        color4.layer.cornerRadius = 20;
//        
//        UIButton *color5 = [[UIButton alloc] initWithFrame:CGRectMake(197, 5, 40, 40)];
//        color5.backgroundColor = [UIColor colorWithRed:1.00 green:0.73 blue:0.00 alpha:1.00];
//        color5.layer.cornerRadius = 20;
//        
//        UIButton *color6 = [[UIButton alloc] initWithFrame:CGRectMake(245, 5, 40, 40)];
//        color6.backgroundColor = [UIColor colorWithRed:1.00 green:0.89 blue:0.00 alpha:1.00];
//        color6.layer.cornerRadius = 20;
//        
//        UIButton *color7 = [[UIButton alloc] initWithFrame:CGRectMake(293, 5, 40, 40)];
//        color7.backgroundColor = [UIColor colorWithRed:1.00 green:1.00 blue:0.00 alpha:1.00];
//        color7.layer.cornerRadius = 20;
//        
//        UIButton *color8 = [[UIButton alloc] initWithFrame:CGRectMake(8, 50, 40, 40)];
//        color8.backgroundColor = [UIColor colorWithRed:0.87 green:1.00 blue:0.00 alpha:1.00];
//        color8.layer.cornerRadius = 20;
//        
//        UIButton *color9 = [[UIButton alloc] initWithFrame:CGRectMake(53, 50, 40, 40)];
//        color9.backgroundColor = [UIColor colorWithRed:0.00 green:0.76 blue:0.00 alpha:1.00];
//        color9.layer.cornerRadius = 20;
//        
//        UIButton *color10 = [[UIButton alloc] initWithFrame:CGRectMake(101, 50, 40, 40)];
//        color10.backgroundColor = [UIColor colorWithRed:0.00 green:0.76 blue:0.68 alpha:1.00];
//        color10.layer.cornerRadius = 20;
//        
//        UIButton *color11 = [[UIButton alloc] initWithFrame:CGRectMake(149, 50, 40, 40)];
//        color11.backgroundColor = [UIColor blueColor];
//        color11.layer.cornerRadius = 20;
//        
//        UIButton *color12 = [[UIButton alloc] initWithFrame:CGRectMake(197, 50, 40, 40)];
//        color12.backgroundColor = [UIColor colorWithRed:0.42 green:0.00 blue:0.78 alpha:1.00];
//        color12.layer.cornerRadius = 20;
//        
//        UIButton *color13 = [[UIButton alloc] initWithFrame:CGRectMake(245, 50, 40, 40)];
//        color13.backgroundColor = [UIColor colorWithRed:0.61 green:0.00 blue:0.78 alpha:1.00];
//        color13.layer.cornerRadius = 20;
//        
//        UIButton *color14 = [[UIButton alloc] initWithFrame:CGRectMake(293, 50, 40, 40)];
//        color14.backgroundColor = [UIColor colorWithRed:0.78 green:0.02 blue:0.65 alpha:1.00];
//        color14.layer.cornerRadius = 20;
//        
//        if([buttonType isEqualToString:@"ink"]){
//            [color1 addTarget:self action:@selector(GetInkBackgroundColor:) forControlEvents:UIControlEventTouchUpInside];
//            [color2 addTarget:self action:@selector(GetInkBackgroundColor:) forControlEvents:UIControlEventTouchUpInside];
//            [color3 addTarget:self action:@selector(GetInkBackgroundColor:) forControlEvents:UIControlEventTouchUpInside];
//            [color4 addTarget:self action:@selector(GetInkBackgroundColor:) forControlEvents:UIControlEventTouchUpInside];
//            [color5 addTarget:self action:@selector(GetInkBackgroundColor:) forControlEvents:UIControlEventTouchUpInside];
//            [color6 addTarget:self action:@selector(GetInkBackgroundColor:) forControlEvents:UIControlEventTouchUpInside];
//            [color7 addTarget:self action:@selector(GetInkBackgroundColor:) forControlEvents:UIControlEventTouchUpInside];
//            [color8 addTarget:self action:@selector(GetInkBackgroundColor:) forControlEvents:UIControlEventTouchUpInside];
//            [color9 addTarget:self action:@selector(GetInkBackgroundColor:) forControlEvents:UIControlEventTouchUpInside];
//            [color10 addTarget:self action:@selector(GetInkBackgroundColor:) forControlEvents:UIControlEventTouchUpInside];
//            [color11 addTarget:self action:@selector(GetInkBackgroundColor:) forControlEvents:UIControlEventTouchUpInside];
//            [color12 addTarget:self action:@selector(GetInkBackgroundColor:) forControlEvents:UIControlEventTouchUpInside];
//            [color13 addTarget:self action:@selector(GetInkBackgroundColor:) forControlEvents:UIControlEventTouchUpInside];
//            [color14 addTarget:self action:@selector(GetInkBackgroundColor:) forControlEvents:UIControlEventTouchUpInside];
//        } else if([buttonType isEqualToString:@"highlight"]){
//            [color1 addTarget:self action:@selector(GetHighlightBackgroundColor:) forControlEvents:UIControlEventTouchUpInside];
//            [color2 addTarget:self action:@selector(GetHighlightBackgroundColor:) forControlEvents:UIControlEventTouchUpInside];
//            [color3 addTarget:self action:@selector(GetHighlightBackgroundColor:) forControlEvents:UIControlEventTouchUpInside];
//            [color4 addTarget:self action:@selector(GetHighlightBackgroundColor:) forControlEvents:UIControlEventTouchUpInside];
//            [color5 addTarget:self action:@selector(GetHighlightBackgroundColor:) forControlEvents:UIControlEventTouchUpInside];
//            [color6 addTarget:self action:@selector(GetHighlightBackgroundColor:) forControlEvents:UIControlEventTouchUpInside];
//            [color7 addTarget:self action:@selector(GetHighlightBackgroundColor:) forControlEvents:UIControlEventTouchUpInside];
//            [color8 addTarget:self action:@selector(GetHighlightBackgroundColor:) forControlEvents:UIControlEventTouchUpInside];
//            [color9 addTarget:self action:@selector(GetHighlightBackgroundColor:) forControlEvents:UIControlEventTouchUpInside];
//            [color10 addTarget:self action:@selector(GetHighlightBackgroundColor:) forControlEvents:UIControlEventTouchUpInside];
//            [color11 addTarget:self action:@selector(GetHighlightBackgroundColor:) forControlEvents:UIControlEventTouchUpInside];
//            [color12 addTarget:self action:@selector(GetHighlightBackgroundColor:) forControlEvents:UIControlEventTouchUpInside];
//            [color13 addTarget:self action:@selector(GetHighlightBackgroundColor:) forControlEvents:UIControlEventTouchUpInside];
//            [color14 addTarget:self action:@selector(GetHighlightBackgroundColor:) forControlEvents:UIControlEventTouchUpInside];
//        } else if([buttonType isEqualToString:@"underline"]){
//            [color1 addTarget:self action:@selector(GetUnderlineBackgroundColor:) forControlEvents:UIControlEventTouchUpInside];
//            [color2 addTarget:self action:@selector(GetUnderlineBackgroundColor:) forControlEvents:UIControlEventTouchUpInside];
//            [color3 addTarget:self action:@selector(GetUnderlineBackgroundColor:) forControlEvents:UIControlEventTouchUpInside];
//            [color4 addTarget:self action:@selector(GetUnderlineBackgroundColor:) forControlEvents:UIControlEventTouchUpInside];
//            [color5 addTarget:self action:@selector(GetUnderlineBackgroundColor:) forControlEvents:UIControlEventTouchUpInside];
//            [color6 addTarget:self action:@selector(GetUnderlineBackgroundColor:) forControlEvents:UIControlEventTouchUpInside];
//            [color7 addTarget:self action:@selector(GetUnderlineBackgroundColor:) forControlEvents:UIControlEventTouchUpInside];
//            [color8 addTarget:self action:@selector(GetUnderlineBackgroundColor:) forControlEvents:UIControlEventTouchUpInside];
//            [color9 addTarget:self action:@selector(GetUnderlineBackgroundColor:) forControlEvents:UIControlEventTouchUpInside];
//            [color10 addTarget:self action:@selector(GetUnderlineBackgroundColor:) forControlEvents:UIControlEventTouchUpInside];
//            [color11 addTarget:self action:@selector(GetUnderlineBackgroundColor:) forControlEvents:UIControlEventTouchUpInside];
//            [color12 addTarget:self action:@selector(GetUnderlineBackgroundColor:) forControlEvents:UIControlEventTouchUpInside];
//            [color13 addTarget:self action:@selector(GetUnderlineBackgroundColor:) forControlEvents:UIControlEventTouchUpInside];
//            [color14 addTarget:self action:@selector(GetUnderlineBackgroundColor:) forControlEvents:UIControlEventTouchUpInside];
//        } else if([buttonType isEqualToString:@"cancleline"]){
//            [color1 addTarget:self action:@selector(GetCanclelineBackgroundColor:) forControlEvents:UIControlEventTouchUpInside];
//            [color2 addTarget:self action:@selector(GetCanclelineBackgroundColor:) forControlEvents:UIControlEventTouchUpInside];
//            [color3 addTarget:self action:@selector(GetCanclelineBackgroundColor:) forControlEvents:UIControlEventTouchUpInside];
//            [color4 addTarget:self action:@selector(GetCanclelineBackgroundColor:) forControlEvents:UIControlEventTouchUpInside];
//            [color5 addTarget:self action:@selector(GetCanclelineBackgroundColor:) forControlEvents:UIControlEventTouchUpInside];
//            [color6 addTarget:self action:@selector(GetCanclelineBackgroundColor:) forControlEvents:UIControlEventTouchUpInside];
//            [color7 addTarget:self action:@selector(GetCanclelineBackgroundColor:) forControlEvents:UIControlEventTouchUpInside];
//            [color8 addTarget:self action:@selector(GetCanclelineBackgroundColor:) forControlEvents:UIControlEventTouchUpInside];
//            [color9 addTarget:self action:@selector(GetCanclelineBackgroundColor:) forControlEvents:UIControlEventTouchUpInside];
//            [color10 addTarget:self action:@selector(GetCanclelineBackgroundColor:) forControlEvents:UIControlEventTouchUpInside];
//            [color11 addTarget:self action:@selector(GetCanclelineBackgroundColor:) forControlEvents:UIControlEventTouchUpInside];
//            [color12 addTarget:self action:@selector(GetCanclelineBackgroundColor:) forControlEvents:UIControlEventTouchUpInside];
//            [color13 addTarget:self action:@selector(GetCanclelineBackgroundColor:) forControlEvents:UIControlEventTouchUpInside];
//            [color14 addTarget:self action:@selector(GetCanclelineBackgroundColor:) forControlEvents:UIControlEventTouchUpInside];
//        } else if([buttonType isEqualToString:@"square"]){
//            [color1 addTarget:self action:@selector(GetSquareBackgroundColor:) forControlEvents:UIControlEventTouchUpInside];
//            [color2 addTarget:self action:@selector(GetSquareBackgroundColor:) forControlEvents:UIControlEventTouchUpInside];
//            [color3 addTarget:self action:@selector(GetSquareBackgroundColor:) forControlEvents:UIControlEventTouchUpInside];
//            [color4 addTarget:self action:@selector(GetSquareBackgroundColor:) forControlEvents:UIControlEventTouchUpInside];
//            [color5 addTarget:self action:@selector(GetSquareBackgroundColor:) forControlEvents:UIControlEventTouchUpInside];
//            [color6 addTarget:self action:@selector(GetSquareBackgroundColor:) forControlEvents:UIControlEventTouchUpInside];
//            [color7 addTarget:self action:@selector(GetSquareBackgroundColor:) forControlEvents:UIControlEventTouchUpInside];
//            [color8 addTarget:self action:@selector(GetSquareBackgroundColor:) forControlEvents:UIControlEventTouchUpInside];
//            [color9 addTarget:self action:@selector(GetSquareBackgroundColor:) forControlEvents:UIControlEventTouchUpInside];
//            [color10 addTarget:self action:@selector(GetSquareBackgroundColor:) forControlEvents:UIControlEventTouchUpInside];
//            [color11 addTarget:self action:@selector(GetSquareBackgroundColor:) forControlEvents:UIControlEventTouchUpInside];
//            [color12 addTarget:self action:@selector(GetSquareBackgroundColor:) forControlEvents:UIControlEventTouchUpInside];
//            [color13 addTarget:self action:@selector(GetSquareBackgroundColor:) forControlEvents:UIControlEventTouchUpInside];
//            [color14 addTarget:self action:@selector(GetSquareBackgroundColor:) forControlEvents:UIControlEventTouchUpInside];
//            color14.backgroundColor = [UIColor clearColor];
//            [color14.layer setBorderColor:[UIColor colorWithRed:0.00 green:0.00 blue:0.00 alpha:0.1].CGColor];
//            [color14.layer setBorderWidth:1.00];
//        } else if([buttonType isEqualToString:@"circle"]){
//            [color1 addTarget:self action:@selector(GetCircleBackgroundColor:) forControlEvents:UIControlEventTouchUpInside];
//            [color2 addTarget:self action:@selector(GetCircleBackgroundColor:) forControlEvents:UIControlEventTouchUpInside];
//            [color3 addTarget:self action:@selector(GetCircleBackgroundColor:) forControlEvents:UIControlEventTouchUpInside];
//            [color4 addTarget:self action:@selector(GetCircleBackgroundColor:) forControlEvents:UIControlEventTouchUpInside];
//            [color5 addTarget:self action:@selector(GetCircleBackgroundColor:) forControlEvents:UIControlEventTouchUpInside];
//            [color6 addTarget:self action:@selector(GetCircleBackgroundColor:) forControlEvents:UIControlEventTouchUpInside];
//            [color7 addTarget:self action:@selector(GetCircleBackgroundColor:) forControlEvents:UIControlEventTouchUpInside];
//            [color8 addTarget:self action:@selector(GetCircleBackgroundColor:) forControlEvents:UIControlEventTouchUpInside];
//            [color9 addTarget:self action:@selector(GetCircleBackgroundColor:) forControlEvents:UIControlEventTouchUpInside];
//            [color10 addTarget:self action:@selector(GetCircleBackgroundColor:) forControlEvents:UIControlEventTouchUpInside];
//            [color11 addTarget:self action:@selector(GetCircleBackgroundColor:) forControlEvents:UIControlEventTouchUpInside];
//            [color12 addTarget:self action:@selector(GetCircleBackgroundColor:) forControlEvents:UIControlEventTouchUpInside];
//            [color13 addTarget:self action:@selector(GetCircleBackgroundColor:) forControlEvents:UIControlEventTouchUpInside];
//            [color14 addTarget:self action:@selector(GetCircleBackgroundColor:) forControlEvents:UIControlEventTouchUpInside];
//            color14.backgroundColor = [UIColor clearColor];
//            [color14.layer setBorderColor:[UIColor colorWithRed:0.00 green:0.00 blue:0.00 alpha:0.1].CGColor];
//            [color14.layer setBorderWidth:1.00];
//        }
//        
//        [self.ColorPickerView addSubview:color1];
//        [self.ColorPickerView addSubview:color2];
//        [self.ColorPickerView addSubview:color3];
//        [self.ColorPickerView addSubview:color4];
//        [self.ColorPickerView addSubview:color5];
//        [self.ColorPickerView addSubview:color6];
//        [self.ColorPickerView addSubview:color7];
//        [self.ColorPickerView addSubview:color8];
//        [self.ColorPickerView addSubview:color9];
//        [self.ColorPickerView addSubview:color10];
//        [self.ColorPickerView addSubview:color11];
//        [self.ColorPickerView addSubview:color12];
//        [self.ColorPickerView addSubview:color13];
//        [self.ColorPickerView addSubview:color14];
//    } else {
//        UIButton *color1 = [[UIButton alloc] initWithFrame:CGRectMake(8, 5, 40, 40)];
//        color1.backgroundColor = [UIColor blackColor];
//        color1.layer.cornerRadius = 20;
//        
//        UIButton *color2 = [[UIButton alloc] initWithFrame:CGRectMake(53, 5, 40, 40)];
//        color2.backgroundColor = [UIColor redColor];
//        color2.layer.cornerRadius = 20;
//        
//        UIButton *color3 = [[UIButton alloc] initWithFrame:CGRectMake(101, 5, 40, 40)];
//        color3.backgroundColor = [UIColor brownColor];
//        color3.layer.cornerRadius = 20;
//        
//        UIButton *color4 = [[UIButton alloc] initWithFrame:CGRectMake(149, 5, 40, 40)];
//        color4.backgroundColor = [UIColor orangeColor];
//        color4.layer.cornerRadius = 20;
//        
//        UIButton *color5 = [[UIButton alloc] initWithFrame:CGRectMake(197, 5, 40, 40)];
//        color5.backgroundColor = [UIColor colorWithRed:1.00 green:0.73 blue:0.00 alpha:1.00];
//        color5.layer.cornerRadius = 20;
//        
//        UIButton *color6 = [[UIButton alloc] initWithFrame:CGRectMake(245, 5, 40, 40)];
//        color6.backgroundColor = [UIColor colorWithRed:1.00 green:0.89 blue:0.00 alpha:1.00];
//        color6.layer.cornerRadius = 20;
//        
//        UIButton *color7 = [[UIButton alloc] initWithFrame:CGRectMake(293, 5, 40, 40)];
//        color7.backgroundColor = [UIColor colorWithRed:1.00 green:1.00 blue:0.00 alpha:1.00];
//        color7.layer.cornerRadius = 20;
//        
//        UIButton *color8 = [[UIButton alloc] initWithFrame:CGRectMake(8, 50, 40, 40)];
//        color8.backgroundColor = [UIColor colorWithRed:0.87 green:1.00 blue:0.00 alpha:1.00];
//        color8.layer.cornerRadius = 20;
//        
//        UIButton *color9 = [[UIButton alloc] initWithFrame:CGRectMake(53, 50, 40, 40)];
//        color9.backgroundColor = [UIColor colorWithRed:0.00 green:0.76 blue:0.00 alpha:1.00];
//        color9.layer.cornerRadius = 20;
//        
//        UIButton *color10 = [[UIButton alloc] initWithFrame:CGRectMake(101, 50, 40, 40)];
//        color10.backgroundColor = [UIColor colorWithRed:0.00 green:0.76 blue:0.68 alpha:1.00];
//        color10.layer.cornerRadius = 20;
//        
//        UIButton *color11 = [[UIButton alloc] initWithFrame:CGRectMake(149, 50, 40, 40)];
//        color11.backgroundColor = [UIColor blueColor];
//        color11.layer.cornerRadius = 20;
//        
//        UIButton *color12 = [[UIButton alloc] initWithFrame:CGRectMake(197, 50, 40, 40)];
//        color12.backgroundColor = [UIColor colorWithRed:0.42 green:0.00 blue:0.78 alpha:1.00];
//        color12.layer.cornerRadius = 20;
//        
//        UIButton *color13 = [[UIButton alloc] initWithFrame:CGRectMake(245, 50, 40, 40)];
//        color13.backgroundColor = [UIColor colorWithRed:0.61 green:0.00 blue:0.78 alpha:1.00];
//        color13.layer.cornerRadius = 20;
//        
//        UIButton *color14 = [[UIButton alloc] initWithFrame:CGRectMake(293, 50, 40, 40)];
//        color14.backgroundColor = [UIColor colorWithRed:0.78 green:0.02 blue:0.65 alpha:1.00];
//        color14.layer.cornerRadius = 20;
//        
//        if([buttonType isEqualToString:@"squareCorner"]){
//            [color1 addTarget:self action:@selector(GetSquareCornerBackgroundColor:) forControlEvents:UIControlEventTouchUpInside];
//            [color2 addTarget:self action:@selector(GetSquareCornerBackgroundColor:) forControlEvents:UIControlEventTouchUpInside];
//            [color3 addTarget:self action:@selector(GetSquareCornerBackgroundColor:) forControlEvents:UIControlEventTouchUpInside];
//            [color4 addTarget:self action:@selector(GetSquareCornerBackgroundColor:) forControlEvents:UIControlEventTouchUpInside];
//            [color5 addTarget:self action:@selector(GetSquareCornerBackgroundColor:) forControlEvents:UIControlEventTouchUpInside];
//            [color6 addTarget:self action:@selector(GetSquareCornerBackgroundColor:) forControlEvents:UIControlEventTouchUpInside];
//            [color7 addTarget:self action:@selector(GetSquareCornerBackgroundColor:) forControlEvents:UIControlEventTouchUpInside];
//            [color8 addTarget:self action:@selector(GetSquareCornerBackgroundColor:) forControlEvents:UIControlEventTouchUpInside];
//            [color9 addTarget:self action:@selector(GetSquareCornerBackgroundColor:) forControlEvents:UIControlEventTouchUpInside];
//            [color10 addTarget:self action:@selector(GetSquareCornerBackgroundColor:) forControlEvents:UIControlEventTouchUpInside];
//            [color11 addTarget:self action:@selector(GetSquareCornerBackgroundColor:) forControlEvents:UIControlEventTouchUpInside];
//            [color12 addTarget:self action:@selector(GetSquareCornerBackgroundColor:) forControlEvents:UIControlEventTouchUpInside];
//            [color13 addTarget:self action:@selector(GetSquareCornerBackgroundColor:) forControlEvents:UIControlEventTouchUpInside];
//            [color14 addTarget:self action:@selector(GetSquareCornerBackgroundColor:) forControlEvents:UIControlEventTouchUpInside];
//            
//            [self.squareColorPickerView addSubview:color1];
//            [self.squareColorPickerView addSubview:color2];
//            [self.squareColorPickerView addSubview:color3];
//            [self.squareColorPickerView addSubview:color4];
//            [self.squareColorPickerView addSubview:color5];
//            [self.squareColorPickerView addSubview:color6];
//            [self.squareColorPickerView addSubview:color7];
//            [self.squareColorPickerView addSubview:color8];
//            [self.squareColorPickerView addSubview:color9];
//            [self.squareColorPickerView addSubview:color10];
//            [self.squareColorPickerView addSubview:color11];
//            [self.squareColorPickerView addSubview:color12];
//            [self.squareColorPickerView addSubview:color13];
//            [self.squareColorPickerView addSubview:color14];
//        } else if([buttonType isEqualToString:@"circleCorner"]){
//            [color1 addTarget:self action:@selector(GetCircleCornerBackgroundColor:) forControlEvents:UIControlEventTouchUpInside];
//            [color2 addTarget:self action:@selector(GetCircleCornerBackgroundColor:) forControlEvents:UIControlEventTouchUpInside];
//            [color3 addTarget:self action:@selector(GetCircleCornerBackgroundColor:) forControlEvents:UIControlEventTouchUpInside];
//            [color4 addTarget:self action:@selector(GetCircleCornerBackgroundColor:) forControlEvents:UIControlEventTouchUpInside];
//            [color5 addTarget:self action:@selector(GetCircleCornerBackgroundColor:) forControlEvents:UIControlEventTouchUpInside];
//            [color6 addTarget:self action:@selector(GetCircleCornerBackgroundColor:) forControlEvents:UIControlEventTouchUpInside];
//            [color7 addTarget:self action:@selector(GetCircleCornerBackgroundColor:) forControlEvents:UIControlEventTouchUpInside];
//            [color8 addTarget:self action:@selector(GetCircleCornerBackgroundColor:) forControlEvents:UIControlEventTouchUpInside];
//            [color9 addTarget:self action:@selector(GetCircleCornerBackgroundColor:) forControlEvents:UIControlEventTouchUpInside];
//            [color10 addTarget:self action:@selector(GetCircleCornerBackgroundColor:) forControlEvents:UIControlEventTouchUpInside];
//            [color11 addTarget:self action:@selector(GetCircleCornerBackgroundColor:) forControlEvents:UIControlEventTouchUpInside];
//            [color12 addTarget:self action:@selector(GetCircleCornerBackgroundColor:) forControlEvents:UIControlEventTouchUpInside];
//            [color13 addTarget:self action:@selector(GetCircleCornerBackgroundColor:) forControlEvents:UIControlEventTouchUpInside];
//            [color14 addTarget:self action:@selector(GetCircleCornerBackgroundColor:) forControlEvents:UIControlEventTouchUpInside];
//            
//            [self.circleColorPickerView addSubview:color1];
//            [self.circleColorPickerView addSubview:color2];
//            [self.circleColorPickerView addSubview:color3];
//            [self.circleColorPickerView addSubview:color4];
//            [self.circleColorPickerView addSubview:color5];
//            [self.circleColorPickerView addSubview:color6];
//            [self.circleColorPickerView addSubview:color7];
//            [self.circleColorPickerView addSubview:color8];
//            [self.circleColorPickerView addSubview:color9];
//            [self.circleColorPickerView addSubview:color10];
//            [self.circleColorPickerView addSubview:color11];
//            [self.circleColorPickerView addSubview:color12];
//            [self.circleColorPickerView addSubview:color13];
//            [self.circleColorPickerView addSubview:color14];
//        }
//    }
//}
//
//-(IBAction)getInkOpacity:(id)sender{
//    inkOpacityValue = (int)self.opacitySlider.value;
//    NSLog(@"opacity = %f", (CGFloat)inkOpacityValue);
//    CGFloat red;
//    CGFloat green;
//    CGFloat blue;
//    CGFloat alpha = inkOpacityValue*0.01;
//    CGFloat tmpAlpha;
//    [self.exampleInkColor getRed:&red green:&green blue:&blue alpha:&tmpAlpha];
//    [self.DocumentViewController setInkToolLineColor:[UIColor colorWithRed:red green:green blue:blue alpha:alpha]];
//    self.opacityLabel.text = [NSString stringWithFormat:@"투명도 %d%%",inkOpacityValue];
//}
//
//-(IBAction)getInkBold:(id)sender{
//    UISlider *slider = (UISlider *)sender;
//    
//    //Round the value to the a target interval
//    CGFloat roundedValue = [self roundValue:slider.value];
//    
//    //Snap to the final value
//    [slider setValue:roundedValue animated:NO];
//    NSLog(@"inkBoldValue = %f", roundedValue);
//    NSString *widthText;
//    inkBoldValue = self.boldSlider.value;
//    
//    [self.DocumentViewController setInkToolLineWidth:self.boldSlider.value];
//    if(inkBoldValue == 0.5) { widthText = @"굵기 1PX"; }
//    else if(inkBoldValue == 1.0) { widthText = @"굵기 2PX"; }
//    else if(inkBoldValue == 1.5) { widthText = @"굵기 3PX"; }
//    else if(inkBoldValue == 2.0) { widthText = @"굵기 4PX"; }
//    else if(inkBoldValue == 2.5) { widthText = @"굵기 5PX"; }
//    else if(inkBoldValue == 3.0) { widthText = @"굵기 6PX"; }
//    else if(inkBoldValue == 3.5) { widthText = @"굵기 7PX"; }
//    else if(inkBoldValue == 4.0) { widthText = @"굵기 8PX"; }
//    else if(inkBoldValue == 4.5) { widthText = @"굵기 9PX"; }
//    else { widthText = @"굵기 10PX"; }
//    
//    self.boldLabel.text = [NSString stringWithFormat:@"%@",widthText];
//}
// 
//    - (float)roundValue:(float)value
//    {
//        //get the remainder of value/interval
//        //make sure that the remainder is positive by getting its absolute value
//        float tempValue = fabsf(fmodf(value, 0.5)); //need to import <math.h>
//        
//        //if the remainder is greater than or equal to the half of the interval then return the higher interval
//        //otherwise, return the lower interval
//        if(tempValue >= (0.5 / 2.0)){
//            return value - tempValue + 0.5;
//        }
//        else{
//            return value - tempValue;
//        }
//    }
//    
//    
//float RoundValue(UISlider * slider) {
//    return roundf(slider.value * 2.0) * 0.5;
//}
//
//-(IBAction)getSquareBold:(id)sender{
//    squareBoldValue = (int)self.boldSlider.value;
//    NSLog(@"bold = %d", squareBoldValue);
//    [self.DocumentViewController setSquareAnnotwidth:self.boldSlider.value];
//    self.boldLabel.text = [NSString stringWithFormat:@"선 굵기 %dPX",squareBoldValue];
//}
//
//-(IBAction)getCircleBold:(id)sender{
//    circleBoldValue = (int)self.boldSlider.value;
//    NSLog(@"bold = %d", circleBoldValue);
//    [self.DocumentViewController setCircleAnnotwidth:self.boldSlider.value];
//    self.boldLabel.text = [NSString stringWithFormat:@"선 굵기 %dPX",circleBoldValue];
//}
//
//-(IBAction)getpageSlider:(id)sender{
//    int rounded = self.pageSlider.value;  //Casting to an int will truncate, round down
//    [sender setValue:rounded animated:NO];
//    NSLog(@"%d",(int)self.pageSlider.value);
//    currentSliderValue = rounded;
//    if(beforeSliderValue != currentSliderValue){
//        NSLog(@"gotopage");
//        [self.DocumentViewController gotoPage:currentSliderValue fitToScreen:YES];
//        beforeSliderValue = currentSliderValue;
//    }
//    
//}
//
//-(IBAction)getHighlightOpacity:(id)sender{
//    highlightOpacityValue = (int)self.opacitySlider.value;
//    NSLog(@"opacity = %d", highlightOpacityValue);
//    CGFloat red;
//    CGFloat green;
//    CGFloat blue;
//    CGFloat alpha = highlightOpacityValue*0.01;
//    CGFloat tmpAlpha;
//    [self.exampleInkColor getRed:&red green:&green blue:&blue alpha:&tmpAlpha];
//    [self.DocumentViewController setTextHighlightToolColor:[UIColor colorWithRed:red green:green blue:blue alpha:alpha]];
//    self.opacityLabel.text = [NSString stringWithFormat:@"투명도 %d%%",highlightOpacityValue];
//}
//
//- (IBAction)GetInkBackgroundColor:(UIButton *)sender
//{
//    NSLog(@"%ld", (long)sender.tag);
//    CGFloat red;
//    CGFloat green;
//    CGFloat blue;
//    CGFloat alpha = inkOpacityValue*0.01;
//    CGFloat tmpAlpha;
//    [sender.backgroundColor getRed:&red green:&green blue:&blue alpha:&tmpAlpha];
//    [self.DocumentViewController setInkToolLineColor:[UIColor colorWithRed:red green:green blue:blue alpha:alpha]];
//    self.exampleInkColor = sender.backgroundColor;
//    self.exampleInkColorView.backgroundColor = sender.backgroundColor;
//}
//
//- (IBAction)GetHighlightBackgroundColor:(UIButton *)sender
//{
//    CGFloat red;
//    CGFloat green;
//    CGFloat blue;
//    CGFloat alpha = highlightOpacityValue*0.01;
//    CGFloat tmpAlpha;
//    [sender.backgroundColor getRed:&red green:&green blue:&blue alpha:&tmpAlpha];
//    [self.DocumentViewController setTextHighlightToolColor:[UIColor colorWithRed:red green:green blue:blue alpha:alpha]];
//    self.exampleHighlightColor = sender.backgroundColor;
//    self.exampleHighlightColorView.backgroundColor = sender.backgroundColor;
//}
//
//- (IBAction)GetUnderlineBackgroundColor:(UIButton *)sender
//{
//    [self.DocumentViewController setTextUnderlineToolColor:sender.backgroundColor];
//    self.exampleUnderlineColor = sender.backgroundColor;
//    self.exampleUnderlineColorView.backgroundColor = sender.backgroundColor;
//}
//
//- (IBAction)GetCanclelineBackgroundColor:(UIButton *)sender
//{
//    [self.DocumentViewController setTextStrikeoutToolColor:sender.backgroundColor];
//    self.exampleCanclelineColor = sender.backgroundColor;
//    self.exampleCanclelineColorView.backgroundColor = sender.backgroundColor;
//}
//
//- (IBAction)GetSquareBackgroundColor:(UIButton *)sender
//{
//    [self.DocumentViewController setSquareAnnotColor:sender.backgroundColor];
//    self.exampleSquareColor = sender.backgroundColor;
//    self.exampleColorView.backgroundColor = sender.backgroundColor;
//}
//
//- (IBAction)GetCircleBackgroundColor:(UIButton *)sender
//{
//    [self.DocumentViewController setCircleAnnotColor:sender.backgroundColor];
//    self.exampleCircleColor = sender.backgroundColor;
//    self.exampleColorView.backgroundColor = sender.backgroundColor;
//}
//
//- (IBAction)GetSquareCornerBackgroundColor:(UIButton *)sender
//{
//    [self.DocumentViewController setSquareAnnotBorderColor:sender.backgroundColor];
//    self.exampleSquareCornerColor = sender.backgroundColor;
//    self.exampleSquareCornerColorView.backgroundColor = sender.backgroundColor;
//}
//
//- (IBAction)GetCircleCornerBackgroundColor:(UIButton *)sender
//{
//    [self.DocumentViewController setCircleAnnotBorderColor:sender.backgroundColor];
//    self.exampleCircleCornerColor = sender.backgroundColor;
//    self.exampleCircleCornerColorView.backgroundColor = sender.backgroundColor;
//}
//
//- (IBAction)getUnderLineSwitch:(id)sender {
//    UISwitch *mySwitch = (UISwitch *)sender;
//    
//    if ([mySwitch isOn]) {
//        useUnderline = 1;
//        self.underLineUseLabel.textColor = [UIColor colorWithRed:0.08 green:0.46 blue:0.98 alpha:1.00];
//        self.underLineUseLabel.text = [NSString stringWithFormat:@"사용"];
//        [self.DocumentViewController setTextUnderlineToolSquiggly:YES];
//    } else {
//        useUnderline = 0;
//        self.underLineUseLabel.textColor = [UIColor colorWithRed:0.89 green:0.89 blue:0.89 alpha:1.00];
//        self.underLineUseLabel.text = [NSString stringWithFormat:@"사용 안함"];
//        [self.DocumentViewController setTextUnderlineToolSquiggly:NO];
//    }
//}
//
//- (BOOL) showNoteContents:(UIViewController *)controller annot: (UIControl *)annot{
//    NSLog(@"asdf");
//}
//
//- (BOOL) showNoteAnnotEditView:(UIViewController *)controller annot: (UIControl *)annot{
//    NSLog(@"qwer");
//}
//
//- (void)showNoteAnnotEditView: (NoteAnnot*)annot
//{
//    NSLog(@"yyyyy");
//}
//
//
//- (BOOL) onTapUp: (id)sender{
//    NSLog(@"test");
//}
//
//- (void)releaseAnnots{
//    UsingInk = NO;
//    UsingSquare = NO;
//    UsingCircle = NO;
//    UsingHighlight = NO;
//    UsingUnderline = NO;
//    UsingCancle = NO;
//    UsingNote = NO;
//    UsingEraser = NO;
//    
//    [self.inkBtn setImage:[UIImage imageNamed:@"viewer-icon/pan-icon-01.png"] forState:UIControlStateNormal];
//    [self.squareBtn setImage:[UIImage imageNamed:@"viewer-icon/pan-icon-02.png"] forState:UIControlStateNormal];
//    [self.circleBtn setImage:[UIImage imageNamed:@"viewer-icon/pan-icon-03.png"] forState:UIControlStateNormal];
//    [self.highlightBtn setImage:[UIImage imageNamed:@"viewer-icon/pan-icon-04.png"] forState:UIControlStateNormal];
//    [self.underlineBtn setImage:[UIImage imageNamed:@"viewer-icon/pan-icon-05.png"] forState:UIControlStateNormal];
//    [self.cancleBtn setImage:[UIImage imageNamed:@"viewer-icon/pan-icon-06.png"] forState:UIControlStateNormal];
//    [self.noteBtn setImage:[UIImage imageNamed:@"viewer-icon/pan-icon-07.png"] forState:UIControlStateNormal];
//    [self.eraserBtn setImage:[UIImage imageNamed:@"viewer-icon/pan-icon-08.png"] forState:UIControlStateNormal];
//}
//
//- (void)releaseAnnotBtn{
//    [self.inkBtn removeFromSuperview];
//    [self.squareBtn removeFromSuperview];
//    [self.circleBtn removeFromSuperview];
//    [self.highlightBtn removeFromSuperview];
//    [self.underlineBtn removeFromSuperview];
//    [self.cancleBtn removeFromSuperview];
//    [self.noteBtn removeFromSuperview];
//    [self.eraserBtn removeFromSuperview];
//}
//
//
//- (void)releaseSubViews{
//    [self.lineView removeFromSuperview];
//    [self.colorLabel removeFromSuperview];
//    [self.ColorPickerView removeFromSuperview];
//    [self.opacityLabel removeFromSuperview];
//    [self.opacityView removeFromSuperview];
//    [self.boldLabel removeFromSuperview];
//    [self.boldView removeFromSuperview];
//    [self.underLineLabel removeFromSuperview];
//    [self.underLineView removeFromSuperview];
//    [self.underLineSwitch removeFromSuperview];
//    [self.exampleCanclelineColorView removeFromSuperview];
//    [self.squareColorLabel removeFromSuperview];
//    [self.squareColorPickerView removeFromSuperview];
//    [self.exampleColorView removeFromSuperview];
//    [self.exampleSquareCornerColorView removeFromSuperview];
//    [self.circleColorLabel removeFromSuperview];
//    [self.circleColorPickerView removeFromSuperview];
//    [self.exampleCircleCornerColorView removeFromSuperview];
//    [self.defaultEraserBtn removeFromSuperview];
//    [self.blockEraserBtn removeFromSuperview];
//    [self.allEraserBtn removeFromSuperview];
//    [self.exampleInkColorView removeFromSuperview];
//    [self.exampleHighlightColorView removeFromSuperview];
//    [self.exampleUnderlineColorView removeFromSuperview];
//}
//
//
//
//
//
//@end
