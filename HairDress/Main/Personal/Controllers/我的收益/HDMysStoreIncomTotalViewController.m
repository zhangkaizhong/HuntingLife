//
//  HDMysStoreIncomTotalViewController.m
//  HairDress
//
//  Created by 张凯中 on 2020/3/11.
//  Copyright © 2020 zhangkaizhong. All rights reserved.
//

#import "HDMysStoreIncomTotalViewController.h"
#import "HDMyIncomInfoModel.h"

@interface HDMysStoreIncomTotalViewController () <navViewDelegate>

@property (nonatomic,strong) HDBaseNavView *navView;
@property (nonatomic,strong) UIScrollView *mainScrollView;
@property (nonatomic,strong) UIView *viewToday;//今日收入
@property (nonatomic,strong) UIView *viewTotal;//总收入

@property (nonatomic,strong) HDMyIncomInfoModel *modelIncomeInfo;

@end

@implementation HDMysStoreIncomTotalViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = RGBBG;
    [self.view addSubview:self.navView];
    [self.view addSubview:self.mainScrollView];
    
    [self requestIncomsData];
}

#pragma mark -- delegate / action
-(void)navBackClicked{
    [self.navigationController popViewControllerAnimated:YES];
}

#pragma mark --请求数据
-(void)requestIncomsData{
    NSMutableDictionary *params = [NSMutableDictionary new];
    NSString *storeType = [HDUserDefaultMethods getData:@"storePost"];
    NSString *storeId = [HDUserDefaultMethods getData:@"storeId"];
    NSString *tonyId = [HDUserDefaultMethods getData:@"userId"];
    if ([HDToolHelper StringIsNullOrEmpty:tonyId]) {
        return;
    }
    if ([storeType isEqualToString:@"B"]) {
        // 店主
        if ([HDToolHelper StringIsNullOrEmpty:storeId]) {
            return;
        }
        [params setValue:storeId forKey:@"storeId"];
    }else if ([storeType isEqualToString:@"T"]){
        //发型师
        [params setValue:tonyId forKey:@"tonyId"];
    }
    
    [MHNetworkManager postReqeustWithURL:URL_StoreCountSettle params:params successBlock:^(NSDictionary *returnData) {
        if ([returnData[@"respCode"] integerValue] == 200) {
            self.modelIncomeInfo = [HDMyIncomInfoModel mj_objectWithKeyValues:returnData[@"data"]];
            [self.mainScrollView addSubview:self.viewToday];
            [self.mainScrollView addSubview:self.viewTotal];
            
            self.mainScrollView.contentSize = CGSizeMake(kSCREEN_WIDTH, self.viewTotal.bottom);
        }
    } failureBlock:^(NSError *error) {
        
    } showHUD:YES];
}

#pragma mark -- UI
-(UIScrollView *)mainScrollView{
    if (!_mainScrollView) {
        _mainScrollView = [[UIScrollView alloc] initWithFrame:CGRectMake(0, NAVHIGHT, kSCREEN_WIDTH, kSCREEN_HEIGHT-NAVHIGHT)];
        _mainScrollView.backgroundColor = [UIColor clearColor];
    }
    return _mainScrollView;
}

//今日收益
-(UIView *)viewToday{
    if (!_viewToday) {
        _viewToday = [[UIView alloc] initWithFrame:CGRectMake(0, 0, kSCREEN_WIDTH, 158)];
        _viewToday.backgroundColor = [UIColor whiteColor];
        
        UILabel *lblDate = [[UILabel alloc] initCommonWithFrame:CGRectMake(16, 24, kSCREEN_WIDTH-32, 20) title:self.modelIncomeInfo.today bgColor:[UIColor clearColor] titleColor:RGBTEXT titleFont:20 textAlignment:NSTextAlignmentLeft isFit:NO];
        [_viewToday addSubview:lblDate];
        
        UIView *view1 = [self createAmountView:CGRectMake(0, lblDate.bottom, kSCREEN_WIDTH/3, _viewToday.height-lblDate.bottom) title:@"今日收入" amount:[NSString stringWithFormat:@"%.2f",[self.modelIncomeInfo.dayAmount floatValue]] isLine:YES];
        [_viewToday addSubview:view1];
        
        UIView *view2 = [self createAmountView:CGRectMake(CGRectGetMaxX(view1.frame), lblDate.bottom, kSCREEN_WIDTH/3, _viewToday.height-lblDate.bottom) title:@"订单数" amount:self.modelIncomeInfo.dayOrderNum isLine:YES];
        [_viewToday addSubview:view2];
        
        UIView *view3 = [self createAmountView:CGRectMake(CGRectGetMaxX(view2.frame), lblDate.bottom, kSCREEN_WIDTH/3, _viewToday.height-lblDate.bottom) title:@"结算订单数" amount:self.modelIncomeInfo.daySettleNum isLine:NO];
        [_viewToday addSubview:view3];
    }
    return _viewToday;
}

//总收益
-(UIView *)viewTotal{
    if (!_viewTotal) {
        _viewTotal = [[UIView alloc] initWithFrame:CGRectMake(0, _viewToday.bottom+8, kSCREEN_WIDTH, 114)];
        _viewTotal.backgroundColor = [UIColor whiteColor];
        
        UIView *view1 = [self createAmountView:CGRectMake(0, 0, kSCREEN_WIDTH/3, _viewTotal.height) title:@"总收入" amount:[NSString stringWithFormat:@"%.2f",[self.modelIncomeInfo.totalAmount floatValue]] isLine:YES];
        [_viewTotal addSubview:view1];
        
        UIView *view2 = [self createAmountView:CGRectMake(CGRectGetMaxX(view1.frame), 0, kSCREEN_WIDTH/3, _viewTotal.height) title:@"总订单数" amount:self.modelIncomeInfo.totalOrderNum isLine:YES];
        [_viewTotal addSubview:view2];
        
        UIView *view3 = [self createAmountView:CGRectMake(CGRectGetMaxX(view2.frame), 0, kSCREEN_WIDTH/3, _viewTotal.height) title:@"总结算订单数" amount:self.modelIncomeInfo.totalSettleNum isLine:NO];
        [_viewTotal addSubview:view3];
    }
    return _viewTotal;
}

-(HDBaseNavView *)navView{
    if (!_navView) {
        _navView = [[HDBaseNavView alloc] initWithFrame:CGRectMake(0, 0, kSCREEN_WIDTH, NAVHIGHT) title:@"收益统计" bgColor:RGBMAIN backBtn:YES rightBtn:@"" rightBtnImage:@"" theDelegate:self];
    }
    return _navView;
}

-(UIView *)createAmountView:(CGRect)frame title:(NSString *)title amount:(NSString *)amount isLine:(BOOL)line{
    UIView *view = [[UIView alloc] initWithFrame:frame];
    
    UILabel *lblTitle = [[UILabel alloc] initCommonWithFrame:CGRectMake(0, 32, view.width, 12) title:title bgColor:[UIColor clearColor] titleColor:RGBLIGHT_TEXTINFO titleFont:12 textAlignment:NSTextAlignmentCenter isFit:NO];
    [view addSubview:lblTitle];
    
    UILabel *lblAmount = [[UILabel alloc] initCommonWithFrame:CGRectMake(0, lblTitle.bottom+20, view.width, 18) title:amount bgColor:[UIColor clearColor] titleColor:RGBTEXT titleFont:18 textAlignment:NSTextAlignmentCenter isFit:NO];
    [view addSubview:lblAmount];
    
    if (line) {
        UIView *viewLine = [[UIView alloc] initWithFrame:CGRectMake(view.width-1, 0, 1, 40)];
        viewLine.centerY = view.height/2;
        viewLine.backgroundColor = RGBCOLOR(238, 238, 238);
        [view addSubview:viewLine];
    }
    
    return view;
}

@end
