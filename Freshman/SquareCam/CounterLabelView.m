//
//  CounterLabelView.m
//  SquareCam 
//
//  Created by masaki on 2014/03/02.
//
//

#import "CounterLabelView.h"

@implementation CounterLabelView
{
    int endValue;
    double delta;
}

+ (instancetype)labelWithFont:(UIFont *)font frame:(CGRect)r andValue:(int)v
{
    CounterLabelView* label = [[CounterLabelView alloc] initWithFrame:r];
    if (label!=nil) {
        label.backgroundColor = [UIColor clearColor];
        label.font = font;
        label.value = v;
    }
    return label;
}

- (void)setValue:(int)value
{
    _value = value;
    self.text = [NSString stringWithFormat:@"SCORE: %i", self.value];
}

- (void)updateValueBy:(NSNumber*)valueDelta
{
    self.value += [valueDelta intValue];
    if ([valueDelta intValue]>0) {
        if (self.value > endValue) {
            self.value = endValue;
            return;
        }
    } else {
        if (self.value < endValue) {
            self.value = endValue;
            return;
        }
    }
    [self performSelector:@selector(updateValueBy:) withObject:valueDelta afterDelay:delta];
}

- (void)flashLabel
{
    [UIView animateWithDuration:0.1f delay:0.0f options:UIViewAnimationOptionCurveEaseIn animations:^{
        self.transform = CGAffineTransformMakeScale(1.5f, 1.5f);
    }completion:^(BOOL finished){
        [UIView animateWithDuration:0.1f delay:0.0f options:UIViewAnimationOptionCurveLinear animations:^{
            self.transform = CGAffineTransformMakeScale(1.0f, 1.0f);
        }completion:^(BOOL finished2){
            NSLog(@"aa");
        }];
    }];
}

- (void)countTo:(int)to withDuration:(float)t
{
    self.value = to;
    [self flashLabel];
    return;
    
    delta = t/(abs(to-self.value)+1);
    if (delta < 0.05) delta = 0.05;
    endValue = to;
    [NSObject cancelPreviousPerformRequestsWithTarget:self];
    
    if (to-self.value>0) {
        [self updateValueBy:@1];
    } else {
        [self updateValueBy:@-1];
    }
}
@end
