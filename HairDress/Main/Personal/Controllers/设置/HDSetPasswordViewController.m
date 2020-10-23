//
//  HDSetPasswordViewController.m
//  HairDress
//
//  Created by 张凯中 on 2020/3/2.
//  Copyright © 2020 zhangkaizhong. All rights reserved.
//

#import "HDSetPasswordViewController.h"

@interface HDSetPasswordViewController ()<navViewDelegate>

@property (nonatomic,strong) HDBaseNavView *navView;
@property (nonatomic,strong) UIScrollView *mainScrollView;

@property (nonatomic,strong) UIView *viewTextPwd;
@property (nonatomic,weak) HDTextFeild *txtpwd;
@property (nonatomic,weak) HDTextFeild *txtpwdCom;

@end

@implementation HDSetPasswordViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = RGBBG;
    [self.view addSubview:self.navView];
    [self.view addSubview:self.mainScrollView];
}

#pragma mark -- delegate action
-(void)navBackClicked{
    [self.navigationController popViewControllerAnimated:YES];
}

//输入监听
-(void)textFeildChangedAction:(UITextField *)sender{
    if (sender.text.length > 6) {
        sender.text = [sender.text substringToIndex:6];
    }
}

//设置密码请求
-(void)setPwdRequest{
    if (self.txtpwd.text.length != 6 || self.txtpwdCom.text.length != 6) {
        [SVHUDHelper showDarkWarningMsg:@"支付密码应为6位数字"];
        return;
    }
    if (![self.txtpwd.text isEqualToString:self.txtpwdCom.text]) {
        [SVHUDHelper showDarkWarningMsg:@"两次输入的密码不一样"];
        return;
    }
    
    NSDictionary *parmas = @{
        @"confirmPassword":self.txtpwdCom.text,
        @"id":[HDUserDefaultMethods getData:@"userId"],
        @"newPassword":self.txtpwd.text
    };
    WeakSelf;
    [MHNetworkManager postReqeustWithURL:URL_MemberSetPayPassword params:parmas successBlock:^(NSDictionary *returnData) {
        if ([returnData[@"respCode"] integerValue] == 200) {
            [SVHUDHelper showSuccessDoneMsg:@"设置成功"];
            NSDictionary *userInfo = [HDToolHelper nullDicToDic:returnData[@"data"]];
            [HDUserDefaultMethods saveData:userInfo[@"payPassword"] andKey:@"payPassword"];
            [HDUserDefaultMethods saveData:self.txtpwd.text andKey:@"payPasswordText"];
            [HDToolHelper delayMethodFourGCD:1.5 method:^{
                [weakSelf.navigationController popViewControllerAnimated:YES];
            }];
        }
    } failureBlock:^(NSError *error) {
        
    } showHUD:YES];
}

#pragma mark -- UI
-(HDBaseNavView *)navView{
    if (!_navView) {
        _navView = [[HDBaseNavView alloc] initWithFrame:CGRectMake(0, 0, kSCREEN_WIDTH, NAVHIGHT) title:@"设置支付密码" bgColor:RGBMAIN backBtn:YES rightBtn:@"" rightBtnImage:@"" theDelegate:self];
    }
    return _navView;
}

-(UIScrollView *)mainScrollView{
    if (!_mainScrollView) {
        _mainScrollView = [[UIScrollView alloc] initWithFrame:CGRectMake(0, NAVHIGHT, kSCREEN_WIDTH, kSCREEN_HEIGHT-NAVHIGHT)];
        [_mainScrollView addSubview:self.viewTextPwd];
        
        UIView *viewPwd = [self createTextView:CGRectMake(0, _viewTextPwd.bottom, kSCREEN_WIDTH, 55) title:@"支付密码" placeText:@"请输入六位数字密码"];
        self.txtpwd = (UITextField *)[viewPwd viewWithTag:1000];
        [_mainScrollView addSubview:viewPwd];
        
        UIView *viewPwdCom = [self createTextView:CGRectMake(0, viewPwd.bottom, kSCREEN_WIDTH, 55) title:@"确认密码" placeText:@"请输入六位数字密码"];
        self.txtpwdCom = (HDTextFeild *)[viewPwdCom viewWithTag:1000];
        [_mainScrollView addSubview:viewPwdCom];
        
        UIButton *btnDone = [[UIButton alloc] initCommonWithFrame:CGRectMake(16, _mainScrollView.height-48-32, kSCREEN_WIDTH-32, 48) btnTitle:@"确定" bgColor:RGBMAIN titleColor:[UIColor whiteColor] titleFont:14];
        btnDone.layer.cornerRadius = 24;
        
        [btnDone addTarget:self action:@selector(setPwdRequest) forControlEvents:UIControlEventTouchUpInside];
        [_mainScrollView addSubview:btnDone];
        
        _mainScrollView.contentSize = CGSizeMake(kSCREEN_WIDTH, btnDone.bottom);
    }
    return _mainScrollView;
}

//工号
-(UIView *)viewTextPwd{
    if (!_viewTextPwd) {
        _viewTextPwd = [[UIView alloc] initWithFrame:CGRectMake(0, 0, kSCREEN_WIDTH, 48)];
        _viewTextPwd.backgroundColor = RGBBG;
        
        UILabel *lblNo = [[UILabel alloc] initCommonWithFrame:CGRectMake(16, 0, kSCREEN_WIDTH-32, _viewTextPwd.height) title:@"请设置支付密码" bgColor:[UIColor clearColor] titleColor:RGBLIGHT_TEXTINFO titleFont:14 textAlignment:NSTextAlignmentLeft isFit:NO];
        [_viewTextPwd addSubview:lblNo];
        
    }
    return _viewTextPwd;
}


-(UIView *)createTextView:(CGRect)frame title:(NSString *)title placeText:(NSString *)place{
    UIView *view = [[UIView alloc] initWithFrame:frame];
    
    view.backgroundColor = [UIColor whiteColor];
    UIView *line = [[UIView alloc] initWithFrame:CGRectMake(16, view.height-1, kSCREEN_WIDTH-32, 1)];
    line.backgroundColor = RGBCOLOR(241, 241, 241);
    [view addSubview:line];
    
    UILabel *lblTitle = [[UILabel alloc] initCommonWithFrame:CGRectMake(16, 0, 100, 20) title:title bgColor:[UIColor clearColor] titleColor:RGBLIGHT_TEXTINFO titleFont:14 textAlignment:NSTextAlignmentLeft isFit:YES];
    lblTitle.centerY = view.height/2;
    [view addSubview:lblTitle];
    
    HDTextFeild *txtPwd = [[HDTextFeild alloc] initWithFrame:CGRectMake(CGRectGetMaxX(lblTitle.frame)+10, 0, kSCREEN_WIDTH-CGRectGetMaxX(lblTitle.frame)-10-16, 20)];
    txtPwd.placeholder = @"输入6位支付密码";
    txtPwd.tintColor = RGBMAIN;
    txtPwd.keyboardType = UIKeyboardTypeNumberPad;
    txtPwd.centerY = view.height/2;
    txtPwd.font = [UIFont systemFontOfSize:14];
    txtPwd.secureTextEntry = YES;
    txtPwd.tag = 1000;
    [view addSubview:txtPwd];
    [txtPwd addTarget:self action:@selector(textFeildChangedAction:)forControlEvents:UIControlEventEditingChanged];
    
    return view;
}

@end
