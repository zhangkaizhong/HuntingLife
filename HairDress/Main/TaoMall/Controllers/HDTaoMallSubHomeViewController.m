//
//  HDTaoMallSubViewController.m
//  HairDress
//
//  Created by 张凯中 on 2020/1/6.
//  Copyright © 2020 zhangkaizhong. All rights reserved.
//

#import "HDTaoMallSubHomeViewController.h"

#import "HDTaoHomeStructModel.h"
#import <SDCycleScrollView.h>

#import "HDTaoGoodsCollectionViewCell.h"
#import "HDTaoHomeFormatDemoView.h"
#import "HDTaoFloorView.h"

#import "HDWebViewController.h"
#import "HDTaoGoodsDetailViewController.h"
#import "HDTaoMallSubIconGoodsViewController.h"
#import "HDTaoMallFloorDetailViewController.h"
#import "HDTaoMallSubCommonViewController.h"

@interface HDTaoMallSubHomeViewController ()<SDCycleScrollViewDelegate,UIScrollViewDelegate,HDTaoHomeFormatDemoViewDelegate,HDTaoFloorViewDelegate,UICollectionViewDelegate,UICollectionViewDataSource,UICollectionViewDelegateFlowLayout>

@property (nonatomic,assign) NSInteger page;
@property (nonatomic,strong) SDCycleScrollView * bannerView;  // 滚动视图
@property (nonatomic,strong) UIView *menuBtnsView;//菜单
@property (nonatomic,strong) HDTaoHomeFormatDemoView *jingxuanView;//精选
@property (nonatomic,strong) HDTaoFloorView *floorVoView;//楼层
@property (nonatomic,strong) UIView *titleView;//菜单视图
@property (nonatomic,strong) UIView *otherBarSortView;//
@property (nonatomic,strong) UIView *specialView;//

@property (nonatomic,weak) UILabel *lblMenuTitle;

@property (nonatomic,strong) UICollectionView *goodsCollectView;//底部

@property (nonatomic,strong) UIScrollView *mainSrollView;//主视图

//页面总数据
@property (nonatomic,strong) HDTaoHomeStructModel *indexModel;
//轮播图数组
@property (nonatomic,strong) NSMutableArray *bannerImageUrls;//轮播图片url

@property (nonatomic,strong) NSDictionary *dicGoodsList;
@property (nonatomic,strong) NSMutableArray *goodsArr;
@property (nonatomic,strong) NSMutableArray *iconsArr;

@end

@implementation HDTaoMallSubHomeViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.view.backgroundColor = [UIColor clearColor];
    
    self.page = 1;
    
    self.bannerImageUrls = [NSMutableArray new];
    self.goodsArr = [NSMutableArray new];
    self.iconsArr = [NSMutableArray new];

    [self setUI];
    [self setupRefresh];
    
    //获取首页UI结构
    [self getBarIndexConstructRequest];
}

#pragma mark ================== UI =====================
-(void)setUI{
    [self.view addSubview:self.mainSrollView];
    
    [self.mainSrollView addSubview:self.bannerView];
    [self.mainSrollView addSubview:self.menuBtnsView];
    [self.mainSrollView addSubview:self.jingxuanView];
    [self.mainSrollView addSubview:self.floorVoView];
    [self.mainSrollView addSubview:self.titleView];
    [self.mainSrollView addSubview:self.goodsCollectView];
}

#pragma mark ================== 监听网络变化后重新加载数据 =====================
-(void)getLoadDataBase:(NSNotification *)text{
    [super getLoadDataBase:text];
    if ([text.userInfo[@"netType"] integerValue] != 0) {
        if (!self.indexModel) {
            [self getBarIndexConstructRequest];
        }
    }
}

#pragma mark - 添加刷新控件
-(void)setupRefresh{
//    self.mainSrollView.mj_header = [MJRefreshNormalHeader headerWithRefreshingTarget:self refreshingAction:@selector(loadNewData)];
    self.mainSrollView.mj_footer = [MJRefreshBackNormalFooter footerWithRefreshingTarget:self refreshingAction:@selector(loadMoreData)];
    MJRefreshNormalHeader *header = [MJRefreshNormalHeader headerWithRefreshingTarget:self refreshingAction:@selector(loadNewData)];
    self.mainSrollView.mj_header = header;
    header.lastUpdatedTimeLabel.hidden = YES;
    header.stateLabel.textColor = [UIColor whiteColor];
}

//下拉刷新数据
-(void)loadNewData{
    [self.mainSrollView.mj_footer endRefreshing];
    self.page = 1;
    [self getBarIndexConstructRequest];
    
}

//上提加载更多
-(void)loadMoreData{
    [self.mainSrollView.mj_header endRefreshing];
    self.page ++;
    [self reqeustMoreGoodsListData];
}

//下拉过程
-(void)scrollViewDidScroll:(UIScrollView *)scrollView{
    CGFloat offsetY = scrollView.contentOffset.y;
    [[NSNotificationCenter defaultCenter] postNotificationName:@"changeHeightNotice" object:nil userInfo:@{@"offset":[NSString stringWithFormat:@"%f",offsetY]}];
}

#pragma mark -- action/delegate
//精选商品点击事件（formatDemoView）
-(void)clickFormatGoodIndex:(NSDictionary *)dic{
    dic = [HDToolHelper nullDicToDic:dic];
    if ([dic[@"specialType"] isEqualToString:@"goodsType"]) {
        HDTaoMallSubCommonViewController *subCommonVC = [HDTaoMallSubCommonViewController new];
        subCommonVC.cid = dic[@"specialTypeValue"];
        subCommonVC.subTitle = dic[@"title"];
        [self.navigationController pushViewController:subCommonVC animated:YES];
    }else if ([dic[@"specialType"] isEqualToString:@"ahref"] || [dic[@"specialType"] isEqualToString:@"custom"]) {//超级链接、自定义链接
        HDWebViewController *webVC = [[HDWebViewController alloc] init];
        webVC.url_str = dic[@"specialTypeValue"];
        webVC.title_str = dic[@"title"];
        [self.navigationController pushViewController:webVC animated:YES];
    }
}

//商品详情
-(void)clickGoodsInfo:(NSString *)taoId{
    DTLog(@"%@",taoId);
    HDTaoGoodsDetailViewController *detailVC = [HDTaoGoodsDetailViewController new];
    detailVC.taoId = taoId;
    detailVC.indexTab = 1;
    [self.navigationController pushViewController:detailVC animated:YES];
}

//楼层商品详情
-(void)clickFloorGoodsMore:(NSDictionary *)dicFloor dicTime:(NSDictionary * _Nullable)timeDic{
    DTLog(@"%@",dicFloor);
    if ([[HDUserDefaultMethods getData:@"userId"] isEqualToString:@""]) {
        [HDToolHelper preToLoginView];
        return;
    }
    HDTaoMallFloorDetailViewController *floorVC = [HDTaoMallFloorDetailViewController new];
    floorVC.dicFloor = dicFloor;
    floorVC.dicTime = timeDic;
    [self.navigationController pushViewController:floorVC animated:YES];
}

//轮播跳转
- (void)cycleScrollView:(SDCycleScrollView *)cycleScrollView didSelectItemAtIndex:(NSInteger)index{
    NSDictionary *dic = self.indexModel.bannerVoList[index];
    if ([dic[@"bannerType"] isEqualToString:@"ahref"] || [dic[@"bannerType"] isEqualToString:@"custom"]) {//超级链接、自定义链接
        HDWebViewController *webVC = [[HDWebViewController alloc] init];
        webVC.url_str = dic[@"bannerTypeValue"];
        webVC.title_str = dic[@"bannerTitle"];
        [self.navigationController pushViewController:webVC animated:YES];
    }
    if ([dic[@"bannerType"] isEqualToString:@"single"]) {//商品
        HDTaoGoodsDetailViewController *detailVC = [HDTaoGoodsDetailViewController new];
        detailVC.taoId = dic[@"bannerTypeValue"];
        detailVC.indexTab = 1;
        [self.navigationController pushViewController:detailVC animated:YES];
    }
}

//菜单icon点击
-(void)tapIconAction:(UIGestureRecognizer *)sender{
    NSInteger index = sender.view.tag-1000;
    if (index >= self.iconsArr.count) {
        return;
    }
    NSDictionary *dic = self.iconsArr[sender.view.tag-1000];
    dic = [HDToolHelper nullDicToDic:dic];
    DTLog(@"%@",dic);
    //商品列表
    if ([dic[@"iconType"] isEqualToString:@"goodsType"]) {
        HDTaoMallSubIconGoodsViewController *iconVC = [HDTaoMallSubIconGoodsViewController new];
        iconVC.subTitle = dic[@"iconTitle"];
        iconVC.iconId = dic[@"id"];
        [self.navigationController pushViewController:iconVC animated:YES];
    }
    //网页
    else{
        if ([dic[@"iconType"] isEqualToString:@"ahref"] || [dic[@"iconType"] isEqualToString:@"custom"]) {//超级链接、自定义链接
            HDWebViewController *webVC = [[HDWebViewController alloc] init];
            webVC.url_str = dic[@"iconTypeValue"];
            webVC.title_str = dic[@"iconTitle"];
            [self.navigationController pushViewController:webVC animated:YES];
        }else{
            HDTaoMallSubIconGoodsViewController *iconVC = [HDTaoMallSubIconGoodsViewController new];
            iconVC.subTitle = dic[@"iconTitle"];
            iconVC.iconId = dic[@"id"];
            [self.navigationController pushViewController:iconVC animated:YES];
        }
    }
}

#pragma mark -- 数据请求
//请求页面结构
-(void)getBarIndexConstructRequest{
    NSMutableDictionary *params = [NSMutableDictionary new];
    [params setValue:self.index_id forKey:@"id"];
    [params setValue:self.position_code forKey:@"positionCode"];
    if (![[HDUserDefaultMethods getData:@"userId"] isEqualToString:@""]) {
        [params setValue:[HDUserDefaultMethods getData:@"userId"] forKey:@"userId"];
    }
    WeakSelf;
    [MHNetworkManager postReqeustWithURL:URL_TaoBarIndex params:params successBlock:^(NSDictionary *returnData) {
        DTLog(@"%@",returnData);
        [self.mainSrollView.mj_header endRefreshing];
        
        if ([returnData[@"respCode"] integerValue] == 200) {
            self.indexModel = [HDTaoHomeStructModel mj_objectWithKeyValues:[HDToolHelper nullDicToDic:returnData[@"data"]]];
            
            //首页轮播图
            [self.bannerImageUrls removeAllObjects];
            if (self.indexModel.bannerVoList.count > 0) {
                weakSelf.bannerView.hidden = NO;
                weakSelf.menuBtnsView.y = weakSelf.bannerView.bottom+8;
                
                for (NSDictionary *dic in self.indexModel.bannerVoList) {
                    [self.bannerImageUrls addObject:dic[@"bannerPic"]];
                }
                weakSelf.bannerView.imageURLStringsGroup = self.bannerImageUrls;
            }else{
                weakSelf.bannerView.hidden = YES;
                weakSelf.menuBtnsView.y = 0;
            }
            
            //菜单
            [self.iconsArr removeAllObjects];
            if (self.indexModel.iconVoList.count > 0) {
                [self.iconsArr addObjectsFromArray:self.indexModel.iconVoList];
            }
            [self createIconMenuList:self.iconsArr];
            self.jingxuanView.y = self.menuBtnsView.bottom;
            //更新容器高度
            weakSelf.mainSrollView.contentSize = CGSizeMake(kSCREEN_WIDTH, self.jingxuanView.bottom+16);
            
            //精选
            if (self.indexModel.formatDemoVoList.count > 0) {
                self.jingxuanView.arrList = self.indexModel.formatDemoVoList;
                self.jingxuanView.delegate = self;
                
                self.floorVoView.y = self.jingxuanView.bottom;
                //更新容器高度
                weakSelf.mainSrollView.contentSize = CGSizeMake(kSCREEN_WIDTH, self.floorVoView.bottom+16);
            }else{
                self.jingxuanView.height = 8;
                self.floorVoView.y = self.jingxuanView.bottom;
                //更新容器高度
                weakSelf.mainSrollView.contentSize = CGSizeMake(kSCREEN_WIDTH, self.floorVoView.bottom+16);
            }
            
            //楼层
            if (self.indexModel.floorVoList.count > 0) {
                self.floorVoView.arrData = self.indexModel.floorVoList;
                //更新容器高度
                weakSelf.mainSrollView.contentSize = CGSizeMake(kSCREEN_WIDTH, self.floorVoView.bottom+16);
                
                //底部商品列表
                for (NSDictionary *dic in self.indexModel.floorVoList) {
                    if ([dic[@"floorType"] isEqualToString:@"goodsType"]) {
                        self.dicGoodsList = dic;
                        
                        [self.goodsArr removeAllObjects];
                        
                        NSArray *arr = [HDTaoGoodsModel mj_objectArrayWithKeyValuesArray:dic[@"goodsList"]];
                        [self.goodsArr addObjectsFromArray:arr];
                        
                        self.titleView.height = 56;
                        self.titleView.y = self.floorVoView.bottom;
                        
                        NSMutableAttributedString *string = [[NSMutableAttributedString alloc] initWithString:dic[@"floorTitle"] attributes: @{NSFontAttributeName: TEXT_SC_TFONT(TEXT_SC_Medium, 21),NSForegroundColorAttributeName: RGBTEXT}];
                        self.lblMenuTitle.attributedText = string;
                        
                        self.goodsCollectView.y = self.titleView.bottom;
                        
                        [self.goodsCollectView reloadData];
                        CGFloat height = self.goodsCollectView.collectionViewLayout.collectionViewContentSize.height;
                        self.goodsCollectView.height = height;
                        
                        //更新容器高度
                        weakSelf.mainSrollView.contentSize = CGSizeMake(kSCREEN_WIDTH, self.goodsCollectView.bottom+16);
                    }
                }
            }else{
                self.floorVoView.arrData = @[];
                self.floorVoView.height = 0;
                self.titleView.height = 0;
                self.titleView.y = self.floorVoView.bottom;
                self.goodsCollectView.y = self.titleView.bottom;
                [self.goodsArr removeAllObjects];
                [self.goodsCollectView reloadData];
                self.goodsCollectView.height = 0;
                //更新容器高度
                weakSelf.mainSrollView.contentSize = CGSizeMake(kSCREEN_WIDTH, self.goodsCollectView.bottom+16);
            }
        }
    } failureBlock:^(NSError *error) {
        
    } showHUD:YES];
}

#pragma mark ================== 商品楼层数据加载更多 =====================
-(void)reqeustMoreGoodsListData{
    if (!self.dicGoodsList) {
        [self.mainSrollView.mj_footer endRefreshingWithNoMoreData];
        return;
    }
    NSDictionary *params = @{
        @"page":@{
                @"pageIndex":@(self.page),
                @"pageSize":@(20)
        },
        @"id":self.dicGoodsList[@"id"],
        @"floorType":self.dicGoodsList[@"floorType"],
        @"floorTypeValue":self.dicGoodsList[@"floorTypeValue"]
    };
    WeakSelf;
    [MHNetworkManager postReqeustWithURL:URL_TaoFloorGoodsList params:params successBlock:^(NSDictionary *returnData) {
        DTLog(@"%@",returnData);
        [weakSelf.mainSrollView.mj_footer endRefreshing];
        
        if ([returnData[@"respCode"] integerValue] == 200) {
            NSArray *arr = [HDTaoGoodsModel mj_objectArrayWithKeyValuesArray:returnData[@"data"]];
            [self.goodsArr addObjectsFromArray:arr];
            
            [self.goodsCollectView reloadData];
            CGFloat height = self.goodsCollectView.collectionViewLayout.collectionViewContentSize.height;
            self.goodsCollectView.height = height;
            
            //更新容器高度
            weakSelf.mainSrollView.contentSize = CGSizeMake(kSCREEN_WIDTH, self.goodsCollectView.bottom+16);
        }else{
            self.page --;
        }
    } failureBlock:^(NSError *error) {
        
    } showHUD:NO];
}

#pragma mark ================== collectionView delegate datasource =====================
-(NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section{
    return self.goodsArr.count;
}

-(CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath{
    return CGSizeMake((kSCREEN_WIDTH-32)/2, 283*SCALE);
}

-(UIEdgeInsets)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout insetForSectionAtIndex:(NSInteger)section{
    return UIEdgeInsetsMake(8, 12, 8, 12);
}

-(CGFloat)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout minimumLineSpacingForSectionAtIndex:(NSInteger)section{
    return 8;//可以根据section 设置不同section item的行间距
}
- (CGFloat)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout minimumInteritemSpacingForSectionAtIndex:(NSInteger)section{
    return 8;// 可以根据section 设置不同section item的列间距
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath{
    //cell的重用，在设置UICollectionView 中注册了cell
    HDTaoGoodsCollectionViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:NSStringFromClass([HDTaoGoodsCollectionViewCell class]) forIndexPath:indexPath];
    cell.model = self.goodsArr[indexPath.item];
    return cell;
}

-(void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath{
    HDTaoGoodsModel *model = self.goodsArr[indexPath.item];
    HDTaoGoodsDetailViewController *detailVC = [HDTaoGoodsDetailViewController new];
    detailVC.taoId = model.taoId;
    detailVC.indexTab = 1;
    [self.navigationController pushViewController:detailVC animated:YES];
}

#pragma mark ================== createUI =====================
//主视图
-(UIScrollView *)mainSrollView{
    if (!_mainSrollView) {
        _mainSrollView = [[UIScrollView alloc] initWithFrame:CGRectMake(0, 0, kSCREEN_WIDTH, kSCREEN_HEIGHT-48-NAVHIGHT-KTarbarHeight)];
        _mainSrollView.backgroundColor = [UIColor clearColor];
        _mainSrollView.delegate = self;
    }
    return _mainSrollView;
}

#pragma mark ================== 轮播 =====================
-(SDCycleScrollView *)bannerView{
    if (!_bannerView) {
        SDCycleScrollView *cycleScrollView = [SDCycleScrollView cycleScrollViewWithFrame:CGRectMake(24, 8, kSCREEN_WIDTH-48, 143) delegate:self placeholderImage:[UIImage imageNamed:@""]];
        cycleScrollView.delegate = self;
        cycleScrollView.bannerImageViewContentMode = UIViewContentModeScaleAspectFill;
        cycleScrollView.layer.cornerRadius = 12;
        cycleScrollView.autoScrollTimeInterval = 3;
        cycleScrollView.layer.masksToBounds = YES;
        cycleScrollView.backgroundColor = [UIColor clearColor];
//        cycleScrollView.pageControlStyle = SDCycleScrollViewPageContolStyleAnimated;
        cycleScrollView.currentPageDotColor = RGBMAIN;
//        cycleScrollView.currentPageDotImage = [UIImage imageNamed:@"evaluation_s_selected"];
//        cycleScrollView.pageDotImage = [UIImage imageNamed:@"evaluation_s_nor"];
        
        _bannerView = cycleScrollView;
    }
    return _bannerView;
}

#pragma mark ================== 菜单 =====================
-(UIView *)menuBtnsView{
    if (!_menuBtnsView) {
        _menuBtnsView = [[UIScrollView alloc] initWithFrame:CGRectMake(0, _bannerView.bottom+8, kSCREEN_WIDTH, 0)];
        _menuBtnsView.backgroundColor = [UIColor whiteColor];
    }
    return _menuBtnsView;
}

#pragma mark ================== 精选 =====================
-(HDTaoHomeFormatDemoView *)jingxuanView{
    if (!_jingxuanView) {
        _jingxuanView = [[HDTaoHomeFormatDemoView alloc] initWithFrame:CGRectMake(0, _menuBtnsView.bottom, kSCREEN_WIDTH, 1)];
        _jingxuanView.backgroundColor = [UIColor whiteColor];
    }
    return _jingxuanView;
}

//floorVoList 楼层
-(HDTaoFloorView *)floorVoView{
    if (!_floorVoView) {
        _floorVoView = [[HDTaoFloorView alloc] initWithFrame:CGRectMake(0, _jingxuanView.bottom, kSCREEN_WIDTH, 1)];
        _floorVoView.backgroundColor = [UIColor whiteColor];
        _floorVoView.delegate = self;
    }
    return _floorVoView;
}

//今日上新菜单视图
-(UIView *)titleView{
    if (!_titleView) {
        _titleView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, kSCREEN_WIDTH, 0)];
        _titleView.backgroundColor = RGBBG;
        
        UILabel *lblTitle = [[UILabel alloc] initWithFrame:CGRectMake(12, 20, _titleView.width-24, 22)];
        [_titleView addSubview:lblTitle];
        self.lblMenuTitle = lblTitle;
    }
    return _titleView;
}

//底部商品列表
-(UICollectionView *)goodsCollectView{
    if (!_goodsCollectView) {
        UICollectionViewFlowLayout *layout = [[UICollectionViewFlowLayout alloc] init];
        _goodsCollectView = [[UICollectionView alloc] initWithFrame:CGRectMake(0, _floorVoView.bottom, kSCREEN_WIDTH, 0) collectionViewLayout:layout];
        _goodsCollectView.delegate = self;
        _goodsCollectView.dataSource = self;
        
        _goodsCollectView.bounces = NO;
        _goodsCollectView.backgroundColor = RGBBG;
        [_goodsCollectView registerClass:[HDTaoGoodsCollectionViewCell class] forCellWithReuseIdentifier:NSStringFromClass([HDTaoGoodsCollectionViewCell class])];
    }
    return _goodsCollectView;
}

#pragma mark -- 创建菜单按钮视图
-(void)createIconMenuList:(NSArray *)arrMenu{
    for (UIView *viewq in [_menuBtnsView subviews]) {
        [viewq removeFromSuperview];
    }
    _menuBtnsView.height = 0;
    
    for (int i=0; i<arrMenu.count; i++) {
        NSDictionary *dic = arrMenu[i];
        UIView *viewBtn = [[UIView alloc] initWithFrame:CGRectMake(0, 0, kSCREEN_WIDTH/5, 8+48+8+12+8)];
        viewBtn.tag = 1000+i;
        viewBtn.backgroundColor = [UIColor whiteColor];
        
        //添加点击动作
        UITapGestureRecognizer *tapIcon = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapIconAction:)];
        viewBtn.userInteractionEnabled = YES;
        [viewBtn addGestureRecognizer:tapIcon];
        
        UIImageView *image = [[UIImageView alloc] initWithFrame:CGRectMake(0, 8, 48, 48)];
        [image sd_setImageWithURL:[NSURL URLWithString:dic[@"iconPic"]]];
        image.centerX = viewBtn.width/2;
        [viewBtn addSubview:image];
        
        UILabel *menuLbl = [[UILabel alloc] initCommonWithFrame:CGRectMake(8, image.bottom+8, viewBtn.width-16, 12) title:dic[@"iconTitle"] bgColor:[UIColor clearColor] titleColor:RGBLIGHT_TEXTINFO titleFont:12 textAlignment:NSTextAlignmentCenter isFit:NO];
        [viewBtn addSubview:menuLbl];
        
        UIView *viewBtnLast = (UIView *)[_menuBtnsView viewWithTag:1000+i-1];
        
        if (i == 0) {
            viewBtn.x = 0;
            viewBtn.y = 0;
        }else{
            viewBtn.x = CGRectGetMaxX(viewBtnLast.frame);
            if (CGRectGetMaxX(viewBtn.frame) > kSCREEN_WIDTH) {
                viewBtn.x = 0;
                viewBtn.y = CGRectGetMaxY(viewBtnLast.frame);
            }else{
                viewBtn.y = viewBtnLast.y;
            }
        }
        
        [_menuBtnsView addSubview:viewBtn];
        _menuBtnsView.height = viewBtn.bottom;
    }
}

@end
