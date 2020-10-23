//
//  HDRegisterViewController.m
//  HairDress
//
//  Created by Apple on 2019/12/18.
//  Copyright © 2019 zhangkaizhong. All rights reserved.
//

#import "HDForgetPwdViewController.h"

#import "HDRegisterTextFeild.h"

@interface HDForgetPwdViewController ()<navViewDelegate,UITextFieldDelegate>

@property (nonatomic,strong)HDBaseNavView *navView;//导航栏
@property (nonatomic,strong)ZXLGCDTimer *timer;
@property (nonatomic,strong) UIScrollView * mainScoll;  // 主视图
@property (nonatomic,strong) UIView * controlView;  // 控件视图
@property (nonatomic,strong) UIButton * btnComfirn;  // 确认按钮
@property (nonatomic,strong) UIButton * btnGetVercode;  // 确认按钮
@property (nonatomic,strong) UIButton *btnGetCode;  // 获取验证码按钮

@end

//倒计时总秒数
static NSInteger secondsCountDown = 0;

@implementation HDForgetPwdViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    // UI
    [self createUI];
}

/*
 创建UI
 */
-(void)createUI{
    self.view.backgroundColor = RGBAlpha(249, 249, 249, 1);
    [self.view addSubview:self.mainScoll];
    [self.view addSubview:self.navView];
    [self.mainScoll addSubview:self.controlView];
    self.mainScoll.contentSize = CGSizeMake(kSCREEN_WIDTH, CGRectGetMaxY(_controlView.frame)+30);
}

#pragma mark ================== delegate/action =====================

// 导航栏
-(void)navBackClicked{
    [self.navigationController popViewControllerAnimated:YES];
}

// 获取验证码
-(void)txtBtnAction:(UIButton *)sender{
    HDTextFeild *txtPhone = [self.view viewWithTag:20000];
    if ([sender.titleLabel.text isEqualToString:@"获取验证码"]) {
        self.btnGetCode = sender;
        if (![txtPhone.text isPhoneNo]) {
            return;
        }
        [self getPhoneCode:txtPhone.text];
    }
}

// 注册
-(void)registerBtnAction:(UIButton *)sender{
    HDTextFeild *txtPhone = [self.view viewWithTag:20000];
    HDTextFeild *txtVercode = [self.view viewWithTag:20001];
    HDTextFeild *txtPwd = [self.view viewWithTag:20002];
    
    if (![txtPhone.text isPhoneNo]) {
        [SVHUDHelper showInfoWithTimestamp:1 msg:@"手机号输入有误"];
        return;
    }
    if (![txtVercode.text isNumber]) {
        [SVHUDHelper showInfoWithTimestamp:1 msg:@"验证码输入错误"];
        return;
    }
    if (txtPwd.text.length < 6) {
        [SVHUDHelper showInfoWithTimestamp:1 msg:@"密码长度应大于等于6位"];
        return;
    }
    
    //重置密码请求
    [self resetPwdRequest:txtPhone.text code:txtVercode.text pwd:txtPwd.text];
}

// 输入监听
-(void)textFieldDidChange:(UITextField *)textField{
    HDTextFeild *txtPhone = [self.view viewWithTag:20000];
    HDTextFeild *txtVercode = [self.view viewWithTag:20001];
    HDTextFeild *txtPwd = [self.view viewWithTag:20002];
    if (txtPhone.text.length > 11) {
        txtPhone.text = [txtPhone.text substringToIndex:11];
    }
    if (txtVercode.text.length > 4) {
        txtVercode.text = [txtVercode.text substringToIndex:4];
    }
    // 确认按钮可点击状态监听
    if (txtPhone.text.length == 11 && txtVercode.text.length > 0 && txtPwd.text.length>0) {
        _btnComfirn.userInteractionEnabled = YES;
        _btnComfirn.backgroundColor = RGBMAIN;
        [_btnComfirn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    }else{
        _btnComfirn.userInteractionEnabled = NO;
        [_btnComfirn setTitleColor:RGBAlpha(153, 153, 153, 1) forState:UIControlStateNormal];
        _btnComfirn.backgroundColor = RGBAlpha(230, 230, 230, 1);
    }
}

// 手机号监听
-(void)phoneTextFieldDidChange:(UITextField *)textField{
    HDTextFeild *txtPhone = [self.view viewWithTag:20000];
    if (txtPhone.text.length > 11) {
        txtPhone.text = [txtPhone.text substringToIndex:11];
    }
    //获取验证码
    if (txtPhone.text.length == 11) {
        self.btnGetVercode.userInteractionEnabled = YES;
        [self.btnGetVercode setTitleColor:RGBMAIN forState:UIControlStateNormal];
    }else{
        self.btnGetVercode.userInteractionEnabled = NO;
        [self.btnGetVercode setTitleColor:RGBTEXTINFO forState:UIControlStateNormal];
    }
}

#pragma mark ================== 网络请求 =====================
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

//重新设置密码
-(void)resetPwdRequest:(NSString *)phone code:(NSString *)verCode pwd:(NSString *)pwd{
    [MHNetworkManager postReqeustWithURL:URL_ResetPhonePwd params:@{@"phone":phone,@"phoneCode":verCode,@"password":pwd} successBlock:^(NSDictionary *returnData) {
        [SVHUDHelper showInfoWithTimestamp:1 msg:returnData[@"respMsg"]];
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

#pragma mark ================== 加载视图 =====================

-(HDBaseNavView *)navView{
    if (!_navView) {
        _navView=[[HDBaseNavView alloc] initWithFrame:CGRectMake(0, 0, kSCREEN_WIDTH, NAVHIGHT) title:@"忘记密码" bgColor:[UIColor clearColor] backBtn:YES rightBtn:@"" rightBtnImage:@"" theDelegate:self];
    }
    return _navView;
}

-(UIScrollView *)mainScoll{
    if (!_mainScoll) {
        _mainScoll = [[UIScrollView alloc] initWithFrame:CGRectMake(0, 0, kSCREEN_WIDTH, kSCREEN_HEIGHT)];
        _mainScoll.contentSize = CGSizeMake(kSCREEN_WIDTH, kSCREEN_HEIGHT);
        _mainScoll.backgroundColor = [UIColor clearColor];
        _mainScoll.scrollEnabled = NO;
    }
    return _mainScoll;
}

-(UIView *)controlView{
    if (!_controlView) {
        _controlView = [[UIView alloc] initWithFrame:CGRectMake(16, NAVHIGHT+24, kSCREEN_WIDTH-32, 336)];
        _controlView.backgroundColor = [UIColor whiteColor];
        _controlView.layer.cornerRadius = 8;
        _controlView.layer.shadowColor = [UIColor colorWithRed:0/255.0 green:0/255.0 blue:0/255.0 alpha:0.08].CGColor;
        _controlView.layer.shadowOpacity = 1;
        _controlView.layer.shadowRadius = 4;

        // 添加子控件
        NSArray *txtDicArr = @[@{@"placeHolder":@"请输入您的手机号",@"image":@"login_input_ic_phone",@"btn":@""},
                               @{@"placeHolder":@"请输入验证码",@"image":@"login_input_ic_verificationcode",@"btn":@"获取验证码"},
                               @{@"placeHolder":@"请输入6-32位密码",@"image":@"login_input_ic_keyword",@"btn":@"login_input_ic_hidepassword"}];
        
        for (int i = 0; i<txtDicArr.count; i++) {
            HDRegisterTextFeild *txt = [[HDRegisterTextFeild alloc] initWithFrame:CGRectMake(24, i*(36+24)+40, _controlView.width-24-24, 36) placeHolder:txtDicArr[i][@"placeHolder"] titleImage:txtDicArr[i][@"image"] btnImage:txtDicArr[i][@"btn"]];
            txt.tag = 1000+i;
            txt.btn.tag = 10000+i;
            txt.txtFeild.tag = 20000+i;
            txt.txtFeild.delegate = self;
            if ([txtDicArr[i][@"btn"] isEqualToString:@"获取验证码"]) {
                txt.btn.userInteractionEnabled = NO;
                self.btnGetVercode = txt.btn;
            }
            [txt.btn addTarget:self action:@selector(txtBtnAction:) forControlEvents:UIControlEventTouchUpInside];
            // 手机号监听
            if (i==0) {
                [txt.txtFeild addTarget:self action:@selector(phoneTextFieldDidChange:)forControlEvents:UIControlEventEditingChanged];
            }else{
                [txt.txtFeild addTarget:self action:@selector(textFieldDidChange:)forControlEvents:UIControlEventEditingChanged];
            }
            if (i == 2) {
                txt.txtFeild.secureTextEntry = YES;
            }
            [_controlView addSubview:txt];
        }
        
        [_controlView addSubview:self.btnComfirn];
    }
    return _controlView;
}

-(UIButton *)btnComfirn{
    if (!_btnComfirn) {
        UIView *txtLast = [_controlView viewWithTag:1002];
        _btnComfirn = [[UIButton alloc] initCommonWithFrame:CGRectMake(24, CGRectGetMaxY(txtLast.frame)+64, _controlView.width-24-24, 36) btnTitle:@"确认" bgColor:RGBAlpha(230, 230, 230, 1) titleColor:RGBAlpha(153, 153, 153, 1) titleFont:14];
        _btnComfirn.layer.cornerRadius = _btnComfirn.height/2;
        [_btnComfirn addTarget:self action:@selector(registerBtnAction:) forControlEvents:UIControlEventTouchUpInside];
        _btnComfirn.userInteractionEnabled = NO;
    }
    return _btnComfirn;
}


@end
