//
//  HDTaskSubAllListViewController.m
//  HairDress
//
//  Created by Apple on 2020/1/20.
//  Copyright © 2020 zhangkaizhong. All rights reserved.
//

#import "HDMyTaskListSubViewController.h"

#import "HDMyTaskListTableViewCell.h"

#import "HDTaskCompletingViewController.h"
#import "HDMyTaskDetailInfoViewController.h"

@interface HDMyTaskListSubViewController ()<UITableViewDelegate,UITableViewDataSource>

@property (nonatomic,assign) NSInteger page;
@property (nonatomic,strong) UITableView *mainTableView;
//任务列表数据
@property (nonatomic,strong) NSMutableArray *arrData;
//定时器
@property(nonatomic,strong)NSTimer *timer;

@end

@implementation HDMyTaskListSubViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.arrData = [NSMutableArray new];
    self.page = 1;
    
    UIView *viewLine = [[UIView alloc] initWithFrame:CGRectMake(0, 0, kSCREEN_WIDTH, 1)];
    viewLine.backgroundColor = RGBCOLOR(210, 210, 210);
    [self.view addSubview:viewLine];
    [self.view addSubview:self.mainTableView];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(reloadListAction:) name:@"reloadMyTaskList" object:nil];
    
    [self setupRefresh];
    [self getTaskListData:NO];
}

- (void)dealloc{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    DTLog(@"%s",__FUNCTION__);
}

#pragma mark - 添加刷新控件
-(void)setupRefresh{
    self.mainTableView.mj_footer = [MJRefreshBackNormalFooter footerWithRefreshingTarget:self refreshingAction:@selector(loadMoreData)];
}

//重新刷新列表
-(void)reloadListAction:(NSNotification *)sender{
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
    [self getTaskListData:NO];
}

#pragma mark ================== 数据请求 =====================
//任务列表
-(void)getTaskListData:(BOOL)more{
    if (!self.checkStatus) {
        self.checkStatus = @"";
    }
    NSDictionary *params = @{
        @"page":@{
                @"pageIndex":@(self.page),
                @"pageSize":@(20)
        },
        @"checkStatus":self.checkStatus,
        @"memberId":[HDUserDefaultMethods getData:@"userId"]
    };
    [MHNetworkManager postReqeustWithURL:URL_TaskQueryUserTaskList params:params successBlock:^(NSDictionary *returnData) {
        
        returnData = [HDToolHelper nullDicToDic:returnData];
        if ([returnData[@"respCode"] integerValue] == 200) {
            if (more) {
                [self.mainTableView.mj_footer endRefreshing];
            }else{
                [self.arrData removeAllObjects];
            }
            NSArray *arr = [HDMyTaskListModel mj_objectArrayWithKeyValuesArray:returnData[@"data"]];
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
                self.page --;
                [self.mainTableView.mj_footer endRefreshing];
            }
        }
    } failureBlock:^(NSError *error) {
        if (more) {
            self.page --;
            [self.mainTableView.mj_footer endRefreshing];
        }
    } showHUD:YES];
}

#pragma mark ================== tavleView delegate datasource =====================
-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    return 105+9*SCALE;
}

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return self.arrData.count;
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    HDMyTaskListTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:NSStringFromClass([HDMyTaskListTableViewCell class])];
    [cell setSecond:self.arrData[indexPath.row] row:indexPath.row];
    return cell;
}

- (void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath{
    HDMyTaskListTableViewCell *timeCell = (HDMyTaskListTableViewCell *)cell;
    [timeCell setSecond:self.arrData[indexPath.row] row:indexPath.row];
}

//详情
-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    HDMyTaskListModel *model = self.arrData[indexPath.row];
    HDMyTaskDetailInfoViewController *detailVC = [HDMyTaskDetailInfoViewController new];
    detailVC.memberTaskId = model.memberTaskId;
    [self.navigationController pushViewController:detailVC animated:YES];
}

#pragma mark ================== UI =====================
-(UITableView *)mainTableView{
    if (!_mainTableView) {
        _mainTableView = [[UITableView alloc] initWithFrame:CGRectMake(0, 1, kSCREEN_WIDTH-24*SCALE, kSCREEN_HEIGHT-NAVHIGHT-49-12*SCALE-8*SCALE-8*SCALE) style:UITableViewStylePlain];
        _mainTableView.delegate = self;
        _mainTableView.dataSource = self;
        _mainTableView.separatorStyle = UITableViewCellSeparatorStyleNone;
        [_mainTableView registerClass:[HDMyTaskListTableViewCell class] forCellReuseIdentifier:NSStringFromClass([HDMyTaskListTableViewCell class])];
    }
    return _mainTableView;
}

@end
