//
//  HDMyCutOrderServicesViewController.m
//  HairDress
//
//  Created by 张凯中 on 2019/12/29.
//  Copyright © 2019 zhangkaizhong. All rights reserved.
//

#import "HDMyCollectionsShopViewController.h"

#import "HDHomeTableViewCell.h"
#import <TencentLBS/TencentLBS.h>
#import "HDShopDetailViewController.h"

@interface HDMyCollectionsShopViewController ()<UITableViewDelegate,UITableViewDataSource,HDShopDetailViewDelegate,TencentLBSLocationManagerDelegate>

@property (nonatomic,strong) TencentLBSLocationManager *locationManager;
@property (nonatomic,assign) NSInteger page;
@property (nonatomic,strong) UITableView *mainTableView;
@property (nonatomic,strong) NSMutableArray *arrData;

@property (nonatomic,copy) NSString *longitude;
@property (nonatomic,copy) NSString *latitude;

@end

@implementation HDMyCollectionsShopViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.page = 1;
    self.arrData = [NSMutableArray new];
    self.view.backgroundColor = RGBBG;
    [self.view addSubview:self.mainTableView];
    
    [self setupRefresh];
    
    //定位
    [self configLocationManager];
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
    [self requestCollectionList:NO];
    
}

//上提加载更多
-(void)loadMoreData{
    [self.mainTableView.mj_header endRefreshing];
    self.page ++;
    [self requestCollectionList:YES];
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
        
        [self requestCollectionList:NO];
    }
}

#pragma mark -- delegate
-(void)clickSearchShopCellWithModel:(HDHomeShopListModel *)model{
    HDShopDetailViewController *detailVC = [HDShopDetailViewController new];
    detailVC.shop_id = model.storeId;
    detailVC.delegate = self;
    [self.navigationController pushViewController:detailVC animated:YES];
}

//取消收藏
-(void)clickCollectActionRefreshList{
    [self loadNewData];
}

#pragma mark -- 数据请求
-(void)requestCollectionList:(BOOL)more{
    NSMutableDictionary *params = [NSMutableDictionary new];
    [params setValue:self.collectType forKey:@"collectType"];
    [params setValue:[HDUserDefaultMethods getData:@"userId"] forKey:@"userId"];
    [params setValue:@{
            @"pageIndex":@(self.page),
            @"pageSize":@(20)
    } forKey:@"page"];
    if (self.longitude && self.latitude) {
        [params setValue:[NSString stringWithFormat:@"%@,%@",self.latitude,self.longitude] forKey:@"location"];
    }
    WeakSelf;
    [MHNetworkManager postReqeustWithURL:URL_CollectList params:params successBlock:^(NSDictionary *returnData) {
        DTLog(@"%@",returnData);
        
        if ([returnData[@"respCode"] integerValue] == 200) {
            if (more) {
                [weakSelf.mainTableView.mj_footer endRefreshing];
            }else{
                [self.arrData removeAllObjects];
                [weakSelf.mainTableView.mj_header endRefreshing];
            }
            NSArray *arr = [HDHomeShopListModel mj_objectArrayWithKeyValuesArray:returnData[@"data"]];
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
    } showHUD:!more];
}

#pragma mark -- tableView delegate datasource

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return self.arrData.count;
}

-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    HDHomeShopListModel *model = self.arrData[indexPath.row];
    return model.cellHeight;
}

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
    detailVC.delegate = self;
    [self.navigationController pushViewController:detailVC animated:YES];
}

#pragma mark -- 加载控件

-(UITableView *)mainTableView{
    if (!_mainTableView) {
        _mainTableView = [[UITableView alloc] initWithFrame:CGRectMake(0, 8, kSCREEN_WIDTH, kSCREEN_HEIGHT-NAVHIGHT-48-8) style:UITableViewStylePlain];
        _mainTableView.delegate = self;
        _mainTableView.dataSource = self;
        _mainTableView.backgroundColor = [UIColor clearColor];
        _mainTableView.separatorStyle = UITableViewCellSeparatorStyleNone;
        [_mainTableView registerClass:[HDHomeTableViewCell class] forCellReuseIdentifier:NSStringFromClass([HDHomeTableViewCell class])];
    }
    return _mainTableView;
}

@end
