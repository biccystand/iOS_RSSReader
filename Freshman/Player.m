//
//  Player.m
//  SquareCam 
//
//  Created by masaki on 2014/02/26.
//
//

#import "Player.h"
#import "UIView+TSExtention.h"
#import "config.h"

@implementation Player

//- (id)initOnView
//{
//    self.width = 60;
//    self.height = 60;
//    self.x = 100;
//    self.y = 100;
//    self = [super initWithFrame:CGRectMake(self.x, self.y, self.width, self.height)];
//    return self;
//}
//
- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
    }
    return self;
}

- (CGPoint)topRight
{
    float top = 0;
    float right = kScreenWidth - self.width;
    return CGPointMake(right, top);
}

- (CGPoint)bottomLeft
{
    float bottom = kScreenHeight - kAdbarHeight - kToolBarHeight;
    float left = 0;
    return CGPointMake(left, bottom);
}

- (void)moveX:(NSInteger)dx moveY: (NSInteger)dy
{
    self.x += dx;
    self.y += dy;
    if (self.x < self.bottomLeft.x) {
        NSLog(@"hright: %f", self.bottomLeft.x);
        self.x = self.bottomLeft.x;
    }
    else if (self.x > self.topRight.x) {
        NSLog(@"tright: %f", self.topRight.x);
        self.x = self.topRight.x;
    }

    if (self.y < self.topRight.y) {
        self.y = 0;
    }
    else if (self.y > self.bottomLeft.y) {
        self.y = self.bottomLeft.y;
    }
    
    NSLog(@"position: %f, %f", self.x, self.y);
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
