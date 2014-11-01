//
//  Fruit.h
//  SquareCam 
//
//  Created by masaki on 2014/02/26.
//
//

#import <UIKit/UIKit.h>
@class Fruit;
@protocol FruitDelegateProtocol <NSObject>
- (void)dectectCollision:(Fruit*)fruit;
@end

@interface Fruit : UIImageView
@property (weak, nonatomic) id<FruitDelegateProtocol> delegate;
@property (nonatomic, assign) NSInteger index;
- (void)animateMoveX:(CGFloat)dx moveY:(CGFloat)dy duration:(CGFloat)duration;
@end
