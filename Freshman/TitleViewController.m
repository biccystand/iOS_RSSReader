//
//  TitleViewController.m
//  SquareCam 
//
//  Created by masaki on 2014/03/02.
//
//

#import "TitleViewController.h"
#import "Reachability.h"
#import "ArticleViewController.h"
#import "IconDownloader.h"
#import "config.h"

#define isOffline \
([[Reachability reachabilityForInternetConnection] currentReachabilityStatus] == NotReachable ? YES : NO )

@interface TitleViewController ()<UITableViewDataSource, UITableViewDelegate> {
    NSMutableArray *_items;
    UIImage *image0;
    UIImage *image1;
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
    __weak IBOutlet UISegmentedControl *_topicSetmentedControl;
}
@property (weak, nonatomic) IBOutlet UIBarButtonItem *appButton;
@property (nonatomic, strong) NSMutableDictionary *imageDownloadsInProgress;
@property (nonatomic, retain) NADView *nadView;
- (IBAction)_topicChanged:(id)sender;
@end

@implementation TitleViewController

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
    if (SYSTEM_VERSION_GREATER_THAN_OR_EQUAL_TO(@"7.0")) {
        _topicSetmentedControl.tintColor = [UIColor whiteColor];
    }
	// Do any additional setup after loading the view.
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    NSLog(@"did");
//    if (isOffline) {
//        [self checkOffline];
//    }
}

- (void)checkOffline
{
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"ネットワーク接続エラー" message:@"オフラインのためデータを取得できませんでした (>_<)" delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil, nil];
    [alert show];
    NSLog(@"show");
}

- (void)startDownload
{
    NSLog(@"startDownloada00");

    if (isOffline) {
        [self checkOffline];
        [_refreshControl endRefreshing];
        return;
    }
    _items = [[NSMutableArray alloc] init];
//    NSString *feed = @"http://www.apple.com/jp/main/rss/hotnews/hotnews.rss";
    NSString *feed;
    NSLog(@"startDownloada01");
    switch (_topicSetmentedControl.selectedSegmentIndex) {
        case 0:
//            http://b.hatena.ne.jp/search/text?q=%E8%82%A9%E3%81%93%E3%82%8A
            feed = @"http://b.hatena.ne.jp/search/text?q=%E6%96%B0%E5%85%A5%E7%A4%BE%E5%93%A1+%7C+%E6%96%B0%E7%A4%BE%E4%BC%9A%E4%BA%BA&sort=recent&users=3&mode=rss";
//            http://b.hatena.ne.jp/search/text?q=%E8%85%B0%E7%97%9B
//            http://b.hatena.ne.jp/search/tag?q=%E7%BE%8E%E5%AE%B9&users=3
//            feed = @"http://b.hatena.ne.jp/search/text?q=%E5%B0%8F%E9%A1%94&mode=rss&users=3";
//            feed = @"http://b.hatena.ne.jp/search/text?q=%E5%B0%8F%E9%A1%94&mode=rss&sort=hot&threshold=100";
            break;
        case 1:
            feed = @"http://b.hatena.ne.jp/search/tag?q=%E6%96%B0%E5%85%A5%E7%A4%BE%E5%93%A1+%7C+%E6%96%B0%E7%A4%BE%E4%BC%9A%E4%BA%BA&mode=rss&sort=popular&threshold=100";
            break;
        default:
            break;
    }
    NSLog(@"startDownloada02");
    
    NSURL *url = [NSURL URLWithString:feed];
    NSURLRequest *request = [NSURLRequest requestWithURL:url];
    NSOperationQueue *queue = [[NSOperationQueue alloc] init];
//    _topicSetmentedControl.enabled = NO;
    
    NSLog(@"startDownloada03");
    [NSURLConnection sendAsynchronousRequest:request
                                       queue:queue
                           completionHandler:
     ^(NSURLResponse *response, NSData *data, NSError *error){
         NSLog(@"startDownloada04");
         _parser = [[NSXMLParser alloc] initWithData:data];
         NSLog(@"startDownloada05");
         _parser.delegate = self;
         NSLog(@"startDownloada06");
         [_parser parse];
         NSLog(@"startDownloada07");
         if (!_downLoaded) {
             _downLoaded = YES;
         }
//         [self.tableView setContentOffset:CGPointZero animated:YES];

     }];
    NSLog(@"startDownloada08");
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
}

- (void)parser:(NSXMLParser *)parser
foundCharacters:(NSString *)string
{

    if ([_elementName isEqualToString:@"title"]) {
        _item.title = [_item.title stringByAppendingString:string];
    } else if ([_elementName isEqualToString:@"description"]){
        _item.description = [_item.description stringByAppendingString:string];
    } else if ([_elementName isEqualToString:@"hatena:bookmarkcount"]){
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
    } else if ([_elementName isEqualToString:@"content:encoded"]){
//        NSLog(@"date: %@", string);
//        http://cdn-ak.favicon.st-hatena.com
        NSRange range = [string rangeOfString:@"http://cdn-ak.favicon.st-hatena.com"];
        if (range.location != NSNotFound)
        {
            _imageString = [_imageString stringByAppendingString:string];
            _item.imageURLString = [_item.imageURLString stringByAppendingString:string];
        }
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
        NSLog(@"itemt: %ld", (long)_item.count);
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
        
        
        
////        NSError *error;
//        regexp = [NSRegularExpression regularExpressionWithPattern:@"([0-9]+)" options:0 error:&error];
//        if (error != nil) {
//            NSLog(@"err: %@", error);
//        }
//        else
//        {
//            NSTextCheckingResult *match = [regexp firstMatchInString:_item.dateString options:0 range:NSMakeRange(0, _dateString.length)];
//            NSLog(@"match::%@", [_item.dateString substringWithRange:[match rangeAtIndex:0]]);
//            
//        }
//
//        NSLog(@"datestring: %@", _item.dateString);
//        NSString *dateExtracted;
//        NSDateFormatter *formetter = [[NSDateFormatter alloc] init];
//        [formetter setDateFormat:@"YYYY-MM-dd"];
//        NSDate* date = [formetter dateFromString:_item.dateString];
//        _item.date = date;
//        NSLog(@"date: %@", date);
        _item.count = [_countString integerValue];
        NSLog(@"count: %ld", (long)_item.count);
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
    NSLog(@"items0: %d", (int)_items.count);
    
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

    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"Cell" forIndexPath:indexPath];
    NSLog(@"items1:%d",(int)_items.count);
    Item *item;

    if (_items.count > 0) {
        if (indexPath.row < _items.count) {
            item = _items[indexPath.row];
        }
        else
        {
            item = nil;
            NSLog(@"nonoono");
        }
        NSLog(@"image::::%@", item.image);
        UIImageView *imageView = (UIImageView*)[cell viewWithTag:1];
        imageView.contentMode = UIViewContentModeScaleAspectFit;
    //    imageView.image = nil;
        
        UILabel *dateLabel = (UILabel*)[cell viewWithTag:3];
        dateLabel.text = item.dateString;
        
        UILabel *countLabel = (UILabel*)[cell viewWithTag:4];
        countLabel.text = [NSString stringWithFormat:@"%ldusers", (long)item.count];
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
        
        if (!item.image)
        {
            NSLog(@"noimage :%d", indexPath.row);
            NSLog(@"--------------");
            if (self.tableView.dragging == NO && self.tableView.decelerating == NO)
            {
                [self startIconDownload:item forIndexPath:indexPath];
            }
            // if a download is deferred or in progress, return a placeholder image
            imageView.image = nil;
        }
        else{
            NSLog(@"okimage :%d", indexPath.row);
            NSLog(@"okimageurl :%@", item.imageURLString);
            NSLog(@"okimageimg :%@", item.image);
            NSLog(@"--------------");
            imageView.image = (UIImage*)[_imageDictionary objectForKey:[NSNumber numberWithInt:indexPath.row]];
//            imageView.image = _item.image;
//            if (indexPath.row == 0) {
//                imageView.image = image0;
//            }
//            else if (indexPath.row == 1)
//            {
//                imageView.image = image0;
//            }
        }
    }
    

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
            imageView.image = item.image;
            NSLog(@"ok2image :%d", indexPath.row);
            NSLog(@"ok2imageurl :%@", item.imageURLString);
            NSLog(@"ok2imageimg :%@", item.image);
            NSLog(@"--------------");
            
            UIImage *image = [[UIImage alloc] initWithCGImage:item.image.CGImage];
            [_imageDictionary setObject:image forKey:[NSNumber numberWithInt:indexPath.row]];
//            if (indexPath.row == 0) {
//                image0 = [[UIImage alloc] initWithCGImage:item.image.CGImage];
//            }
//            else if (indexPath.row == 1)
//            {
//                image1 = [[UIImage alloc] initWithCGImage:item.image.CGImage];
//            }
            
//            UIImageView *imageView0 = (UIImageView*)[cell viewWithTag:444];
//            UIImageView *imageView1 = (UIImageView*)[cell viewWithTag:445];
//            imageView0.image = image0;
//            imageView1.image = image1;
            
//            Item *downloadedItem = [_items objectAtIndex:indexPath.row];
//            downloadedItem.image = item.image;

            
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
            NSLog(@"index: %ld", (long)indexPath.row);
            NSLog(@"items2:%d",(int)_items.count);
            Item *item;
            if (indexPath.row < _items.count) {
                item = _items[indexPath.row];
            }
            else
            {
                item = nil;
                NSLog(@"nonoono");
            }

//            Item *item = _items[indexPath.row];
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
        NSLog(@"items3:%d",(int)_items.count);
        Item *item;
        if (indexPath.row < _items.count) {
            item = _items[indexPath.row];
        }
        else
        {
            item = nil;
            NSLog(@"nonoono");
        }
//        Item *item = _items[indexPath.row];
        ArticleViewController *articleViewController = (ArticleViewController*) [segue destinationViewController];
//        articleViewController.url = [NSURL URLWithString:item.link];
//        articleViewController.titleString = item.title;
//        articleViewController.favorite = item.favorite;
        item.hatebu = YES;
        articleViewController.theItem = item;
//        articleViewController.hatebu = YES;
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
