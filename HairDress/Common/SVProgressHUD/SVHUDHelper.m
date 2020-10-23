//
//  SVProgressHUD.m
//  HairDress
//
//  Created by Apple on 2019/12/30.
//  Copyright © 2019 zhangkaizhong. All rights reserved.
//

#import "SVHUDHelper.h"

@implementation SVHUDHelper

//有遮罩层提示信息
+ (void)showInfoWithTimestamp:(NSInteger)timestamp msg:(NSString *)msg{
    [SVProgressHUD setDefaultMaskType:SVProgressHUDMaskTypeBlack];
    [SVProgressHUD setDefaultStyle:SVProgressHUDStyleLight];
    [SVProgressHUD setMinimumDismissTimeInterval:timestamp];
    [SVProgressHUD setInfoImage:[UIImage imageNamed:@"xxx"]];
    [SVProgressHUD showInfoWithStatus:msg];
}

//加载过程菊花
+(void)showLoadingHUD{
    [SVProgressHUD show];
    [SVProgressHUD setDefaultStyle:0];//0：白色透明，1:黑色背景，2
    [SVProgressHUD setDefaultMaskType:2];//1：无遮罩层，2：有白色透明遮罩层，3：黑色透明遮罩层，4:黑色发光遮罩层，5黑色透明遮罩
    [SVProgressHUD setForegroundColor:RGBMAIN];//设置菊花颜色
    [SVProgressHUD setBackgroundColor:[UIColor clearColor]];//设置转圈背景颜色
    [SVProgressHUD setDefaultAnimationType:0];//0:加载动画为转圈，1:加载动画为菊花
//    [SVProgressHUD setMinimumSize:CGSizeMake(100, 100)];
//    [SVProgressHUD setRingRadius:1100];
    [SVProgressHUD setRingThickness:3];//设置加载圈圈的粗细
//    [SVProgressHUD setCornerRadius:1];
}

//无遮罩层提示信息
+ (void)showWorningMsg:(NSString *)msg timeInt:(NSInteger)timestamp{
    [SVProgressHUD setDefaultMaskType:1];
    [SVProgressHUD setDefaultStyle:SVProgressHUDStyleLight];
    [SVProgressHUD setMinimumDismissTimeInterval:timestamp];
    [SVProgressHUD setInfoImage:[UIImage imageNamed:@"xxx"]];
    [SVProgressHUD showInfoWithStatus:msg];
}

// 黑色遮罩层提示信息
+ (void)showDarkWarningMsg:(NSString *)msg{
    [SVProgressHUD setDefaultMaskType:SVProgressHUDMaskTypeBlack];
    [SVProgressHUD setDefaultStyle:SVProgressHUDStyleDark];
    [SVProgressHUD setMinimumDismissTimeInterval:1];
    [SVProgressHUD setInfoImage:[UIImage imageNamed:@"adfasdfasdf"]];
    [SVProgressHUD showInfoWithStatus:msg];
}

// 带图片遮罩层提示信息
+ (void)showSuccessDoneMsg:(NSString *)msg{
    [SVProgressHUD setDefaultMaskType:1];
    [SVProgressHUD setDefaultStyle:SVProgressHUDStyleLight];
    [SVProgressHUD setMinimumDismissTimeInterval:1];
    [SVProgressHUD setInfoImage:[UIImage imageNamed:@"check_ic_selected"]];
    [SVProgressHUD showInfoWithStatus:msg];
}

@end
