//
//  HDMyShopOrdersSubViewController.m
//  HairDress
//
//  Created by 张凯中 on 2019/12/29.
//  Copyright © 2019 zhangkaizhong. All rights reserved.
//

#import "HDMyShopOrdersSubViewController.h"

#import "HDMyShopOrdersTableViewCell.h"

@interface HDMyShopOrdersSubViewController ()<UITableViewDelegate,UITableViewDataSource>

@property (nonatomic,assign) NSInteger page;
@property (nonatomic,strong) UITableView *mainTableView;

@property (nonatomic,strong) NSMutableArray *dataArr;

@end

@implementation HDMyShopOrdersSubViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.page = 1;
    self.view.backgroundColor = RGBBG;
    self.dataArr = [NSMutableArray new];
    
    [self.view addSubview:self.mainTableView];
    
    [self getOrderList:NO];
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
    [self getOrderList:NO];
    
}

//上提加载更多
-(void)loadMoreData{
    [self.mainTableView.mj_header endRefreshing];
    self.page ++;
    [self getOrderList:YES];
}

#pragma mark -- 请求商品订单列表
//商品列表
-(void)getOrderList:(BOOL)more{
    NSDictionary *parmas = @{
        @"page":@{
                @"pageIndex":@(self.page),
                @"pageSize":@(20)
        },
        @"orderStatus":self.status,
        @"userId":[HDUserDefaultMethods getData:@"userId"]
    };
    [MHNetworkManager postReqeustWithURL:URL_TaoQueryOrderList params:parmas successBlock:^(NSDictionary *returnData) {
        if ([returnData[@"respCode"] integerValue] == 200) {
            if (!more) {
                [self.mainTableView.mj_header endRefreshing];
                [self.dataArr removeAllObjects];
            }else{
                [self.mainTableView.mj_footer endRefreshing];
            }
        
            NSArray *arr = [HDUserGoodsOrderListModel mj_objectArrayWithKeyValuesArray:returnData[@"data"]];
            [self.dataArr addObjectsFromArray:arr];
            
            if (arr.count == 0 && more) {
                [self.mainTableView.mj_footer endRefreshingWithNoMoreData];
            }
            
            if (self.dataArr.count == 0) {
                [self.mainTableView addSubview:self.viewEmpty];
                self.viewEmpty.hidden = NO;
            }else{
                self.viewEmpty.hidden = YES;
            }
            
            [self.mainTableView reloadData];
        }else{
            if (!more) {
                [self.mainTableView.mj_header endRefreshing];
            }else{
                self.page --;
                [self.mainTableView.mj_footer endRefreshing];
            }
            [SVHUDHelper showInfoWithTimestamp:1 msg:returnData[@"respMsg"]];
        }
    } failureBlock:^(NSError *error) {
        if (!more) {
            [self.mainTableView.mj_header endRefreshing];
        }else{
            self.page --;
            [self.mainTableView.mj_footer endRefreshing];
        }
    } showHUD:YES];
}

#pragma mark -- tableView delegate/datasource

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return self.dataArr.count;
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    HDMyShopOrdersTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:NSStringFromClass([HDMyShopOrdersTableViewCell class]) forIndexPath:indexPath];
    cell.model = self.dataArr[indexPath.row];
    return cell;
}

-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    return 149+8;
}

#pragma mark -- 加载控件
-(UITableView *)mainTableView{
    if (!_mainTableView) {
        _mainTableView = [[UITableView alloc] initWithFrame:CGRectMake(0, 0, kSCREEN_WIDTH, kSCREEN_HEIGHT-NAVHIGHT-48) style:UITableViewStylePlain];
        _mainTableView.delegate = self;
        _mainTableView.dataSource = self;
        _mainTableView.backgroundColor = [UIColor clearColor];
        _mainTableView.separatorStyle = UITableViewCellSeparatorStyleNone;
        [_mainTableView registerClass:[HDMyShopOrdersTableViewCell class] forCellReuseIdentifier:NSStringFromClass([HDMyShopOrdersTableViewCell class])];
    }
    return _mainTableView;
}


@end
