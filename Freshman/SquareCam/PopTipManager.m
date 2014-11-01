//
//  PopTipManager.m
//  SquareCam 
//
//  Created by masaki on 2014/03/18.
//
//

#import "PopTipManager.h"
#import "config.h"

@implementation PopTipManager
- (NSDictionary *)popTipContents
{
    NSDictionary *contents = [NSDictionary dictionaryWithObjectsAndKeys:
                              // Rounded rect buttons
                              @"画面に顔を写してみてね。\n黄色い枠が表示されたら成功だよ！", [NSNumber numberWithInt:0],
                              @"画面に顔が写ったよ！\n両目を開けて口を閉じると上に移動するよ。", [NSNumber numberWithInt:1],
                              @"画面に顔が写ったから上に移動できたよ！\nこんどは両目を開けたまま笑顔を作ってみてね。下に移動するよ。", [NSNumber numberWithInt:2],
                              // Nav bar buttons
                              @"下に移動できたよ！\n次は、笑顔のまま右目だけを閉じてみてね。右に移動するよ。", [NSNumber numberWithInt:3],
                              @"右に移動できたよ！\n次は反対に、笑顔のまま左目だけを閉じてみてね。左に移動するよ。", [NSNumber numberWithInt:4],
                              // Toolbar buttons
                              @"左に移動できたよ！\nこれで4方向への動きを覚えたよ。次は腕試しにリンゴを拾ってみよう。時間内にいくつ拾えるかな？", [NSNumber numberWithInt:5],
                              @"おめでとう！これでチュートリアルはおしまいだよ！やったね！！", [NSNumber numberWithInt:6],
                              nil];
    return contents;
}

- (NSDictionary*)popTipTitles
{
    NSDictionary *titles = [NSDictionary dictionaryWithObjectsAndKeys:
                            @"Title", [NSNumber numberWithInt:14],
                            @"Auto Orientation", [NSNumber numberWithInt:12],
                            nil];
    return titles;
}

- (NSArray*)colorSchemes
{
    NSArray *schemes = [NSArray arrayWithObjects:
                        [NSArray arrayWithObjects:ColorPink, [NSNull null], nil],
                        [NSArray arrayWithObjects:ColorPink, [NSNull null], nil],
                        [NSArray arrayWithObjects:ColorPink, [NSNull null], nil],
                        [NSArray arrayWithObjects:ColorPink, [NSNull null], nil],
                        [NSArray arrayWithObjects:ColorPink, [NSNull null], nil],
                        [NSArray arrayWithObjects:ColorPink, [NSNull null], nil],
                        [NSArray arrayWithObjects:ColorPink, [NSNull null], nil],
                        [NSArray arrayWithObjects:[UIColor colorWithRed:134.0/255.0 green:74.0/255.0 blue:110.0/255.0 alpha:1.0], [NSNull null], nil],
                        [NSArray arrayWithObjects:[UIColor darkGrayColor], [NSNull null], nil],
                        [NSArray arrayWithObjects:[UIColor lightGrayColor], [UIColor darkTextColor], nil],
                        [NSArray arrayWithObjects:[UIColor orangeColor], [UIColor blueColor], nil],
                        [NSArray arrayWithObjects:[UIColor colorWithRed:220.0/255.0 green:0.0/255.0 blue:0.0/255.0 alpha:1.0], [NSNull null], nil],
                        nil];
    return schemes;
}
@end
