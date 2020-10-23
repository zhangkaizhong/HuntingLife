//
//  AppDelegate+ThirdParty.h
//  HairDress
//
//  Created by 张凯中 on 2020/2/12.
//  Copyright © 2020 zhangkaizhong. All rights reserved.
//  第三方相关

#import "AppDelegate.h"

NS_ASSUME_NONNULL_BEGIN

@interface AppDelegate (ThirdParty)

//配置微信
-(void)regiterWX;
//七鱼
-(void)registerQiYu;

//配置阿里百川
-(void)setupAlibc;

@end

NS_ASSUME_NONNULL_END
