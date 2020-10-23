//
//  HDMyTeamsViewController.m
//  HairDress
//
//  Created by 张凯中 on 2019/12/30.
//  Copyright © 2019 zhangkaizhong. All rights reserved.
//

#import "HDMyTeamsViewController.h"

#import "HDMyTeamsTableViewCell.h"
#import "HDMyTeamFansNumModel.h"

@interface HDMyTeamsViewController ()<navViewDelegate,UITableViewDelegate,UITableViewDataSource,UITextFieldDelegate>

@property (nonatomic,strong) HDBaseNavView *navView;
@property (nonatomic,strong) UITableView *mainTableView;
@property (nonatomic,strong) UIView *redView;

@property (nonatomic,assign) NSInteger page;
@property (nonatomic,strong) NSMutableArray *arrData;
@property (nonatomic,strong) HDMyTeamFansNumModel *fansModel;

@property (nonatomic,copy) NSString *dateFlagStr;

@property (nonatomic,weak) UILabel *lblFansCount;//粉丝数
@property (nonatomic,weak) UILabel *lblTodayFans;//今日新增粉丝
@property (nonatomic,weak) UILabel *lblMonthFans;//本月新增粉丝

@end

@implementation HDMyTeamsViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.page = 1;
    self.dateFlagStr = @"";
    self.arrData = [NSMutableArray new];
    
    self.view.backgroundColor = RGBBG;
    [self.view addSubview:self.navView];
    [self.view addSubview:self.redView];
    [self.view addSubview:self.mainTableView];
    
    [self getFansInfos];
    
    [self setupRefresh];
    [self getFansListData:NO];
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
    [self getFansListData:NO];
}

//上提加载更多
-(void)loadMoreData{
    [self.mainTableView.mj_header endRefreshing];
    self.page ++;
    [self getFansListData:YES];
}

#pragma mark -- 数据请求
//查询粉丝数据
-(void)getFansInfos{
    [MHNetworkManager postReqeustWithURL:URL_FansNumAndFatherName params:@{@"id":[HDUserDefaultMethods getData:@"userId"]} successBlock:^(NSDictionary *returnData) {
        if ([returnData[@"respCode"] integerValue] == 200) {
            NSDictionary *dic = [HDToolHelper nullDicToDic:returnData[@"data"]];
            self.fansModel = [HDMyTeamFansNumModel mj_objectWithKeyValues:dic];
            self.lblFansCount.text = [NSString stringWithFormat:@"%ld",(long)[self.fansModel.num integerValue]];
            self.lblMonthFans.text = [NSString stringWithFormat:@"%ld",(long)[self.fansModel.monthAddNum integerValue]];
            self.lblTodayFans.text = [NSString stringWithFormat:@"%ld",(long)[self.fansModel.todayAddNum integerValue]];
        }
    } failureBlock:^(NSError *error) {
        
    } showHUD:YES];
}

//分页查询全部粉丝
-(void)getFansListData:(BOOL)more{
    NSDictionary *params = @{
        @"page":@{
                @"pageIndex":@(self.page),
                @"pageSize":@(20)
        },
        @"dateFlag":self.dateFlagStr,
        @"userName":self.navView.txtSearch.text,
        @"id":[HDUserDefaultMethods getData:@"userId"]
    };
    WeakSelf;
    [MHNetworkManager postReqeustWithURL:URL_FansQueryTotalTeamFans params:params successBlock:^(NSDictionary *returnData) {
        if ([returnData[@"respCode"] integerValue] == 200) {
            if (more) {
                [self.mainTableView.mj_footer endRefreshing];
            }else{
                [self.arrData removeAllObjects];
                [self.mainTableView.mj_header endRefreshing];
            }
            
            NSArray *arr = returnData[@"data"];
            if (more && arr.count == 0) {
                weakSelf.page --;
            }
            [self.arrData addObjectsFromArray:arr];
            [self.mainTableView reloadData];
            if (arr.count == 0) {
                [self.mainTableView.mj_footer endRefreshingWithNoMoreData];
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

#pragma mark -- delegate action

-(void)navBackClicked{
    [self.navigationController popViewControllerAnimated:YES];
}

#pragma mark -- tableview delegate datasource

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return self.arrData.count;
}

-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    return 53;
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    HDMyTeamsTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:NSStringFromClass([HDMyTeamsTableViewCell class]) forIndexPath:indexPath];
    cell.dic = self.arrData[indexPath.row];
    return cell;
}

#pragma mark ================== 加载控件 =====================

-(UIView *)redView{
    if (!_redView) {
        _redView = [[UIView alloc] initWithFrame:CGRectMake(0, NAVHIGHT, kSCREEN_WIDTH, 76)];
        _redView.backgroundColor = RGBMAIN;
        
        // 粉丝总数
        UILabel *lblFansCount = [[UILabel alloc] initCommonWithFrame:CGRectMake(0, 24, kSCREEN_WIDTH/3, 16) title:@"0" bgColor:[UIColor clearColor] titleColor:[UIColor whiteColor] titleFont:16 textAlignment:NSTextAlignmentCenter isFit:NO];
        [_redView addSubview:lblFansCount];
        self.lblFansCount = lblFansCount;
        
        UILabel *lblFansCountText = [[UILabel alloc] initCommonWithFrame:CGRectMake(0, lblFansCount.bottom+8, lblFansCount.width, 12) title:@"粉丝总数" bgColor:[UIColor clearColor] titleColor:[UIColor whiteColor] titleFont:12 textAlignment:NSTextAlignmentCenter isFit:NO];
        [_redView addSubview:lblFansCountText];
        
        // 今日新增粉丝
        UILabel *lblTodayFans = [[UILabel alloc] initCommonWithFrame:CGRectMake(_redView.width/3, 24, _redView.width/3, 16) title:@"0" bgColor:[UIColor clearColor] titleColor:[UIColor whiteColor] titleFont:16 textAlignment:NSTextAlignmentCenter isFit:NO];
        [_redView addSubview:lblTodayFans];
        self.lblTodayFans = lblTodayFans;
        
        UILabel *lblTodayFansText = [[UILabel alloc] initCommonWithFrame:CGRectMake(lblTodayFans.x, lblTodayFans.bottom+8, lblTodayFans.width, 12) title:@"今日新增粉丝" bgColor:[UIColor clearColor] titleColor:[UIColor whiteColor] titleFont:12 textAlignment:NSTextAlignmentCenter isFit:NO];
        [_redView addSubview:lblTodayFansText];
        
        // 本月新增粉丝
        UILabel *lblMonthFans = [[UILabel alloc] initCommonWithFrame:CGRectMake(_redView.width/3*2, 24, _redView.width/3, 16) title:@"0" bgColor:[UIColor clearColor] titleColor:[UIColor whiteColor] titleFont:16 textAlignment:NSTextAlignmentCenter isFit:NO];
        [_redView addSubview:lblMonthFans];
        self.lblMonthFans = lblMonthFans;
        
        UILabel *lblMonthFansText = [[UILabel alloc] initCommonWithFrame:CGRectMake(lblMonthFans.x, lblMonthFans.bottom+8, lblMonthFans.width, 12) title:@"本月新增粉丝" bgColor:[UIColor clearColor] titleColor:[UIColor whiteColor] titleFont:12 textAlignment:NSTextAlignmentCenter isFit:NO];
        [_redView addSubview:lblMonthFansText];
    }
    return _redView;
}

-(UITableView *)mainTableView{
    if (!_mainTableView) {
        _mainTableView = [[UITableView alloc] initWithFrame:CGRectMake(0, _redView.bottom+8, kSCREEN_WIDTH, kSCREEN_HEIGHT-NAVHIGHT-_redView.height-8) style:UITableViewStylePlain];
        _mainTableView.delegate = self;
        _mainTableView.dataSource = self;
        _mainTableView.backgroundColor = [UIColor clearColor];
        [_mainTableView registerClass:[HDMyTeamsTableViewCell class] forCellReuseIdentifier:NSStringFromClass([HDMyTeamsTableViewCell class])];
        _mainTableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    }
    return _mainTableView;
}

-(HDBaseNavView *)navView{
    if (!_navView) {
        _navView = [[HDBaseNavView alloc] initSearchBarWithButtonsFrame:CGRectMake(0, 0, kSCREEN_WIDTH, NAVHIGHT) bgColor:RGBMAIN textColor:[UIColor clearColor] searchViewColor:RGBAlpha(246, 246, 246, 0.32) btnTitle:@"" placeHolder:@"搜索粉丝用户名" theDelegate:self];
        _navView.txtSearch.textColor = [UIColor whiteColor];
        _navView.txtSearch.tintColor = [UIColor whiteColor];
        _navView.txtSearch.returnKeyType = UIReturnKeySearch;
        _navView.txtSearch.delegate = self;
        [_navView.txtSearch addTarget:self action:@selector(textFieldDidChange:)forControlEvents:UIControlEventEditingChanged];
    }
    return _navView;
}

-(BOOL)textFieldShouldReturn:(UITextField *)textField{
    //搜索
    self.page = 1;
    self.dateFlagStr = @"";
    [self getFansListData:NO];
    return YES;
}

-(void)textFieldDidChange:(UITextField *)sender{
    //搜索
    self.page = 1;
    self.dateFlagStr = @"";
    [self getFansListData:NO];
}

@end
