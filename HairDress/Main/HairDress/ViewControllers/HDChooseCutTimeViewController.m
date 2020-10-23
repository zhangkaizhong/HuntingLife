//
//  HDOrderManageViewController.m
//  HairDress
//
//  Created by 张凯中 on 2019/12/26.
//  Copyright © 2019 zhangkaizhong. All rights reserved.
//

#import "HDChooseCutTimeViewController.h"

#import "HDChooseCutTimeSubViewController.h"
#import "HDGetNumSuccessViewController.h"
#import "HDMyCutAllOrdersViewController.h"

#import "ZJSegmentStyle.h"
#import "ZJScrollPageView.h"
#import "PayManager.h"

@interface HDChooseCutTimeViewController ()<navViewDelegate,HDChooseCutTimeSubViewDelegate>

@property (nonatomic,strong) HDBaseNavView *navView;
@property (nonatomic,strong) UIView *comfirnGeNoView;
@property (nonatomic,strong) UILabel *lblComfirnPrice;
@property (nonatomic,strong) HDChooseCutTimeSubViewController *vcToday;
@property (nonatomic,strong) HDChooseCutTimeSubViewController *vcTomorrow;
@property (nonatomic,strong) HDChooseCutTimeSubViewController *vcAfterTomorrow;

@property (nonatomic,copy) NSString *timeType;
@property (nonatomic,strong) NSDictionary *dicSelected;
@property (nonatomic,strong) NSDictionary *dicOrderInfo;//订单详情

@property (nonatomic,copy) NSString *payType;//支付方式
@property (nonatomic,copy) NSString *isReYuyue;//再次预约标识

@end

@implementation HDChooseCutTimeViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.isReYuyue = @"F";
    self.payType = @"wxpay";
    
    self.view.backgroundColor = RGBBG;
    [self.view addSubview:self.navView];
    //必要的设置, 如果没有设置可能导致内容显示不正常
    self.automaticallyAdjustsScrollViewInsets = NO;
    ZJSegmentStyle *style = [[ZJSegmentStyle alloc] init];
    //显示滚动条
    style.showLine = YES;
    style.scrollTitle = NO;
    style.selectedTitleColor = RGBTEXT;
    style.titleFont = TEXT_SC_TFONT(TEXT_SC_Regular, 14*SCALE);
    style.titleSelectedFont = TEXT_SC_TFONT(TEXT_SC_Medium, 14*SCALE);
    style.scrollLineColor = RGBTEXT;
    style.normalTitleColor = RGBTEXT;
    style.gradualChangeTitleColor = NO;
    // 设置子控制器 --- 注意子控制器需要设置title, 将用于对应的tag显示title
    NSArray *childVcs = [NSArray arrayWithArray:[self setupChildVcAndTitle]];
    // 初始化
    ZJScrollPageView *scrollPageView = [[ZJScrollPageView alloc] initWithFrame:CGRectMake(0, NAVHIGHT, kSCREEN_WIDTH, kSCREEN_HEIGHT-NAVHIGHT-57*SCALE) segmentStyle:style childVcs:childVcs parentViewController:self];
    
    [self.view addSubview:scrollPageView];
    [self.view addSubview:self.comfirnGeNoView];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(reGetOrderRefreshAction:) name:NOTICE_TYPE_WXPAYSUCCESS object:nil];
}

#pragma mark -- delegate / action

-(void)navBackClicked{
    for (UIViewController *viewCon in self.navigationController.viewControllers) {
        if ([viewCon isKindOfClass:[HDMyCutAllOrdersViewController class]]) {
            HDMyCutAllOrdersViewController *orderVC = (HDMyCutAllOrdersViewController *)viewCon;
            [self.navigationController popToViewController:orderVC animated:YES];
            return;
        }
    }
    [self.navigationController popViewControllerAnimated:YES];
}

//付款成功刷新页面
-(void)reGetOrderRefreshAction:(NSNotification *)sender{
    HDGetNumSuccessViewController *getVC  = [HDGetNumSuccessViewController new];
    getVC.orderCutInfo = self.dicOrderInfo;
    [self.navigationController pushViewController:getVC animated:YES];
}

//选中的时间段
-(void)didSelectTime:(NSDictionary *)dic timeType:(NSString *)timeType{
    self.dicSelected = dic;
    self.timeType = timeType;
    if ([self.timeType isEqualToString:@"day"]) {
        [self.vcTomorrow reloadBtnSelectedStatus];
        [self.vcAfterTomorrow reloadBtnSelectedStatus];
    }
    if ([self.timeType isEqualToString:@"tomorrow"]) {
        [self.vcToday reloadBtnSelectedStatus];
        [self.vcAfterTomorrow reloadBtnSelectedStatus];
    }
    if ([self.timeType isEqualToString:@"afterTomorrow"]) {
        [self.vcTomorrow reloadBtnSelectedStatus];
        [self.vcToday reloadBtnSelectedStatus];
    }
}

//确认取号
-(void)comfirnGetAction:(UIButton *)sender{
    if (!self.dicSelected) {
        [SVHUDHelper showDarkWarningMsg:@"请选择预约时段"];
        return;
    }
    //创建理发订单
    [self createCutOrderRequest];
}

//理发预约请求
-(void)createCutOrderRequest{
    NSArray *arrayStart = [self.dicSelected[@"startTime"] componentsSeparatedByString:@":"];
    NSArray *arrayEnd = [self.dicSelected[@"endTime"] componentsSeparatedByString:@":"];
    NSString *startTime = @"";
    NSString *endTime = @"";
    if (arrayStart.count > 0) {
        startTime = arrayStart[0];
    }
    if (arrayEnd.count > 0) {
        endTime = arrayEnd[0];
    }
    NSString *timeType = @"";
    if (self.timeType) {
        timeType = self.timeType;
    }
     
    NSDictionary *params = @{
        @"isYuyue":self.isReYuyue,
        @"endTime":endTime,
        @"startTime":startTime,
        @"timeType":timeType,
        @"serviceId":self.dicSelectService[@"id"],
        @"storeId":self.storeID,
        @"tonyId":self.cutterID,
        @"userId":[HDUserDefaultMethods getData:@"userId"]
    };
    [MHNetworkManager postReqeustWithURL:URL_YuyueCreateOrder params:params successBlock:^(NSDictionary *returnData) {
        DTLog(@"URL_YuyueCreateOrder:%@",returnData);
        if ([returnData[@"respCode"] integerValue] == 200) {
            self.dicOrderInfo = [HDToolHelper nullDicToDic:returnData[@"data"]];
            
            self.isReYuyue = @"F";
            
            NSArray *data = @[@"微信支付",@"支付宝支付"];
            NSDictionary *dic = @{@"dataArr":data,@"payAmount":self.dicOrderInfo[@"payAmount"]};
            [[WMZAlert shareInstance] showAlertWithType:AlertTypeTopay headTitle:@"消费金额" textTitle:dic viewController:self leftHandle:^(id anyID) {
                //取消
            }rightHandle:^(id any) {
                //确定
                if ([any isEqualToString:@"支付宝支付"]) {
                    self.payType = @"alipay";
                }else{
                    self.payType = @"wxpay";
                }
                [self gotoPay];
            }];
        }
        else if ([returnData[@"respCode"] integerValue] == 201){
            
            [[WMZAlert shareInstance] showAlertWithType:AlertTypeYuyue headTitle:@"您已取号" textTitle:returnData[@"data"] viewController:self leftHandle:^(id anyID) {
                //再次预约
                self.isReYuyue = @"T";
                [self createCutOrderRequest];
                
            }rightHandle:^(id any) {
                self.isReYuyue = @"F";
            }];
        }
        else{
            self.isReYuyue = @"F";
            [SVHUDHelper showInfoWithTimestamp:1 msg:returnData[@"respMsg"]];
        }
        
    } failureBlock:^(NSError *error) {
        
    } showHUD:YES];
}

//去付款 调用支付接口
-(void)gotoPay{
    NSDictionary *params = @{
        @"clientIp":@"",
        @"orderId":self.dicOrderInfo[@"orderId"],
        @"orderName":@"",
        @"payChannel":@"app",
        @"payType":@"order",
        @"payWay":self.payType
    };
    [MHNetworkManager postReqeustWithURL:URL_PayToPay params:params successBlock:^(NSDictionary *returnData) {
        DTLog(@"%@",returnData);
        if ([returnData[@"respCode"] integerValue] == 200) {
            NSDictionary *dicOrder = [HDToolHelper nullDicToDic:returnData[@"data"]];
            if ([self.payType isEqualToString:@"wxpay"]) {
                PayReq* req = [[PayReq alloc] init];
                req.partnerId   = returnData[@"data"][@"mchId"];
                req.prepayId    = returnData[@"data"][@"prepayid"];
                req.nonceStr    = returnData[@"data"][@"nonceStr"];
                req.timeStamp   = [returnData[@"data"][@"timeStamp"] doubleValue];
                req.package     = returnData[@"data"][@"wxPackage"];
                req.sign = returnData[@"data"][@"paySign"];
                [WXApi sendReq:req completion:nil];
            }else{
                //支付宝支付
                NSString *orderString = dicOrder[@"aliPaySign"];
                [[PayManager shareInstance] paybyAlipayWithSign:orderString callback:^(NSDictionary *resultDic) {
                    if ([resultDic[@"resultStatus"] integerValue] == 9000) {
                        //支付成功
                        HDGetNumSuccessViewController *getVC  = [HDGetNumSuccessViewController new];
                        getVC.orderCutInfo = self.dicOrderInfo;
                        [self.navigationController pushViewController:getVC animated:YES];
                    }else if ([resultDic[@"resultStatus"] integerValue] == 6001) {
                        [SVHUDHelper showDarkWarningMsg:@"支付取消"];
                    }
                    else{
                        [SVHUDHelper showDarkWarningMsg:@"支付失败"];
                    }
                }];
            }
        }
        
    } failureBlock:^(NSError *error) {
        
    } showHUD:YES];
}

- (NSArray *)setupChildVcAndTitle {
    
    NSDate *date = [NSDate date];
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    [formatter setDateFormat:@"MM.dd"];
    NSString *todayStr = [formatter stringFromDate:date];
    
    HDChooseCutTimeSubViewController *vc1 = [[HDChooseCutTimeSubViewController alloc] init];
    vc1.title = todayStr;
    vc1.timeType = @"day";
    vc1.storeID = self.storeID;
    vc1.delegate = self;
    self.vcToday = vc1;
    
    NSString *tomorrowStr = [self GetTomorrowDay:[NSDate date] dayNum:1];

    HDChooseCutTimeSubViewController *vc2 = [[HDChooseCutTimeSubViewController alloc] init];
    vc2.title = tomorrowStr;
    vc2.storeID = self.storeID;
    vc2.timeType = @"tomorrow";
    vc2.delegate = self;
    self.vcTomorrow = vc2;
    
    NSString *afterTomorrowStr = [self GetTomorrowDay:[NSDate date] dayNum:2];
    HDChooseCutTimeSubViewController *vc3 = [[HDChooseCutTimeSubViewController alloc] init];
    vc3.title = afterTomorrowStr;
    vc3.storeID = self.storeID;
    vc3.timeType = @"afterTomorrow";
    vc3.delegate = self;
    self.vcAfterTomorrow = vc3;

    NSArray *childVcs = [NSArray arrayWithObjects:vc1, vc2, vc3,nil];
    return childVcs;
}

#pragma mark ================== 加载控件 =====================

-(HDBaseNavView *)navView{
    if (!_navView) {
        _navView = [[HDBaseNavView alloc] initWithFrame:CGRectMake(0, 0, kSCREEN_WIDTH, NAVHIGHT) title:@"时段选择" bgColor:[UIColor whiteColor] backBtn:YES rightBtn:@"" rightBtnImage:@"" theDelegate:self];
    }
    return _navView;
}

// 确认取号
-(UIView *)comfirnGeNoView{
    if (!_comfirnGeNoView) {
        _comfirnGeNoView = [[UIView alloc] initWithFrame:CGRectMake(0, kSCREEN_HEIGHT-49*SCALE, kSCREEN_WIDTH, 49*SCALE)];
        _comfirnGeNoView.backgroundColor = [UIColor whiteColor];
        [_comfirnGeNoView addSubview:self.lblComfirnPrice];
        self.lblComfirnPrice.attributedText =  [[NSString alloc] setAttrText:[NSString stringWithFormat:@"¥%.2f",[self.dicSelectService[@"amount"] floatValue]]  textColor:RGBMAIN setRange:NSMakeRange(0, 1) setColor:RGBMAIN];
        
        UIButton *btnComfirn = [[UIButton alloc] initSystemWithFrame:CGRectMake(kSCREEN_WIDTH-16*SCALE-148*SCALE, 0, 148*SCALE, 32*SCALE) btnTitle:@"确认取号" btnImage:@"" titleColor:[UIColor whiteColor] titleFont:14];
        btnComfirn.backgroundColor = RGBMAIN;
        btnComfirn.centerY = _comfirnGeNoView.height/2;
        btnComfirn.titleLabel.font = TEXT_SC_TFONT(TEXT_SC_Medium, 14*SCALE);
        btnComfirn.layer.cornerRadius = 6;
        [_comfirnGeNoView addSubview:btnComfirn];
        [btnComfirn addTarget:self action:@selector(comfirnGetAction:) forControlEvents:UIControlEventTouchUpInside];
        
        self.lblComfirnPrice.centerY = btnComfirn.centerY;
    }
    return _comfirnGeNoView;
}

// 价格
-(UILabel *)lblComfirnPrice{
    if (!_lblComfirnPrice) {
        _lblComfirnPrice = [[UILabel alloc] init];
        _lblComfirnPrice.frame = CGRectMake(16,14,150,20);
        _lblComfirnPrice.textColor = RGBMAIN;
        _lblComfirnPrice.font = [UIFont systemFontOfSize:14];
    }
    return _lblComfirnPrice;
}

//传入今天的时间，返回明天的时间
- (NSString *)GetTomorrowDay:(NSDate *)aDate dayNum:(NSInteger)numDate{
    NSCalendar *gregorian = [[NSCalendar alloc] initWithCalendarIdentifier:NSCalendarIdentifierGregorian];
    NSDateComponents *components = [gregorian components:NSCalendarUnitWeekday | NSCalendarUnitYear | NSCalendarUnitMonth | NSCalendarUnitDay fromDate:aDate];
    [components setDay:([components day]+numDate)];
    
    NSDate *beginningOfWeek = [gregorian dateFromComponents:components];
    NSDateFormatter *dateday = [[NSDateFormatter alloc] init];
    [dateday setDateFormat:@"MM.dd"];
    return [dateday stringFromDate:beginningOfWeek];
}

@end
