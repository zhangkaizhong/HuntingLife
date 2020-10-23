//
//  HDSearchViewController.m
//  HairDress
//
//  Created by 张凯中 on 2019/12/21.
//  Copyright © 2019 zhangkaizhong. All rights reserved.
//

#import "HDSearchViewController.h"

#import "HDSearchShopsViewController.h"

#import "HDSearchCutterViewController.h"
#import "HDShopEvaluateViewController.h"

#import "ZJSegmentStyle.h"
#import "ZJScrollPageView.h"
#import "LrdSuperMenu.h"

@interface HDSearchViewController ()<navViewDelegate,ZJScrollPageViewDelegate,ZJScrollSegmentViewDelegate,LrdSuperMenuDataSource, LrdSuperMenuDelegate>

@property (nonatomic,strong)HDBaseNavView *navView;

@property (nonatomic,strong)LrdSuperMenu *menuView;
@property (nonatomic,weak) ZJScrollPageView *scrollPageView;
@property (nonatomic,strong) HDSearchShopsViewController *shopVC;
@property (nonatomic,strong) HDSearchCutterViewController *cutterVC;

@property (nonatomic, strong) NSMutableArray *nearByTradeArr;//商圈
@property (nonatomic, strong) NSArray *sortArr;//智能排序
@property (nonatomic, strong) NSMutableArray *servicesTypeArr;//服务类型

@property (nonatomic,copy) NSString *tradeStr;
@property (nonatomic,copy) NSString *serviceStr;
@property (nonatomic,copy) NSString *sortStr;
@property (nonatomic,copy) NSString *isStartSearch;//是否开始搜索
@property (nonatomic,copy) NSString *searchType;//门店或发型师

@end

@implementation HDSearchViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.nearByTradeArr = [NSMutableArray new];
    self.servicesTypeArr = [NSMutableArray new];
    
    self.tradeStr = @"";
    self.serviceStr = @"";
    self.sortStr = @"";
    self.searchType = @"1";
    self.isStartSearch = @"0";
    
    [self.view addSubview:self.navView];
    [self createScrollView];
    
    [self getTradeListData];
}

#pragma mark -- 数据请求
//获取商圈数据
-(void)getTradeListData{
    if (!self.cityName) {
        self.cityName = @"厦门市";
    }
    
    [MHNetworkManager postReqeustWithURL:URL_SearchQueryCityTrade params:@{@"name":self.cityName} successBlock:^(NSDictionary *returnData) {
        DTLog(@"%@",returnData);
        if ([returnData[@"respCode"] integerValue] == 200) {
            [self.nearByTradeArr removeAllObjects];
            NSArray *arr = returnData[@"data"];
            
            for (NSDictionary *dic in arr) {
                NSMutableDictionary *dicNew = [[NSMutableDictionary alloc] init];
                [dicNew setValue:dic[@"id"] forKey:@"id"];
                [dicNew setValue:dic[@"name"] forKey:@"name"];
                
                NSMutableArray *subArr = [NSMutableArray new];
                
                NSArray *arrDic = dic[@"tradeList"];
                
                [subArr addObject:@{@"id":dic[@"id"],@"name":dic[@"name"],@"num":@"-1"}];
                [subArr addObjectsFromArray:arrDic];
                
                [dicNew setValue:subArr forKey:@"tradeList"];
                [self.nearByTradeArr addObject:dicNew];
            }
            //获取服务类型数据
            [self getServiceTypesList];
        }
    } failureBlock:^(NSError *error) {
        
    } showHUD:YES];
}

//获取服务类型数据
-(void)getServiceTypesList{
    [MHNetworkManager postReqeustWithURL:URL_ConfigList params:@{@"configType":@"service_item"} successBlock:^(NSDictionary *returnData) {
        DTLog(@"%@",returnData);
        if ([returnData[@"respCode"] integerValue] == 200) {
            [self.servicesTypeArr removeAllObjects];
            [self.servicesTypeArr addObjectsFromArray:returnData[@"data"]];
            self.sortArr = @[@{@"name":@"距离优先",@"id":@"1"}, @{@"name":@"好评优先",@"id":@"2"}, @{@"name":@"低价优先",@"id":@"3"}, @{@"name":@"高价优先",@"id":@"4"}];
            //创建菜单
            [self createMenuView];
            
            self.scrollPageView.y = self.menuView.bottom;
            self.scrollPageView.height = kSCREEN_HEIGHT-self.menuView.height-NAVHIGHT;
        }
    } failureBlock:^(NSError *error) {
        
    } showHUD:YES];
}

#pragma mark -- 菜单代理
- (NSInteger)numberOfColumnsInMenu:(LrdSuperMenu *)menu {
    return 3;
}

- (NSInteger)menu:(LrdSuperMenu *)menu numberOfRowsInColumn:(NSInteger)column {
    if (column == 0) {
        return self.nearByTradeArr.count;
    }else if(column == 1) {
        return self.servicesTypeArr.count;
    }else {
        return self.sortArr.count;
    }
}

- (NSString *)menu:(LrdSuperMenu *)menu titleForRowAtIndexPath:(LrdIndexPath *)indexPath {
    if (indexPath.column == 0) {
        return [NSString stringWithFormat:@"  %@",self.nearByTradeArr[indexPath.row][@"name"]];
    }else if(indexPath.column == 1) {
        return [NSString stringWithFormat:@"  %@",self.servicesTypeArr[indexPath.row][@"configName"]];
    }else {
        return [NSString stringWithFormat:@"  %@",self.sortArr[indexPath.row][@"name"]];
    }
}

- (NSString *)menu:(LrdSuperMenu *)menu imageNameForRowAtIndexPath:(LrdIndexPath *)indexPath {
//    if (indexPath.column == 0 || indexPath.column == 1) {
//        return @"baidu";
//    }
    return nil;
}

- (NSString *)menu:(LrdSuperMenu *)menu imageForItemsInRowAtIndexPath:(LrdIndexPath *)indexPath {
//    if (indexPath.column == 0 && indexPath.item >= 0) {
//        return @"baidu";
//    }
    return nil;
}

- (NSString *)menu:(LrdSuperMenu *)menu detailTextForRowAtIndexPath:(LrdIndexPath *)indexPath {
//    if (indexPath.column != 0) {
//        return nil;
//    }
//    else if(indexPath.column < 2){
//        return [@(arc4random()%1000) stringValue];
//    }
    return nil;
}

- (NSString *)menu:(LrdSuperMenu *)menu detailTextForItemsInRowAtIndexPath:(LrdIndexPath *)indexPath {
    //右边菜单的数量
    NSArray *arrRight = self.nearByTradeArr[indexPath.row][@"tradeList"];
    if ([arrRight[indexPath.item][@"num"] integerValue] == -1) {
        return @"";
    }
    return [NSString stringWithFormat:@"%ld",[arrRight[indexPath.item][@"num"] integerValue]];;
}

- (NSInteger)menu:(LrdSuperMenu *)menu numberOfItemsInRow:(NSInteger)row inColumn:(NSInteger)column {
    if (column == 0) {
        NSArray *arrRight = self.nearByTradeArr[row][@"tradeList"];
        return arrRight.count;
    }
    return 0;
}

- (NSString *)menu:(LrdSuperMenu *)menu titleForItemsInRowAtIndexPath:(LrdIndexPath *)indexPath {
    NSInteger row = indexPath.row;
    if (indexPath.column == 0) {
        NSArray *arrRight = self.nearByTradeArr[row][@"tradeList"];
        return [NSString stringWithFormat:@"  %@",arrRight[indexPath.item][@"name"]];
    }
    return nil;
}

- (void)menu:(LrdSuperMenu *)menu didSelectRowAtIndexPath:(LrdIndexPath *)indexPath {
    if (indexPath.item >= 0) {
        NSArray *arrRight = self.nearByTradeArr[indexPath.row][@"tradeList"];
        self.tradeStr = arrRight[indexPath.item][@"id"];
        self.isStartSearch = @"1";
        [self navRightClicked];
    }else {
        if (indexPath.column == 1) {
            self.serviceStr = self.servicesTypeArr[indexPath.row][@"configValue"];
            self.isStartSearch = @"1";
            [self navRightClicked];
        }
        if (indexPath.column == 2) {
            self.sortStr = self.sortArr[indexPath.row][@"id"];
            self.isStartSearch = @"1";
            [self navRightClicked];
        }
    }
}

#pragma mark --滚动列表视图代理
//按钮点击位置
- (void)clickBtnLabelAtIndex:(NSInteger)currentIndex{
    if (currentIndex == 0) {
        //门店
        self.searchType = @"1";
    }else{
        //发型师
        self.searchType = @"2";
    }
    
    if ([self.isStartSearch isEqualToString:@"1"]) {
        [self navRightClicked];
    }
}

//视图滚动位置
-(void)ZJSrollViewDidScrollToIndex:(NSInteger)currentIndex{
    if (currentIndex == 0) {
        //门店
        self.searchType = @"1";
    }else{
        //发型师
        self.searchType = @"2";
    }
}

// 添加子控制器
- (NSArray *)setupChildVcAndTitle {
    self.shopVC = [[HDSearchShopsViewController alloc] init];
    self.shopVC.title = @"门店";
    self.shopVC.longitude = self.longitude;
    self.shopVC.latitude = self.latitude;

    self.cutterVC = [[HDSearchCutterViewController alloc] init];
    self.cutterVC.title = @"发型师";

    NSArray *childVcs = [NSArray arrayWithObjects:self.shopVC, self.cutterVC,nil];
    return childVcs;
}

#pragma mark -- 加载控件
-(void)createScrollView{
    //必要的设置, 如果没有设置可能导致内容显示不正常
    self.automaticallyAdjustsScrollViewInsets = NO;
    ZJSegmentStyle *style = [[ZJSegmentStyle alloc] init];
    //显示滚动条
    style.showLine = YES;
    style.scrollTitle = NO;
    style.selectedTitleColor = RGBMAIN;
    style.scrollLineColor = RGBMAIN;
    style.normalTitleColor = RGBTEXT;
    // 颜色渐变
    style.gradualChangeTitleColor = YES;
    // 设置子控制器 --- 注意子控制器需要设置title, 将用于对应的tag显示title
    NSArray *childVcs = [NSArray arrayWithArray:[self setupChildVcAndTitle]];
    // 初始化
    CGFloat y = NAVHIGHT;
    CGFloat h = kSCREEN_HEIGHT-NAVHIGHT;
    if (_menuView) {
        y = _menuView.bottom;
        h = kSCREEN_HEIGHT-_menuView.height-NAVHIGHT;
    }
    ZJScrollPageView *scrollPageView = [[ZJScrollPageView alloc] initWithFrame:CGRectMake(0, y, kSCREEN_WIDTH, h) segmentStyle:style childVcs:childVcs parentViewController:self];
    self.scrollPageView = scrollPageView;
    
    self.scrollPageView.zjdelegate = self;
    self.scrollPageView.segmentView.segDelegate = self;
    
    [self.view addSubview:scrollPageView];
}

//菜单
-(void)createMenuView{
    _menuView = [[LrdSuperMenu alloc] initWithOrigin:CGPointMake(0, NAVHIGHT) andHeight:48];
    _menuView.delegate = self;
    _menuView.dataSource = self;
    [self.view addSubview:_menuView];
    
    _menuView.indicatorColor = RGBMAIN;
    _menuView.selectedTextColor = RGBMAIN;
}
 
-(HDBaseNavView *)navView{
    if (!_navView) {
        _navView = [[HDBaseNavView alloc] initSearchBarWithButtonsFrame:CGRectMake(0, 0, kSCREEN_WIDTH, NAVHIGHT) bgColor:[UIColor whiteColor] textColor:[UIColor clearColor] searchViewColor:RGBAlpha(246, 246, 246, 1) btnTitle:@"搜索" placeHolder:@"请输入发型师或门店名称" theDelegate:self];
    }
    
    return _navView;
}

//搜索
-(void)navRightClicked{
    self.isStartSearch = @"1";
    if ([self.searchType isEqualToString:@"1"]) {
        self.shopVC.searchName = _navView.txtSearch.text;
        self.shopVC.serviceStr = self.serviceStr;
        self.shopVC.sortStr = self.sortStr;
        self.shopVC.tradeStr = self.tradeStr;
        [self.shopVC setupRefresh];
    }
    if ([self.searchType isEqualToString:@"2"]) {
        self.cutterVC.searchName = _navView.txtSearch.text;
        self.cutterVC.serviceStr = self.serviceStr;
        self.cutterVC.sortStr = self.sortStr;
        self.cutterVC.tradeStr = self.tradeStr;
        [self.cutterVC setupRefresh];
    }
}

//搜素
-(void)navTxtEndEditing:(NSString *)textSearch{
    self.isStartSearch = @"1";
    if ([self.searchType isEqualToString:@"1"]) {
        self.shopVC.searchName = _navView.txtSearch.text;
        self.shopVC.serviceStr = self.serviceStr;
        self.shopVC.sortStr = self.sortStr;
        self.shopVC.tradeStr = self.tradeStr;
        [self.shopVC setupRefresh];
    }
    if ([self.searchType isEqualToString:@"2"]) {
        self.cutterVC.searchName = _navView.txtSearch.text;
        self.cutterVC.serviceStr = self.serviceStr;
        self.cutterVC.sortStr = self.sortStr;
        self.cutterVC.tradeStr = self.tradeStr;
        [self.cutterVC setupRefresh];
    }
}

-(void)navBackClicked{
    [self.navigationController popViewControllerAnimated:YES];
}

@end
