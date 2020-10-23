//
//  HDSearchShopsViewController.m
//  HairDress
//
//  Created by 张凯中 on 2019/12/21.
//  Copyright © 2019 zhangkaizhong. All rights reserved.
//

#import "HDSearchShopsViewController.h"

#import "HDHomeTableViewCell.h"
#import <TencentLBS/TencentLBS.h>
#import "HDShopDetailViewController.h"

@interface HDSearchShopsViewController ()<UITableViewDelegate,UITableViewDataSource,TencentLBSLocationManagerDelegate>

@property (nonatomic,strong) TencentLBSLocationManager *locationManager;
@property (nonatomic,assign) NSInteger page;
@property (nonatomic,strong) UITableView *mainTableView;
@property (nonatomic,strong) NSMutableArray *arrData;

@end

@implementation HDSearchShopsViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    UIView *line = [[UIView alloc] initWithFrame:CGRectMake(0, 0, kSCREEN_WIDTH, 1)];
    line.backgroundColor = RGBAlpha(239, 239, 239, 1);
    [self.view addSubview:line];
    
    self.view.backgroundColor = RGBBG;
    self.arrData = [NSMutableArray new];
    [self.view addSubview:self.mainTableView];
    
    //定位
    [self configLocationManager];
}

#pragma mark - 添加刷新控件
-(void)setupRefresh{
    self.mainTableView.mj_header = [MJRefreshNormalHeader headerWithRefreshingTarget:self refreshingAction:@selector(loadNewData)];
    self.mainTableView.mj_footer = [MJRefreshBackNormalFooter footerWithRefreshingTarget:self refreshingAction:@selector(loadMoreData)];
    
    [self loadNewData];
}

//下拉刷新数据
-(void)loadNewData{
    [self.mainTableView.mj_footer endRefreshing];
    self.page = 1;
    [self searchStoreListRequest:NO];
}

//上提加载更多
-(void)loadMoreData{
    [self.mainTableView.mj_header endRefreshing];
    self.page ++;
    [self searchStoreListRequest:YES];
}

#pragma mark -- 定位相关
- (void)configLocationManager{
    self.locationManager = [[TencentLBSLocationManager alloc] init];
    [self.locationManager setDelegate:self];
    [self.locationManager setApiKey:TencentMapKey];
    // 如果需要POI信息的话，根据所需要的级别来设定，定位结果将会根据设定的POI级别来返回，如：
    [self.locationManager setRequestLevel:TencentLBSRequestLevelPoi];
    // 申请的定位权限，得和在info.list申请的权限对应才有效
    CLAuthorizationStatus authorizationStatus = [CLLocationManager authorizationStatus];
    if (authorizationStatus == kCLAuthorizationStatusNotDetermined) {
        [self.locationManager requestWhenInUseAuthorization];
    }
    
    [self.locationManager startUpdatingLocation];
}

#pragma mark ================== 获取定位结果 =====================
-(void)tencentLBSLocationManager:(TencentLBSLocationManager *)manager didUpdateLocation:(TencentLBSLocation *)location{
    //定位结果
    self.longitude = [NSString stringWithFormat:@"%f",location.location.coordinate.longitude];
    self.latitude = [NSString stringWithFormat:@"%f",location.location.coordinate.latitude];
    [HDUserDefaultMethods saveData:self.longitude andKey:@"userLong"];
    [HDUserDefaultMethods saveData:self.latitude andKey:@"userLat"];
    if (![HDToolHelper StringIsNullOrEmpty:self.longitude] && ![HDToolHelper StringIsNullOrEmpty:self.latitude] && [self.longitude floatValue] > 0 && [self.latitude floatValue] > 0) {
        [self.locationManager stopUpdatingLocation];
    }
}

#pragma mark -- 数据请求
//搜索门店
-(void)searchStoreListRequest:(BOOL)more{
    NSMutableDictionary *params = [NSMutableDictionary new];
    [params setValue:self.tradeStr forKey:@"areaId"];
    [params setValue:self.serviceStr forKey:@"configValue"];
    [params setValue:@{
            @"pageIndex":@(self.page),
            @"pageSize":@(20)
    } forKey:@"page"];
    [params setValue:self.searchName forKey:@"searchName"];
    [params setValue:self.sortStr forKey:@"sort"];
    if (self.longitude && self.latitude) {
        [params setValue:[NSString stringWithFormat:@"%@,%@",self.latitude,self.longitude] forKey:@"location"];
    }
    WeakSelf;
    [MHNetworkManager postReqeustWithURL:URL_GetHomepage params:params successBlock:^(NSDictionary *returnData) {
        DTLog(@"%@",returnData);
        
        if ([returnData[@"respCode"] integerValue] == 200) {
            if (!more) {
                [self.arrData removeAllObjects];
                [weakSelf.mainTableView.mj_header endRefreshing];
            }else{
                [weakSelf.mainTableView.mj_footer endRefreshing];
            }
            NSArray *arr = [HDHomeShopListModel mj_objectArrayWithKeyValuesArray:returnData[@"data"]];
            if (more && arr.count == 0) {
                weakSelf.page --;
            }
            [weakSelf.arrData addObjectsFromArray:arr];
            [weakSelf.mainTableView reloadData];
        
            if (weakSelf.arrData.count == 0) {
                [weakSelf.mainTableView addSubview:self.viewEmpty];
                weakSelf.viewEmpty.hidden = NO;
            }else{
                weakSelf.viewEmpty.hidden = YES;
            }
        
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

#pragma mark -- delegate

#pragma mark -- tableview delegate \ action

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    HDHomeTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:NSStringFromClass([HDHomeTableViewCell class]) forIndexPath:indexPath];
    cell.shopModel = self.arrData[indexPath.row];
    if (indexPath.row == 0) {
        cell.nearestDis = @"1";
    }else{
        cell.nearestDis = @"0";
    }
    return cell;
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    HDHomeShopListModel *model = self.arrData[indexPath.row];
    HDShopDetailViewController *detailVC = [HDShopDetailViewController new];
    detailVC.shop_id = model.storeId;
    [self.navigationController pushViewController:detailVC animated:YES];
}

-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    HDHomeShopListModel *model = self.arrData[indexPath.row];
    return model.cellHeight;
}

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return self.arrData.count;
}


#pragma mark -- 加载控件

-(UITableView *)mainTableView{
    if (!_mainTableView) {
        _mainTableView = [[UITableView alloc] initWithFrame:CGRectMake(0, 1, kSCREEN_WIDTH, kSCREEN_HEIGHT-NAVHIGHT-48-49) style:UITableViewStylePlain];
        _mainTableView.backgroundColor = [UIColor clearColor];
        _mainTableView.delegate = self;
        _mainTableView.dataSource = self;
        _mainTableView.separatorStyle = UITableViewCellSeparatorStyleNone;
        [_mainTableView registerClass:[HDHomeTableViewCell class] forCellReuseIdentifier:NSStringFromClass([HDHomeTableViewCell class])];
        
    }
    
    return _mainTableView;
}

#pragma mark -- 加载视图


@end
