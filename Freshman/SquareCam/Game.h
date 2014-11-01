//
//  Game.h
//  SquareCam 
//
//  Created by masaki on 2014/02/27.
//
//

#import <Foundation/Foundation.h>

@interface Game : NSObject
@property (nonatomic, assign) int fruitNum;
@property (nonatomic, assign) BOOL animateFruit;
@property (nonatomic, assign) int timeToSolve;
@property (nonatomic, assign) int pointsPerFruit;
@property (nonatomic, assign) int gameNum;
+ (instancetype)gameWithNum:(int)gameNum;
@end
