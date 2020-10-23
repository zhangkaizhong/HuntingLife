//
//  HDTaoMallViewController.m
//  HairDress
//
//  Created by Apple on 2019/12/18.
//  Copyright © 2019 zhangkaizhong. All rights reserved.
//

#import "HDTaoMallViewController.h"
#import "HDTaoMallSubHomeViewController.h"
#import "HDTaoMallSubWearsViewController.h"
#import "HDTaoMallSubCommonViewController.h"
#import "HDTaoSearchGoodsViewController.h"

#import <QYSDK/QYSDK.h>
#import "ZJSegmentStyle.h"
#import "ZJScrollPageView.h"

@interface HDTaoMallViewController ()<navViewDelegate,ZJScrollPageViewDelegate,ZJScrollSegmentViewDelegate>

@property (nonatomic,strong) HDBaseNavView *navView;
@property (nonatomic,strong) UIScrollView *mainScrollView;
@property (nonatomic,strong) ZJSegmentStyle *style;
@property (nonatomic,strong) ZJScrollPageView *scrollPageView;

@property (nonatomic,weak) UIImageView *viewImageBack;

@property (nonatomic,strong) NSMutableArray *arrBarList;

@end

@implementation HDTaoMallViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.arrBarList = [NSMutableArray new];

    UIImageView *viewImageBack = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, kSCREEN_WIDTH, 181*SCALE)];
    self.viewImageBack = viewImageBack;
    viewImageBack.image = [UIImage imageNamed:@"featured_bg"];
    [self.view addSubview:viewImageBack];
    
    [self.view addSubview:self.navView];
    [self.view addSubview:self.mainScrollView];
    
    [self getBarList];
    
    [self setupRefresh];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(didScrollViewChangeImageHeight:) name:@"changeHeightNotice" object:nil];
}

-(UIScrollView *)mainScrollView{
    if (!_mainScrollView) {
        _mainScrollView = [[UIScrollView alloc] initWithFrame:CGRectMake(0, NAVHIGHT, kSCREEN_WIDTH, kSCREEN_HEIGHT-KTarbarHeight-NAVHIGHT)];
        _mainScrollView.backgroundColor = [UIColor clearColor];
    }
    return _mainScrollView;
}

#pragma mark - 添加刷新控件
-(void)setupRefresh{
    MJRefreshNormalHeader *header = [MJRefreshNormalHeader headerWithRefreshingTarget:self refreshingAction:@selector(getBarList)];
    self.mainScrollView.mj_header = header;
    header.lastUpdatedTimeLabel.hidden = YES;
    header.stateLabel.textColor = [UIColor whiteColor];
}

-(void)didScrollViewChangeImageHeight:(NSNotification *)notice{
    CGFloat offset =[ notice.userInfo[@"offset"] floatValue];
    if (offset >= 0) {
        self.viewImageBack.height = 181*SCALE;
    }else{
        CGFloat h = 181*SCALE-NAVHIGHT-48;
        if (-offset<h) {
            self.viewImageBack.height = 181*SCALE;
        }else{
            self.viewImageBack.height = NAVHIGHT+48-offset;
        }
    }
}

#pragma mark -- 创建视图
-(void)setupBarListView{
    //必要的设置, 如果没有设置可能导致内容显示不正常
    self.automaticallyAdjustsScrollViewInsets = NO;
    self.style = [[ZJSegmentStyle alloc] init];
    //显示滚动条
    self.style.showLine = YES;
    self.style.scrollTitle = YES;
    self.style.selectedTitleColor = [UIColor whiteColor];
    self.style.titleFont = TEXT_SC_TFONT(TEXT_SC_Regular, 14*SCALE);
    self.style.titleSelectedFont = TEXT_SC_TFONT(TEXT_SC_Medium, 14*SCALE);
    self.style.scrollLineColor = [UIColor whiteColor];
    self.style.normalTitleColor = [UIColor whiteColor];
    self.style.gradualChangeTitleColor = NO;
    // 设置子控制器 --- 注意子控制器需要设置title, 将用于对应的tag显示title
    NSArray *childVcs = [NSArray arrayWithArray:[self setupChildVcAndTitle]];
    // 初始化
    self.scrollPageView = [[ZJScrollPageView alloc] initWithFrame:CGRectMake(0, NAVHIGHT, kSCREEN_WIDTH, kSCREEN_HEIGHT-NAVHIGHT-KTarbarHeight) segmentStyle:self.style childVcs:childVcs parentViewController:self];
    self.scrollPageView.zjdelegate = self;
    
    self.scrollPageView.segmentView.backgroundColor = [UIColor clearColor];
    self.scrollPageView.backgroundColor = [UIColor clearColor];
    self.scrollPageView.contentView.backgroundColor = [UIColor clearColor];
    self.scrollPageView.contentView.collectionView.backgroundColor = [UIColor clearColor];
    
    self.scrollPageView.segmentView.segDelegate = self;
    [self.view addSubview:self.scrollPageView];
}

#pragma mark ================== 监听网络变化后重新加载数据 =====================
-(void)getLoadDataBase:(NSNotification *)text{
    [super getLoadDataBase:text];
    if ([text.userInfo[@"netType"] integerValue] != 0) {
        if (self.arrBarList.count == 0) {
            [self getBarList];
        }
    }
}

#pragma mark -- 获取首页barList
-(void)getBarList{
    WeakSelf;
    [MHNetworkManager postReqeustWithURL:URL_TaoBarList params:@{} successBlock:^(NSDictionary *returnData) {
        DTLog(@"%@",returnData);
        [weakSelf.mainScrollView.mj_header endRefreshing];
        if ([returnData[@"respCode"] integerValue] == 200) {
            [self.arrBarList addObjectsFromArray:returnData[@"data"]];
            if (self.arrBarList.count > 0) {
                weakSelf.mainScrollView.hidden = YES;
                [self setupBarListView];
            }else{
                weakSelf.mainScrollView.hidden = NO;
            }
        }else{
            weakSelf.mainScrollView.hidden = NO;
        }
    } failureBlock:^(NSError *error) {
        [weakSelf.mainScrollView.mj_header endRefreshing];
    } showHUD:YES];
}

//设置子控制器
- (NSArray *)setupChildVcAndTitle {
    NSMutableArray *childVcs = [NSMutableArray new];
    for (int i = 0; i<self.arrBarList.count; i++) {
        NSDictionary *indexDic = self.arrBarList[i];
        if ([indexDic[@"positionCode"] isEqualToString:@"cpsIndex"]) {
            HDTaoMallSubHomeViewController *homeVC = [[HDTaoMallSubHomeViewController alloc] init];
            homeVC.title = self.arrBarList[i][@"title"];
//            homeVC.delegate = self;
            homeVC.index_id = indexDic[@"id"];
            homeVC.position_code = indexDic[@"positionCode"];
            [childVcs addObject:homeVC];
        }else{
            HDTaoMallSubWearsViewController *wearVC = [HDTaoMallSubWearsViewController new];
            wearVC.title = self.arrBarList[i][@"title"];
            wearVC.cid = indexDic[@"cid"];
            wearVC.index_id = indexDic[@"id"];
            wearVC.position_code = indexDic[@"positionCode"];
            [childVcs addObject:wearVC];
        }
    }
    return childVcs;
}

//滚动视图滚动位置
-(void)ZJSrollViewDidScrollToIndex:(NSInteger)currentIndex{
    if (currentIndex == 0) {
//        _navView.backgroundColor = RGBCOLOR(255, 168, 1);
//        self.scrollPageView.segmentView.backgroundColor = RGBCOLOR(255, 168, 1);
//        self.viewBack.backgroundColor = RGBCOLOR(255, 168, 1);
    }else{
//        _navView.backgroundColor = RGBMAIN;
//        self.scrollPageView.segmentView.backgroundColor = RGBMAIN;
//        self.viewBack.backgroundColor = [UIColor clearColor];
    }
}

//按钮点击位置
-(void)clickBtnLabelAtIndex:(NSInteger)currentIndex{
    if (currentIndex == 0) {
//        _navView.backgroundColor = RGBCOLOR(255, 168, 1);
//        self.scrollPageView.segmentView.backgroundColor = RGBCOLOR(255, 168, 1);
//        self.viewBack.backgroundColor = RGBCOLOR(255, 168, 1);
    }else{
//        _navView.backgroundColor = RGBMAIN;
//        self.scrollPageView.segmentView.backgroundColor = RGBMAIN;
//        self.viewBack.backgroundColor = [UIColor clearColor];
    }
}

#pragma mark -- delegate action
-(void)navRightClicked{
    if ([[HDUserDefaultMethods getData:@"userId"] isEqualToString:@""]) {
        [HDToolHelper preToLoginView];
        return;
    }
    [IQKeyboardManager sharedManager].enable =NO;
    
    QYCustomUIConfig *UIConfig = [[QYSDK sharedSDK] customUIConfig];
    UIConfig.serviceHeadImage = [UIImage imageNamed:@"appicon_img"];
    UIConfig.customerHeadImage = [UIImage imageNamed:@"appicon_img"];
    QYSessionViewController *sessionViewController = [[QYSDK sharedSDK] sessionViewController];
    sessionViewController.sessionTitle = @"联系客服";
    HDBaseNavViewController *nav = [[HDBaseNavViewController alloc] initWithRootViewController:sessionViewController];
    nav.modalPresentationStyle = 0;
    UIButton *btnBack = [[UIButton alloc] initSystemWithFrame:CGRectMake(0, 0, 10, 10) btnTitle:@"" btnImage:@"common_ic_arrow_back" titleColor:[UIColor clearColor] titleFont:0];
    [btnBack addTarget:self action:@selector(onBack:) forControlEvents:UIControlEventTouchUpInside];
    sessionViewController.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView:btnBack];
    [self presentViewController:nav animated:YES completion:nil];
}

- (void)onBack:(id)sender {
    [IQKeyboardManager sharedManager].enable =YES;
    [self dismissViewControllerAnimated:YES completion:nil];
}

//搜索商品
-(void)searchGoodsAction:(UIGestureRecognizer *)sender{
    HDTaoSearchGoodsViewController *searchVC = [HDTaoSearchGoodsViewController new];
    [self.navigationController pushViewController:searchVC animated:YES];
}

#pragma mark -- 加载控件

-(HDBaseNavView *)navView{
    if (!_navView) {
        _navView = [[HDBaseNavView alloc] initSearchBarWithButtonsFrame:CGRectMake(0, 0, kSCREEN_WIDTH, NAVHIGHT) bgColor:[UIColor clearColor] textColor:RGBTEXT searchViewColor:[UIColor whiteColor] btnTitle:@"客服" placeHolder:@"搜索商品名或粘贴宝贝标题" theDelegate:self];
        _navView.txtSearch.userInteractionEnabled = NO;
        
        UIView *viewBack = [[UIView alloc] initWithFrame:CGRectMake(40, NAVHIGHT-8-28, kSCREEN_WIDTH-8-40-34-16, 28)];
        viewBack.backgroundColor = [UIColor clearColor];
        [_navView addSubview:viewBack];
        viewBack.userInteractionEnabled = YES;
        UITapGestureRecognizer *tapSearch = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(searchGoodsAction:)];
        [viewBack addGestureRecognizer:tapSearch];
    }
    return _navView;
}

-(void)dealloc{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

@end
