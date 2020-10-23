//
//  HDSearchCutterViewController.m
//  HairDress
//
//  Created by 张凯中 on 2019/12/21.
//  Copyright © 2019 zhangkaizhong. All rights reserved.
//

#import "HDSearchCutterViewController.h"

#import "HDCutterTableViewCell.h"
#import "HDCutterDetailViewController.h"
#import "HDGetCutNumberViewController.h"

@interface HDSearchCutterViewController ()<UITableViewDataSource,UITableViewDelegate,HDCutterTableViewCellDelegate>

@property (nonatomic,assign) NSInteger page;
@property (nonatomic,strong) NSMutableArray *arrData;
@property (nonatomic,strong) UITableView *mainTableView;

@end

@implementation HDSearchCutterViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    UIView *line = [[UIView alloc] initWithFrame:CGRectMake(0, 0, kSCREEN_WIDTH, 1)];
    line.backgroundColor = RGBAlpha(239, 239, 239, 1);
    [self.view addSubview:line];
    
//    self.view.backgroundColor = RGBBG;
    self.arrData = [NSMutableArray new];
    [self.view addSubview:self.mainTableView];
}

#pragma mark - 添加刷新控件
-(void)setupRefresh{
    self.mainTableView.mj_header = [MJRefreshNormalHeader headerWithRefreshingTarget:self refreshingAction:@selector(loadNewData)];
    self.mainTableView.mj_footer = [MJRefreshBackNormalFooter footerWithRefreshingTarget:self refreshingAction:@selector(loadMoreData)];
    
    [self loadNewData];
}

//下拉刷新数据
-(void)loadNewData{
    [self.mainTableView.mj_footer endRefreshing];
    self.page = 1;
    [self requestCutterList:NO];
}

//上提加载更多
-(void)loadMoreData{
    [self.mainTableView.mj_header endRefreshing];
    self.page ++;
    [self requestCutterList:YES];
}

#pragma mark ================== 取号 =====================
-(void)clickGenumAction:(HDShopCutterListModel *)model{
    HDGetCutNumberViewController *getVC = [HDGetCutNumberViewController new];
    getVC.cutter_id = model.tonyId;
    [self.navigationController pushViewController:getVC animated:YES];
}

#pragma mark ================== 请求发型师列表 =====================
-(void)requestCutterList:(BOOL)more{
    NSDictionary *dic = @{
        @"areaId":self.tradeStr,
        @"configValue":self.serviceStr,
        @"sort":self.sortStr,
        @"searchName":self.searchName,
        @"page":@{@"pageIndex":@(self.page),@"pageSize":@"20"},
        @"location":[NSString stringWithFormat:@"%@,%@",[HDUserDefaultMethods getData:@"userLat"],[HDUserDefaultMethods getData:@"userLong"]]
    };
    WeakSelf;
    [MHNetworkManager postReqeustWithURL:URL_TonyList params:dic successBlock:^(NSDictionary *returnData) {
        DTLog(@"%@",returnData);
        
        if ([returnData[@"respCode"] integerValue] == 200) {
            if (more) {
                [weakSelf.mainTableView.mj_footer endRefreshing];
            }else{
                [self.arrData removeAllObjects];
                [weakSelf.mainTableView.mj_header endRefreshing];
            }
            NSArray *arr = [HDShopCutterListModel mj_objectArrayWithKeyValuesArray:returnData[@"data"]];
            if (more && arr.count == 0) {
                weakSelf.page --;
            }
            for (HDShopCutterListModel *model in arr) {
                model.isDetail = @"1";
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

#pragma mark -- tableview delegate \ action

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    HDCutterTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"cuttercell" forIndexPath:indexPath];
    cell.delegate = self;
    cell.model = self.arrData[indexPath.row];
    return cell;
}

-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    HDShopCutterListModel *model = self.arrData[indexPath.row];
    return model.cellHeight;
}

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return self.arrData.count;
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    HDShopCutterListModel *model = self.arrData[indexPath.row];
    HDCutterDetailViewController *detailVC = [HDCutterDetailViewController new];
    detailVC.cutter_id = model.tonyId;
    [self.navigationController pushViewController:detailVC animated:YES];
}


#pragma mark -- 加载控件

-(UITableView *)mainTableView{
    if (!_mainTableView) {
        _mainTableView = [[UITableView alloc] initWithFrame:CGRectMake(0, 1, kSCREEN_WIDTH, kSCREEN_HEIGHT-NAVHIGHT-48-49) style:UITableViewStylePlain];
        _mainTableView.backgroundColor = [UIColor clearColor];
        _mainTableView.delegate = self;
        _mainTableView.dataSource = self;
        _mainTableView.separatorStyle = UITableViewCellSeparatorStyleNone;
        [_mainTableView registerClass:[HDCutterTableViewCell class] forCellReuseIdentifier:@"cuttercell"];
    }
    return _mainTableView;
}


@end
