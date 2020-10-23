//
//  HDOrderManageWaitViewController.m
//  HairDress
//
//  Created by 张凯中 on 2019/12/26.
//  Copyright © 2019 zhangkaizhong. All rights reserved.
//

#import "HDMyShopWaiterSubViewController.h"

#import "HDMyShopWaiterTableViewCell.h"

@interface HDMyShopWaiterSubViewController ()<UITableViewDelegate,UITableViewDataSource,MyShopWaiterDelegate>

@property (nonatomic,assign) NSInteger page;
@property (nonatomic,strong) NSMutableArray *arrDataList;
@property (nonatomic,strong) UITableView *mainTableView;

@end

@implementation HDMyShopWaiterSubViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.view.backgroundColor = RGBBG;
    self.page = 1;
    self.arrDataList = [NSMutableArray new];
    
    [self.view addSubview:self.mainTableView];
    
    [self setupRefresh];
    
    [self.mainTableView.mj_header beginRefreshing];
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
    [self requestWaiterList:NO];
}

//上提加载更多
-(void)loadMoreData{
    [self.mainTableView.mj_header endRefreshing];
    self.page ++;
    [self requestWaiterList:YES];
}

#pragma mark ================== 数据接口请求 =====================
//请求门店店员列表
-(void)requestWaiterList:(BOOL)more{
    if (!self.storePost) {
        self.storePost = @"";
    }
    if (!self.searchName) {
        self.searchName = @"";
    }
    NSDictionary *dic = @{
        @"storeId": [HDUserDefaultMethods getData:@"storeId"],
        @"storePost":self.storePost,
        @"page":@{@"pageIndex":@(self.page),@"pageSize":@"200"},
        @"searchName":self.searchName
    };
    WeakSelf;
    [MHNetworkManager postReqeustWithURL:URL_StoreTonyList params:dic successBlock:^(NSDictionary *returnData) {
        if ([returnData[@"respCode"] integerValue] == 200) {
            if (more) {
                [weakSelf.mainTableView.mj_footer endRefreshing];
            }else{
                [self.arrDataList removeAllObjects];
                [weakSelf.mainTableView.mj_header endRefreshing];
            }
            NSArray *arr = [HDStoreWaiterListModel mj_objectArrayWithKeyValuesArray:returnData[@"data"]];
            [self.arrDataList addObjectsFromArray:arr];
            if (self.arrDataList.count == [returnData[@"count"] integerValue]) {
                [self.mainTableView.mj_footer endRefreshingWithNoMoreData];
            }
            [self.mainTableView reloadData];
            
            if (self.arrDataList.count == 0) {
                [self.mainTableView addSubview:self.viewEmpty];
                self.viewEmpty.hidden = NO;
            }else{
                self.viewEmpty.hidden = YES;
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
    } showHUD:NO];
}

//变更岗位
-(void)updateTonyPostRequest:(NSString *)storePost withModel:(HDStoreWaiterListModel *)model{
    if (!storePost) {
        [SVHUDHelper showWorningMsg:@"岗位不能为空" timeInt:1];
        return;
    }
    NSString *storePostType = @"T";
    if ([storePost isEqualToString:@"普通店员"]) {
        storePostType = @"O";
    }
    WeakSelf;
    [MHNetworkManager postReqeustWithURL:URL_StoreUpdateTonyPost params:@{@"storePost":storePostType,@"tonyId":model.tonyId} successBlock:^(NSDictionary *returnData) {

        if ([returnData[@"respCode"] integerValue] == 200) {
            [SVHUDHelper showWorningMsg:@"变更成功" timeInt:1];
            [HDToolHelper delayMethodFourGCD:1 method:^{
                [weakSelf requestWaiterList:NO];
                if (self.delegate && [self.delegate respondsToSelector:@selector(refreshDataList:)]) {
                    [self.delegate refreshDataList:self.storePost];
                }
            }];
        }else{
            [SVHUDHelper showWorningMsg:returnData[@"respMsg"] timeInt:1];
        }
    } failureBlock:^(NSError *error) {
        
    } showHUD:YES];
}

//删除店员
-(void)deleteStoreWaiterRequest:(HDStoreWaiterListModel *)model{
    WeakSelf;
    [MHNetworkManager postReqeustWithURL:URL_StoreDeleteTony params:@{@"tonyId":model.tonyId} successBlock:^(NSDictionary *returnData) {
        
        if ([returnData[@"respCode"] integerValue] == 200) {
            [SVHUDHelper showWorningMsg:@"删除成功" timeInt:1];
            [HDToolHelper delayMethodFourGCD:1 method:^{
                [weakSelf requestWaiterList:NO];
                if (self.delegate && [self.delegate respondsToSelector:@selector(refreshDataList:)]) {
                    [self.delegate refreshDataList:self.storePost];
                }
            }];
        }else{
            [SVHUDHelper showWorningMsg:returnData[@"respMsg"] timeInt:1];
        }
    } failureBlock:^(NSError *error) {
        
    } showHUD:YES];
}

#pragma mark -- action / delegate
// 变更岗位
-(void)clickChangeShopWaiterType:(NSString *)btnTitle withModel:(nonnull HDStoreWaiterListModel *)model{
    if ([btnTitle isEqualToString:@"变更岗位"]) {
        NSString *postStr = @"发型师";
        if ([model.storePost isEqualToString:@"O"]) {
            postStr = @"普通店员";
        }
        NSDictionary *data = @{@"arr":@[@"发型师",@"普通店员"],@"select":postStr};
        [[WMZAlert shareInstance] showAlertWithType:AlertTypeSelect headTitle:@"变更岗位为" textTitle:data viewController:self leftHandle:^(id anyID) {
            //取消
        }rightHandle:^(id any) {
            //确定
            [self updateTonyPostRequest:any withModel:model];
        }];
    }
    else{
        [[WMZAlert shareInstance] showAlertWithType:AlertTypeNornal headTitle:@"提示" textTitle:@"您确定删除该店员吗?" viewController:self leftHandle:^(id anyID) {
            //取消
        }rightHandle:^(id any) {
            //确定
            [self deleteStoreWaiterRequest:model];
        }];
    }
}

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return self.arrDataList.count;
}

-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    return 151;
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    HDMyShopWaiterTableViewCell * cell = [tableView dequeueReusableCellWithIdentifier:@"cellwaiter" forIndexPath:indexPath];
    cell.delegate = self;
    cell.model = self.arrDataList[indexPath.row];
    return cell;
}

-(UITableView *)mainTableView{
    if (!_mainTableView) {
        _mainTableView = [[UITableView alloc] initWithFrame:CGRectMake(0, 0, kSCREEN_WIDTH, kSCREEN_HEIGHT-NAVHIGHT-48) style:UITableViewStylePlain];
        _mainTableView.delegate = self;
        _mainTableView.dataSource = self;
        _mainTableView.backgroundColor = [UIColor clearColor];
        _mainTableView.separatorStyle = UITableViewCellSeparatorStyleNone;
        [_mainTableView registerClass:[HDMyShopWaiterTableViewCell class] forCellReuseIdentifier:@"cellwaiter"];
    }
    return _mainTableView;
}

@end
