//
//  HDBankCardPhoneViewController.m
//  HairDress
//
//  Created by 张凯中 on 2019/12/30.
//  Copyright © 2019 zhangkaizhong. All rights reserved.
//

#import "HDBankCardPhoneViewController.h"

@interface HDBankCardPhoneViewController ()<navViewDelegate>

@property (nonatomic,strong)HDBaseNavView *navView;
@property (nonatomic,strong)UIScrollView *mainScrollView;

@end

@implementation HDBankCardPhoneViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.view.backgroundColor = RGBBG;
    [self.view addSubview:self.navView];
    [self.view addSubview:self.mainScrollView];
}

#pragma mark -- delegate / action

- (void)navBackClicked{
    [self.navigationController popViewControllerAnimated:YES];
}

// 下一步
-(void)btnNextAction{
    
}


-(HDBaseNavView *)navView{
    if (!_navView) {
        _navView = [[HDBaseNavView alloc] initWithFrame:CGRectMake(0, 0, kSCREEN_WIDTH, NAVHIGHT) title:@"验证手机号" bgColor:RGBMAIN backBtn:YES rightBtn:@"" rightBtnImage:@"" theDelegate:self];
    }
    return _navView;
}

@end
