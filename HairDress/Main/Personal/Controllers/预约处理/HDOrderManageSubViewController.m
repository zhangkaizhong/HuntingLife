//
//  HDOrderManageWaitViewController.m
//  HairDress
//
//  Created by 张凯中 on 2019/12/26.
//  Copyright © 2019 zhangkaizhong. All rights reserved.
//

#import "HDOrderManageSubViewController.h"

#import "HDCancelCutQueneViewController.h"
#import "HDOrderManageTableViewCell.h"

@interface HDOrderManageSubViewController ()<UITableViewDelegate,UITableViewDataSource,OrderManageCellDelegate>

@property (nonatomic,assign) NSInteger page;
@property (nonatomic,strong) NSMutableArray *dataArr;
@property (nonatomic,strong) UITableView *mainTableView;

@end

@implementation HDOrderManageSubViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.view.backgroundColor = RGBBG;
    
    self.page = 1;
    self.dataArr = [NSMutableArray new];
    
    [self.view addSubview:self.mainTableView];
    
    [self setupRefresh];
    
    [self.mainTableView.mj_header beginRefreshing];
    
    if ([self.type isEqualToString:@"queue"]) {
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(cancelQueueRefreshAction:) name:@"cancelQueue" object:nil];
    }
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

#pragma mark -- action / delegate
-(void)clickOrderButtonType:(ServiceButtonType)btnType withModel:(nonnull HDStoreOrderListModel *)model{
    if (btnType == ButtonTypeCancel) {// 取消
        HDCancelCutQueneViewController *cancelVC = [HDCancelCutQueneViewController new];
        cancelVC.order_id = model.orderId;
        cancelVC.queue_num = model.queueNum;
        cancelVC.cancel_type = @"store";
        [self.navigationController pushViewController:cancelVC animated:YES];
    }
    if (btnType == ButtonTypeDone) {// 完成
        [self finishServiceRequest:model];
    }
    if (btnType == ButtonTypeBegain) {//开始
        [self begainServiceRequest:model];
    }
}

//取消预约通知
-(void)cancelQueueRefreshAction:(NSNotification *)notice{
    [self requestOrderList:NO];
}

#pragma mark ================== 数据请求 =====================
//请求订单列表
-(void)requestOrderList:(BOOL)more{
    NSDictionary *params = @{
        @"page":@{@"pageIndex":@(self.page),@"pageSize":@(20)},
        @"storeId":[HDUserDefaultMethods getData:@"storeId"],
        @"tonyId":[HDUserDefaultMethods getData:@"userId"],
        @"orderStatus":self.type
    };
    [MHNetworkManager postReqeustWithURL:URL_StoreOrderList params:params successBlock:^(NSDictionary *returnData) {
        DTLog(@"%@",returnData);
        
        if ([returnData[@"respCode"] integerValue] == 200) {
            if (!more) {
                [self.dataArr removeAllObjects];
                [self.mainTableView.mj_header endRefreshing];
            }else{
                [self.mainTableView.mj_footer endRefreshing];
            }
            if ([returnData[@"data"] isKindOfClass:[NSArray class]]) {
                NSArray *arr = [HDStoreOrderListModel mj_objectArrayWithKeyValuesArray:returnData[@"data"]];
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
            self.page --;
            [self.mainTableView.mj_footer endRefreshing];
        }
    } showHUD:NO];
}

//开始服务请求
-(void)begainServiceRequest:(HDStoreOrderListModel *)model{
    [MHNetworkManager postReqeustWithURL:URL_TonyStartService params:@{@"orderId":model.orderId} successBlock:^(NSDictionary *returnData) {
        DTLog(@"%@",returnData);
        if ([returnData[@"respCode"] integerValue] == 200) {
            [self loadNewData];
        }else{
            [SVHUDHelper showInfoWithTimestamp:1 msg:returnData[@"respMsg"]];
        }
    } failureBlock:^(NSError *error) {
        
    } showHUD:YES];
}

//完成服务请求
-(void)finishServiceRequest:(HDStoreOrderListModel *)model{
    [MHNetworkManager postReqeustWithURL:URL_TonyFinishService params:@{@"orderId":model.orderId} successBlock:^(NSDictionary *returnData) {
        if ([returnData[@"respCode"] integerValue] == 200) {
            [self loadNewData];
        }else{
            [SVHUDHelper showInfoWithTimestamp:1 msg:returnData[@"respMsg"]];
        }
    } failureBlock:^(NSError *error) {
        
    } showHUD:YES];
}

#pragma mark -- tableView delegate && datasource

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return self.dataArr.count;
}

-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    if ([self.type isEqualToString:@"queue"]) {
        //普通店员查看预约
        if ([[HDUserDefaultMethods getData:@"storePost"] isEqualToString:@"O"]){
            return 200;
        }
        return 285;
    }
    if ([self.type isEqualToString:@"service"]) {
        //普通店员查看预约
        if ([[HDUserDefaultMethods getData:@"storePost"] isEqualToString:@"O"]){
            return 200;
        }
        return 285;
    }
    if ([self.type isEqualToString:@"cancel"]) {
        return 174;
    }
    return 236;
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    HDOrderManageTableViewCell * cell = [tableView dequeueReusableCellWithIdentifier:@"cellwait" forIndexPath:indexPath];
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
        
        [_mainTableView registerClass:[HDOrderManageTableViewCell class] forCellReuseIdentifier:@"cellwait"];
    }
    return _mainTableView;
}

-(void)dealloc{
    DTLog(@"HDOrderManageSubViewController dealloc");
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

@end
