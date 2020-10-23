//
//  PersonalCenterViewController.m
//
//
//  Created by hyw on 2018/11/14.
//  Copyright © 2018年 bksx. All rights reserved.
//

#import "HDNewTaskViewController.h"
#import "CenterTouchTableView.h"

#import "YWPageHeadView.h"
#import "HW3DBannerView.h"
#import <SDCycleScrollView.h>

#import "HDTaskSubAllListViewController.h"
#import "HDWebViewController.h"
#import "HDTaoGoodsDetailViewController.h"
#import "HDMyTaskListViewController.h"

#import "ZJSegmentStyle.h"
#import "ZJScrollPageView.h"

#define PageHeadViewHegiht 173
#define HeaderHeight 44

@interface HDNewTaskViewController () <SDCycleScrollViewDelegate,navViewDelegate,ZJScrollSegmentViewDelegate,UITableViewDelegate, UITableViewDataSource, UIGestureRecognizerDelegate>

@property (nonatomic,strong) HDTaskSubAllListViewController *vc1;
@property (nonatomic,strong) HDTaskSubAllListViewController *vc2;
@property (nonatomic,strong) HDTaskSubAllListViewController *vc3;
@property (nonatomic,strong) HDTaskSubAllListViewController *vc4;
@property (nonatomic,strong) HDBaseNavView *navView;

@property (nonatomic, strong) CenterTouchTableView *mainTableView;
@property (nonatomic,strong) HW3DBannerView *bannerView;
@property (nonatomic,strong) SDCycleScrollView *SDBannarView;

@property (nonatomic,strong) UIButton *btnRecords;

@property (nonatomic, strong) ZJScrollPageView *segmentView;
@property (nonatomic,strong) YWPageHeadView *pageHeadView;

@property (nonatomic, assign) BOOL canScroll;//mainTableView是否可以滚动
@property (nonatomic, assign) BOOL isBacking;//是否正在pop

//空白view，可以加空间
@property (nonatomic, strong) UIView *tabHeadView;
//头部总高度
@property (nonatomic, assign) CGFloat offHeight;

//任务数据详情
@property (nonatomic,strong) NSDictionary *taskNumInfo;
//banner
@property (nonatomic,strong) NSMutableArray *bannerListArray;
@property (nonatomic,strong) NSMutableArray *imageArray;

@end


@implementation HDNewTaskViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.view.backgroundColor = [UIColor whiteColor];
    if (@available(iOS 11.0, *)) {
        [[UIScrollView appearance] setContentInsetAdjustmentBehavior:UIScrollViewContentInsetAdjustmentNever];
    }else {
        self.automaticallyAdjustsScrollViewInsets = NO;
    }
    
    //如果使用自定义的按钮去替换系统默认返回按钮，会出现滑动返回手势失效的情况
    self.navigationController.interactivePopGestureRecognizer.delegate = self;
    //注册允许外层tableView滚动通知-解决和分页视图的上下滑动冲突问题
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(acceptMsg:) name:@"leaveTop" object:nil];
    //分页的scrollView左右滑动的时候禁止mainTableView滑动，停止滑动的时候允许mainTableView滑动
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(acceptMsg:) name:@"IsEnablePersonalCenterVCMainTableViewScroll" object:nil];
    
    self.imageArray = [NSMutableArray new];
    self.bannerListArray = [NSMutableArray new];
    //这三个高度必须先算出来，建议请求完数据知道高度以后再调用下面代码
    self.offHeight = (PageHeadViewHegiht+HeaderHeight)*SCALE;
    
    [self.view addSubview:self.navView];
    [self.view addSubview:self.mainTableView];
    
    [self.view addSubview:self.btnRecords];
    
    [self getTaskIndexNumData];
}

#pragma mark ================== 监听网络变化后重新加载数据 =====================
-(void)getLoadDataBase:(NSNotification *)text{
    [super getLoadDataBase:text];
    if ([text.userInfo[@"netType"] integerValue] != 0) {
        if (!self.taskNumInfo) {
            [self getTaskIndexNumData];
        }
    }
}

#pragma mark ================== 数据请求 =====================
//任务数
-(void)getTaskIndexNumData{
    [MHNetworkManager postReqeustWithURL:URL_TaskQueryAppTaskIndexNum params:@{} successBlock:^(NSDictionary *returnData) {
        
        returnData = [HDToolHelper nullDicToDic:returnData];
        if ([returnData[@"respCode"] integerValue] == 200) {
            self.taskNumInfo = [HDToolHelper nullDicToDic:returnData[@"data"]];
            
            [self setupSubViews];
            
            [self getBarnnerList];
        }
    } failureBlock:^(NSError *error) {
        
    } showHUD:YES];
}

//轮播
-(void)getBarnnerList{
//    WeakSelf;
    [MHNetworkManager postReqeustWithURL:URL_GetBannarList params:@{@"positionCode":@"taskIndex"} successBlock:^(NSDictionary *returnData) {
        returnData = [HDToolHelper nullDicToDic:returnData];
        if ([returnData[@"respCode"] integerValue] == 200) {
            [self.bannerListArray removeAllObjects];
            [self.imageArray removeAllObjects];
            [self.bannerListArray addObjectsFromArray:returnData[@"data"]];
            for (NSDictionary *dicPic in self.bannerListArray) {
                [self.imageArray addObject:dicPic[@"bannerPic"]];
            }
            
            if (self.bannerListArray.count == 0) {
                self.bannerView.hidden = YES;
            }else{
                self.bannerView.hidden = YES;
                self.SDBannarView.hidden = NO;
                self.SDBannarView.imageURLStringsGroup = self.imageArray;
                
//                self.bannerView.hidden = NO;
//                if (self.imageArray.count == 1) {
//                    self.bannerView.hidden = YES;
//                    self.SDBannarView.hidden = NO;
//                    self.SDBannarView.imageURLStringsGroup = self.imageArray;
//                }else{
//                    self.bannerView.hidden = NO;
//                    self.SDBannarView.hidden = YES;
//                    self.bannerView.data = self.imageArray;
//                }
//                self.bannerView.clickImageBlock = ^(NSInteger currentIndex) { // 点击中间图片的回调
//                    NSDictionary *dic = weakSelf.bannerListArray[currentIndex];
//                    if ([dic[@"bannerType"] isEqualToString:@"ahref"] || [dic[@"bannerType"] isEqualToString:@"custom"]) {//超级链接、自定义链接
//                        HDWebViewController *webVC = [[HDWebViewController alloc] init];
//                        webVC.url_str = dic[@"bannerTypeValue"];
//                        webVC.title_str = dic[@"bannerTitle"];
//                        [weakSelf.navigationController pushViewController:webVC animated:YES];
//                    }
//                    if ([dic[@"bannerType"] isEqualToString:@"single"]) {//商品
//                        HDTaoGoodsDetailViewController *detailVC = [HDTaoGoodsDetailViewController new];
//                        detailVC.taoId = dic[@"bannerTypeValue"];
//                        detailVC.indexTab = 2;
//                        [weakSelf.navigationController pushViewController:detailVC animated:YES];
//                    }
//                };
            }
        }
    } failureBlock:^(NSError *error) {
        
    } showHUD:YES];
}

//点击滚动按钮
-(void)clickBtnLabelAtIndex:(NSInteger)currentIndex{
    if (currentIndex == 0) {
        [self.vc1 loadNewData];
    }
    if (currentIndex == 1) {
        [self.vc2 loadNewData];
    }
    if (currentIndex == 2) {
        [self.vc3 loadNewData];
    }
    if (currentIndex == 3) {
        [self.vc4 loadNewData];
    }
}

//查看任务记录
-(void)btnRecordsAction:(UIButton *)sender{
    if ([[HDUserDefaultMethods getData:@"userId"] isEqualToString:@""]) {
        [HDToolHelper preToLoginView];
        return;
    }
    HDMyTaskListViewController *taskVC = [HDMyTaskListViewController new];
    [self.navigationController pushViewController:taskVC animated:YES];
}

//滚动视图点击代理
-(void)cycleScrollView:(SDCycleScrollView *)cycleScrollView didSelectItemAtIndex:(NSInteger)index{
    NSDictionary *dic = self.bannerListArray[index];
    if ([dic[@"bannerType"] isEqualToString:@"ahref"] || [dic[@"bannerType"] isEqualToString:@"custom"]) {//超级链接、自定义链接
        HDWebViewController *webVC = [[HDWebViewController alloc] init];
        webVC.url_str = dic[@"bannerTypeValue"];
        webVC.title_str = dic[@"bannerTitle"];
        [self.navigationController pushViewController:webVC animated:YES];
    }
    if ([dic[@"bannerType"] isEqualToString:@"single"]) {//商品
        HDTaoGoodsDetailViewController *detailVC = [HDTaoGoodsDetailViewController new];
        detailVC.taoId = dic[@"bannerTypeValue"];
        detailVC.indexTab = 2;
        [self.navigationController pushViewController:detailVC animated:YES];
    }
}

#pragma mark - Private Methods
- (void)setupSubViews {
    self.mainTableView.backgroundColor = [UIColor clearColor];
    
    self.mainTableView.tableHeaderView = self.pageHeadView;
    [self.pageHeadView addSubview:self.bannerView];
    [self.pageHeadView addSubview:self.SDBannarView];
    [self.pageHeadView addSubview:self.tabHeadView];
    self.pageHeadView.parentScrollView = self.mainTableView;
    self.pageHeadView.chidlScrollView = self.bannerView.mainScrollView;
    
    _bannerView.placeHolderImage = [UIImage imageNamed:@""]; // 设置占位图片
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];

}

- (void)acceptMsg:(NSNotification *)notification {
    NSDictionary *userInfo = notification.userInfo;
    
    if ([notification.name isEqualToString:@"leaveTop"]) {
        NSString *canScroll = userInfo[@"canScroll"];
        if ([canScroll isEqualToString:@"1"]) {
            self.canScroll = YES;
        }
    } else if ([notification.name isEqualToString:@"IsEnablePersonalCenterVCMainTableViewScroll"]) {
        NSString *canScroll = userInfo[@"canScroll"];
        if ([canScroll isEqualToString:@"1"]) {
            self.mainTableView.scrollEnabled = YES;
        } else if([canScroll isEqualToString:@"0"]) {
            self.mainTableView.scrollEnabled = NO;
        }
    }
}

#pragma mark - UiScrollViewDelegate
- (BOOL)scrollViewShouldScrollToTop:(UIScrollView *)scrollView {
    //通知分页子控制器列表返回顶部
    [[NSNotificationCenter defaultCenter] postNotificationName:@"SegementViewChildVCBackToTop" object:nil];
    return YES;
}

/**
 * 处理联动
 * 因为要实现下拉头部放大的问题，tableView设置了contentInset，所以试图刚加载的时候会调用一遍这个方法，所以要做一些特殊处理，
 */
- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
    //当前y轴偏移量
    CGFloat currentOffsetY  = scrollView.contentOffset.y;
    CGFloat criticalPointOffsetY = [self.mainTableView rectForSection:0].origin.y;
    //利用contentOffset处理内外层scrollView的滑动冲突问题
    if (currentOffsetY >= criticalPointOffsetY) {
        scrollView.contentOffset = CGPointMake(0, criticalPointOffsetY);
        [[NSNotificationCenter defaultCenter] postNotificationName:@"goTop" object:nil userInfo:@{@"canScroll":@"1"}];
        self.canScroll = NO;
    } else {
        if (!self.canScroll) {
            scrollView.contentOffset = CGPointMake(0, criticalPointOffsetY);
        }
    }
}

#pragma mark - UITableViewDataSource
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return 1;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:NSStringFromClass([UITableViewCell class])];
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    [cell.contentView addSubview:self.setPageViewControllers];
    return cell;
}

#pragma mark - UITableViewDelegate
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return kSCREEN_HEIGHT - NAVHIGHT-KTarbarHeight;
}

//导航栏
-(HDBaseNavView *)navView{
    if (!_navView) {
        _navView = [[HDBaseNavView alloc] initWithFrame:CGRectMake(0, 0, kSCREEN_WIDTH, NAVHIGHT) title:@"任务列表" bgColor:[UIColor whiteColor] backBtn:YES rightBtn:@"" rightBtnImage:@"" theDelegate:self];
    }
    return _navView;
}

-(void)navBackClicked{
    [self.navigationController popViewControllerAnimated:YES];
}

/*
 * 这里可以设置替换你喜欢的segmentView
 */
- (UIView *)setPageViewControllers {
    if (!_segmentView) {
        
        ZJSegmentStyle *style = [[ZJSegmentStyle alloc] init];
        //显示滚动条
        style.showLine = YES;
        style.scrollTitle = NO;
        style.selectedTitleColor = RGBMAIN;
        style.scrollLineColor = RGBMAIN;
        style.normalTitleColor = RGBTEXT;
        style.titleCanReload = YES;
        style.titleFont = TEXT_SC_TFONT(TEXT_SC_Medium, 14*SCALE);
        style.titleSelectedFont = TEXT_SC_TFONT(TEXT_SC_Medium, 14*SCALE);
        // 颜色渐变
        style.gradualChangeTitleColor = YES;
        // 设置子控制器 --- 注意子控制器需要设置title, 将用于对应的tag显示title
        NSArray *childVcs = [NSArray arrayWithArray:[self setupChildVcAndTitle]];
        // 初始化
        ZJScrollPageView *scrollPageView = [[ZJScrollPageView alloc] initWithFrame:CGRectMake(0,0, kSCREEN_WIDTH, kSCREEN_HEIGHT - NAVHIGHT-KTarbarHeight) segmentStyle:style childVcs:childVcs parentViewController:self];
        _segmentView = scrollPageView;
        scrollPageView.segmentView.segDelegate = self;
    }
    return _segmentView;
}

// 创建自控制器
- (NSArray *)setupChildVcAndTitle {
    self.vc1 = [[HDTaskSubAllListViewController alloc] init];
    self.vc1.title = @"全部";
    self.vc1.taskType = @"";
    self.vc2 = [[HDTaskSubAllListViewController alloc] init];
    self.vc2.title = @"分享";
    self.vc2.taskType = @"share";
    self.vc3 = [[HDTaskSubAllListViewController alloc] init];
    self.vc3.title = @"点赞";
    self.vc3.taskType = @"seem";
    self.vc4 = [[HDTaskSubAllListViewController alloc] init];
    self.vc4.title = @"播放";
    self.vc4.taskType = @"video";

    NSArray *childVcs = [NSArray arrayWithObjects:self.vc1, self.vc2, self.vc3,self.vc4,nil];
    return childVcs;
}

- (UITableView *)mainTableView {
    if (!_mainTableView) {
        self.canScroll = YES;
        
        self.mainTableView = [[CenterTouchTableView alloc]initWithFrame:CGRectMake(0, NAVHIGHT, kSCREEN_WIDTH, kSCREEN_HEIGHT-KTarbarHeight-NAVHIGHT) style:UITableViewStylePlain];
        _mainTableView.delegate = self;
        _mainTableView.dataSource = self;
        _mainTableView.showsVerticalScrollIndicator = NO;
        [_mainTableView registerClass:[UITableViewCell class] forCellReuseIdentifier:NSStringFromClass([UITableViewCell class])];
        _mainTableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    }
    return _mainTableView;
}

// 头部视图
-(UIView *)tabHeadView{
    if (!_tabHeadView) {
        _tabHeadView = [[UIView alloc]initWithFrame:CGRectMake(0, _bannerView.bottom, kSCREEN_WIDTH, HeaderHeight)];
        
        NSString *numstr = @"0";
        numstr = [NSString stringWithFormat:@"%ld",(long)[self.taskNumInfo[@"totalNum"] integerValue]];
        
        UILabel *lblTaskNum = [[UILabel alloc] initWithFrame:CGRectMake(12, 15*SCALE, 100, 20)];
        NSMutableAttributedString *string = [[NSMutableAttributedString alloc] initWithString:[NSString stringWithFormat:@"今日工作：%@个",numstr] attributes: @{NSFontAttributeName: [UIFont fontWithName:@"PingFang SC" size: 14],NSForegroundColorAttributeName: RGBMAIN}];
        lblTaskNum.attributedText = string;
        [lblTaskNum sizeToFit];
        [_tabHeadView addSubview:lblTaskNum];
        
        NSString *moneystr = @"0";
        moneystr = [NSString stringWithFormat:@"%.2f",[self.taskNumInfo[@"sumMoney"] floatValue]];
        UILabel *lblMoney = [[UILabel alloc] initWithFrame:CGRectMake(CGRectGetMaxX(lblTaskNum.frame), 0, kSCREEN_WIDTH-CGRectGetMaxX(lblTaskNum.frame)-12, 20)];
        lblMoney.centerY = lblTaskNum.centerY;
        NSMutableAttributedString *stringMoney = [[NSMutableAttributedString alloc] initWithString:[NSString stringWithFormat:@"可赚%@元",moneystr] attributes: @{NSFontAttributeName: [UIFont fontWithName:@"PingFang SC" size: 14],NSForegroundColorAttributeName: [UIColor colorWithRed:255/255.0 green:194/255.0 blue:63/255.0 alpha:1.0]}];
        lblMoney.textAlignment = NSTextAlignmentRight;
        lblMoney.attributedText = stringMoney;
        [_tabHeadView addSubview:lblMoney];
    }
    return _tabHeadView;
}

-(HW3DBannerView *)bannerView{
    if (!_bannerView) {
        _bannerView = [HW3DBannerView initWithFrame:CGRectMake(0, 9*SCALE, kSCREEN_WIDTH, 164*SCALE) imageSpacing:10 imageWidth:kSCREEN_WIDTH - 50*SCALE];
        _bannerView.initAlpha = 0.5; // 设置两边卡片的透明度
        _bannerView.imageRadius = 10; // 设置卡片圆角
        _bannerView.imageHeightPoor = 10; // 设置中间卡片与两边卡片的高度差
        _bannerView.showPageControl = NO;
        _bannerView.autoScrollTimeInterval = 3;
    }
    return _bannerView;
}

-(SDCycleScrollView *)SDBannarView{
    if (!_SDBannarView) {
        /// 轮播图
        SDCycleScrollView *cycleScrollView = [SDCycleScrollView cycleScrollViewWithFrame:CGRectMake(0, 9*SCALE, kSCREEN_WIDTH, 164*SCALE) delegate:self placeholderImage:[UIImage imageNamed:@""]];
        cycleScrollView.bannerImageViewContentMode = UIViewContentModeScaleAspectFill;
        cycleScrollView.autoScrollTimeInterval = 3;
        cycleScrollView.showPageControl = NO;
        _SDBannarView = cycleScrollView;
        _SDBannarView.hidden = YES;
    }
    return _SDBannarView;
}


-(YWPageHeadView *)pageHeadView{
    if (!_pageHeadView) {
        _pageHeadView = [[YWPageHeadView alloc]init];
        _pageHeadView.frame = CGRectMake(0, 0,kSCREEN_WIDTH, self.offHeight);
    }
    return _pageHeadView;
}

//任务记录
-(UIButton *)btnRecords{
    if (!_btnRecords) {
        _btnRecords = [[UIButton alloc] initSystemWithFrame:CGRectMake(kSCREEN_WIDTH-60*SCALE, kSCREEN_HEIGHT-KTarbarHeight-43*SCALE, 48*SCALE, 43*SCALE) btnTitle:@"" btnImage:@"tasklist_ic_taskrecord" titleColor:[UIColor clearColor] titleFont:0];
        [_btnRecords addTarget:self action:@selector(btnRecordsAction:) forControlEvents:UIControlEventTouchUpInside];
    }
    return _btnRecords;
}

//视图加载过程
- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    self.isBacking = NO;
    [[NSNotificationCenter defaultCenter] postNotificationName:@"PersonalCenterVCBackingStatus" object:nil userInfo:@{@"isBacking":@(self.isBacking)}];
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    self.isBacking = YES;
    [[NSNotificationCenter defaultCenter] postNotificationName:@"PersonalCenterVCBackingStatus" object:nil userInfo:@{@"isBacking":@(self.isBacking)}];
}

- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

@end
