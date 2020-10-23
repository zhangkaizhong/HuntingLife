//
//  HDTinyMyShowsViewController.m
//  HairDress
//
//  Created by Apple on 2019/12/27.
//  Copyright © 2019 zhangkaizhong. All rights reserved.
//

#import "HDTinyMyShowsViewController.h"

#import "HDAddTinyShowsViewController.h"
#import "HDMyTinyShowsCollectionCell.h"

@interface HDTinyMyShowsViewController ()<navViewDelegate,HDMyTinyShowsDelegate,HDAddTinyShowsDelegate,UICollectionViewDelegate,UICollectionViewDataSource,UICollectionViewDelegateFlowLayout>

@property (nonatomic,strong) HDBaseNavView *navView;
@property (nonatomic,strong) UICollectionView *mainCollectView;
@property (nonatomic,strong) UIButton *buttonComfirn;

@property (nonatomic,assign) NSInteger page;
@property (nonatomic,strong) NSMutableArray *arrData;

@end

@implementation HDTinyMyShowsViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.page = 1;
    self.arrData = [NSMutableArray new];
    self.view.backgroundColor = RGBBG;
    [self.view addSubview:self.navView];
    [self.view addSubview:self.mainCollectView];
//    [self.view addSubview:self.buttonComfirn];
    
    [self getWorksShowListRequest:NO];
    [self setupRefresh];
}

#pragma mark - 添加刷新控件
-(void)setupRefresh{
    self.mainCollectView.mj_header = [MJRefreshNormalHeader headerWithRefreshingTarget:self refreshingAction:@selector(loadNewData)];
    self.mainCollectView.mj_footer = [MJRefreshBackNormalFooter footerWithRefreshingTarget:self refreshingAction:@selector(loadMoreData)];
}

//下拉刷新数据
-(void)loadNewData{
    [self.mainCollectView.mj_footer endRefreshing];
    self.page = 1;
    [self getWorksShowListRequest:NO];
}

//上提加载更多
-(void)loadMoreData{
    [self.mainCollectView.mj_header endRefreshing];
    self.page ++;
    [self getWorksShowListRequest:YES];
}

#pragma mark ================== 获取作品集列表 =====================
-(void)getWorksShowListRequest:(BOOL)more{
    NSDictionary *params = @{
        @"page":@{
                @"pageIndex":@(self.page),
                @"pageSize":@(20)
        },
        @"tonyId":[HDUserDefaultMethods getData:@"userId"],
    };
    [MHNetworkManager postReqeustWithURL:URL_TonyWorkShowsManageList params:params successBlock:^(NSDictionary *returnData) {
        if ([returnData[@"respCode"] integerValue] == 200) {
            if (more) {
                [self.mainCollectView.mj_footer endRefreshing];
            }else{
                [self.arrData removeAllObjects];
                [self.mainCollectView.mj_header endRefreshing];
            }
            NSArray *arr = [HDCutterWorkShowsModel mj_objectArrayWithKeyValuesArray:returnData[@"data"]];
            [self.arrData addObjectsFromArray:arr];
            if (self.arrData.count == [returnData[@"count"] integerValue]) {
                [self.mainCollectView.mj_footer endRefreshingWithNoMoreData];
            }
            [self.mainCollectView reloadData];
            
            if (self.arrData.count == 0) {
                [self.mainCollectView addSubview:self.viewEmpty];
                self.viewEmpty.hidden = NO;
            }else{
                self.viewEmpty.hidden = YES;
            }
        }else{
            if (more) {
                self.page --;
                [self.mainCollectView.mj_footer endRefreshing];
            }else{
                [self.mainCollectView.mj_header endRefreshing];
            }
        }
    } failureBlock:^(NSError *error) {
        if (more) {
            self.page --;
            [self.mainCollectView.mj_footer endRefreshing];
        }else{
            [self.mainCollectView.mj_header endRefreshing];
        }
    } showHUD:YES];
}

//删除作品集
-(void)deleteWorkShows:(HDCutterWorkShowsModel *)model{
    [MHNetworkManager postReqeustWithURL:URL_TonyDelWorksShow params:@{@"workId":model.workId} successBlock:^(NSDictionary *returnData) {
        [SVHUDHelper showWorningMsg:returnData[@"respMsg"] timeInt:1];
        [self loadNewData];
    } failureBlock:^(NSError *error) {
        
    } showHUD:YES];
}

//添加作品集后刷新列表代理
-(void)refreshNewShowsList{
    [self loadNewData];
}

#pragma mark -- delegate / action

-(void)navBackClicked{
    [self.navigationController popViewControllerAnimated:YES];
}

// 添加
-(void)navRightClicked{
    HDAddTinyShowsViewController *ShowsVC = [HDAddTinyShowsViewController new];
    ShowsVC.delegate = self;
    [self.navigationController pushViewController:ShowsVC animated:YES];
}

// 确定
-(void)comfirnAction{
    [self.navigationController popViewControllerAnimated:YES];
}

//删除作品
-(void)clickDeleteShows:(HDCutterWorkShowsModel *)model{
    [[WMZAlert shareInstance] showAlertWithType:AlertTypeNornal headTitle:@"提示" textTitle:@"您确定删除该作品集吗?" viewController:self leftHandle:^(id anyID) {
        //取消
    }rightHandle:^(id any) {
        //确定
        [self deleteWorkShows:model];
    }];
}

#pragma mark -- collectView delegate datasource

-(CGFloat)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout minimumLineSpacingForSectionAtIndex:(NSInteger)section{
    return 16;//可以根据section 设置不同section item的行间距
}
- (CGFloat)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout minimumInteritemSpacingForSectionAtIndex:(NSInteger)section{
    return 11;// 可以根据section 设置不同section item的列间距
}

- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath{
    return CGSizeMake((kSCREEN_WIDTH-32-15)/2+4, 208);//可以根据indexpath 设置item 的size
}

-(UIEdgeInsets)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout insetForSectionAtIndex:(NSInteger)section{
    return UIEdgeInsetsMake(20, 12, 20, 12);
}

- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView
{
    return 1;//设置section 个数
}
 
- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section
{
    return self.arrData.count;//根据section设置每个section的item个数
}
 
- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    //cell的重用，在设置UICollectionView 中注册了cell
    HDMyTinyShowsCollectionCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"showscell" forIndexPath:indexPath];
    cell.model = self.arrData[indexPath.item];
    cell.delegate = self;
    return cell;
}

-(void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath{
    
}

#pragma mark ================== 加载控件 =====================

-(UICollectionView *)mainCollectView{
    if (!_mainCollectView) {
        UICollectionViewFlowLayout *layout = [[UICollectionViewFlowLayout alloc] init];
        _mainCollectView = [[UICollectionView alloc] initWithFrame:CGRectMake(0, NAVHIGHT, kSCREEN_WIDTH, kSCREEN_HEIGHT-NAVHIGHT) collectionViewLayout:layout];
        _mainCollectView.delegate = self;
        _mainCollectView.dataSource = self;
        _mainCollectView.backgroundColor = [UIColor clearColor];
        [_mainCollectView registerClass:[HDMyTinyShowsCollectionCell class] forCellWithReuseIdentifier:@"showscell"];
        
        // 底部视图
//        UIView *footer = [[UIView alloc] initWithFrame:CGRectMake(0, kSCREEN_HEIGHT+32+32+48,kSCREEN_WIDTH,32+32+48)];
//        [_mainCollectView addSubview:footer];
//        _mainCollectView.contentInset = UIEdgeInsetsMake(0, 0, 32+32+48, 0);
    }
    return _mainCollectView;
}

-(HDBaseNavView *)navView{
    if (!_navView) {
        _navView = [[HDBaseNavView alloc] initWithFrame:CGRectMake(0, 0, kSCREEN_WIDTH, NAVHIGHT) title:@"作品集" bgColor:RGBMAIN backBtn:YES rightBtn:@"添加" rightBtnImage:@"" theDelegate:self];
    }
    return _navView;
}

//
-(UIButton *)buttonComfirn{
    if (!_buttonComfirn) {
        _buttonComfirn = [[UIButton alloc] initSystemWithFrame:CGRectMake(16, kSCREEN_HEIGHT-48-32, kSCREEN_WIDTH-32, 48) btnTitle:@"确定" btnImage:@"" titleColor:[UIColor whiteColor] titleFont:14];
        _buttonComfirn.layer.cornerRadius = 24;
        _buttonComfirn.backgroundColor = RGBMAIN;
        
        [_buttonComfirn addTarget:self action:@selector(comfirnAction) forControlEvents:UIControlEventTouchUpInside];
    }
    return _buttonComfirn;
}
@end
