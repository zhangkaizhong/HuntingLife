//
//  HDTaoMallSubWearsViewController.m
//  HairDress
//
//  Created by Apple on 2020/1/9.
//  Copyright © 2020 zhangkaizhong. All rights reserved.
//

#import "HDTaoMallSubCommonViewController.h"

#import "HDTaoGoodsDetailViewController.h"

#import "HDTaoGoodsCollectionViewCell.h"
#import "HDTaoIconCollectionCell.h"
#import "HQCollectionViewFlowLayout.h"
#import "HQTopStopView.h"
#import "HQTaoFooterView.h"

@interface HDTaoMallSubCommonViewController () <navViewDelegate,UICollectionViewDataSource,UICollectionViewDelegate,UICollectionViewDelegateFlowLayout,HQTopStopViewDelegate>

@property (nonatomic, strong) UICollectionView *mainCollectionView;
@property (nonatomic, strong) HDBaseNavView *navView;

@property (nonatomic,assign) NSInteger page;
@property (nonatomic,strong) NSMutableArray *arrGoodsData;//商品列表

@property (nonatomic,copy) NSString *priceSortType;//价格排序
@property (nonatomic,copy) NSString *sortType;//综合排序
@property (nonatomic,copy) NSString *volumeSortType;//销量排序

@end

@implementation HDTaoMallSubCommonViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = RGBBG;
    [self.view addSubview:self.navView];
    
    self.sortType = @"new";
    self.priceSortType = @"";
    self.volumeSortType = @"";
    self.page = 1;
    self.arrGoodsData = [NSMutableArray new];
    [self.view addSubview:self.mainCollectionView];
    
    [self setupRefresh];
    [self loadNewData];
}

#pragma mark -- delegate Action
-(void)clickSortAction:(NSString *)sortTitle sort:(NSString *)sortType{
    if ([sortTitle isEqualToString:@"综合"]) {
        self.sortType = sortType;
        self.priceSortType = @"";
        self.volumeSortType = @"";
    }
    if ([sortTitle isEqualToString:@"价格"]) {
        self.priceSortType = sortType;
        self.sortType = @"";
        self.volumeSortType = @"";
    }
    if ([sortTitle isEqualToString:@"销量"]) {
        self.volumeSortType = sortType;
        self.priceSortType = @"";
        self.sortType = @"";
    }
    [self getGoodsListRequest:NO];
}

#pragma mark - 添加刷新控件
-(void)setupRefresh{
    self.mainCollectionView.mj_header = [MJRefreshNormalHeader headerWithRefreshingTarget:self refreshingAction:@selector(loadNewData)];
    self.mainCollectionView.mj_footer = [MJRefreshBackNormalFooter footerWithRefreshingTarget:self refreshingAction:@selector(loadMoreData)];
}

//下拉刷新数据
-(void)loadNewData{
    [self.mainCollectionView.mj_footer endRefreshing];
    self.page = 1;
    [self getGoodsListRequest:NO];
}

//上提加载更多
-(void)loadMoreData{
    [self.mainCollectionView.mj_header endRefreshing];
    self.page ++;
    [self getGoodsListRequest:YES];
}

#pragma mark ================== delegate action =====================
-(void)navBackClicked{
    [self.navigationController popViewControllerAnimated:YES];
}

#pragma mark ================== 数据请求 =====================
//请求商品列表
-(void)getGoodsListRequest:(BOOL)more{
    if (!self.cid && self.keyWords) {
        [self getSearchGoodsList:more];
        return;
    }
    NSDictionary *params = @{
        @"cidType":@"cpsItem",
        @"cid":self.cid,
        @"page":@{
                @"pageIndex":@(self.page),
                @"pageSize":@(20)
        },
        @"priceSort":self.priceSortType,
        @"sortType":self.sortType,
        @"volumeSort":self.volumeSortType
    };
    [MHNetworkManager postReqeustWithURL:URL_TaoOtherGoodsList params:params successBlock:^(NSDictionary *returnData) {
        returnData = [HDToolHelper nullDicToDic:returnData];
        if ([returnData[@"respCode"] integerValue] == 200) {
            if (more) {
                [self.mainCollectionView.mj_footer endRefreshing];
            }else{
                [self.arrGoodsData removeAllObjects];
                [self.mainCollectionView.mj_header endRefreshing];
            }
            NSArray *arr = [HDTaoGoodsModel mj_objectArrayWithKeyValuesArray:returnData[@"data"]];
            [self.arrGoodsData addObjectsFromArray:arr];
            [self.mainCollectionView reloadData];
        }else{
            if (more) {
                self.page --;
                [self.mainCollectionView.mj_footer endRefreshing];
            }else{
                [self.mainCollectionView.mj_header endRefreshing];
            }
        }
    } failureBlock:^(NSError *error) {
        if (more) {
            self.page --;
            [self.mainCollectionView.mj_footer endRefreshing];
        }else{
            [self.mainCollectionView.mj_header endRefreshing];
        }
    } showHUD:YES];
}

//加载搜索商品列表
-(void)getSearchGoodsList:(BOOL)more{
    NSString *sort = @"";
    if (![self.sortType isEqualToString:@""]) {
        sort = @"new";
    }
    if ([self.priceSortType isEqualToString:@"asc"]) {
        sort = @"price_asc";
    }
    if ([self.priceSortType isEqualToString:@"desc"]) {
        sort = @"price_desc";
    }
    if ([self.volumeSortType isEqualToString:@"asc"]) {
        sort = @"sale_num_asc";
    }
    if ([self.volumeSortType isEqualToString:@"desc"]) {
        sort = @"sale_num_desc";
    }
    NSDictionary *params = @{
        @"page":@{
                @"pageIndex":@(self.page),
                @"pageSize":@(20)
        },
        @"q":self.keyWords,
        @"sort":sort,
        @"searchType":self.searchType ? self.searchType : @""
    };
    [MHNetworkManager postReqeustWithURL:URL_TaoGoodsSearch params:params successBlock:^(NSDictionary *returnData) {
        returnData = [HDToolHelper nullDicToDic:returnData];
        if ([returnData[@"respCode"] integerValue] == 200) {
            if (more) {
                [self.mainCollectionView.mj_footer endRefreshing];
            }else{
                [self.arrGoodsData removeAllObjects];
                [self.mainCollectionView.mj_header endRefreshing];
            }
            NSArray *arr = [HDTaoGoodsModel mj_objectArrayWithKeyValuesArray:returnData[@"data"]];
            [self.arrGoodsData addObjectsFromArray:arr];
            [self.mainCollectionView reloadData];
        }else{
            if (more) {
                self.page --;
                [self.mainCollectionView.mj_footer endRefreshing];
            }else{
                [self.mainCollectionView.mj_header endRefreshing];
            }
        }
    } failureBlock:^(NSError *error) {
        if (more) {
            self.page --;
            [self.mainCollectionView.mj_footer endRefreshing];
        }else{
            [self.mainCollectionView.mj_header endRefreshing];
        }
    } showHUD:YES];
}

#pragma mark ---------  UICollectionView  Delegate/DataSource-----
//点击单元格
-(void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath{
    HDTaoGoodsModel *model = self.arrGoodsData[indexPath.item];
    HDTaoGoodsDetailViewController *detailVC = [HDTaoGoodsDetailViewController new];
    detailVC.taoId = model.taoId;
    detailVC.indexTab = 1;
    [self.navigationController pushViewController:detailVC animated:YES];
}

-(NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView{
    return 1;
}

//设置区头高度
- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout referenceSizeForHeaderInSection:(NSInteger)section{
    return CGSizeMake(kSCREEN_WIDTH,48);
}

//设置区尾高度
- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout referenceSizeForFooterInSection:(NSInteger)section{
    return CGSizeZero;
}

//配置区头
-(UICollectionReusableView *)collectionView:(UICollectionView *)collectionView viewForSupplementaryElementOfKind:(NSString *)kind atIndexPath:(NSIndexPath *)indexPath{
    if (kind == UICollectionElementKindSectionHeader) {
        HQTopStopView *headerView = [collectionView dequeueReusableSupplementaryViewOfKind:UICollectionElementKindSectionHeader withReuseIdentifier:@"topView" forIndexPath:indexPath];
        headerView.backgroundColor = [UIColor whiteColor];
        headerView.delegate = self;
        return headerView;
    }
    return nil;
}
#pragma mark ================== collectionView delegate datasource =====================
-(NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section{
    return self.arrGoodsData.count;
}

-(CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath{
    return CGSizeMake((kSCREEN_WIDTH-32)/2, 283*SCALE);
}

-(UIEdgeInsets)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout insetForSectionAtIndex:(NSInteger)section{
    return UIEdgeInsetsMake(1, 12, 8, 12);
}

-(CGFloat)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout minimumLineSpacingForSectionAtIndex:(NSInteger)section{
    return 8;//可以根据section 设置不同section item的行间距
}
- (CGFloat)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout minimumInteritemSpacingForSectionAtIndex:(NSInteger)section{
    return 8;// 可以根据section 设置不同section item的列间距
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    //cell的重用，在设置UICollectionView 中注册了cell
    HDTaoGoodsCollectionViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:NSStringFromClass([HDTaoGoodsCollectionViewCell class]) forIndexPath:indexPath];
    cell.model = self.arrGoodsData[indexPath.item];
    return cell;
}

#pragma mark -- 懒加载

- (UICollectionView *)mainCollectionView{
    if (!_mainCollectionView) {
        HQCollectionViewFlowLayout *flowlayout = [[HQCollectionViewFlowLayout alloc] init];
        //设置悬停高度，默认64
        flowlayout.naviHeight = 0;
        _mainCollectionView = [[UICollectionView alloc] initWithFrame:CGRectMake(0 , NAVHIGHT, kSCREEN_WIDTH, kSCREEN_HEIGHT-NAVHIGHT) collectionViewLayout:flowlayout];
        _mainCollectionView.delegate = self;
        _mainCollectionView.dataSource = self;
        
        [_mainCollectionView setBackgroundColor:[UIColor clearColor]];
        
        //注册单元格
        [_mainCollectionView registerClass:[HDTaoGoodsCollectionViewCell class] forCellWithReuseIdentifier:NSStringFromClass([HDTaoGoodsCollectionViewCell class])];
        //注册区头
        [_mainCollectionView registerClass:[HQTopStopView class] forSupplementaryViewOfKind: UICollectionElementKindSectionHeader withReuseIdentifier:@"topView"];
    }
    return _mainCollectionView;
}

-(HDBaseNavView *)navView{
    if (!_navView) {
        _navView = [[HDBaseNavView alloc] initWithFrame:CGRectMake(0, 0, kSCREEN_WIDTH, NAVHIGHT) title:self.subTitle bgColor:[UIColor whiteColor] backBtn:YES rightBtn:@"" rightBtnImage:@"" theDelegate:self];
    }
    return _navView;
}

@end
