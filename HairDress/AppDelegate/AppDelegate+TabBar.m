//
//  AppDelegate+TabBar.m
//  HairDress
//
//  Created by Apple on 2019/12/18.
//  Copyright © 2019 zhangkaizhong. All rights reserved.
//

#import "AppDelegate+TabBar.h"


@implementation AppDelegate (TabBar)

// 设置根控制器
-(void)setupRootViewController{
    self.window = [[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
    self.window.backgroundColor = [UIColor whiteColor];
    
    // 判断用户是否是第一次进入
//    NSString *userID = [HDUserDefaultMethods getData:@"userId"];
//    if (![HDToolHelper StringIsNullOrEmpty:userID]) {
        self.tabbarVC = [[HDBaseTabBarViewController alloc] init];
        [self.window setRootViewController:self.tabbarVC];
//    }else{
//        HDBaseNavViewController *loginVC = [[HDBaseNavViewController alloc] initWithRootViewController:[HDPreLoginViewController new]];
//        [self.window setRootViewController:loginVC];
//    }
    
    [self.window makeKeyAndVisible];
}

//键盘设置
-(void)setupKeyboard{
    [[IQKeyboardManager sharedManager] setEnableAutoToolbar:YES];
    [[IQKeyboardManager sharedManager] setShouldResignOnTouchOutside:YES];
}


@end
