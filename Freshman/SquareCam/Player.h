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
@property (nonatomic, assign) CGPoint centerOfArea;
@property (nonatomic, assign) CGRect mainGameFrame;
@property (nonatomic, strong) UIButton *button;
- (void)moveX:(NSInteger)dx moveY: (NSInteger)dy;
@end
