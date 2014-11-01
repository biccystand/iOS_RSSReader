//
//  CounterLabelView.h
//  SquareCam 
//
//  Created by masaki on 2014/03/02.
//
//

#import <UIKit/UIKit.h>

@interface CounterLabelView : UILabel
@property (assign, nonatomic) int value;
+(instancetype)labelWithFont:(UIFont*)font frame:(CGRect)r andValue:(int)v;
-(void)countTo:(int)to withDuration:(float)t;
-(void)setValue:(int)value;
@end
