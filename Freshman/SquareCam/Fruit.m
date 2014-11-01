//
//  Fruit.m
//  SquareCam 
//
//  Created by masaki on 2014/02/26.
//
//

#import "Fruit.h"
#import "UIView+TSExtention.h"

@implementation Fruit

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
    }
    return self;
}

- (void)animateMoveX:(CGFloat)dx moveY:(CGFloat)dy duration:(CGFloat)duration
{
//    [UIView animateWithDuration:duration animations:^{
//        self.x += dx;
//        self.y += dy;
//    }];
    [UIView animateWithDuration:duration animations:^{
        self.x += dx;
//        self.y += 1;
    } completion:^(BOOL finished){
        [self animateMoveX:-dx moveY:-dy duration:duration];
    }];
}

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect
{
    // Drawing code
}
*/

@end
