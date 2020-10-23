//
//  HDTaskSubAllListViewController.m
//  HairDress
//
//  Created by Apple on 2020/1/20.
//  Copyright © 2020 zhangkaizhong. All rights reserved.
//

#import "HDTaskSubAllListViewController.h"

#import "HDTaskListTableViewCell.h"
#import "HDTaskDetailViewController.h"

@interface HDTaskSubAllListViewController ()<UITableViewDelegate,UITableViewDataSource>

@property (nonatomic,assign) NSInteger page;

//任务列表数据
@property (nonatomic,strong) NSMutableArray *arrData;

@end

@implementation HDTaskSubAllListViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = RGBBG;
    UIView *line = [[UIView alloc] initWithFrame:CGRectMake(0, 0, kSCREEN_WIDTH, 1)];
    [self.view addSubview:line];
    line.backgroundColor = RGBBG;
    
    self.arrData = [NSMutableArray new];
    self.page = 1;
    
    [self.view addSubview:self.mainTableView];
    
    [self setupRefresh];
    
    [self getTaskListData:NO];
}

-(void)setupRefresh{
    self.mainTableView.mj_header = [MJRefreshNormalHeader headerWithRefreshingTarget:self refreshingAction:@selector(loadNewData)];
    self.mainTableView.mj_footer = [MJRefreshBackNormalFooter footerWithRefreshingTarget:self refreshingAction:@selector(loadMoreData)];
}

//下拉刷新数据
-(void)loadNewData{
    [self.mainTableView.mj_footer endRefreshing];
    self.page = 1;
    [self getTaskListData:NO];
}

//上提加载更多
-(void)loadMoreData{
    [self.mainTableView.mj_header endRefreshing];
    self.page ++;
    [self getTaskListData:YES];
}

//重新刷新
-(void)tapEmptyAction:(UIGestureRecognizer *)gestur{
    [super tapEmptyAction:gestur];
    [self loadNewData];
}

#pragma mark ================== 数据请求 =====================
//任务列表
-(void)getTaskListData:(BOOL)more{
    NSDictionary *params = @{
        @"page":@{
                @"pageIndex":@(self.page),
                @"pageSize":@(20)
        },
        @"taskType":self.taskType
    };
    WeakSelf;
    [MHNetworkManager postReqeustWithURL:URL_TaskQueryAppTaskList params:params successBlock:^(NSDictionary *returnData) {
        
        returnData = [HDToolHelper nullDicToDic:returnData];
        if ([returnData[@"respCode"] integerValue] == 200) {
            if (more) {
                [self.mainTableView.mj_footer endRefreshing];
            }else{
                [self.arrData removeAllObjects];
            }
            NSArray *arr = [HDTaskListModel mj_objectArrayWithKeyValuesArray:returnData[@"data"]];
            if (more && arr.count == 0) {
                weakSelf.page --;
            }
            [self.arrData addObjectsFromArray:arr];
            [self.mainTableView reloadData];
            if (arr.count == 0) {
                [self.mainTableView.mj_footer endRefreshingWithNoMoreData];
            }
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
            }
        }
    } failureBlock:^(NSError *error) {
        if (more) {
            self.page --;
            [self.mainTableView.mj_footer endRefreshing];
        }
    } showHUD:!more];
}

#pragma mark ================== tavleView delegate datasource =====================
-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    HDTaskListModel *model = self.arrData[indexPath.row];
    return model.cellHeight;
}

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return self.arrData.count;
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    HDTaskListTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:NSStringFromClass([HDTaskListTableViewCell class])];
    cell.model = self.arrData[indexPath.row];
    return cell;
}

//详情
-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    HDTaskListModel *model = self.arrData[indexPath.row];
    HDTaskDetailViewController *detailVC = [HDTaskDetailViewController new];
    detailVC.taskId = model.taskId;
    [self.navigationController pushViewController:detailVC animated:YES];
}

#pragma mark ================== UI =====================
-(UITableView *)mainTableView{
    if (!_mainTableView) {
        _mainTableView = [[UITableView alloc] initWithFrame:CGRectMake(0, 1, kSCREEN_WIDTH, kSCREEN_HEIGHT-NAVHIGHT-49-KTarbarHeight) style:UITableViewStylePlain];
        _mainTableView.delegate = self;
        _mainTableView.dataSource = self;
        _mainTableView.separatorStyle = UITableViewCellSeparatorStyleNone;
        [_mainTableView registerClass:[HDTaskListTableViewCell class] forCellReuseIdentifier:NSStringFromClass([HDTaskListTableViewCell class])];
    }
    return _mainTableView;
}

@end
