//
//  FavoriteLitViewController.m
//  SquareCam 
//
//  Created by masaki on 2014/03/11.
//
//

#import "FavoriteLitViewController.h"
#import "ArticleViewController.h"
#import "IconDownloader.h"
#import "PersistencyManager.h"
#import "Reachability.h"
#import "PersistencyManager.h"
#import "config.h"

#define isOffline \
([[Reachability reachabilityForInternetConnection] currentReachabilityStatus] == NotReachable ? YES : NO )

@interface FavoriteLitViewController ()<UITableViewDataSource, UITableViewDelegate> {
    NSMutableArray *_items;
    Item *_item;
    NSString *_dateString;
    NSString *_imageString;
    NSString *_countString;
    NSXMLParser *_parser;
    NSString *_elementName;
    BOOL _toReload;
//    UIRefreshControl *_refreshControl;
    ArticleViewController *_articleViewController;
}
@property (weak, nonatomic) IBOutlet UIBarButtonItem *appButton;
@property (nonatomic, strong) NSMutableDictionary *imageDownloadsInProgress;
@property (nonatomic, retain) NADView *nadView;

@end

@implementation FavoriteLitViewController

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
    
    float tabBarHeight = self.tabBarController.rotatingFooterView.frame.size.height;
    
    float nadviewY;
    if (SYSTEM_VERSION_LESS_THAN(@"7.0")) {
        nadviewY = kScreenHeight - kAdbarHeight-tabBarHeight-kToolBarHeight-kStatusBarHeight;
    }
    else
    {
        _appButton.tintColor = [UIColor whiteColor];
        nadviewY = kScreenHeight - kAdbarHeight-tabBarHeight;
    }
    self.nadView = [[NADView alloc] initWithFrame:CGRectMake(0, nadviewY, kScreenWidth, kAdbarHeight)];
    [self.nadView setIsOutputLog:NO];
    [self.nadView setNendID:kNendID spotID:kSpotID];
    [self.nadView setDelegate:self];
    [self.nadView load];
    
    [self.view addSubview:self.nadView];
    
    
    self.imageDownloadsInProgress = [NSMutableDictionary dictionary];
    _tableView.delegate = self;
    _tableView.dataSource = self;
    _articleViewController = [[ArticleViewController alloc] init];	// Do any additional setup after loading the view.
    
    if (SYSTEM_VERSION_GREATER_THAN_OR_EQUAL_TO(@"7.0"))
    {
        self.navigationItem.rightBarButtonItem.tintColor = [UIColor whiteColor];
    }
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [_tableView reloadData];
    [self loadImagesForOnscreenRows];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    NSArray *allDownloads = [self.imageDownloadsInProgress allValues];
    [allDownloads makeObjectsPerformSelector:@selector(cancelDownload)];
    //    _topicSetmentedControl.enabled = YES;
    
    [self.imageDownloadsInProgress removeAllObjects];
}

- (void)dealloc
{
    [self.nadView setDelegate:nil];
    self.nadView = nil;
}

#pragma mark - UITableViewDelegateMethods
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [[PersistencyManager sharedInstance] items].count;
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (UITableViewCell*)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"Cell" forIndexPath:indexPath];
    Item *item = [PersistencyManager sharedInstance].items[indexPath.row];
    NSLog(@"image::::%@", item.image);
    UIImageView *imageView = (UIImageView*)[cell viewWithTag:1];
    //    imageView.image = nil;
    if (!item.image || !_toReload)
    {
        if (self.tableView.dragging == NO && self.tableView.decelerating == NO)
        {
            [self startIconDownload:item forIndexPath:indexPath];
        }
        // if a download is deferred or in progress, return a placeholder image
        imageView.image = nil;
    }
    
    UILabel *dateLabel = (UILabel*)[cell viewWithTag:3];
    dateLabel.text = item.dateString;
    
//    UILabel *countLabel = (UILabel*)[cell viewWithTag:4];
//    countLabel.text = [NSString stringWithFormat:@"%dusers", item.count];
//    UITextView *titleTextView = (UITextView*)[cell viewWithTag:2];
    UILabel *titleLabel = (UILabel*)[cell viewWithTag:2];
//    titleTextView.text = @"";
    titleLabel.text = item.title;
    //    [self cutoffTextview:titleTextView];
    
//    UITextView* descriptionView = (UITextView*)[cell viewWithTag:5];
//    UILabel *descriptionLabel = (UILabel*)[cell viewWithTag:15];
//    descriptionView.editable = NO;
//    descriptionView.scrollEnabled = NO;
//    descriptionView.text = @"";
//    descriptionLabel.text = item.description;
    return cell;
}

- (UITableViewCellEditingStyle)tableView:(UITableView *)aTableView editingStyleForRowAtIndexPath:(NSIndexPath *)indexPath {
//    if (self.editing) {
        return UITableViewCellEditingStyleDelete;
//    }
//    return UITableViewCellEditingStyleNone;
}

#pragma mark - Table cell image support

// -------------------------------------------------------------------------------
//	startIconDownload:forIndexPath:
// -------------------------------------------------------------------------------
- (void)startIconDownload:(Item *)item forIndexPath:(NSIndexPath *)indexPath
{
    if (isOffline) {
        return;
    }
    IconDownloader *iconDownloader = [self.imageDownloadsInProgress objectForKey:indexPath];
    if (iconDownloader == nil)
    {
        iconDownloader = [[IconDownloader alloc] init];
        iconDownloader.item = item;
        [iconDownloader setCompletionHandler:^{
            
            UITableViewCell *cell = [self.tableView cellForRowAtIndexPath:indexPath];
            
            // Display the newly loaded image
            //            cell.imageView.image = item.image;
            
            UIImageView *imageView = (UIImageView*)[cell viewWithTag:1];
            imageView.image = item.image;
            
            
            // Remove the IconDownloader from the in progress list.
            // This will result in it being deallocated.
            [self.imageDownloadsInProgress removeObjectForKey:indexPath];
            
        }];
        [self.imageDownloadsInProgress setObject:iconDownloader forKey:indexPath];
        [iconDownloader startDownload];
    }
}

// -------------------------------------------------------------------------------
//	loadImagesForOnscreenRows
//  This method is used in case the user scrolled into a set of cells that don't
//  have their app icons yet.
// -------------------------------------------------------------------------------
- (void)loadImagesForOnscreenRows
{
    if ([[PersistencyManager sharedInstance] items].count > 0)
    {
        NSArray *visiblePaths = [self.tableView indexPathsForVisibleRows];
        for (NSIndexPath *indexPath in visiblePaths)
        {
            NSLog(@"index: %ld", (long)indexPath.row);
            Item *item;
            if (indexPath.row < [[PersistencyManager sharedInstance] items].count) {
                item = [[PersistencyManager sharedInstance] items][indexPath.row];
            }
            else
            {
                item = nil;
            }
            //            AppRecord *appRecord = [self.entries objectAtIndex:indexPath.row];
            //
            if (!item.image || !_toReload)
                // Avoid the app icon download if the app already has an icon
            {
                [self startIconDownload:item forIndexPath:indexPath];
            }
        }
    }
}

#pragma mark - UIScrollViewDelegate

// -------------------------------------------------------------------------------
//	scrollViewDidEndDragging:willDecelerate:
//  Load images for all onscreen rows when scrolling is finished.
// -------------------------------------------------------------------------------
- (void)scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate
{
    NSLog(@"del1");
    if (!decelerate)
	{
        [self loadImagesForOnscreenRows];
    }
}

// -------------------------------------------------------------------------------
//	scrollViewDidEndDecelerating:
// -------------------------------------------------------------------------------
- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView
{
    NSLog(@"del2");
    [self loadImagesForOnscreenRows];
}

#pragma mark
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if ([[segue identifier] isEqualToString:@"showDetail"]) {
        NSIndexPath *indexPath = [_tableView indexPathForSelectedRow];
//        Item *item = _items[indexPath.row];
        Item *item;
        if (indexPath.row < [PersistencyManager sharedInstance].items.count) {
            item = [PersistencyManager sharedInstance].items[indexPath.row];
        }
        else{
            item = nil;
        }
//        NSLog(@"item: %@", item);
//        NSLog(@"item: %@", item.link);
        ArticleViewController *articleViewController = (ArticleViewController*) [segue destinationViewController];
        //        articleViewController.url = [NSURL URLWithString:item.link];
        //        articleViewController.titleString = item.title;
        //        articleViewController.favorite = item.favorite;
        item.hatebu = NO;
        articleViewController.theItem = item;
        articleViewController.fromFavorite = YES;
        //        articleViewController.hatebu = YES;
        //        articleViewController.urlString = item.link;
        //        NSLog(@"url: %@", item.link);
    }
}
#pragma mark - NadView Delegate Methods
- (void)nadViewDidFinishLoad:(NADView *)adView
{
    
}

- (IBAction)didTapEditButton:(id)sender {
    if ([[PersistencyManager sharedInstance] items].count == 0 && !_tableView.editing) {
        return;
    }
    [_tableView setEditing:!_tableView.editing animated:YES];
    if (_tableView.editing) {
        self.navigationItem.rightBarButtonItem.title = @"キャンセル";
    } else {
        self.navigationItem.rightBarButtonItem.title = @"編集";
    }
}

- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        Item *item = [PersistencyManager sharedInstance].items[indexPath.row];
        NSLog(@"item: %@", item);
        for (Item *theItem in [[PersistencyManager sharedInstance] items]) {
            NSLog(@"itemInArray: %@", theItem);
        }
        NSString *url = item.link;
        NSInteger hatebu = item.hatebu;
        [[PersistencyManager sharedInstance] removeItemURL:url hatebu:hatebu];
//        [[PersistencyManager sharedInstance].items removeObjectAtIndex:indexPath.row];
        NSLog(@"items: %@", [[PersistencyManager sharedInstance] items]);
        [_tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationAutomatic];
    }
    if ([PersistencyManager sharedInstance].items.count < 1) {
        if (_tableView.editing) {
            [_tableView setEditing:NO animated:YES];
            self.navigationItem.rightBarButtonItem.title = @"編集";
        }
        
    }
}

@end
