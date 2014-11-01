//
//  RecommendViewController.m
//  SquareCam 
//
//  Created by masaki on 2014/04/06.
//
//

#import "RecommendViewController.h"
#import "config.h"

@interface RecommendViewController ()
@property (weak, nonatomic) IBOutlet UIBarButtonItem *navButton;
@property (nonatomic, strong) UIWebView * webView;
@property (nonatomic, retain) NADView *nadView;

@end

@implementation RecommendViewController
- (IBAction)footButtonPressed:(id)sender {
    [self dismissRecommendViewController];
}
- (IBAction)navButtonPressed:(id)sender {
    [self dismissRecommendViewController];
}

- (void)dismissRecommendViewController
{
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    CGFloat navBarHeight;
    CGFloat toolBarY;

    if (SYSTEM_VERSION_LESS_THAN(@"7.0")) {
        navBarHeight = kToolBarHeight;
        toolBarY = kScreenHeight - kToolBarHeight - kAdbarHeight - kToolBarHeight - kStatusBarHeight;
    }
    else
    {
        _navButton.tintColor = [UIColor whiteColor];
        navBarHeight = kToolBarHeight + kStatusBarHeight;
        toolBarY = kScreenHeight - kToolBarHeight - kAdbarHeight;
        navBarHeight = 0;
    }
    
    UIToolbar *toolBar = [[UIToolbar alloc] initWithFrame:CGRectMake(0, toolBarY, kScreenWidth, kAdbarHeight)];
    UIBarButtonItem *dismissButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemStop target:self action:@selector(dismissRecommendViewController)];
    UIBarButtonItem *flexibleSpace = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace target:nil action:nil];
    NSArray *items = [NSArray arrayWithObjects: flexibleSpace, dismissButton, nil];
    [toolBar setItems:items];
    UINavigationBar *navBar = [[UINavigationBar alloc] initWithFrame:CGRectMake(0, 0, kScreenWidth, navBarHeight-1)];
//    UINavigationItem* naviItem = [[UINavigationItem alloc] initWithTitle:@"髪型の追加"];
//    UIBarButtonItem* backButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemStop target:self action:@selector(dismiss:)];
    if (SYSTEM_VERSION_LESS_THAN(@"7.0")) {
        self.nadView = [[NADView alloc] initWithFrame:CGRectMake(0, kScreenHeight - kAdbarHeight-20-kToolBarHeight, kScreenWidth, kAdbarHeight)];
    }
    else
    {
        self.nadView = [[NADView alloc] initWithFrame:CGRectMake(0, kScreenHeight - kAdbarHeight, kScreenWidth, kAdbarHeight)];
    }
    [self.nadView setIsOutputLog:NO];
    [self.nadView setNendID:kNendID spotID:kSpotID];
    [self.nadView setDelegate:self];
    [self.nadView load];
    
    
    // ナビゲーションアイテムの右側に戻るボタンを設置
//    naviItem.rightBarButtonItem = backButton;
    
    // ナビゲーションバーにナビゲーションアイテムを設置
//    [navBar pushNavigationItem:naviItem animated:YES];
    
    
    CGFloat webViewHeight;
    if (SYSTEM_VERSION_LESS_THAN(@"7.0")) {
        webViewHeight = kScreenHeight - navBar.frame.size.height - kAdbarHeight - kToolBarHeight - 20;
        _webView = [[UIWebView alloc] initWithFrame:CGRectMake(0, 0, kScreenWidth, webViewHeight)];
    }
    else
    {
        webViewHeight = kScreenHeight - navBar.frame.size.height - kAdbarHeight - kToolBarHeight;
        _webView = [[UIWebView alloc] initWithFrame:CGRectMake(0, navBar.frame.origin.y + navBar.frame.size.height, kScreenWidth, webViewHeight)];
    }
    _webView.delegate = self;
    NSString *path = [[NSBundle mainBundle] pathForResource:@"about" ofType:@"html"];
    [_webView loadRequest:[NSURLRequest requestWithURL:[NSURL fileURLWithPath:path]]];
    [self.view addSubview:_webView];
    [self.view addSubview:toolBar];
    [self.view addSubview:self.nadView];
//    [self.view addSubview:navBar];
    

}

//- (void)viewWillAppear:(BOOL)animated
//{
//    [super viewWillAppear:animated];
////    _toolBar.frame = CGRectMake(100, 100, 300, 20);
//
//}
//
- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)dealloc
{
    [self.nadView setDelegate:nil];
    self.nadView = nil;
}

- (void)nadViewDidFinishLoad:(NADView *)adView
{
    
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
