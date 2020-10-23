//
//  AppDelegate+NetWork.m
//  HairDress
//
//  Created by Apple on 2020/1/16.
//  Copyright © 2020 zhangkaizhong. All rights reserved.
//

#import "AppDelegate+NetWork.h"

@implementation AppDelegate (NetWork)

//监听网络变化
- (void)monitorNetworkState{
    AFNetworkReachabilityManager *manager = [AFNetworkReachabilityManager sharedManager];
    [manager startMonitoring];
    [manager setReachabilityStatusChangeBlock:^(AFNetworkReachabilityStatus status) {
        switch (status) {
            case AFNetworkReachabilityStatusNotReachable:
                [SVHUDHelper showWorningMsg:@"当前无网络" timeInt:1];
                [[NSNotificationCenter defaultCenter] postNotification:[NSNotification notificationWithName:KLoadDataBase object:nil userInfo:@{@"netType":@"0"}]];
                break;
            case AFNetworkReachabilityStatusUnknown:
                [[NSNotificationCenter defaultCenter] postNotification:[NSNotification notificationWithName:KLoadDataBase object:nil userInfo:@{@"netType":@"1"}]];
                break;
            case AFNetworkReachabilityStatusReachableViaWiFi:
                [[NSNotificationCenter defaultCenter] postNotification:[NSNotification notificationWithName:KLoadDataBase object:nil userInfo:@{@"netType":@"2"}]];
                break;
            case AFNetworkReachabilityStatusReachableViaWWAN:
                [[NSNotificationCenter defaultCenter] postNotification:[NSNotification notificationWithName:KLoadDataBase object:nil userInfo:@{@"netType":@"3"}]];
                break;
            default:
                break;
        }
    }];
    
}

@end
