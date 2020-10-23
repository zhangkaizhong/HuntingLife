//
//  HDCheckCutQueneViewController.m
//  HairDress
//
//  Created by Apple on 2019/12/25.
//  Copyright © 2019 zhangkaizhong. All rights reserved.
//

#import "HDCheckCutQueneViewController.h"

#import "HDCancelCutQueneViewController.h"

@interface HDCheckCutQueneViewController ()<navViewDelegate>

@property (nonatomic,strong) HDBaseNavView * navView;  // 导航栏
@property (nonatomic,strong) UIScrollView *mainScrollView; // 主视图
@property (nonatomic,strong) UIView *mainView;
@property (nonatomic,weak) UIView *viewWaitTime; // 等待时间view
@property (nonatomic,weak) UIView *viewWaitNumber; // 等待人数view
@property (nonatomic,weak) UIView *viewNumberCode; // 号码view

@property (nonatomic,strong) NSArray *arrData;

@property (nonatomic,weak) UIButton * btnCancel;  // 取消排队
@property (nonatomic,weak) UIButton * btnAtShop;  // 我已到店

@end

@implementation HDCheckCutQueneViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.view.backgroundColor = RGBBG;
    [self.view addSubview:self.navView];
    [self.view addSubview:self.mainScrollView];
}

#pragma mark ================== delegate / action =====================

-(void)navBackClicked{
    [self.navigationController popViewControllerAnimated:YES];
}

//查看排队进度
-(void)checkQueueProcessAction{
    [self requestQueueProcess];
    
}

// 取消排队 我已到店
-(void)btnAction:(UIButton *)sender{
    if ([sender.titleLabel.text isEqualToString:@"取消排号"]) {
        HDCancelCutQueneViewController *cancelVC = [HDCancelCutQueneViewController new];
        cancelVC.order_id = self.dicOrderInfo[@"orderId"];
        cancelVC.queue_num = self.dicOrderInfo[@"queueNum"];
        cancelVC.cancel_type = @"user";
        [self.navigationController pushViewController:cancelVC animated:YES];
    }else{
        // 一键呼叫
        
    }
}

#pragma mark -- 查看排队进度请求
-(void)requestQueueProcess{
    [MHNetworkManager postReqeustWithURL:URL_YuyueDetailOrderPop params:@{@"orderId":self.dicOrderInfo[@"orderId"]} successBlock:^(NSDictionary *returnData) {
        DTLog(@"%@",returnData);
        returnData = [HDToolHelper nullDicToDic:returnData];
        if ([returnData[@"respCode"] integerValue] == 200) {
            NSMutableArray *arr = [NSMutableArray new];
            
            NSArray *arrQueue = returnData[@"data"][@"queueList"];
            NSArray *arrService = returnData[@"data"][@"serviceList"];
            
            for (NSDictionary *dic in arrService) {
                [arr addObject:dic];
            }
            for (NSDictionary *dic in arrQueue) {
                [arr addObject:dic];
            }
            [[WMZAlert shareInstance] showAlertWithType:AlertTypeQueueCheck headTitle:@"排队进度" textTitle:@{@"arr":arr,@"cutter":returnData[@"data"]} viewController:self leftHandle:^(id anyID) {
                //再次预约
                
            }rightHandle:^(id any) {

            }];
        }
    } failureBlock:^(NSError *error) {
        
    } showHUD:YES];
}

#pragma mark ================== 加载视图 =====================

-(UIScrollView *)mainScrollView{
    if (!_mainScrollView) {
        _mainScrollView = [[UIScrollView alloc] initWithFrame:CGRectMake(0, NAVHIGHT, kSCREEN_WIDTH, kSCREEN_HEIGHT-NAVHIGHT)];
        _mainScrollView.backgroundColor = RGBBG;
        
        [_mainScrollView addSubview:self.mainView];
    }
    return _mainScrollView;
}

-(UIView *)mainView{
    if (!_mainView) {
        _mainView = [[UIView alloc] initWithFrame:CGRectMake(16, 16, kSCREEN_WIDTH-32, 300)];
        _mainView.backgroundColor = [UIColor whiteColor];
        _mainView.layer.cornerRadius = 4;
        
        // 号码
        UIView *viewNumberCode = [[UIView alloc] initWithFrame:CGRectMake(0, 32, (_mainView.width)/3, 44)];
        self.viewNumberCode = viewNumberCode;
        [_mainView addSubview:viewNumberCode];
        
        UILabel *lblNumberCode = [[UILabel alloc] initCommonWithFrame:CGRectMake(0, 0, (_mainView.width)/3, 24) title:self.dicOrderInfo[@"queueNum"] bgColor:[UIColor clearColor] titleColor:RGBTEXT titleFont:24 textAlignment:NSTextAlignmentCenter isFit:NO];
        [viewNumberCode addSubview:lblNumberCode];
        UILabel *lblNumberCodeDes = [[UILabel alloc] initCommonWithFrame:CGRectMake(0, lblNumberCode.bottom+8, (_mainView.width)/3, 12) title:@"排队号码" bgColor:[UIColor clearColor] titleColor:RGBTEXTINFO titleFont:12 textAlignment:NSTextAlignmentCenter isFit:NO];
        [viewNumberCode addSubview:lblNumberCodeDes];
        
        // 排队人数
        UIView *viewWatNumber = [[UIView alloc] initWithFrame:CGRectMake(0, 32, (_mainView.width)/3, 44)];
        self.viewWaitNumber = viewWatNumber;
        [_mainView addSubview:viewWatNumber];
        self.viewWaitNumber.centerX = _mainView.width/2;
        
        UILabel *lblWaitNumber = [[UILabel alloc] initCommonWithFrame:CGRectMake(0, 0, (_mainView.width)/3, 24) title:[NSString stringWithFormat:@"%ld",(long)[self.dicOrderInfo[@"waitNum"] integerValue]] bgColor:[UIColor clearColor] titleColor:RGBTEXT titleFont:24 textAlignment:NSTextAlignmentCenter isFit:NO];
        [viewWatNumber addSubview:lblWaitNumber];
        UILabel *lblWait = [[UILabel alloc] initCommonWithFrame:CGRectMake(0, lblWaitNumber.bottom+8, (_mainView.width)/3, 12) title:@"前面人数(人)" bgColor:[UIColor clearColor] titleColor:RGBTEXTINFO titleFont:12 textAlignment:NSTextAlignmentCenter isFit:NO];
        [viewWatNumber addSubview:lblWait];
        
        // 等待时间
        UIView *viewWaitTime = [[UIView alloc] initWithFrame:CGRectMake(_mainView.width-(_mainView.width)/3, 32, (_mainView.width)/3, 44)];
        self.viewWaitTime = viewWaitTime;
        [_mainView addSubview:viewWaitTime];
        
        UILabel *lblWaitTime = [[UILabel alloc] initCommonWithFrame:CGRectMake(0, 0, (_mainView.width)/3, 24) title:[NSString stringWithFormat:@"%.0f",[self.dicOrderInfo[@"waitTime"] floatValue]] bgColor:[UIColor clearColor] titleColor:RGBTEXT titleFont:24 textAlignment:NSTextAlignmentCenter isFit:NO];
        [viewWaitTime addSubview:lblWaitTime];
        UILabel *lblWaitTimeDes = [[UILabel alloc] initCommonWithFrame:CGRectMake(0, lblWaitTime.bottom+8, (_mainView.width)/3, 12) title:@"预计等待(分钟)" bgColor:[UIColor clearColor] titleColor:RGBTEXTINFO titleFont:12 textAlignment:NSTextAlignmentCenter isFit:NO];
        [viewWaitTime addSubview:lblWaitTimeDes];
        
        // 查看排队进度按钮
//        UIButton *btnCheck = [[UIButton alloc] initSystemWithFrame:CGRectMake(0, viewWatNumber.bottom+24, 110, 14) btnTitle:@"查看排队进度 >>" btnImage:@"" titleColor:RGBMAIN titleFont:14];
//        btnCheck.centerX = kSCREEN_WIDTH/2;
//        [_mainView addSubview:btnCheck];
//        [btnCheck addTarget:self action:@selector(checkQueueProcessAction) forControlEvents:UIControlEventTouchUpInside];
        
        // 门店地址视图
        UIView *viewShop = [[UIView alloc] initWithFrame:CGRectMake(0, viewWatNumber.bottom+24, _mainView.width, 50)];
        [_mainView addSubview:viewShop];
        
        UIView *line1 = [[UIView alloc] initWithFrame:CGRectMake(24, 0, _mainView.width-48, 1)];
        line1.backgroundColor = RGBAlpha(241, 241, 241, 1);
        [viewShop addSubview:line1];
        UIView *line2 = [[UIView alloc] initWithFrame:CGRectMake(24, 49, _mainView.width-48, 1)];
        line2.backgroundColor = RGBAlpha(241, 241, 241, 1);
        [viewShop addSubview:line2];
        
        UILabel *lblShopName = [[UILabel alloc] initCommonWithFrame:CGRectMake(24, 0, viewShop.width-24, 16) title:self.dicOrderInfo[@"storeName"] bgColor:[UIColor clearColor] titleColor:RGBTEXT titleFont:16 textAlignment:NSTextAlignmentLeft isFit:NO];
        [viewShop addSubview:lblShopName];
        lblShopName.centerY = viewShop.height/2;
        
        // 服务项目详情
        NSString *strContent = @"发型师\n\n服务项目\n\n合计\n\n取号时间";
        UILabel *lblServiceContent = [[UILabel alloc] initCommonWithFrame:CGRectMake(24, viewShop.bottom+16, _mainView.width/2, 50) title:strContent bgColor:[UIColor clearColor] titleColor:RGBTEXTINFO titleFont:14 textAlignment:NSTextAlignmentLeft isFit:NO];
        lblServiceContent.numberOfLines = 0;
        [lblServiceContent sizeToFit];
        [_mainView addSubview:lblServiceContent];
        
        NSString *strContentDes = [NSString stringWithFormat:@"%@\n\n%@\n\n¥%@\n\n%@",self.dicOrderInfo[@"tonyName"],self.dicOrderInfo[@"serviceName"],self.dicOrderInfo[@"payAmount"],self.dicOrderInfo[@"createTime"]];
        UILabel *lblContentDes = [[UILabel alloc] initCommonWithFrame:CGRectMake(_mainView.width/2+8, viewShop.bottom+16, _mainView.width/2-24, 50) title:strContentDes bgColor:[UIColor clearColor] titleColor:RGBTEXT titleFont:14 textAlignment:NSTextAlignmentRight isFit:NO];
        lblContentDes.numberOfLines = 0;
        [lblContentDes sizeToFit];
        [_mainView addSubview:lblContentDes];
        
        UIView *line3 = [[UIView alloc] initWithFrame:CGRectMake(24, lblContentDes.bottom+16, _mainView.width-48, 1)];
        line3.backgroundColor = RGBAlpha(241, 241, 241, 1);
        [_mainView addSubview:line3];
        
        // 取消排队按钮
        UIButton *btnCancel = [[UIButton alloc] initSystemWithFrame:CGRectMake(24, line3.bottom+24, (_mainView.width-48), 36) btnTitle:@"取消排号" btnImage:@"" titleColor:RGBMAIN titleFont:14];
        btnCancel.layer.cornerRadius = 2;
        btnCancel.layer.borderWidth = 1;
        btnCancel.layer.borderColor = RGBMAIN.CGColor;
        [_mainView addSubview:btnCancel];
        self.btnCancel = btnCancel;
        [self.btnCancel addTarget:self action:@selector(btnAction:) forControlEvents:UIControlEventTouchUpInside];
        
//        UIButton *btnAtShop = [[UIButton alloc] initSystemWithFrame:CGRectMake(CGRectGetMaxX(btnCancel.frame)+15, line3.bottom+24, (_mainView.width-48-15)/2, 36) btnTitle:@"一键呼叫" btnImage:@"" titleColor:[UIColor whiteColor] titleFont:14];
//        btnAtShop.layer.cornerRadius = 2;
//        btnAtShop.backgroundColor = RGBMAIN;
//        [_mainView addSubview:btnAtShop];
//        self.btnAtShop = btnAtShop;
//        [self.btnAtShop addTarget:self action:@selector(btnAction:) forControlEvents:UIControlEventTouchUpInside];
        
        
        _mainView.height = btnCancel.bottom+24;
        _mainScrollView.contentSize = CGSizeMake(kSCREEN_WIDTH, _mainView.bottom);
        
    }
    return _mainView;
}

-(HDBaseNavView *)navView{
    if (!_navView) {
        _navView = [[HDBaseNavView alloc] initWithFrame:CGRectMake(0, 0, kSCREEN_WIDTH, NAVHIGHT) title:@"排队进度" bgColor:[UIColor whiteColor] backBtn:YES rightBtn:@"" rightBtnImage:@"" theDelegate:self];
        
    }
    return _navView;
}

@end
