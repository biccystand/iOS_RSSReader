//
//  NaverTitleViewController.m
//  SquareCam 
//
//  Created by masaki on 2014/03/10.
//
//

#import "NaverTitleViewController.h"
#import "ArticleViewController.h"
#import "IconDownloader.h"
#import "Reachability.h"
#import "config.h"

#define isOffline \
([[Reachability reachabilityForInternetConnection] currentReachabilityStatus] == NotReachable ? YES : NO )

@interface NaverTitleViewController ()<UITableViewDataSource, UITableViewDelegate> {
    NSMutableArray *_items;
    Item *_item;
    BOOL _downLoaded;
    NSString *_dateString;
    NSString *_imageString;
    NSString *_countString;
    NSXMLParser *_parser;
    NSString *_elementName;
    UIRefreshControl *_refreshControl;
    ArticleViewController *_articleViewController;
    NSMutableDictionary *_imageDictionary;
//    __weak IBOutlet UISegmentedControl *_topicSetmentedControl;
}
@property (weak, nonatomic) IBOutlet UIBarButtonItem *appButton;
@property (nonatomic, strong) NSMutableDictionary *imageDownloadsInProgress;
@property (nonatomic, retain) NADView *nadView;
//- (IBAction)_topicChanged:(id)sender;
@end

@implementation NaverTitleViewController

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
    _imageDictionary = [NSMutableDictionary dictionary];
    
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
    _refreshControl = [[UIRefreshControl alloc] init];
    [_refreshControl addTarget:self action:@selector(startDownload) forControlEvents:UIControlEventValueChanged];
    [_tableView addSubview:_refreshControl];
    [self startDownload];
    _articleViewController = [[ArticleViewController alloc] init];
	// Do any additional setup after loading the view.
}

- (void)checkOffline
{
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"ネットワーク接続エラー" message:@"オフラインのためデータを取得できませんでした (>_<)" delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil, nil];
    [alert show];
    NSLog(@"show");
}

- (void)startDownload
{
    if (isOffline) {
        [self checkOffline];
        [_refreshControl endRefreshing];
        return;
    }
    _items = [[NSMutableArray alloc] init];
    //    NSString *feed = @"http://www.apple.com/jp/main/rss/hotnews/hotnews.rss";
    NSString *feed;
//    switch (_topicSetmentedControl.selectedSegmentIndex) {
//        case 0:
    feed = @"http://matome.naver.jp/feed/topic/1LzKd";
//            feed = @"http://matome.naver.jp/feed/topic/1Ly1R";
//            break;
//        case 1:
//            feed = @"http://b.hatena.ne.jp/search/tag?q=%E5%B0%8F%E9%A1%94&mode=rss&sort=popular&threshold=100";
//            break;
//        default:
//            break;
//    }
//    
    NSURL *url = [NSURL URLWithString:feed];
    NSURLRequest *request = [NSURLRequest requestWithURL:url];
    NSOperationQueue *queue = [[NSOperationQueue alloc] init];
    //    _topicSetmentedControl.enabled = NO;
    
    [NSURLConnection sendAsynchronousRequest:request
                                       queue:queue
                           completionHandler:
     ^(NSURLResponse *response, NSData *data, NSError *error){
         _parser = [[NSXMLParser alloc] initWithData:data];
         _parser.delegate = self;
         [_parser parse];
         if (!_downLoaded) {
             _downLoaded = YES;
         }
     }];
}

- (void)parser:(NSXMLParser *)parser
didStartElement:(NSString *)elementName
  namespaceURI:(NSString *)namespaceURI
 qualifiedName:(NSString *)qName
    attributes:(NSDictionary *)attributeDict
{
    _elementName = elementName;
    if ([_elementName isEqualToString:@"item"]) {
        //        NSLog(@"--------------------");
        _item = [[Item alloc] init];
        _item.title = @"";
        _item.description = @"";
        _item.link = @"";
        _item.subject = @"";
        _item.count = 0;
        _item.image = nil;
        _item.date = nil;
        _item.dateString = @"";
        _item.imageURLString = @"";
        _countString = @"";
        _imageString = @"";
        _dateString = @"";
    }
    else if ([_elementName isEqualToString:@"media:thumbnail"]) {
        NSLog(@"Name is %@", [attributeDict objectForKey:@"url"]);
        _item.imageURLString = [attributeDict objectForKey:@"url"];
    }
}

- (void)parser:(NSXMLParser *)parser
foundCharacters:(NSString *)string
{
    
    if ([_elementName isEqualToString:@"title"]) {
        _item.title = [_item.title stringByAppendingString:string];
    } else if ([_elementName isEqualToString:@"description"]){
        _item.description = [_item.description stringByAppendingString:string];
    } else if ([_elementName isEqualToString:@"favorite"]){
        //        NSLog(@"count: %@", string);
        _countString = [_countString stringByAppendingString:string];
    } else if ([_elementName isEqualToString:@"dc:subject"]){
        //        NSLog(@"subject: %@", string);
        _item.subject = [_item.subject stringByAppendingString:string];
    } else if ([_elementName isEqualToString:@"link"]){
        //        NSLog(@"link: %@", string);
        _item.link = [_item.link stringByAppendingString:string];
    } else if ([_elementName isEqualToString:@"dc:date"]){
        //        NSLog(@"date: %@", string);
        _item.dateString = [_item.dateString stringByAppendingString:string];
//    } else if ([_elementName isEqualToString:@"media:thumbnail"]){
//        NSLog(@"thumb: %@", string);
//        //        http://cdn-ak.favicon.st-hatena.com
//        NSRange range = [string rangeOfString:@"http://cdn-ak.favicon.st-hatena.com"];
//        if (range.location != NSNotFound)
//        {
//            _imageString = [_imageString stringByAppendingString:string];
//            _item.imageURLString = [_item.imageURLString stringByAppendingString:string];
//        }
    }
}

- (void)parser:(NSXMLParser *)parser
 didEndElement:(NSString *)elementName
  namespaceURI:(NSString *)namespaceURI
 qualifiedName:(NSString *)qName
{
    if ([elementName isEqualToString:@"item"]) {
        //        int itemIndex = _items.count;
        [_items addObject:_item];
        //        NSLog(@"item: %@", _item);
        _item.title = [_item.title stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
        _item.link = [_item.link stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
        _item.subject = [_item.subject stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
        
        NSLog(@"title: %@", _item.title);
        NSLog(@"itemt: %d", (int)_item.count);
        NSLog(@"link: %@", _item.link);
        NSLog(@"subject: %@", _item.subject);
        NSLog(@"date: %@", _dateString);
        
        NSString *string = _item.dateString;
        NSError *error   = nil;
        NSRegularExpression *regexp =
        [NSRegularExpression regularExpressionWithPattern:@"(\\d+)\\-(\\d+)\\-(\\d+)T(\\d+):(\\d+)(.*)"
                                                  options:0
                                                    error:&error];
        if (error != nil) {
            NSLog(@"%@", error);
        } else {
            NSTextCheckingResult *match =
            [regexp firstMatchInString:string options:0 range:NSMakeRange(0, string.length)];
            NSLog(@"%d", match.numberOfRanges); // 3のはず
            NSLog(@"%@", [string substringWithRange:[match rangeAtIndex:0]]); // マッチした文字列全部
            NSLog(@"y:%@", [string substringWithRange:[match rangeAtIndex:1]]); // "正規表現"
            NSLog(@"m:%@", [string substringWithRange:[match rangeAtIndex:2]]); // "大丈夫だ、問題ない"
            NSLog(@"d:%@", [string substringWithRange:[match rangeAtIndex:3]]); // "大丈夫だ、問題ない"
            NSLog(@"o:%@", [string substringWithRange:[match rangeAtIndex:4]]); // "大丈夫だ、問題ない"
            _item.dateString = [NSString stringWithFormat:@"%@/%@/%@ %@:%@", [string substringWithRange:[match rangeAtIndex:1]],[string substringWithRange:[match rangeAtIndex:2]],[string substringWithRange:[match rangeAtIndex:3]],[string substringWithRange:[match rangeAtIndex:4]],[string substringWithRange:[match rangeAtIndex:5]]];
        }
        
        //        NSString *dateExtracted;
        //        NSDateFormatter *formetter = [[NSDateFormatter alloc] init];
        //        [formetter setDateFormat:@"YYYY-MM-dd"];
        //        NSDate* date = [formetter dateFromString:_item.dateString];
        //        _item.date = date;
        //        NSLog(@"date: %@", date);
        _item.count = [_countString integerValue];
        NSLog(@"count: %d", (int)_item.count);
        NSLog(@"image: %@", _imageString);
        NSLog(@"image: %@", _item.imageURLString);
        
        //        dispatch_queue_t q_global = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0);
        //        dispatch_queue_t q_main = dispatch_get_main_queue();
        //        _item.image = nil;
        //        dispatch_async(q_global, ^{
        //            UIImage *image = [UIImage imageWithData:[NSData dataWithContentsOfURL: [NSURL URLWithString: _imageString]]];
        //
        //            dispatch_async(q_main, ^{
        ////                [self setImage:image toItemIndex:itemIndex];
        ////                _item.image = image;
        ////                NSLog(@"img::%@", _item.image);
        //            });
        //        });
    }
}

- (void)setImage:(UIImage*)image toItemIndex:(NSInteger)index
{
    if (index < _items.count) {
        Item *item = _items[index];
        item.image = image;
    }
    else
    {
        NSLog(@"nonoono");
    }
}

- (void)parserDidEndDocument:(NSXMLParser *)parser
{
    dispatch_async(dispatch_get_main_queue(), ^{
        [_refreshControl endRefreshing];
        [self.tableView reloadData];
    });
    //    _topicSetmentedControl.enabled = YES;
}


- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
    // terminate all pending download connections
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
    return _items.count?_items.count:kCustomRowCount;
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (UITableViewCell*)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    
    if (_items.count == 0 && indexPath.row == 0)
    {
        UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"LoadingCell" forIndexPath:indexPath];
        return cell;
    }
    

    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"acell" forIndexPath:indexPath];
    Item *item;
    if (_downLoaded) {
        if (indexPath.row < _items.count) {
            item = _items[indexPath.row];
        }
        else
        {
            item = nil;
            NSLog(@"nonoono");
        }

        UIImageView *imageView = (UIImageView*)[cell viewWithTag:1];
        NSLog(@"imagev: %@", imageView);
        NSLog(@"cell: %@", cell);
        //    imageView.image = nil;
        if (!item.image)
        {
            if (self.tableView.dragging == NO && self.tableView.decelerating == NO)
            {
                [self startIconDownload:item forIndexPath:indexPath];
            }
            // if a download is deferred or in progress, return a placeholder image
            imageView.image = nil;
        }
        else
        {
            imageView.image = (UIImage*)[_imageDictionary objectForKey:[NSNumber numberWithInt:indexPath.row]];

        }
    }
    UILabel *dateLabel = (UILabel*)[cell viewWithTag:3];
    dateLabel.text = item.dateString;
    
    UILabel *countLabel = (UILabel*)[cell viewWithTag:4];
    if (item.count > 0) {
        countLabel.text = [NSString stringWithFormat:@"⭐️%d", (int)item.count];
    }
    UITextView *titleTextView = (UITextView*)[cell viewWithTag:2];
    UILabel *titleLabel = (UILabel*)[cell viewWithTag:12];
    titleTextView.text = @"";
    titleLabel.text = item.title;
    //    [self cutoffTextview:titleTextView];
    
    UITextView* descriptionView = (UITextView*)[cell viewWithTag:5];
    UILabel *descriptionLabel = (UILabel*)[cell viewWithTag:15];
    descriptionView.editable = NO;
    descriptionView.scrollEnabled = NO;
    descriptionView.text = @"";
    descriptionLabel.text = item.description;
    return cell;
}

//- (void)cutoffTextview:(UITextView*)textview
//{
//    if(textview.contentSize.height > textview.frame.size.height)
//    {
//
//        while (textview.contentSize.height > textview.frame.size.height)
//        {
//            textview.text = [textview.text substringWithRange:NSMakeRange(0, textview.text.length-1)];
//        }
//        textview.text = [textview.text substringWithRange:NSMakeRange(0, textview.text.length-2)];
//        textview.text= [NSString stringWithFormat:@"%@..",textview.text];
//        textview.text = @"cut off";
//    }
//}
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
            imageView.contentMode = UIViewContentModeScaleAspectFit;
            imageView.image = item.image;
            
            UIImage *image = [[UIImage alloc] initWithCGImage:item.image.CGImage];
            [_imageDictionary setObject:image forKey:[NSNumber numberWithInt:indexPath.row]];

            
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
    if ([_items count] > 0)
    {
        NSArray *visiblePaths = [self.tableView indexPathsForVisibleRows];
        for (NSIndexPath *indexPath in visiblePaths)
        {
            NSLog(@"index: %d", (int)indexPath.row);
            Item *item;
            if (indexPath.row < _items.count) {
                item = _items[indexPath.row];
            }
            else
            {
                item = nil;
                NSLog(@"nonoono");
            }
            //            AppRecord *appRecord = [self.entries objectAtIndex:indexPath.row];
            //
            if (!item.image)
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
        if (indexPath.row < _items.count) {
            item = _items[indexPath.row];
        }
        else
        {
            item = nil;
            NSLog(@"nonoono");
        }
        ArticleViewController *articleViewController = (ArticleViewController*) [segue destinationViewController];
//        articleViewController.url = [NSURL URLWithString:item.link];
//        articleViewController.titleString = item.title;
//        articleViewController.favorite = item.favorite;
        item.hatebu = NO;
        articleViewController.theItem = item;
//        articleViewController.hatebu = NO;
        //        articleViewController.urlString = item.link;
        //        NSLog(@"url: %@", item.link);
    }
}
- (IBAction)_topicChanged:(id)sender {
    [self startDownload];
}

#pragma mark - NadView Delegate Methods
- (void)nadViewDidFinishLoad:(NADView *)adView
{
    
}

@end
