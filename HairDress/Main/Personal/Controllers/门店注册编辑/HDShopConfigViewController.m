//
//  HDShopConfigViewController.m
//  HairDress
//
//  Created by 张凯中 on 2020/3/11.
//  Copyright © 2020 zhangkaizhong. All rights reserved.
//

#import "HDShopConfigViewController.h"

#import "HDMyStoreConfigTableViewCell.h"
#import "HDAddShopConfigViewController.h"

@interface HDShopConfigViewController ()<navViewDelegate,HDAddShopConfigDelegate,UITableViewDelegate,UITableViewDataSource>

@property (nonatomic,strong) HDBaseNavView *navView;
@property (nonatomic,strong) UITableView *mainTableView;

@property (nonatomic,assign) NSInteger page;
@property (nonatomic,strong) NSMutableArray *arrData;

@property (nonatomic,strong) UIButton *btnDone;// 确认

@end

@implementation HDShopConfigViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.page = 1;
    self.arrData = [NSMutableArray new];
    
    self.view.backgroundColor = RGBBG;
    [self.view addSubview:self.navView];
    [self.view addSubview:self.mainTableView];
    [self.view addSubview:self.btnDone];
    
    [self setupRefresh];
    
    [self getShopConfigListData:NO];
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
    [self getShopConfigListData:NO];
    
}

//上提加载更多
-(void)loadMoreData{
    [self.mainTableView.mj_header endRefreshing];
    self.page ++;
    [self getShopConfigListData:YES];
}

#pragma mark -- delegate / action
-(void)navBackClicked{
    [self.navigationController popViewControllerAnimated:YES];
}

//新增后刷新列表
-(void)refreshShopConfigList{
    [self loadNewData];
}

//新增门店配置
-(void)addConfigAction{
    HDAddShopConfigViewController *addVC = [HDAddShopConfigViewController new];
    addVC.delegate = self;
    [self.navigationController pushViewController:addVC animated:YES];
}

#pragma mark -- 获取门店配置列表
-(void)getShopConfigListData:(BOOL)more{
    if ([[HDUserDefaultMethods getData:@"storeId"] isEqualToString:@""]) {
        return;
    }
    NSDictionary *params = @{
        @"page":@{
                @"pageIndex":@(self.page),
                @"pageSize":@(20)
        },
        @"storeId":[HDUserDefaultMethods getData:@"storeId"]
    };
    [MHNetworkManager postReqeustWithURL:URL_StoreConfigList params:params successBlock:^(NSDictionary *returnData) {
        
        if ([returnData[@"respCode"] integerValue] == 200) {
            if (more) {
                [self.mainTableView.mj_footer endRefreshing];
            }else{
                [self.arrData removeAllObjects];
                [self.mainTableView.mj_header endRefreshing];
            }
            
            NSArray *arr = [HDMyStoreConfigModel mj_objectArrayWithKeyValuesArray:returnData[@"data"]];
            if (arr.count == 0 && more) {
                [self.mainTableView.mj_footer endRefreshingWithNoMoreData];
            }
            [self.arrData addObjectsFromArray:arr];
            [self.mainTableView reloadData];
            
            if (self.arrData.count == 0) {
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

#pragma mark -- tableView delegate datasource

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return self.arrData.count;
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    HDMyStoreConfigTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:NSStringFromClass([HDMyStoreConfigTableViewCell class])];
    cell.model = self.arrData[indexPath.row];
    return cell;
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    HDMyStoreConfigModel *model = self.arrData[indexPath.row];
    HDAddShopConfigViewController *addVC = [HDAddShopConfigViewController new];
    addVC.delegate = self;
    addVC.storeConfigModel = model;
    [self.navigationController pushViewController:addVC animated:YES];
}

-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    return 57;
}

#pragma mark -- 加载控件

-(UITableView *)mainTableView{
    if (!_mainTableView) {
        _mainTableView = [[UITableView alloc] initWithFrame:CGRectMake(0, NAVHIGHT, kSCREEN_WIDTH, kSCREEN_HEIGHT-NAVHIGHT-48-40-32) style:UITableViewStylePlain];
        _mainTableView.delegate = self;
        _mainTableView.dataSource = self;
        _mainTableView.backgroundColor = [UIColor clearColor];
        _mainTableView.separatorStyle = UITableViewCellSeparatorStyleNone;
        [_mainTableView registerClass:[HDMyStoreConfigTableViewCell class] forCellReuseIdentifier:NSStringFromClass([HDMyStoreConfigTableViewCell class])];
    }
    return _mainTableView;
}

-(UIButton *)btnDone{
    if (!_btnDone) {
        _btnDone = [[UIButton alloc] initSystemWithFrame:CGRectMake(16, kSCREEN_HEIGHT-48-32, kSCREEN_WIDTH-32, 48) btnTitle:@"新增门店配置" btnImage:@"" titleColor:[UIColor whiteColor] titleFont:14];
        _btnDone.layer.cornerRadius = 24;
        _btnDone.backgroundColor = RGBMAIN;
        
        [_btnDone addTarget:self action:@selector(addConfigAction) forControlEvents:UIControlEventTouchUpInside];
    }
    return _btnDone;
}

-(HDBaseNavView *)navView{
    if (!_navView) {
        
        _navView = [[HDBaseNavView alloc] initWithFrame:CGRectMake(0, 0, kSCREEN_WIDTH, NAVHIGHT) title:@"门店配置" bgColor:RGBMAIN backBtn:YES rightBtn:@"" rightBtnImage:@"" theDelegate:self];
    }
    return _navView;
}

@end
