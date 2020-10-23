//
//  HDResetPasswordsViewController.m
//  HairDress
//
//  Created by 张凯中 on 2020/2/14.
//  Copyright © 2020 zhangkaizhong. All rights reserved.
//

#import "HDResetPasswordsViewController.h"

@interface HDResetPasswordsViewController ()<navViewDelegate>

@property (nonatomic,strong) HDBaseNavView *navView;
@property (nonatomic,strong)ZXLGCDTimer *timer;
@property (nonatomic,strong) UIScrollView *mainScrollView;

@property (nonatomic,weak) UILabel *lblSendText;
@property (nonatomic,weak) HDTextFeild *txtVerCode;
@property (nonatomic,weak) HDTextFeild *txtPwd;

@property (nonatomic,copy) NSString *phoneNum;

@property (nonatomic,strong) UIButton * btnGetCode;  // 获取验证码按钮

@end

//倒计时总秒数
static NSInteger secondsCountDown = 0;

@implementation HDResetPasswordsViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.view.backgroundColor = RGBBG;
    [self.view addSubview:self.navView];
    [self.view addSubview:self.mainScrollView];
    
    self.phoneNum = [HDUserDefaultMethods getData:@"phone"];
}

#pragma mark -- delegate action
-(void)navBackClicked{
    [self.navigationController popViewControllerAnimated:YES];
}

//获取验证码
-(void)btnGetCodeAction:(UIButton *)sender{
    [self getPhoneCode:self.phoneNum];
}

//输入监听
-(void)textFeildChangedAction:(UITextField *)sender{
    if (self.txtVerCode.text.length > 4) {
        self.txtVerCode.text = [self.txtVerCode.text substringToIndex:4];
    }
    if ([self.pwdType isEqualToString:@"1"]) {
        if (self.txtPwd.text.length > 32) {
            self.txtPwd.text = [self.txtPwd.text substringToIndex:32];
        }
    }
    else{
        if (self.txtPwd.text.length > 6) {
            self.txtPwd.text = [self.txtPwd.text substringToIndex:6];
        }
    }
}

#pragma mark -- 数据请求
//发送短信验证码
-(void)getPhoneCode:(NSString *)phone{
    [MHNetworkManager postReqeustWithURL:URL_SendPhoneCode params:@{@"phone":phone} successBlock:^(NSDictionary *returnData) {
        [SVHUDHelper showInfoWithTimestamp:1 msg:returnData[@"respMsg"]];
        if ([returnData[@"respCode"] integerValue] == 200) {
            //设置定时器
            secondsCountDown = 60;
            [self.btnGetCode setTitle:[NSString stringWithFormat:@"%ld秒后重发",(long)secondsCountDown] forState:UIControlStateNormal];
            [self.btnGetCode setTitleColor:RGBTEXTINFO forState:UIControlStateNormal];
            self.btnGetCode.userInteractionEnabled = NO;
            if (!self.timer) {
                self.timer = [[ZXLGCDTimer alloc] initWithTimeInterval:1 target:self selector:@selector(countDownAction) parameter:0];
            }
        }
    } failureBlock:^(NSError *error) {
        [SVHUDHelper showInfoWithTimestamp:1 msg:error.localizedDescription];
    } showHUD:YES];
}

//实现倒计时动作
-(void)countDownAction{
    //倒计时-1
    secondsCountDown--;
    
    if (secondsCountDown <=0) {
        [self.btnGetCode setTitle:@"获取验证码" forState:UIControlStateNormal];
        [self.btnGetCode setTitleColor:RGBMAIN forState:UIControlStateNormal];
        self.btnGetCode.userInteractionEnabled = YES;
        return;
    }
    [self.btnGetCode setTitle:[NSString stringWithFormat:@"%ld秒后重发",(long)secondsCountDown] forState:UIControlStateNormal];
    [self.btnGetCode setTitleColor:RGBTEXTINFO forState:UIControlStateNormal];
    self.btnGetCode.userInteractionEnabled = NO;
}

//修改密码请求
-(void)resetPwdRequest{
    if ([self.pwdType isEqualToString:@"1"]) {
        //修改账号密码
        [self resetUserPwdRequest];
    }else{
        //修改支付密码
        [self resetPayPwdRequest];
    }
}

//修改账号密码
-(void)resetUserPwdRequest{
    if ([self.txtVerCode.text isEqualToString:@""]) {
        [SVHUDHelper showDarkWarningMsg:@"短信验证码不能为空"];
        return;
    }
    if ([self.pwdType isEqualToString:@"1"]) {
        if (self.txtPwd.text.length <6) {
            [SVHUDHelper showDarkWarningMsg:@"请输入6-32位新密码"];
            return;
        }
        if (![HDToolHelper checkPassword:self.txtPwd.text]) {
            [SVHUDHelper showDarkWarningMsg:@"密码应为数字、或数字和字母组合"];
            return;
        }
    }else{
        if (self.txtPwd.text.length <6) {
            [SVHUDHelper showDarkWarningMsg:@"请输入6位数字支付密码"];
            return;
        }
    }
    WeakSelf;
    NSMutableDictionary *params = [NSMutableDictionary new];
    [params setValue:self.phoneNum forKey:@"phone"];
    [params setValue:self.txtVerCode.text forKey:@"phoneCode"];
    [params setValue:self.txtPwd.text forKey:@"password"];
    [MHNetworkManager postReqeustWithURL:URL_ResetPhonePwd params:params successBlock:^(NSDictionary *returnData) {
        if ([returnData[@"respCode"] integerValue] == 200) {
            NSDictionary *userInfo = [HDToolHelper nullDicToDic:returnData[@"data"]];
            [HDUserDefaultMethods saveData:userInfo[@"password"] andKey:@"password"];
            [HDUserDefaultMethods saveData:self.txtPwd.text andKey:@"passwordText"];
            [HDToolHelper delayMethodFourGCD:1.5 method:^{
                [weakSelf.navigationController popViewControllerAnimated:YES];
            }];
        }
        [SVHUDHelper showInfoWithTimestamp:1 msg:returnData[@"respMsg"]];
    } failureBlock:^(NSError *error) {
        [SVHUDHelper showInfoWithTimestamp:1 msg:error.localizedDescription];
    } showHUD:YES];
}

//修改支付密码
-(void)resetPayPwdRequest{
    if (self.txtPwd.text.length !=6 || ![HDToolHelper isInputShouldBeNumber:self.txtPwd.text]) {
        [SVHUDHelper showDarkWarningMsg:@"支付密码应为6位纯数字"];
        return;
    }
    if ([self.txtVerCode.text isEqualToString:@""]) {
        [SVHUDHelper showDarkWarningMsg:@"短信验证码不能为空"];
        return;
    }
    NSMutableDictionary *params = [NSMutableDictionary new];
    [params setValue:self.phoneNum forKey:@"phone"];
    [params setValue:self.txtVerCode.text forKey:@"phoneCode"];
    [params setValue:self.txtPwd.text forKey:@"password"];
    [params setValue:[[[UIDevice currentDevice] identifierForVendor] UUIDString] forKey:@"equipmentNo"];
    [params setValue:[HDUserDefaultMethods getData:@"userId"] forKey:@"id"];
    WeakSelf;
    [MHNetworkManager postReqeustWithURL:URL_MemberPayPasswordPhone params:params successBlock:^(NSDictionary *returnData) {
        [SVHUDHelper showInfoWithTimestamp:1 msg:returnData[@"respMsg"]];
        if ([returnData[@"respCode"] integerValue] == 200) {
            NSDictionary *userInfo = [HDToolHelper nullDicToDic:returnData[@"data"]];
            [HDUserDefaultMethods saveData:userInfo[@"payPassword"] andKey:@"payPassword"];
            [HDUserDefaultMethods saveData:self.txtPwd.text andKey:@"payPasswordText"];
            [HDToolHelper delayMethodFourGCD:1.5 method:^{
                [weakSelf.navigationController popViewControllerAnimated:YES];
            }];
        }
    } failureBlock:^(NSError *error) {
        [SVHUDHelper showInfoWithTimestamp:1 msg:error.localizedDescription];
    } showHUD:YES];
}

#pragma mark -- UI
-(HDBaseNavView *)navView{
    if (!_navView) {
        NSString *strTitle = @"修改登录密码";
        if ([self.pwdType isEqualToString:@"2"]) {
            strTitle = @"修改支付密码";
        }
        _navView = [[HDBaseNavView alloc] initWithFrame:CGRectMake(0, 0, kSCREEN_WIDTH, NAVHIGHT) title:strTitle bgColor:RGBMAIN backBtn:YES rightBtn:@"" rightBtnImage:@"" theDelegate:self];
    }
    return _navView;
}

-(UIScrollView *)mainScrollView{
    if (!_mainScrollView) {
        _mainScrollView = [[UIScrollView alloc] initWithFrame:CGRectMake(0, NAVHIGHT, kSCREEN_WIDTH, kSCREEN_HEIGHT-NAVHIGHT)];
        _mainScrollView.backgroundColor = [UIColor clearColor];
        
        UIView *viewPhone = [[UIView alloc] initWithFrame:CGRectMake(0, 0, kSCREEN_WIDTH, 76)];
        viewPhone.backgroundColor = RGBBG;
        [_mainScrollView addSubview:viewPhone];
        
        UILabel *lblSendText = [[UILabel alloc] initCommonWithFrame:CGRectMake(16, 12, kSCREEN_WIDTH-32, 12) title:@"发送验证码到你的手机号" bgColor:[UIColor clearColor] titleColor:RGBLIGHT_TEXTINFO titleFont:12 textAlignment:NSTextAlignmentLeft isFit:NO];
        [viewPhone addSubview:lblSendText];
        self.lblSendText = lblSendText;
        
        NSString *phoneNum = [[HDUserDefaultMethods getData:@"phone"] stringByReplacingCharactersInRange:NSMakeRange(3, 4) withString:@"****"];
        UILabel *lblPhone = [[UILabel alloc] initCommonWithFrame:CGRectMake(16, lblSendText.bottom+12, kSCREEN_WIDTH-32, 16) title:phoneNum bgColor:[UIColor clearColor] titleColor:RGBTEXT titleFont:16 textAlignment:NSTextAlignmentLeft isFit:NO];
        [viewPhone addSubview:lblPhone];
        
        //验证码
        UIView *viewVerCode = [[UIView alloc] initWithFrame:CGRectMake(0, viewPhone.bottom, kSCREEN_WIDTH, 55)];
        viewVerCode.backgroundColor = [UIColor whiteColor];
        [_mainScrollView addSubview:viewVerCode];
        
        HDTextFeild *txtVerCode = [[HDTextFeild alloc] initWithFrame:CGRectMake(16, 0, 150, 14)];
        txtVerCode.placeholder = @"输入验证码";
        txtVerCode.centerY = 55/2;
        self.txtVerCode = txtVerCode;
        txtVerCode.keyboardType = UIKeyboardTypeNumberPad;
        txtVerCode.font = [UIFont systemFontOfSize:14];
        [viewVerCode addSubview:txtVerCode];
        [txtVerCode addTarget:self action:@selector(textFeildChangedAction:)forControlEvents:UIControlEventEditingChanged];
        
        UIButton *btnGetCode = [[UIButton alloc] initCommonWithFrame:CGRectMake(0, 0, 80, 25) btnTitle:@"获取验证码" bgColor:[UIColor clearColor] titleColor:RGBMAIN titleFont:12];
        btnGetCode.centerY = 55/2;
        btnGetCode.x = kSCREEN_WIDTH - 16 - btnGetCode.width;
        [viewVerCode addSubview:btnGetCode];
        self.btnGetCode = btnGetCode;
        [btnGetCode addTarget:self action:@selector(btnGetCodeAction:) forControlEvents:UIControlEventTouchUpInside];
        
        UIView *line = [[UIView alloc] initWithFrame:CGRectMake(16, 54, kSCREEN_WIDTH-32, 1)];
        line.backgroundColor = RGBCOLOR(241, 241, 241);
        [viewVerCode addSubview:line];
        
        //密码
        UIView *viewPwd = [[UIView alloc] initWithFrame:CGRectMake(0, viewVerCode.bottom, kSCREEN_WIDTH, 55)];
        viewPwd.backgroundColor = [UIColor whiteColor];
        [_mainScrollView addSubview:viewPwd];
        
        HDTextFeild *txtPwd = [[HDTextFeild alloc] initWithFrame:CGRectMake(16, 0, kSCREEN_WIDTH-32, 14)];
        if ([self.pwdType isEqualToString:@"1"]) {
            txtPwd.placeholder = @"输入6-32位新密码";
        }
        else{
            txtPwd.placeholder = @"输入6位支付密码";
            txtPwd.keyboardType = UIKeyboardTypeNumberPad;
        }
        txtPwd.centerY = 55/2;
        self.txtPwd = txtPwd;
        txtPwd.font = [UIFont systemFontOfSize:14];
        txtPwd.secureTextEntry = YES;
        [viewPwd addSubview:txtPwd];
        [txtPwd addTarget:self action:@selector(textFeildChangedAction:)forControlEvents:UIControlEventEditingChanged];
        
        UIButton *btnDone = [[UIButton alloc] initCommonWithFrame:CGRectMake(16, _mainScrollView.height-48-32, kSCREEN_WIDTH-32, 48) btnTitle:@"确定" bgColor:RGBMAIN titleColor:[UIColor whiteColor] titleFont:14];
        btnDone.layer.cornerRadius = 24;
        
        [btnDone addTarget:self action:@selector(resetPwdRequest) forControlEvents:UIControlEventTouchUpInside];
        [_mainScrollView addSubview:btnDone];
        
        _mainScrollView.contentSize = CGSizeMake(kSCREEN_WIDTH, btnDone.bottom);
    }
    return _mainScrollView;
}

@end
