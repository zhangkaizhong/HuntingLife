//
//  HDRegisterDoneViewController.m
//  HairDress
//
//  Created by Apple on 2019/12/30.
//  Copyright © 2019 zhangkaizhong. All rights reserved.
//

#import "HDRegisterDoneViewController.h"
#import "HDBindWXViewController.h"
#import "WXApi.h"

@interface HDRegisterDoneViewController ()<navViewDelegate>

@property (nonatomic,strong)HDBaseNavView *navView;//导航栏

@end

@implementation HDRegisterDoneViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.view.backgroundColor = RGBBG;
    [self.view addSubview:self.navView];
    
    UIImageView *imageDone = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"common_ic_success"]];
    imageDone.centerX = kSCREEN_WIDTH/2;
    imageDone.y = 144;
    [self.view addSubview:imageDone];
    
    UILabel *lblDone = [[UILabel alloc] initCommonWithFrame:CGRectMake(0, imageDone.bottom+24, kSCREEN_WIDTH, 16) title:@"注册成功！" bgColor:[UIColor clearColor] titleColor:RGBTEXT titleFont:16 textAlignment:NSTextAlignmentCenter isFit:NO];
    [self.view addSubview:lblDone];
    
    // 一键登录
    UIButton *buttonLog = [[UIButton alloc] initSystemWithFrame:CGRectMake(16, lblDone.bottom+96, kSCREEN_WIDTH-32, 48) btnTitle:@"一键登录" btnImage:@"" titleColor:[UIColor whiteColor] titleFont:14];
    buttonLog.layer.cornerRadius = 48/2;
    buttonLog.backgroundColor = RGBMAIN;
    [self.view addSubview:buttonLog];
    [buttonLog addTarget:self action:@selector(loginAction) forControlEvents:UIControlEventTouchUpInside];
}

#pragma mark ================== delegate /action =====================

// 导航栏
-(void)navBackClicked{
    [self.navigationController popViewControllerAnimated:YES];
}

// 一键登录
-(void)loginAction{
    NSDictionary *params = @{
        @"registrationId":[HDUserDefaultMethods getData:JPUSH_REGID],
        @"phone":self.phone,
        @"password":self.pwd
    };
    [MHNetworkManager postReqeustWithURL:URL_LoginPhone params:params successBlock:^(NSDictionary *returnData) {
        if ([returnData[@"respCode"] integerValue] == 200) {
            NSDictionary *userInfo = [HDToolHelper nullDicToDic:returnData[@"data"]];
            // 缓存用户信息
            [HDToolHelper saveData:userInfo];
            
            if ([userInfo[@"unionId"] isEqualToString:@""]) {
                if ([WXApi isWXAppInstalled]) {
                    //绑定微信
                    HDBindWXViewController *bindVC = [HDBindWXViewController new];
                    bindVC.userId = userInfo[@"id"];
                    [self.navigationController pushViewController:bindVC animated:YES];
                }else{
                    HDBaseTabBarViewController *tabVC = [HDBaseTabBarViewController new];
                    tabVC.selectedIndex = 3;
                    UIWindow *window = [[UIApplication sharedApplication] keyWindow];
                    window.rootViewController = tabVC;
                }
            }
            else{
                HDBaseTabBarViewController *tabVC = [HDBaseTabBarViewController new];
                tabVC.selectedIndex = 3;
                UIWindow *window = [[UIApplication sharedApplication] keyWindow];
                window.rootViewController = tabVC;
            }
        }else{
            [SVHUDHelper showInfoWithTimestamp:1 msg:returnData[@"respMsg"]];
        }
    } failureBlock:^(NSError *error) {
        
    } showHUD:YES];
}


#pragma mark ================== 加载视图 =====================

-(HDBaseNavView *)navView{
    if (!_navView) {
        _navView=[[HDBaseNavView alloc] initWithFrame:CGRectMake(0, 0, kSCREEN_WIDTH, NAVHIGHT) title:@"注册成功" bgColor:[UIColor clearColor] backBtn:YES rightBtn:@"" rightBtnImage:@"" theDelegate:self];
    }
    return _navView;
}



@end
