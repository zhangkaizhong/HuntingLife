//
//  HDOrderManageViewController.m
//  HairDress
//
//  Created by 张凯中 on 2019/12/26.
//  Copyright © 2019 zhangkaizhong. All rights reserved.
//

#import "HDMyCollectionsViewController.h"

#import "HDMyCollectionsShopViewController.h"
#import "HDMyCollectionsCutterViewController.h"
#import "HDMyCollectionsGoodViewController.h"

#import "ZJSegmentStyle.h"
#import "ZJScrollPageView.h"

@interface HDMyCollectionsViewController ()<navViewDelegate>

@property (nonatomic,strong) HDBaseNavView *navView;

@end

@implementation HDMyCollectionsViewController

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

    HDMyCollectionsShopViewController *vc1 = [[HDMyCollectionsShopViewController alloc] init];
    vc1.collectType = @"store";
    vc1.title = @"门店";

    HDMyCollectionsCutterViewController *vc2 = [[HDMyCollectionsCutterViewController alloc] init];
    vc2.collectType = @"tony";
    vc2.title = @"发型师";

//    HDMyCollectionsGoodViewController *vc3 = [[HDMyCollectionsGoodViewController alloc] init];
//    vc3.title = @"商品";

    NSArray *childVcs = [NSArray arrayWithObjects:vc1, vc2,nil];
    return childVcs;
}

#pragma mark ================== 加载控件 =====================

-(HDBaseNavView *)navView{
    if (!_navView) {
        _navView = [[HDBaseNavView alloc] initWithFrame:CGRectMake(0, 0, kSCREEN_WIDTH, NAVHIGHT) title:@"我的收藏" bgColor:RGBMAIN backBtn:YES rightBtn:@"" rightBtnImage:@"" theDelegate:self];
    }
    return _navView;
}

@end
