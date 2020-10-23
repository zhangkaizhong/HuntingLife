//
//  HDMyCutOrderServicesViewController.m
//  HairDress
//
//  Created by 张凯中 on 2019/12/29.
//  Copyright © 2019 zhangkaizhong. All rights reserved.
//

#import "HDMyCutOrdersDoneViewController.h"

#import "HDPublishEvaluateViewController.h"
#import "HDChooseCutTimeViewController.h"
#import "HDMyCutOrdersSubTableViewCell.h"

@interface HDMyCutOrdersDoneViewController ()<UITableViewDelegate,UITableViewDataSource,HDMyCutOrdersSubDelegate,HDPublishEvaluateDelegate>

@property (nonatomic,assign) NSInteger page;
@property (nonatomic,strong) NSMutableArray *dataArr;
@property (nonatomic,strong) UITableView *mainTableView;

@end

@implementation HDMyCutOrdersDoneViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.view.backgroundColor = RGBBG;
    [self.view addSubview:self.mainTableView];
    
    self.page = 1;
    self.dataArr = [NSMutableArray new];
    
    [self setupRefresh];
    
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
        @"userId":[HDUserDefaultMethods getData:@"userId"],
        @"orderStatus":self.type
    };
    [MHNetworkManager postReqeustWithURL:URL_YuyueUserOrderList params:params successBlock:^(NSDictionary *returnData) {
        DTLog(@"%@",returnData);
        
        if ([returnData[@"respCode"] integerValue] == 200) {
            if (!more) {
                [self.mainTableView.mj_header endRefreshing];
                [self.dataArr removeAllObjects];
            }else{
                [self.mainTableView.mj_footer endRefreshing];
            }
            if ([returnData[@"data"] isKindOfClass:[NSArray class]]) {
                NSArray *arr = [HDUserOrderListModel mj_objectArrayWithKeyValuesArray:returnData[@"data"]];
                [self.dataArr addObjectsFromArray:arr];
                [self.mainTableView reloadData];
                
                if (more && arr.count == 0) {
                    [self.mainTableView.mj_footer endRefreshingWithNoMoreData];
                }
                
                if (self.dataArr.count == 0) {
                    [self.mainTableView addSubview:self.viewEmpty];
                    self.viewEmpty.hidden = NO;
                }else{
                    self.viewEmpty.hidden = YES;
                }
            }
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
    } showHUD:NO];
}

//理发预约请求
-(void)createCutOrderRequest:(HDUserOrderListModel *)model{
    
    [self getNumRequest:model];
    
//    NSDictionary *params = @{
//        @"isYuyue":@"T",
//        @"serviceId":model.serviceId,
//        @"storeId":model.storeId,
//        @"tonyId":model.tonyId,
//        @"userId":[HDUserDefaultMethods getData:@"userId"]
//    };
//    [MHNetworkManager postReqeustWithURL:URL_YuyueCreateOrder params:params successBlock:^(NSDictionary *returnData) {
//        [SVHUDHelper showWorningMsg:returnData[@"respMsg"] timeInt:1];
//        if ([returnData[@"respCode"] integerValue] == 200) {
//            [HDToolHelper delayMethodFourGCD:1 method:^{
//                if (self.delegate && [self.delegate respondsToSelector:@selector(selectIndexRefresh)]) {
//                    [self.delegate selectIndexRefresh];
//                }
//            }];
//        }
//    } failureBlock:^(NSError *error) {
//
//    } showHUD:YES];
}

//重新获取配置项价格
-(void)getNumRequest:(HDUserOrderListModel *)model{
    NSDictionary *params = @{
        @"tonyId":model.tonyId
    };
    [MHNetworkManager postReqeustWithURL:URL_StoreTakeNum params:params successBlock:^(NSDictionary *returnData) {
        if ([returnData[@"respCode"] integerValue] == 200) {
            
            NSArray *arrVolist = returnData[@"data"][@"itemVoList"];
            for (NSDictionary *dic in arrVolist) {
                if ([model.serviceId integerValue] == [dic[@"id"] integerValue]) {
                    HDChooseCutTimeViewController *chooseVC = [HDChooseCutTimeViewController new];
                    chooseVC.storeID = model.storeId;
                    chooseVC.dicSelectService = dic;
                    chooseVC.cutterID = model.tonyId;
                    [self.navigationController pushViewController:chooseVC animated:YES];
                }
            }
            
        }else{
            [SVHUDHelper showInfoWithTimestamp:1 msg:returnData[@"respMsg"]];
        }
    } failureBlock:^(NSError *error) {
        
    } showHUD:YES];
}

#pragma mark ================== delegate action =====================
-(void)clickMyCutOrdersSubBtnType:(MyCutOrdersSubButtonType)type model:(nonnull HDUserOrderListModel *)model{
    if (type == MyCutOrdersSubButtonTypeEva) {//评价
        HDPublishEvaluateViewController *evaVC = [HDPublishEvaluateViewController new];
        evaVC.order_id = model.orderId;
        evaVC.delegate = self;
        [self.navigationController pushViewController:evaVC animated:YES];
    }else{
        [[WMZAlert shareInstance] showAlertWithType:AlertTypeNornal headTitle:@"提示" textTitle:@"是否重新取号?" viewController:self leftHandle:^(id anyID) {
            //取消
        }rightHandle:^(id any) {
            //重新取号
            [self createCutOrderRequest:model];
        }];
    }
}

//评价后刷新列表
-(void)publishEvaDelegate{
    [self requestOrderList:NO];
}

#pragma mark -- tableView delegate datasource

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return self.dataArr.count;
}

-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    return 328;
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    HDMyCutOrdersSubTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:NSStringFromClass([HDMyCutOrdersSubTableViewCell class]) forIndexPath:indexPath];
    cell.delegate = self;
    cell.model = self.dataArr[indexPath.row];
    return cell;
}

#pragma mark -- 加载控件

-(UITableView *)mainTableView{
    if (!_mainTableView) {
        _mainTableView = [[UITableView alloc] initWithFrame:CGRectMake(0, 0, kSCREEN_WIDTH, kSCREEN_HEIGHT-NAVHIGHT-48) style:UITableViewStylePlain];
        _mainTableView.delegate = self;
        _mainTableView.dataSource = self;
        _mainTableView.backgroundColor = [UIColor clearColor];
        _mainTableView.separatorStyle = UITableViewCellSeparatorStyleNone;
        [_mainTableView registerClass:[HDMyCutOrdersSubTableViewCell class] forCellReuseIdentifier:NSStringFromClass([HDMyCutOrdersSubTableViewCell class])];
    }
    return _mainTableView;
}

@end
