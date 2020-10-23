//
//  HDTinyResumeViewController.m
//  HairDress
//
//  Created by Apple on 2019/12/27.
//  Copyright © 2019 zhangkaizhong. All rights reserved.
//

#import "HDTinyResumeViewController.h"

#import "HDTinyMyShowsViewController.h"
#import "HDAddCutExpirenceViewController.h"
#import "HDTinyResumeTableViewCell.h"

@interface HDTinyResumeViewController ()<navViewDelegate,HDAddCutExpirenceDelegate,UITableViewDelegate,UITableViewDataSource>

@property (nonatomic,strong) HDBaseNavView *navView;
@property (nonatomic,strong) UITableView *mainTableView;

@property (nonatomic,strong) NSMutableArray * arrData;  // 数据源

@end

@implementation HDTinyResumeViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.arrData = [NSMutableArray new];
    
    [self.view addSubview:self.navView];
    [self.view addSubview:self.mainTableView];
    
    [self getExpListRequest];
    [self setupRefresh];
}

#pragma mark - 添加刷新控件
-(void)setupRefresh{
    self.mainTableView.mj_header = [MJRefreshNormalHeader headerWithRefreshingTarget:self refreshingAction:@selector(loadNewData)];
}

//下拉刷新数据
-(void)loadNewData{
    [self getExpListRequest];
}

#pragma mark ================== 获取剪发经验列表数据=====================
-(void)getExpListRequest{
    NSDictionary *params = @{
        @"page":@{
                @"pageIndex":@(1),
                @"pageSize":@(1000)
        },
        @"tonyId":[HDUserDefaultMethods getData:@"userId"],
    };
    [MHNetworkManager postReqeustWithURL:URL_TonyExpManageList params:params successBlock:^(NSDictionary *returnData) {
        [self.mainTableView.mj_header endRefreshing];
        if ([returnData[@"respCode"] integerValue] == 200) {
            [self.arrData removeAllObjects];
            NSArray *arr = [HDCutterResumeExpModel mj_objectArrayWithKeyValuesArray:returnData[@"data"]];
            [self.arrData addObjectsFromArray:arr];
            [self.mainTableView reloadData];
        }else{
            [SVHUDHelper showInfoWithTimestamp:1 msg:returnData[@"respMsg"]];
        }
    } failureBlock:^(NSError *error) {
        [self.mainTableView.mj_header endRefreshing];
    } showHUD:YES];
}

#pragma mark -- delegate / action

-(void)navBackClicked{
    [self.navigationController popViewControllerAnimated:YES];
}

// 作品集
-(void)tapShowsAction:(UIGestureRecognizer *)sender{
    HDTinyMyShowsViewController *showsVc = [[HDTinyMyShowsViewController alloc] init];
    [self.navigationController pushViewController:showsVc animated:YES];
}

// 添加剪发经验
-(void)btnAddExpierenceAction{
    HDAddCutExpirenceViewController *cutVC = [HDAddCutExpirenceViewController new];
    cutVC.delegate = self;
    [self.navigationController pushViewController:cutVC animated:YES];
}

//添加删除成功后回调
-(void)addCutExpActionDelegate{
    [self getExpListRequest];
}

#pragma mark ================== tableView delegate datasource =====================

-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
    return 1;
}

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return self.arrData.count;
}

//行高
-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    HDCutterResumeExpModel *model = self.arrData[indexPath.row];
    return model.cellHeight;
}

-(UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section{
    UIView *view = [[UIView alloc] initWithFrame:CGRectMake(0, 0, kSCREEN_WIDTH, 8+16+19)];
    view.backgroundColor = [UIColor whiteColor];
    
    UILabel *lblTitle = [[UILabel alloc] initCommonWithFrame:CGRectMake(16, 19, 150, 16) title:@"剪发经验" bgColor:[UIColor clearColor] titleColor:RGBTEXT titleFont:16 textAlignment:NSTextAlignmentLeft isFit:NO];
    [view addSubview:lblTitle];
    
    UIButton *btnAdd = [[UIButton alloc] initSystemWithFrame:CGRectMake(kSCREEN_WIDTH-16-26, 0, 26, 12) btnTitle:@"添加" btnImage:@"" titleColor:RGBMAIN titleFont:12];
    btnAdd.centerY = lblTitle.centerY;
    [btnAdd addTarget:self action:@selector(btnAddExpierenceAction) forControlEvents:UIControlEventTouchUpInside];
    
    [view addSubview:btnAdd];
    
    return view;
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    HDCutterResumeExpModel *model = self.arrData[indexPath.row];
    HDAddCutExpirenceViewController *cutVC = [HDAddCutExpirenceViewController new];
    cutVC.expId = model.expId;
    cutVC.delegate = self;
    [self.navigationController pushViewController:cutVC animated:YES];
}

-(UIView *)tableView:(UITableView *)tableView viewForFooterInSection:(NSInteger)section{
    UIView *view = [[UIView alloc] initWithFrame:CGRectMake(0, 0, kSCREEN_WIDTH, 81)];
    view.backgroundColor = [UIColor whiteColor];
    
    UIView *line = [[UIView alloc] initWithFrame:CGRectMake(16, 0, kSCREEN_WIDTH-32, 1)];
    line.backgroundColor = RGBCOLOR(241, 241, 241);
    [view addSubview:line];
    
    UILabel *lblTitle = [[UILabel alloc] initCommonWithFrame:CGRectMake(16, 0, 150, 16) title:@"作品集" bgColor:[UIColor clearColor] titleColor:RGBTEXT titleFont:16 textAlignment:NSTextAlignmentLeft isFit:NO];
    [view addSubview:lblTitle];
    lblTitle.centerY = 40;
    
    UIButton *btnGo = [[UIButton alloc] initSystemWithFrame:CGRectMake(kSCREEN_WIDTH-16-24, 0, 24, 24) btnTitle:@"" btnImage:@"" titleColor:RGBMAIN titleFont:0];
    btnGo.centerY = lblTitle.centerY;
    [btnGo setImage:[UIImage imageNamed:@"common_ic_arrow_right_g"] forState:UIControlStateNormal];
    
    [view addSubview:btnGo];
    
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapShowsAction:)];
    view.userInteractionEnabled = YES;
    [view addGestureRecognizer:tap];
    
    return view;
}

// 头高
-(CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section{
    return 8+16+19;
}

// 尾高
-(CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section{
    return 81;
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    HDTinyResumeTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"resumecell" forIndexPath:indexPath];
    cell.model = self.arrData[indexPath.row];
    cell.rowIndex = indexPath.row;
    return cell;
}

#pragma mark ================== 加载控件 =====================

-(UITableView *)mainTableView{
    if (!_mainTableView) {
        _mainTableView = [[UITableView alloc] initWithFrame:CGRectMake(0, NAVHIGHT, kSCREEN_WIDTH, kSCREEN_HEIGHT-NAVHIGHT) style:UITableViewStyleGrouped];
        _mainTableView.delegate = self;
        _mainTableView.dataSource = self;
        _mainTableView.separatorStyle = UITableViewCellSeparatorStyleNone;
        [_mainTableView registerClass:[HDTinyResumeTableViewCell class] forCellReuseIdentifier:@"resumecell"];
    }
    return _mainTableView;
}

-(HDBaseNavView *)navView{
    if (!_navView) {
        _navView = [[HDBaseNavView alloc] initWithFrame:CGRectMake(0, 0, kSCREEN_WIDTH, NAVHIGHT) title:@"微简历" bgColor:RGBMAIN backBtn:YES rightBtn:@"" rightBtnImage:@"" theDelegate:self];
    }
    return _navView;
}

@end
