//
//  AlertMessage.m
//  SquareCam 
//
//  Created by masaki on 2014/03/19.
//
//

#import "AlertMessage.h"
#import "Colours.h"
#import "config.h"

@implementation AlertMessage
+ (AlertMessage*)sharedInstance
{
    static AlertMessage *_sharedInstance = nil;
    static dispatch_once_t oncePredicate;
    
    dispatch_once(&oncePredicate, ^{
        _sharedInstance = [[AlertMessage alloc] init];
    });
    return _sharedInstance;
}

- (NSString*)alertMessageOnTimeout:(BOOL)timeout onTutorial:(BOOL)onTutorial withScore:(NSInteger)score withHiscore:(NSInteger)hiscore
{
    NSString *message;
    if (timeout) {
        if (onTutorial) {
            message = [NSString stringWithFormat:@"小顔になれるゲーム「小顔っくま」のチュートリアルで %d 点とったよ！", (int)score];
        }
        else {
            message = [NSString stringWithFormat:@"小顔になれるゲーム「小顔っくま」で %d点とったよ！", (int)score];
            if (score == hiscore) {
                message = [message stringByAppendingString:@"\n自己記録更新！"];
            }
        }
    }
    else
    {
        if (onTutorial) {
            message = @"チュートリアルを中止します。";
        }
        else
        {
            message = @"ゲームを中止します。";
        }
    }

    return message;
}

- (NSMutableArray*)buttonArrayOnTimeout:(BOOL)timeout onTutorial:(BOOL)onTutorial onArticle:(BOOL)onArticle
{
    NSMutableArray *array;
    if (onArticle) {
        array = [NSMutableArray arrayWithObjects:@"LINE", @"Twitter", @"Facebook", @"閉じる", nil];
    }
    else
    {
        if (timeout) {
            array = [NSMutableArray arrayWithObjects:@"LINE", @"Twitter", @"Facebook", @"OK", nil];
        }
        else
        {
            array = [NSMutableArray arrayWithObjects:@"OK", nil];
            
        }
    }
    return array;
}

- (NSMutableArray*)buttonColorsArrayOnTimeout:(BOOL)timeout onTutorial:(BOOL)onTutorial
{
    NSMutableArray *array;
    if (timeout) {
        array = [NSMutableArray arrayWithObjects:[UIColor successColor], ColorTwitter, ColorFacebook, ColorPink, nil];
//         [UIColor colorWithRed:0.0f green:0.5f blue:1.0f alpha:1.0f]
    }
    else
    {
        array = [NSMutableArray arrayWithObjects:ColorPink,nil];
        
    }
    return array;
}

@end
