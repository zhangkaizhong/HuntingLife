//
//  HDLoginViewController.m
//  HairDress
//
//  Created by Apple on 2019/12/18.
//  Copyright © 2019 zhangkaizhong. All rights reserved.
//

#import "HDLoginViewController.h"

#import "HDForgetPwdViewController.h"
#import "HDRegisterViewController.h"
#import "HDBindWXViewController.h"
#import "HDRegisterTextFeild.h"
#import "HDHtmlViewController.h"

@interface HDLoginViewController ()<UITextFieldDelegate,navViewDelegate>

@property (nonatomic,strong)HDBaseNavView *navView;//导航栏
@property (nonatomic,strong)ZXLGCDTimer *timer;

@property (nonatomic,strong) UIImageView * backImage;  // 背景图
@property (nonatomic,strong) UIImageView * imageApp;  // app图标
@property (nonatomic,strong) UIScrollView * mainScroll;  // 主视图
@property (nonatomic,strong) UIView * controlView;  // 控件视图
@property (nonatomic,strong) UIButton * btnLogin;  // 登录按钮
@property (nonatomic,strong) UIButton * btnAgree;  // 协议按钮
@property (nonatomic,strong) UILabel * lblAgreeMent;  // 协议按钮
@property (nonatomic,strong) UILabel * lblAgree;
@property (nonatomic,strong) UIView * agreeMentView;  // 协议视图
@property (nonatomic,strong) UIButton * btnForget;  // 忘记密码按钮
@property (nonatomic,strong) UIButton * btnVerLogin;  // 验证码登录按钮

@property (nonatomic,assign) NSString *loginType; // 登录类型：1->密码，2->验证码
@property (nonatomic,copy) NSString *select_agree;//勾选协议

@property (nonatomic,copy) NSString *strPhone;

@property (nonatomic,strong) UIButton * btnGetCode;  // 获取验证码按钮

@end

//倒计时总秒数
static NSInteger secondsCountDown = 0;

@implementation HDLoginViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    // UI
    [self createUI];
    
    self.loginType = @"1";
    self.select_agree = @"1";
}

/*
 创建UI
 */
-(void)createUI{
    self.view.backgroundColor = RGBAlpha(249, 249, 249, 1);
    [self.view addSubview:self.backImage];
    [self.view addSubview:self.mainScroll];
    [_mainScroll addSubview:self.controlView];
    [_mainScroll addSubview:self.imageApp];
    [self.view addSubview:self.navView];
}

#pragma mark ================== delegate/action =====================

// 导航栏
-(void)navBackClicked{
    [self.navigationController popViewControllerAnimated:YES];
}


// 同意协议
-(void)tapAgreeAction:(UIButton *)sender{
    sender.selected = !sender.selected;
    if (sender.selected) {
        //选中
        self.select_agree = @"1";
    }else{
        //未选中
        self.select_agree = @"0";
    }
}

// 协议详情
-(void)tapAgreementDetailAction{
    NSString *path = [[NSBundle mainBundle] pathForResource:@"web.html" ofType:nil];
    NSString *htmlString = [[NSString alloc]initWithContentsOfFile:path encoding:NSUTF8StringEncoding error:nil];
    HDHtmlViewController *vc = [HDHtmlViewController new];
    vc.textHtml = htmlString;
    [self.navigationController pushViewController:vc animated:YES];
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

// 短信验证码登录按钮点击事件
-(void)clickVerLoginAction:(UIButton *)sender{
    
    self.loginType = @"2";
    [_controlView removeFromSuperview];
    _controlView = nil;
    
    [_mainScroll addSubview:self.controlView];
    [_mainScroll bringSubviewToFront:self.imageApp];
    
    sender.hidden = YES;
    
    [_btnForget setTitle:@"密码登录" forState:UIControlStateNormal];
}

// 忘记密码/密码登录 按钮点击事件
-(void)clickForgetPwdAction:(UIButton *)sender{
    
    if ([self.loginType isEqualToString:@"1"]) {
        
        [self.navigationController pushViewController:[HDForgetPwdViewController new] animated:YES];
    }else{
        
        self.loginType = @"1";
        [_controlView removeFromSuperview];
        _controlView = nil;
        
        [_mainScroll addSubview:self.controlView];
        [_mainScroll bringSubviewToFront:self.imageApp];
        _btnVerLogin.hidden = NO;
        [_btnForget setTitle:@"忘记密码" forState:UIControlStateNormal];
    }
}

// 登录按钮点击事件
-(void)loginBtnAction:(UIButton *)sender{
    
    HDTextFeild *txtPhone = [self.view viewWithTag:20000];
    HDTextFeild *txtCode = [self.view viewWithTag:20001];
    if ([self.select_agree isEqualToString:@"1"]) {
        // 登录请求
        if ([self.loginType isEqualToString:@"1"]) {
            // 密码
            [self requestLogin:txtPhone.text pwd:txtCode.text code:@""];
        }
        else{
            // 验证码
            [self requestLogin:txtPhone.text pwd:@"" code:txtCode.text];
        }
    }
    else{
        [SVHUDHelper showInfoWithTimestamp:1 msg:@"请勾选协议"];
    }
}

// 输入监听
-(void)textFieldDidChange:(UITextField *)textField{
    HDTextFeild *txtPhone = [self.view viewWithTag:20000];
    HDTextFeild *txtPwd = [self.view viewWithTag:20001];
    self.strPhone = txtPhone.text;
    if (txtPhone.text.length > 11) {
        txtPhone.text = [txtPhone.text substringToIndex:11];
    }
    if ([self.loginType isEqualToString:@"2"]) {
        if (txtPwd.text.length > 4) {
            txtPwd.text = [txtPwd.text substringToIndex:4];
        }
    }
    if ([txtPhone.text isPhoneNo] && txtPwd.text.length>=4) {
        _btnLogin.userInteractionEnabled = YES;
        _btnLogin.backgroundColor = RGBMAIN;
        [_btnLogin setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    }else{
        _btnLogin.userInteractionEnabled = NO;
        [_btnLogin setTitleColor:RGBAlpha(153, 153, 153, 1) forState:UIControlStateNormal];
        _btnLogin.backgroundColor = RGBAlpha(230, 230, 230, 1);
    }
}


// 手机号监听
-(void)phoneTextFieldDidChange:(UITextField *)textField{
    HDTextFeild *txtPhone = [self.view viewWithTag:20000];
    self.strPhone = txtPhone.text;
    if (txtPhone.text.length > 11) {
        txtPhone.text = [txtPhone.text substringToIndex:11];
    }
    //获取验证码
    UIButton *btnGet = (UIButton *)[self.view viewWithTag:10001];
    if ([txtPhone.text isPhoneNo]) {
        btnGet.userInteractionEnabled = YES;
        [btnGet setTitleColor:RGBMAIN forState:UIControlStateNormal];
    }else{
        btnGet.userInteractionEnabled = NO;
        [btnGet setTitleColor:RGBTEXTINFO forState:UIControlStateNormal];
    }
}

#pragma mark ================== 登录相关请求 =====================
// 手机密码登录
-(void)requestLogin:(NSString *)phone pwd:(NSString *)pwd code:(NSString *)code{
    NSMutableDictionary *dic = [[NSMutableDictionary alloc] init];
    [dic setValue:phone forKey:@"phone"];
    if (![pwd isEqualToString:@""]) {
        [dic setValue:pwd forKey:@"password"];
    }else{
        [dic setValue:code forKey:@"phoneCode"];
    }
    [dic setValue:[HDUserDefaultMethods getData:JPUSH_REGID] forKey:@"registrationId"];
    [MHNetworkManager postReqeustWithURL:URL_LoginPhone params:dic successBlock:^(NSDictionary *returnData) {
        if ([returnData[@"respCode"] integerValue] == 200) {
            NSDictionary *userInfo = [HDToolHelper nullDicToDic:returnData[@"data"]];
            if ([userInfo[@"unionId"] isEqualToString:@""]) {
                //绑定微信
                HDBindWXViewController *bindVC = [HDBindWXViewController new];
                bindVC.userId = userInfo[@"id"];
                [self.navigationController pushViewController:bindVC animated:YES];
            }
            else{
                // 缓存用户信息
                [HDToolHelper saveData:userInfo];
                
                HDBaseTabBarViewController *tabVC = [HDBaseTabBarViewController new];
                tabVC.selectedIndex = 3;
                UIWindow *window = [[UIApplication sharedApplication] keyWindow];
                window.rootViewController = tabVC;
            }
        }else{
            [SVHUDHelper showInfoWithTimestamp:1 msg:returnData[@"respMsg"]];
        }
    } failureBlock:^(NSError *error) {
        
    } showHUD:YES];
}

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

#pragma mark ================== 加载视图 =====================

-(UIImageView *)backImage{
    if (!_backImage) {
        _backImage = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, kSCREEN_WIDTH, kSCREEN_HEIGHT)];
        _backImage.image = [UIImage imageNamed:@"bg_input_img"];
    }
    return _backImage;
}

-(UIScrollView *)mainScroll{
    if (!_mainScroll) {
        _mainScroll = [[UIScrollView alloc] initWithFrame:CGRectMake(0, 0, kSCREEN_WIDTH, kSCREEN_HEIGHT)];
        _mainScroll.backgroundColor = [UIColor clearColor];
    }
    return _mainScroll;
}

-(UIView *)controlView{
    if (!_controlView) {
        _controlView = [[UIView alloc] initWithFrame:CGRectMake(16, 171*HEIGHT_SCALE, kSCREEN_WIDTH-32, 349*HEIGHT_SCALE)];
        _controlView.layer.cornerRadius = 8;
        _controlView.backgroundColor = [UIColor whiteColor];
        _controlView.layer.shadowColor = [UIColor colorWithRed:0/255.0 green:0/255.0 blue:0/255.0 alpha:0.08].CGColor;
        _controlView.layer.shadowOffset = CGSizeMake(0,2);
        _controlView.layer.shadowOpacity = 1;
        _controlView.layer.shadowRadius = 4;
        
        // 添加子控件
        NSArray *txtDicArr = @[@{@"placeHolder":@"请输入您的手机号",@"image":@"login_input_ic_phone",@"btn":@""},
                               @{@"placeHolder":@"请输入6-32位密码",@"image":@"login_input_ic_keyword",@"btn":@"login_input_ic_hidepassword"}];
        if ([self.loginType isEqualToString:@"2"]) {
            txtDicArr = @[@{@"placeHolder":@"请输入您的手机号",@"image":@"login_input_ic_phone",@"btn":@""},
            @{@"placeHolder":@"请输入验证码",@"image":@"login_input_ic_verificationcode",@"btn":@"获取验证码"}];
        }
        
        for (int i = 0; i<txtDicArr.count; i++) {
            HDRegisterTextFeild *txt = [[HDRegisterTextFeild alloc] initWithFrame:CGRectMake(24, i*(36+24)*HEIGHT_SCALE+109*HEIGHT_SCALE, _controlView.width-24-24, 36*HEIGHT_SCALE) placeHolder:txtDicArr[i][@"placeHolder"] titleImage:txtDicArr[i][@"image"] btnImage:txtDicArr[i][@"btn"]];
            txt.tag = 1000+i;
            txt.btn.tag = 10000+i;
            txt.txtFeild.tag = 20000+i;
            txt.txtFeild.delegate = self;
            [txt.btn addTarget:self action:@selector(txtBtnAction:) forControlEvents:UIControlEventTouchUpInside];
            
            if (i==0) {
                if (self.strPhone) {
                    txt.txtFeild.text = self.strPhone;
                }
            }
            
            if ([self.loginType isEqualToString:@"2"]) {
                //验证码登录
                txt.txtFeild.keyboardType = UIKeyboardTypeNumberPad;
                if (i==0) {
                    [txt.txtFeild addTarget:self action:@selector(phoneTextFieldDidChange:)forControlEvents:UIControlEventEditingChanged];
                }else{
                    if ([self.strPhone isPhoneNo]){
                        txt.btn.userInteractionEnabled = YES;
                        [txt.btn setTitleColor:RGBMAIN forState:UIControlStateNormal];
                    }
                    else{
                        txt.btn.userInteractionEnabled = NO;
                        [txt.btn setTitleColor:RGBTEXTINFO forState:UIControlStateNormal];
                    }
                    [txt.txtFeild addTarget:self action:@selector(textFieldDidChange:)forControlEvents:UIControlEventEditingChanged];
                }
            }else{
                //密码登录
                if (i==0) {
                    txt.txtFeild.keyboardType = UIKeyboardTypeNumberPad;
                }
                if (i == 1) {
                    txt.txtFeild.secureTextEntry = YES;
                }
                [txt.txtFeild addTarget:self action:@selector(textFieldDidChange:)forControlEvents:UIControlEventEditingChanged];
            }
            
            [_controlView addSubview:txt];
        }
        
        [_controlView addSubview:self.btnLogin];
        [_controlView addSubview:self.agreeMentView];
        [_controlView addSubview:self.btnForget];
        [_controlView addSubview:self.btnVerLogin];
        [_controlView addSubview:self.btnLogin];
        [_controlView addSubview:self.agreeMentView];
    }
    return _controlView;
}

-(UIButton *)btnForget{
    if (!_btnForget) {
        UIView *txtLast = [_controlView viewWithTag:1001];
        _btnForget = [[UIButton alloc] initSystemWithFrame:CGRectMake(txtLast.x+8, CGRectGetMaxY(txtLast.frame)+24*HEIGHT_SCALE, 50, 12*HEIGHT_SCALE) btnTitle:@"忘记密码" btnImage:@"" titleColor:RGBMAIN titleFont:12];
        
        // 点击事件
        [_btnForget addTarget:self action:@selector(clickForgetPwdAction:) forControlEvents:UIControlEventTouchUpInside];
    }
    return _btnForget;
}

-(UIButton *)btnVerLogin{
    if (!_btnVerLogin) {
        UIView *txtLast = [_controlView viewWithTag:1001];
        _btnVerLogin = [[UIButton alloc] initSystemWithFrame:CGRectMake(_controlView.width-84-32, CGRectGetMaxY(txtLast.frame)+24*HEIGHT_SCALE, 86, 12*HEIGHT_SCALE) btnTitle:@"短信验证码登录" btnImage:@"" titleColor:RGBMAIN titleFont:12];
        
        // 点击事件
        [_btnVerLogin addTarget:self action:@selector(clickVerLoginAction:) forControlEvents:UIControlEventTouchUpInside];
    }
    return _btnVerLogin;
}

-(UIButton *)btnLogin{
    if (!_btnLogin) {
        _btnLogin = [[UIButton alloc] initCommonWithFrame:CGRectMake(24, CGRectGetMaxY(self.btnVerLogin.frame)+32*HEIGHT_SCALE, _controlView.width-24-24, 36*HEIGHT_SCALE) btnTitle:@"登录" bgColor:RGBAlpha(230, 230, 230, 1) titleColor:RGBAlpha(153, 153, 153, 1) titleFont:14];
        _btnLogin.layer.cornerRadius = _btnLogin.height/2;
        [_btnLogin addTarget:self action:@selector(loginBtnAction:) forControlEvents:UIControlEventTouchUpInside];
        _btnLogin.userInteractionEnabled = NO;
    }
    return _btnLogin;
}

-(UIView *)agreeMentView{
    if (!_agreeMentView) {
        _agreeMentView = [[UIView alloc] initWithFrame:CGRectMake(0, CGRectGetMaxY(_btnLogin.frame)+15, _controlView.width, 12)];
        
        // 添加子控件
        [_agreeMentView addSubview:self.btnAgree];
        [_agreeMentView addSubview:self.lblAgree];
        [_agreeMentView addSubview:self.lblAgreeMent];
        _agreeMentView.width = CGRectGetMaxX(self.lblAgreeMent.frame);
        _agreeMentView.centerX = _controlView.width/2;
    }
    return _agreeMentView;
}

-(UIButton *)btnAgree{
    if (!_btnAgree) {
        _btnAgree = [[UIButton alloc] initSystemWithFrame:CGRectMake(0, 0, 12, 12) btnTitle:@"" btnImage:@"checkbox_default" titleColor:[UIColor whiteColor] titleFont:0];
        _btnAgree.centerY = _agreeMentView.height/2;
        _btnAgree.selected = YES;
        [_btnAgree setImage:[UIImage imageNamed:@"checkbox_selected"] forState:UIControlStateSelected];
        
        //点击事件
        [_btnAgree addTarget:self action:@selector(tapAgreeAction:) forControlEvents:UIControlEventTouchUpInside];
    }
    return _btnAgree;
}

-(UILabel *)lblAgree{
    if (!_lblAgree) {
        _lblAgree = [[UILabel alloc] initCustomWithFrame:CGRectMake(CGRectGetMaxX(_btnAgree.frame)+5, 0, 100, 12) title:@"登录即同意" bgColor:[UIColor clearColor] titleColor:RGBAlpha(153, 153, 153, 1) titleFont:12];
        [_lblAgree sizeToFit];
        _lblAgree.height = 12;
    }
    return _lblAgree;
}

-(UILabel *)lblAgreeMent{
    if (!_lblAgreeMent) {
        _lblAgreeMent = [[UILabel alloc] initCustomWithFrame:CGRectMake(CGRectGetMaxX(_lblAgree.frame), 0, 100, 12) title:@"《巢流APP用户协议》" bgColor:[UIColor clearColor] titleColor:RGBAlpha(32, 137, 253, 1) titleFont:12];
        [_lblAgreeMent sizeToFit];
        _lblAgreeMent.height = 12;
        
        UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapAgreementDetailAction)];
        _lblAgreeMent.userInteractionEnabled = YES;
        [_lblAgreeMent addGestureRecognizer:tap];
    }
    return _lblAgreeMent;
}

-(UIImageView *)imageApp{
    if (!_imageApp) {
        _imageApp = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"logo_signin"]];
        _imageApp.centerX = kSCREEN_WIDTH/2;
        _imageApp.y = 131*HEIGHT_SCALE;
    }
    return _imageApp;
}

-(HDBaseNavView *)navView{
    if (!_navView) {
        _navView=[[HDBaseNavView alloc] initWithFrame:CGRectMake(0, 0, kSCREEN_WIDTH, NAVHIGHT) title:@"" bgColor:[UIColor clearColor] backBtn:YES rightBtn:@"" rightBtnImage:@"" theDelegate:self];
    }
    return _navView;
}

@end
