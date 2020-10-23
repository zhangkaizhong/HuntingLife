//
//  HDOrderManageWaitViewController.m
//  HairDress
//
//  Created by 张凯中 on 2019/12/26.
//  Copyright © 2019 zhangkaizhong. All rights reserved.
//

#import "HDMyOrdersSubViewController.h"

#import "HDMyOrdersTableViewCell.h"

@interface HDMyOrdersSubViewController ()<UITableViewDelegate,UITableViewDataSource,MyOrdersCellDelegate>

@property (nonatomic,assign) NSInteger page;
@property (nonatomic,strong) NSMutableArray *dataArr;

@property (nonatomic,strong) UITableView *mainTableView;

@end

@implementation HDMyOrdersSubViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.view.backgroundColor = RGBBG;
    [self.view addSubview:self.mainTableView];
    
    self.page = 1;
    self.dataArr = [NSMutableArray new];
    
    [self setupRefresh];
    //创建刷新控件
    [self.mainTableView.mj_header beginRefreshing];
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
    [self requestOrderList:NO];
}

//上提加载更多
-(void)loadMoreData{
    [self.mainTableView.mj_header endRefreshing];
    self.page ++;
    [self requestOrderList:YES];
}

#pragma mark ================== 数据请求 =====================
//请求订单列表
-(void)requestOrderList:(BOOL)more{
    NSDictionary *params = @{
        @"page":@{@"pageIndex":@(self.page),@"pageSize":@(10)},
        @"tonyId":[HDUserDefaultMethods getData:@"userId"],
        @"orderStatus":self.type
    };
    [MHNetworkManager postReqeustWithURL:URL_TonyOrderList params:params successBlock:^(NSDictionary *returnData) {
        DTLog(@"%@",returnData);
        if ([returnData[@"respCode"] integerValue] == 200) {
            
            if (!more) {
                [self.mainTableView.mj_header endRefreshing];
                [self.dataArr removeAllObjects];
            }else{
                [self.mainTableView.mj_footer endRefreshing];
            }
            
            if ([returnData[@"data"] isKindOfClass:[NSArray class]]) {
                NSArray *arr = [HDTonyOrderListModel mj_objectArrayWithKeyValuesArray:returnData[@"data"]];
                [self.dataArr addObjectsFromArray:arr];
                [self.mainTableView reloadData];
                
                if (self.dataArr.count == 0) {
                    [self.mainTableView addSubview:self.viewEmpty];
                    self.viewEmpty.hidden = NO;
                }else{
                    self.viewEmpty.hidden = YES;
                }
                if (arr.count == 0) {
                    [self.mainTableView.mj_footer endRefreshingWithNoMoreData];
                }
            }
        }else{
            if (!more) {
                [self.mainTableView.mj_header endRefreshing];
            }else{
                self.page--;
                [self.mainTableView.mj_footer endRefreshing];
            }
            [SVHUDHelper showInfoWithTimestamp:1 msg:returnData[@"respMsg"]];
        }
    } failureBlock:^(NSError *error) {
        if (!more) {
            [self.mainTableView.mj_header endRefreshing];
        }else{
            self.page--;
            [self.mainTableView.mj_footer endRefreshing];
        }
    } showHUD:NO];
}

//开始服务请求
-(void)begainServiceRequest:(HDTonyOrderListModel *)model{
    [MHNetworkManager postReqeustWithURL:URL_TonyStartService params:@{@"orderId":model.orderId} successBlock:^(NSDictionary *returnData) {
        if ([returnData[@"respCode"] integerValue] == 200) {
            [self loadNewData];
        }else{
            [SVHUDHelper showInfoWithTimestamp:1 msg:returnData[@"respMsg"]];
        }
    } failureBlock:^(NSError *error) {
        
    } showHUD:YES];
}

//完成服务请求
-(void)finishServiceRequest:(HDTonyOrderListModel *)model{
    [MHNetworkManager postReqeustWithURL:URL_TonyFinishService params:@{@"orderId":model.orderId} successBlock:^(NSDictionary *returnData) {
        if ([returnData[@"respCode"] integerValue] == 200) {
            [self loadNewData];
        }else{
            [SVHUDHelper showInfoWithTimestamp:1 msg:returnData[@"respMsg"]];
        }
    } failureBlock:^(NSError *error) {
        
    } showHUD:YES];
}

#pragma mark -- action / delegate
-(void)clickOrderButtonType:(MyOrdersButtonType)btnType model:(nonnull HDTonyOrderListModel *)model{
    if (btnType == MyOrdersButtonTypeDone) {// 完成服务
        [self finishServiceRequest:model];
    }
    if (btnType == MyOrdersButtonTypeBegain) {//开始服务
        [self begainServiceRequest:model];
    }
}

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return self.dataArr.count;
}

-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    if ([self.type isEqualToString:@"queue"]) {
        return 120;
    }
    if ([self.type isEqualToString:@"service"]) {
        return 120;
    }
    return 144;
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    HDMyOrdersTableViewCell * cell = [tableView dequeueReusableCellWithIdentifier:@"cellorder" forIndexPath:indexPath];
    cell.model = self.dataArr[indexPath.row];
    cell.delegate = self;
    return cell;
}

-(UITableView *)mainTableView{
    if (!_mainTableView) {
        _mainTableView = [[UITableView alloc] initWithFrame:CGRectMake(0, 0, kSCREEN_WIDTH, kSCREEN_HEIGHT-NAVHIGHT-48) style:UITableViewStylePlain];
        _mainTableView.delegate = self;
        _mainTableView.dataSource = self;
        _mainTableView.backgroundColor = [UIColor clearColor];
        _mainTableView.separatorStyle = UITableViewCellSeparatorStyleNone;
        
        [_mainTableView registerClass:[HDMyOrdersTableViewCell class] forCellReuseIdentifier:@"cellorder"];
    }
    return _mainTableView;
}

@end
