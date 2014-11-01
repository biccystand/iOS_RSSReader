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
        NSLog(@"pleyerframe:%f,%f,%f,%f", frame.origin.x, frame.origin.y, frame.size.width, frame.size.height);
        self.button = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, frame.size.width, frame.size.height)];
        self.button.backgroundColor = [UIColor clearColor];
        [self addSubview:self.button];
    }
    return self;
}

- (CGPoint)topRight
{
//    float top = 0;
    float top = _mainGameFrame.origin.y;
    float right = kScreenWidth - self.width;
    return CGPointMake(right, top);
}

- (CGPoint)bottomLeft
{
//    float bottom = kScreenHeight - kAdbarHeight - kToolBarHeight;
    float bottom = _mainGameFrame.origin.y + _mainGameFrame.size.height;
    float left = 0;
    
    return CGPointMake(left, bottom);
}

- (CGPoint)centerOfArea
{
    float centerX = (self.topRight.x + self.bottomLeft.x)/2.0f;
    float centerY = (self.topRight.y + self.bottomLeft.y)/2.0f;
    return CGPointMake(centerX, centerY);
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
        self.y = self.topRight.y;
        self.backgroundColor = [UIColor orangeColor];
    }
    else if (self.y > self.bottomLeft.y - self.height) {
        self.y = self.bottomLeft.y - self.height;
        self.backgroundColor = [UIColor greenColor];
    }
    
    NSLog(@"position: %f, %f", self.x, self.y);

//    int ivSize = (int)self.width;
//    int ivHeight = (int)self.height;

//    CGPoint p = CGPointMake(randomf(ivSize, (int)(kScreenWidth)-ivSize), randomf(kToolBarHeight+kStatusBarHeight+ivHeight, (int)(480-kAdbarHeight-kTabbarHeight-ivHeight-kBButtonHeight)));

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
