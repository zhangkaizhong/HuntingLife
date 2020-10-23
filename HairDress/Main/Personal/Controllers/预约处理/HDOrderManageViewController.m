//
//  HDOrderManageViewController.m
//  HairDress
//
//  Created by 张凯中 on 2019/12/26.
//  Copyright © 2019 zhangkaizhong. All rights reserved.
//

#import "HDOrderManageViewController.h"

#import "HDOrderManageSubViewController.h"

#import "ZJSegmentStyle.h"
#import "ZJScrollPageView.h"

@interface HDOrderManageViewController ()<navViewDelegate>

@property (nonatomic,strong) HDBaseNavView *navView;
@property (nonatomic,strong) ZJScrollPageView *orderScrollPageView;

@end

@implementation HDOrderManageViewController

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
    self.orderScrollPageView = scrollPageView;
    if (_index) {
        [self.orderScrollPageView setSelectedIndex:_index animated:NO];
    }
    [self.view addSubview:scrollPageView];

}

#pragma mark -- delegate / action
-(void)navBackClicked{
    [self.navigationController popViewControllerAnimated:YES];
}

- (NSArray *)setupChildVcAndTitle {
    
    HDOrderManageSubViewController *vc1 = [[HDOrderManageSubViewController alloc] init];
    vc1.type = @"queue";
    vc1.title = @"待接单";

    HDOrderManageSubViewController *vc2 = [[HDOrderManageSubViewController alloc] init];
    vc2.type = @"service";
    vc2.title = @"已接单";

    HDOrderManageSubViewController *vc3 = [[HDOrderManageSubViewController alloc] init];
    vc3.type = @"finish";
    vc3.title = @"已完成";
    
    HDOrderManageSubViewController *vc4 = [[HDOrderManageSubViewController alloc] init];
    vc4.type = @"cancel";
    vc4.title = @"退款/过号";

    NSArray *childVcs = [NSArray arrayWithObjects:vc1, vc2, vc3,vc4,nil];
    return childVcs;
}

//选中页面
-(void)selectIndexRefresh:(NSInteger)index{
    [self.orderScrollPageView setSelectedIndex:index animated:NO];
}

-(HDBaseNavView *)navView{
    if (!_navView) {
        if (!self.suTitle) {
            self.suTitle = @"预约处理";
        }
        _navView = [[HDBaseNavView alloc] initWithFrame:CGRectMake(0, 0, kSCREEN_WIDTH, NAVHIGHT) title:self.suTitle bgColor:RGBMAIN backBtn:YES rightBtn:@"" rightBtnImage:@"" theDelegate:self];
    }
    return _navView;
}

@end
