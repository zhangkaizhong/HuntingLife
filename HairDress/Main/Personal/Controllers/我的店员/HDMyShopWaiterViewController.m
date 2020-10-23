//
//  HDOrderManageViewController.m
//  HairDress
//
//  Created by 张凯中 on 2019/12/26.
//  Copyright © 2019 zhangkaizhong. All rights reserved.
//

#import "HDMyShopWaiterViewController.h"

#import "HDMyShopWaiterSubViewController.h"

#import "ZJSegmentStyle.h"
#import "ZJScrollPageView.h"

@interface HDMyShopWaiterViewController ()<navViewDelegate,HDMyShopWaiterSubViewConDelegate,UITextFieldDelegate,ZJScrollPageViewDelegate,ZJScrollSegmentViewDelegate>

@property (nonatomic,strong) HDBaseNavView *navView;
@property (nonatomic,strong) HDMyShopWaiterSubViewController *vcAll;
@property (nonatomic,strong) HDMyShopWaiterSubViewController *vcT;
@property (nonatomic,strong) HDMyShopWaiterSubViewController *vcO;

@property (nonatomic,assign) NSInteger indexPage;

@end

@implementation HDMyShopWaiterViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self.view addSubview:self.navView];
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
    ZJScrollPageView *scrollPageView = [[ZJScrollPageView alloc] initWithFrame:CGRectMake(0, NAVHIGHT, kSCREEN_WIDTH, kSCREEN_HEIGHT-NAVHIGHT) segmentStyle:style childVcs:childVcs parentViewController:self];
    scrollPageView.zjdelegate = self;
    scrollPageView.segmentView.segDelegate = self;
    
    [self.view addSubview:scrollPageView];
}

#pragma mark -- delegate / action

-(void)navBackClicked{
    [self.navigationController popViewControllerAnimated:YES];
}

//滚动视图滚动位置
-(void)ZJSrollViewDidScrollToIndex:(NSInteger)currentIndex{
    self.indexPage = currentIndex;
    if (self.indexPage == 0) {
        self.vcAll.searchName = _navView.txtSearch.text;
    }
    if (self.indexPage == 1) {
        self.vcT.searchName = _navView.txtSearch.text;
    }
    if (self.indexPage == 2) {
        self.vcO.searchName = _navView.txtSearch.text;
    }
}

//按钮点击位置
-(void)clickBtnLabelAtIndex:(NSInteger)currentIndex{
    self.indexPage = currentIndex;
    if (self.indexPage == 0) {
        self.vcAll.searchName = _navView.txtSearch.text;
    }
    if (self.indexPage == 1) {
        self.vcT.searchName = _navView.txtSearch.text;
    }
    if (self.indexPage == 2) {
        self.vcO.searchName = _navView.txtSearch.text;
    }
}

//刷新数据
-(void)refreshDataList:(NSString *)storePost{
    if ([storePost isEqualToString:@""]) {//当前页面为全部
        [self.vcO loadNewData];
        [self.vcT loadNewData];
    }
    if ([storePost isEqualToString:@"T"]) {//当前页面为发型师
        [self.vcAll loadNewData];
        [self.vcO loadNewData];
    }
    if ([storePost isEqualToString:@"O"]) {//当前页面为店员
        [self.vcAll loadNewData];
        [self.vcT loadNewData];
    }
}

- (NSArray *)setupChildVcAndTitle {
    
    HDMyShopWaiterSubViewController *vc1 = [[HDMyShopWaiterSubViewController alloc] init];
    self.vcAll = vc1;
    self.vcAll.storePost = @"";
    self.vcAll.delegate = self;
    self.vcAll.title = @"全部";

    HDMyShopWaiterSubViewController *vc2 = [[HDMyShopWaiterSubViewController alloc] init];
    self.vcT = vc2;
    self.vcT.storePost = @"T";
    self.vcT.delegate = self;
    self.vcT.title = @"发型师";

    HDMyShopWaiterSubViewController *vc3 = [[HDMyShopWaiterSubViewController alloc] init];
    self.vcO = vc3;
    self.vcO.storePost = @"O";
    self.vcO.delegate = self;
    self.vcO.title = @"普通店员";

    NSArray *childVcs = [NSArray arrayWithObjects:self.vcAll, self.vcT, self.vcO,nil];
    return childVcs;
}

#pragma mark ================== 加载控件 =====================

-(HDBaseNavView *)navView{
    if (!_navView) {
        _navView = [[HDBaseNavView alloc] initSearchBarWithButtonsFrame:CGRectMake(0, 0, kSCREEN_WIDTH, NAVHIGHT) bgColor:RGBMAIN textColor:[UIColor clearColor] searchViewColor:RGBAlpha(246, 246, 246, 0.32) btnTitle:@"" placeHolder:@"搜索店员名字或手机号码" theDelegate:self];
        _navView.txtSearch.textColor = [UIColor whiteColor];
        _navView.txtSearch.tintColor = [UIColor whiteColor];
        _navView.txtSearch.returnKeyType = UIReturnKeySearch;
        _navView.txtSearch.delegate = self;
        [_navView.txtSearch addTarget:self action:@selector(textFieldDidChange:)forControlEvents:UIControlEventEditingChanged];
    }
    return _navView;
}


-(BOOL)textFieldShouldReturn:(UITextField *)textField{
    //搜索
    [self startSearch];
    return YES;
}

-(void)textFieldDidChange:(UITextField *)sender{
    //搜索
    [self startSearch];
}

//搜索
-(void)startSearch{
    if (self.indexPage == 0) {
        self.vcAll.searchName = _navView.txtSearch.text;
        [self.vcAll loadNewData];
    }
    if (self.indexPage == 1) {
        self.vcT.searchName = _navView.txtSearch.text;
        [self.vcT loadNewData];
    }
    if (self.indexPage == 2) {
        self.vcO.searchName = _navView.txtSearch.text;
        [self.vcO loadNewData];
    }
}


@end
