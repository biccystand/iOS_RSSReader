//
//  ArticleViewController.m
//  SquareCam 
//
//  Created by masaki on 2014/03/03.
//
//

#import "ArticleViewController.h"
#import "PersistencyManager.h"
#import "Item.h"
#import "config.h"
#import "Reachability.h"
#import "UIView+TSExtention.h"
#import "CustomIOS7AlertView.h"
#import "AlertMessage.h"
#import "DCSocial.h"
#import "AlertMessage.h"
#import "PopTipManager.h"

#define isOffline \
([[Reachability reachabilityForInternetConnection] currentReachabilityStatus] == NotReachable ? YES : NO )
#define ColorStar [UIColor whiteColor]


@interface ArticleViewController () <UIWebViewDelegate,CustomIOS7AlertViewDelegate>
{
    NSString *message;
    NSTimer *timer;
    NSURLRequest *request;
    PopTipManager *_popTipManager;
    NSUserDefaults *_userdefaults;
}
@property (weak, nonatomic) IBOutlet UIBarButtonItem *starButton;
@property (weak, nonatomic) IBOutlet UIActivityIndicatorView *indicator;
@property (nonatomic, retain) NADView *nadView;
@property (weak, nonatomic) IBOutlet UIBarButtonItem *barBackButton;
@property (weak, nonatomic) IBOutlet UIBarButtonItem *barStarButton;
@property (nonatomic, strong) UIToolbar *toolbar;
@end

@implementation ArticleViewController

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
    _userdefaults = [NSUserDefaults standardUserDefaults];
    _webView.delegate = self;
//    float tabBarHeight = self.tabBarController.rotatingFooterView.frame.size.height;
    float nadviewY;
    if (SYSTEM_VERSION_LESS_THAN(@"7.0")) {
        nadviewY = kScreenHeight - kAdbarHeight - kToolBarHeight - kToolBarHeight - kStatusBarHeight;
    }
    else
    {
        nadviewY = kScreenHeight - kAdbarHeight - kToolBarHeight;
    }
    self.nadView = [[NADView alloc] initWithFrame:CGRectMake(0, nadviewY, kScreenWidth, kAdbarHeight)];
//    self.nadView = [[NADView alloc] initWithFrame:CGRectMake(0, kScreenHeight - kAdbarHeight-tabBarHeight, kScreenWidth, kAdbarHeight)];
    [self.nadView setIsOutputLog:NO];
    [self.nadView setNendID:kNendID spotID:kSpotID];
    [self.nadView setDelegate:self];
    [self.nadView load];
//    _webView.height -= self.nadView.height + kToolBarHeight;
    _webView.height -= kToolBarHeight;
    
    [self.view addSubview:self.nadView];
    
//    _toolbar = [[UIToolbar alloc] initWithFrame:CGRectMake(0, self.nadView.y - kToolBarHeight, kScreenWidth, kToolBarHeight)];
    float toolbarOffset;
    if (SYSTEM_VERSION_GREATER_THAN_OR_EQUAL_TO(@"7.0")) {
        toolbarOffset = 0;
    }
    else
    {
        toolbarOffset = 0;
    }
    _toolbar = [[UIToolbar alloc] initWithFrame:CGRectMake(0, self.nadView.y +self.nadView.height-toolbarOffset, kScreenWidth, kToolBarHeight)];
    _toolbar.backgroundColor = ColorPink;
    NSLog(@"toolbarframe: %f, %f, %f, %f", _toolbar.frame.origin.x, _toolbar.frame.origin.y, _toolbar.frame.size.width, _toolbar.frame.size.height);
    [self.view addSubview:_toolbar];
    [self setupToolbar];
}

- (void)setUpPopTipView
{
    int intStarPopped = [_userdefaults integerForKey:@"starPopped"];
    if (intStarPopped > 1) {
        return;
    }
    _popTipManager = [[PopTipManager alloc] init];
	self.visiblePopTipViews = [NSMutableArray array];
    self.popContents = _popTipManager.popTipContents;
    self.titles   = _popTipManager.popTipTitles;
    self.colorSchemes = _popTipManager.colorSchemes;
    [self showPopTip:_starButton];
    [_userdefaults setObject:[NSNumber numberWithInt:++intStarPopped] forKey:@"starPopped"];
}

#pragma mark - CMPopTipView
- (void)dismissAllPopTipViews
{
	while ([self.visiblePopTipViews count] > 0) {
		CMPopTipView *popTipView = [self.visiblePopTipViews objectAtIndex:0];
		[popTipView dismissAnimated:YES];
		[self.visiblePopTipViews removeObjectAtIndex:0];
	}
}

- (void)showPopTip:(id)sender
{
	[self dismissAllPopTipViews];
    
	if (sender == self.currentPopTipViewTarget) {
		// Dismiss the popTipView and that is all
		self.currentPopTipViewTarget = nil;
	}
	else {
		NSString *contentMessage = @"☆を押すとお気に入り登録します    ";
		UIView *contentView = nil;
		NSArray *colorScheme = [self.colorSchemes objectAtIndex:1];
        NSLog(@"colorScheme: %@", colorScheme);
        NSLog(@"schemes: %@", _colorSchemes);
//		UIColor *backgroundColor = [colorScheme objectAtIndex:0];
		UIColor *textColor = [colorScheme objectAtIndex:1];
        
		UIColor *backgroundColor = ColorPink2;
        //		UIColor *textColor = [UIColor whiteColor];
		
		NSString *title = nil;
		
		CMPopTipView *popTipView;
        popTipView.hasGradientBackground = NO;
		if (contentView) {
			popTipView = [[CMPopTipView alloc] initWithCustomView:contentView];
		}
		else if (title) {
			popTipView = [[CMPopTipView alloc] initWithTitle:title message:contentMessage];
		}
		else {
			popTipView = [[CMPopTipView alloc] initWithMessage:contentMessage];
		}
		popTipView.delegate = self;
		
		/* Some options to try.
		 */
		//popTipView.disableTapToDismiss = YES;
		//popTipView.preferredPointDirection = PointDirectionUp;
		//popTipView.hasGradientBackground = NO;
        //popTipView.cornerRadius = 2.0;
        //popTipView.sidePadding = 30.0f;
        //popTipView.topMargin = 20.0f;
        //popTipView.pointerSize = 50.0f;
		
		if (backgroundColor && ![backgroundColor isEqual:[NSNull null]]) {
			popTipView.backgroundColor = backgroundColor;
		}
		if (textColor && ![textColor isEqual:[NSNull null]]) {
			popTipView.textColor = textColor;
		}
        
        popTipView.animation = 1;
		popTipView.has3DStyle = 0;
		
		popTipView.dismissTapAnywhere = YES;
        //        [popTipView autoDismissAnimated:YES atTimeInterval:300.0];
        
		if ([sender isKindOfClass:[UIButton class]]) {
			UIButton *button = (UIButton *)sender;
			[popTipView presentPointingAtView:button inView:self.view animated:YES];
		}
		else {
			UIBarButtonItem *barButtonItem = (UIBarButtonItem *)sender;
			[popTipView presentPointingAtBarButtonItem:barButtonItem animated:YES];
		}
		
		[self.visiblePopTipViews addObject:popTipView];
        NSLog(@"ptviews: %@", _visiblePopTipViews);
		self.currentPopTipViewTarget = sender;
	}
}

#pragma mark - CMPopTipView Delegate Methods
- (void)popTipViewWasDismissedByUser:(CMPopTipView *)popTipView
{
	[self.visiblePopTipViews removeObject:popTipView];
	self.currentPopTipViewTarget = nil;
}

#pragma mark -

- (void)setupToolbar
{
    UIBarButtonItem *spacer = [[UIBarButtonItem alloc]
                               initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace
                               target:nil action:nil];
    
    UIBarButtonItem *backToRootButton = [[UIBarButtonItem alloc]
                               initWithTitle:@"<<" style:UIBarButtonItemStyleBordered
                               target:self action:@selector(backToRootView:)];
    UIBarButtonItem *previousButton = [[UIBarButtonItem alloc]
                                         initWithTitle:@"<" style:UIBarButtonItemStyleBordered
                                         target:self action:@selector(previousWeb:)];
    UIBarButtonItem *nextButton = [[UIBarButtonItem alloc]
                                         initWithTitle:@">" style:UIBarButtonItemStyleBordered
                                         target:self action:@selector(nextWeb:)];
    UIBarButtonItem *reloadButton = [[UIBarButtonItem alloc]
                                     initWithBarButtonSystemItem:UIBarButtonSystemItemRefresh target:nil action:@selector(reloadWebview:)];
    UIBarButtonItem *actionButton = [[UIBarButtonItem alloc]
                                     initWithBarButtonSystemItem:UIBarButtonSystemItemAction target:nil action:@selector(callAction:)];
    
    NSArray *items = [NSArray arrayWithObjects:backToRootButton, spacer, previousButton, spacer, nextButton, spacer, reloadButton, spacer, actionButton, nil];
    [_toolbar setItems:items];
}

- (void)callAction:(id)sender
{
    [self launchDialog:self];
}


- (void)reloadWebview:(id)sender
{
    [_webView reload];
}

- (void)backToRootView:(id)sender
{
    [self barBackButtonPushed:sender];
}

- (void)previousWeb:(id)sender
{
    if (_webView.canGoBack) {
        [_webView goBack];
    }
}

- (void)nextWeb:(id)sender
{
    if (_webView.canGoForward) {
        [_webView goForward];
    }
}

- (void)checkOffline
{
    [UIApplication sharedApplication].networkActivityIndicatorVisible = NO;
    [_indicator stopAnimating];
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"ネットワーク接続エラー" message:@"オフラインのためデータを取得できませんでした (>_<)" delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil, nil];
    [alert show];
    NSLog(@"show");
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    self.navigationItem.title = @"a";
    UILabel *titleLabel = [[UILabel alloc] init];
    titleLabel.frame = CGRectMake(0, 10, 140, 30);
    titleLabel.text = _theItem.title;
    titleLabel.font = [UIFont boldSystemFontOfSize:12.0];
    if (SYSTEM_VERSION_GREATER_THAN_OR_EQUAL_TO(@"7.0")) {
        titleLabel.textColor = [UIColor whiteColor];
    }
    titleLabel.numberOfLines = 3;
    self.navigationItem.titleView = titleLabel;
    titleLabel.textColor = [UIColor whiteColor];
    self.navigationItem.titleView.backgroundColor = [UIColor clearColor];
    
    
    NSLog(@"itemlink: %@ __", _theItem.link);
    if (!isOffline) {
        if ([_theItem.link isEqualToString:@"http://twpro.jp/nishikurashiki"]) {
            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"接続エラー" message:@"エラーが発生しました" delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil, nil];
            [alert show];
        }
        else {
            request = [NSURLRequest requestWithURL:[NSURL URLWithString:_theItem.link]];
            [_webView loadRequest:request];
        }
    }
    else
    {
        [self checkOffline];
    }
    
    NSLog(@"link: %@", _theItem.link);
    _barStarButton.title = @"☆";
//    _barStarButton.tintColor = [UIColor whiteColor];
    
    [self setStarState];
    if (_fromFavorite) {
        UINavigationBar *toolbar = self.navigationController.navigationBar;
        NSMutableArray *items = [[NSMutableArray alloc] initWithArray:[toolbar items]];
        NSLog(@"items: %@", items);
        [items removeObject:_barStarButton];
        _barStarButton.tintColor = [UIColor clearColor];
        _barStarButton.enabled = NO;
        _barStarButton.title = @"";
    }
    else
    {
        if (SYSTEM_VERSION_GREATER_THAN_OR_EQUAL_TO(@"7.0"))
        {
            _barStarButton.tintColor = ColorStar;
        }
        else
        {
//            _barStarButton.tintColor = ColorStar;

        }
        _barStarButton.enabled = YES;
    }
    
}

- (void)setStarState
{
    if (SYSTEM_VERSION_GREATER_THAN_OR_EQUAL_TO(@"7.0")) {
        _barBackButton.tintColor = [UIColor whiteColor];
    }
    NSMutableArray *items = [[PersistencyManager sharedInstance] items];
    for (Item *item in items) {
        if ([item.link isEqualToString:_theItem.link] && item.hatebu == _theItem.hatebu) {
            _barStarButton.title = @"★";
            if (SYSTEM_VERSION_GREATER_THAN_OR_EQUAL_TO(@"7.0")) {
                _barStarButton.tintColor = ColorStar;
            }
            break;
        }
    }
}

//- (void)backButtonPushed:(id)sender
//{
//    
//}


- (void)viewDidAppear:(BOOL)animated
{
//    NSLog(@"url: %@", _urlString);
    [super viewDidAppear:animated];
    [self setUpPopTipView];

//    UIBarButtonItem *btn = [[UIBarButtonItem alloc]
//                            initWithBarButtonSystemItem:UIBarButtonSystemItemCamera
//                            target:self action:@selector(backButtonPushed:)];
//    self.navigationItem.backBarButtonItem = btn;
}

- (void)viewDidDisappear:(BOOL)animated
{
    [super viewDidDisappear:animated];
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    [_webView stopLoading];
    [_indicator startAnimating];
    [UIApplication sharedApplication].networkActivityIndicatorVisible = NO;
}

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

- (IBAction)barBackButtonPushed:(id)sender {
    [self.navigationController popViewControllerAnimated:YES];
}

- (IBAction)barStarButtonPushed:(id)sender {
    NSLog(@"%@", _barStarButton.title);
    if ([_barStarButton.title isEqualToString:@"☆"]) {
        _barStarButton.title = @"★";
        if (SYSTEM_VERSION_GREATER_THAN_OR_EQUAL_TO(@"7.0")) {
            _barStarButton.tintColor = ColorStar;
        }
        [[PersistencyManager sharedInstance] addItemToDatabase:_theItem];
    }
    else
    {
        _barStarButton.title = @"☆";
//        _barStarButton.tintColor = [UIColor whiteColor];
        [[PersistencyManager sharedInstance] removeItemURL:_theItem.link hatebu:_theItem.hatebu];
    }
    
    [[PersistencyManager sharedInstance] sayData];
}

- (void)cancelWeb
{
    NSLog(@"didn't finish loading within 10 sec");
    [[NSURLCache sharedURLCache] removeCachedResponseForRequest:request];
    [[NSURLCache sharedURLCache] removeAllCachedResponses];

    // do anything error
    if (_webView && _webView.loading){
        [_webView stopLoading];
    }
    
    _webView.delegate=nil;
    
    
    NSURL *url = [NSURL URLWithString:@"http://yahoo.co.jp"];
    NSURLRequest *requestObj = [NSURLRequest requestWithURL:url];
    [_webView loadRequest:requestObj];
    
}

#pragma makr - UIWebView Delegate Methods

- (void)webView:(UIWebView *)webView didFailLoadWithError:(NSError *)error
{
    NSLog(@"error receipt");
}

- (void)webViewDidStartLoad:(UIWebView *)webView
{
    [UIApplication sharedApplication].networkActivityIndicatorVisible = YES;
    [_indicator startAnimating];
//    timer = [NSTimer scheduledTimerWithTimeInterval:2.0 target:self selector:@selector(cancelWeb) userInfo:nil repeats:NO];
}

- (void)webViewDidFinishLoad:(UIWebView *)webView
{
    [timer invalidate];
    [UIApplication sharedApplication].networkActivityIndicatorVisible = NO;
    [_indicator stopAnimating];
    
    if (webView.canGoForward) {
        UIBarButtonItem *forwardButton = _toolbar.items[4];
        forwardButton.enabled = YES;
    }
    else {
        UIBarButtonItem *forwardButton = _toolbar.items[4];
        forwardButton.enabled = NO;
    }
    
    if (webView.canGoBack) {
        UIBarButtonItem *backButton = _toolbar.items[2];
        backButton.enabled = YES;
    }
    else {
        UIBarButtonItem *backButton = _toolbar.items[2];
        backButton.enabled = NO;
    }
}

//- (BOOL)webView:(UIWebView *)webView shouldStartLoadWithRequest:(NSURLRequest *)request navigationType:(UIWebViewNavigationType)navigationType {
//    if ([request.URL.scheme isEqualToString:@"cancel"]) {
//        return NO;
//    }
//    return YES;
//}

//- (void)webView:(UIWebView *)webView didFailLoadWithError:(NSError *)error{ [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:NO];
//}

#pragma mark - NadView Delegate Methods
- (void)nadViewDidFinishLoad:(NADView *)adView
{
    
}

#pragma mark - CustomIOS7Alertview Delegate Methods
- (void)launchDialog:(id)sender
{
    AlertMessage* aleretMessage = [AlertMessage sharedInstance];
    CustomIOS7AlertView *alertView = [CustomIOS7AlertView alertWithTitle:nil message:@"記事を共有"];
    [alertView setButtonTitles:[aleretMessage buttonArrayOnTimeout:YES onTutorial:NO onArticle:YES]];
    [alertView setButtonColors:[aleretMessage buttonColorsArrayOnTimeout:YES onTutorial:NO]];
    [alertView setDelegate:self];
    [alertView setOnButtonTouchUpInside:^(CustomIOS7AlertView *alertView, int buttonIndex) {
        NSLog(@"Block: Button at position %d is clicked on alertView %ld.", buttonIndex, (long)[alertView tag]);
        [alertView close];
    }];
    [alertView show];
    
}

- (void)customIOS7dialogButtonTouchUpInside: (CustomIOS7AlertView *)alertView clickedButtonAtIndex: (NSInteger)buttonIndex
{
    NSLog(@"Delegate: Button at position %d is clicked on alertView %ld.", (int)buttonIndex, (long)[alertView tag]);
    
    message = [NSString stringWithFormat:@"%@\n%@", _theItem.title, _theItem.link];

    
    switch (buttonIndex) {
        case 0:
            [DCSocial postTextToLine:message];
            break;
        case 1:
            [DCSocial postToTwitter:self text:message imageName:nil url:nil];
            break;
        case 2:
            [DCSocial postToFacebook:self text:message imageName:nil url:nil];
        default:
            [alertView close];
    }
}


@end
