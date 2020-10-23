//
//  HDMyTaoGoodsOrderViewController.m
//  HairDress
//
//  Created by 张凯中 on 2020/6/9.
//  Copyright © 2020 zhangkaizhong. All rights reserved.
//

#import "HDMyTaoGoodsOrderViewController.h"

#import "HDMyCutOrdersToPayViewController.h"
#import "HDMyCutOrdersWaitViewController.h"
#import "HDMyCutOrderServicesViewController.h"
#import "HDMyCutOrdersDoneViewController.h"

#import "HDMyShopOrdersSubViewController.h"
#import "ZJSegmentStyle.h"
#import "ZJScrollPageView.h"

@interface HDMyTaoGoodsOrderViewController ()<navViewDelegate>

@property (nonatomic,strong) HDBaseNavView *navView;

@end

@implementation HDMyTaoGoodsOrderViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.view.backgroundColor = RGBBG;
    [self.view addSubview:self.navView];
    
    [self setupMainView];
}

#pragma mark -- UI

-(HDBaseNavView *)navView{
    if (!_navView) {
        _navView = [[HDBaseNavView alloc] initWithFrame:CGRectMake(0, 0, kSCREEN_WIDTH, NAVHIGHT) title:@"淘宝订单" bgColor:[UIColor whiteColor] backBtn:YES rightBtn:@"" rightBtnImage:@"" theDelegate:self];
    }
    return _navView;
}

// 商品订单
-(void)setupMainView{
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
    NSArray *childVcs = [NSArray arrayWithArray:[self setupShopChildVcAndTitle]];
    // 初始化
    ZJScrollPageView *scrollPageView = [[ZJScrollPageView alloc] initWithFrame:CGRectMake(0, NAVHIGHT, kSCREEN_WIDTH, kSCREEN_HEIGHT-NAVHIGHT) segmentStyle:style childVcs:childVcs parentViewController:self];
    
    [self.view addSubview:scrollPageView];
}

// 添加商品订单子控制器
- (NSArray *)setupShopChildVcAndTitle {
    HDMyShopOrdersSubViewController *vc1 = [[HDMyShopOrdersSubViewController alloc] init];
    vc1.status = @"all";
    vc1.title = @"全部";

    HDMyShopOrdersSubViewController *vc2 = [[HDMyShopOrdersSubViewController alloc] init];
    vc2.status = @"no_settle";
    vc2.title = @"未结算";

    HDMyShopOrdersSubViewController *vc3 = [[HDMyShopOrdersSubViewController alloc] init];
    vc3.status = @"settled";
    vc3.title = @"已结算";

    HDMyShopOrdersSubViewController *vc4 = [[HDMyShopOrdersSubViewController alloc] init];
    vc4.status = @"cancel";
    vc4.title = @"已失效";

    NSArray *childVcs = [NSArray arrayWithObjects:vc1, vc2, vc3,vc4,nil];
    return childVcs;
}

#pragma mark -- delegate / action
- (void)navBackClicked{
    [self.navigationController popViewControllerAnimated:YES];
}

@end
