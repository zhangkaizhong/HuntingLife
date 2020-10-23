//
//  HDButton.h
//  HairDress
//
//  Created by Apple on 2019/12/19.
//  Copyright © 2019 zhangkaizhong. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

typedef NS_ENUM(NSInteger) {
    TOP     = 0, // 上
    LEFT    = 1, // 左
    BOTTOM  = 2, // 下
    RIGHT   = 3 ,// 右
    LeftEast   = 4,  // 最左
    RIGHT_DOWN = 5, // 右下
    LeftCostom = 6,
    LeftWallet = 7,
    RIGHTMore = 8,
    Top_Msg = 9,
    Top_24 = 10
}BtnType;

@interface HDButton : UIButton

@property (nonatomic, assign) BtnType btnType;

@end

NS_ASSUME_NONNULL_END
