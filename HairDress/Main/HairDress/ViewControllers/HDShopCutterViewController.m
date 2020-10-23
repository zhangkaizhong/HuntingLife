//
//  HDSearchCutterViewController.m
//  HairDress
//
//  Created by 张凯中 on 2019/12/21.
//  Copyright © 2019 zhangkaizhong. All rights reserved.
//

#import "HDShopCutterViewController.h"

#import "HDCutterDetailViewController.h"
//#import "HDNewCutterDetailViewController.h"
#import "HDGetCutNumberViewController.h"

#import "UITableView+FDTemplateLayoutCell.h"
#import "HDCutterTableViewCell.h"

@interface HDShopCutterViewController ()<UITableViewDataSource,UITableViewDelegate,HDCutterTableViewCellDelegate>

//页码
@property (nonatomic,assign) NSInteger page;

@property (nonatomic,strong) UITableView *mainTableView;

//列表数据
@property (nonatomic,strong) NSMutableArray *arrDataList;

@end

@implementation HDShopCutterViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    UIView *line = [[UIView alloc] initWithFrame:CGRectMake(0, 0, kSCREEN_WIDTH, 1)];
    line.backgroundColor = RGBAlpha(239, 239, 239, 1);
    [self.view addSubview:line];
    
//    self.view.backgroundColor = RGBBG;
    [self.view addSubview:self.mainTableView];
    
    self.page = 1;
    self.arrDataList = [NSMutableArray new];
    
    [self requestCutterList:NO];
    
    [self setupRefresh];
}

//重新刷新
-(void)tapEmptyAction:(UIGestureRecognizer *)gestur{
    [super tapEmptyAction:gestur];
    [self requestCutterList:NO];
}

#pragma mark - 添加刷新控件
-(void)setupRefresh{
    self.mainTableView.mj_footer = [MJRefreshBackNormalFooter footerWithRefreshingTarget:self refreshingAction:@selector(loadMoreData)];
}

//上提加载更多
-(void)loadMoreData{
    self.page ++;
    [self requestCutterList:YES];
}

#pragma mark ================== 请求门店发型师列表 =====================
-(void)requestCutterList:(BOOL)more{
    NSDictionary *dic = @{
        @"storeId": self.shop_id,
        @"page":@{@"pageIndex":@(self.page),@"pageSize":@"200"}
    };
    WeakSelf;
    [MHNetworkManager postReqeustWithURL:URL_TonyList params:dic successBlock:^(NSDictionary *returnData) {
        DTLog(@"%@",returnData);
        if (more) {
            [weakSelf.mainTableView.mj_footer endRefreshing];
        }
        if ([returnData[@"respCode"] integerValue] == 200) {
            NSArray *arr = [HDShopCutterListModel mj_objectArrayWithKeyValuesArray:returnData[@"data"]];
            if (more && arr.count == 0) {
                weakSelf.page --;
            }
            for (HDShopCutterListModel *model in arr) {
                model.isDetail = @"1";
            }
            [self.arrDataList addObjectsFromArray:arr];
            [self.mainTableView reloadData];
            
            if (self.arrDataList.count == 0) {
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
            }
        }
    } failureBlock:^(NSError *error) {
        if (more) {
            [weakSelf.mainTableView.mj_footer endRefreshing];
        }
    } showHUD:YES];
}

#pragma mark ================== 取号 =====================
-(void)clickGenumAction:(HDShopCutterListModel *)model{
    HDGetCutNumberViewController *getVC = [HDGetCutNumberViewController new];
    getVC.cutter_id = model.tonyId;
    [self.navigationController pushViewController:getVC animated:YES];
}

#pragma mark -- tableview delegate \ action

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"cuttercell" forIndexPath:indexPath];
    HDCutterTableViewCell  *cell1 = nil;
    cell1 = (HDCutterTableViewCell *)cell;
    cell1.delegate = self;
    cell1.model = self.arrDataList[indexPath.row];
    return cell1;
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    HDShopCutterListModel *model = self.arrDataList[indexPath.row];
    HDCutterDetailViewController *detailVC = [HDCutterDetailViewController new];
    detailVC.cutter_id = model.tonyId;
    [self.navigationController pushViewController:detailVC animated:YES];
}

-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    HDShopCutterListModel *model = self.arrDataList[indexPath.row];
    return model.cellHeight;
}

//- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
//    return [self.mainTableView fd_heightForCellWithIdentifier:@"cuttercell" configuration:^(HDCutterTableViewCell *cell) {
//        [self configureOriCell:cell atIndexPath:indexPath];
//    }];
//}
//
//- (void)configureOriCell:(HDCutterTableViewCell *)cell atIndexPath:(NSIndexPath *)indexPath{
//    cell.fd_enforceFrameLayout = NO; // Enable to use "-sizeThatFits:"
//    if (indexPath.row < _arrDataList.count) {
//        cell.model = _arrDataList[indexPath.row];
//    }
//}

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return self.arrDataList.count;
}


#pragma mark -- 加载控件

-(UITableView *)mainTableView{
    if (!_mainTableView) {
        _mainTableView = [[UITableView alloc] initWithFrame:CGRectMake(0, 1, kSCREEN_WIDTH, kSCREEN_HEIGHT-NAVHIGHT-49) style:UITableViewStylePlain];
        _mainTableView.delegate = self;
        _mainTableView.dataSource = self;
        _mainTableView.backgroundColor = [UIColor clearColor];
        _mainTableView.separatorStyle = UITableViewCellSeparatorStyleNone;
        [_mainTableView registerClass:[HDCutterTableViewCell class] forCellReuseIdentifier:@"cuttercell"];
        
    }
    
    return _mainTableView;
}


@end
