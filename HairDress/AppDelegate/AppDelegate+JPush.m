//
//  AppDelegate+JPush.h
//  JPush
//
//  Created by fangxue on 2017/4/10.
//  Copyright © 2017年 fangxue. All rights reserved.

#import "AppDelegate+JPush.h"

#import "HDWebViewController.h"
#import "HDNewTaskViewController.h"
#import "HDTaoGoodsDetailViewController.h"
#import "HDCutHomeViewController.h"
#import "HDNewPersonalViewController.h"
#import "HDTaoMallViewController.h"

@implementation AppDelegate (JPush)

-(void)registerJPush:(UIApplication *)application options:(NSDictionary *)launchOptions
{
    //    添加初始化APNs代码
    //Required
    //notice: 3.0.0及以后版本注册可以这样写，也可以继续用之前的注册方式
    JPUSHRegisterEntity * entity = [[JPUSHRegisterEntity alloc] init];
    entity.types = JPAuthorizationOptionAlert|JPAuthorizationOptionBadge|JPAuthorizationOptionSound;
    if ([[UIDevice currentDevice].systemVersion floatValue] >= 8.0) {
        // 可以添加自定义categories
        // NSSet<UNNotificationCategory *> *categories for iOS10 or later
        // NSSet<UIUserNotificationCategory *> *categories for iOS8 and iOS9
    }
    [JPUSHService registerForRemoteNotificationConfig:entity delegate:self];
    
    // 添加初始化JPush代码
    // Optional
    // 获取IDFA
    // 如需使用IDFA功能请添加此代码并在初始化方法的advertisingIdentifier参数中填写对应值
//    NSString *advertisingId = [[[ASIdentifierManager sharedManager] advertisingIdentifier] UUIDString];
//
//    NSString *idfv = [[[UIDevice currentDevice] identifierForVendor] UUIDString];
//
//    NSLog(@"获取IDFA:%@",advertisingId);
//    NSLog(@"获取IDFV:%@",idfv);
    // Required
    // init Push
    // notice: 2.1.5版本的SDK新增的注册方法，改成可上报IDFA，如果没有使用IDFA直接传nil
    // 如需继续使用pushConfig.plist文件声明appKey等配置内容，请依旧使用[JPUSHService setupWithOption:launchOptions]方式初始化。
    [JPUSHService setupWithOption:launchOptions appKey:JPUSH_APP_KEY
                          channel:@"Channel"
                 apsForProduction:isProduction
            advertisingIdentifier:nil];
    
    //[JPUSHService setLogOFF];
    
    //获取极光注册号
    [JPUSHService registrationIDCompletionHandler:^(int resCode, NSString *registrationID) {
        
        if(resCode == 0){
            DTLog(@"registrationID获取成功：%@",registrationID);
            [HDUserDefaultMethods saveData:registrationID andKey:JPUSH_REGID];
        }else{
            DTLog(@"registrationID获取失败，code：%d",resCode);
        }
    }];
    
    if (launchOptions) {
        NSDictionary * remoteNotification = [launchOptions objectForKey:UIApplicationLaunchOptionsRemoteNotificationKey];
        //这个判断是在程序没有运行的情况下收到通知，点击通知跳转页面
        if (remoteNotification) {
            NSLog(@"推送消息==== %@",remoteNotification);
            [self goToMssageViewControllerWith:remoteNotification];
        }
    }
}

#pragma mark- JPUSHRegisterDelegate

// iOS 10 Support
/**
*极光前台状态下收到远程APNS通知
*取代了系统IOS10 以后的 willPresentNotification方法
*/
- (void)jpushNotificationCenter:(UNUserNotificationCenter *)center willPresentNotification:(UNNotification *)notification withCompletionHandler:(void (^)(NSInteger))completionHandler  API_AVAILABLE(ios(10.0)){
    // Required
    NSDictionary * userInfo = notification.request.content.userInfo;
    if (@available(iOS 10.0, *)) {
        if([notification.request.trigger isKindOfClass:[UNPushNotificationTrigger class]]) {
            [JPUSHService handleRemoteNotification:userInfo];
            
            //在应用内运行
//            [self didRecevieNotification:userInfo];
            NSLog(@"didRecevieNotification74");
        }
    } else {
        // Fallback on earlier versions
    }
    
    if ([UIApplication sharedApplication].applicationState == UIApplicationStateActive) {
        // 需要执行这个方法，选择是否提醒用户，有Badge、Sound、Alert三种类型可以设置
        completionHandler(UNNotificationPresentationOptionSound|UNNotificationPresentationOptionAlert);
    }else{
        completionHandler(UNNotificationPresentationOptionBadge|UNNotificationPresentationOptionSound|UNNotificationPresentationOptionAlert);
    }
}

// iOS 10 Support
//所有状态，前台和后台关闭状态下 收到远程APNS通知==点击动作后，如果是在关闭状态，过程是先走appdelegate launchfinish方法
- (void)jpushNotificationCenter:(UNUserNotificationCenter *)center didReceiveNotificationResponse:(UNNotificationResponse *)response withCompletionHandler:(void (^)(void))completionHandler  API_AVAILABLE(ios(10.0)){
    // Required
    NSDictionary * userInfo = response.notification.request.content.userInfo;
    if (@available(iOS 10.0, *)) {
        if([response.notification.request.trigger isKindOfClass:[UNPushNotificationTrigger class]]) {
            [JPUSHService handleRemoteNotification:userInfo];
            [self didRecevieNotification:userInfo];
        }
    } else {
        // Fallback on earlier versions
    }
    completionHandler();  // 系统要求执行这个方法
}

//iOS 12
-(void)jpushNotificationCenter:(UNUserNotificationCenter *)center openSettingsForNotification:(UNNotification *)notification API_AVAILABLE(ios(10.0)){
    
}

- (void)jpushNotificationAuthorization:(JPAuthorizationStatus)status withInfo:(NSDictionary *)info {
    DTLog(@"jpush-info:%@",info);
}


//require 设置角标和清除角标
- (void)applicationDidEnterBackground:(UIApplication *)application {
    //设置本地icon角标
    [[UIApplication sharedApplication] setApplicationIconBadgeNumber:0];
    //设置极光后台角标
    [JPUSHService setBadge:0];
}

//收到消息后，告诉极光收到消息
-(void)JpushHandle:(NSDictionary *)userInfo{
    [JPUSHService handleRemoteNotification:userInfo];
}


#pragma mark -----自定义的东西-----
//处理收到的提醒
-(void)didRecevieNotification :(NSDictionary *)receiveNotifi{
    DTLog(@"jpush-info:%@",receiveNotifi);
    UIViewController *curVC = [HDToolHelper getCurrentVC];
    //理发首页
    if ([receiveNotifi[@"contentType"] isEqualToString:@"cutIndex"]) {
        [self selectIndexCon:curVC selectIndex:0];
    }
    //精选首页
    if ([receiveNotifi[@"contentType"] isEqualToString:@"cpsIndex"]) {
        [self selectIndexCon:curVC selectIndex:1];
    }
    //任务中心
    if ([receiveNotifi[@"contentType"] isEqualToString:@"taskIndex"]) {
        HDNewTaskViewController *taskVC = [HDNewTaskViewController new];
        [curVC.navigationController pushViewController:taskVC animated:YES];
    }
    //个人中心
    if ([receiveNotifi[@"contentType"] isEqualToString:@"personCenter"]) {
        [self selectIndexCon:curVC selectIndex:2];
    }
    //自定义链接
    if ([receiveNotifi[@"contentType"] isEqualToString:@"custom"]) {
        HDWebViewController *webVC = [HDWebViewController new];
        webVC.url_str = receiveNotifi[@"contentValue"];
        webVC.title_str = receiveNotifi[@"title"];
        UIViewController *cutVC = [HDToolHelper getCurrentVC];
        [cutVC.navigationController pushViewController:webVC animated:YES];
    }
    //商品详情
    if ([receiveNotifi[@"contentType"] isEqualToString:@"goods"]) {
        HDTaoGoodsDetailViewController *detailVC = [HDTaoGoodsDetailViewController new];
        detailVC.taoId = receiveNotifi[@"contentValue"];
        UIViewController *cutVC = [HDToolHelper getCurrentVC];
        [cutVC.navigationController pushViewController:detailVC animated:YES];
    }
}

-(void)goToMssageViewControllerWith:(NSDictionary *)userInfo{//启动后处理远程通知

    //极光推送
    if(userInfo[@"_j_business"]){ //远程通知
           
        [JPUSHService handleRemoteNotification:userInfo];
        
        [self didRecevieNotification:userInfo];
    }
        
}

// 选中控制器
-(void)selectIndexCon:(UIViewController *)currentVC selectIndex:(NSInteger)index{
    UITabBarController *rootTab = (UITabBarController *)[UIApplication sharedApplication].keyWindow.rootViewController;
    rootTab.selectedIndex = index;
    
    if (currentVC.presentingViewController) {
       [currentVC dismissViewControllerAnimated:NO completion:^{
            if ([currentVC.presentingViewController isKindOfClass:[UINavigationController class]]) {
                UINavigationController *navi = (UINavigationController *)currentVC.presentingViewController;
                [navi popToRootViewControllerAnimated:NO];
            }
        }];
    } else {
        [currentVC.navigationController popToRootViewControllerAnimated:NO];
    }
}

@end
