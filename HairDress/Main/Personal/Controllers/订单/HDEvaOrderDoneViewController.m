//
//  HDRegisterDoneViewController.m
//  HairDress
//
//  Created by Apple on 2019/12/30.
//  Copyright © 2019 zhangkaizhong. All rights reserved.
//

#import "HDEvaOrderDoneViewController.h"

#import "HDMyCutAllOrdersViewController.h"

@interface HDEvaOrderDoneViewController ()<navViewDelegate>

@property (nonatomic,strong)HDBaseNavView *navView;//导航栏

@end

@implementation HDEvaOrderDoneViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.view.backgroundColor = RGBBG;
    [self.view addSubview:self.navView];
    
    UIImageView *imageDone = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"common_ic_success"]];
    imageDone.centerX = kSCREEN_WIDTH/2;
    imageDone.y = 144;
    [self.view addSubview:imageDone];
    
    UILabel *lblDone = [[UILabel alloc] initCommonWithFrame:CGRectMake(0, imageDone.bottom+24, kSCREEN_WIDTH, 16) title:@"评价成功" bgColor:[UIColor clearColor] titleColor:RGBTEXT titleFont:16 textAlignment:NSTextAlignmentCenter isFit:NO];
    [self.view addSubview:lblDone];
    
    // 返回首页
    UIButton *buttonHome = [[UIButton alloc] initSystemWithFrame:CGRectMake(16, lblDone.bottom+96, kSCREEN_WIDTH-32, 48) btnTitle:@"返回首页" btnImage:@"" titleColor:[UIColor whiteColor] titleFont:14];
    buttonHome.layer.cornerRadius = 48/2;
    buttonHome.backgroundColor = RGBMAIN;
    [self.view addSubview:buttonHome];
    [buttonHome addTarget:self action:@selector(buttonHomeAction) forControlEvents:UIControlEventTouchUpInside];
}

#pragma mark ================== delegate /action =====================

// 导航栏
-(void)navBackClicked{
    for (UIViewController *viewCon in self.navigationController.viewControllers) {
        if ([viewCon isKindOfClass:[HDMyCutAllOrdersViewController class]]) {
            [self.navigationController popToViewController:viewCon animated:YES];
            return;
        }
    }
    [self.navigationController popViewControllerAnimated:YES];
}

//返回首页
-(void)buttonHomeAction{
    [HDToolHelper chooseToJumpHome:self selectIndex:0];
}

#pragma mark ================== 加载视图 =====================

-(HDBaseNavView *)navView{
    if (!_navView) {
        _navView=[[HDBaseNavView alloc] initWithFrame:CGRectMake(0, 0, kSCREEN_WIDTH, NAVHIGHT) title:@"发表评价" bgColor:[UIColor clearColor] backBtn:YES rightBtn:@"" rightBtnImage:@"" theDelegate:self];
    }
    return _navView;
}



@end
