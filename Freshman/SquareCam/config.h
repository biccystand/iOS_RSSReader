//
//  config.h
//  SquareCam 
//
//  Created by masaki on 2013/11/04.
//
//

#ifndef SquareCam__config_h
#define SquareCam__config_h

#if TARGET_IPHONE_SIMULATOR
#define kSimulator 1
#else
#define kSimulator 0
#endif

#define ColorPink [UIColor colorWithRed:255/255.0f green:152/255.0f blue:15/255.0f alpha:1.0]
#define ColorPink2 [UIColor colorWithRed:255/255.0f green:120/255.0f blue:0/255.0f alpha:1.0]
#define ColorLightPink [UIColor colorWithRed:255.0f/255.0f green:77.0f/255.0f blue:94.0f/255.0f alpha:1.0f]
#define ColorLightPink2 [UIColor colorWithRed:255.0f/255.0f green:84.0f/255.0f blue:104.0f/255.0f alpha:1.0f]
#define ColorTwitter [UIColor colorWithRed:0.0f green:172.0f/255.0f blue:237.0f/255.0f alpha:1.0f]
#define ColorFacebook [UIColor colorWithRed:30.0f/255.0f green:50.0f/255.0f blue:97.0f/255.0f alpha:1.0f]
#define kFontHUD [UIFont fontWithName:@"Ka-Boing!" size:18]
#define kFontHUDBig [UIFont fontWithName:@"Ka-Boing!" size:18]
//#define kLabelFont [UIFont fontWithName:@"Ka-Boing!.ttf" size:24]

//UI defines
#define kScreenWidth [UIScreen mainScreen].bounds.size.width
#define kScreenHeight [UIScreen mainScreen].bounds.size.height

//add more definitions here
#define kAdbarHeight 50.0
#define kAdbarHeightAtSix 70.0
#define kToolBarHeight 44
#define kStatusBarHeight 20
#define kKeyboardHeight 216
#define kTabbarHeight 49
#define kBButtonHeight 34
#define kScreen35Height 480.0
#define kScreen40Height 568.0
#define kHUDLabelHeight 30.0

#define kMainGameHeight kScreen35Height - (kAdbarHeight + kToolBarHeight + kHUDLabelHeight + kStatusBarHeight + kTabbarHeight + kBButtonHeight)
#define kMainGameHeaderHeight kStatusBarHeight + kToolBarHeight + kHUDLabelHeight
#define kMainGame40Offset (kScreen40Height - kScreen35Height)/2

#define kMainGame35Rect CGRectMake(0,kMainGameHeaderHeight,kScreenWidth,kMainGameHeight)
#define kMainGame40Rect CGRectMake(0,kMainGameHeaderHeight+kMainGame40Offset,kScreenWidth,kMainGameHeight)

#define kNendID @"782886b2497f1e9e9c5305e2957c2d386cfca47c"
#define kSpotID @"163292"
//#define kNendID @""
//#define kSpotID @""

#define kCustomRowCount     1

#define SYSTEM_VERSION_EQUAL_TO(v)                  ([[[UIDevice currentDevice] systemVersion] compare:v options:NSNumericSearch] == NSOrderedSame)
#define SYSTEM_VERSION_GREATER_THAN(v)              ([[[UIDevice currentDevice] systemVersion] compare:v options:NSNumericSearch] == NSOrderedDescending)
#define SYSTEM_VERSION_GREATER_THAN_OR_EQUAL_TO(v)  ([[[UIDevice currentDevice] systemVersion] compare:v options:NSNumericSearch] != NSOrderedAscending)
#define SYSTEM_VERSION_LESS_THAN(v)                 ([[[UIDevice currentDevice] systemVersion] compare:v options:NSNumericSearch] == NSOrderedAscending)
#define SYSTEM_VERSION_LESS_THAN_OR_EQUAL_TO(v)     ([[[UIDevice currentDevice] systemVersion] compare:v options:NSNumericSearch] != NSOrderedDescending)

#endif
