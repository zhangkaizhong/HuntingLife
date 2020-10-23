//
//  HDOrderManageViewController.m
//  HairDress
//
//  Created by 张凯中 on 2019/12/26.
//  Copyright © 2019 zhangkaizhong. All rights reserved.
//

#import "HDMyOrdersViewController.h"

#import "HDMyOrdersSubViewController.h"

#import "ZJSegmentStyle.h"
#import "ZJScrollPageView.h"

@interface HDMyOrdersViewController ()<navViewDelegate>

@property (nonatomic,strong) HDBaseNavView *navView;

@end

@implementation HDMyOrdersViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self.view addSubview:self.navView];
    //必要的设置, 如果没有设置可能导致内容显示不正常
    self.automaticallyAdjustsScrollViewInsets = NO;
    ZJSegmentStyle *style = [[ZJSegmentStyle alloc] init];
    //显示滚动条
    style.showLine = YES;
    style.scrollTitle = NO;
    style.selectedTitleColor = RGBMAIN;
    style.scrollLineColor = RGBMAIN;
    style.normalTitleColor = RGBTEXT;
    // 颜色渐变
    style.gradualChangeTitleColor = YES;
    // 设置子控制器 --- 注意子控制器需要设置title, 将用于对应的tag显示title
    NSArray *childVcs = [NSArray arrayWithArray:[self setupChildVcAndTitle]];
    // 初始化
    ZJScrollPageView *scrollPageView = [[ZJScrollPageView alloc] initWithFrame:CGRectMake(0, NAVHIGHT, kSCREEN_WIDTH, kSCREEN_HEIGHT-NAVHIGHT) segmentStyle:style childVcs:childVcs parentViewController:self];
    
    [self.view addSubview:scrollPageView];

}

#pragma mark -- delegate / action

-(void)navBackClicked{
    [self.navigationController popViewControllerAnimated:YES];
}

- (NSArray *)setupChildVcAndTitle {
    

    HDMyOrdersSubViewController *vc1 = [[HDMyOrdersSubViewController alloc] init];
    vc1.type = @"queue";
    vc1.title = @"等待服务";

    HDMyOrdersSubViewController *vc2 = [[HDMyOrdersSubViewController alloc] init];
    vc2.type = @"service";
    vc2.title = @"服务中";

    HDMyOrdersSubViewController *vc3 = [[HDMyOrdersSubViewController alloc] init];
    vc3.type = @"finish";
    vc3.title = @"已完成";

    NSArray *childVcs = [NSArray arrayWithObjects:vc1, vc2, vc3,nil];
    return childVcs;
}


-(HDBaseNavView *)navView{
    if (!_navView) {
        _navView = [[HDBaseNavView alloc] initWithFrame:CGRectMake(0, 0, kSCREEN_WIDTH, NAVHIGHT) title:@"我的预约" bgColor:RGBMAIN backBtn:YES rightBtn:@"" rightBtnImage:@"" theDelegate:self];
    }
    return _navView;
}

@end
