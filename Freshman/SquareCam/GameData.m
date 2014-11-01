//
//  GameData.m
//  SquareCam 
//
//  Created by masaki on 2014/02/27.
//
//

#import "GameData.h"

@implementation GameData
- (void)setPoints:(int)points
{
    _points = MAX(points, 0);
}

- (void)setMaxPoints:(int)maxPoints
{
    _maxPoints = MAX(maxPoints, _points);
}
@end
