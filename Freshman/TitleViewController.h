//
//  TitleViewController.h
//  SquareCam 
//
//  Created by masaki on 2014/03/02.
//
//

#import <UIKit/UIKit.h>
#import "Item.h"
#import "NADView.h"

@interface TitleViewController : UIViewController <NSXMLParserDelegate, NADViewDelegate>
@property (weak, nonatomic) IBOutlet UITableView *tableView;
@end
