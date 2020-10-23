//
//  AppDelegate+JPush.h
//  JPush
//
//  Created by fangxue on 2017/4/10.
//  Copyright © 2017年 fangxue. All rights reserved.
//

#import "AppDelegate.h"
#import "JPUSHService.h"
// iOS10注册APNs所需头文件
#ifdef NSFoundationVersionNumber_iOS_9_x_Max
#import <UserNotifications/UserNotifications.h>
#endif

static BOOL isProduction = true;
@interface AppDelegate (JPush)<JPUSHRegisterDelegate>
/**
 *  极光推送单类
 *
 *  @param application   应用
 *  @param launchOptions 需要传入的launchOptions
 */
-(void)registerJPush:(UIApplication *)application options:(NSDictionary *)launchOptions;
@end
