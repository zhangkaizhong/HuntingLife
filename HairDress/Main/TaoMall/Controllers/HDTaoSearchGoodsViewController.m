//
//  HDTaoSearchGoodsViewController.m
//  HairDress
//
//  Created by 张凯中 on 2020/3/3.
//  Copyright © 2020 zhangkaizhong. All rights reserved.
//

#import "HDTaoSearchGoodsViewController.h"
#import "HDTaoMallSubCommonViewController.h"
#import "HDWebViewController.h"
#import "HDTaoGoodsDetailViewController.h"
#import "HDTaoGoodsCollectionViewCell.h"
#import "HDTaoGoodsDetailViewController.h"

#import <SDCycleScrollView.h>

@interface HDTaoSearchGoodsViewController ()<navViewDelegate,UITextFieldDelegate,SDCycleScrollViewDelegate,UICollectionViewDelegate,UICollectionViewDataSource,UICollectionViewDelegateFlowLayout>

@property (nonatomic,strong) HDBaseNavView *navView;
@property (nonatomic,strong) UIScrollView *mainScrollView;
@property (nonatomic,strong) UICollectionView *collectView;
@property (nonatomic,strong) UIView *searchView;
@property (nonatomic,strong) UIView *searchResultView;

@property (nonatomic,strong) UIView *tagsView;//热门标签视图
@property (nonatomic,strong) UIView *blockView;
@property (nonatomic,strong) UIView *buttonMenuView;
@property (nonatomic,strong) SDCycleScrollView * bannerView;  // 滚动视图

@property (nonatomic,strong) NSMutableArray *bannerListArray;
@property (nonatomic,strong) NSMutableArray *imageArray;
@property (nonatomic,strong) NSMutableArray *dataHotItemsArr;

@property (nonatomic,assign) NSInteger page;
@property (nonatomic,strong) NSMutableArray *arrGoodsData;//商品列表

@property (nonatomic,copy) NSString *searchType;//搜全网，或app
@property (nonatomic,copy) NSString *isCoupon;//只看有券
@property (nonatomic,copy) NSString *isTM;//只看天猫
@property (nonatomic,copy) NSString *sortType;//排序类型

@end

@implementation HDTaoSearchGoodsViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.dataHotItemsArr = [NSMutableArray new];
    self.imageArray = [NSMutableArray new];
    self.bannerListArray = [NSMutableArray new];
    self.arrGoodsData = [NSMutableArray new];
    
    self.page = 1;
    self.searchType = @"app";
    self.isCoupon = @"0";
    self.isTM = @"";
    self.sortType = @"new";
    
    [self.view addSubview:self.navView];
    [self.view addSubview:self.buttonMenuView];
    [self.view addSubview:self.mainScrollView];
    
    [self requestHomeBannerList];
}

#pragma mark - 添加刷新控件
-(void)setupRefresh{
    self.collectView.mj_header = [MJRefreshNormalHeader headerWithRefreshingTarget:self refreshingAction:@selector(loadNewData)];
    self.collectView.mj_footer = [MJRefreshBackNormalFooter footerWithRefreshingTarget:self refreshingAction:@selector(loadMoreData)];
}

//下拉刷新数据
-(void)loadNewData{
    [self.collectView.mj_footer endRefreshing];
    self.page = 1;
    [self getSearchGoodsList:NO];
}

//上提加载更多
-(void)loadMoreData{
    [self.collectView.mj_header endRefreshing];
    self.page ++;
    [self getSearchGoodsList:YES];
}

//首页banner点击
- (void)cycleScrollView:(SDCycleScrollView *)cycleScrollView didSelectItemAtIndex:(NSInteger)index{
    NSDictionary *dic = self.bannerListArray[index];
    if ([dic[@"bannerType"] isEqualToString:@"ahref"] || [dic[@"bannerType"] isEqualToString:@"custom"]) {//超级链接、自定义链接
        HDWebViewController *webVC = [[HDWebViewController alloc] init];
        webVC.url_str = dic[@"bannerTypeValue"];
        webVC.title_str = dic[@"bannerTitle"];
        [self.navigationController pushViewController:webVC animated:YES];
    }
    if ([dic[@"bannerType"] isEqualToString:@"single"]) {//商品
        HDTaoGoodsDetailViewController *detailVC = [HDTaoGoodsDetailViewController new];
        detailVC.taoId = dic[@"bannerTypeValue"];
        detailVC.indexTab = 0;
        [self.navigationController pushViewController:detailVC animated:YES];
    }
}

//获取热门标签
-(void)getHotSearchGoodsItems{
    [MHNetworkManager postReqeustWithURL:URL_TaoHotSearchList1 params:@{} successBlock:^(NSDictionary *returnData) {
        
        if ([returnData[@"respCode"] integerValue] == 200) {
            [self.dataHotItemsArr addObjectsFromArray:returnData[@"data"]];
            [self createTags];
            if (self.imageArray.count == 0) {
                self.bannerView.height = 0;
                self.tagsView.y = 0;
            }
            self.searchView.height = self.tagsView.bottom;
            self.mainScrollView.contentSize = CGSizeMake(kSCREEN_WIDTH, self.searchView.bottom);
        }
    } failureBlock:^(NSError *error) {
        
    } showHUD:YES];
}

#pragma mark ================== 首页轮播列表 =====================
-(void)requestHomeBannerList{
    NSString *userId = [HDUserDefaultMethods getData:@"userId"];
    NSMutableDictionary *params = [NSMutableDictionary new];
    [params setValue:@"allSearch" forKey:@"positionCode"];
    if (![HDToolHelper StringIsNullOrEmpty:userId]) {
        [params setValue:userId forKey:@"userId"];
    }
    [MHNetworkManager postReqeustWithURL:URL_GetBannarList params:params successBlock:^(NSDictionary *returnData) {
        returnData = [HDToolHelper nullDicToDic:returnData];
        if ([returnData[@"respCode"] integerValue] == 200) {
            [self.bannerListArray removeAllObjects];
            [self.imageArray removeAllObjects];
            [self.bannerListArray addObjectsFromArray:returnData[@"data"]];
            for (NSDictionary *dicPic in self.bannerListArray) {
                [self.imageArray addObject:dicPic[@"bannerPic"]];
            }
            self.bannerView.imageURLStringsGroup = self.imageArray;
            [self getHotSearchGoodsItems];
        }
    } failureBlock:^(NSError *error) {
        
    } showHUD:NO];
}

#pragma mark -- delegate Action
-(void)navBackClicked{
    [self.navigationController popViewControllerAnimated:YES];
}

//切换搜索
-(void)btnSelectedAction:(UIButton *)sender{
    [_navView.txtSearch resignFirstResponder];
    
    sender.selected = !sender.selected;
    
    NSInteger tagBtn = sender.tag;
    
    for (int i=0; i<2; i++) {
        UIButton *btn = (UIButton *)[_buttonMenuView viewWithTag:100+i];
        btn.selected = NO;
    }
    
    UIButton *btn = (UIButton *)[_buttonMenuView viewWithTag:tagBtn];
    btn.selected = YES;
    [UIView animateWithDuration:0.3 animations:^{
        self.blockView.x = btn.x;
    }];
    
    if ([btn.titleLabel.text isEqualToString:@"搜APP"]) {
        self.searchType = @"app";
    }else{
        self.searchType = @"tb";
    }
    
    if ([_navView.txtSearch.text isEqualToString:@""]) {
        return;
    }
    //刷新数据
    [self loadNewData];
}

//排序筛选
-(void)btnSortSelectedAction:(UIButton *)sender{
    [_navView.txtSearch resignFirstResponder];
    for (int i=0; i<3; i++) {
        UIButton *btn = (UIButton *)[_searchResultView viewWithTag:100+i];
        btn.selected = NO;
        if (i==2 || i==1) {
            [btn setImage:[UIImage imageNamed:@"paixujiantouxia"] forState:UIControlStateNormal];
        }
    }
    
    NSInteger tagBtn = sender.tag;
    UIButton *btn = (UIButton *)[_searchResultView viewWithTag:tagBtn];
    btn.selected = YES;
    if (tagBtn == 102) {
        if ([self.sortType isEqualToString:@"price_asc"]) {
            //价格从高到低
            self.sortType = @"price_desc";
            [btn setImage:[UIImage imageNamed:@"paixujiantou_down"] forState:UIControlStateNormal];
        }else{
            //价格从低到高
            self.sortType = @"price_asc";
            [btn setImage:[UIImage imageNamed:@"paixujiantou_up"] forState:UIControlStateNormal];
        }
    }else{
        if (tagBtn == 101) {
            if ([self.sortType isEqualToString:@"sale_num_asc"]) {
                //价格从高到低
                self.sortType = @"sale_num_desc";
                [btn setImage:[UIImage imageNamed:@"paixujiantou_down"] forState:UIControlStateNormal];
            }else{
                //价格从低到高
                self.sortType = @"sale_num_asc";
                [btn setImage:[UIImage imageNamed:@"paixujiantou_up"] forState:UIControlStateNormal];
            }
        }
        if (tagBtn == 100) {
            self.sortType = @"new";
        }
    }
    if ([_navView.txtSearch.text isEqualToString:@""]) {
        return;
    }
    //刷新数据
    [self loadNewData];
}

//只看有券
-(void)btnCouponAction:(UIButton *)sender{
    [_navView.txtSearch resignFirstResponder];
    sender.selected = !sender.selected;
    if (sender.selected) {
        self.isCoupon = @"1";
        sender.backgroundColor = RGBMAIN;
        [sender setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    }else{
        self.isCoupon = @"";
        sender.backgroundColor = RGBCOLOR(242, 238, 237);
        [sender setTitleColor:RGBCOLOR(15, 14, 12) forState:UIControlStateNormal];
    }
    if ([_navView.txtSearch.text isEqualToString:@""]) {
        return;
    }
    //刷新数据
    [self loadNewData];
}

//只看有券
-(void)btnTMAction:(UIButton *)sender{
    [_navView.txtSearch resignFirstResponder];
    sender.selected = !sender.selected;
    if (sender.selected) {
        self.isTM = @"tmall";
        
        sender.backgroundColor = RGBMAIN;
        [sender setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    }else{
        self.isTM = @"";
        sender.backgroundColor = RGBCOLOR(242, 238, 237);
        [sender setTitleColor:RGBCOLOR(15, 14, 12) forState:UIControlStateNormal];
    }
    if ([_navView.txtSearch.text isEqualToString:@""]) {
        return;
    }
    //刷新数据
    [self loadNewData];
}

//搜索
-(void)navRightClicked{
    if ([_navView.txtSearch.text isEqualToString:@""]) {
        [SVHUDHelper showWorningMsg:@"请输入搜索关键字" timeInt:1];
        return;
    }
    [_navView.txtSearch resignFirstResponder];
    
    [self getSearchGoodsList:NO];
}

//加载搜索商品列表
-(void)getSearchGoodsList:(BOOL)more{
    NSDictionary *params = @{
        @"page":@{
                @"pageIndex":@(self.page),
                @"pageSize":@(20)
        },
        @"q":_navView.txtSearch.text,
        @"sort":self.sortType,
        @"searchType":self.searchType,
        @"tj":self.isTM,
        @"youquan":self.isCoupon
    };
    [MHNetworkManager postReqeustWithURL:URL_TaoGoodsSearch params:params successBlock:^(NSDictionary *returnData) {
        returnData = [HDToolHelper nullDicToDic:returnData];
        if ([returnData[@"respCode"] integerValue] == 200) {
            if (more) {
                [self.collectView.mj_footer endRefreshing];
            }else{
                [self.arrGoodsData removeAllObjects];
                [self.collectView.mj_header endRefreshing];
            }
            NSArray *arr = [HDTaoGoodsModel mj_objectArrayWithKeyValuesArray:returnData[@"data"]];
            [self.arrGoodsData addObjectsFromArray:arr];
            [self.collectView reloadData];
            if (self.arrGoodsData.count > 0) {
                self.viewEmpty.hidden = YES;

                self.searchView.hidden = YES;
                self.searchResultView.hidden = NO;
                self.mainScrollView.contentSize = CGSizeMake(kSCREEN_WIDTH, self.searchResultView.bottom);
            }else{
                [self.collectView addSubview:self.viewEmpty];
                self.viewEmpty.hidden = NO;
            }
        }else{
            if (more) {
                self.page --;
                [self.collectView.mj_footer endRefreshing];
            }else{
                [self.collectView.mj_header endRefreshing];
            }
        }
    } failureBlock:^(NSError *error) {
        if (more) {
            self.page --;
            [self.collectView.mj_footer endRefreshing];
        }else{
            [self.collectView.mj_header endRefreshing];
        }
    } showHUD:YES];
}

//热门标签搜索
-(void)tapSearchTagAction:(UIGestureRecognizer *)sender{
    UILabel *lblTag = (UILabel *)sender.view;
    _navView.txtSearch.text = lblTag.text;
    [self getSearchGoodsList:NO];
//    HDTaoMallSubCommonViewController *searchVC = [HDTaoMallSubCommonViewController new];
//    searchVC.keyWords = lblTag.text;
//    searchVC.subTitle = lblTag.text;
//    [self.navigationController pushViewController:searchVC animated:YES];
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

//点击单元格
-(void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath{
    HDTaoGoodsModel *model = self.arrGoodsData[indexPath.item];
    HDTaoGoodsDetailViewController *detailVC = [HDTaoGoodsDetailViewController new];
    detailVC.taoId = model.taoId;
    detailVC.indexTab = 1;
    [self.navigationController pushViewController:detailVC animated:YES];
}

#pragma mark -- UITEXTFIELD DELEGATE
-(BOOL)textFieldShouldClear:(UITextField *)textField{
    if (self.arrGoodsData.count == 0) {
        _searchResultView.hidden = YES;
        _searchView.hidden = NO;
        self.mainScrollView.contentSize = CGSizeMake(kSCREEN_WIDTH, self.searchView.bottom);
    }
    return YES;
}

#pragma mark -- 加载控件

-(UIScrollView *)mainScrollView{
    if (!_mainScrollView) {
        _mainScrollView = [[UIScrollView alloc] initWithFrame:CGRectMake(0, _buttonMenuView.bottom, kSCREEN_WIDTH, kSCREEN_HEIGHT-_buttonMenuView.bottom)];
        _mainScrollView.backgroundColor = [UIColor clearColor];
        
        [_mainScrollView addSubview:self.searchView];
        [_mainScrollView addSubview:self.searchResultView];
    }
    return _mainScrollView;
}

-(UIView *)searchView{
    if (!_searchView) {
        _searchView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, kSCREEN_WIDTH, 100)];
        
        [_searchView addSubview:self.bannerView];
        [_searchView addSubview:self.tagsView];
    }
    return _searchView;
}

-(HDBaseNavView *)navView{
    if (!_navView) {
        _navView = [[HDBaseNavView alloc] initSearchBarWithButtonsFrame:CGRectMake(0, 0, kSCREEN_WIDTH, NAVHIGHT) bgColor:[UIColor whiteColor] textColor:[UIColor clearColor] searchViewColor:RGBAlpha(245, 245, 245, 1) btnTitle:@"搜索" placeHolder:@"搜索商品名或粘贴宝贝标题" theDelegate:self];
        UIView *searchView = (UIView *)[_navView viewWithTag:10000];
        UIImageView *imageSearch = (UIImageView *)[searchView viewWithTag:100];
        HDTextFeild *txtSearch = (HDTextFeild *)[searchView viewWithTag:200];
        UIButton *backBtn = (UIButton *)[_navView viewWithTag:20000];
        UIButton *rightBtn = (UIButton *)[_navView viewWithTag:30000];
        
        txtSearch.delegate = self;
        
        searchView.y = NAVHIGHT - 6*SCALE - 32*SCALE;
        searchView.x = 44*SCALE;
        searchView.width = kSCREEN_WIDTH - 44*SCALE - 12*SCALE;
        searchView.height = 32*SCALE;
        searchView.layer.cornerRadius = 16*SCALE;
        
        imageSearch.centerY = searchView.height/2;
        txtSearch.centerY = searchView.height/2;
        txtSearch.width = txtSearch.width - 10;
        
        backBtn.width = 44*SCALE;
        backBtn.centerY = searchView.centerY;
        
        rightBtn.x = kSCREEN_WIDTH - 12*SCALE - 64*SCALE;
        rightBtn.width = 64*SCALE;
        rightBtn.height = 32*SCALE;
        rightBtn.y = searchView.y;
        
        CGFloat corner = 16*SCALE;
        CAShapeLayer *shapeLayer = [CAShapeLayer layer];
        shapeLayer.path = [UIBezierPath bezierPathWithRoundedRect:rightBtn.bounds byRoundingCorners:UIRectCornerTopRight | UIRectCornerBottomRight cornerRadii:CGSizeMake(corner, corner)].CGPath;
        rightBtn.layer.mask = shapeLayer;
        
        rightBtn.backgroundColor = RGBMAIN;
        [rightBtn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    }
    return _navView;
}

//顶部按钮（搜app，搜全网）
-(UIView *)buttonMenuView{
    if (!_buttonMenuView) {
        _buttonMenuView = [[UIView alloc] initWithFrame:CGRectMake(0, _navView.bottom, kSCREEN_WIDTH, 45*SCALE)];
        _buttonMenuView.backgroundColor = [UIColor whiteColor];
        
        self.blockView = [[UIView alloc] initWithFrame:CGRectMake(0, _buttonMenuView.height-3, 50, 2)];
        self.blockView.backgroundColor = RGBMAIN;
        [_buttonMenuView addSubview:self.blockView];
        
        UIView *line = [[UIView alloc] initWithFrame:CGRectMake(0, _buttonMenuView.height-1, kSCREEN_WIDTH, 1)];
        line.backgroundColor = RGBCOLOR(245, 245, 245);
        [_buttonMenuView addSubview:line];
        
        NSArray *btns = @[@"搜APP",@"搜全网"];
        for (int i=0; i<btns.count; i++) {
            UIButton *btn = [[UIButton alloc] initSystemWithFrame:CGRectMake(44*SCALE+70*SCALE*i, 0, 64*SCALE, _buttonMenuView.height-3) btnTitle:btns[i] btnImage:@"" titleColor:RGBTEXT titleFont:14*SCALE];
            [btn setTitleColor:RGBMAIN forState:UIControlStateSelected];
            btn.titleLabel.font = TEXT_SC_TFONT(TEXT_SC_Medium, 14*SCALE);
            btn.tag = 100+i;
            if (i == 0) {
                btn.selected = YES;
                self.blockView.x = btn.x;
                self.blockView.width = btn.width;
            }
            [_buttonMenuView addSubview:btn];
            
            [btn addTarget:self action:@selector(btnSelectedAction:) forControlEvents:UIControlEventTouchUpInside];
        }
    }
    return _buttonMenuView;
}

//排序筛选视图
-(UIView *)searchResultView{
    if (!_searchResultView) {
        _searchResultView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, kSCREEN_WIDTH, _mainScrollView.height)];
        _searchResultView.hidden = YES;
        
        NSArray *btns = @[@"综合",@"销量",@"价格"];
        for (int i=0; i<btns.count; i++) {
            UIButton *btn = [[UIButton alloc] initCustomWithFrame:CGRectMake(28*SCALE+56*SCALE*i, 0, 30*SCALE, 40*SCALE) btnTitle:btns[i] btnImage:@"" btnType:RIGHT bgColor:[UIColor clearColor] titleColor:RGBCOLOR(17, 17, 17) titleFont:14*SCALE];
            [btn setTitleColor:RGBMAIN forState:UIControlStateSelected];
            btn.tag = 100+i;
            if (i == 0) {
                btn.selected = YES;
            }
            if (i==2 || i==1) {
                btn.width = 60*SCALE;
                [btn setImage:[UIImage imageNamed:@"paixujiantouxia"] forState:UIControlStateNormal];
            }
            [_searchResultView addSubview:btn];
            
            [btn addTarget:self action:@selector(btnSortSelectedAction:) forControlEvents:UIControlEventTouchUpInside];
        }
        
        UIView *line = [[UIView alloc] initWithFrame:CGRectMake(0, 40*SCALE, kSCREEN_WIDTH, 1)];
        line.backgroundColor = RGBCOLOR(245, 245, 245);
        [_searchResultView addSubview:line];
        
        //快捷筛选
        UILabel *lblText = [[UILabel alloc] initCommonWithFrame:CGRectMake(28*SCALE, line.bottom, 0, 52*SCALE) title:@"快捷筛选" bgColor:[UIColor clearColor] titleColor:RGBCOLOR(159, 143, 143) titleFont:12*SCALE textAlignment:NSTextAlignmentLeft isFit:YES];
        lblText.height = 52*SCALE;
        [_searchResultView addSubview:lblText];
        
        UIButton *btnCounpon = [[UIButton alloc] initSystemWithFrame:CGRectMake(CGRectGetMaxX(lblText.frame)+27*SCALE, 0, 68*SCALE, 28*SCALE) btnTitle:@"只看有券" btnImage:@"" titleColor:RGBCOLOR(15, 14, 12) titleFont:12*SCALE];
        btnCounpon.backgroundColor = RGBCOLOR(242, 238, 237);
        btnCounpon.layer.cornerRadius = 4;
        btnCounpon.centerY = lblText.centerY;
        [btnCounpon addTarget:self action:@selector(btnCouponAction:) forControlEvents:UIControlEventTouchUpInside];
        [_searchResultView addSubview:btnCounpon];
        
        UIButton *btnTM = [[UIButton alloc] initSystemWithFrame:CGRectMake(CGRectGetMaxX(btnCounpon.frame)+16*SCALE, 0, 68*SCALE, 28*SCALE) btnTitle:@"只看天猫" btnImage:@"" titleColor:RGBCOLOR(15, 14, 12) titleFont:12*SCALE];
        btnTM.backgroundColor = RGBCOLOR(242, 238, 237);
        btnTM.layer.cornerRadius = 4;
        btnTM.centerY = btnCounpon.centerY;
        [btnTM addTarget:self action:@selector(btnTMAction:) forControlEvents:UIControlEventTouchUpInside];
        [_searchResultView addSubview:btnTM];
        
        [_searchResultView addSubview:self.collectView];
        self.collectView.y = lblText.bottom;
        self.collectView.height = _mainScrollView.height - lblText.bottom;
        
        [self setupRefresh];
    }
    return _searchResultView;
}

- (UICollectionView *)collectView{
    if (!_collectView) {
        UICollectionViewFlowLayout *flowlayout = [[UICollectionViewFlowLayout alloc] init];
        _collectView = [[UICollectionView alloc] initWithFrame:CGRectMake(0 , 0, kSCREEN_WIDTH, 0) collectionViewLayout:flowlayout];
        _collectView.delegate = self;
        _collectView.dataSource = self;
        
        [_collectView setBackgroundColor:[UIColor clearColor]];
        
        //注册单元格
        [_collectView registerClass:[HDTaoGoodsCollectionViewCell class] forCellWithReuseIdentifier:NSStringFromClass([HDTaoGoodsCollectionViewCell class])];
    }
    return _collectView;
}

//banner
-(SDCycleScrollView *)bannerView{
    if (!_bannerView) {
        SDCycleScrollView *cycleScrollView = [SDCycleScrollView cycleScrollViewWithFrame:CGRectMake(0,0, kSCREEN_WIDTH, 130*SCALE) delegate:self placeholderImage:[UIImage imageNamed:@""]];
        cycleScrollView.delegate = self;
        cycleScrollView.autoScrollTimeInterval = 3;
        cycleScrollView.backgroundColor = [UIColor clearColor];
        cycleScrollView.currentPageDotColor = RGBMAIN;
        cycleScrollView.pageDotColor = [UIColor whiteColor];
        
        _bannerView = cycleScrollView;
    }
    return _bannerView;
}

-(UIView *)tagsView{
    if (!_tagsView) {
        _tagsView = [[UIView alloc] initWithFrame:CGRectMake(0, self.bannerView.bottom, kSCREEN_WIDTH, 0)];
    }
    return _tagsView;
}

//创建标签
-(void)createTags{
    if (self.dataHotItemsArr.count == 0) {
        return;
    }
    UILabel *lblTextHot = [[UILabel alloc] initCommonWithFrame:CGRectMake(16, 16, kSCREEN_WIDTH-32, 14) title:@"热门搜索" bgColor:[UIColor clearColor] titleColor:RGBTEXT titleFont:14 textAlignment:NSTextAlignmentLeft isFit:NO];
    [_tagsView addSubview:lblTextHot];
    
    //热门城市
    for (int i=0; i<self.dataHotItemsArr.count; i++) {
        
        CGFloat height_btn = 24;
        
        UILabel *lblTag = [[UILabel alloc] initCommonWithFrame:CGRectMake(16, lblTextHot.bottom+i*(100+16), kSCREEN_WIDTH, height_btn) title:self.dataHotItemsArr[i][@"keywords"] bgColor:[UIColor clearColor] titleColor:RGBTEXTINFO titleFont:12 textAlignment:NSTextAlignmentCenter isFit:YES];
        lblTag.width = lblTag.width + 30;
        lblTag.height = height_btn;
        
        UITapGestureRecognizer *tapTag = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapSearchTagAction:)];
        lblTag.userInteractionEnabled = YES;
        [lblTag addGestureRecognizer:tapTag];
        
        lblTag.tag = 100 + i;
        
        lblTag.layer.cornerRadius = 4;
        lblTag.layer.borderWidth = 1;
        lblTag.layer.borderColor = RGBBtnLayer.CGColor;
        
        UIView *lblLast = (UIView *)[_tagsView viewWithTag:100+i-1];
        
        if (i == 0) {
            lblTag.x = 16;
            lblTag.y = lblTextHot.bottom+16;
        }else{
            lblTag.x = CGRectGetMaxX(lblLast.frame)+16;
            if (CGRectGetMaxX(lblTag.frame)+15 > kSCREEN_WIDTH) {
                lblTag.x = 16;
                lblTag.y = CGRectGetMaxY(lblLast.frame)+8;
            }else{
                lblTag.y = lblLast.y;
            }
        }
        
        [_tagsView addSubview:lblTag];
        _tagsView.height = lblTag.bottom+16;
    }
}

@end
