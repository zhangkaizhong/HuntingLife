//
//  HDHomeViewController.m
//  HairDress
//
//  Created by Apple on 2019/12/18.
//  Copyright © 2019 zhangkaizhong. All rights reserved.
//

#import "HDCutHomeViewController.h"

#import "HDSearchViewController.h"
#import "HDSearchAreasViewController.h"
#import "HDShopDetailViewController.h"
#import "HDWebViewController.h"
#import "HDTaoGoodsDetailViewController.h"
#import "HDCalenderViewController.h"

#import <TencentLBS/TencentLBS.h>
#import <SDCycleScrollView.h>
#import "HDHomeTableViewCell.h"
#import "UIScrollView+Associated.h"

#define TABLE_HEARDER_HEGHT (224+56+8)*SCALE

@interface HDCutHomeViewController ()<TencentLBSLocationManagerDelegate,navViewDelegate,SDCycleScrollViewDelegate,UITableViewDelegate,UITableViewDataSource,HomeTableViewCellDelegate>
{
    CGRect initialFrame;
    CGFloat defaultViewHeight;
}
@property (nonatomic,strong) TencentLBSLocationManager *locationManager;

//bannerlist
@property (nonatomic,strong)NSMutableArray *imageArray;
@property (nonatomic,strong)NSMutableArray *bannerListArray;
//门店列表数据
@property (nonatomic,strong) NSMutableArray *arrDataList;

@property (nonatomic,strong) UITableView * mainTableView;  // 列表

@property (nonatomic,strong)HDBaseNavView *navView;//导航栏
@property (nonatomic,strong)HDBaseNavView *navHiddenView;//隐藏导航栏
@property (nonatomic,strong) SDCycleScrollView * bannerView;  // 滚动视图
@property (nonatomic,strong)UIImageView *headBackImgView; // 顶部背景
@property (nonatomic,strong)UIImageView *topBackImgView; // 顶部背景
@property (nonatomic,strong)UIView *headerView; // 头视图

@property (nonatomic,copy) NSString *longitude;
@property (nonatomic,copy) NSString *latitude;

@property (nonatomic,strong) UIButton *btnRecords;

//根据定位获取的城市名
@property (nonatomic,copy) NSString *locationCityName;

@property (nonatomic,assign) NSInteger page;

@end

@implementation HDCutHomeViewController

- (void)viewDidLoad {
    [super viewDidLoad];

    if (@available(iOS 11.0, *)) {
        [[UIScrollView appearance] setContentInsetAdjustmentBehavior:UIScrollViewContentInsetAdjustmentNever];
    }else {
        self.automaticallyAdjustsScrollViewInsets = NO;
    }
    
//    [self.view addSubview:self.topBackImgView];
    [self.view addSubview:self.mainTableView];
    [self.view addSubview:self.navHiddenView];
    
    self.headerView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, kSCREEN_WIDTH, TABLE_HEARDER_HEGHT)];
    [self.headerView addSubview:self.headBackImgView];
    [self.headerView addSubview:self.bannerView];
    [self.headerView addSubview:self.navView];
    [self.view addSubview:self.btnRecords];
    self.mainTableView.tableHeaderView = self.headerView;
    
    initialFrame       = _headBackImgView.frame;
    defaultViewHeight  = initialFrame.size.height;
    
    self.page = 1;
    self.arrDataList = [NSMutableArray new];
    self.imageArray = [NSMutableArray new];
    self.bannerListArray = [NSMutableArray new];
    
    //定位
    [self configLocationManager];
    
    [self requestHomeBannerList];
    
    [self setupRefresh];
}

#pragma mark ================== 监听网络变化后重新加载数据 =====================
-(void)getLoadDataBase:(NSNotification *)text{
    [super getLoadDataBase:text];
    if ([text.userInfo[@"netType"] integerValue] != 0){
        if (self.arrDataList.count == 0) {
            [self loadNewData];
        }
        if (self.bannerListArray.count == 0) {
            [self requestHomeBannerList];
        }
    }
}

#pragma mark ================== 首页数据请求 =====================
#pragma mark - 添加刷新控件
-(void)setupRefresh{
//    self.mainTableView.mj_header = [MJRefreshNormalHeader headerWithRefreshingTarget:self refreshingAction:@selector(loadNewData)];
    self.mainTableView.mj_footer = [MJRefreshBackNormalFooter footerWithRefreshingTarget:self refreshingAction:@selector(loadMoreData)];
    MJRefreshNormalHeader *header = [MJRefreshNormalHeader headerWithRefreshingTarget:self refreshingAction:@selector(loadNewData)];
//    MJRefreshGifHeader *header = [MJRefreshGifHeader headerWithRefreshingTarget:self refreshingAction:@selector(loadNewData)];
    self.mainTableView.mj_header = header;
    header.lastUpdatedTimeLabel.hidden =YES;
//    header.stateLabel.textColor = [UIColor whiteColor];
//    [header setImages:@[[UIImage imageNamed:@"home_bg"]] forState:MJRefreshStateRefreshing];
}

//下拉刷新数据
-(void)loadNewData{
    [self requestHomeBannerList];
    [self.mainTableView.mj_footer endRefreshing];
    self.page = 1;
    [self requestHomeDataList:NO];
}

//上提加载更多
-(void)loadMoreData{
    [self.mainTableView.mj_header endRefreshing];
    self.page ++;
    [self requestHomeDataList:YES];
}

#pragma mark ================== 门店列表请求 =====================
-(void)requestHomeDataList:(BOOL)more{
    NSDictionary *dic = @{
        @"location": [NSString stringWithFormat:@"%@,%@",self.latitude,self.longitude],
        @"page":@{@"pageIndex":@(self.page),@"pageSize":@"20"}
    };
    WeakSelf;
    [MHNetworkManager postReqeustWithURL:URL_GetHomepage params:dic successBlock:^(NSDictionary *returnData) {
        DTLog(@"%@",returnData);
        weakSelf.bannerView.imageURLStringsGroup = self.imageArray;
        if ([returnData[@"respCode"] integerValue] == 200) {
            if (!more) {
                [self.arrDataList removeAllObjects];
                [weakSelf.mainTableView.mj_header endRefreshing];
            }else{
                [weakSelf.mainTableView.mj_footer endRefreshing];
            }
            NSArray *arr = [HDHomeShopListModel mj_objectArrayWithKeyValuesArray:returnData[@"data"]];
            if (more && arr.count == 0) {
                weakSelf.page --;
            }
            [weakSelf.arrDataList addObjectsFromArray:arr];
            [weakSelf.mainTableView reloadData];
            if (arr.count == 0) {
                [weakSelf.mainTableView.mj_footer endRefreshingWithNoMoreData];
            }
        }else{
            if (!more) {
                [weakSelf.mainTableView.mj_header endRefreshing];
            }else{
                weakSelf.page --;
                [weakSelf.mainTableView.mj_footer endRefreshing];
            }
            [SVHUDHelper showInfoWithTimestamp:1 msg:returnData[@"respMsg"]];
        }
    } failureBlock:^(NSError *error) {
        if (!more) {
            [weakSelf.mainTableView.mj_header endRefreshing];
        }else{
            weakSelf.page --;
            [weakSelf.mainTableView.mj_footer endRefreshing];
        }
    } showHUD:!more];
}

#pragma mark ================== 首页轮播列表 =====================
-(void)requestHomeBannerList{
    [MHNetworkManager postReqeustWithURL:URL_GetBannarList params:@{@"positionCode":@"cutIndex"} successBlock:^(NSDictionary *returnData) {
        returnData = [HDToolHelper nullDicToDic:returnData];
        if ([returnData[@"respCode"] integerValue] == 200) {
            [self.bannerListArray removeAllObjects];
            [self.imageArray removeAllObjects];
            [self.bannerListArray addObjectsFromArray:returnData[@"data"]];
            for (NSDictionary *dicPic in self.bannerListArray) {
                [self.imageArray addObject:dicPic[@"bannerPic"]];
            }
//            if (self.imageArray.count == 0) {
//                self.headerView.height = 0;
//            }else{
//                self.headerView.height = TABLE_HEARDER_HEGHT;
                self.bannerView.imageURLStringsGroup = self.imageArray;
//            }
        }
    } failureBlock:^(NSError *error) {
        
    } showHUD:NO];
}

#pragma mark ================== 获取定位结果 =====================
-(void)tencentLBSLocationManager:(TencentLBSLocationManager *)manager didUpdateLocation:(TencentLBSLocation *)location{
    //定位结果
    DTLog(@"location:%@---%@---%@---%@", location.province,location.city,location.district,location.name);
    DTLog(@"location:%f---%f", location.location.coordinate.longitude,location.location.coordinate.latitude);
    self.longitude = [NSString stringWithFormat:@"%f",location.location.coordinate.longitude];
    self.latitude = [NSString stringWithFormat:@"%f",location.location.coordinate.latitude];
    [HDUserDefaultMethods saveData:self.longitude andKey:@"userLong"];
    [HDUserDefaultMethods saveData:self.latitude andKey:@"userLat"];
    if (![HDToolHelper StringIsNullOrEmpty:self.longitude] && ![HDToolHelper StringIsNullOrEmpty:self.latitude] && [self.longitude floatValue] > 0 && [self.latitude floatValue] > 0) {
        [self.locationManager stopUpdatingLocation];
        NSString *cityStr = location.city;
        self.locationCityName = location.city;
        NSString *lastString = [cityStr substringFromIndex:cityStr.length-1];
        if ([lastString isEqualToString:@"市"]) {
            cityStr = [cityStr substringToIndex:[cityStr length]-1];
        }
        self.navView.cityName = cityStr;
        self.navHiddenView.cityName = cityStr;
        [self requestHomeDataList:NO];
    }
}

 #pragma mark ================== delegate =====================
// 搜索
-(void)navClickSearchView{
    HDSearchViewController *searchVC = [[HDSearchViewController alloc] init];
    searchVC.cityName = self.locationCityName;
    searchVC.longitude = self.longitude;
    searchVC.latitude = self.latitude;
    [self.navigationController pushViewController:searchVC animated:YES];
}

#pragma mark - UIScrollViewDelegate 导航栏渐变
-(void)scrollViewDidScroll:(UIScrollView *)scrollView{
    CGFloat offsetY = scrollView.contentOffset.y;
    if (offsetY <= 0) {//下拉，隐藏 navView
//        _topBackImgView.y = -240*SCALE-offsetY;
    }else{//移动过程
        if (offsetY>TABLE_HEARDER_HEGHT-30) {
            [UIView animateWithDuration:0.5 animations:^{
                self.navHiddenView.y = 0;
            }];
        }else if (offsetY<TABLE_HEARDER_HEGHT-70){
            [UIView animateWithDuration:0.5 animations:^{
                self.navHiddenView.y = -NAVHIGHT-12*SCALE;
            }];
        }
    }
}

//城市选择
-(void)navClickCitySearch{
//    HDSearchAreasViewController *areasVC = [HDSearchAreasViewController new];
//    [self.navigationController pushViewController:areasVC animated:YES];
}

//首页banner点击
- (void)cycleScrollView:(SDCycleScrollView *)cycleScrollView didSelectItemAtIndex:(NSInteger)index{
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
        detailVC.indexTab = 0;
        [self.navigationController pushViewController:detailVC animated:YES];
    }
}

// cell btn click
-(void)clickHomeCellWithModel:(HDHomeShopListModel *)model{
    HDShopDetailViewController *detailVC = [HDShopDetailViewController new];
    detailVC.shop_id = model.storeId;
    [self.navigationController pushViewController:detailVC animated:YES];
}

#pragma mark ================== tableview delegate =====================

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    HDHomeTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"homecell" forIndexPath:indexPath];
    cell.delegate = self;
    cell.shopModel = self.arrDataList[indexPath.row];
    if (indexPath.row == 0) {
        cell.nearestDis = @"1";
    }else{
        cell.nearestDis = @"0";
    }
    return cell;
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    HDHomeShopListModel *model = self.arrDataList[indexPath.row];
    HDShopDetailViewController *detailVC = [HDShopDetailViewController new];
    detailVC.shop_id = model.storeId;
    [self.navigationController pushViewController:detailVC animated:YES];
}

-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    HDHomeShopListModel *model = self.arrDataList[indexPath.row];
    return model.cellHeight;
}

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return self.arrDataList.count;
}

// 剪发日历
-(void)btnRecordsAction:(UIButton *)sender{
    if ([[HDUserDefaultMethods getData:@"userId"] isEqualToString:@""]) {
        [HDToolHelper preToLoginView];
        return;
    }
    HDCalenderViewController *calenderVC = [HDCalenderViewController new];
    [self.navigationController pushViewController:calenderVC animated:YES];
}

#pragma mark ================== 懒加载 =====================

-(UITableView *)mainTableView{
    if (!_mainTableView) {
        _mainTableView = [[UITableView alloc] initWithFrame:CGRectMake(0,0, kSCREEN_WIDTH, kSCREEN_HEIGHT-KTarbarHeight) style:UITableViewStylePlain];
        _mainTableView.delegate = self;
        _mainTableView.dataSource = self;
        _mainTableView.separatorStyle = UITableViewCellSeparatorStyleNone;
        _mainTableView.backgroundColor = [UIColor clearColor];
        [_mainTableView registerClass:[HDHomeTableViewCell class] forCellReuseIdentifier:@"homecell"];
    }
    return _mainTableView;
}

// 导航栏
-(HDBaseNavView *)navView{
    if (!_navView) {
        _navView = [[HDBaseNavView alloc] initSearchBarViewWithFrame:CGRectMake(10, 224*SCALE, kSCREEN_WIDTH-20, 56*SCALE)
                                                             bgColor:[UIColor whiteColor]
                                                           textColor:RGBTEXT
                                                     searchViewColor:[UIColor whiteColor]
                                                             isWhite:@"0"
                                                         theDelegate:self];
        _navView.layer.backgroundColor = [UIColor colorWithRed:255/255.0 green:255/255.0 blue:255/255.0 alpha:1.0].CGColor;
        _navView.layer.cornerRadius = 4;
        _navView.layer.shadowColor = [UIColor colorWithRed:0/255.0 green:0/255.0 blue:0/255.0 alpha:0.1].CGColor;
        _navView.layer.shadowOffset = CGSizeMake(0,1);
        _navView.layer.shadowOpacity = 1;
        _navView.layer.shadowRadius = 4;
        _navView.searchView.centerY = 56*SCALE/2;
        _navView.searchView.width = kSCREEN_WIDTH-20-32;
        _navView.searchView.layer.cornerRadius = 32*SCALE/2;
        _navView.searchView.layer.borderWidth = 1;
        _navView.searchView.layer.borderColor = RGBCOLOR(229, 229, 229).CGColor;
    }
    return _navView;
}

// 导航栏
-(HDBaseNavView *)navHiddenView{
    if (!_navHiddenView) {
        _navHiddenView = [[HDBaseNavView alloc] initSearchBarViewWithFrame:CGRectMake(0, -NAVHIGHT-12*SCALE, kSCREEN_WIDTH, NAVHIGHT+12*SCALE)
                                                             bgColor:[UIColor whiteColor]
                                                           textColor:RGBTEXT
                                                     searchViewColor:[UIColor whiteColor]
                                                             isWhite:@"0"
                                                         theDelegate:self];
        _navHiddenView.searchView.width = kSCREEN_WIDTH-32;
        _navHiddenView.searchView.layer.cornerRadius = 32*SCALE/2;
        _navHiddenView.searchView.layer.borderWidth = 1;
        _navHiddenView.searchView.layer.borderColor = RGBCOLOR(229, 229, 229).CGColor;
    }
    return _navHiddenView;
}
-(SDCycleScrollView *)bannerView{
    if (!_bannerView) {
        
        SDCycleScrollView *cycleScrollView = [SDCycleScrollView cycleScrollViewWithFrame:CGRectMake(0,0, kSCREEN_WIDTH, 235*SCALE) delegate:self placeholderImage:[UIImage imageNamed:@""]];
        cycleScrollView.delegate = self;
        cycleScrollView.autoScrollTimeInterval = 3;
        cycleScrollView.backgroundColor = [UIColor clearColor];
        cycleScrollView.currentPageDotColor = RGBMAIN;
        cycleScrollView.pageControlBottomOffset = 10;
        cycleScrollView.pageDotColor = [UIColor whiteColor];
        
        _bannerView = cycleScrollView;
    }
    return _bannerView;
}

- (UIImageView *)headBackImgView{
    if (!_headBackImgView) {
        _headBackImgView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, kSCREEN_WIDTH, 150*HEIGHT_SCALE)];
        _headBackImgView.image = [UIImage imageNamed:@"home_bg320"];
    }
    return _headBackImgView;
}
- (UIImageView *)topBackImgView{
    if (!_topBackImgView) {
        _topBackImgView = [[UIImageView alloc] initWithFrame:CGRectMake(0, -240*SCALE, kSCREEN_WIDTH, 240*SCALE)];
        _topBackImgView.image = [UIImage imageNamed:@"home_bg240"];
    }
    return _topBackImgView;
}

// 剪发日历
-(UIButton *)btnRecords{
    if (!_btnRecords) {
        _btnRecords = [[UIButton alloc] initSystemWithFrame:CGRectMake(kSCREEN_WIDTH-60*SCALE, kSCREEN_HEIGHT-KTarbarHeight-47*SCALE, 50*SCALE, 47*SCALE) btnTitle:@"" btnImage:@"btn_calendar_cl" titleColor:[UIColor clearColor] titleFont:0];
        [_btnRecords addTarget:self action:@selector(btnRecordsAction:) forControlEvents:UIControlEventTouchUpInside];
    }
    return _btnRecords;
}

#pragma mark -- 定位相关
- (void)configLocationManager
{
    self.locationManager = [[TencentLBSLocationManager alloc] init];
    [self.locationManager setDelegate:self];
    [self.locationManager setApiKey:TencentMapKey];
//    [self.locationManager setPausesLocationUpdatesAutomatically:NO];
//    // 需要后台定位的话，可以设置此属性为YES。
//    [self.locationManager setAllowsBackgroundLocationUpdates:YES];
    // 如果需要POI信息的话，根据所需要的级别来设定，定位结果将会根据设定的POI级别来返回，如：
    [self.locationManager setRequestLevel:TencentLBSRequestLevelPoi];
    // 申请的定位权限，得和在info.list申请的权限对应才有效
    CLAuthorizationStatus authorizationStatus = [CLLocationManager authorizationStatus];
    if (authorizationStatus == kCLAuthorizationStatusNotDetermined) {
        [self.locationManager requestWhenInUseAuthorization];
    }
    
    [self.locationManager startUpdatingLocation];
}

@end
