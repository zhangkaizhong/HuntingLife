//
//  HDMyShopOrdersSubViewController.m
//  HairDress
//
//  Created by 张凯中 on 2019/12/29.
//  Copyright © 2019 zhangkaizhong. All rights reserved.
//

#import "HDMyCutOrdersWaitViewController.h"

#import "HDCancelCutQueneViewController.h"

@interface HDMyCutOrdersWaitViewController ()

@property (nonatomic,strong) UIScrollView *mainScrollView;

@property (nonatomic,strong) NSMutableArray *arrData;

@property (nonatomic,strong) UIView *viewNoInshop;//到店前
@property (nonatomic,strong) UIView *viewInShop;//已到店

@property (nonatomic,weak) UILabel *lblPaiNo;//排号
@property (nonatomic,weak) UILabel *lblWaitNum;//等待人数
@property (nonatomic,weak) UILabel *lblWaitTime;//预计等待时间
@property (nonatomic,weak) UILabel *lblService;//服务项目
@property (nonatomic,weak) UILabel *lblPrice;// 价格
@property (nonatomic,weak) UILabel *lblWarn;//注意事项
@property (nonatomic,weak) UILabel *lblRule;//排队规则
@property (nonatomic,weak) UILabel *lblShopName;//门店名称
@property (nonatomic,weak) UILabel *lblDistance;//距离
@property (nonatomic,weak) UILabel *lblDes;//项目详情

@property (nonatomic,weak) UIButton *btnCheckPai;//查看排队进度
@property (nonatomic,weak) UIButton *btnCancel;//取消排号
@property (nonatomic,weak) UIButton *btnComfirn;//我已到店/一键呼叫

@property (nonatomic,strong) NSDictionary *dicOrderInfo;//待消费订单详情

@end

@implementation HDMyCutOrdersWaitViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.view.backgroundColor = RGBBG;
    
    [self.view addSubview:[self createMainScrollView]];

    [self getOrderWaitData];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(reGetOrderRefreshAction:) name:@"cancelQueue" object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(reGetOrderRefreshAction:) name:NOTICE_TYPE_WXPAYSUCCESS object:nil];
    
    [self setupRefresh];
}

#pragma mark - 添加刷新控件
-(void)setupRefresh{
    self.mainScrollView.mj_header = [MJRefreshNormalHeader headerWithRefreshingTarget:self refreshingAction:@selector(loadNewData)];
}

//下拉刷新数据
-(void)loadNewData{
    [self getOrderWaitData];
}

#pragma mark -- action
-(void)btnAction:(UIButton *)sender{
    if ([sender.titleLabel.text isEqualToString:@"取消排号"]) {
        HDCancelCutQueneViewController *cancelVC = [HDCancelCutQueneViewController new];
        cancelVC.order_id = self.dicOrderInfo[@"orderId"];
        cancelVC.queue_num = self.dicOrderInfo[@"queueNum"];
        cancelVC.cancel_type = @"user";
        [self.navigationController pushViewController:cancelVC animated:YES];
    }
    if ([sender.titleLabel.text isEqualToString:@"我已到店"]) {
        [self startQueueRequest];
    }
    if ([sender.titleLabel.text isEqualToString:@"一键呼叫"]) {
        NSLog(@"一键呼叫");
    }
}

//刷新数据
-(void)reGetOrderRefreshAction:(NSNotification *)notice{
    [self getOrderWaitData];
}

#pragma mark -- 跳转第三方地图导航
-(void)tapAddressAction:(UIGestureRecognizer *)sender{
    [HDToolHelper showMapsWithLat:self.dicOrderInfo[@"latitude"] longt:self.dicOrderInfo[@"longitude"]];
}

#pragma mark ================== 请求数据 =====================
//获取待消费数据
-(void)getOrderWaitData{
    WeakSelf;
    NSDictionary *params = @{@"orderStatus":@(1),@"userId":[HDUserDefaultMethods getData:@"userId"]};
    [MHNetworkManager postReqeustWithURL:URL_YuyueUserOrder params:params successBlock:^(NSDictionary *returnData) {
        [self.mainScrollView.mj_header endRefreshing];
        returnData = [HDToolHelper nullDicToDic:returnData];
        if ([returnData[@"respCode"] integerValue] == 200) {
            self.viewEmpty.hidden = YES;
            if (self.viewInShop) {
                [self.viewInShop removeFromSuperview];
            }
            if (self.viewNoInshop) {
                [self.viewNoInshop removeFromSuperview];
            }
            if ([returnData[@"data"] isKindOfClass:[NSDictionary class]]) {
                self.dicOrderInfo = returnData[@"data"];
                if (self.dicOrderInfo) {
                    if ([self.dicOrderInfo[@"orderStatus"] isEqualToString:@"wait"]) {
                        [weakSelf.mainScrollView addSubview:[self createViewNoInshop]];
                        weakSelf.mainScrollView.contentSize = CGSizeMake(kSCREEN_WIDTH, self.viewNoInshop.bottom+24);
                        if (self.viewNoInshop.bottom+24 < (kSCREEN_HEIGHT-120-48+1)) {
                            weakSelf.mainScrollView.contentSize = CGSizeMake(kSCREEN_WIDTH, kSCREEN_HEIGHT-120-48+1);
                        }
                    }else{
                        [weakSelf.mainScrollView addSubview:[self createViewInShop]];
                        weakSelf.mainScrollView.contentSize = CGSizeMake(kSCREEN_WIDTH, self.viewInShop.bottom+24);
                        if (self.viewInShop.bottom+24 < (kSCREEN_HEIGHT-120-48+1)) {
                            weakSelf.mainScrollView.contentSize = CGSizeMake(kSCREEN_WIDTH, kSCREEN_HEIGHT-120-48+1);
                        }
                    }
                }
            }else{
                if ([returnData[@"data"] isKindOfClass:[NSString class]] || [returnData[@"data"] isKindOfClass:[NSNull class]]) {
                    if ([HDToolHelper StringIsNullOrEmpty:returnData[@"data"]]) {
                        [self.mainScrollView addSubview:self.viewEmpty];
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

//到店请求
-(void)startQueueRequest{
    NSDictionary *params = @{
        @"orderId":self.dicOrderInfo[@"orderId"]
    };
    WeakSelf;
    [MHNetworkManager postReqeustWithURL:URL_YuyueStartQueue params:params successBlock:^(NSDictionary *returnData) {
        DTLog(@"%@",returnData);
        if ([returnData[@"respCode"] integerValue] == 200) {
            [SVHUDHelper showDarkWarningMsg:@"签到成功"];
            if ([returnData[@"data"] isKindOfClass:[NSDictionary class]]){
                if (self.viewInShop) {
                    [self.viewInShop removeFromSuperview];
                }
                if (self.viewNoInshop) {
                    [self.viewNoInshop removeFromSuperview];
                }
                weakSelf.dicOrderInfo = returnData[@"data"];
                if (self.dicOrderInfo) {
                    if ([self.dicOrderInfo[@"orderStatus"] isEqualToString:@"wait"]) {
                        [weakSelf.mainScrollView addSubview:[self createViewNoInshop]];
                        weakSelf.mainScrollView.contentSize = CGSizeMake(kSCREEN_WIDTH, self.viewNoInshop.bottom+24);
                        if (self.viewNoInshop.bottom+24 < (kSCREEN_HEIGHT-120-48+1)) {
                            weakSelf.mainScrollView.contentSize = CGSizeMake(kSCREEN_WIDTH, kSCREEN_HEIGHT-120-48+1);
                        }
                    }else{
                        [weakSelf.mainScrollView addSubview:[self createViewInShop]];
                        weakSelf.mainScrollView.contentSize = CGSizeMake(kSCREEN_WIDTH, self.viewInShop.bottom+24);
                        if (self.viewInShop.bottom+24 < (kSCREEN_HEIGHT-120-48+1)) {
                            weakSelf.mainScrollView.contentSize = CGSizeMake(kSCREEN_WIDTH, kSCREEN_HEIGHT-120-48+1);
                        }
                    }
                }
            }
        }else{
            [SVHUDHelper showInfoWithTimestamp:1 msg:returnData[@"respMsg"]];
        }
    } failureBlock:^(NSError *error) {
        
    } showHUD:YES];
}

#pragma mark -- 加载控件

-(UIScrollView *)createMainScrollView{
    _mainScrollView = [[UIScrollView alloc] initWithFrame:CGRectMake(0, 0, kSCREEN_WIDTH, kSCREEN_HEIGHT-NAVHIGHT-48)];
    _mainScrollView.backgroundColor = [UIColor clearColor];
    return _mainScrollView;
}

// 到店前
-(UIView *)createViewNoInshop{
    _viewNoInshop = [[UIView alloc] initWithFrame:CGRectMake(16, 8, kSCREEN_WIDTH-32, 100)];
    _viewNoInshop.layer.cornerRadius = 4;
    _viewNoInshop.backgroundColor = [UIColor whiteColor];
    
    //预约时段
    UIView *viewTime = [self createItemView:CGRectMake(0, 32, _viewNoInshop.width, 28) title:@"预约时段" item:[NSString stringWithFormat:@"%@-%@",self.dicOrderInfo[@"startTimeDate"],self.dicOrderInfo[@"endTimeDate"]] itemColor:RGBMAIN];
    [_viewNoInshop addSubview:viewTime];
    //排队号码
    UIView *viewQueue = [self createItemView:CGRectMake(0, viewTime.bottom, _viewNoInshop.width, 28) title:@"排队号码" item:self.dicOrderInfo[@"queueNum"] itemColor:RGBTEXT];
    [_viewNoInshop addSubview:viewQueue];
    //服务项目
    UIView *viewService = [self createItemView:CGRectMake(0, viewQueue.bottom, _viewNoInshop.width, 28) title:@"服务项目" item:self.dicOrderInfo[@"serviceName"] itemColor:RGBTEXT];
    [_viewNoInshop addSubview:viewService];
    //合计
    UIView *viewAmount = [self createItemView:CGRectMake(0, viewService.bottom, _viewNoInshop.width, 28) title:@"合计" item:[NSString stringWithFormat:@"¥%.2f",[self.dicOrderInfo[@"payAmount"] floatValue]] itemColor:RGBTEXT];
    [_viewNoInshop addSubview:viewAmount];
    //取号时间
    UIView *viewCreateTime = [self createItemView:CGRectMake(0, viewAmount.bottom, _viewNoInshop.width, 28) title:@"取号时间" item:self.dicOrderInfo[@"createTime"] itemColor:RGBTEXT];
    [_viewNoInshop addSubview:viewCreateTime];
    
    UIView *line1 = [[UIView alloc] initWithFrame:CGRectMake(24, viewCreateTime.bottom+16, _viewNoInshop.width-48, 1)];
    line1.backgroundColor = RGBAlpha(241, 241, 241, 1);
    [_viewNoInshop addSubview:line1];
    
    //门店视图
    UIView *viewShop = [[UIView alloc] initWithFrame:CGRectMake(0, line1.bottom, _viewNoInshop.width, 49)];
    [_viewNoInshop addSubview:viewShop];
    
    UITapGestureRecognizer *tapAdd = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapAddressAction:)];
    viewShop.userInteractionEnabled = YES;
    [viewShop addGestureRecognizer:tapAdd];
    
    UIImageView *imageAddress = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"common_ic_location"]];
    imageAddress.x = viewShop.width - imageAddress.width-24;
    [viewShop addSubview:imageAddress];
    
    UILabel *lblShopName = [[UILabel alloc] initCommonWithFrame:CGRectMake(24, 0, viewShop.width- imageAddress.width - 16-24, 14) title:self.dicOrderInfo[@"storeName"] bgColor:[UIColor clearColor] titleColor:RGBTEXT titleFont:14 textAlignment:NSTextAlignmentLeft isFit:NO];
    lblShopName.font = TEXT_SC_TFONT(TEXT_SC_Medium, 14);
    lblShopName.numberOfLines = 0;
    [lblShopName sizeToFit];
    [viewShop addSubview:lblShopName];
    if (lblShopName.height <= 14) {
        lblShopName.height = 14;
    }
    viewShop.height = lblShopName.bottom+16;
    lblShopName.centerY = viewShop.height/2;
    imageAddress.centerY = lblShopName.centerY;
    
    UIView *line2 = [[UIView alloc] initWithFrame:CGRectMake(24, viewShop.height-1, _viewNoInshop.width-48, 1)];
    line2.backgroundColor = RGBAlpha(241, 241, 241, 1);
    [viewShop addSubview:line2];
    
    // 注意事项
    NSString *strWarn = self.dicOrderInfo[@"content"];
    UILabel *lblWarn = [[UILabel alloc] initCommonWithFrame:CGRectMake(24, viewShop.bottom+16, _viewNoInshop.width-48, 100) title:strWarn bgColor:[UIColor clearColor] titleColor:RGBTEXT titleFont:12 textAlignment:NSTextAlignmentLeft isFit:NO];
    lblWarn.numberOfLines = 0;
    [lblWarn sizeToFit];
    [_viewNoInshop addSubview:lblWarn];
    self.lblWarn = lblWarn;
    
    UIView *line3 = [[UIView alloc] initWithFrame:CGRectMake(24, lblWarn.bottom+16, _viewNoInshop.width-48, 1)];
    line3.backgroundColor = RGBCOLOR(241, 241, 241);
    [_viewNoInshop addSubview:line3];
    
    // 排队规则
    UILabel *lblRuleText = [[UILabel alloc] initCommonWithFrame:CGRectMake(24, line3.bottom+16, _viewNoInshop.width-48, 12) title:@"排队规则" bgColor:[UIColor clearColor] titleColor:RGBTEXTINFO titleFont:12 textAlignment:NSTextAlignmentLeft isFit:NO];
    [_viewNoInshop addSubview:lblRuleText];
    
    NSString *strRule = self.dicOrderInfo[@"rule"];
    UILabel *lblRule = [[UILabel alloc] initCommonWithFrame:CGRectMake(24, lblRuleText.bottom+11, _viewNoInshop.width-48, 100) title:strRule bgColor:[UIColor clearColor] titleColor:RGBTEXT titleFont:12 textAlignment:NSTextAlignmentLeft isFit:NO];
    lblRule.numberOfLines = 0;
    [lblRule sizeToFit];
    [_viewNoInshop addSubview:lblRule];
    self.lblRule = lblRule;
    
    UIView *line4 = [[UIView alloc] initWithFrame:CGRectMake(24, lblRule.bottom+16, _viewNoInshop.width-48, 1)];
    line4.backgroundColor = RGBCOLOR(241, 241, 241);
    [_viewNoInshop addSubview:line4];
    
    //取消排号
    UIButton *buttCancel = [[UIButton alloc] initSystemWithFrame:CGRectMake(24, line4.bottom+16, (_viewNoInshop.width-48-15)/2, 36) btnTitle:@"取消排号" btnImage:@"" titleColor:RGBMAIN titleFont:14];
    self.btnCancel = buttCancel;
    buttCancel.layer.cornerRadius = 6;
    buttCancel.layer.borderColor = RGBMAIN.CGColor;
    buttCancel.layer.borderWidth = 1;
    [_viewNoInshop addSubview:buttCancel];
    [buttCancel addTarget:self action:@selector(btnAction:) forControlEvents:UIControlEventTouchUpInside];
    
    // 我已到店
    UIButton *buttComfirn = [[UIButton alloc] initSystemWithFrame:CGRectMake(CGRectGetMaxX(buttCancel.frame)+15, line4.bottom+16, (_viewNoInshop.width-48-15)/2, 36) btnTitle:@"我已到店" btnImage:@"" titleColor:[UIColor whiteColor] titleFont:14];
    self.btnComfirn = buttComfirn;
    buttComfirn.backgroundColor = RGBMAIN;
    buttComfirn.layer.cornerRadius = 6;
    [_viewNoInshop addSubview:buttComfirn];
    [buttComfirn addTarget:self action:@selector(btnAction:) forControlEvents:UIControlEventTouchUpInside];
    
    // 更新view高度
    _viewNoInshop.height = buttCancel.bottom+24;
    
    return _viewNoInshop;
}

// 到店后待消费
-(UIView *)createViewInShop{
    _viewInShop = [[UIView alloc] initWithFrame:CGRectMake(16, 8, kSCREEN_WIDTH-32, 200)];
    _viewInShop.layer.cornerRadius = 4;
    _viewInShop.backgroundColor = [UIColor whiteColor];
    
    // 排队号码
    UILabel *lblPaiNo = [[UILabel alloc] initCommonWithFrame:CGRectMake(0, 32, _viewInShop.width/3, 24) title:self.dicOrderInfo[@"queueNum"] bgColor:[UIColor clearColor] titleColor:RGBTEXT titleFont:24 textAlignment:NSTextAlignmentCenter isFit:NO];
    [_viewInShop addSubview:lblPaiNo];
    self.lblPaiNo = lblPaiNo;
    
    UILabel *lblPaiText = [[UILabel alloc] initCommonWithFrame:CGRectMake(0, lblPaiNo.bottom+8, lblPaiNo.width, 12) title:@"排队号码" bgColor:[UIColor clearColor] titleColor:RGBTEXTINFO titleFont:12 textAlignment:NSTextAlignmentCenter isFit:NO];
    [_viewInShop addSubview:lblPaiText];
    
    // 排队人数
    UILabel *lblWaitNumber = [[UILabel alloc] initCommonWithFrame:CGRectMake(_viewInShop.width/3, 32, _viewInShop.width/3, 24) title:[NSString stringWithFormat:@"%ld",[self.dicOrderInfo[@"waitNum"] integerValue]] bgColor:[UIColor clearColor] titleColor:RGBTEXT titleFont:24 textAlignment:NSTextAlignmentCenter isFit:NO];
    [_viewInShop addSubview:lblWaitNumber];
    self.lblWaitNum = lblWaitNumber;
    
    UILabel *lblWaitNumberText = [[UILabel alloc] initCommonWithFrame:CGRectMake(lblWaitNumber.x, lblWaitNumber.bottom+8, lblWaitNumber.width, 12) title:@"前面排队(人)" bgColor:[UIColor clearColor] titleColor:RGBTEXTINFO titleFont:12 textAlignment:NSTextAlignmentCenter isFit:NO];
    [_viewInShop addSubview:lblWaitNumberText];
    
    // 排队人数
    UILabel *lblWaitTime = [[UILabel alloc] initCommonWithFrame:CGRectMake(_viewInShop.width/3*2, 32, _viewInShop.width/3, 24) title:[NSString stringWithFormat:@"%.0f",[self.dicOrderInfo[@"waitTime"] floatValue]] bgColor:[UIColor clearColor] titleColor:RGBTEXT titleFont:24 textAlignment:NSTextAlignmentCenter isFit:NO];
    [_viewInShop addSubview:lblWaitTime];
    self.lblWaitTime = lblWaitTime;
    
    UILabel *lblWaitTimeText = [[UILabel alloc] initCommonWithFrame:CGRectMake(lblWaitTime.x, lblWaitTime.bottom+8, lblWaitTime.width, 12) title:@"预计等待(分钟)" bgColor:[UIColor clearColor] titleColor:RGBTEXTINFO titleFont:12 textAlignment:NSTextAlignmentCenter isFit:NO];
    [_viewInShop addSubview:lblWaitTimeText];
    
    // 门店名称/地址
    UIView *viewAddress = [[UIView alloc] initWithFrame:CGRectMake(0, lblWaitTimeText.bottom+24, _viewInShop.width, 50)];
    [_viewInShop addSubview:viewAddress];
    
    UIView *line1 = [[UIView alloc] initWithFrame:CGRectMake(24, 0, viewAddress.width-48, 1)];
    line1.backgroundColor = RGBCOLOR(241, 241, 241);
    [viewAddress addSubview:line1];
    UIView *line2 = [[UIView alloc] initWithFrame:CGRectMake(24, 49, viewAddress.width-48, 1)];
    line2.backgroundColor = RGBCOLOR(241, 241, 241);
    [viewAddress addSubview:line2];
    
    UILabel *lblShopName = [[UILabel alloc] initCommonWithFrame:CGRectMake(24, 0, viewAddress.width/2+50, 16) title:self.dicOrderInfo[@"storeName"] bgColor:[UIColor clearColor] titleColor:RGBTEXT titleFont:14 textAlignment:NSTextAlignmentLeft isFit:NO];
    lblShopName.font = TEXT_SC_TFONT(TEXT_SC_Medium, 14);
    lblShopName.centerY = viewAddress.height/2;
    self.lblShopName = lblShopName;
    [viewAddress addSubview:lblShopName];
    
    // 项目详情
    NSString *strDes = @"发型师\n\n服务项目\n\n合计\n\n取号时间";
    UILabel *lblDesText = [[UILabel alloc] initCommonWithFrame:CGRectMake(24, viewAddress.bottom+16, _viewInShop.width/2, 100) title:strDes bgColor:[UIColor clearColor] titleColor:RGBTEXTINFO titleFont:14 textAlignment:NSTextAlignmentLeft isFit:NO];
    lblDesText.numberOfLines = 0;
    [lblDesText sizeToFit];
    [_viewInShop addSubview:lblDesText];
    
    NSString *strInfo = [NSString stringWithFormat:@"%@\n\n%@\n\n¥%.2f\n\n%@",self.dicOrderInfo[@"tonyName"],self.dicOrderInfo[@"serviceName"],[self.dicOrderInfo[@"payAmount"] floatValue],self.dicOrderInfo[@"createTime"]];
    UILabel *lblDes = [[UILabel alloc] initCommonWithFrame:CGRectMake(_viewInShop.width/2+12, lblDesText.y, _viewInShop.width/2, 100) title:strInfo bgColor:[UIColor clearColor] titleColor:RGBTEXT titleFont:14 textAlignment:NSTextAlignmentRight isFit:NO];
    lblDes.numberOfLines = 0;
    [lblDes sizeToFit];
    self.lblDes = lblDes;
    [_viewInShop addSubview:lblDes];
    
    UIView *line3 = [[UIView alloc] initWithFrame:CGRectMake(24, lblDes.bottom+16, _viewInShop.width-48, 1)];
    line3.backgroundColor = RGBCOLOR(241, 241, 241);
    [_viewInShop addSubview:line3];
    
    //取消排号
    UIButton *buttCancel = [[UIButton alloc] initSystemWithFrame:CGRectMake(24, line3.bottom+24, _viewInShop.width-48, 36) btnTitle:@"取消排号" btnImage:@"" titleColor:RGBMAIN titleFont:14];
    self.btnCancel = buttCancel;
    buttCancel.layer.cornerRadius = 2;
    buttCancel.layer.borderColor = RGBMAIN.CGColor;
    buttCancel.layer.borderWidth = 1;
    [_viewInShop addSubview:buttCancel];
    [buttCancel addTarget:self action:@selector(btnAction:) forControlEvents:UIControlEventTouchUpInside];
    
    _viewInShop.height = buttCancel.bottom+24;
    
    return _viewInShop;
}

-(void)dealloc{
    DTLog(@"HDMyCutOrdersWaitViewController dealloc");
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

-(UIView *)createItemView:(CGRect)frame title:(NSString *)title item:(NSString *)itemStr itemColor:(UIColor *)color{
    UIView *view = [[UIView alloc] initWithFrame:frame];
    
    UILabel *lbl = [[UILabel alloc] initCommonWithFrame:CGRectMake(24, 0, 100, view.height) title:title bgColor:[UIColor clearColor] titleColor:RGBCOLOR(153, 153, 153) titleFont:14 textAlignment:NSTextAlignmentLeft isFit:YES];
    lbl.height = view.height;
    [view addSubview:lbl];
    
    UILabel *item = [[UILabel alloc] initCommonWithFrame:CGRectMake(CGRectGetMaxX(lbl.frame)+10, 0, view.width-CGRectGetMaxX(lbl.frame)-10-24, view.height) title:itemStr bgColor:[UIColor clearColor] titleColor:color titleFont:14 textAlignment:NSTextAlignmentRight isFit:NO];
    [view addSubview:item];
    
    return view;
}


@end
