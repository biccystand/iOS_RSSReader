//
//  Player.h
//  SquareCam 
//
//  Created by masaki on 2014/02/26.
//
//

#import <UIKit/UIKit.h>

@interface Player : UIImageView
@property (nonatomic, assign) CGPoint topRight;
@property (nonatomic, assign) CGPoint bottomLeft;
//- (id)initOnView;
- (void)moveX:(NSInteger)dx moveY: (NSInteger)dy;
@end
