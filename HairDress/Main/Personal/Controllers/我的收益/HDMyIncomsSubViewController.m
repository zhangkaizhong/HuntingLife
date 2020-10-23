//
//  HDMyCutOrderServicesViewController.m
//  HairDress
//
//  Created by 张凯中 on 2019/12/29.
//  Copyright © 2019 zhangkaizhong. All rights reserved.
//

#import "HDMyIncomsSubViewController.h"

#import "HDMyIncomsTableViewCell.h"

@interface HDMyIncomsSubViewController ()<UITableViewDelegate,UITableViewDataSource>

@property (nonatomic,strong) UITableView *mainTableView;
@property (nonatomic,assign) NSInteger page;
@property (nonatomic,strong) NSMutableArray *arrData;

@end

@implementation HDMyIncomsSubViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.view.backgroundColor = RGBBG;
    self.page = 1;
    self.arrData = [NSMutableArray new];
    [self.view addSubview:self.mainTableView];
    
    [self setupRefresh];
    [self requestUserMoneyDetailList:NO];
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
    [self requestUserMoneyDetailList:NO];
    
}

//上提加载更多
-(void)loadMoreData{
    [self.mainTableView.mj_header endRefreshing];
    self.page ++;
    [self requestUserMoneyDetailList:YES];
}

#pragma mark -- 数据请求
-(void)requestUserMoneyDetailList:(BOOL)more{
    NSDictionary *params = @{
        @"profitOrderSource":self.orderSource,
        @"settleStatus":self.settleStatus,
        @"page":@{
                @"pageIndex":@(self.page),
                @"pageSize":@(20)
        },
        @"userId":[HDUserDefaultMethods getData:@"userId"]
    };
    WeakSelf;
    [MHNetworkManager postReqeustWithURL:URL_UserProfitList params:params successBlock:^(NSDictionary *returnData) {
        DTLog(@"%@",returnData);
        
        if ([returnData[@"respCode"] integerValue] == 200) {
            if (more) {
                [weakSelf.mainTableView.mj_footer endRefreshing];
            }else{
                [self.arrData removeAllObjects];
                [weakSelf.mainTableView.mj_header endRefreshing];
            }
            NSArray *arr = [HDMyIncomProfitsModel mj_objectArrayWithKeyValuesArray:returnData[@"data"]];
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
    return 119;
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    HDMyIncomsTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:NSStringFromClass([HDMyIncomsTableViewCell class]) forIndexPath:indexPath];
    cell.model = self.arrData[indexPath.row];
    return cell;
}

#pragma mark -- 加载控件

-(UITableView *)mainTableView{
    if (!_mainTableView) {
        _mainTableView = [[UITableView alloc] initWithFrame:CGRectMake(0, 8, kSCREEN_WIDTH, kSCREEN_HEIGHT-NAVHIGHT-8-56) style:UITableViewStylePlain];
        _mainTableView.delegate = self;
        _mainTableView.dataSource = self;
        _mainTableView.backgroundColor = [UIColor clearColor];
        _mainTableView.separatorStyle = UITableViewCellSeparatorStyleNone;
        [_mainTableView registerClass:[HDMyIncomsTableViewCell class] forCellReuseIdentifier:NSStringFromClass([HDMyIncomsTableViewCell class])];
    }
    return _mainTableView;
}

@end
