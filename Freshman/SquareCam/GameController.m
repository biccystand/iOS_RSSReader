//
//  GameController.m
//  SquareCam 
//
//  Created by masaki on 2014/02/27.
//
//

#import "GameController.h"
#import "Player.h"
#import "UIView+TSExtention.h"
#import "Game.h"
#import "GameData.h"
#import "CounterLabelView.h"
#import "HiScoreView.h"
#import "StopwatchView.h"
#import "HUDView.h"
#import "PopTipManager.h"
#import "config.h"
#import "CustomIOS7AlertView.h"
#import "AlertMessage.h"
#import "DCSocial.h"
#import "SquareCamViewController.h"


#define randomf(minX,maxX) ((float)(arc4random() % (maxX - minX + 1)) + (float)minX)
#define kDt 0.1
#define kTutorialMoveSteps 2

typedef enum EntityTag {
    PlayerEntityTag = 10,
    FruitEntityTag
} EntityTag;

@interface GameController() <CustomIOS7AlertViewDelegate>

@end

@implementation GameController
{
    Player *_player;
//    UILabel *_timeLabel;
//    UILabel *_scoreLabel;
    BOOL _timeOut;
    NSMutableArray* _fruits;
    NSTimer *_timer;
    int _timerTicked;
    int _secondsLeft;
    float _timerCount;
    CGRect _mainGameFrame;
    NSUserDefaults *userDefaults;
    NSInteger hiScore;
    NSInteger score;
    PopTipManager *_popTipManager;
    NSInteger _tutorialNumber;
    BOOL _sleepGame;
    NSMutableArray *_tutorialProgressArray;
    NSString *message;
    BOOL _tutorialStepEnded;
    BOOL _tutorialGamePlaying;
    NSInteger _tutorialMoveSteps;
}

- (instancetype)init
{
    self = [super init];
    if (self != nil) {
        userDefaults = [NSUserDefaults standardUserDefaults];
        self.data = [[GameData alloc] init];
        self.data.maxPoints = (int)[userDefaults integerForKey:@"hiScore"];
        _playingGame = NO;
        [self prepareAudio];
        [self setUpPopTipView];
        NSLog(@"contents: %@", _popContents);

        if (kScreenHeight == kScreen35Height) {
            _mainGameFrame = kMainGame35Rect;
        }
        else if (kScreenHeight == kScreen40Height) {
            _mainGameFrame = kMainGame40Rect;
        }
        else
        {
            NSAssert(1, @"error");
            
        }
    }
    
//    NSLog(@"frame: %f, %f, %f, %f", _mainGameFrame.origin.x, _mainGameFrame.origin.y , _mainGameFrame.size.width, _mainGameFrame.size.height);
    return self;
}

- (void)setUpPopTipView
{
    _popTipManager = [[PopTipManager alloc] init];
	self.visiblePopTipViews = [NSMutableArray array];
    self.popContents = _popTipManager.popTipContents;
    self.titles   = _popTipManager.popTipTitles;
    self.colorSchemes = _popTipManager.colorSchemes;
    _tutorialProgressArray = [NSMutableArray arrayWithCapacity:_popContents.count];
    for (int i=0; i<_popContents.count; i++) {
        [_tutorialProgressArray addObject:@0];
    }
    NSLog(@"schemes: %@", _colorSchemes);
}


- (void)setUpHud: (HUDView*)hudView
{
    self.hud = hudView;
    [self.hud.hiscoreView setValue:self.data.maxPoints];
    [self.hud.stopwatch setSeconds:0];
    [self.hud.gamePoints setValue:0];
}
//- (void)setUpHUD
//{
//    _scoreLabel = [[UILabel alloc] initWithFrame:CGRectMake(5, 40, 100, 50)];
//    _scoreLabel.textColor = [UIColor blueColor];
//    [_gameView addSubview:_scoreLabel];
//    _timeLabel = [[UILabel alloc] initWithFrame:CGRectMake(210, 40, 100, 50)];
//    _timeLabel.textColor = [UIColor greenColor];
//    [_gameView addSubview:_timeLabel];
//}

- (void)setupEntities
{
//    if (!_scoreLabel) {
//        [self setUpHUD];
//    }
    
    
    _player = [[Player alloc] initWithFrame:CGRectMake(150, 150, 59, 80)];
    _player.mainGameFrame = _mainGameFrame;
//    if (_tutorial) {
//        _player.y = _player.bottomLeft.y - _player.height;
//        _player.x = _player.bottomLeft.x + _player.width;
        _player.y = _player.centerOfArea.y;
        _player.x = _player.centerOfArea.x;
//    }
    UIImage *bearImage = [UIImage imageNamed:@"bear"];
    _player.image = bearImage;
//    player.backgroundColor = [UIColor redColor];
    _player.tag = PlayerEntityTag;
    
    NSLog(@"_gamev: %@", _gameView);
    [_gameView addSubview:_player];
    
    if (!_tutorial || _tutorialStepEnded) {
        [self deployFruits];
    }
}

- (void)deployFruits
{
    _fruits = [NSMutableArray arrayWithCapacity:_game.fruitNum];
    UIImage *image = [UIImage imageNamed:@"apple2"];
    NSLog(@"im: %@", image);
    for (int i=0; i< _game.fruitNum; i++) {
        Fruit *fruit = [[Fruit alloc] init];
        fruit.size = CGSizeMake(26, 31);
        fruit.image = image;
        fruit.contentMode = UIViewContentModeScaleAspectFit;
        fruit.index = i;
        fruit.delegate = self;
        //        fruit.backgroundColor = [UIColor purpleColor];
        fruit.center = [self pointInView: fruit];
        fruit.tag = FruitEntityTag+i;
        [_fruits addObject:fruit];
        [_gameView addSubview:fruit];
    }
}

#pragma mark - Tutorial

- (void) startTutorial
{
    NSLog(@"contents: %@", _popContents);
    _playingGame = NO;

    _tutorialNumber = 0;
    _sleepGame = NO;
    [self.hud.stopwatch setSeconds:0];
    [self.hud.gamePoints setValue:0];
    [self progressTutorial];
}

- (void) progressTutorial
{
    NSLog(@"tutorialNumber00[%d]: %@",(int)_tutorialNumber,_tutorialProgressArray[_tutorialNumber]);
    if (![_tutorialProgressArray[_tutorialNumber] intValue]) {
        [self showPopTip:_player.button];
        _tutorialProgressArray[_tutorialNumber] = @1;
    }
    else
    {
        [self showPopTip:_player.button];
    }
    if (_tutorialNumber == 6) {
        _tutorialStepEnded = YES;
        [self stopGameOnTimeout:NO];
        _tutorialGamePlaying = YES;
        [self performSelector:@selector(startGame) withObject:nil afterDelay:0.2];
    }
}


#pragma mark - Tutorial end


- (CGPoint)pointInView:(UIImageView*)iv
{
    int ivSize = (int)iv.width;
//    int ivHeight = (int)iv.height;
    
    return CGPointMake(randomf(ivSize, (int)(kScreenWidth)-ivSize), randomf((int)_mainGameFrame.origin.y, (int)(_mainGameFrame.origin.y+_mainGameFrame.size.height)));
    
//    return CGPointMake(randomf(ivSize, (int)(kScreenWidth)-ivSize), randomf(kToolBarHeight+kStatusBarHeight+ivHeight, (int)(480-kAdbarHeight-kTabbarHeight-ivHeight-kBButtonHeight)));

    
//    return CGPointMake(randomf(ivSize, (int)(kScreenWidth)-ivSize),  (int)(480-kAdbarHeight-kTabbarHeight-ivHeight-kBButtonHeight));
//    return CGPointMake(randomf(ivSize, (int)(kScreenWidth)-ivSize),  kToolBarHeight+kStatusBarHeight+ivHeight);
//    return CGPointMake(randomf(ivSize, (int)(kScreenWidth)-ivSize), randomf(ivSize, (int)(kScreenHeight)-60-ivSize));
}

- (void)tutorialMoveStepCleared
{
    if (++_tutorialMoveSteps > kTutorialMoveSteps) {
        _tutorialMoveSteps = 0;
        [self progressTutorial];
    }
}

- (void)reactToFaceFeature:(CIFaceFeature*)faceFeature
{
    if (_tutorial && _tutorialNumber == 1) {
        [self tutorialMoveStepCleared];
    }
    if (faceFeature.rightEyeClosed) {
        NSLog(@"smile1");
//        _player.backgroundColor = [UIColor blueColor];
    }
    else
    {
//        _player.backgroundColor = [UIColor orangeColor];
    }
    if (faceFeature.hasSmile && !faceFeature.rightEyeClosed && !faceFeature.leftEyeClosed) {
        NSLog(@"smile1");
        if (_tutorial && _tutorialNumber == 3) {
            [self tutorialMoveStepCleared];
        }
//        _player.backgroundColor = [UIColor blueColor];
        [_player moveX:0 moveY:10];
    }
    else if (faceFeature.hasSmile && faceFeature.rightEyeClosed && !faceFeature.leftEyeClosed) {
        NSLog(@"smile2");
        if (_tutorial && _tutorialNumber == 5) {
            [self tutorialMoveStepCleared];
        }
//        _player.backgroundColor = [UIColor orangeColor];
        [_player moveX:-10 moveY:0];
    }
    else if (faceFeature.hasSmile && !faceFeature.rightEyeClosed && faceFeature.leftEyeClosed) {
        NSLog(@"smile3");
        if (_tutorial && _tutorialNumber == 4) {
            [self tutorialMoveStepCleared];
        }

//        _player.backgroundColor = [UIColor greenColor];
        [_player moveX:10 moveY:0];
    }
    else{
        if (_tutorial && _tutorialNumber == 2) {
            [self tutorialMoveStepCleared];
        }

        [_player moveX:0 moveY:-10];
    }
    
    _player.backgroundColor = [UIColor clearColor];

    
    for (Fruit *fruit in _fruits) {
        if (CGRectIntersectsRect(_player.frame, fruit.frame)) {
            [self collisionFruit:fruit];
        }
    }

}

- (void)collisionFruit:(Fruit*)fruit
{
    if (!_playingGame) {
        return;
    }
    [self playSound];
//    _player.backgroundColor = [UIColor redColor];
//    fruit.backgroundColor  = [UIColor redColor];
    
    fruit.center = [self pointInView:fruit];
    self.data.points += self.game.pointsPerFruit;
    if (self.data.points > self.data.maxPoints) {
        self.data.maxPoints = self.data.points;
        [self.hud.hiscoreView countTo:self.data.maxPoints withDuration:0.3];
    }
    [self.hud.gamePoints countTo:self.data.points withDuration:0.3];
    
//    _scoreLabel.text = [NSString stringWithFormat:@"Score: %d", self.data.points];
}

- (void)gameLoop:(NSTimer*)timer
{
    if (_timerTicked % (int)(1/kDt) == 0) {
        _secondsLeft -= 1;
    }
    _timerTicked++;
    _timerCount += kDt;
    
    NSLog(@"timer: %f",ceil(_timerTicked*kDt));
    if (_timerTicked) {
        NSLog(@"ticked");
    }
    if (_secondsLeft == 0) {
        [self stopGameOnTimeout:YES];
    }
//    _timeLabel.text = [NSString stringWithFormat:@"left: %d", _secondsLeft];
    [self.hud.stopwatch setSeconds:_secondsLeft];

}

- (void)startTimer
{
    _playingGame = YES;
    _secondsLeft = _game.timeToSolve;
    _timerCount = 0.0f;
    _timerTicked = 0;
    [self.hud.stopwatch setSeconds:_secondsLeft];
    _timer = [NSTimer scheduledTimerWithTimeInterval:kDt target:self selector:@selector(gameLoop:) userInfo:nil repeats:YES];
}

- (void)startGame;
{
    if (_playingGame) {
        return;
    }
    [self.squareCamViewController showButtonInActive:YES];
    if (_game.gameNum == 1) {
        _tutorial = YES;
    }
    else
    {
        _tutorial = NO;
    }
    self.data.points = 0;
    [self.hud.gamePoints setValue:0];
    UIApplication *application = [UIApplication sharedApplication];
    application.idleTimerDisabled = YES;
    [self setupEntities];
    if (_tutorial && !_tutorialStepEnded) {
        [self startTutorial];
    }
    else
    {
        [self startTimer];
    }
}

- (void)stopGameOnTimeout:(BOOL)timeOut
{
    _playingGame = NO;
    _timeOut = timeOut;
    [self dismissAllPopTipViews];
    UIApplication *application = [UIApplication sharedApplication];
    application.idleTimerDisabled = NO;
    [_timer invalidate];
    _timer = nil;
    for (UIView *view in _gameView.subviews) {
        if (view.tag >= PlayerEntityTag) {
            [view removeFromSuperview];
        }
    }
    if (_game.gameNum != 1) {
        [userDefaults setInteger:self.data.maxPoints forKey:@"hiScore"];
    }
    self.onGameOver();
    [self launchDialog:self withTimeout:timeOut];
}

//-(void)startStopwatch
//{
//    //initialize the timer HUD
//    _secondsLeft = self.level.timeToSolve;
//    [self.hud.stopwatch setSeconds:_secondsLeft];
//    
//    //schedule a new timer
//    _timer = [NSTimer scheduledTimerWithTimeInterval:1.0
//                                              target:self
//                                            selector:@selector(tick:)
//                                            userInfo:nil
//                                             repeats:YES];
//}

////stopwatch on tick
//-(void)tick:(NSTimer*)timer
//{
//    _secondsLeft --;
//    [self.hud.stopwatch setSeconds:_secondsLeft];
//    
//    if (_secondsLeft==0) {
//        [self stopStopwatch];
//    }
//}

//connect the Hint button
-(void)setHud:(HUDView *)hud
{
    _hud = hud;
    //    [hud.btnHelp addTarget:self action:@selector(actionHint) forControlEvents:UIControlEventTouchUpInside];
}

- (void)dectectCollision:(Fruit*)fruit
{
    
}

-(void)prepareAudio
{
    NSError *error = nil;
    NSString *path = [[NSBundle mainBundle] pathForResource:@"pop" ofType:@"wav"];
    NSURL *url = [[NSURL alloc] initFileURLWithPath:path];
    _audioPlayer = [[AVAudioPlayer alloc] initWithContentsOfURL:url error:&error];
    
    if ( error != nil )
    {
        NSLog(@"Error %@", [error localizedDescription]);
    }
    [_audioPlayer prepareToPlay];
    [_audioPlayer setDelegate:self];
    //    NSTimeInterval ti = self.player.duration;
}

- (void)playSound
{
    if (_audioPlayer.isPlaying) {
        _audioPlayer.currentTime = 0;
    } else {
        [_audioPlayer play];
    }
}

#pragma mark - AVAudioPlayerDelegate
-(void)audioPlayerDidFinishPlaying:(AVAudioPlayer *)player successfully:(BOOL)flag
{
    if ( flag )
    {
        NSLog(@"Done");
    }
}

#pragma mark - CMPopTipView
- (void)dismissAllPopTipViews
{
	while ([self.visiblePopTipViews count] > 0) {
		CMPopTipView *popTipView = [self.visiblePopTipViews objectAtIndex:0];
		[popTipView dismissAnimated:YES];
		[self.visiblePopTipViews removeObjectAtIndex:0];
	}
}

- (void)showPopTip:(id)sender
{
	[self dismissAllPopTipViews];
    NSLog(@"tutorialNumber01: %d", (int)_tutorialNumber);

	if (sender == self.currentPopTipViewTarget) {
		// Dismiss the popTipView and that is all
		self.currentPopTipViewTarget = nil;
	}
	else {
		NSString *contentMessage = nil;
		UIView *contentView = nil;
		NSNumber *key = [NSNumber numberWithInt:(int)_tutorialNumber++];
        if (_tutorialNumber == 2) {
            return;
        }
        NSLog(@"tutorialNumber02: %d", (int)_tutorialNumber);
		id content = [self.popContents objectForKey:key];
        NSLog(@"tutorialNumber03: %@", self.popContents);
		if ([content isKindOfClass:[UIView class]]) {
			contentView = content;
		}
		else if ([content isKindOfClass:[NSString class]]) {
			contentMessage = content;
		}
		else {
            NSLog(@"content: %@", content);
			contentMessage = @"メッセージ";
		}
		NSArray *colorScheme = [self.colorSchemes objectAtIndex:1];
        NSLog(@"colorScheme: %@", colorScheme);
        NSLog(@"schemes: %@", _colorSchemes);
		UIColor *backgroundColor = [colorScheme objectAtIndex:0];
		UIColor *textColor = [colorScheme objectAtIndex:1];

//		UIColor *backgroundColor = ColorPink;
//		UIColor *textColor = [UIColor whiteColor];
		
		NSString *title = [self.titles objectForKey:key];
		
		CMPopTipView *popTipView;
		if (contentView) {
			popTipView = [[CMPopTipView alloc] initWithCustomView:contentView];
		}
		else if (title) {
			popTipView = [[CMPopTipView alloc] initWithTitle:title message:contentMessage];
		}
		else {
			popTipView = [[CMPopTipView alloc] initWithMessage:contentMessage];
		}
		popTipView.delegate = self;
		
		/* Some options to try.
		 */
		//popTipView.disableTapToDismiss = YES;
		//popTipView.preferredPointDirection = PointDirectionUp;
		//popTipView.hasGradientBackground = NO;
        //popTipView.cornerRadius = 2.0;
        //popTipView.sidePadding = 30.0f;
        //popTipView.topMargin = 20.0f;
        //popTipView.pointerSize = 50.0f;
		
		if (backgroundColor && ![backgroundColor isEqual:[NSNull null]]) {
			popTipView.backgroundColor = backgroundColor;
		}
		if (textColor && ![textColor isEqual:[NSNull null]]) {
			popTipView.textColor = textColor;
		}
        
        popTipView.animation = 1;
		popTipView.has3DStyle = 0;
		
		popTipView.dismissTapAnywhere = YES;
//        [popTipView autoDismissAnimated:YES atTimeInterval:300.0];
        
		if ([sender isKindOfClass:[UIButton class]]) {
			UIButton *button = (UIButton *)sender;
			[popTipView presentPointingAtView:button inView:self.gameView animated:YES];
		}
		else {
			UIBarButtonItem *barButtonItem = (UIBarButtonItem *)sender;
			[popTipView presentPointingAtBarButtonItem:barButtonItem animated:YES];
		}
		
		[self.visiblePopTipViews addObject:popTipView];
        NSLog(@"ptviews: %@", _visiblePopTipViews);
		self.currentPopTipViewTarget = sender;
        NSLog(@"content: %@", contentMessage);
        if (_tutorialNumber == 6) {
            [self.squareCamViewController makeToast:contentMessage];
        }
	}
}

#pragma mark - CMPopTipView Delegate Methods
- (void)popTipViewWasDismissedByUser:(CMPopTipView *)popTipView
{
	[self.visiblePopTipViews removeObject:popTipView];
	self.currentPopTipViewTarget = nil;
}

#pragma mark - CustomIOS7Alertview Delegate Methods
- (void)launchDialog:(id)sender withTimeout:(BOOL)timeout
{
    if (!_squareCamViewController.appearing) {
        return;
    }
    if (_tutorial && _tutorialStepEnded && !_tutorialGamePlaying) {
        return;
    }
    AlertMessage* aleretMessage = [AlertMessage sharedInstance];
    message = [aleretMessage alertMessageOnTimeout:timeout onTutorial:_tutorial withScore:self.data.points withHiscore:self.data.maxPoints];
    CustomIOS7AlertView *alertView = [CustomIOS7AlertView alertWithTitle:nil message:message];
    [alertView setButtonTitles:[aleretMessage buttonArrayOnTimeout:timeout onTutorial:_tutorial onArticle:NO]];
    [alertView setButtonColors:[aleretMessage buttonColorsArrayOnTimeout:timeout onTutorial:_tutorial]];
    [alertView setDelegate:self];
    [alertView setOnButtonTouchUpInside:^(CustomIOS7AlertView *alertView, int buttonIndex) {
        NSLog(@"Block: Button at position %d is clicked on alertView %ld.", buttonIndex, (long)[alertView tag]);
        [alertView close];
    }];
    [alertView show];
    _tutorialStepEnded = NO;
    _tutorialGamePlaying = NO;
}

- (void)customIOS7dialogButtonTouchUpInside: (CustomIOS7AlertView *)alertView clickedButtonAtIndex: (NSInteger)buttonIndex
{
    NSLog(@"Delegate: Button at position %d is clicked on alertView %ld.", (int)buttonIndex, (long)[alertView tag]);
    
    switch (buttonIndex) {
        case 0:
            if (_timeOut) {
                [DCSocial postTextToLine:message];
            }
            break;
        case 1:
            [DCSocial postToTwitter:self.squareCamViewController text:message imageName:nil url:nil];
            break;
        case 2:
            [DCSocial postToFacebook:self.squareCamViewController text:message imageName:nil url:nil];
        default:
            [alertView close];
    }
}



@end
