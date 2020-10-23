//
//  HDTaoMallSubWearsViewController.m
//  HairDress
//
//  Created by Apple on 2020/1/9.
//  Copyright © 2020 zhangkaizhong. All rights reserved.
//

#import "HDTaoMallSubWearsViewController.h"

#import "HDTaoMallSubCommonViewController.h"
#import "HDTaoGoodsDetailViewController.h"

#import "HDTaoGoodsCollectionViewCell.h"
#import "HDTaoIconCollectionCell.h"
#import "HQCollectionViewFlowLayout.h"
#import "HQTopStopView.h"
#import "HQTaoFooterView.h"

@interface HDTaoMallSubWearsViewController () <UICollectionViewDataSource,UICollectionViewDelegate,UICollectionViewDelegateFlowLayout,HQTopStopViewDelegate>

@property (nonatomic, strong) UICollectionView *mainCollectionView;

@property (nonatomic,assign) NSInteger page;
@property (nonatomic,strong) NSMutableArray *arrGoodsData;//商品列表
@property (nonatomic,strong) NSMutableArray *arrIconData;//菜单列表

@property (nonatomic,copy) NSString *priceSortType;//价格排序
@property (nonatomic,copy) NSString *sortType;//综合排序
@property (nonatomic,copy) NSString *volumeSortType;//销量排序

@end

@implementation HDTaoMallSubWearsViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = RGBBG;
    
    self.sortType = @"desc";
    self.priceSortType = @"";
    self.volumeSortType = @"";
    self.page = 1;
    self.arrGoodsData = [NSMutableArray new];
    self.arrIconData = [NSMutableArray new];
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
    
    [self requestBarData];
    [self getGoodsListRequest:NO];
}

//上提加载更多
-(void)loadMoreData{
    [self.mainCollectionView.mj_header endRefreshing];
    self.page ++;
    [self getGoodsListRequest:YES];
}

#pragma mark ================== 数据请求 =====================
//请求页面结构数据
-(void)requestBarData{
    NSMutableDictionary *params = [NSMutableDictionary new];
    [params setValue:self.index_id forKey:@"id"];
    [params setValue:self.position_code forKey:@"positionCode"];
    if (![[HDUserDefaultMethods getData:@"userId"] isEqualToString:@""]) {
        [params setValue:[HDUserDefaultMethods getData:@"userId"] forKey:@"userId"];
    }
    
    [MHNetworkManager postReqeustWithURL:URL_TaoBarIndex params:params successBlock:^(NSDictionary *returnData) {
        returnData = [HDToolHelper nullDicToDic:returnData];
        if ([returnData[@"respCode"] integerValue] == 200) {
            [self.arrIconData removeAllObjects];
            NSArray *arr = returnData[@"data"][@"otherBarSortVoList"];
            [self.arrIconData addObjectsFromArray:arr];
            [self.mainCollectionView reloadData];
        }
    } failureBlock:^(NSError *error) {
        
    } showHUD:YES];
}

//请求商品列表
-(void)getGoodsListRequest:(BOOL)more{
    NSDictionary *params = @{
        @"cidType":@"cpsBar",
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

#pragma mark ---------  UICollectionView  Delegate/DataSource-----
//点击单元格
-(void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath{
    if (indexPath.section == 0) {
        NSDictionary *dic = self.arrIconData[indexPath.item];
        HDTaoMallSubCommonViewController *subCommonVC = [HDTaoMallSubCommonViewController new];
        subCommonVC.cid = dic[@"cid"];
        subCommonVC.subTitle = dic[@"title"];
        [self.navigationController pushViewController:subCommonVC animated:YES];
    }
    else{
        HDTaoGoodsModel *model = self.arrGoodsData[indexPath.item];
        HDTaoGoodsDetailViewController *detailVC = [HDTaoGoodsDetailViewController new];
        detailVC.taoId = model.taoId;
        detailVC.indexTab = 1;
        [self.navigationController pushViewController:detailVC animated:YES];
    }
}

-(NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView{
    return 2;
}

//设置区头高度
- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout referenceSizeForHeaderInSection:(NSInteger)section{
    if (section == 0) {
        return CGSizeZero;
    }
    return CGSizeMake(kSCREEN_WIDTH,48);
}

//设置区尾高度
- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout referenceSizeForFooterInSection:(NSInteger)section{
    if (section == 0) {
        return CGSizeMake(kSCREEN_WIDTH, 8);
    }
    return CGSizeZero;
}

//配置区头
-(UICollectionReusableView *)collectionView:(UICollectionView *)collectionView viewForSupplementaryElementOfKind:(NSString *)kind atIndexPath:(NSIndexPath *)indexPath{
    if (kind == UICollectionElementKindSectionFooter) {
        HQTaoFooterView *footerView = [collectionView dequeueReusableSupplementaryViewOfKind:UICollectionElementKindSectionFooter withReuseIdentifier:@"footerView" forIndexPath:indexPath];
        footerView.backgroundColor = RGBBG;
        return footerView;
    }
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
    if (section==0) {
        return self.arrIconData.count;
    }
    return self.arrGoodsData.count;
}

-(CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath{
    if (indexPath.section == 0) {
        return CGSizeMake(kSCREEN_WIDTH/4,kSCREEN_WIDTH/4);
    }
    return CGSizeMake((kSCREEN_WIDTH-32)/2, 283*SCALE);
}

-(UIEdgeInsets)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout insetForSectionAtIndex:(NSInteger)section{
    if (section == 0) {
        return UIEdgeInsetsMake(0, 0, 0, 0);
    }
    return UIEdgeInsetsMake(8, 12, 8, 12);
}

-(CGFloat)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout minimumLineSpacingForSectionAtIndex:(NSInteger)section{
    if (section == 0) {
        return 0;
    }
    return 8;//可以根据section 设置不同section item的行间距
}
- (CGFloat)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout minimumInteritemSpacingForSectionAtIndex:(NSInteger)section{
    if (section == 0) {
        return 0;
    }
    return 8;// 可以根据section 设置不同section item的列间距
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.section == 0) {
        collectionView.backgroundColor = [UIColor whiteColor];
        HDTaoIconCollectionCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:NSStringFromClass([HDTaoIconCollectionCell class]) forIndexPath:indexPath];
        cell.contentView.backgroundColor = [UIColor clearColor];
        cell.dic = self.arrIconData[indexPath.item];
        return cell;
    }
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
        _mainCollectionView = [[UICollectionView alloc] initWithFrame:CGRectMake(0 , 0, kSCREEN_WIDTH, kSCREEN_HEIGHT-48-NAVHIGHT-KTarbarHeight) collectionViewLayout:flowlayout];
        _mainCollectionView.delegate = self;
        _mainCollectionView.dataSource = self;
        
        [_mainCollectionView setBackgroundColor:[UIColor clearColor]];
        
        //注册单元格
        [_mainCollectionView registerClass:[HDTaoGoodsCollectionViewCell class] forCellWithReuseIdentifier:NSStringFromClass([HDTaoGoodsCollectionViewCell class])];
        //注册单元格
        [_mainCollectionView registerClass:[HDTaoIconCollectionCell class] forCellWithReuseIdentifier:NSStringFromClass([HDTaoIconCollectionCell class])];
        //注册区头
        [_mainCollectionView registerClass:[HQTopStopView class] forSupplementaryViewOfKind: UICollectionElementKindSectionHeader withReuseIdentifier:@"topView"];
        //注册区尾
        [_mainCollectionView registerClass:[HQTaoFooterView class] forSupplementaryViewOfKind: UICollectionElementKindSectionFooter withReuseIdentifier:@"footerView"];
    }
    return _mainCollectionView;
}

@end
