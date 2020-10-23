//
//  AppDelegate.m
//  HairDress
//
//  Created by Apple on 2019/12/18.
//  Copyright © 2019 zhangkaizhong. All rights reserved.
//

#import "AppDelegate.h"
#import "AppDelegate+TabBar.h"
#import "AppDelegate+NetWork.h"
#import "AppDelegate+ThirdParty.h"
#import "AppDelegate+JPush.h"

@interface AppDelegate ()

@end

@implementation AppDelegate


- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    
    // 设置状态栏颜色为白色
    [UIApplication sharedApplication].statusBarStyle = UIStatusBarStyleDefault;
    
    // 创建根控制器
    [self setupRootViewController];
    
    // 设置键盘
    [self setupKeyboard];
    
    //设置微信
    [self regiterWX];
    
    //七鱼
    [self registerQiYu];
    
    //配置阿里百川
    [self setupAlibc];
    
    //极光
    [self registerJPush:application options:launchOptions];
    
    //网络监听
    [self monitorNetworkState];
    
    return YES;
}

- (void)application:(UIApplication *)application didReceiveRemoteNotification:(NSDictionary *)userInfo {
    // Required,For systems with less than or equal to iOS6
    [JPUSHService handleRemoteNotification:userInfo];
    
    DTLog(@"jpush-info:%@",userInfo);
}

//Required必须
//注册APNs成功并上报DeviceToken
- (void)application:(UIApplication *)application
didRegisterForRemoteNotificationsWithDeviceToken:(NSData *)deviceToken {
    
    /// Required - 注册 DeviceToken
    [JPUSHService registerDeviceToken:deviceToken];
}

//Optional 可选
- (void)application:(UIApplication *)application didFailToRegisterForRemoteNotificationsWithError:(NSError *)error {
    //Optional
    NSLog(@"did Fail To Register For Remote Notifications With Error: %@", error);
}


@end
