//
//  PersistencyManager.h
//  TokiMemo
//
//  Created by masaki on 2013/09/30.
//  Copyright (c) 2013年 masaki. All rights reserved.
//

#import <Foundation/Foundation.h>
@class Item;

@interface PersistencyManager : NSObject
+(PersistencyManager*)sharedInstance;
@property (nonatomic, strong) NSMutableArray *items;
- (void)removeItemURL:(NSString *)urlString hatebu:(NSInteger)hatebu;
- (void)removeAllTimeMemoOfDatabase;
- (void)addItemToDatabase:(Item *)newItem;
- (void)updateItem:(NSString*)link hatebu:(NSString*)hatebu favorite:(NSInteger)favorite;
- (void)sayData;
//- (void)saveDateWithColorNum:(NSInteger)num;
//- (void)updateTimeMemoInArrayWithId:(NSInteger)timeMemoId color:(NSInteger)color memo:(NSString *)memo;
//- (void)removeTimeMemoAtIndexPath: (NSIndexPath *)indexPath;
@end
