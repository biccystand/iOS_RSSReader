//
//  Item.h
//  NewsReader
//
//  Created by Dolice on 2013/03/02.
//  Copyright (c) 2013年 Dolice. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface Item : NSObject
@property (nonatomic, copy) NSString *title;
@property (nonatomic, copy) NSString *description;
@property (nonatomic, copy) NSString *subject;
@property (nonatomic, copy) NSString *link;
@property (nonatomic, copy) NSString *dateString;
@property (nonatomic, copy) NSString *imageURLString;
//@property (nonatomic, copy) NSString *linkString;
//@property (nonatomic, copy) NSString *countString;
@property (nonatomic, strong) UIImage *image;
@property (nonatomic, strong) NSDate *date;
@property (nonatomic, assign) NSInteger count;
@property (nonatomic, assign) BOOL favorite;
@property (nonatomic, assign) NSInteger itemId;
@property (nonatomic, copy) NSString *countString;
@property (nonatomic, assign) NSInteger hatebu;
@end
