//
//  HDMyWithdrawRecordsViewController.m
//  HairDress
//
//  Created by 张凯中 on 2020/2/14.
//  Copyright © 2020 zhangkaizhong. All rights reserved.
//

#import "HDMyWithdrawRecordsViewController.h"

#import "HDMyWithdrawRecordsTableViewCell.h"

@interface HDMyWithdrawRecordsViewController ()<navViewDelegate,UITableViewDelegate,UITableViewDataSource>

@property (nonatomic,strong) HDBaseNavView *navView;
@property (nonatomic,strong) UITableView *mainTableView;
@property (nonatomic,strong) NSMutableArray *dataArr;
@property (nonatomic,assign) NSInteger page;

@end

@implementation HDMyWithdrawRecordsViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.dataArr = [NSMutableArray new];
    self.page = 1;
    
    self.view.backgroundColor = RGBBG;
    [self.view addSubview:self.navView];
    [self.view addSubview:self.mainTableView];
    
    [self getWithdrewReacordsData:NO];
    
    [self setupRefresh];
}

#pragma mark -- delegate action
-(void)navBackClicked{
    [self.navigationController popViewControllerAnimated:YES];
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
    [self getWithdrewReacordsData:NO];
}

//上提加载更多
-(void)loadMoreData{
    [self.mainTableView.mj_header endRefreshing];
    self.page ++;
    [self getWithdrewReacordsData:YES];
}

#pragma mark -- 数据请求
//获取提现记录
-(void)getWithdrewReacordsData:(BOOL)more{
    NSDictionary *params = @{
        @"page":@{
                @"pageIndex":@(self.page),
                @"pageSize":@(20)
        },
        @"userId":[HDUserDefaultMethods getData:@"userId"]
    };
    WeakSelf;
    [MHNetworkManager postReqeustWithURL:URL_MemberWithdrawAppList params:params successBlock:^(NSDictionary *returnData) {
        DTLog(@"%@",returnData);
        
        if ([returnData[@"respCode"] integerValue] == 200) {
            if (more) {
                [weakSelf.mainTableView.mj_footer endRefreshing];
            }else{
                [self.dataArr removeAllObjects];
                [weakSelf.mainTableView.mj_header endRefreshing];
            }
            NSArray *arr = [HDWithdrewRecordModel mj_objectArrayWithKeyValuesArray:returnData[@"data"]];
            if (more && arr.count == 0) {
                weakSelf.page --;
            }
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
    return self.dataArr.count;
}

-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    return 132;
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    HDMyWithdrawRecordsTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:NSStringFromClass([HDMyWithdrawRecordsTableViewCell class]) forIndexPath:indexPath];
    cell.model = self.dataArr[indexPath.row];
    return cell;
}

#pragma mark -- UI
-(UITableView *)mainTableView{
    if (!_mainTableView) {
        _mainTableView = [[UITableView alloc] initWithFrame:CGRectMake(0, NAVHIGHT, kSCREEN_WIDTH, kSCREEN_HEIGHT-NAVHIGHT) style:UITableViewStylePlain];
        _mainTableView.delegate = self;
        _mainTableView.dataSource = self;
        _mainTableView.backgroundColor = [UIColor clearColor];
        [_mainTableView registerClass:[HDMyWithdrawRecordsTableViewCell class] forCellReuseIdentifier:NSStringFromClass([HDMyWithdrawRecordsTableViewCell class])];
        _mainTableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    }
    return _mainTableView;
}

-(HDBaseNavView *)navView{
    if (!_navView) {
        _navView = [[HDBaseNavView alloc] initWithFrame:CGRectMake(0, 0, kSCREEN_WIDTH, NAVHIGHT) title:@"提现记录" bgColor:RGBMAIN backBtn:YES rightBtn:@"" rightBtnImage:@"" theDelegate:self];
    }
    return _navView;
}

@end
