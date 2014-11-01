//
//  Game.m
//  SquareCam 
//
//  Created by masaki on 2014/02/27.
//
//

#import "Game.h"

@implementation Game
+ (instancetype)gameWithNum:(int)gameNum
{
    NSString* fileName = [NSString stringWithFormat:@"game.plist"];
    NSString* gamePath = [[[NSBundle mainBundle] resourcePath] stringByAppendingPathComponent:fileName];
    
    NSLog(@"path: %@", gamePath);
    NSArray *gameArray = [NSArray arrayWithContentsOfFile:gamePath];
    NSDictionary* gameDict = [gameArray objectAtIndex:(gameNum-1)];
//    NSDictionary* gameDict = [NSDictionary dictionaryWithContentsOfFile:gamePath];
    NSAssert(gameDict, @"game config file not found");
    
    Game* g = [[Game alloc] init];
    g.fruitNum = [gameDict[@"fruitNum"] intValue];
    g.timeToSolve = [gameDict[@"timeToSolve"] intValue];
    g.animateFruit = [gameDict[@"animateFruit"] intValue];
    g.pointsPerFruit = [gameDict[@"pointsPerFruit"] intValue];
    g.gameNum = gameNum;
    
    return g;
}
@end
