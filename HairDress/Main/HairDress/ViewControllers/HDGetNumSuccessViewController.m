//
//  HDGetNumSuccessViewController.m
//  HairDress
//
//  Created by 张凯中 on 2019/12/24.
//  Copyright © 2019 zhangkaizhong. All rights reserved.
//

#import "HDGetNumSuccessViewController.h"

#import "HDGetCutNumberViewController.h"
#import "HDCheckCutQueneViewController.h"
#import "HDMyCutAllOrdersViewController.h"
#import "HDCancelCutQueneViewController.h"

@interface HDGetNumSuccessViewController ()<navViewDelegate>

@property (nonatomic,strong) HDBaseNavView * navView;  // 导航栏
@property (nonatomic,strong) UIScrollView *mainScrollView; // 主视图

@end

@implementation HDGetNumSuccessViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.view.backgroundColor = RGBBG;
    [self.view addSubview:self.navView];
    [self.view addSubview:self.mainScrollView];
}

#pragma mark ================== delegate / action =====================

-(void)navBackClicked{
    for (UIViewController *viewCon in self.navigationController.viewControllers) {
        if ([viewCon isKindOfClass:[HDGetCutNumberViewController class]]) {
            [self.navigationController popToViewController:viewCon animated:YES];
            return;
        }
        if ([viewCon isKindOfClass:[HDMyCutAllOrdersViewController class]]) {
            HDMyCutAllOrdersViewController *orderVC = (HDMyCutAllOrdersViewController *)viewCon;
            [orderVC selectIndexRefresh:0 isReoload:YES];
            [self.navigationController popToViewController:orderVC animated:YES];
            return;
        }
    }
    [self.navigationController popViewControllerAnimated:YES];
}

// 查看排队
-(void)btnAction:(UIButton *)sender{
    if ([sender.titleLabel.text isEqualToString:@"取消排号"]) {
        HDCancelCutQueneViewController *cancelVC = [HDCancelCutQueneViewController new];
        cancelVC.order_id = self.orderCutInfo[@"orderId"];
        cancelVC.queue_num = self.orderCutInfo[@"queueNum"];
        cancelVC.cancel_type = @"user";
        [self.navigationController pushViewController:cancelVC animated:YES];
    }else{
        //到店请求
        [self startQueueRequest];
    }
}

#pragma mark -- 跳转第三方地图导航
-(void)tapAddressAction:(UIGestureRecognizer *)sender{
    [HDToolHelper showMapsWithLat:self.orderCutInfo[@"latitude"] longt:self.orderCutInfo[@"longitude"]];
}

#pragma mark ================== 签到请求 =====================
-(void)startQueueRequest{
    NSDictionary *params = @{
        @"orderId":self.orderCutInfo[@"orderId"]
    };
    [MHNetworkManager postReqeustWithURL:URL_YuyueStartQueue params:params successBlock:^(NSDictionary *returnData) {
        if ([returnData[@"respCode"] integerValue] == 200) {
            [SVHUDHelper showDarkWarningMsg:@"签到成功"];
            [HDToolHelper delayMethodFourGCD:1 method:^{
                HDCheckCutQueneViewController *check = [HDCheckCutQueneViewController new];
                check.dicOrderInfo = returnData[@"data"];
                [self.navigationController pushViewController:check animated:YES];
            }];
        }else{
            [SVHUDHelper showInfoWithTimestamp:1 msg:returnData[@"respMsg"]];
        }
    } failureBlock:^(NSError *error) {
        
    } showHUD:YES];
}

#pragma mark ================== 加载控件 =====================

-(UIScrollView *)mainScrollView{
    if (!_mainScrollView) {
        _mainScrollView = [[UIScrollView alloc] initWithFrame:CGRectMake(0, NAVHIGHT, kSCREEN_WIDTH, kSCREEN_HEIGHT-NAVHIGHT)];
        _mainScrollView.backgroundColor = [UIColor clearColor];
        
        UIView *viewBack = [[UIView alloc] initWithFrame:CGRectMake(16, 16, kSCREEN_WIDTH-32, 300)];
        viewBack.backgroundColor = [UIColor whiteColor];
        viewBack.layer.cornerRadius = 4;
        [_mainScrollView addSubview:viewBack];
        
        //预约时段
        UIView *viewTime = [self createItemView:CGRectMake(0, 32, viewBack.width, 28) title:@"预约时段" item:[NSString stringWithFormat:@"%@-%@",self.orderCutInfo[@"startTimeDate"],self.orderCutInfo[@"endTimeDate"]] itemColor:RGBMAIN];
        [viewBack addSubview:viewTime];
        //排队号码
        UIView *viewQueue = [self createItemView:CGRectMake(0, viewTime.bottom, viewBack.width, 28) title:@"排队号码" item:self.orderCutInfo[@"queueNum"] itemColor:RGBTEXT];
        [viewBack addSubview:viewQueue];
        //服务项目
        UIView *viewService = [self createItemView:CGRectMake(0, viewQueue.bottom, viewBack.width, 28) title:@"服务项目" item:self.orderCutInfo[@"serviceName"] itemColor:RGBTEXT];
        [viewBack addSubview:viewService];
        //合计
        UIView *viewAmount = [self createItemView:CGRectMake(0, viewService.bottom, viewBack.width, 28) title:@"合计" item:[NSString stringWithFormat:@"¥%.2f",[self.orderCutInfo[@"payAmount"] floatValue]] itemColor:RGBTEXT];
        [viewBack addSubview:viewAmount];
        //取号时间
        UIView *viewCreateTime = [self createItemView:CGRectMake(0, viewAmount.bottom, viewBack.width, 28) title:@"取号时间" item:self.orderCutInfo[@"createTime"] itemColor:RGBTEXT];
        [viewBack addSubview:viewCreateTime];
        
        UIView *line1 = [[UIView alloc] initWithFrame:CGRectMake(24, viewCreateTime.bottom+16, viewBack.width-48, 1)];
        line1.backgroundColor = RGBAlpha(241, 241, 241, 1);
        [viewBack addSubview:line1];
        
        //门店视图
        UIView *viewShop = [[UIView alloc] initWithFrame:CGRectMake(0, line1.bottom, viewBack.width, 49)];
        [viewBack addSubview:viewShop];
        
        UITapGestureRecognizer *tapAdd = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapAddressAction:)];
        viewShop.userInteractionEnabled = YES;
        [viewShop addGestureRecognizer:tapAdd];
        
        UIImageView *imageAddress = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"common_ic_location"]];
        imageAddress.x = viewShop.width - imageAddress.width-24;
        [viewShop addSubview:imageAddress];
        
        UILabel *lblShopName = [[UILabel alloc] initCommonWithFrame:CGRectMake(24, 0, viewShop.width- imageAddress.width - 16-24, 14) title:self.orderCutInfo[@"storeName"] bgColor:[UIColor clearColor] titleColor:RGBTEXT titleFont:14 textAlignment:NSTextAlignmentLeft isFit:NO];
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
        
        UIView *line2 = [[UIView alloc] initWithFrame:CGRectMake(24, viewShop.height-1, viewBack.width-48, 1)];
        line2.backgroundColor = RGBAlpha(241, 241, 241, 1);
        [viewShop addSubview:line2];
        
        // 注意
        UILabel *lblAtten = [[UILabel alloc] initCommonWithFrame:CGRectMake(24, viewShop.bottom+16, viewBack.width-48, 50) title:@"" bgColor:[UIColor clearColor] titleColor:RGBTEXT titleFont:13 textAlignment:NSTextAlignmentLeft isFit:NO];
        lblAtten.text = self.orderCutInfo[@"content"];
        lblAtten.numberOfLines = 0;
        [lblAtten sizeToFit];
        [viewBack addSubview:lblAtten];
        
        UIView *line3 = [[UIView alloc] initWithFrame:CGRectMake(24, lblAtten.bottom+16, kSCREEN_WIDTH-48, 1)];
        line3.backgroundColor = RGBAlpha(241, 241, 241, 1);
        [viewBack addSubview:line3];
            
        // 排队规则
        UILabel *lblRule = [[UILabel alloc] initCommonWithFrame:CGRectMake(24, line3.bottom+16, viewBack.width-48, 12) title:@"排队规则" bgColor:[UIColor clearColor] titleColor:RGBTEXTINFO titleFont:13 textAlignment:NSTextAlignmentLeft isFit:NO];
        lblRule.numberOfLines = 0;
        [lblRule sizeToFit];
        [viewBack addSubview:lblRule];
        
        NSString *strContent = self.orderCutInfo[@"rule"];
        UILabel *lblRuleContent = [[UILabel alloc] initCommonWithFrame:CGRectMake(24, lblRule.bottom+11, viewBack.width-48, 50) title:strContent bgColor:[UIColor clearColor] titleColor:RGBTEXT titleFont:12 textAlignment:NSTextAlignmentLeft isFit:NO];
        lblRuleContent.numberOfLines = 0;
        [lblRuleContent sizeToFit];
        [viewBack addSubview:lblRuleContent];
        
        UIView *line = [[UIView alloc] initWithFrame:CGRectMake(24, lblRuleContent.bottom+16, viewBack.width-48, 1)];
        line.backgroundColor = RGBCOLOR(241, 241, 241);
        [viewBack addSubview:line];
        
        
        // 取消排队按钮
        UIButton *btnCancel = [[UIButton alloc] initSystemWithFrame:CGRectMake(24, line.bottom+24, (viewBack.width-48-15)/2, 36) btnTitle:@"取消排号" btnImage:@"" titleColor:RGBMAIN titleFont:14];
        btnCancel.layer.cornerRadius = 6;
        btnCancel.layer.borderWidth = 1;
        btnCancel.titleLabel.font = TEXT_SC_TFONT(TEXT_SC_Medium, 14);
        btnCancel.layer.borderColor = RGBMAIN.CGColor;
        [viewBack addSubview:btnCancel];
        [btnCancel addTarget:self action:@selector(btnAction:) forControlEvents:UIControlEventTouchUpInside];
        
        //我已到店
        UIButton *btnAtShop = [[UIButton alloc] initSystemWithFrame:CGRectMake(CGRectGetMaxX(btnCancel.frame)+15, line.bottom+24, (viewBack.width-48-15)/2, 36) btnTitle:@"我已到店" btnImage:@"" titleColor:[UIColor whiteColor] titleFont:14];
        btnAtShop.layer.cornerRadius = 6;
        btnAtShop.backgroundColor = RGBMAIN;
        btnAtShop.titleLabel.font = TEXT_SC_TFONT(TEXT_SC_Medium, 14);
        [viewBack addSubview:btnAtShop];
        [btnAtShop addTarget:self action:@selector(btnAction:) forControlEvents:UIControlEventTouchUpInside];
        
        viewBack.height = btnAtShop.bottom + 40;
        
        _mainScrollView.contentSize = CGSizeMake(kSCREEN_WIDTH, viewBack.height);
        
    }
    return _mainScrollView;
}

-(HDBaseNavView *)navView{
    if (!_navView) {
        _navView = [[HDBaseNavView alloc] initWithFrame:CGRectMake(0, 0, kSCREEN_WIDTH, NAVHIGHT) title:@"取号成功" bgColor:[UIColor whiteColor] backBtn:YES rightBtn:@"" rightBtnImage:@"" theDelegate:self];
        
    }
    return _navView;
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
