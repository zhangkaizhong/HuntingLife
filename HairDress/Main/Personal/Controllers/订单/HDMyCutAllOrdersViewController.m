//
//  HDMyCutAllOrdersViewController.m
//  HairDress
//
//  Created by 张凯中 on 2020/6/9.
//  Copyright © 2020 zhangkaizhong. All rights reserved.
//

#import "HDMyCutAllOrdersViewController.h"

#import "HDMyCutOrdersToPayViewController.h"
#import "HDMyCutOrdersWaitViewController.h"
#import "HDMyCutOrderServicesViewController.h"
#import "HDMyCutOrdersDoneViewController.h"

#import "ZJSegmentStyle.h"
#import "ZJScrollPageView.h"

@interface HDMyCutAllOrdersViewController ()<navViewDelegate>

@property (nonatomic,strong) HDMyCutOrdersToPayViewController *vcWaitPay;//待付款
@property (nonatomic,strong) HDMyCutOrdersWaitViewController *vcWait;//待消费
@property (nonatomic,strong) ZJScrollPageView *cutScrollPageView;
@property (nonatomic,strong) HDBaseNavView *navView;

@end

@implementation HDMyCutAllOrdersViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.view.backgroundColor = RGBBG;
    [self.view addSubview:self.navView];
    
    [self setupMainView];
}

// 理发订单
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
    NSArray *childVcs = [NSArray arrayWithArray:[self setupCutChildVcAndTitle]];
    // 初始化
    ZJScrollPageView *scrollPageView = [[ZJScrollPageView alloc] initWithFrame:CGRectMake(0, NAVHIGHT, kSCREEN_WIDTH, kSCREEN_HEIGHT-NAVHIGHT) segmentStyle:style childVcs:childVcs parentViewController:self];
    self.cutScrollPageView = scrollPageView;
    if (_index) {
        [self.cutScrollPageView setSelectedIndex:_index animated:NO];
    }
    [self.view addSubview:scrollPageView];
}

// 添加理发订单子控制器
- (NSArray *)setupCutChildVcAndTitle {
    
    self.vcWait = [[HDMyCutOrdersWaitViewController alloc] init];
    self.vcWait.title = @"待消费";
    
    self.vcWaitPay = [[HDMyCutOrdersToPayViewController alloc] init];
    self.vcWaitPay.title = @"待付款";

    HDMyCutOrderServicesViewController *vc2 = [[HDMyCutOrderServicesViewController alloc] init];
    vc2.title = @"服务中";

    HDMyCutOrdersDoneViewController *vc3 = [[HDMyCutOrdersDoneViewController alloc] init];
    vc3.type = @"3";
    vc3.title = @"已完成";

    HDMyCutOrdersDoneViewController *vc4 = [[HDMyCutOrdersDoneViewController alloc] init];
    vc4.type = @"4";
    vc4.title = @"退款/过号";

    NSArray *childVcs = [NSArray arrayWithObjects:self.vcWait,self.vcWaitPay, vc2, vc3,vc4, nil];
    return childVcs;
}

-(HDBaseNavView *)navView{
    if (!_navView) {
        _navView = [[HDBaseNavView alloc] initWithFrame:CGRectMake(0, 0, kSCREEN_WIDTH, NAVHIGHT) title:@"理发订单" bgColor:[UIColor whiteColor] backBtn:YES rightBtn:@"" rightBtnImage:@"" theDelegate:self];
    }
    return _navView;
}

//选中页面
-(void)selectIndexRefresh:(NSInteger)index isReoload:(BOOL)reload{
    [self.cutScrollPageView setSelectedIndex:index animated:NO];
    if (reload) {
        if (index == 0) {
            [self.vcWaitPay getOrderWaitData];
        }
        if (index == 1) {
            [self.vcWait loadNewData];
        }
    }
}

#pragma mark -- delegate / action
- (void)navBackClicked{
    [self.navigationController popViewControllerAnimated:YES];
}

@end
