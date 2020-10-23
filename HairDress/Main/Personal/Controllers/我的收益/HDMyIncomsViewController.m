//
//  HDMyOrdersViewController.m
//  HairDress
//
//  Created by 张凯中 on 2019/12/28.
//  Copyright © 2019 zhangkaizhong. All rights reserved.
//

#import "HDMyIncomsViewController.h"

#import "HDMyIncomsSubViewController.h"

#import "HDMyTaskIncomeTableViewCell.h"
#import "HDMyStoreIncomeInfoListCell.h"
#import "ZJSegmentStyle.h"
#import "ZJScrollPageView.h"

@interface HDMyIncomsViewController ()<navViewDelegate,UITableViewDelegate,UITableViewDataSource>

@property (nonatomic,strong) UITableView *mainTableView;
@property (nonatomic,strong) UITableView *mainStoreTableView;
@property (nonatomic,assign) NSInteger page;
@property (nonatomic,assign) NSInteger pageStore;
@property (nonatomic,strong) NSMutableArray *arrData;
@property (nonatomic,strong) NSMutableArray *arrStoreData;

@property (nonatomic,strong) HDBaseNavView *navView;

@property (nonatomic,strong) UIView *headerButtonView;
@property (nonatomic,strong) UIView *viewOrders;// 订单收益
@property (nonatomic,strong) UIView *viewTask;//任务收益
@property (nonatomic,strong) UIView *viewStore;//门店收益

@property (nonatomic,weak) UIButton *buttonOrders;
@property (nonatomic,weak) UIButton *buttonTask;
@property (nonatomic,weak) UIButton *buttonStore;

@property (nonatomic,copy) NSString *storePost;
@property (nonatomic,assign) BOOL isStore;

@end

@implementation HDMyIncomsViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.storePost = [HDUserDefaultMethods getData:@"storePost"];
    
    self.view.backgroundColor = RGBBG;
    [self.view addSubview:self.navView];
    [self.view addSubview:self.headerButtonView];
    [self.view addSubview:self.viewOrders];
}

#pragma mark -- delegate / action

- (void)navBackClicked{
    [self.navigationController popViewControllerAnimated:YES];
}

// 订单收益
-(void)buttonOrdersAction:(UIButton *)sender{
    self.isStore = NO;
    
    [sender setTitleColor:RGBMAIN forState:UIControlStateNormal];
    sender.backgroundColor = [UIColor whiteColor];
    
    [self.buttonTask setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    self.buttonTask.backgroundColor = RGBMAIN;
    
    [self.buttonStore setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    self.buttonStore.backgroundColor = RGBMAIN;
    
    _viewOrders.hidden = NO;
    _viewTask.hidden = YES;
    _viewStore.hidden = YES;
}

// 任务收益
-(void)buttonTaskAction:(UIButton *)sender{
    self.isStore = NO;
    
    [sender setTitleColor:RGBMAIN forState:UIControlStateNormal];
    sender.backgroundColor = [UIColor whiteColor];
    
    [self.buttonOrders setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    self.buttonOrders.backgroundColor = RGBMAIN;
    
    [self.buttonStore setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    self.buttonStore.backgroundColor = RGBMAIN;
    
    _viewOrders.hidden = YES;
    _viewStore.hidden = YES;
    [self.view addSubview:self.viewTask];
    _viewTask.hidden = NO;
    
    if (self.arrData.count == 0) {
        [self requestUserMoneyDetailList:NO];
    }
}

//门店收益
-(void)buttonStoreAction:(UIButton *)sender{
    self.isStore = YES;
    
    [sender setTitleColor:RGBMAIN forState:UIControlStateNormal];
    sender.backgroundColor = [UIColor whiteColor];
    
    [self.buttonOrders setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    self.buttonOrders.backgroundColor = RGBMAIN;
    
    [self.buttonTask setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    self.buttonTask.backgroundColor = RGBMAIN;
    
    _viewOrders.hidden = YES;
    _viewTask.hidden = YES;
    [self.view addSubview:self.viewStore];
    _viewStore.hidden = NO;
    
    if (self.arrStoreData.count == 0) {
        [self requestStoreIncomListData:NO];
    }
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
        
        // 订单收益
        UIButton *buttonOrders = [[UIButton alloc] initSystemWithFrame:CGRectMake(0, 0, viewBtns.width/2, 32) btnTitle:@"订单收益" btnImage:@"" titleColor:RGBMAIN titleFont:14];
        buttonOrders.backgroundColor = [UIColor whiteColor];
        
        CGFloat corner = 16;
        CAShapeLayer *shapeLayer = [CAShapeLayer layer];
        shapeLayer.path = [UIBezierPath bezierPathWithRoundedRect:buttonOrders.bounds byRoundingCorners:UIRectCornerTopLeft | UIRectCornerBottomLeft cornerRadii:CGSizeMake(corner, corner)].CGPath;
        buttonOrders.layer.mask = shapeLayer;
        
        [viewBtns addSubview:buttonOrders];
        self.buttonOrders = buttonOrders;
        
        [buttonOrders addTarget:self action:@selector(buttonOrdersAction:) forControlEvents:UIControlEventTouchUpInside];
        
        // 门店收益
        UIButton *buttonStore = [[UIButton alloc] initSystemWithFrame:CGRectMake(CGRectGetMaxX(self.buttonOrders.frame), 0, viewBtns.width/3, 32) btnTitle:@"门店收益" btnImage:@"" titleColor:[UIColor whiteColor] titleFont:14];
        buttonStore.backgroundColor = RGBMAIN;
        
        UIView *line = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 1, buttonStore.height)];
        line.backgroundColor = [UIColor whiteColor];
        [buttonStore addSubview:line];
        
        [viewBtns addSubview:buttonStore];
        self.buttonStore = buttonStore;
        
        [buttonStore addTarget:self action:@selector(buttonStoreAction:) forControlEvents:UIControlEventTouchUpInside];
        
        //任务收益
        UIButton *buttonTask = [[UIButton alloc] initSystemWithFrame:CGRectMake(CGRectGetMaxX(buttonOrders.frame), 0, viewBtns.width/2, 32) btnTitle:@"其他收益" btnImage:@"" titleColor:[UIColor whiteColor] titleFont:14];
        buttonTask.backgroundColor = RGBMAIN;
        
        buttonTask.layer.borderWidth = 1;
        buttonTask.layer.borderColor = [UIColor whiteColor].CGColor;
        
        [viewBtns addSubview:buttonTask];
        self.buttonTask = buttonTask;
        
        [buttonTask addTarget:self action:@selector(buttonTaskAction:) forControlEvents:UIControlEventTouchUpInside];
        
        if ([self.storePost isEqualToString:@"B"]) {
            self.buttonStore.hidden = NO;
            self.buttonOrders.width = viewBtns.width/3;
            self.buttonStore.width = viewBtns.width/3;
            self.buttonTask.width = viewBtns.width/3;
            self.buttonStore.x = CGRectGetMaxX(self.buttonOrders.frame);
            self.buttonTask.x = CGRectGetMaxX(self.buttonStore.frame);
        }else{
            self.buttonStore.hidden = YES;
            self.buttonOrders.width = viewBtns.width/2;
            self.buttonTask.width = viewBtns.width/2;
            self.buttonTask.x = CGRectGetMaxX(self.buttonOrders.frame);
        }
        
        CGFloat corner1 = 16;
        CAShapeLayer *shapeLayer1 = [CAShapeLayer layer];
        shapeLayer1.path = [UIBezierPath bezierPathWithRoundedRect:self.buttonTask.bounds byRoundingCorners:UIRectCornerTopRight | UIRectCornerBottomRight cornerRadii:CGSizeMake(corner1, corner1)].CGPath;
        self.buttonTask.layer.mask = shapeLayer1;
    }
    return _headerButtonView;
}

// 商品订单
-(UIView *)viewOrders{
    if (!_viewOrders) {
        _viewOrders = [[UIView alloc] initWithFrame:CGRectMake(0, _headerButtonView.bottom, kSCREEN_WIDTH, kSCREEN_HEIGHT-NAVHIGHT-_headerButtonView.height)];
        _viewOrders.hidden = NO;
        
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
        ZJScrollPageView *scrollPageView = [[ZJScrollPageView alloc] initWithFrame:CGRectMake(0, 0, kSCREEN_WIDTH, _viewOrders.height) segmentStyle:style childVcs:childVcs parentViewController:self];
        
        [_viewOrders addSubview:scrollPageView];
    }
    return _viewOrders;
}

// 任务收益单
-(UIView *)viewTask{
    if (!_viewTask) {
        _viewTask = [[UIView alloc] initWithFrame:CGRectMake(0, _headerButtonView.bottom, kSCREEN_WIDTH, kSCREEN_HEIGHT-NAVHIGHT-_headerButtonView.height)];
        _viewTask.hidden = NO;
        
        self.page = 1;
        self.arrData = [NSMutableArray new];
        [_viewTask addSubview:self.mainTableView];
        
        [self setupRefresh];
    }
    return _viewTask;
}

//门店收益
-(UIView *)viewStore{
    if (!_viewStore) {
        _viewStore = [[UIView alloc] initWithFrame:CGRectMake(0, _headerButtonView.bottom, kSCREEN_WIDTH, kSCREEN_HEIGHT-NAVHIGHT-_headerButtonView.height)];
        _viewStore.hidden = NO;
        
        self.pageStore = 1;
        self.arrStoreData = [NSMutableArray new];
        [_viewStore addSubview:self.mainStoreTableView];
        
        [self setupStoreRefresh];
    }
    return _viewStore;
}

// 添加商品订单子控制器
- (NSArray *)setupShopChildVcAndTitle {
    HDMyIncomsSubViewController *vc1 = [[HDMyIncomsSubViewController alloc] init];
    vc1.orderSource = @"cpsOrder";
    vc1.settleStatus = @"";
    vc1.title = @"全部";

    HDMyIncomsSubViewController *vc2 = [[HDMyIncomsSubViewController alloc] init];
    vc2.orderSource = @"cpsOrder";
    vc2.settleStatus = @"no_handle";
    vc2.title = @"未结算";

    HDMyIncomsSubViewController *vc3 = [[HDMyIncomsSubViewController alloc] init];
    vc3.orderSource = @"cpsOrder";
    vc3.settleStatus = @"finish";
    vc3.title = @"已结算";

    HDMyIncomsSubViewController *vc4 = [[HDMyIncomsSubViewController alloc] init];
    vc4.orderSource = @"cpsOrder";
    vc4.settleStatus = @"cancel";
    vc4.title = @"已失效";

    NSArray *childVcs = [NSArray arrayWithObjects:vc1, vc2, vc3,vc4,nil];
    return childVcs;
}

#pragma mark - 添加刷新控件
-(void)setupRefresh{
    self.mainTableView.mj_header = [MJRefreshNormalHeader headerWithRefreshingTarget:self refreshingAction:@selector(loadNewData)];
    self.mainTableView.mj_footer = [MJRefreshBackNormalFooter footerWithRefreshingTarget:self refreshingAction:@selector(loadMoreData)];
}

//下拉刷新数据
-(void)loadNewData{
    [self.mainTableView.mj_footer endRefreshing];
    self.page = 1;
    [self requestUserMoneyDetailList:NO];
}

//上提加载更多
-(void)loadMoreData{
    [self.mainTableView.mj_header endRefreshing];
    self.page ++;
    [self requestUserMoneyDetailList:YES];
}

#pragma mark -- 门店收益刷新
-(void)setupStoreRefresh{
    self.mainStoreTableView.mj_header = [MJRefreshNormalHeader headerWithRefreshingTarget:self refreshingAction:@selector(loadStoreNewData)];
    self.mainStoreTableView.mj_footer = [MJRefreshBackNormalFooter footerWithRefreshingTarget:self refreshingAction:@selector(loadStoreMoreData)];
}

//下拉刷新数据
-(void)loadStoreNewData{
    [self.mainStoreTableView.mj_footer endRefreshing];
    self.pageStore = 1;
    [self requestStoreIncomListData:NO];
}

//上提加载更多
-(void)loadStoreMoreData{
    [self.mainStoreTableView.mj_header endRefreshing];
    self.pageStore ++;
    [self requestStoreIncomListData:YES];
}

#pragma mark -- 数据请求
//任务收益
-(void)requestUserMoneyDetailList:(BOOL)more{
    NSDictionary *params = @{
        @"profitOrderSource":@"task",
        @"settleStatus":@"",
        @"page":@{
                @"pageIndex":@(self.page),
                @"pageSize":@(20)
        },
        @"userId":[HDUserDefaultMethods getData:@"userId"]
    };
    WeakSelf;
    [MHNetworkManager postReqeustWithURL:URL_UserProfitList params:params successBlock:^(NSDictionary *returnData) {
        DTLog(@"%@",returnData);
        
        if ([returnData[@"respCode"] integerValue] == 200) {
            if (more) {
                [weakSelf.mainTableView.mj_footer endRefreshing];
            }else{
                [self.arrData removeAllObjects];
                [weakSelf.mainTableView.mj_header endRefreshing];
            }
            NSArray *arr = [HDMyIncomProfitsModel mj_objectArrayWithKeyValuesArray:returnData[@"data"]];
            if (more && arr.count == 0) {
                weakSelf.page --;
            }
            [self.arrData addObjectsFromArray:arr];
            [self.mainTableView reloadData];
            
            if (self.arrData.count == 0) {
                [self.mainTableView addSubview:self.viewEmpty];
                self.viewEmpty.hidden = NO;
            }else{
                self.viewEmpty.hidden = YES;
            }
            
            if (arr.count == 0) {
                [self.mainTableView.mj_footer endRefreshingWithNoMoreData];
            }
        }else{
            if (more) {
                weakSelf.page --;
                [weakSelf.mainTableView.mj_footer endRefreshing];
            }else{
                [weakSelf.mainTableView.mj_header endRefreshing];
            }
        }
    } failureBlock:^(NSError *error) {
        if (more) {
            weakSelf.page --;
            [weakSelf.mainTableView.mj_footer endRefreshing];
        }else{
            [weakSelf.mainTableView.mj_header endRefreshing];
        }
    } showHUD:YES];
}

//门店收益
-(void)requestStoreIncomListData:(BOOL)more{
    NSDictionary *params = @{
        @"storeId":[HDUserDefaultMethods getData:@"storeId"],
        @"page":@{
                @"pageIndex":@(self.pageStore),
                @"pageSize":@(20)
        }
    };
    WeakSelf;
    [MHNetworkManager postReqeustWithURL:URL_StoreSettleIncomeList params:params successBlock:^(NSDictionary *returnData) {
        if ([returnData[@"respCode"] integerValue] == 200) {
            if (more) {
                [weakSelf.mainStoreTableView.mj_footer endRefreshing];
            }else{
                [self.arrStoreData removeAllObjects];
                [weakSelf.mainStoreTableView.mj_header endRefreshing];
            }
            NSArray *arr = [HDMyStoreIncomeInfoListModel mj_objectArrayWithKeyValuesArray:returnData[@"data"]];
            if (more && arr.count == 0) {
                weakSelf.pageStore --;
            }
            [self.arrStoreData addObjectsFromArray:arr];
            [self.mainStoreTableView reloadData];
            
            if (self.arrStoreData.count == 0) {
                [self.mainStoreTableView addSubview:self.viewEmpty];
                self.viewEmpty.hidden = NO;
            }else{
                self.viewEmpty.hidden = YES;
            }
            
            if (arr.count == 0) {
                [self.mainStoreTableView.mj_footer endRefreshingWithNoMoreData];
            }
        }else{
            if (more) {
                weakSelf.pageStore--;
                [weakSelf.mainStoreTableView.mj_footer endRefreshing];
            }else{
                [weakSelf.mainStoreTableView.mj_header endRefreshing];
            }
        }
    } failureBlock:^(NSError *error) {
        if (more) {
            weakSelf.pageStore--;
            [weakSelf.mainStoreTableView.mj_footer endRefreshing];
        }else{
            [weakSelf.mainStoreTableView.mj_header endRefreshing];
        }
    } showHUD:YES];
}

#pragma mark -- tableView delegate datasource

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    if (self.isStore) {
        return self.arrStoreData.count;
    }
    return self.arrData.count;
}

-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    if (self.isStore) {
        return 120;
    }
    return 110;
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    if (self.isStore) {
        HDMyStoreIncomeInfoListCell *cell = [tableView dequeueReusableCellWithIdentifier:NSStringFromClass([HDMyStoreIncomeInfoListCell class]) forIndexPath:indexPath];
        cell.model = self.arrStoreData[indexPath.row];
        return cell;
    }
    HDMyTaskIncomeTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:NSStringFromClass([HDMyTaskIncomeTableViewCell class]) forIndexPath:indexPath];
    cell.model = self.arrData[indexPath.row];
    return cell;
}

-(HDBaseNavView *)navView{
    if (!_navView) {
        _navView = [[HDBaseNavView alloc] initWithFrame:CGRectMake(0, 0, kSCREEN_WIDTH, NAVHIGHT) title:@"我的收益" bgColor:RGBMAIN backBtn:YES rightBtn:@"" rightBtnImage:@"" theDelegate:self];
    }
    return _navView;
}

#pragma mark -- 加载控件

-(UITableView *)mainTableView{
    if (!_mainTableView) {
        _mainTableView = [[UITableView alloc] initWithFrame:CGRectMake(0, 8, kSCREEN_WIDTH, kSCREEN_HEIGHT-NAVHIGHT-8-56) style:UITableViewStylePlain];
        _mainTableView.delegate = self;
        _mainTableView.dataSource = self;
        _mainTableView.backgroundColor = [UIColor clearColor];
        _mainTableView.separatorStyle = UITableViewCellSeparatorStyleNone;
        [_mainTableView registerClass:[HDMyTaskIncomeTableViewCell class] forCellReuseIdentifier:NSStringFromClass([HDMyTaskIncomeTableViewCell class])];
    }
    return _mainTableView;
}

-(UITableView *)mainStoreTableView{
    if (!_mainStoreTableView) {
        _mainStoreTableView = [[UITableView alloc] initWithFrame:CGRectMake(0, 8, kSCREEN_WIDTH, kSCREEN_HEIGHT-NAVHIGHT-8-56) style:UITableViewStylePlain];
        _mainStoreTableView.delegate = self;
        _mainStoreTableView.dataSource = self;
        _mainStoreTableView.backgroundColor = [UIColor clearColor];
        _mainStoreTableView.separatorStyle = UITableViewCellSeparatorStyleNone;
        [_mainStoreTableView registerClass:[HDMyStoreIncomeInfoListCell class] forCellReuseIdentifier:NSStringFromClass([HDMyStoreIncomeInfoListCell class])];
    }
    return _mainStoreTableView;
}

@end
