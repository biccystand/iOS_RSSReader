//
//  HUDView.h
//  SquareCam 
//
//  Created by masaki on 2014/03/02.
//
//

#import <UIKit/UIKit.h>
@class StopwatchView;
@class CounterLabelView;
@class HiScoreView;

@interface HUDView : UIView
@property (strong, nonatomic) StopwatchView* stopwatch;
@property (strong, nonatomic) CounterLabelView* gamePoints;
@property (strong, nonatomic) UIButton* btnHelp;
@property (strong, nonatomic) HiScoreView *hiscoreView;
+(instancetype)viewWithRect:(CGRect)r;
@end
