//
//  AppDelegate.h
//  HairDress
//
//  Created by Apple on 2019/12/18.
//  Copyright © 2019 zhangkaizhong. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "WXApi.h"
#import <AlibcTradeSDK/AlibcTradeSDK.h>
#import <QYSDK/QYSDK.h>
#import <AlipaySDK/AlipaySDK.h>
#import <UMCommon/UMCommon.h>
#import <UMShare/UMShare.h>
#import "HDPreLoginViewController.h"
#import "HDLoginViewController.h"
#import "HDBaseTabBarViewController.h"
#import "PayManager.h"
#import <UserNotifications/UserNotifications.h>

@interface AppDelegate : UIResponder <UIApplicationDelegate,WXApiDelegate>

@property (strong, nonatomic) UIWindow *window;
@property (nonatomic,strong) HDBaseTabBarViewController *tabbarVC;
@property (nonatomic,strong) HDLoginViewController *preLoginVC;

@end

