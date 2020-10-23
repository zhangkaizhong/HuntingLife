//
//  HDMyCutOrderServicesViewController.m
//  HairDress
//
//  Created by 张凯中 on 2019/12/29.
//  Copyright © 2019 zhangkaizhong. All rights reserved.
//

#import "HDMyCollectionsCutterViewController.h"

#import "HDCutterDetailViewController.h"
#import "HDGetCutNumberViewController.h"
#import "HDCutterTableViewCell.h"

@interface HDMyCollectionsCutterViewController ()<UITableViewDelegate,UITableViewDataSource,HDCutterDetailViewDelegate,HDCutterTableViewCellDelegate>

@property (nonatomic,strong) UITableView *mainTableView;
@property (nonatomic,strong) NSMutableArray *arrData;
@property (nonatomic,assign) NSInteger page;

@end

@implementation HDMyCollectionsCutterViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.page = 1;
    self.arrData = [NSMutableArray new];
    self.view.backgroundColor = RGBBG;
    [self.view addSubview:self.mainTableView];
    
    [self setupRefresh];
    [self requestCollectionList:NO];
}

#pragma mark - 添加刷新控件
-(void)setupRefresh{
    self.mainTableView.mj_header = [MJRefreshNormalHeader headerWithRefreshingTarget:self refreshingAction:@selector(loadNewData)];
    self.mainTableView.mj_footer = [MJRefreshBackNormalFooter footerWithRefreshingTarget:self refreshingAction:@selector(loadMoreData)];
}

//取消收藏刷新列表数据
-(void)clickCollectActionRefreshList{
    [self loadNewData];
}

//下拉刷新数据
-(void)loadNewData{
    [self.mainTableView.mj_footer endRefreshing];
    self.page = 1;
    [self requestCollectionList:NO];
    
}

//上提加载更多
-(void)loadMoreData{
    [self.mainTableView.mj_header endRefreshing];
    self.page ++;
    [self requestCollectionList:YES];
}

#pragma mark -- 数据请求
-(void)requestCollectionList:(BOOL)more{
    NSDictionary *params = @{
        @"collectType":self.collectType,
        @"page":@{
                @"pageIndex":@(self.page),
                @"pageSize":@(20)
        },
        @"userId":[HDUserDefaultMethods getData:@"userId"],
        @"location":[NSString stringWithFormat:@"%@,%@",[HDUserDefaultMethods getData:@"userLat"],[HDUserDefaultMethods getData:@"userLong"]]
    };
    WeakSelf;
    [MHNetworkManager postReqeustWithURL:URL_CollectList params:params successBlock:^(NSDictionary *returnData) {
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

#pragma mark -- tableView delegate datasource

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return self.arrData.count;
}

-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    HDShopCutterListModel *model = self.arrData[indexPath.row];
    return model.cellHeight;
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    HDCutterTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:NSStringFromClass([HDCutterTableViewCell class]) forIndexPath:indexPath];
    cell.model = self.arrData[indexPath.row];
    cell.delegate = self;
    return cell;
}

#pragma mark ================== 取号 =====================
-(void)clickGenumAction:(HDShopCutterListModel *)model{
    HDGetCutNumberViewController *getVC = [HDGetCutNumberViewController new];
    getVC.cutter_id = model.tonyId;
    [self.navigationController pushViewController:getVC animated:YES];
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    HDShopCutterListModel *model = self.arrData[indexPath.row];
    HDCutterDetailViewController *detailVC = [HDCutterDetailViewController new];
    detailVC.cutter_id = model.tonyId;
    detailVC.delegate = self;
    [self.navigationController pushViewController:detailVC animated:YES];
}

#pragma mark -- 加载控件

-(UITableView *)mainTableView{
    if (!_mainTableView) {
        _mainTableView = [[UITableView alloc] initWithFrame:CGRectMake(0, 8, kSCREEN_WIDTH, kSCREEN_HEIGHT-NAVHIGHT-48-8) style:UITableViewStylePlain];
        _mainTableView.delegate = self;
        _mainTableView.dataSource = self;
        _mainTableView.backgroundColor = [UIColor clearColor];
        _mainTableView.separatorStyle = UITableViewCellSeparatorStyleNone;
        [_mainTableView registerClass:[HDCutterTableViewCell class] forCellReuseIdentifier:NSStringFromClass([HDCutterTableViewCell class])];
    }
    return _mainTableView;
}

@end
