//
//  HDCancelCutQueneViewController.m
//  HairDress
//
//  Created by Apple on 2019/12/25.
//  Copyright © 2019 zhangkaizhong. All rights reserved.
//

#import "HDCancelCutQueneViewController.h"

#import "HDShopDetailViewController.h"
#import "HDMyCutAllOrdersViewController.h"
#import "HDOrderManageViewController.h"

@interface HDCancelCutQueneViewController ()<navViewDelegate>

@property (nonatomic,strong) HDBaseNavView * navView;  // 导航栏
@property (nonatomic,strong) UIScrollView *mainScrollView; // 主视图
@property (nonatomic,weak) UIView *viewBtns;
@property (nonatomic,strong) UIButton * btnComfirn;  // 确认按钮

@property (nonatomic,strong) NSArray *arrData;

@property (nonatomic,copy) NSString *cancel_reason;//取消原因

@end

@implementation HDCancelCutQueneViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.view.backgroundColor = RGBBG;
    [self.view addSubview:self.navView];
    
    self.cancel_reason = @"";
    
    [self getCancelReasonList];
}

#pragma mark ================== delegate / action =====================

-(void)navBackClicked{
    [self.navigationController popViewControllerAnimated:YES];
}

// 选择取消原因
-(void)btnChooseTypeAction:(UIButton *)sender{
    sender.selected=!sender.selected;
    
    if (sender.selected) {
        sender.layer.borderColor = RGBMAIN.CGColor;
    }else{
        sender.layer.borderColor = RGBLINE.CGColor;
    }
    
    self.cancel_reason = @"";
    for (int i =0 ;i<self.arrData.count; i++) {
        UIButton *btn = (UIButton *)[_viewBtns viewWithTag:i+100];
        if (btn.selected) {
            if ([self.cancel_reason isEqualToString:@""]) {
                self.cancel_reason = btn.titleLabel.text;
            }
            else{
                self.cancel_reason = [NSString stringWithFormat:@"%@,%@",self.cancel_reason,btn.titleLabel.text];
            }
        }
    }
    if (![self.cancel_reason isEqualToString:@""]) {
        self.btnComfirn.userInteractionEnabled = YES;
        self.btnComfirn.backgroundColor = RGBMAIN;
        [self.btnComfirn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    }
    else{
        self.btnComfirn.backgroundColor = RGBCOLOR(230, 230, 230);
        [self.btnComfirn setTitleColor:RGBTEXTINFO forState:UIControlStateNormal];
        self.btnComfirn.userInteractionEnabled = NO;
    }
    
    DTLog(@"%@",self.cancel_reason);
}

// 确定
-(void)btnComfirnAction{
    if ([HDToolHelper StringIsNullOrEmpty:self.cancel_reason]) {
        [SVHUDHelper showInfoWithTimestamp:1 msg:@"请选择取消原因"];
        return;
    }
    
    [self cancelOrderRequest];
}

#pragma mark -- 取消订单请求
-(void)cancelOrderRequest{
    if (!self.order_id) {
        [SVHUDHelper showInfoWithTimestamp:1 msg:@"订单ID有误，无法取消"];
        return;
    }
    [MHNetworkManager postReqeustWithURL:URL_YuyueCancelOrder params:@{@"cancelReason":self.cancel_reason,@"orderId":self.order_id,@"cancelType":self.cancel_type} successBlock:^(NSDictionary *returnData) {
        if ([returnData[@"respCode"] integerValue] == 200) {
            [SVHUDHelper showDarkWarningMsg:[NSString stringWithFormat:@"您的排队%@已取消",self.queue_num]];
            [HDToolHelper delayMethodFourGCD:1 method:^{
                for (UIViewController *vieCon in [self.navigationController viewControllers]) {
                    if ([vieCon isKindOfClass:[HDShopDetailViewController class]]) {
                        [self.navigationController popToViewController:vieCon animated:YES];
                    }
                    if ([vieCon isKindOfClass:[HDMyCutAllOrdersViewController class]] || [vieCon isKindOfClass:[HDOrderManageViewController class]]) {
                        [[NSNotificationCenter defaultCenter] postNotificationName:@"cancelQueue" object:nil];
                        [self.navigationController popToViewController:vieCon animated:YES];
                    }
                }
            }];
        }else{
            [SVHUDHelper showInfoWithTimestamp:1 msg:returnData[@"respMsg"]];
        }
    } failureBlock:^(NSError *error) {
        
    } showHUD:YES];
}

//获取取消原因列表
-(void)getCancelReasonList{
    [MHNetworkManager postReqeustWithURL:URL_ConfigList params:@{@"configType":@"cancel_reason"} successBlock:^(NSDictionary *returnData) {
        if ([returnData[@"respCode"] integerValue] == 200) {
            self.arrData = returnData[@"data"];
            [self.view addSubview:self.mainScrollView];
            [self.view addSubview:self.btnComfirn];
        }
    } failureBlock:^(NSError *error) {
        
    } showHUD:YES];
}

#pragma mark ================== 加载控件 =====================

-(UIScrollView *)mainScrollView{
    if (!_mainScrollView) {
        _mainScrollView = [[UIScrollView alloc] initWithFrame:CGRectMake(0, NAVHIGHT, kSCREEN_WIDTH, kSCREEN_HEIGHT-NAVHIGHT-80)];
        _mainScrollView.backgroundColor = [UIColor clearColor];
        
        UIView *viewBtns = [[UIView alloc] initWithFrame:CGRectMake(0, 0, kSCREEN_WIDTH, 300)];
        [_mainScrollView addSubview:viewBtns];
        viewBtns.backgroundColor = [UIColor whiteColor];
        self.viewBtns = viewBtns;
        
        UILabel *lblTitle = [[UILabel alloc] initCommonWithFrame:CGRectMake(16, 16, kSCREEN_WIDTH, 14) title:@"取消原因" bgColor:[UIColor clearColor] titleColor:RGBTEXT titleFont:14 textAlignment:NSTextAlignmentLeft isFit:NO];
        [viewBtns addSubview:lblTitle];
        
        UILabel *lblContent = [[UILabel alloc] initCommonWithFrame:CGRectMake(16, lblTitle.bottom+16, kSCREEN_WIDTH-32, 12) title:@"请选择取消原因，我们会为您持续优化产品体验和服务体验。" bgColor:[UIColor clearColor] titleColor:RGBLIGHT_TEXTINFO titleFont:12 textAlignment:NSTextAlignmentLeft isFit:NO];
        [viewBtns addSubview:lblContent];
        
        // 添加按钮
        for (int i = 0; i<self.arrData.count; i++) {
            
            UIButton *button = [[UIButton alloc] initCustomWithFrame:CGRectMake(16, 82+i*(56+16), (kSCREEN_WIDTH-32-23)/2, 56) btnTitle:self.arrData[i][@"configName"] btnImage:@"" btnType:RIGHT_DOWN bgColor:[UIColor whiteColor] titleColor:RGBTEXT titleFont:14];
            button.tag = 100+i;
            
            button.layer.cornerRadius = 4;
            button.layer.borderWidth = 1;
            button.layer.borderColor = RGBLINE.CGColor;
            [button setTitleColor:RGBMAIN forState:UIControlStateSelected];
            [button setImage:[UIImage imageNamed:@"login_input_ic_selected"] forState:UIControlStateSelected];
            
            UIButton *btnLast = (UIButton *)[viewBtns viewWithTag:100+i-1];
            if(i%2 == 1){
                button.x = kSCREEN_WIDTH/2+23/2;
                button.y = btnLast.y;
            }else{
                if (i==0) {
                    button.x = 16;
                    button.y = 82;
                }else{
                    button.x = 16;
                    button.y = btnLast.y+56+16;
                }
            }
            [button addTarget:self action:@selector(btnChooseTypeAction:) forControlEvents:UIControlEventTouchUpInside];
            
            [viewBtns addSubview:button];
            viewBtns.height = button.bottom+24;
        }
        
        _mainScrollView.contentSize = CGSizeMake(kSCREEN_WIDTH, _viewBtns.bottom+16);
        
    }
    return _mainScrollView;
}

-(HDBaseNavView *)navView{
    if (!_navView) {
        _navView = [[HDBaseNavView alloc] initWithFrame:CGRectMake(0, 0, kSCREEN_WIDTH, NAVHIGHT) title:@"取消排队" bgColor:[UIColor whiteColor] backBtn:YES rightBtn:@"" rightBtnImage:@"" theDelegate:self];
        
    }
    return _navView;
}

-(UIButton *)btnComfirn{
    if (!_btnComfirn) {
        _btnComfirn = [[UIButton alloc] initSystemWithFrame:CGRectMake(16,kSCREEN_HEIGHT - 48 -16, kSCREEN_WIDTH-32, 48) btnTitle:@"确定" btnImage:@"" titleColor:RGBTEXTINFO titleFont:14];
        _btnComfirn.userInteractionEnabled = NO;
        _btnComfirn.layer.cornerRadius = 24;
        _btnComfirn.backgroundColor = RGBCOLOR(230, 230, 230);
        
        [_btnComfirn addTarget:self action:@selector(btnComfirnAction) forControlEvents:UIControlEventTouchUpInside];
    }
    return _btnComfirn;
}

- (void)dealloc{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    NSLog(@"dealloc");
}

@end
