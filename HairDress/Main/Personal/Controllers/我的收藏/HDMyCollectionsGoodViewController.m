//
//  HDMyCutOrderServicesViewController.m
//  HairDress
//
//  Created by 张凯中 on 2019/12/29.
//  Copyright © 2019 zhangkaizhong. All rights reserved.
//

#import "HDMyCollectionsGoodViewController.h"

#import "HDTaoGoodsDetailViewController.h"
#import "HDCollectGoodsTableViewCell.h"

@interface HDMyCollectionsGoodViewController ()<HDTaoGoodsDetailViewDelegate,UITableViewDelegate,UITableViewDataSource>

@property (nonatomic,assign) NSInteger page;
@property (nonatomic,strong) UITableView *mainTableView;
@property (nonatomic,strong) NSMutableArray *arrData;

@end

@implementation HDMyCollectionsGoodViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.view.backgroundColor = RGBBG;
    self.page = 1;
    self.arrData = [NSMutableArray new];
    [self.view addSubview:self.mainTableView];
    
    [self setupRefresh];
    
    [self.mainTableView.mj_header beginRefreshing];
}

#pragma mark - 添加刷新控件
-(void)setupRefresh{
    self.mainTableView.mj_header = [MJRefreshNormalHeader headerWithRefreshingTarget:self refreshingAction:@selector(loadNewData)];
//    self.mainTableView.mj_footer = [MJRefreshBackNormalFooter footerWithRefreshingTarget:self refreshingAction:@selector(loadMoreData)];
}

//取消收藏刷新列表数据
-(void)clickCollectActionRefreshList{
    [self loadNewData];
}

//下拉刷新数据
-(void)loadNewData{
    [self.mainTableView.mj_footer endRefreshing];
    self.page = 1;
    [self getGoodsList:NO];
    
}

//上提加载更多
-(void)loadMoreData{
    [self.mainTableView.mj_header endRefreshing];
    self.page ++;
    [self getGoodsList:YES];
}

//重新刷新数据
-(void)clickCollectGoodsActionRefreshList{
    [self loadNewData];
}

#pragma mark -- 获取收藏列表
-(void)getGoodsList:(BOOL)more{
    NSDictionary *params = @{
        @"memberType":@"F",
        @"userId":[HDUserDefaultMethods getData:@"userId"]
    };
    [MHNetworkManager postReqeustWithURL:URL_TaoUserGoodsList params:params successBlock:^(NSDictionary *returnData) {
        [self.mainTableView.mj_header endRefreshing];
        if ([returnData[@"respCode"] integerValue] == 200) {
            [self.arrData removeAllObjects];
            NSArray *arr = [HDTaoUserGoodsModel mj_objectArrayWithKeyValuesArray:returnData[@"data"]];
            [self.arrData addObjectsFromArray:arr];
            [self.mainTableView reloadData];
            if (self.arrData.count == 0) {
                [self.mainTableView addSubview:self.viewEmpty];
                self.viewEmpty.hidden = NO;
            }else{
                self.viewEmpty.hidden = YES;
            }
        }else{
            if (self.arrData.count == 0) {
                [self.mainTableView addSubview:self.viewEmpty];
                self.viewEmpty.hidden = NO;
            }else{
                self.viewEmpty.hidden = YES;
            }
        }
    } failureBlock:^(NSError *error) {
        if (self.arrData.count == 0) {
            [self.mainTableView addSubview:self.viewEmpty];
            self.viewEmpty.hidden = NO;
        }else{
            self.viewEmpty.hidden = YES;
        }
    } showHUD:NO];
}

#pragma mark -- tableView delegate datasource

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return self.arrData.count;
}

-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    return 121;
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    HDCollectGoodsTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:NSStringFromClass([HDCollectGoodsTableViewCell class]) forIndexPath:indexPath];
    cell.model = self.arrData[indexPath.row];
    return cell;
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    HDTaoUserGoodsModel *model = self.arrData[indexPath.row];
    HDTaoGoodsDetailViewController *detailVC = [HDTaoGoodsDetailViewController new];
    detailVC.taoId = model.taoId;
    detailVC.indexTab = 1;
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
        [_mainTableView registerClass:[HDCollectGoodsTableViewCell class] forCellReuseIdentifier:NSStringFromClass([HDCollectGoodsTableViewCell class])];
    }
    return _mainTableView;
}

@end
