//
//  HDSearchShopsViewController.m
//  HairDress
//
//  Created by 张凯中 on 2019/12/21.
//  Copyright © 2019 zhangkaizhong. All rights reserved.
//

#import "HDServiceEvaluateViewController.h"

#import "HDServiceEvaTableViewCell.h"
#import "UITableView+FDTemplateLayoutCell.h"
#import "HDEvaluateModel.h"

#define Cell_ID @"CellForServiceEva"

@interface HDServiceEvaluateViewController ()<UITableViewDelegate,UITableViewDataSource>

@property (nonatomic,assign) NSInteger page;
@property (nonatomic,strong) UITableView *tableView;
@property (nonatomic,strong) NSMutableArray *dataArray;
@property (nonatomic,strong) UIView *headerView;

@property (nonatomic,weak) UILabel *lblCountTotal;
@property (nonatomic,weak) UILabel *lblEvaScore;

@end

@implementation HDServiceEvaluateViewController


- (void)viewDidLoad{
    [super viewDidLoad];
    
    [self initUI];
    
    self.dataArray = [NSMutableArray new];
    self.page = 1;
    
    [self setupRefresh];
    
    //获取评价统计
    [self getCountTonyEvaRequest];
    
    [self getEvaListData:NO];
}

#pragma mark - 添加刷新控件
-(void)setupRefresh{
    self.tableView.mj_footer = [MJRefreshBackNormalFooter footerWithRefreshingTarget:self refreshingAction:@selector(loadMoreData)];
}

//上提加载更多
-(void)loadMoreData{
    self.page ++;
    [self getEvaListData:YES];
}

#pragma mark ================== 获取数据 =====================
-(void)getCountTonyEvaRequest{
    [MHNetworkManager postReqeustWithURL:URL_CountTonyEvaluate params:@{@"tonyId":self.tonyId} successBlock:^(NSDictionary *returnData) {
        DTLog(@"%@",returnData);
        if ([returnData[@"respCode"] integerValue] == 200) {
            self.lblCountTotal.text = [NSString stringWithFormat:@"%ld",(long)[returnData[@"data"][@"allNum"] integerValue]];
            self.lblEvaScore.text = [NSString stringWithFormat:@"%.2f",[returnData[@"data"][@"score"] floatValue]];
        }
    } failureBlock:^(NSError *error) {
        
    } showHUD:NO];
}

//获取评价统计列表
-(void)getEvaListData:(BOOL)more{
    NSDictionary *params = @{
        @"tonyId": self.tonyId,
        @"page":@{@"pageIndex":@(self.page),@"pageSize":@"10"},
    };
    WeakSelf;
    [MHNetworkManager postReqeustWithURL:URL_EvaluateList params:params successBlock:^(NSDictionary *returnData) {
        DTLog(@"%@",returnData);
        
        if ([returnData[@"respCode"] integerValue] == 200) {
            if (!more) {
                [self.dataArray removeAllObjects];
            }else{
                [self.tableView.mj_footer endRefreshing];
            }
            NSArray *arr = [HDEvaluateModel mj_objectArrayWithKeyValuesArray:returnData[@"data"]];
            if (more && arr.count == 0) {
                weakSelf.page --;
            }
            [self.dataArray addObjectsFromArray:arr];
            [self.tableView reloadData];
            if (arr.count == 0) {
                [self.tableView.mj_footer endRefreshingWithNoMoreData];
            }
        }else{
            if (more) {
                self.page --;
                [self.tableView.mj_footer endRefreshing];
            }
        }
    } failureBlock:^(NSError *error) {
        if (more) {
            self.page --;
            [self.tableView.mj_footer endRefreshing];
        }
    } showHUD:NO];
}

#pragma mark ================== 创建UI =====================
- (void)initUI{
    self.tableView = [[UITableView alloc] initWithFrame:CGRectMake(0, 1, kSCREEN_WIDTH, kSCREEN_HEIGHT-NAVHIGHT-49-KTarbarHeight-8) style:UITableViewStyleGrouped];
    self.tableView.delegate   = self;
    self.tableView.dataSource = self;
    self.tableView.backgroundColor = RGBBG;
    self.tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    [self.view addSubview:self.tableView];
    
    [self.tableView registerClass:[HDServiceEvaTableViewCell class] forCellReuseIdentifier:Cell_ID];
    
    self.tableView.tableHeaderView = self.headerView;
}


#pragma mark - Lazy Load
- (NSMutableArray *)dataArray{
    if (!_dataArray) {
        _dataArray = [NSMutableArray array];
    }
    return _dataArray;
}


#pragma mark - UITableViewDataSource

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return self.dataArray.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:Cell_ID];
    
    HDEvaluateModel *model  = self.dataArray[indexPath.row];
    
    HDServiceEvaTableViewCell  *cell1 = nil;//原创
    cell1 = (HDServiceEvaTableViewCell *)cell;
    cell1.model = model;
//    cell1.delegate = self;
    return cell1;
}

#pragma mark - UITableViewDelegate

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    return [self.tableView fd_heightForCellWithIdentifier:Cell_ID configuration:^(HDServiceEvaTableViewCell *cell) {
        [self configureOriCell:cell atIndexPath:indexPath];
    }];
}

- (void)configureOriCell:(HDServiceEvaTableViewCell *)cell atIndexPath:(NSIndexPath *)indexPath{
    cell.fd_enforceFrameLayout = NO; // Enable to use "-sizeThatFits:"
    if (indexPath.row < _dataArray.count) {
        cell.model = _dataArray[indexPath.row];
    }
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    NSLog(@"%ld",(long)indexPath.item);
}

-(UIView *)headerView{
    if (!_headerView) {
        _headerView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, kSCREEN_WIDTH, 86)];
        _headerView.backgroundColor = [UIColor whiteColor];
        
        UIView *line1 = [[UIView alloc] initWithFrame:CGRectMake(kSCREEN_WIDTH/2, 0, 1, 48)];
        line1.centerY = 86/2;
        line1.backgroundColor = RGBLINE;
        [_headerView addSubview:line1];
        
        UIView *line2 = [[UIView alloc] initWithFrame:CGRectMake(0, 0, kSCREEN_WIDTH, 1)];
        line2.backgroundColor = RGBLINE;
        [_headerView addSubview:line2];
        
        UIView *line3 = [[UIView alloc] initWithFrame:CGRectMake(0, 85, kSCREEN_WIDTH, 1)];
        line3.backgroundColor = RGBLINE;
        [_headerView addSubview:line3];
        
        UIView *viewScore = [[UIView alloc] initWithFrame:CGRectMake(0, 0, kSCREEN_WIDTH/2, 86)];
        [_headerView addSubview:viewScore];
        
        UILabel *lblScroeNum = [[UILabel alloc] initCommonWithFrame:CGRectMake(0, 24, kSCREEN_WIDTH/2, 20) title:@"暂无" bgColor:[UIColor clearColor] titleColor:[UIColor blackColor] titleFont:20 textAlignment:NSTextAlignmentCenter isFit:NO];
        self.lblEvaScore = lblScroeNum;
        [viewScore addSubview:lblScroeNum];
        UILabel *lblScroe = [[UILabel alloc] initCommonWithFrame:CGRectMake(0, CGRectGetMaxY(lblScroeNum.frame)+9, kSCREEN_WIDTH/2, 12) title:@"评分" bgColor:[UIColor clearColor] titleColor:RGBTEXTINFO titleFont:12 textAlignment:NSTextAlignmentCenter isFit:NO];
        [viewScore addSubview:lblScroe];
        
        UIView *viewComment = [[UIView alloc] initWithFrame:CGRectMake(kSCREEN_WIDTH/2, 0, kSCREEN_WIDTH/2, 86)];
        [_headerView addSubview:viewComment];
        
        UILabel *lblCommentNum = [[UILabel alloc] initCommonWithFrame:CGRectMake(0, 24, kSCREEN_WIDTH/2, 20) title:@"0" bgColor:[UIColor clearColor] titleColor:[UIColor blackColor] titleFont:20 textAlignment:NSTextAlignmentCenter isFit:NO];
        [viewComment addSubview:lblCommentNum];
        self.lblCountTotal = lblCommentNum;
        UILabel *lblComment = [[UILabel alloc] initCommonWithFrame:CGRectMake(0, CGRectGetMaxY(lblScroeNum.frame)+9, kSCREEN_WIDTH/2, 12) title:@"评论数" bgColor:[UIColor clearColor] titleColor:RGBTEXTINFO titleFont:12 textAlignment:NSTextAlignmentCenter isFit:NO];
        [viewComment addSubview:lblComment];
    }
    return _headerView;
}


@end
