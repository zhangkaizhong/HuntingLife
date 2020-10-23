//
//  HDTaoMallFloorDetailViewController.m
//  HairDress
//
//  Created by Apple on 2020/2/10.
//  Copyright © 2020 zhangkaizhong. All rights reserved.
//

#import "HDTaoMallFloorDetailViewController.h"

#import "HDTaoMallFloorDetailTableViewCell.h"
#import "HDTaoGoodsDetailViewController.h"

@interface HDTaoMallFloorDetailViewController ()<navViewDelegate,UITableViewDelegate,UITableViewDataSource>

@property (nonatomic,strong) HDBaseNavView *navView;
@property (nonatomic,strong) UIScrollView *timeScrollView;
@property (nonatomic,strong) UITableView *mainTableView;

@property (nonatomic,strong) NSMutableArray *arrGoodsList;
@property (nonatomic,strong) NSArray *arrTimes;
@property (nonatomic,assign) CGFloat offsetX;
@property (nonatomic,assign) NSInteger page;

@property (nonatomic,copy) NSString *actId;
@property (nonatomic,copy) NSDictionary *actTimeDic;

@end

@implementation HDTaoMallFloorDetailViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = RGBBG;
    self.page = 1;
    self.arrGoodsList = [NSMutableArray new];
    
    [self.view addSubview:self.navView];
    [self setupUI];
    [self.view addSubview:self.mainTableView];
    [self setupScrollTimes];
    
    [self setupRefresh];
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
    [self getFloorGoodsList:NO];
}

//上提加载更多
-(void)loadMoreData{
    [self.mainTableView.mj_header endRefreshing];
    self.page ++;
    [self getFloorGoodsList:YES];
}

#pragma mark ================== delegate action =====================
-(void)navBackClicked{
    [self.navigationController popViewControllerAnimated:YES];
}

//选择时间段刷新列表
-(void)tapTimeViewAction:(UIGestureRecognizer *)sender{
    NSInteger viewTag = sender.view.tag;
    for (int i = 0; i<self.arrTimes.count; i++) {
        UIView *viewSub = (UIView *)[_timeScrollView viewWithTag:100+i];
        UILabel *lblBegainTime = (UILabel *)[viewSub viewWithTag:1000];
        UILabel *lblIsShowText = (UILabel *)[viewSub viewWithTag:2000];
        viewSub.backgroundColor = [UIColor clearColor];
        lblBegainTime.textColor = [UIColor whiteColor];
        lblIsShowText.textColor = [UIColor whiteColor];
    }
    
    UIView *viewTime = (UIView *)[_timeScrollView viewWithTag:viewTag];
    UILabel *lblBegainTime = (UILabel *)[viewTime viewWithTag:1000];
    UILabel *lblIsShowText = (UILabel *)[viewTime viewWithTag:2000];
    viewTime.backgroundColor = [UIColor whiteColor];
    lblBegainTime.textColor = RGBMAIN;
    lblIsShowText.textColor = RGBMAIN;
    
    self.offsetX = CGRectGetMaxX(viewTime.frame)+12-kSCREEN_WIDTH;
    if (self.offsetX<0) {
        self.offsetX = 0;
    }
    if (_timeScrollView.contentSize.width>=kSCREEN_WIDTH) {
        CGFloat maxRight = _timeScrollView.contentSize.width-kSCREEN_WIDTH;
        if (self.offsetX > maxRight) {
            self.offsetX = maxRight;
        }
    }
    [_timeScrollView setContentOffset:CGPointMake(self.offsetX, 0) animated:YES];
    
    NSDictionary *dic = self.arrTimes[viewTag-100];
    self.actId = dic[@"id"];
    self.actTimeDic = dic;
    [self getFloorGoodsList:NO];
}

#pragma mark ================== 数据请求 =====================

//获取对应时间段商品列表
-(void)getFloorGoodsList:(BOOL)more{
    if (!self.actId) {
        if (more) {
            [self.mainTableView.mj_footer endRefreshing];
        }else{
            [self.mainTableView.mj_header endRefreshing];
        }
        return;
    }
    NSDictionary *params = @{
        @"activityId":self.actId,
        @"floorId":self.dicFloor[@"id"],
        @"page":@{@"pageIndex":@(self.page),@"pageSize":@(20)}
    };
    [MHNetworkManager postReqeustWithURL:URL_TaoFloorActivityGoodsList params:params successBlock:^(NSDictionary *returnData) {
        returnData = [HDToolHelper nullDicToDic:returnData];
        if ([returnData[@"respCode"] integerValue] == 200) {
            if (more) {
                [self.mainTableView.mj_footer endRefreshing];
            }else{
                [self.arrGoodsList removeAllObjects];
                [self.mainTableView.mj_header endRefreshing];
            }
            NSArray *arr = [HDTaoGoodsModel mj_objectArrayWithKeyValuesArray:returnData[@"data"]];
            if (more && arr.count == 0) {
                self.page --;
            }
            [self.arrGoodsList addObjectsFromArray:arr];
            [self.mainTableView reloadData];
            if (arr.count == 0) {
                [self.mainTableView.mj_footer endRefreshingWithNoMoreData];
            }
            if (self.arrGoodsList.count == 0) {
                [self.mainTableView addSubview:self.viewEmpty];
                self.viewEmpty.hidden = NO;
            }else{
                self.viewEmpty.hidden = YES;
            }
        }else{
            if (more) {
                self.page --;
                [self.mainTableView.mj_footer endRefreshing];
            }else{
                [self.mainTableView.mj_header endRefreshing];
            }
        }
    } failureBlock:^(NSError *error) {
        if (more) {
            self.page --;
            [self.mainTableView.mj_footer endRefreshing];
        }else{
            [self.mainTableView.mj_header endRefreshing];
        }
    } showHUD:YES];
}

//创建时间段滚动视图
-(void)setupScrollTimes{
    if (!self.dicFloor) {
        return;
    }
    self.arrTimes = self.dicFloor[@"activityList"];
    for (int i=0;i<self.arrTimes.count;i++) {
        NSDictionary *timeDic = self.arrTimes[i];
        UIView *viewTime = [[UIView alloc] initWithFrame:CGRectMake(12+i*100, 0, 88, _timeScrollView.height)];
        viewTime.backgroundColor = [UIColor whiteColor];
        viewTime.layer.cornerRadius = 4;
        
        viewTime.tag = 100+i;
        
        UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapTimeViewAction:)];
        viewTime.userInteractionEnabled = YES;
        [viewTime addGestureRecognizer:tap];
        
        //开抢时间
        UILabel *lblBegainTime = [[UILabel alloc] initCommonWithFrame:CGRectMake(0, 6, viewTime.width, 20) title:timeDic[@"showTime"] bgColor:[UIColor clearColor] titleColor:RGBMAIN titleFont:20 textAlignment:NSTextAlignmentCenter isFit:NO];
        lblBegainTime.tag = 1000;
        [viewTime addSubview:lblBegainTime];
        [lblBegainTime sizeToFit];
        lblBegainTime.width = lblBegainTime.width + 12;
        lblBegainTime.height = 20;
        viewTime.width = lblBegainTime.width;
        
        UILabel *lblIsShowText = [[UILabel alloc] initCommonWithFrame:CGRectMake(0, lblBegainTime.bottom+6, viewTime.width, 10) title:timeDic[@"saleStatus"] bgColor:[UIColor clearColor] titleColor:RGBMAIN titleFont:10 textAlignment:NSTextAlignmentCenter isFit:NO];
        [viewTime addSubview:lblIsShowText];
        lblIsShowText.tag = 2000;
        //是否正在抢购
        if ([timeDic[@"id"] integerValue] == [self.dicTime[@"id"] integerValue]) {
            self.actId = timeDic[@"id"];
            self.actTimeDic = timeDic;
            viewTime.backgroundColor = [UIColor whiteColor];
            lblBegainTime.textColor = RGBMAIN;
            lblIsShowText.textColor = RGBMAIN;
            
            self.offsetX = CGRectGetMaxX(viewTime.frame)-kSCREEN_WIDTH;
            if (self.offsetX<0) {
                self.offsetX = 0;
            }
        }else{
            viewTime.backgroundColor = [UIColor clearColor];
            lblBegainTime.textColor = [UIColor whiteColor];
            lblIsShowText.textColor = [UIColor whiteColor];
        }

        [_timeScrollView addSubview:viewTime];
        _timeScrollView.contentSize = CGSizeMake(CGRectGetMaxX(viewTime.frame)+12, _timeScrollView.height);
    }
    
    if (_timeScrollView.contentSize.width>=kSCREEN_WIDTH) {
        CGFloat maxRight = _timeScrollView.contentSize.width-kSCREEN_WIDTH;
        if (self.offsetX > maxRight) {
            self.offsetX = maxRight;
        }
    }
    [_timeScrollView setContentOffset:CGPointMake(self.offsetX, 0) animated:YES];
    
    [self getFloorGoodsList:NO];
}

#pragma mark -- tableView delegate datasource
-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return self.arrGoodsList.count;
}

-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    return 134;
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    HDTaoMallFloorDetailTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:NSStringFromClass([HDTaoMallFloorDetailTableViewCell class]) forIndexPath:indexPath];
    cell.model = self.arrGoodsList[indexPath.row];
    return cell;
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    HDTaoGoodsModel *model = self.arrGoodsList[indexPath.row];
    if ([model.clickStatus isEqualToString:@"0"]) {
        [SVHUDHelper showInfoWithTimestamp:1 msg:@"该活动已结束"];
        return;
    }
    if ([model.clickStatus isEqualToString:@"2"]) {
        [SVHUDHelper showInfoWithTimestamp:1 msg:@"该活动未开始，敬请期待"];
        return;
    }
    HDTaoGoodsDetailViewController *detailVC = [HDTaoGoodsDetailViewController new];
    detailVC.taoId = model.taoId;
    detailVC.indexTab = 1;
    [self.navigationController pushViewController:detailVC animated:YES];
}

#pragma mark ================== UI =====================

-(HDBaseNavView *)navView{
    if (!_navView) {
        _navView = [[HDBaseNavView alloc] initWithFrame:CGRectMake(0, 0, kSCREEN_WIDTH, NAVHIGHT) title:self.dicFloor[@"floorTitle"] bgColor:RGBMAIN backBtn:YES rightBtn:@"" rightBtnImage:@"" theDelegate:self];
    }
    return _navView;
}

-(void)setupUI{
    UIView *view = [[UIView alloc] initWithFrame:CGRectMake(0, NAVHIGHT, kSCREEN_WIDTH, 58)];
    view.backgroundColor = RGBMAIN;
    [self.view addSubview:view];
    
    //多时段scrollView
    UIScrollView *timeScroll = [[UIScrollView alloc] initWithFrame:CGRectMake(0, 0, kSCREEN_WIDTH, 50)];
    timeScroll.showsHorizontalScrollIndicator = NO;
    self.timeScrollView = timeScroll;
    [view addSubview:timeScroll];
    timeScroll.bouncesZoom = NO;
}

-(UITableView *)mainTableView{
    if (!_mainTableView) {
        _mainTableView = [[UITableView alloc] initWithFrame:CGRectMake(0, NAVHIGHT+58, kSCREEN_WIDTH, kSCREEN_HEIGHT-NAVHIGHT-58) style:UITableViewStylePlain];
        _mainTableView.delegate = self;
        _mainTableView.dataSource = self;
        _mainTableView.backgroundColor = [UIColor clearColor];
        _mainTableView.separatorStyle = UITableViewCellSeparatorStyleNone;
        [_mainTableView registerClass:[HDTaoMallFloorDetailTableViewCell class] forCellReuseIdentifier:NSStringFromClass([HDTaoMallFloorDetailTableViewCell class])];
        
    }
    return _mainTableView;
}

@end
