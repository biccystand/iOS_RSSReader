//
//  FavoriteLitViewController.h
//  SquareCam 
//
//  Created by masaki on 2014/03/11.
//
//

#import <UIKit/UIKit.h>
#import "Item.h"
#import "NADView.h"

@interface FavoriteLitViewController : UIViewController <NSXMLParserDelegate, NADViewDelegate>
@property (weak, nonatomic) IBOutlet UITableView *tableView;

@end
