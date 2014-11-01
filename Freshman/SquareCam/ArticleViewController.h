//
//  ArticleViewController.h
//  SquareCam 
//
//  Created by masaki on 2014/03/03.
//
//

#import <UIKit/UIKit.h>
#import "NADView.h"
#import "CMPopTipView.h"
@class Item;

@interface ArticleViewController : UIViewController <NADViewDelegate, CMPopTipViewDelegate>
@property (weak, nonatomic) IBOutlet UIWebView *webView;
//@property (strong, nonatomic) NSURL *url;
//@property (copy, nonatomic) NSString *titleString;
//@property (copy, nonatomic) NSString *urlString;
@property (nonatomic, strong) Item *theItem;
//@property (nonatomic, assign) BOOL hatebu;
@property (nonatomic, assign) BOOL favorite;
@property (nonatomic, assign) BOOL fromFavorite;
@property (nonatomic, strong)	NSArray			*colorSchemes;
@property (nonatomic, strong)	NSDictionary	*popContents;
@property (nonatomic, strong)	id				currentPopTipViewTarget;
@property (nonatomic, strong
           )	NSDictionary	*titles;
@property (nonatomic, strong)	NSMutableArray	*visiblePopTipViews;
@end
