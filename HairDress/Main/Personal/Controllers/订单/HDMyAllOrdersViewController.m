//
//  HDMyOrdersViewController.m
//  HairDress
//
//  Created by 张凯中 on 2019/12/28.
//  Copyright © 2019 zhangkaizhong. All rights reserved.
//

#import "HDMyAllOrdersViewController.h"

#import "HDMyCutOrdersToPayViewController.h"
#import "HDMyShopOrdersSubViewController.h"
#import "HDMyCutOrdersWaitViewController.h"
#import "HDMyCutOrderServicesViewController.h"
#import "HDMyCutOrdersDoneViewController.h"
#import "ZJSegmentStyle.h"
#import "ZJScrollPageView.h"

@interface HDMyAllOrdersViewController ()<navViewDelegate>

@property (nonatomic,strong) HDMyCutOrdersToPayViewController *vcWaitPay;//待付款
@property (nonatomic,strong) HDMyCutOrdersWaitViewController *vcWait;//待消费
@property (nonatomic,strong) ZJScrollPageView *cutScrollPageView;
@property (nonatomic,strong) HDBaseNavView *navView;
@property (nonatomic,strong) UIView *headerButtonView;
@property (nonatomic,strong) UIView *viewShopOrders;// 商品订单
@property (nonatomic,strong) UIView *viewCutOrders;//理发订单

@property (nonatomic,weak) UIButton *buttonShop;
@property (nonatomic,weak) UIButton *buttonCut;

@end

@implementation HDMyAllOrdersViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.view.backgroundColor = RGBBG;
    [self.view addSubview:self.navView];
    [self.view addSubview:self.headerButtonView];
    [self.view addSubview:self.viewShopOrders];
}

#pragma mark -- delegate / action

- (void)navBackClicked{
    [self.navigationController popViewControllerAnimated:YES];
}

//选中页面
-(void)selectIndexRefresh:(NSInteger)index{
    [self.cutScrollPageView setSelectedIndex:index animated:YES];
    if (index == 0) {
        [self.vcWaitPay getOrderWaitData];
    }
    if (index == 1) {
        [self.vcWait loadNewData];
    }
}

// 商品订单
-(void)buttonShopAction:(UIButton *)sender{
    [sender setTitleColor:RGBMAIN forState:UIControlStateNormal];
    sender.backgroundColor = [UIColor whiteColor];
    sender.layer.borderWidth = 1;
    sender.layer.borderColor = [UIColor whiteColor].CGColor;
    
    [self.buttonCut setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    self.buttonCut.backgroundColor = RGBMAIN;
    self.buttonCut.layer.borderWidth = 1;
    self.buttonCut.layer.borderColor = [UIColor whiteColor].CGColor;
    
    _viewShopOrders.hidden = NO;
    _viewCutOrders.hidden = YES;
}

// 理发订单
-(void)buttonCutAction:(UIButton *)sender{
    [sender setTitleColor:RGBMAIN forState:UIControlStateNormal];
    sender.backgroundColor = [UIColor whiteColor];
    sender.layer.borderWidth = 1;
    sender.layer.borderColor = [UIColor whiteColor].CGColor;
    
    [self.buttonShop setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    self.buttonShop.backgroundColor = RGBMAIN;
    self.buttonShop.layer.borderWidth = 1;
    self.buttonShop.layer.borderColor = [UIColor whiteColor].CGColor;
    
    _viewShopOrders.hidden = YES;
    [self.view addSubview:self.viewCutOrders];
    _viewCutOrders.hidden = NO;
}

#pragma mark -- 加载视图

-(UIView *)headerButtonView{
    if (!_headerButtonView) {
        _headerButtonView = [[UIView alloc] initWithFrame:CGRectMake(0, NAVHIGHT, kSCREEN_WIDTH, 56)];
        _headerButtonView.backgroundColor = RGBMAIN;
        
        UIView *viewBtns = [[UIView alloc] initWithFrame:CGRectMake(16, 8, kSCREEN_WIDTH-32, 32)];
        viewBtns.layer.borderColor = [UIColor whiteColor].CGColor;
        viewBtns.layer.borderWidth = 1;
        viewBtns.layer.cornerRadius = 32/2;
        [_headerButtonView addSubview:viewBtns];
        
        // 商品订单
        UIButton *buttonShop = [[UIButton alloc] initSystemWithFrame:CGRectMake(0, 0, viewBtns.width/2, 32) btnTitle:@"商品订单" btnImage:@"" titleColor:RGBMAIN titleFont:14];
        buttonShop.backgroundColor = [UIColor whiteColor];
        
        CGFloat corner = 16;
        CAShapeLayer *shapeLayer = [CAShapeLayer layer];
        shapeLayer.path = [UIBezierPath bezierPathWithRoundedRect:buttonShop.bounds byRoundingCorners:UIRectCornerTopLeft | UIRectCornerBottomLeft cornerRadii:CGSizeMake(corner, corner)].CGPath;
        buttonShop.layer.mask = shapeLayer;
        
        [viewBtns addSubview:buttonShop];
        self.buttonShop = buttonShop;
        
        [buttonShop addTarget:self action:@selector(buttonShopAction:) forControlEvents:UIControlEventTouchUpInside];
        
        //理发订单
        UIButton *buttonCut = [[UIButton alloc] initSystemWithFrame:CGRectMake(CGRectGetMaxX(buttonShop.frame), 0, viewBtns.width/2, 32) btnTitle:@"理发订单" btnImage:@"" titleColor:[UIColor whiteColor] titleFont:14];
        buttonCut.backgroundColor = RGBMAIN;
        
        CGFloat corner1 = 16;
        CAShapeLayer *shapeLayer1 = [CAShapeLayer layer];
        shapeLayer1.path = [UIBezierPath bezierPathWithRoundedRect:buttonCut.bounds byRoundingCorners:UIRectCornerTopRight | UIRectCornerBottomRight cornerRadii:CGSizeMake(corner1, corner1)].CGPath;
        buttonCut.layer.mask = shapeLayer1;
        
        buttonCut.layer.borderWidth = 1;
        buttonCut.layer.borderColor = [UIColor whiteColor].CGColor;
        
        [viewBtns addSubview:buttonCut];
        self.buttonCut = buttonCut;
        
        [buttonCut addTarget:self action:@selector(buttonCutAction:) forControlEvents:UIControlEventTouchUpInside];
    }
    return _headerButtonView;
}

// 商品订单
-(UIView *)viewShopOrders{
    if (!_viewShopOrders) {
        _viewShopOrders = [[UIView alloc] initWithFrame:CGRectMake(0, _headerButtonView.bottom, kSCREEN_WIDTH, kSCREEN_HEIGHT-NAVHIGHT-_headerButtonView.height)];
        _viewShopOrders.hidden = NO;
        
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
        ZJScrollPageView *scrollPageView = [[ZJScrollPageView alloc] initWithFrame:CGRectMake(0, 0, kSCREEN_WIDTH, _viewShopOrders.height) segmentStyle:style childVcs:childVcs parentViewController:self];
        
        [_viewShopOrders addSubview:scrollPageView];
    }
    return _viewShopOrders;
}

// 理发订单
-(UIView *)viewCutOrders{
    if (!_viewCutOrders) {
        _viewCutOrders = [[UIView alloc] initWithFrame:CGRectMake(0, _headerButtonView.bottom, kSCREEN_WIDTH, kSCREEN_HEIGHT-NAVHIGHT-_headerButtonView.height)];
        _viewCutOrders.hidden = NO;
        
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
        ZJScrollPageView *scrollPageView = [[ZJScrollPageView alloc] initWithFrame:CGRectMake(0, 0, kSCREEN_WIDTH, _viewCutOrders.height) segmentStyle:style childVcs:childVcs parentViewController:self];
        self.cutScrollPageView = scrollPageView;
        
        [_viewCutOrders addSubview:scrollPageView];
    }
    return _viewCutOrders;
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

// 添加理发订单子控制器
- (NSArray *)setupCutChildVcAndTitle {
    self.vcWaitPay = [[HDMyCutOrdersToPayViewController alloc] init];
    self.vcWaitPay.title = @"待支付";
    
    self.vcWait = [[HDMyCutOrdersWaitViewController alloc] init];
//    vc1.type = @"1";
    self.vcWait.title = @"待消费";

    HDMyCutOrderServicesViewController *vc2 = [[HDMyCutOrderServicesViewController alloc] init];
//    vc2.type = @"2";
    vc2.title = @"服务中";

    HDMyCutOrdersDoneViewController *vc3 = [[HDMyCutOrdersDoneViewController alloc] init];
    vc3.type = @"3";
    vc3.title = @"已完成";

    HDMyCutOrdersDoneViewController *vc4 = [[HDMyCutOrdersDoneViewController alloc] init];
    vc4.type = @"4";
//    vc4.delegate = self;
    vc4.title = @"已取消/过号";

    NSArray *childVcs = [NSArray arrayWithObjects:self.vcWaitPay,self.vcWait, vc2, vc3,vc4, nil];
    return childVcs;
}

-(HDBaseNavView *)navView{
    if (!_navView) {
        _navView = [[HDBaseNavView alloc] initWithFrame:CGRectMake(0, 0, kSCREEN_WIDTH, NAVHIGHT) title:@"我的订单" bgColor:RGBMAIN backBtn:YES rightBtn:@"" rightBtnImage:@"" theDelegate:self];
    }
    return _navView;
}

@end
