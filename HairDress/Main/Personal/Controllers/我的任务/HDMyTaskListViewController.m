//
//  PersonalCenterViewController.m
//
//
//  Created by hyw on 2018/11/14.
//  Copyright © 2018年 bksx. All rights reserved.
//

#import "HDMyTaskListViewController.h"
#import "CenterTouchTableView.h"

#import "YWPageHeadView.h"
#import "HW3DBannerView.h"

#import "HDMyTaskCountInfoModel.h"

#import "HDNewPersonalViewController.h"
#import "HDMyTaskListSubViewController.h"
#import "HDMyWithdrawViewController.h"

#import "ZJSegmentStyle.h"
#import "ZJScrollPageView.h"

@interface HDMyTaskListViewController () <navViewDelegate,UITableViewDelegate, UITableViewDataSource, UIGestureRecognizerDelegate>
{
    CGRect initialFrame;
    CGFloat defaultViewHeight;
}
@property (nonatomic,strong) HDBaseNavView *navView;

@property (nonatomic, strong) CenterTouchTableView *mainTableView;

@property (nonatomic, strong) ZJScrollPageView *segmentView;

@property (nonatomic, assign) BOOL canScroll;//mainTableView是否可以滚动
@property (nonatomic, assign) BOOL isBacking;//是否正在pop

//头部背景图
@property (nonatomic,strong) UIImageView *imageHeadBack;

@property (nonatomic,weak) UILabel *lblTotalNum;//任务数
@property (nonatomic,weak) UILabel *lblFinishNum;//累计奖励
@property (nonatomic,weak) UILabel *lblTotalMoney;//累计收入

@property (nonatomic,strong) YWPageHeadView *pageHeadView;

//任务数据详情
@property (nonatomic,strong) HDMyTaskCountInfoModel *taskNumInfoModel;

@end


@implementation HDMyTaskListViewController

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
    
    [self setupSubViews];
    
    [self getMyTaskData];
}

#pragma mark ================== 监听网络变化后重新加载数据 =====================
-(void)getLoadDataBase:(NSNotification *)text{
    [super getLoadDataBase:text];
    if ([text.userInfo[@"netType"] integerValue] != 0) {
        
    }
}

#pragma mark -- delegate / action
-(void)navBackClicked{
    for (UIViewController *viewCon in [self.navigationController viewControllers]) {
        if ([viewCon isKindOfClass:[HDNewPersonalViewController class]]) {
            HDNewPersonalViewController *perVC = (HDNewPersonalViewController *)viewCon;
            [self.navigationController popToViewController:perVC animated:YES];
            return;
        }
    }
    [self.navigationController popViewControllerAnimated:YES];
}

//提现
-(void)btnWithDrewAction:(UIButton *)sender{
    HDMyWithdrawViewController *withVC = [HDMyWithdrawViewController new];
    [self.navigationController pushViewController:withVC animated:YES];
}

#pragma mark ================== 数据请求 =====================
//我的任务统计数据
-(void)getMyTaskData{
    [MHNetworkManager postReqeustWithURL:URL_TaskQueryUserTaskCountInfo params:@{@"id":[HDUserDefaultMethods getData:@"userId"]} successBlock:^(NSDictionary *returnData) {
        DTLog(@"%@",returnData);
        if ([returnData[@"respCode"] integerValue] == 200) {
            self.taskNumInfoModel = [HDMyTaskCountInfoModel mj_objectWithKeyValues:returnData[@"data"]];
            self.lblTotalNum.text = self.taskNumInfoModel.totalNum;
            self.lblFinishNum.text = self.taskNumInfoModel.finishNum;
            self.lblTotalMoney.text = self.taskNumInfoModel.totalMoney;
        }
    } failureBlock:^(NSError *error) {
        
    } showHUD:YES];
}

#pragma mark - Private Methods
- (void)setupSubViews {
    self.mainTableView.backgroundColor = [UIColor clearColor];
    
    [self.view addSubview:self.mainTableView];
    [self.view addSubview:self.navView];
    
    self.mainTableView.tableHeaderView = self.pageHeadView;
    self.pageHeadView.parentScrollView = self.mainTableView;
    
    initialFrame       = _imageHeadBack.frame;
    defaultViewHeight  = initialFrame.size.height;
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
    CGFloat criticalPointOffsetY = [self.mainTableView rectForSection:0].origin.y-NAVHIGHT-8*SCALE;
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
    
    if (currentOffsetY <= 0) {//下拉，隐藏 navView
        _navView.backgroundColor = [RGBMAIN colorWithAlphaComponent:0];
        // 背景拉伸
        CGFloat offsetY = (scrollView.contentOffset.y + scrollView.contentInset.top) * -1;
        initialFrame.origin.y = - offsetY * 1;
        initialFrame.size.height = defaultViewHeight + offsetY;
        _imageHeadBack.frame = initialFrame;
    }else if(currentOffsetY > NAVHIGHT){//移动过程
        _navView.backgroundColor = [RGBMAIN colorWithAlphaComponent:currentOffsetY/(NAVHIGHT*2)];
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
    return kSCREEN_HEIGHT - NAVHIGHT-8*SCALE;
}

//导航栏
-(HDBaseNavView *)navView{
    if (!_navView) {
        _navView = [[HDBaseNavView alloc] initWithFrame:CGRectMake(0, 0, kSCREEN_WIDTH, NAVHIGHT) title:@"我的任务" bgColor:RGBMAIN backBtn:YES rightBtn:@"" rightBtnImage:@"" theDelegate:self];
        _navView.backgroundColor = [UIColor clearColor];
    }
    return _navView;
}

-(UIImageView *)imageHeadBack{
    if (!_imageHeadBack) {
        _imageHeadBack = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, kSCREEN_WIDTH, 156)];
        _imageHeadBack.image = [UIImage imageNamed:@"task_nav_bg"];
    }
    return _imageHeadBack;
}

/*
 * 这里可以设置替换你喜欢的segmentView
 */
- (UIView *)setPageViewControllers {
    if (!_segmentView) {
        
        ZJSegmentStyle *style = [[ZJSegmentStyle alloc] init];
        //显示滚动条
        style.showLine = YES;
        style.scrollTitle = YES;
        style.selectedTitleColor = RGBMAIN;
        style.scrollLineColor = RGBMAIN;
        style.normalTitleColor = RGBTEXT;
        style.titleFont = TEXT_SC_TFONT(TEXT_SC_Regular, 12*SCALE);
        style.titleSelectedFont = TEXT_SC_TFONT(TEXT_SC_Regular, 12*SCALE);
        // 颜色渐变
        style.gradualChangeTitleColor = YES;
        // 设置子控制器 --- 注意子控制器需要设置title, 将用于对应的tag显示title
        NSArray *childVcs = [NSArray arrayWithArray:[self setupChildVcAndTitle]];
        // 初始化
        ZJScrollPageView *scrollPageView = [[ZJScrollPageView alloc] initWithFrame:CGRectMake(12*SCALE,0, kSCREEN_WIDTH-24*SCALE, kSCREEN_HEIGHT - NAVHIGHT-12*SCALE-8*SCALE) segmentStyle:style childVcs:childVcs parentViewController:self];
        _segmentView = scrollPageView;
        
        scrollPageView.layer.borderWidth = 1;
        scrollPageView.layer.borderColor = RGBCOLOR(210, 210, 210).CGColor;
        scrollPageView.layer.cornerRadius = 4;
    }
    return _segmentView;
}

// 创建自控制器
- (NSArray *)setupChildVcAndTitle {
    HDMyTaskListSubViewController *vc1 = [[HDMyTaskListSubViewController alloc] init];
    vc1.title = @"全部";
    vc1.checkStatus = @"";
    HDMyTaskListSubViewController *vc2 = [[HDMyTaskListSubViewController alloc] init];
    vc2.title = @"进行中";
    vc2.checkStatus = @"accept";
    HDMyTaskListSubViewController *vc3 = [[HDMyTaskListSubViewController alloc] init];
    vc3.title = @"审核中";
    vc3.checkStatus = @"waitCheck";
    HDMyTaskListSubViewController *vc4 = [[HDMyTaskListSubViewController alloc] init];
    vc4.title = @"已结束";
    vc4.checkStatus = @"finish";

    NSArray *childVcs = [NSArray arrayWithObjects:vc1, vc2, vc3,vc4,nil];
    return childVcs;
}

- (UITableView *)mainTableView {
    if (!_mainTableView) {
        self.canScroll = YES;
        
        self.mainTableView = [[CenterTouchTableView alloc]initWithFrame:CGRectMake(0, 0, kSCREEN_WIDTH, kSCREEN_HEIGHT) style:UITableViewStylePlain];
        _mainTableView.delegate = self;
        _mainTableView.dataSource = self;
        _mainTableView.showsVerticalScrollIndicator = NO;
        [_mainTableView registerClass:[UITableViewCell class] forCellReuseIdentifier:NSStringFromClass([UITableViewCell class])];
        _mainTableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    }
    return _mainTableView;
}

//头视图
-(YWPageHeadView *)pageHeadView{
    if (!_pageHeadView) {
        _pageHeadView = [[YWPageHeadView alloc]init];
        _pageHeadView.frame = CGRectMake(0, 0,kSCREEN_WIDTH, 0);
        
        [_pageHeadView addSubview:self.imageHeadBack];
        
        UILabel *lblMy = [[UILabel alloc] initCommonWithFrame:CGRectMake(12*SCALE, NAVHIGHT+28*SCALE, kSCREEN_WIDTH/2, 16*SCALE) title:@"我的战绩" bgColor:[UIColor clearColor] titleColor:[UIColor whiteColor] titleFont:16 textAlignment:NSTextAlignmentLeft isFit:NO];
        lblMy.font = TEXT_SC_TFONT(TEXT_SC_Medium, 16*SCALE);
        [_pageHeadView addSubview:lblMy];
        
        UIView *viewMain = [[UIView alloc] initWithFrame:CGRectMake(12*SCALE, lblMy.bottom+14*SCALE, kSCREEN_WIDTH-24*SCALE, 118*SCALE)];
        viewMain.layer.backgroundColor = [UIColor whiteColor].CGColor;
        viewMain.layer.shadowColor = RGBAlpha(0, 0, 0, 0.06).CGColor;
        viewMain.layer.shadowOffset = CGSizeMake(0,6);
        viewMain.layer.shadowOpacity = 1;
        viewMain.layer.shadowRadius = 6;
        [_pageHeadView addSubview:viewMain];
        
        _pageHeadView.height = viewMain.bottom+8*SCALE;
        
        //我的任务
        UIView *subViewTotalNum = [[UIView alloc] initWithFrame:CGRectMake(0, 0, viewMain.width/3, viewMain.height)];
        [viewMain addSubview:subViewTotalNum];
        UILabel *lblTotalNum = [[UILabel alloc] initCommonWithFrame:CGRectMake(0, 39*SCALE, subViewTotalNum.width, 22*SCALE) title:@"0" bgColor:[UIColor clearColor] titleColor:RGBTEXT titleFont:22*SCALE textAlignment:NSTextAlignmentCenter isFit:NO];
        [subViewTotalNum addSubview:lblTotalNum];
        lblTotalNum.font = TEXT_SC_TFONT(TEXT_SC_Medium, 22*SCALE);
        self.lblTotalNum = lblTotalNum;
        
        UILabel *lblTotalNumText = [[UILabel alloc] initCommonWithFrame:CGRectMake(0, lblTotalNum.bottom+8*SCALE, subViewTotalNum.width, 12*SCALE) title:@"我的任务" bgColor:[UIColor clearColor] titleColor:RGBLIGHT_TEXTINFO titleFont:12*SCALE textAlignment:NSTextAlignmentCenter isFit:NO];
        [subViewTotalNum addSubview:lblTotalNumText];
        
        UIView *line1 = [[UIView alloc] initWithFrame:CGRectMake(subViewTotalNum.width-1,0,0.5,60*SCALE)];
        line1.centerY = subViewTotalNum.height/2;
        line1.backgroundColor = RGBCOLOR(242, 242, 242);
        [subViewTotalNum addSubview:line1];
        
        //累计收入
        UIView *subViewTotalMoney = [[UIView alloc] initWithFrame:CGRectMake(CGRectGetMaxX(subViewTotalNum.frame), 0, viewMain.width/3, viewMain.height)];
        [viewMain addSubview:subViewTotalMoney];
        UILabel *lblTotalMoney = [[UILabel alloc] initCommonWithFrame:CGRectMake(0, 39*SCALE, subViewTotalMoney.width, 22*SCALE) title:@"0" bgColor:[UIColor clearColor] titleColor:RGBTEXT titleFont:22*SCALE textAlignment:NSTextAlignmentCenter isFit:NO];
        [subViewTotalMoney addSubview:lblTotalMoney];
        lblTotalMoney.font = TEXT_SC_TFONT(TEXT_SC_Medium, 22*SCALE);
        self.lblTotalMoney = lblTotalMoney;
        
        UILabel *lblTotalMoneyText = [[UILabel alloc] initCommonWithFrame:CGRectMake(0, lblTotalMoney.bottom+8*SCALE, subViewTotalMoney.width, 12*SCALE) title:@"累计" bgColor:[UIColor clearColor] titleColor:RGBLIGHT_TEXTINFO titleFont:12*SCALE textAlignment:NSTextAlignmentCenter isFit:NO];
        [subViewTotalMoney addSubview:lblTotalMoneyText];
        UIView *line2 = [[UIView alloc] initWithFrame:CGRectMake(subViewTotalMoney.width-1,0,0.5,60*SCALE)];
        line2.centerY = subViewTotalNum.height/2;
        line2.backgroundColor = RGBCOLOR(242, 242, 242);
        [subViewTotalMoney addSubview:line2];
        
        //提现
        UIButton *btnWithdrew = [[UIButton alloc] initSystemWithFrame:CGRectMake(CGRectGetMaxX(subViewTotalMoney.frame)+17*SCALE, 0, viewMain.width/3-34*SCALE, 30*SCALE) btnTitle:@"提现" btnImage:@"" titleColor:RGBLIGHT_TEXTINFO titleFont:14*SCALE];
        btnWithdrew.centerY = subViewTotalNum.centerY;
        btnWithdrew.layer.cornerRadius = 30*SCALE/2;
        btnWithdrew.layer.borderWidth = 0.5;
        btnWithdrew.layer.borderColor = HexRGBAlpha(0xCFCFCF, 1).CGColor;
        [btnWithdrew addTarget:self action:@selector(btnWithDrewAction:) forControlEvents:UIControlEventTouchUpInside];
        [viewMain addSubview:btnWithdrew];
        
        //会员了解
        UIView *viewMemberInfo = [[UIView alloc] initWithFrame:CGRectMake(12, viewMain.bottom+12, kSCREEN_WIDTH-24, 48)];
        viewMemberInfo.backgroundColor = RGBCOLOR(255, 243, 217);
        viewMemberInfo.layer.cornerRadius = 4;
//        [_pageHeadView addSubview:viewMemberInfo];
    }
    return _pageHeadView;
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
