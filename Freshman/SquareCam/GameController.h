//
//  GameController.h
//  SquareCam 
//
//  Created by masaki on 2014/02/27.
//
//

#import <Foundation/Foundation.h>
#import <AVFoundation/AVFoundation.h>

#import "Fruit.h"
#import "CMPopTipView.h"

@class Game;
@class GameData;
@class HUDView;
@class SquareCamViewController;

typedef void (^CallbackBlock)();
@interface GameController : NSObject <FruitDelegateProtocol, AVAudioPlayerDelegate, CMPopTipViewDelegate>
@property (weak, nonatomic) SquareCamViewController *squareCamViewController;
@property (weak, nonatomic) UIView *gameView;
@property (strong, nonatomic) Game *game;
@property (strong, nonatomic) CallbackBlock onGameOver;
@property (strong, nonatomic) GameData* data;
@property (weak, nonatomic) HUDView* hud;
@property (nonatomic, assign) BOOL playingGame;
@property (nonatomic) AVAudioPlayer *audioPlayer;
@property (nonatomic, strong)	NSArray			*colorSchemes;
@property (nonatomic, strong)	NSDictionary	*popContents;
@property (nonatomic, strong)	id				currentPopTipViewTarget;
@property (nonatomic, strong
           )	NSDictionary	*titles;
@property (nonatomic, strong)	NSMutableArray	*visiblePopTipViews;
@property (nonatomic, assign) BOOL tutorial;
- (void)setupEntities;
- (void)setUpHud: (HUDView*)hudView;
- (void)reactToFaceFeature:(CIFaceFeature*)faceFeature;
- (void)startGame;
- (void)stopGameOnTimeout:(BOOL)timeOut;
- (void)dectectCollision:(Fruit*)fruit;
@end
