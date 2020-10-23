//
//  HDShopDetailViewController.m
//  HairDress
//
//  Created by 张凯中 on 2019/12/21.
//  Copyright © 2019 zhangkaizhong. All rights reserved.
//

#import "HDShopDetailViewController.h"

#import "CenterTouchTableView.h"

#import "YWPageHeadView.h"

#import "HDShopCutterViewController.h"
#import "HDShopEvaluateViewController.h"
#import "HDShopMsgInfoViewController.h"

#import "UIImageView+LBBlurredImage.h"
#import "ZJSegmentStyle.h"
#import "ZJScrollPageView.h"

#import "HDShopDetailModel.h"

@interface HDShopDetailViewController ()<navViewDelegate,UITableViewDelegate,UITableViewDataSource,UIGestureRecognizerDelegate>

@property (nonatomic,strong) UIView *headerView;

@property (nonatomic,weak) UIButton *btnBack;
@property (nonatomic,weak) UIButton *btnRight;
@property (nonatomic,weak) UILabel *lblTitle;
@property (nonatomic,strong)HDBaseNavView *navView;

@property (nonatomic, strong) ZJScrollPageView *cursorView;
@property (nonatomic, strong) HDShopDetailModel *shopDetailModel;

@property (nonatomic, copy) NSString *isCollect;

@property (nonatomic, strong) CenterTouchTableView *mainTableView;

@property (nonatomic, strong) ZJScrollPageView *segmentView;
@property (nonatomic,strong) YWPageHeadView *pageHeadView;

@property (nonatomic, assign) BOOL canScroll;//mainTableView是否可以滚动
@property (nonatomic, assign) BOOL isBacking;//是否正在pop

//头部总高度
@property (nonatomic, assign) CGFloat offHeight;

@end

@implementation HDShopDetailViewController

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
    
    //这三个高度必须先算出来，建议请求完数据知道高度以后再调用下面代码
    self.offHeight = 20;
    
    [self.view addSubview:self.navView];
    
    [self requestShopDetailData];
//    [self setupRefresh];
}

//#pragma mark - 添加刷新控件
//-(void)setupRefresh{
//    self.mainTableView.mj_header = [MJRefreshNormalHeader headerWithRefreshingTarget:self refreshingAction:@selector(loadNewData)];
//}
//
//-(void)loadNewData{
//    NSLog(@"111");
//    [self.mainTableView.mj_header endRefreshing];
//}

#pragma mark ================== 监听网络变化后重新加载数据 =====================
-(void)getLoadDataBase:(NSNotification *)text{
    [super getLoadDataBase:text];
    if (!self.shopDetailModel) {
        [self requestShopDetailData];
    }
}

#pragma mark - Private Methods
- (void)setupSubViews {
    self.mainTableView.backgroundColor = [UIColor clearColor];
    
    [self.view addSubview:self.mainTableView];
    self.mainTableView.tableHeaderView = self.pageHeadView;
    [self.pageHeadView addSubview:self.headerView];
    self.pageHeadView.parentScrollView = self.mainTableView;
    
    self.pageHeadView.height = self.offHeight;
}

#pragma mark -- 跳转第三方地图导航
-(void)tapAddressAction:(UIGestureRecognizer *)sender{
    [HDToolHelper showMapsWithLat:self.shopDetailModel.latitude longt:self.shopDetailModel.longitude];
}

#pragma mark ================== 获取店铺详情数据 =====================
-(void)requestShopDetailData{
    WeakSelf;
    [MHNetworkManager postReqeustWithURL:URL_GetsStoreDetail params:@{@"storeId":self.shop_id} successBlock:^(NSDictionary *returnData) {
        DTLog(@"%@",returnData);
        if ([returnData[@"respCode"] integerValue] == 200) {
            weakSelf.shopDetailModel = [HDShopDetailModel mj_objectWithKeyValues:returnData[@"data"]];
            
            //创建UI
            [self setupSubViews];
            [self.view bringSubviewToFront:self.navView];
            
            //查询该门店是否已收藏
            [self checkCollectRequest];
            
        }else{
            [SVHUDHelper showInfoWithTimestamp:1 msg:returnData[@"respMsg"]];
        }
    } failureBlock:^(NSError *error) {
        
    } showHUD:YES];
}

//店铺是否收藏
-(void)checkCollectRequest{
    if ([[HDUserDefaultMethods getData:@"userId"] isEqualToString:@""]) {
        return;
    }
    NSDictionary *params = @{
        @"collectId":self.shop_id,
        @"collectType":@"store",
        @"userId":[HDUserDefaultMethods getData:@"userId"]
    };
    [MHNetworkManager postReqeustWithURL:URL_CollectCheckCollect params:params successBlock:^(NSDictionary *returnData) {
        DTLog(@"%@",returnData);
        //是否收藏
        if ([returnData[@"respCode"] integerValue] == 200) {
            if ([returnData[@"data"] isEqualToString:@"F"]) {
                self.isCollect = @"0";
                self.navView.rightImage = @"info_nav_ic_favorite_w";
            }else{
                self.isCollect = @"1";
                self.navView.rightImage = @"info_nav_ic_favorite_selected";
            }
        }else{
            self.isCollect = @"0";
            self.navView.rightImage = @"info_nav_ic_favorite_w";
        }
        
    } failureBlock:^(NSError *error) {
            
    } showHUD:NO];
}

//发送店铺收藏请求
-(void)collectStoreRequest{
    NSDictionary *params = @{
        @"collectId":self.shop_id,
        @"collectType":@"store",
        @"userId":[HDUserDefaultMethods getData:@"userId"]
    };
    [MHNetworkManager postReqeustWithURL:URL_CollectStoreOrTony params:params successBlock:^(NSDictionary *returnData) {
        DTLog(@"%@",returnData);
        if ([returnData[@"respCode"] integerValue] == 200) {
            self.isCollect = @"1";
            self.navView.rightImage = @"info_nav_ic_favorite_selected";
            [SVHUDHelper showSuccessDoneMsg:@"收藏成功"];
            if (self.delegate && [self.delegate respondsToSelector:@selector(clickCollectActionRefreshList)]) {
                [self.delegate clickCollectActionRefreshList];
            }
        }else{
            [SVHUDHelper showDarkWarningMsg:returnData[@"respMsg"]];
        }
    } failureBlock:^(NSError *error) {
        
    } showHUD:YES];
}

//取消收藏请求
-(void)cancelCollectStoreRequest{
    NSDictionary *params = @{
        @"ids":@[self.shop_id],
        @"collectType":@"store",
        @"userId":[HDUserDefaultMethods getData:@"userId"]
    };
    [MHNetworkManager postReqeustWithURL:URL_CollectDelCollect params:params successBlock:^(NSDictionary *returnData) {
        DTLog(@"%@",returnData);
        if ([returnData[@"respCode"] integerValue] == 200) {
            self.isCollect = @"0";
            self.navView.rightImage = @"info_nav_ic_favorite_w";
            [SVHUDHelper showSuccessDoneMsg:@"取消收藏"];
            if (self.delegate && [self.delegate respondsToSelector:@selector(clickCollectActionRefreshList)]) {
                [self.delegate clickCollectActionRefreshList];
            }
        }else{
            [SVHUDHelper showDarkWarningMsg:returnData[@"respMsg"]];
        }
    } failureBlock:^(NSError *error) {
        
    } showHUD:YES];
}

#pragma mark -- delegate

-(void)navBackClicked{
    [self.navigationController popViewControllerAnimated:YES];
}

//收藏
-(void)navRightClicked{
    if ([self.isCollect isEqualToString:@"0"]) {
        //收藏
        [self collectStoreRequest];
    }else{
        //取消收藏
        [self cancelCollectStoreRequest];
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
    CGFloat criticalPointOffsetY = [self.mainTableView rectForSection:0].origin.y-NAVHIGHT;
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
        _navView.backgroundColor = [UIColor clearColor];
        self.lblTitle.textColor = [UIColor whiteColor];
        [self.btnBack setImage:[UIImage imageNamed:@"info_nav_ic_back_w"] forState:UIControlStateNormal];
        if ([self.isCollect isEqualToString:@"0"]) {
            self.navView.rightImage = @"info_nav_ic_favorite_w";
        }
    }else{//移动过程
        if (currentOffsetY > (self.offHeight-NAVHIGHT)) {
            _navView.backgroundColor = [UIColor whiteColor];
            self.lblTitle.textColor = RGBTEXT;
            [self.btnBack setImage:[UIImage imageNamed:@"common_ic_arrow_back"] forState:UIControlStateNormal];
            if ([self.isCollect isEqualToString:@"0"]) {
                self.navView.rightImage = @"info_nav_ic_favorite";
            }
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
    return kSCREEN_HEIGHT - NAVHIGHT;
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
        // 颜色渐变
        style.gradualChangeTitleColor = YES;
        // 设置子控制器 --- 注意子控制器需要设置title, 将用于对应的tag显示title
        NSArray *childVcs = [NSArray arrayWithArray:[self setupChildVcAndTitle]];
        // 初始化
        ZJScrollPageView *scrollPageView = [[ZJScrollPageView alloc] initWithFrame:CGRectMake(0,0, kSCREEN_WIDTH, kSCREEN_HEIGHT - NAVHIGHT) segmentStyle:style childVcs:childVcs parentViewController:self];
        _segmentView = scrollPageView;
    }
    return _segmentView;
}

// 创建自控制器
- (NSArray *)setupChildVcAndTitle {
    //发型师列表
    HDShopCutterViewController *cutVc = [HDShopCutterViewController new];
    cutVc.title = @"发型师";
    cutVc.shop_id = _shopDetailModel.storeId;
    
    //服务评价
    HDShopEvaluateViewController *shoEvaVC = [HDShopEvaluateViewController new];
    shoEvaVC.title = @"服务评价";
    shoEvaVC.shop_id = _shopDetailModel.storeId;
    
    //门店信息
    HDShopMsgInfoViewController *infoVC = [HDShopMsgInfoViewController new];
    infoVC.title = @"门店信息";
    infoVC.shopDetailModel = self.shopDetailModel;

    NSArray *childVcs = [NSArray arrayWithObjects:cutVc, shoEvaVC, infoVC,nil];
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


#pragma mark -- 加载控件

-(HDBaseNavView *)navView{
    if (!_navView) {
        _navView = [[HDBaseNavView alloc] initWithFrame:CGRectMake(0, 0, kSCREEN_WIDTH, NAVHIGHT) title:@"门店详情" bgColor:[UIColor clearColor] backBtn:YES rightBtn:@"" rightBtnImage:@"info_nav_ic_favorite_w" theDelegate:self];
        self.btnBack = (UIButton *)[_navView viewWithTag:5000];
        self.lblTitle = (UILabel *)[_navView viewWithTag:6000];
        self.btnRight = (UIButton *)[_navView viewWithTag:10000];
        self.lblTitle.textColor = [UIColor whiteColor];
        [self.btnBack setImage:[UIImage imageNamed:@"info_nav_ic_back_w"] forState:UIControlStateNormal];
    }
    return _navView;
}

-(UIView *)headerView{
    if (!_headerView) {
        _headerView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, kSCREEN_WIDTH, 100)];
        
        UIView *line = [[UIView alloc] initWithFrame:CGRectMake(0, NAVHIGHT, kSCREEN_WIDTH, 1)];
        line.backgroundColor = [[UIColor whiteColor] colorWithAlphaComponent:0.24];
        [_headerView addSubview:line];
        
        // 店铺名称
        UILabel *lblShopName = [[UILabel alloc] initCommonWithFrame:CGRectMake(16, NAVHIGHT+8, kSCREEN_WIDTH-32, 40)
                                                              title:@""
                                                            bgColor:[UIColor clearColor]
                                                         titleColor:[UIColor whiteColor]
                                                          titleFont:16
                                                      textAlignment:NSTextAlignmentLeft
                                                              isFit:NO];
        lblShopName.text = _shopDetailModel.storeName;
        lblShopName.font = TEXT_SC_TFONT(TEXT_SC_Medium, 16);
        lblShopName.numberOfLines = 0;
        [lblShopName sizeToFit];
        [_headerView addSubview:lblShopName];
        
        // 营业时间
        UILabel *lblTime = [[UILabel alloc] initCommonWithFrame:CGRectMake(16, lblShopName.bottom+8, kSCREEN_WIDTH-32, 12) title:@"" bgColor:[UIColor clearColor] titleColor:RGBAlpha(241, 241, 241, 1) titleFont:12 textAlignment:NSTextAlignmentLeft isFit:NO];
        lblTime.text = [NSString stringWithFormat:@"营业时间：%@-%@",_shopDetailModel.startTime,_shopDetailModel.endTime];
        [_headerView addSubview:lblTime];
        
        // 地址view
        UIView *viewAddress = [[UIView alloc] initWithFrame:CGRectMake(0, lblTime.bottom+20, kSCREEN_WIDTH, 42)];
        [_headerView addSubview:viewAddress];
        
        UITapGestureRecognizer *tapAddress = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapAddressAction:)];
        viewAddress.userInteractionEnabled = YES;
        [viewAddress addGestureRecognizer:tapAddress];
        
        UIImageView *imageAddress = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"info_nav_ic_local_w"]];
        imageAddress.x = kSCREEN_WIDTH - 16 - imageAddress.width;
        [viewAddress addSubview:imageAddress];
        
        UILabel *lblAddress = [[UILabel alloc] initCommonWithFrame:CGRectMake(16, 0, kSCREEN_WIDTH-32 - imageAddress.width - 16, 14) title:@"" bgColor:[UIColor clearColor] titleColor:[UIColor whiteColor] titleFont:14 textAlignment:NSTextAlignmentLeft isFit:NO];
        lblAddress.text = _shopDetailModel.storeAddress;
        lblAddress.numberOfLines = 0;
        [lblAddress sizeToFit];
        [viewAddress addSubview:lblAddress];
        if (lblAddress.height <= 14) {
            lblAddress.height = 14;
        }
        viewAddress.height = lblAddress.bottom+30;
        imageAddress.centerY = viewAddress.height/2;
        lblAddress.centerY = imageAddress.centerY;
        
        _headerView.height = viewAddress.bottom+36;
        self.offHeight = _headerView.height;
        
        //添加背景图片
        UIImageView *bgImgView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, kSCREEN_WIDTH, self.offHeight)];
        bgImgView.contentMode = UIViewContentModeScaleAspectFill;
        bgImgView.layer.masksToBounds = YES;
        [bgImgView setImageToBlur:[HDToolHelper getImageFromURL:_shopDetailModel.logoImg] blurRadius:20 completionBlock:nil];
        bgImgView.userInteractionEnabled = YES;
        [_headerView insertSubview:bgImgView atIndex:0];
    }
    return _headerView;
}

-(YWPageHeadView *)pageHeadView{
    if (!_pageHeadView) {
        _pageHeadView = [[YWPageHeadView alloc]init];
        _pageHeadView.frame = CGRectMake(0, 0,kSCREEN_WIDTH, self.offHeight);
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

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];

}

//接收滚动通知
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

- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

@end
