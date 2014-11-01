//
//  HiScoreView.h
//  SquareCam 
//
//  Created by masaki on 2014/03/14.
//
//

#import <UIKit/UIKit.h>

@interface HiScoreView : UILabel
@property (assign, nonatomic) int value;
+(instancetype)labelWithFont:(UIFont*)font frame:(CGRect)r andValue:(int)v;
-(void)setValue:(int)value;
-(void)countTo:(int)to withDuration:(float)t;
@end
