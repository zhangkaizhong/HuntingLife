//
//  HDMyBankCardInfoEditViewController.m
//  HairDress
//
//  Created by 张凯中 on 2019/12/30.
//  Copyright © 2019 zhangkaizhong. All rights reserved.
//

#import "HDMyBankCardInfoEditViewController.h"

#import "HDAddBankCardViewController.h"

@interface HDMyBankCardInfoEditViewController ()<navViewDelegate>

@property (nonatomic,strong)HDBaseNavView *navView;
@property (nonatomic,strong)UIScrollView *mainScrollView;

@property (nonatomic,weak) UILabel *lblBankName;
@property (nonatomic,weak) UILabel *lblCardType;
@property (nonatomic,weak) HDTextFeild *textPhone;

@end

@implementation HDMyBankCardInfoEditViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.view.backgroundColor = RGBBG;
    [self.view addSubview:self.navView];
    [self.view addSubview:self.mainScrollView];
}

#pragma mark -- delegate / action

- (void)navBackClicked{
    [self.navigationController popViewControllerAnimated:YES];
}

// 下一步
-(void)btnNextAction{
    HDAddBankCardViewController *addVC = [HDAddBankCardViewController new];
    [self.navigationController pushViewController:addVC animated:YES];
}

#pragma mark ================== 加载视图 =====================

-(UIScrollView *)mainScrollView{
    if (!_mainScrollView) {
        _mainScrollView = [[UIScrollView alloc] initWithFrame:CGRectMake(0, NAVHIGHT, kSCREEN_WIDTH, kSCREEN_HEIGHT-NAVHIGHT)];
        _mainScrollView.backgroundColor = [UIColor clearColor];
        
        UILabel *lblTextBank = [[UILabel alloc] initCommonWithFrame:CGRectMake(16, 12, kSCREEN_WIDTH-32, 12) title:@"请选择银行卡类型" bgColor:[UIColor clearColor] titleColor:RGBLIGHT_TEXTINFO titleFont:12 textAlignment:NSTextAlignmentLeft isFit:NO];
        [_mainScrollView addSubview:lblTextBank];
        
        // 银行卡
        UIView *viewBank = [[UIView alloc] initWithFrame:CGRectMake(0, lblTextBank.bottom+12, kSCREEN_WIDTH, 55)];
        viewBank.backgroundColor = [UIColor whiteColor];
        [_mainScrollView addSubview:viewBank];
        UIView *line1 = [[UIView alloc] initWithFrame:CGRectMake(16, 54, kSCREEN_WIDTH-32, 1)];
        line1.backgroundColor = RGBCOLOR(241, 241, 241);
        [viewBank addSubview:line1];
        
        UILabel *lblBankText = [[UILabel alloc] initCommonWithFrame:CGRectMake(16, 20, 100, 14) title:@"银行" bgColor:[UIColor clearColor] titleColor:RGBLIGHT_TEXTINFO titleFont:14 textAlignment:NSTextAlignmentLeft isFit:NO];
        [viewBank addSubview:lblBankText];
        
        UILabel *lblBankName = [[UILabel alloc] initCommonWithFrame:CGRectMake(CGRectGetMaxX(lblBankText.frame)+5, 20, kSCREEN_WIDTH-CGRectGetMaxX(lblBankText.frame)-5-16, 14) title:@"工商银行" bgColor:[UIColor clearColor] titleColor:RGBTEXT titleFont:14 textAlignment:NSTextAlignmentRight isFit:NO];
        [viewBank addSubview:lblBankName];
        self.lblBankName = lblBankName;
        
        // 卡类型
        UIView *viewType = [[UIView alloc] initWithFrame:CGRectMake(0, viewBank.bottom, kSCREEN_WIDTH, 55)];
        viewType.backgroundColor = [UIColor whiteColor];
        [_mainScrollView addSubview:viewType];
        
        UILabel *lblTypeText = [[UILabel alloc] initCommonWithFrame:CGRectMake(16, 20, 100, 14) title:@"卡类型" bgColor:[UIColor clearColor] titleColor:RGBLIGHT_TEXTINFO titleFont:14 textAlignment:NSTextAlignmentLeft isFit:NO];
        [viewType addSubview:lblTypeText];
        
        UILabel *lblCardType = [[UILabel alloc] initCommonWithFrame:CGRectMake(CGRectGetMaxX(lblTypeText.frame)+5, 20, kSCREEN_WIDTH-CGRectGetMaxX(lblTypeText.frame)-5-16, 14) title:@"储蓄卡" bgColor:[UIColor clearColor] titleColor:RGBTEXT titleFont:14 textAlignment:NSTextAlignmentRight isFit:NO];
        [viewType addSubview:lblCardType];
        self.lblCardType = lblCardType;
        
        // 手机号
        UIView *viewPhone = [[UIView alloc] initWithFrame:CGRectMake(0, viewType.bottom+24, kSCREEN_WIDTH, 55)];
        viewPhone.backgroundColor = [UIColor whiteColor];
        [_mainScrollView addSubview:viewPhone];
        
        UILabel *lblPhoneText = [[UILabel alloc] initCommonWithFrame:CGRectMake(16, 20, 100, 14) title:@"手机号" bgColor:[UIColor clearColor] titleColor:RGBLIGHT_TEXTINFO titleFont:14 textAlignment:NSTextAlignmentLeft isFit:NO];
        [viewPhone addSubview:lblPhoneText];
        
        HDTextFeild *textPhone = [[HDTextFeild alloc] initWithFrame:CGRectMake(CGRectGetMaxX(lblPhoneText.frame), 20, kSCREEN_WIDTH-CGRectGetMaxX(lblPhoneText.frame)-16, 14)];
        textPhone.placeholder = @"请输入手机号";
        textPhone.font = [UIFont systemFontOfSize:14];
        textPhone.textAlignment = NSTextAlignmentRight;
        [viewPhone addSubview:textPhone];
        self.textPhone = textPhone;
        
        // 用户协议
        UIButton *btnSelect = [[UIButton alloc] initCustomWithFrame:CGRectMake(17, viewPhone.bottom+20, 30, 15) btnTitle:@"同意" btnImage:@"login_input_ic_selected" btnType:LeftCostom bgColor:[UIColor clearColor] titleColor:RGBTEXT titleFont:12];
        [_mainScrollView addSubview:btnSelect];
        
        UIButton *btnAgree = [[UIButton alloc] initSystemWithFrame:CGRectMake(CGRectGetMaxX(btnSelect.frame)+3, 0, 80, 15) btnTitle:@"《用户协议》" btnImage:@"" titleColor:RGBCOLOR(87, 107, 149) titleFont:12];
        btnAgree.centerY = btnSelect.centerY;
        [_mainScrollView addSubview:btnAgree];
        
        UIButton *btnNext = [[UIButton alloc] initCommonWithFrame:CGRectMake(16, btnAgree.bottom+40, kSCREEN_WIDTH-32, 48) btnTitle:@"下一步" bgColor:[UIColor clearColor] titleColor:RGBTEXTINFO titleFont:14];
        btnNext.layer.cornerRadius = 24;
        btnNext.backgroundColor = RGBCOLOR(230, 230, 230);
        [_mainScrollView addSubview:btnNext];
        
        [btnNext addTarget:self action:@selector(btnNextAction) forControlEvents:UIControlEventTouchUpInside];
        
        _mainScrollView.contentSize = CGSizeMake(kSCREEN_WIDTH, btnNext.bottom+32);
    }
    return _mainScrollView;
}

-(HDBaseNavView *)navView{
    if (!_navView) {
        _navView = [[HDBaseNavView alloc] initWithFrame:CGRectMake(0, 0, kSCREEN_WIDTH, NAVHIGHT) title:@"填写银行卡及身份信息" bgColor:RGBMAIN backBtn:YES rightBtn:@"" rightBtnImage:@"" theDelegate:self];
    }
    return _navView;
}


@end
