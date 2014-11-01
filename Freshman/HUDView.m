//
//  HUDView.m
//  SquareCam 
//
//  Created by masaki on 2014/03/02.
//
//

#import "HUDView.h"
#import "StopwatchView.h"
#import "CounterLabelView.h"
#import "HiScoreView.h"
#import "config.h"

@implementation HUDView
+(instancetype)viewWithRect:(CGRect)r
{
    HUDView* hud = [[HUDView alloc] initWithFrame:r];
    hud.userInteractionEnabled = YES;
    
    hud.stopwatch = [[StopwatchView alloc] initWithFrame:CGRectMake(14, kStatusBarHeight+kToolBarHeight, kScreenWidth/4.0f-14, kHUDLabelHeight)];
    hud.stopwatch.textAlignment = NSTextAlignmentLeft;
    [hud.stopwatch setSeconds:0];
    hud.stopwatch.textColor = ColorPink;
    [hud addSubview:hud.stopwatch];
    
    hud.gamePoints = [CounterLabelView labelWithFont:kFontHUD frame:CGRectMake(kScreenWidth/4.0f, kStatusBarHeight+kToolBarHeight, kScreenWidth*3.0f/8.0f, kHUDLabelHeight) andValue:0];
    hud.gamePoints.textColor = ColorPink;
    [hud addSubview:hud.gamePoints];
    
    hud.hiscoreView = [HiScoreView labelWithFont:kFontHUD frame:CGRectMake(kScreenWidth*5.0f/8.0f, kStatusBarHeight+kToolBarHeight, kScreenWidth*3.0f/8.0f, kHUDLabelHeight) andValue:0];
    hud.hiscoreView.textColor = ColorPink;
    [hud addSubview:hud.hiscoreView];
    
    hud.gamePoints.backgroundColor = [UIColor clearColor];
    hud.stopwatch.backgroundColor = [UIColor clearColor];
    hud.hiscoreView.backgroundColor = [UIColor clearColor];
    
    hud.gamePoints.textAlignment = NSTextAlignmentCenter;
    hud.stopwatch.textAlignment = NSTextAlignmentCenter;
    hud.hiscoreView.textAlignment = NSTextAlignmentCenter;
//    hud.backgroundColor = [UIColor redColor];
    
    UIFont *font = [UIFont fontWithName:@"Ka-Boing!.ttf" size:1];
    NSLog(@"font: %@", font);
    
    return hud;
}

-(id)hitTest:(CGPoint)point withEvent:(UIEvent *)event
{
    // let touches through and only catch the ones on buttons
    UIView* hitView = (UIView*)[super hitTest:point withEvent:event];
    
    if ([hitView isKindOfClass:[UIButton class]]) {
        return hitView;
    }
    
    return nil;
    
}

@end
