//
//  HDMyShopOrdersSubViewController.m
//  HairDress
//
//  Created by 张凯中 on 2019/12/29.
//  Copyright © 2019 zhangkaizhong. All rights reserved.
//

#import "HDMyCutOrdersToPayViewController.h"

#import "HDCancelCutQueneViewController.h"
#import "PayManager.h"

@interface HDMyCutOrdersToPayViewController ()<UITableViewDelegate,UITableViewDataSource>

@property (nonatomic,strong) UITableView *mainTableView;

@property (nonatomic,strong) UIView *viewPay;//详情视图

@property (nonatomic,weak) UILabel *lblService;//服务项目
@property (nonatomic,weak) UILabel *lblPrice;// 价格
@property (nonatomic,weak) UILabel *lblShopName;//门店名称
@property (nonatomic,weak) UILabel *lblDistance;// 距离
@property (nonatomic,weak) UILabel *lblDes;//项目详情

@property (nonatomic,weak) UIButton *btnCancel;//取消
@property (nonatomic,weak) UIButton *btnComfirn;//支付

@property (nonatomic,copy) NSString *payType;//支付方式
@property (nonatomic,strong) NSDictionary *dicOrderInfo;//待支付订单详情

@end

@implementation HDMyCutOrdersToPayViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.view.backgroundColor = RGBBG;
    [self.view addSubview:[self createMainTableView]];
    
    [self getOrderWaitData];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(reGetOrderRefreshAction:) name:@"cancelQueue" object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(reGetOrderRefreshAction:) name:NOTICE_TYPE_WXPAYSUCCESS object:nil];
    
    [self setupRefresh];
    
    self.payType = @"wxpay";
}

#pragma mark - 添加刷新控件
-(void)setupRefresh{
    self.mainTableView.mj_header = [MJRefreshNormalHeader headerWithRefreshingTarget:self refreshingAction:@selector(loadNewData)];
}

//下拉刷新数据
-(void)loadNewData{
    [self getOrderWaitData];
}

#pragma mark -- action
-(void)btnAction:(UIButton *)sender{
    if ([sender.titleLabel.text isEqualToString:@"取消"]) {
        HDCancelCutQueneViewController *cancelVC = [HDCancelCutQueneViewController new];
        cancelVC.order_id = self.dicOrderInfo[@"orderId"];
        cancelVC.queue_num = self.dicOrderInfo[@"queueNum"];
        cancelVC.cancel_type = @"user";
        [self.navigationController pushViewController:cancelVC animated:YES];
    }
    if ([sender.titleLabel.text isEqualToString:@"支付"]) {
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
}

//刷新数据通知
-(void)reGetOrderRefreshAction:(NSNotification *)notice{
    [self getOrderWaitData];
}

#pragma mark ================== 请求数据 =====================
//获取待消费数据
-(void)getOrderWaitData{
    NSDictionary *params = @{@"orderStatus":@(0),@"userId":[HDUserDefaultMethods getData:@"userId"]};
    [MHNetworkManager postReqeustWithURL:URL_YuyueUserOrder params:params successBlock:^(NSDictionary *returnData) {
        [self.mainTableView.mj_header endRefreshing];
        returnData = [HDToolHelper nullDicToDic:returnData];
        if ([returnData[@"respCode"] integerValue] == 200) {
            if ([returnData[@"data"] isKindOfClass:[NSDictionary class]]) {
                self.viewEmpty.hidden = YES;
                if (self.viewPay) {
                    [self.viewPay removeFromSuperview];
                }
                self.dicOrderInfo = [HDToolHelper nullDicToDic:returnData[@"data"]];
                [self.mainTableView addSubview:[self createViewPay]];
            }else{
                if ([returnData[@"data"] isKindOfClass:[NSString class]]) {
                    if ([HDToolHelper StringIsNullOrEmpty:returnData[@"data"]]) {
                        if (self.viewPay) {
                            [self.viewPay removeFromSuperview];
                        }
                        [self.mainTableView addSubview:self.viewEmpty];
                        self.viewEmpty.hidden = NO;
                    }
                }
            }
        }else{
            [SVHUDHelper showInfoWithTimestamp:1 msg:returnData[@"respMsg"]];
        }
    } failureBlock:^(NSError *error) {
        
    } showHUD:YES];
}

//调用支付接口
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
                NSString *orderString = returnData[@"data"][@"aliPaySign"];
                [[PayManager shareInstance] paybyAlipayWithSign:orderString callback:^(NSDictionary *resultDic) {
                    if ([resultDic[@"resultStatus"] integerValue] == 9000) {
                        //支付成功
                        [SVHUDHelper showDarkWarningMsg:@"支付成功"];
                        [self getOrderWaitData];
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

#pragma mark -- tableView delegate
-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return 0;
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:NSStringFromClass([UITableViewCell class])];
    return cell;
}

#pragma mark -- 加载控件

-(UITableView *)createMainTableView{
    _mainTableView = [[UITableView alloc] initWithFrame:CGRectMake(0, 0, kSCREEN_WIDTH, kSCREEN_HEIGHT-NAVHIGHT-48) style:UITableViewStylePlain];
    _mainTableView.delegate = self;
    _mainTableView.dataSource = self;
    _mainTableView.backgroundColor = [UIColor clearColor];
    _mainTableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    [_mainTableView registerClass:[UITableViewCell class] forCellReuseIdentifier:NSStringFromClass([UITableViewCell class])];
    
    return _mainTableView;
}

// 创建视图
-(UIView *)createViewPay{
    _viewPay = [[UIView alloc] initWithFrame:CGRectMake(16, 8, kSCREEN_WIDTH-32, 100)];
    _viewPay.layer.cornerRadius = 4;
    _viewPay.backgroundColor = [UIColor whiteColor];
    
    // 服务项目
    UILabel *lblService = [[UILabel alloc] initCommonWithFrame:CGRectMake(24, 24, 100, 14) title:self.dicOrderInfo[@"serviceName"] bgColor:[UIColor clearColor] titleColor:RGBTEXT titleFont:14 textAlignment:NSTextAlignmentLeft isFit:YES];
    lblService.height = 14;
    [_viewPay addSubview:lblService];
    self.lblService = lblService;
    
    UILabel *lblPrice = [[UILabel alloc] initCommonWithFrame:CGRectMake(CGRectGetMaxX(lblService.frame)+5, 0, _viewPay.width-CGRectGetMaxX(lblService.frame)-5-24, 20) title:@"" bgColor:[UIColor clearColor] titleColor:RGBMAIN titleFont:20 textAlignment:NSTextAlignmentRight isFit:NO];
    lblPrice.attributedText = [[NSString alloc] setAttrText:[NSString stringWithFormat:@"¥%.2f",[self.dicOrderInfo[@"payAmount"] floatValue]]  textColor:RGBMAIN setRange:NSMakeRange(0, 1) setColor:RGBMAIN];
    self.lblPrice = lblPrice;
    self.lblPrice.centerY = lblService.centerY;
    [_viewPay addSubview:lblPrice];
    
    UIView *line1 = [[UIView alloc] initWithFrame:CGRectMake(24, lblPrice.bottom+24, _viewPay.width-48, 1)];
    line1.backgroundColor = RGBCOLOR(241, 241, 241);
    [_viewPay addSubview:line1];
    
    //门店名称
    UILabel *lblShopName = [[UILabel alloc] initCommonWithFrame:CGRectMake(24, line1.bottom+16, 100, 16) title:self.dicOrderInfo[@"storeName"] bgColor:[UIColor clearColor] titleColor:RGBTEXT titleFont:14 textAlignment:NSTextAlignmentLeft isFit:YES];
    lblShopName.height = 16;
    self.lblShopName = lblShopName;
    [_viewPay addSubview:lblShopName];
            
//    UILabel *lblDistance = [[UILabel alloc] initCommonWithFrame:CGRectMake(CGRectGetMaxX(lblShopName.frame)+5, 0, 80, 16) title:@"13.5km" bgColor:[UIColor clearColor] titleColor:RGBTEXT titleFont:14 textAlignment:NSTextAlignmentRight isFit:YES];
//    lblDistance.centerY = lblShopName.centerY;
//    self.lblDistance = lblDistance;
//    self.lblDistance.x = _viewPay.width-lblDistance.width-24;
//    [_viewPay addSubview:lblDistance];

//    UIImageView *imageDis = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"common_ic_location"]];
//    imageDis.x = lblDistance.x - imageDis.width;
//    imageDis.centerY = lblDistance.centerY;
//    [_viewPay addSubview:imageDis];
    
    UIView *line2 = [[UIView alloc] initWithFrame:CGRectMake(24, lblShopName.bottom+16, _viewPay.width-48, 1)];
    line2.backgroundColor = RGBCOLOR(241, 241, 241);
    [_viewPay addSubview:line2];
    

    // 项目详情
    NSString *strDes = @"发型师\n\n服务项目\n\n取号时间 ";
    UILabel *lblDesText = [[UILabel alloc] initCommonWithFrame:CGRectMake(24, line2.bottom+16, _viewPay.width/2, 100) title:strDes bgColor:[UIColor clearColor] titleColor:RGBTEXTINFO titleFont:14 textAlignment:NSTextAlignmentLeft isFit:NO];
    lblDesText.numberOfLines = 0;
    [lblDesText sizeToFit];
    [_viewPay addSubview:lblDesText];
    
    NSString *desInfo = [NSString stringWithFormat:@"%@\n\n%@\n\n%@",self.dicOrderInfo[@"tonyName"],self.dicOrderInfo[@"serviceName"],self.dicOrderInfo[@"createTime"]];
    UILabel *lblDes = [[UILabel alloc] initCommonWithFrame:CGRectMake(CGRectGetMaxX(lblDesText.frame), lblDesText.y, _viewPay.width-CGRectGetMaxX(lblDesText.frame)-24, 100) title:desInfo bgColor:[UIColor clearColor] titleColor:RGBTEXT titleFont:14 textAlignment:NSTextAlignmentRight isFit:NO];
    lblDes.numberOfLines = 0;
    [lblDes sizeToFit];
    lblDes.x = _viewPay.width - lblDes.width-24;
    self.lblDes = lblDes;
    [_viewPay addSubview:lblDes];
    
    UIView *line3 = [[UIView alloc] initWithFrame:CGRectMake(24, lblDesText.bottom+16, _viewPay.width-48, 1)];
    line3.backgroundColor = RGBCOLOR(241, 241, 241);
    [_viewPay addSubview:line3];
    
    //取消排号
    UIButton *buttCancel = [[UIButton alloc] initSystemWithFrame:CGRectMake(24, line3.bottom+24, (_viewPay.width-48-15)/2, 36) btnTitle:@"取消" btnImage:@"" titleColor:RGBMAIN titleFont:14];
    self.btnCancel = buttCancel;
    buttCancel.layer.cornerRadius = 2;
    buttCancel.layer.borderColor = RGBMAIN.CGColor;
    buttCancel.layer.borderWidth = 1;
    [_viewPay addSubview:buttCancel];
    [buttCancel addTarget:self action:@selector(btnAction:) forControlEvents:UIControlEventTouchUpInside];
    
    // 支付
    UIButton *buttComfirn = [[UIButton alloc] initSystemWithFrame:CGRectMake(CGRectGetMaxX(buttCancel.frame)+15, line3.bottom+24, (_viewPay.width-48-15)/2, 36) btnTitle:@"支付" btnImage:@"" titleColor:[UIColor whiteColor] titleFont:14];
    self.btnComfirn = buttComfirn;
    buttComfirn.backgroundColor = RGBMAIN;
    buttComfirn.layer.cornerRadius = 2;
    [_viewPay addSubview:buttComfirn];
    [buttComfirn addTarget:self action:@selector(btnAction:) forControlEvents:UIControlEventTouchUpInside];
    
    // 更新view高度
    _viewPay.height = buttCancel.bottom+24;
    
    return _viewPay;
}

-(void)dealloc{
    DTLog(@"HDMyCutOrdersWaitViewController dealloc");
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}


@end
