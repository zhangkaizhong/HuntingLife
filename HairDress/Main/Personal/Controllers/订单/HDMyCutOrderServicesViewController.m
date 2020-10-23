//
//  HDMyCutOrderServicesViewController.m
//  HairDress
//
//  Created by 张凯中 on 2019/12/29.
//  Copyright © 2019 zhangkaizhong. All rights reserved.
//

#import "HDMyCutOrderServicesViewController.h"

#import "HDMyCutOrderServiceTableViewCell.h"

@interface HDMyCutOrderServicesViewController ()<UITableViewDelegate,UITableViewDataSource>

@property (nonatomic,strong) UITableView *mainTableView;
@property (nonatomic,strong) NSDictionary *dicOrderInfo;//服务中订单详情
@property (nonatomic,strong) NSMutableArray *arrData;

@end

@implementation HDMyCutOrderServicesViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.view.backgroundColor = RGBBG;
    [self.view addSubview:self.mainTableView];
    
    self.arrData = [NSMutableArray new];
    [self setupRefresh];
    [self getOrderServiceData];
}

#pragma mark - 添加刷新控件
-(void)setupRefresh{
    self.mainTableView.mj_header = [MJRefreshNormalHeader headerWithRefreshingTarget:self refreshingAction:@selector(loadNewData)];
}

//下拉刷新数据
-(void)loadNewData{
    [self.mainTableView.mj_footer endRefreshing];
    [self getOrderServiceData];
}

#pragma mark ================== 请求数据 =====================
//获取服务中数据
-(void)getOrderServiceData{
    NSDictionary *params = @{@"orderStatus":@(2),@"userId":[HDUserDefaultMethods getData:@"userId"]};
    [MHNetworkManager postReqeustWithURL:URL_YuyueUserOrder params:params successBlock:^(NSDictionary *returnData) {
        returnData = [HDToolHelper nullDicToDic:returnData];
        [self.mainTableView.mj_header endRefreshing];
        if ([returnData[@"respCode"] integerValue] == 200) {
            [self.arrData removeAllObjects];
            if ([returnData[@"data"] isKindOfClass:[NSDictionary class]]) {
                self.dicOrderInfo = returnData[@"data"];
                [self.arrData addObject:self.dicOrderInfo];
                [self.mainTableView reloadData];
                self.viewEmpty.hidden = YES;
            }else{
                if ([returnData[@"data"] isKindOfClass:[NSString class]] || [returnData[@"data"] isKindOfClass:[NSNull class]]) {
                    [self.mainTableView reloadData];
                    [self.mainTableView addSubview:self.viewEmpty];
                    self.viewEmpty.hidden = NO;
                }
            }
        }else{
            [SVHUDHelper showInfoWithTimestamp:1 msg:returnData[@"respMsg"]];
        }
    } failureBlock:^(NSError *error) {
        [self.mainTableView.mj_header endRefreshing];
    } showHUD:NO];
}

#pragma mark -- tableView delegate datasource

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return self.arrData.count;
}

-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    return 310;
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    HDMyCutOrderServiceTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:NSStringFromClass([HDMyCutOrderServiceTableViewCell class]) forIndexPath:indexPath];
    cell.dic = self.arrData[indexPath.row];
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
        [_mainTableView registerClass:[HDMyCutOrderServiceTableViewCell class] forCellReuseIdentifier:NSStringFromClass([HDMyCutOrderServiceTableViewCell class])];
    }
    return _mainTableView;
}

@end
