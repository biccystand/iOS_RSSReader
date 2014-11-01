//
//  NaverTitleViewController.m
//  SquareCam 
//
//  Created by masaki on 2014/03/10.
//
//

#import "NaverTitleViewController.h"

@interface NaverTitleViewController ()

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
	// Do any additional setup after loading the view.
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)startDownload
{
    _items = [[NSMutableArray alloc] init];
    //    NSString *feed = @"http://www.apple.com/jp/main/rss/hotnews/hotnews.rss";
    NSString *feed;
    switch (_topicSetmentedControl.selectedSegmentIndex) {
        case 0:
            feed = @"http://b.hatena.ne.jp/search/tag?q=%E5%B0%8F%E9%A1%94&mode=rss&sort=hot&threshold=100";
            break;
        case 1:
            feed = @"http://b.hatena.ne.jp/search/tag?q=%E5%B0%8F%E9%A1%94&mode=rss&sort=popular&threshold=100";
            break;
        default:
            break;
    }
    
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
     }];
}


- (UITableViewCell*)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"Cell" forIndexPath:indexPath];
//    Item *item = _items[indexPath.row];
    Item *item = [[Item alloc] init];
    NSLog(@"image::::%@", item.image);
    UIImageView *imageView = (UIImageView*)[cell viewWithTag:1];
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
    
    UILabel *dateLabel = (UILabel*)[cell viewWithTag:3];
    dateLabel.text = item.dateString;
    
    UILabel *countLabel = (UILabel*)[cell viewWithTag:4];
    countLabel.text = [NSString stringWithFormat:@"%dusers", item.count];
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

@end
