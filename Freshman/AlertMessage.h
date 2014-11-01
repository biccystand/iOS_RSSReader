//
//  AlertMessage.h
//  SquareCam 
//
//  Created by masaki on 2014/03/19.
//
//

#import <Foundation/Foundation.h>

@interface AlertMessage : NSObject
+ (AlertMessage*)sharedInstance;
- (NSString*)alertMessageOnTimeout:(BOOL)timeout onTutorial:(BOOL)onTutorial withScore:(NSInteger)score withHiscore:(NSInteger)hiscore;
- (NSMutableArray*)buttonArrayOnTimeout:(BOOL)timeout onTutorial:(BOOL)onTutorial onArticle:(BOOL)onArticle;
- (NSMutableArray*)buttonColorsArrayOnTimeout:(BOOL)timeout onTutorial:(BOOL)onTutorial;
@end
