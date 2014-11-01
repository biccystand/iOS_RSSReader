//
//  StopwatchView.m
//  SquareCam 
//
//  Created by masaki on 2014/03/02.
//
//

#import "StopwatchView.h"
#import "config.h"

@implementation StopwatchView

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
        self.backgroundColor = [UIColor clearColor];
        self.font = kFontHUD;
    }
    return self;
}

- (void)setSeconds:(int)seconds
{
    self.text = [NSString stringWithFormat:@"TIME: %d", seconds];
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
