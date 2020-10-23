//
//  HDAddBankCardViewController.m
//  HairDress
//
//  Created by 张凯中 on 2019/12/30.
//  Copyright © 2019 zhangkaizhong. All rights reserved.
//

#import "HDAddBankCardViewController.h"

@interface HDAddBankCardViewController ()<navViewDelegate>

@property (nonatomic,strong)HDBaseNavView *navView;
@property (nonatomic,strong)UIScrollView *mainScrollView;

@property (nonatomic,weak) HDTextFeild *textName;
@property (nonatomic,weak) HDTextFeild *textCardNo;

@end

@implementation HDAddBankCardViewController

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
    
}

#pragma mark -- 加载控件

-(UIScrollView *)mainScrollView{
    if (!_mainScrollView) {
        _mainScrollView = [[UIScrollView alloc] initWithFrame:CGRectMake(0, NAVHIGHT, kSCREEN_WIDTH, kSCREEN_HEIGHT-NAVHIGHT)];
        _mainScrollView.backgroundColor = [UIColor clearColor];
        
        UILabel *lblTextBank = [[UILabel alloc] initCommonWithFrame:CGRectMake(16, 12, kSCREEN_WIDTH-32, 14) title:@"请绑定持卡人本人的银行卡" bgColor:[UIColor clearColor] titleColor:RGBLIGHT_TEXTINFO titleFont:14 textAlignment:NSTextAlignmentLeft isFit:NO];
        [_mainScrollView addSubview:lblTextBank];
        
        // 手机号
        UIView *viewName = [[UIView alloc] initWithFrame:CGRectMake(0, lblTextBank.bottom+16, kSCREEN_WIDTH, 55)];
        viewName.backgroundColor = [UIColor whiteColor];
        [_mainScrollView addSubview:viewName];
        
        UILabel *lblNameText = [[UILabel alloc] initCommonWithFrame:CGRectMake(16, 20, 100, 14) title:@"持卡人" bgColor:[UIColor clearColor] titleColor:RGBLIGHT_TEXTINFO titleFont:14 textAlignment:NSTextAlignmentLeft isFit:NO];
        [viewName addSubview:lblNameText];
        
        HDTextFeild *textName = [[HDTextFeild alloc] initWithFrame:CGRectMake(CGRectGetMaxX(lblNameText.frame), 20, kSCREEN_WIDTH-CGRectGetMaxX(lblNameText.frame)-16, 14)];
        textName.placeholder = @"请输入持卡人姓名";
        textName.font = [UIFont systemFontOfSize:14];
        textName.textAlignment = NSTextAlignmentRight;
        [viewName addSubview:textName];
        self.textName = textName;
        
        UIView *line1 = [[UIView alloc] initWithFrame:CGRectMake(16, 54, kSCREEN_WIDTH-32, 1)];
        line1.backgroundColor = RGBCOLOR(241, 241, 241);
        [viewName addSubview:line1];
        
        // 卡号
        UIView *viewCard = [[UIView alloc] initWithFrame:CGRectMake(0, viewName.bottom, kSCREEN_WIDTH, 55)];
        viewCard.backgroundColor = [UIColor whiteColor];
        [_mainScrollView addSubview:viewCard];
        
        UILabel *lblCardText = [[UILabel alloc] initCommonWithFrame:CGRectMake(16, 20, 100, 14) title:@"卡号" bgColor:[UIColor clearColor] titleColor:RGBLIGHT_TEXTINFO titleFont:14 textAlignment:NSTextAlignmentLeft isFit:NO];
        [viewCard addSubview:lblCardText];
        
        HDTextFeild *textCardNo = [[HDTextFeild alloc] initWithFrame:CGRectMake(CGRectGetMaxX(lblCardText.frame), 20, kSCREEN_WIDTH-CGRectGetMaxX(lblCardText.frame)-16, 14)];
        textCardNo.placeholder = @"请输入卡号";
        textCardNo.font = [UIFont systemFontOfSize:14];
        textCardNo.textAlignment = NSTextAlignmentRight;
        [viewCard addSubview:textCardNo];
        self.textCardNo = textCardNo;
        
        UIButton *btnNext = [[UIButton alloc] initCommonWithFrame:CGRectMake(16, viewCard.bottom+40, kSCREEN_WIDTH-32, 48) btnTitle:@"下一步" bgColor:[UIColor clearColor] titleColor:RGBTEXTINFO titleFont:14];
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
        _navView = [[HDBaseNavView alloc] initWithFrame:CGRectMake(0, 0, kSCREEN_WIDTH, NAVHIGHT) title:@"添加银行卡" bgColor:RGBMAIN backBtn:YES rightBtn:@"" rightBtnImage:@"" theDelegate:self];
    }
    return _navView;
}

@end
