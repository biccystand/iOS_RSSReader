//
//  NaverTitleViewController.h
//  SquareCam 
//
//  Created by masaki on 2014/03/10.
//
//

#import <UIKit/UIKit.h>
#import "Item.h"
#import "NADView.h"

@interface NaverTitleViewController : UIViewController <NSXMLParserDelegate, NADViewDelegate>
@property (weak, nonatomic) IBOutlet UITableView *tableView;

@end