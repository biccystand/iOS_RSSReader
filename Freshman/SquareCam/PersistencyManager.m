//
//  PersistencyManager.m
//  TokiMemo
//
//  Created by masaki on 2013/09/30.
//  Copyright (c) 2013年 masaki. All rights reserved.
//

#import "PersistencyManager.h"
#import "Item.h"
#include <sqlite3.h>
@implementation PersistencyManager

+(PersistencyManager*)sharedInstance
{
    static PersistencyManager *_sharedInstance = nil;
    static dispatch_once_t oncePredicate;
    
    dispatch_once(&oncePredicate, ^{
        _sharedInstance = [[PersistencyManager alloc] init];
    });
    return _sharedInstance;
}

- (id)init
{
    self = [super init];
    if (self) {
        self.items = [[NSMutableArray alloc] init];
        NSString *filePath = [self copyDatabaseToDocuments];
        [self readTimeMemosFromDatabaseWithPath:filePath];
    }
    return self;
}

- (NSDictionary *)dateDictionary: (NSDate *)now {
    
    NSCalendar *calendar = [NSCalendar currentCalendar];
    NSUInteger flags;
    NSDateComponents *comps;
    
    // 年・月・日を取得
    flags = NSYearCalendarUnit | NSMonthCalendarUnit | NSDayCalendarUnit;
    comps = [calendar components:flags fromDate:now];
    
    NSInteger year = comps.year;
    NSInteger month = comps.month;
    NSInteger day = comps.day;
    
    NSLog(@"%ld年 %ld月 %ld日", (long)year, (long)month, (long)day);
    
    
    // 時・分・秒を取得
    flags = NSHourCalendarUnit | NSMinuteCalendarUnit | NSSecondCalendarUnit;
    comps = [calendar components:flags fromDate:now];
    
    NSInteger hour = comps.hour;
    NSInteger minute = comps.minute;
    NSInteger second = comps.second;
    
    NSLog(@"%ld時 %ld分 %ld秒", (long)hour, (long)minute, (long)second);
    
    
    // 曜日
    comps = [calendar components:NSWeekdayCalendarUnit fromDate:now];
    NSInteger weekday = comps.weekday; // 曜日(1が日曜日 7が土曜日)
    NSLog(@"曜日: %ld", (long)weekday);
    
    NSDictionary *dateDic = @{@"year": [NSNumber numberWithInt:(int)year], @"month": [NSNumber numberWithInt:(int)month], @"day": [NSNumber numberWithInt:(int)day], @"hour": [NSNumber numberWithInt:(int)hour], @"minute": [NSNumber numberWithInt:(int)minute], @"second": [NSNumber numberWithInt:(int)second], @"weekday": [NSNumber numberWithInt:(int)weekday]};
    return dateDic;
}


#pragma mark - database
- (NSString *)copyDatabaseToDocuments {
    NSFileManager *fileManager = [NSFileManager defaultManager];
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *documentsPath = [paths objectAtIndex:0];
    NSString *filePath = [documentsPath stringByAppendingPathComponent:@"items.sqlite"];
    
    if (![fileManager fileExistsAtPath:filePath]) {
        NSString *bundlePath = [[[NSBundle mainBundle] resourcePath] stringByAppendingPathComponent:@"items.sqlite"];
        [fileManager copyItemAtPath:bundlePath toPath:filePath error:nil];
    }
    return filePath;
}

- (void)readTimeMemosFromDatabaseWithPath:(NSString *)filePath {
    sqlite3 *database;
    
    if (sqlite3_open([filePath UTF8String], &database) == SQLITE_OK) {
        const char *sqlStatement = "select * from items order by id desc";
        sqlite3_stmt *compiledStatement;
        if (sqlite3_prepare_v2(database, sqlStatement, -1, &compiledStatement, NULL) == SQLITE_OK) {
            while (sqlite3_step(compiledStatement) == SQLITE_ROW) {
                //
                //                CREATE TABLE timememo (id INTEGER PRIMARY KEY AUTOINCREMENT, year integer, month integer, day integer, hour integer, minute integer, second integer, weekday integer, memo text, color integer)
                //
                NSInteger itemId = sqlite3_column_int(compiledStatement, 0);
                NSString *title;
                char *str = (char*)sqlite3_column_text(compiledStatement, 1);
                if(str == NULL){
                    title = @"";
                }else{
                    title = [NSString stringWithUTF8String:(char *)sqlite3_column_text(compiledStatement, 1)];
                }
                NSString *link;
                str = (char*)sqlite3_column_text(compiledStatement, 2);
                if(str == NULL){
                    link = @"";
                }else{
                    link = [NSString stringWithUTF8String:(char *)sqlite3_column_text(compiledStatement, 2)];
                }
                NSString *dateString;
                str = (char*)sqlite3_column_text(compiledStatement, 3);
                if(str == NULL){
                    dateString = @"";
                }else{
                    dateString = [NSString stringWithUTF8String:(char *)sqlite3_column_text(compiledStatement, 3)];
                }
                NSString *imageURLString;
                str = (char*)sqlite3_column_text(compiledStatement, 4);
                if(str == NULL){
                    imageURLString = @"";
                }else{
                    imageURLString = [NSString stringWithUTF8String:(char *)sqlite3_column_text(compiledStatement, 4)];
                }
                NSString *countString;
                str = (char*)sqlite3_column_text(compiledStatement, 5);
                if(str == NULL){
                    countString = @"";
                }else{
                    countString = [NSString stringWithUTF8String:(char *)sqlite3_column_text(compiledStatement, 5)];
                }
                NSInteger favorite = sqlite3_column_int(compiledStatement, 6);
                NSInteger hatebu = sqlite3_column_int(compiledStatement, 7);
                
                Item *newItem = [[Item alloc] init];
                newItem.itemId = itemId;
                newItem.title = title;
                newItem.link = link;
                newItem.dateString  = dateString;
                newItem.imageURLString = imageURLString;
                newItem.countString = countString;
                newItem.favorite = favorite;
                newItem.hatebu = hatebu;
                [self.items addObject:newItem];
                //                [self.cities addObject:newCity];
            }
        }
        sqlite3_finalize(compiledStatement);
    }
    sqlite3_close(database);
}

- (void)selectTimeMemosFromDatabaseWithPath:(NSString *)filePath {
    sqlite3 *database;
    
    if (sqlite3_open([filePath UTF8String], &database) == SQLITE_OK) {
        const char *sqlStatement = "select * from items order by id desc";
        sqlite3_stmt *compiledStatement;
        if (sqlite3_prepare_v2(database, sqlStatement, -1, &compiledStatement, NULL) == SQLITE_OK) {
            while (sqlite3_step(compiledStatement) == SQLITE_ROW) {
                //
                //                CREATE TABLE timememo (id INTEGER PRIMARY KEY AUTOINCREMENT, year integer, month integer, day integer, hour integer, minute integer, second integer, weekday integer, memo text, color integer)
                //
                NSInteger itemId = sqlite3_column_int(compiledStatement, 0);
                NSString *title;
                char *str = (char*)sqlite3_column_text(compiledStatement, 1);
                if(str == NULL){
                    title = @"";
                }else{
                    title = [NSString stringWithUTF8String:(char *)sqlite3_column_text(compiledStatement, 1)];
                }
                NSString *link;
                str = (char*)sqlite3_column_text(compiledStatement, 2);
                if(str == NULL){
                    link = @"";
                }else{
                    link = [NSString stringWithUTF8String:(char *)sqlite3_column_text(compiledStatement, 2)];
                }
                NSString *dateString;
                str = (char*)sqlite3_column_text(compiledStatement, 3);
                if(str == NULL){
                    dateString = @"";
                }else{
                    dateString = [NSString stringWithUTF8String:(char *)sqlite3_column_text(compiledStatement, 3)];
                }
                NSString *imageURLString;
                str = (char*)sqlite3_column_text(compiledStatement, 4);
                if(str == NULL){
                    imageURLString = @"";
                }else{
                    imageURLString = [NSString stringWithUTF8String:(char *)sqlite3_column_text(compiledStatement, 4)];
                }
                NSString *countString;
                str = (char*)sqlite3_column_text(compiledStatement, 5);
                if(str == NULL){
                    countString = @"";
                }else{
                    countString = [NSString stringWithUTF8String:(char *)sqlite3_column_text(compiledStatement, 5)];
                }
                NSInteger favorite = sqlite3_column_int(compiledStatement, 6);
                NSInteger hatebu = sqlite3_column_int(compiledStatement, 7);
                
                Item *newItem = [[Item alloc] init];
                newItem.itemId = itemId;
                newItem.title = title;
                newItem.link = link;
                newItem.dateString  = dateString;
                newItem.imageURLString = imageURLString;
                newItem.countString = countString;
                newItem.favorite = favorite;
                newItem.hatebu = hatebu;
                
                NSLog(@"title: %@", title);
//                [self.items addObject:newItem];
                //                [self.cities addObject:newCity];
            }
        }
        sqlite3_finalize(compiledStatement);
    }
    sqlite3_close(database);

}


//- (void)readAllDataWithPath:(NSString *)filePath {
//    sqlite3 *database;
//    
//    if (sqlite3_open([filePath UTF8String], &database) == SQLITE_OK) {
//        const char *sqlStatement = "select * from timememo order by id desc";
//        sqlite3_stmt *compiledStatement;
//        if (sqlite3_prepare_v2(database, sqlStatement, -1, &compiledStatement, NULL) == SQLITE_OK) {
//            while (sqlite3_step(compiledStatement) == SQLITE_ROW) {
//                //
//                //                CREATE TABLE timememo (id INTEGER PRIMARY KEY AUTOINCREMENT, year integer, month integer, day integer, hour integer, minute integer, second integer, weekday integer, memo text, color integer)
//                //
//                NSInteger timeMemoId = sqlite3_column_int(compiledStatement, 0);
//                NSInteger year = sqlite3_column_int(compiledStatement, 1);
//                NSInteger month = sqlite3_column_int(compiledStatement, 2);
//                NSInteger day = sqlite3_column_int(compiledStatement, 3);
//                NSInteger hour = sqlite3_column_int(compiledStatement, 4);
//                NSInteger minute = sqlite3_column_int(compiledStatement, 5);
//                NSInteger second = sqlite3_column_int(compiledStatement, 6);
//                NSInteger weekday = sqlite3_column_int(compiledStatement, 7);
//                
//                NSString *memo;
//                char *str = (char*)sqlite3_column_text(compiledStatement, 8);
//                if(str == NULL){
//                    memo = @"";
//                }else{
//                    memo = [NSString stringWithUTF8String:(char *)sqlite3_column_text(compiledStatement, 8)];
//                }
//                //                NSString *memo = [NSString stringWithUTF8String:(char *)sqlite3_column_text(compiledStatement, 8)];
//                NSInteger color = sqlite3_column_int(compiledStatement, 9);
//                
//                TimeMemo *newTimeMemo = [[TimeMemo alloc] init];
//                newTimeMemo.timeMemoId = timeMemoId;
//                newTimeMemo.year = year;
//                newTimeMemo.month = month;
//                newTimeMemo.day  = day;
//                newTimeMemo.hour = hour;
//                newTimeMemo.minute = minute;
//                newTimeMemo.second = second;
//                newTimeMemo.weekday = weekday;
//                newTimeMemo.memo = memo;
//                newTimeMemo.color = color;
//                NSLog(@"alldata id: %d, color: %d", timeMemoId, color);
//                [self.timeMemos addObject:newTimeMemo];
//                //                [self.cities addObject:newCity];
//            }
//        }
//        sqlite3_finalize(compiledStatement);
//    }
//    sqlite3_close(database);
//}

//- (void)saveDateWithColorNum:(NSInteger)num{
//    NSDictionary *dateDic = [self dateDictionary:[NSDate date]];
//    
//    TimeMemo *timeMemo = [[TimeMemo alloc] init];
//    timeMemo.year = [[dateDic objectForKey:@"year"] intValue];
//    timeMemo.month = [[dateDic objectForKey:@"month"] intValue];
//    timeMemo.day = [[dateDic objectForKey:@"day"] intValue];
//    timeMemo.hour = [[dateDic objectForKey:@"hour"] intValue];
//    timeMemo.minute = [[dateDic objectForKey:@"minute"] intValue];
//    timeMemo.second = [[dateDic objectForKey:@"second"] intValue];
//    timeMemo.weekday = [[dateDic objectForKey:@"weekday"] intValue];
//    timeMemo.color = num;
//    //    timeMemo.memo = @"init";
//    
//    //    timeMemo.dateString = dateString;
//    //    timeMemo.timeString = timeString;
//    
//    NSInteger maxId = [self maxIdOfDatabase];
//    NSLog(@"maxId: %d", maxId);
//    timeMemo.timeMemoId = maxId + 1;
//    NSLog(@"newId: %d", timeMemo.timeMemoId);
//    //    NSString *filePath = [self copyDatabaseToDocuments];
//    //    [self readAllDataWithPath:filePath];
//    
//    [self.items insertObject:timeMemo atIndex:0];
////    [self.timeTableViewController reloadTableView];
//    [self addTimeMemoToDatabase:timeMemo];
//    
//    for (TimeMemo *memoInArray in self.items) {
//        NSLog(@"id: %d, color: %d", memoInArray.timeMemoId, memoInArray.color);
//    }
//}


- (NSInteger)maxIdOfDatabase {
    NSInteger maxId = 0;
    
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *documentsPath = [paths objectAtIndex:0];
    NSString *filePath = [documentsPath stringByAppendingPathComponent:@"items.sqlite"];
    
    sqlite3 *database;
    if (sqlite3_open([filePath UTF8String], &database) == SQLITE_OK) {
        const char *sqlStatement = "select max(id) from timememo";
        sqlite3_stmt *compiledStatement;
        if (sqlite3_prepare_v2(database, sqlStatement, -1, &compiledStatement, NULL) == SQLITE_OK) {
            if (sqlite3_step(compiledStatement) == SQLITE_ROW) {
                maxId = sqlite3_column_int(compiledStatement, 0);
                NSLog(@"maxId: %ld", (long)maxId);
            }
        }
        sqlite3_finalize(compiledStatement);
    }
    sqlite3_close(database);
    
    return maxId;
}

- (void)addItemToDatabase:(Item *)newItem {
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *documentsPath = [paths objectAtIndex:0];
    NSString *filePath = [documentsPath stringByAppendingPathComponent:@"items.sqlite"];
    
    sqlite3 *database;
    if (sqlite3_open([filePath UTF8String], &database) == SQLITE_OK) {
        const char *sqlStatement = "insert into items (title, link ,dateString ,imageURLString, count, favorite, hatebu) VALUES (?, ?, ?, ? ,?, ?, ?)";
        sqlite3_stmt *compiledStatement;
        if (sqlite3_prepare_v2(database, sqlStatement, -1, &compiledStatement, NULL) == SQLITE_OK) {
            sqlite3_bind_text(compiledStatement, 1, [newItem.title UTF8String], -1, SQLITE_TRANSIENT);
            sqlite3_bind_text(compiledStatement, 2, [newItem.link UTF8String], -1, SQLITE_TRANSIENT);
            sqlite3_bind_text(compiledStatement, 3, [newItem.dateString UTF8String], -1, SQLITE_TRANSIENT);
            sqlite3_bind_text(compiledStatement, 4, [newItem.imageURLString UTF8String], -1, SQLITE_TRANSIENT);
            sqlite3_bind_text(compiledStatement, 5, [newItem.countString UTF8String], -1, SQLITE_TRANSIENT);
            sqlite3_bind_int(compiledStatement, 6, newItem.favorite);
            sqlite3_bind_int(compiledStatement, 7, (int)newItem.hatebu);
        } else {
            NSLog(@"%d", sqlite3_prepare_v2(database, sqlStatement, -1, &compiledStatement, NULL));
        }
        
        NSLog(@"%@",[self sqlite3StmtToString:compiledStatement]);
        
        if (sqlite3_step(compiledStatement) == SQLITE_DONE) {
            sqlite3_finalize(compiledStatement);
        } else {
            NSLog(@"error: %d", sqlite3_step(compiledStatement));
        }
        sqlite3_finalize(compiledStatement);
        
    }
    sqlite3_close(database);
    NSLog(@"inserted");
    [_items insertObject:newItem atIndex:0];
//    [_items addObject:newItem];
//    NSInteger maxId = [self maxIdOfDatabase];
//    NSLog(@"maxId: %d", maxId);
//    newTimeMemo.timeMemoId = maxId;
//
//    
//    [self selectTimeMemosFromDatabaseWithPath:filePath];
}

//http://stackoverflow.com/questions/9017766/ios-sqlite-how-to-print-a-prepared-sqlite3-stmt-to-nslog
-(NSMutableString*) sqlite3StmtToString:(sqlite3_stmt*) statement
{
    NSMutableString *s = [NSMutableString new];
    [s appendString:@"{\"statement\":["];
    for (int c = 0; c < sqlite3_column_count(statement); c++){
        [s appendFormat:@"{\"column\":\"%@\",\"value\":\"%@\"}",[NSString stringWithUTF8String:(char*)sqlite3_column_name(statement, c)],[NSString stringWithUTF8String:(char*)sqlite3_column_text(statement, c)]];
        if (c < sqlite3_column_count(statement) - 1)
            [s appendString:@","];
    }
    [s appendString:@"]}"];
    return s;
}

- (void)updateTimeMemoOfDatabaseWithId:(NSInteger)timeMemoId colorNum:(NSInteger)colorNum memo:(NSString *)memo{
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *documentsPath = [paths objectAtIndex:0];
    NSString *filePath = [documentsPath stringByAppendingPathComponent:@"items.sqlite"];
    
    sqlite3 *database;
    if (sqlite3_open([filePath UTF8String], &database) == SQLITE_OK) {
        const char *sqlStatement = "update timememo set color = ?, memo = ? where id = ?";
        sqlite3_stmt *compiledStatement;
        if (sqlite3_prepare_v2(database, sqlStatement, -1, &compiledStatement, NULL) == SQLITE_OK) {
            sqlite3_bind_int(compiledStatement, 1, (int)colorNum);
            //            NSString *str;
            //            if ([memo isEqualToString:@""]) {
            //                str = @"NULL";
            //            } else {
            //                str = memo;
            //            }
            
            sqlite3_bind_text(compiledStatement, 2, [memo UTF8String], -1, SQLITE_TRANSIENT);
            sqlite3_bind_int(compiledStatement, 3, (int)timeMemoId);
        } else {
            NSLog(@"%d", sqlite3_prepare_v2(database, sqlStatement, -1, &compiledStatement, NULL));
        }
        sqlite3_step(compiledStatement);
        //        if (sqlite3_step(compiledStatement) == SQLITE_DONE) {
        //            sqlite3_finalize(compiledStatement);
        //        }
        sqlite3_finalize(compiledStatement);
    }
    sqlite3_close(database);
}

- (void)updateItem:(NSString*)link hatebu:(NSString*)hatebu favorite:(NSInteger)favorite {
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *documentsPath = [paths objectAtIndex:0];
    NSString *filePath = [documentsPath stringByAppendingPathComponent:@"items.sqlite"];
    
    sqlite3 *database;
    if (sqlite3_open([filePath UTF8String], &database) == SQLITE_OK) {
        const char *sqlStatement = "update timememo set favorite = ? where link = ? and hatebu = ?";
        sqlite3_stmt *compiledStatement;
        if (sqlite3_prepare_v2(database, sqlStatement, -1, &compiledStatement, NULL) == SQLITE_OK) {
            sqlite3_bind_int(compiledStatement, 1, (int)favorite);
            sqlite3_bind_text(compiledStatement, 2, [link UTF8String], -1, SQLITE_TRANSIENT);
            sqlite3_bind_text(compiledStatement, 3, [hatebu UTF8String], -1, SQLITE_TRANSIENT);
        } else {
            NSLog(@"%d", sqlite3_prepare_v2(database, sqlStatement, -1, &compiledStatement, NULL));
        }
        sqlite3_step(compiledStatement);
        //        if (sqlite3_step(compiledStatement) == SQLITE_DONE) {
        //            sqlite3_finalize(compiledStatement);
        //        }
        sqlite3_finalize(compiledStatement);
    }
    sqlite3_close(database);
}

//- (void)updateItem:(NSString*)link hatebu:(NSString*)hatebu favorite:(NSInteger)favorite- (void)updateTimeMemoOfDatabaseWithId:(NSInteger)timeMemoId colorNum:(NSInteger)colorNum {
//    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
//    NSString *documentsPath = [paths objectAtIndex:0];
//    NSString *filePath = [documentsPath stringByAppendingPathComponent:@"items.sqlite"];
//    
//    sqlite3 *database;
//    if (sqlite3_open([filePath UTF8String], &database) == SQLITE_OK) {
//        const char *sqlStatement = "update timememo set color = ? where id = ?";
//        sqlite3_stmt *compiledStatement;
//        if (sqlite3_prepare_v2(database, sqlStatement, -1, &compiledStatement, NULL) == SQLITE_OK) {
//            sqlite3_bind_int(compiledStatement, 1, colorNum);
//            sqlite3_bind_int(compiledStatement, 2, timeMemoId);
//        } else {
//            NSLog(@"%d", sqlite3_prepare_v2(database, sqlStatement, -1, &compiledStatement, NULL));
//        }
//        sqlite3_step(compiledStatement);
//        //        if (sqlite3_step(compiledStatement) == SQLITE_DONE) {
//        //            sqlite3_finalize(compiledStatement);
//        //        }
//        sqlite3_finalize(compiledStatement);
//    }
//    sqlite3_close(database);
//}

//- (void)updateTimeMemoInArrayWithId:(NSInteger)timeMemoId color:(NSInteger)color memo:(NSString *)memo{
//    
//    NSLog(@"newcolor: %d", color);
//    for (TimeMemo *timeMemo in self.items) {
//        if (timeMemo.timeMemoId == timeMemoId) {
//            NSLog(@"each: %d", timeMemo.timeMemoId);
//            NSLog(@"timemo: %d", timeMemoId);
//            NSLog(@"0color: %d", timeMemo.color);
//            NSLog(@"memo: %@", timeMemo.memo);
//            timeMemo.color = color;
//            timeMemo.memo = memo;
//            NSLog(@"color: %d", timeMemo.color);
//            NSLog(@"memo: %@", timeMemo.memo);
//        }
//    }
////    [self.timeTableViewController reloadTableView];
//}


- (void)updateTimeMemoOfDatabaseWithId:(NSInteger)timeMemoId memo:(NSString *)memo{
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *documentsPath = [paths objectAtIndex:0];
    NSString *filePath = [documentsPath stringByAppendingPathComponent:@"items.sqlite"];
    
    sqlite3 *database;
    if (sqlite3_open([filePath UTF8String], &database) == SQLITE_OK) {
        const char *sqlStatement = "update timememo set memo = ? where id = ?";
        sqlite3_stmt *compiledStatement;
        if (sqlite3_prepare_v2(database, sqlStatement, -1, &compiledStatement, NULL) == SQLITE_OK) {
            //            NSString *str;
            //            if ([memo isEqualToString:@""]) {
            //                str = @"NULL";
            //            } else {
            //                str = memo;
            //            }
            
            sqlite3_bind_text(compiledStatement, 1, [memo UTF8String], -1, SQLITE_TRANSIENT);
            sqlite3_bind_int(compiledStatement, 2, (int)timeMemoId);
        } else {
            NSLog(@"%d", sqlite3_prepare_v2(database, sqlStatement, -1, &compiledStatement, NULL));
        }
        sqlite3_step(compiledStatement);
        //        if (sqlite3_step(compiledStatement) == SQLITE_DONE) {
        //            sqlite3_finalize(compiledStatement);
        //        }
        sqlite3_finalize(compiledStatement);
        
    }
    sqlite3_close(database);
}


- (void)removeAllTimeMemoOfDatabase{
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *documentsPath = [paths objectAtIndex:0];
    NSString *filePath = [documentsPath stringByAppendingPathComponent:@"items.sqlite"];
//    [self selectTimeMemosFromDatabaseWithPath:filePath];

    sqlite3 *database;
    if (sqlite3_open([filePath UTF8String], &database) == SQLITE_OK) {
        const char *sqlStatement = "delete from items";
        sqlite3_stmt *compiledStatement;
        if (sqlite3_prepare_v2(database, sqlStatement, -1, &compiledStatement, NULL) == SQLITE_OK) {
        } else {
            NSLog(@"%d", sqlite3_prepare_v2(database, sqlStatement, -1, &compiledStatement, NULL));
        }
        
        if (sqlite3_step(compiledStatement) == SQLITE_DONE) {
            //            sqlite3_finalize(compiledStatement);
        }
        sqlite3_finalize(compiledStatement);
        
    }
    sqlite3_close(database);
}

- (void)removeItemURL:(NSString *)urlString hatebu:(NSInteger)hatebu {
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *documentsPath = [paths objectAtIndex:0];
    NSString *filePath = [documentsPath stringByAppendingPathComponent:@"items.sqlite"];
    
    sqlite3 *database;
    if (sqlite3_open([filePath UTF8String], &database) == SQLITE_OK) {
        const char *sqlStatement = "delete from items where link = ? and hatebu = ?";
        sqlite3_stmt *compiledStatement;
        if (sqlite3_prepare_v2(database, sqlStatement, -1, &compiledStatement, NULL) == SQLITE_OK) {
            NSLog(@"sqlok_delete__");
        } else {
            NSLog(@"delete_err__: %d", sqlite3_prepare_v2(database, sqlStatement, -1, &compiledStatement, NULL));
        }
        
        sqlite3_bind_text(compiledStatement, 1, [urlString UTF8String], -1, SQLITE_TRANSIENT);
        sqlite3_bind_int(compiledStatement, 2, (int)hatebu);
        
        
        if (sqlite3_step(compiledStatement) == SQLITE_DONE) {
            //            sqlite3_finalize(compiledStatement);
//            NSLog(@"■■deleted::%d", timeMemoId);
            NSLog(@"deleted___");
        }
        sqlite3_finalize(compiledStatement);
    }
    sqlite3_close(database);
    NSMutableArray *delIndexes = [NSMutableArray array];
    for (int i=0; i<_items.count; i++) {
        Item *item = [_items objectAtIndex:i];
        if ([item.link isEqualToString:urlString] && item.hatebu == hatebu) {
            [delIndexes addObject:[NSNumber numberWithInt:i]];
            break;
        }
    }
    
    for (NSNumber *num in delIndexes) {
        NSInteger delIndex = [num integerValue];
        [_items removeObjectAtIndex:delIndex];
        break;
    }
    
    
//    [self selectTimeMemosFromDatabaseWithPath:filePath];

}

//- (void)removeTimeMemosOfDatabaseAtIndexPath:(NSArray *)indexPathArray{
//    NSArray *reverseIndexPathArray = [[indexPathArray reverseObjectEnumerator] allObjects];
//    NSMutableArray *removeArray = [[NSMutableArray alloc] init];
//    NSLog(@"iparray: %@", indexPathArray);
//    for (NSIndexPath *indexPath in reverseIndexPathArray) {
//        NSLog(@"indexPath: %@", indexPath);
//        TimeMemo *timeMemoToDelete = [self.items objectAtIndex:indexPath.row];
//        [removeArray addObject:timeMemoToDelete];
//        NSLog(@"delete Id: %d1", timeMemoToDelete.timeMemoId);
////        [self.timeMemos removeObjectAtIndex:indexPath.row];
//    }
//    [self removeTimeMemosOfDatabaseAtIdNumsArray:indexPathArray];
//    NSLog(@"removaarray: %@", removeArray);
//    [self.items removeObjectsInArray:removeArray];
//    NSLog(@"timememos: %@", self.items);
//
////    [self removeTimeMemoOfDatabaseAtId:timeMemoToDelete.timeMemoId];
//}

//- (void)removeTimeMemosOfDatabaseAtIdNumsArray:(NSArray *)indexPathArray{
//    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
//    NSString *documentsPath = [paths objectAtIndex:0];
//    NSString *filePath = [documentsPath stringByAppendingPathComponent:@"Items.sqlite"];
////    where id = 1 or id = 2
//    NSString *whereState = @"where id=0 or";
//    for (NSIndexPath *indexPath in indexPathArray) {
//        whereState = [whereState stringByAppendingFormat:@" id=%d", indexPath.row];
//    }
//    
//    sqlite3 *database;
//    if (sqlite3_open([filePath UTF8String], &database) == SQLITE_OK) {
//        
//        const char *sqlStatement = "select * from timememo";
//        sqlite3_stmt *compiledStatement;
//        if (sqlite3_prepare_v2(database, sqlStatement, -1, &compiledStatement, NULL) == SQLITE_OK) {
//        } else {
//            NSLog(@"%d", sqlite3_prepare_v2(database, sqlStatement, -1, &compiledStatement, NULL));
//        }
//        
////        sqlite3_bind_int(compiledStatement, 1, timeMemoId);
////        sqlite3_bind_text(compiledStatement, 1, [whereState UTF8String], -1, SQLITE_TRANSIENT);
//        
//        NSLog(@"stmt: %@", compiledStatement);
//        NSLog(@"%@",[self sqlite3StmtToString:compiledStatement]);
//
////        while (sqlite3_step(compiledStatement) == SQLITE_DONE) {
//        while (sqlite3_step(compiledStatement) == SQLITE_ROW) {
//            //            sqlite3_finalize(compiledStatement);
////            NSLog(@"■■deleted::%d", timeMemoId);
//            NSLog(@"row");
//        }
//        sqlite3_finalize(compiledStatement);
//        
//    }
//    sqlite3_close(database);
//    [self selectTimeMemosFromDatabaseWithPath:filePath];
//    
//}

- (void)sayData
{
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *documentsPath = [paths objectAtIndex:0];
    NSString *filePath = [documentsPath stringByAppendingPathComponent:@"items.sqlite"];

    [self selectTimeMemosFromDatabaseWithPath:filePath];
}

//- (void)removeTimeMemosOfDatabaseAtIdNumsArray:(NSArray *)indexPathArray{
//    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
//    NSString *documentsPath = [paths objectAtIndex:0];
//    NSString *filePath = [documentsPath stringByAppendingPathComponent:@"Items.sqlite"];
//    NSString *whereState = @"where id=0";
//    NSLog(@"indexPathArray: %@", indexPathArray);
//    for (NSIndexPath *indexPath in indexPathArray) {
////        TimeMemo* timeMemo = [TimeMemo ]
//        TimeMemo *timeMemoToDelete = [self.items objectAtIndex:indexPath.row];
//        NSLog(@"delete Id: %d", timeMemoToDelete.timeMemoId);
////        [self.timeMemos removeObjectAtIndex:indexPath.row];
////        [self removeTimeMemoOfDatabaseAtId:timeMemoToDelete.timeMemoId];
//
//        
//        whereState = [whereState stringByAppendingFormat:@" or id=%d", timeMemoToDelete.timeMemoId];
//    }
//    
//    NSLog(@"where: %@", whereState);
//
//    sqlite3 *database;
//    if (sqlite3_open([filePath UTF8String], &database) == SQLITE_OK) {
//        
////        NSString *deleteSQL = [NSString stringWithFormat:@"DELETE FROM timememo WHERE %@",[NSString stringWithFormat:@"id > 0"]];
//        NSString *deleteSQL = [NSString stringWithFormat:@"DELETE FROM timememo  %@", whereState];
//        NSLog(@"%@", deleteSQL);
//        
//        // SQL文のコンパイルと実行
//        sqlite3_stmt *statement = Nil;
//        if( sqlite3_prepare_v2(database, [deleteSQL UTF8String], -1, &statement, NULL ) != SQLITE_OK) {
//            NSLog(@"not OK");
//        } else {
//            int wasPrepared = sqlite3_prepare_v2(database, [deleteSQL UTF8String], -1, &statement, NULL );
//            int wasSucceeded = sqlite3_step(statement);
//            NSLog(@"int: %d", wasSucceeded);
//            NSLog(@"preapred: %d", wasPrepared);
//        }
//        sqlite3_finalize(statement);
//        
//        
////        const char *sqlStatement = "delete from timememo where id > ?";
////        sqlite3_stmt *compiledStatement;
////        if (sqlite3_prepare_v2(database, sqlStatement, -1, &compiledStatement, NULL) == SQLITE_OK) {
////            NSLog(@"SQLITE_OK");
////        } else {
////            NSLog(@"%d", sqlite3_prepare_v2(database, sqlStatement, -1, &compiledStatement, NULL));
////        }
//        
////        NSLog(@"bind: %d", sqlite3_bind_text(compiledStatement, 1, [whereState UTF8String], -1, SQLITE_TRANSIENT));
////        NSLog(@"bind: %d", sqlite3_bind_text(compiledStatement, 1, [whereState UTF8String], -1, SQLITE_TRANSIENT));
//        
////        sqlite3_bind_int(compiledStatement, 1, 1);
////        NSString *str = [NSString stringWithFormat:@"19"];
////        sqlite3_bind_text(compiledStatement, 1, [str UTF8String], -1, SQLITE_STATIC);
//
////        NSLog(@"stmt: %@", compiledStatement);
////        NSLog(@"%@",[self sqlite3StmtToString:compiledStatement]);
//        
//        //        while (sqlite3_step(compiledStatement) == SQLITE_DONE) {
////        NSLog(@"sqlite3_step: %d", sqlite3_step(compiledStatement));
////        while (sqlite3_step(compiledStatement) == SQLITE_ROW) {
////            //            sqlite3_finalize(compiledStatement);
////            //            NSLog(@"■■deleted::%d", timeMemoId);
////            NSLog(@"row");
////        }
////        sqlite3_finalize(compiledStatement);
//        
//    }
//    sqlite3_close(database);
//    [self selectTimeMemosFromDatabaseWithPath:filePath];
//    
//}


//- (void)removeTimeMemoAtIndexPath: (NSIndexPath *)indexPath{
//    TimeMemo *timeMemoToDelete = [self.items objectAtIndex:indexPath.row];
//    NSLog(@"delete Id: %d", timeMemoToDelete.timeMemoId);
//    [self.items removeObjectAtIndex:indexPath.row];
//    [self removeTimeMemoOfDatabaseAtId:timeMemoToDelete.timeMemoId];
//}

//- (NSString*)allDataString
//{
//    NSString *string = [[NSString alloc] init];
//    sqlite3 *database;
//    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
//    NSString *documentsPath = [paths objectAtIndex:0];
//    NSString *filePath = [documentsPath stringByAppendingPathComponent:@"Items.sqlite"];
//
//    
//    if (sqlite3_open([filePath UTF8String], &database) == SQLITE_OK) {
//        const char *sqlStatement = "select * from timememo order by id desc";
//        sqlite3_stmt *compiledStatement;
//        if (sqlite3_prepare_v2(database, sqlStatement, -1, &compiledStatement, NULL) == SQLITE_OK) {
//            while (sqlite3_step(compiledStatement) == SQLITE_ROW) {
//                //
//                //                CREATE TABLE timememo (id INTEGER PRIMARY KEY AUTOINCREMENT, year integer, month integer, day integer, hour integer, minute integer, second integer, weekday integer, memo text, color integer)
//                //
//                NSInteger timeMemoId = sqlite3_column_int(compiledStatement, 0);
//                NSInteger year = sqlite3_column_int(compiledStatement, 1);
//                NSInteger month = sqlite3_column_int(compiledStatement, 2);
//                NSInteger day = sqlite3_column_int(compiledStatement, 3);
//                NSInteger hour = sqlite3_column_int(compiledStatement, 4);
//                NSInteger minute = sqlite3_column_int(compiledStatement, 5);
//                NSInteger second = sqlite3_column_int(compiledStatement, 6);
//                NSInteger weekday = sqlite3_column_int(compiledStatement, 7);
//                
//                NSString *memo;
//                char *str = (char*)sqlite3_column_text(compiledStatement, 8);
//                if(str == NULL){
//                    memo = @"";
//                }else{
//                    memo = [NSString stringWithUTF8String:(char *)sqlite3_column_text(compiledStatement, 8)];
//                }
//                //                NSString *memo = [NSString stringWithUTF8String:(char *)sqlite3_column_text(compiledStatement, 8)];
//                NSInteger color = sqlite3_column_int(compiledStatement, 9);
//                
//                TimeMemo *newTimeMemo = [[TimeMemo alloc] init];
//                newTimeMemo.timeMemoId = timeMemoId;
//                newTimeMemo.year = year;
//                newTimeMemo.month = month;
//                newTimeMemo.day  = day;
//                newTimeMemo.hour = hour;
//                newTimeMemo.minute = minute;
//                newTimeMemo.second = second;
//                newTimeMemo.weekday = weekday;
//                newTimeMemo.memo = memo;
//                newTimeMemo.color = color;
////                NSString *newTimeMemoString = [NSString stringWithFormat:@""];
//                string = [string stringByAppendingString:[NSString stringWithFormat:@"%@\n", newTimeMemo.timeMemoString]];
//                NSLog(@"string: %@", string);
//            }
//        }
//        sqlite3_finalize(compiledStatement);
//    }
//    sqlite3_close(database);
//    return string;
//}

@end
