//
//  HDRegisterViewController.m
//  HairDress
//
//  Created by Apple on 2019/12/18.
//  Copyright © 2019 zhangkaizhong. All rights reserved.
//

#import "HDRegisterViewController.h"

#import "HDRegisterTextFeild.h"

#import "HDBindWXViewController.h"
#import "HDHtmlViewController.h"

@interface HDRegisterViewController ()<navViewDelegate,UITextFieldDelegate>

@property (nonatomic,strong)HDBaseNavView *navView;//导航栏
@property (nonatomic,strong)ZXLGCDTimer *timer;
@property (nonatomic,strong) UIScrollView * mainScoll;  // 主视图
@property (nonatomic,strong) UIView * controlView;  // 控件视图
@property (nonatomic,strong) UIButton * btnRegister;  // 注册按钮
@property (nonatomic,strong) UIButton * btnAgree;  // 协议按钮
@property (nonatomic,strong) UILabel * lblAgreeMent;  // 协议按钮
@property (nonatomic,strong) UILabel * lblAgree;
@property (nonatomic,strong) UIView * agreeMentView;  // 协议视图

@property (nonatomic,copy) NSString *select_agree;//勾选协议
@property (nonatomic,strong) UIButton *btnGetCode;  // 获取验证码按钮

@end

//倒计时总秒数
static NSInteger secondsCountDown = 0;

@implementation HDRegisterViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    // UI
    [self createUI];
    self.select_agree = @"1";
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

// 注册
-(void)registerBtnAction:(UIButton *)sender{
    HDTextFeild *txtPhone = [self.view viewWithTag:20000];
    HDTextFeild *txtVercode = [self.view viewWithTag:20001];
    HDTextFeild *txtPwd = [self.view viewWithTag:20002];
    
    if ([txtVercode.text isEqualToString:@""]) {
        [SVHUDHelper showDarkWarningMsg:@"短信验证码不能为空"];
        return;
    }
    if (txtPwd.text.length <6) {
        [SVHUDHelper showDarkWarningMsg:@"请输入6-32位密码"];
        return;
    }
    if (![HDToolHelper checkPassword:txtPwd.text]) {
        [SVHUDHelper showDarkWarningMsg:@"密码应为数字、或数字和字母组合"];
        return;
    }
    
    if ([self.select_agree isEqualToString:@"1"]) {
        // 发送注册请求
        [self phoneRegisterAction:txtPhone.text pwd:txtPwd.text code:txtVercode.text];
    }
    else{
        [SVHUDHelper showInfoWithTimestamp:1 msg:@"请勾选协议"];
    }
}

// 手机注册接口请求
-(void)phoneRegisterAction:(NSString *)phone pwd:(NSString *)pwd code:(NSString *)code{
    WeakSelf;
    NSDictionary *params = @{
        @"password":pwd,
        @"phone":phone,
        @"phoneCode":code,
        @"registrationId":[HDUserDefaultMethods getData:JPUSH_REGID]
    };
    [MHNetworkManager postReqeustWithURL:URL_RegisterPhone params:params successBlock:^(NSDictionary *returnData) {
        DTLog(@"%@",returnData);
        if ([returnData[@"respCode"] integerValue] == 200) {
            NSDictionary *userInfo = [HDToolHelper nullDicToDic:returnData[@"data"]];
            // 手机注册成功后绑定微信
            HDBindWXViewController *bindVC = [HDBindWXViewController new];
            bindVC.phone = phone;
            bindVC.pwd = pwd;
            bindVC.userId = userInfo[@"id"];
            [weakSelf.navigationController pushViewController:bindVC animated:YES];
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
    if (txtPwd.text.length > 32) {
        txtPwd.text = [txtPwd.text substringToIndex:32];
    }
    if ([txtPhone.text isPhoneNo] && txtVercode.text.length == 4 && txtPwd.text.length>=4) {
        _btnRegister.userInteractionEnabled = YES;
        _btnRegister.backgroundColor = RGBMAIN;
        [_btnRegister setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    }else{
        _btnRegister.userInteractionEnabled = NO;
        [_btnRegister setTitleColor:RGBAlpha(153, 153, 153, 1) forState:UIControlStateNormal];
        _btnRegister.backgroundColor = RGBAlpha(230, 230, 230, 1);
    }
}

// 手机号监听
-(void)phoneTextFieldDidChange:(UITextField *)textField{
    HDTextFeild *txtPhone = [self.view viewWithTag:20000];
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

#pragma mark ================== 加载视图 =====================

-(HDBaseNavView *)navView{
    if (!_navView) {
        _navView=[[HDBaseNavView alloc] initWithFrame:CGRectMake(0, 0, kSCREEN_WIDTH, NAVHIGHT) title:@"手机注册" bgColor:[UIColor clearColor] backBtn:YES rightBtn:@"" rightBtnImage:@"" theDelegate:self];
    }
    return _navView;
}

-(UIScrollView *)mainScoll{
    if (!_mainScoll) {
        _mainScoll = [[UIScrollView alloc] initWithFrame:CGRectMake(0, NAVHIGHT, kSCREEN_WIDTH, kSCREEN_HEIGHT-NAVHIGHT)];
        _mainScoll.contentSize = CGSizeMake(kSCREEN_WIDTH, kSCREEN_HEIGHT);
        _mainScoll.backgroundColor = [UIColor clearColor];
        _mainScoll.scrollEnabled = NO;
    }
    return _mainScoll;
}

-(UIView *)controlView{
    if (!_controlView) {
        _controlView = [[UIView alloc] initWithFrame:CGRectMake(16, 24, kSCREEN_WIDTH-32, 336)];
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
            if (i == 1) {
                txt.txtFeild.keyboardType = UIKeyboardTypeNumberPad;
                txt.btn.userInteractionEnabled = NO;
            }
            if (i == 2) {
                txt.txtFeild.secureTextEntry = YES;
            }
            [txt.btn addTarget:self action:@selector(txtBtnAction:) forControlEvents:UIControlEventTouchUpInside];
            // 手机号监听
            if (i==0) {
                txt.txtFeild.keyboardType = UIKeyboardTypeNumberPad;
                [txt.txtFeild addTarget:self action:@selector(phoneTextFieldDidChange:)forControlEvents:UIControlEventEditingChanged];
            }else{
                [txt.txtFeild addTarget:self action:@selector(textFieldDidChange:)forControlEvents:UIControlEventEditingChanged];
            }
            
            [_controlView addSubview:txt];
        }
        
        [_controlView addSubview:self.btnRegister];
        [_controlView addSubview:self.agreeMentView];
    }
    return _controlView;
}

-(UIButton *)btnRegister{
    if (!_btnRegister) {
        UIView *txtLast = [_controlView viewWithTag:1002];
        _btnRegister = [[UIButton alloc] initCommonWithFrame:CGRectMake(24, CGRectGetMaxY(txtLast.frame)+64, _controlView.width-24-24, 36) btnTitle:@"下一步" bgColor:RGBAlpha(230, 230, 230, 1) titleColor:RGBAlpha(153, 153, 153, 1) titleFont:14];
        _btnRegister.layer.cornerRadius = _btnRegister.height/2;
        [_btnRegister addTarget:self action:@selector(registerBtnAction:) forControlEvents:UIControlEventTouchUpInside];
        _btnRegister.userInteractionEnabled = NO;
    }
    return _btnRegister;
}

-(UIView *)agreeMentView{
    if (!_agreeMentView) {
        _agreeMentView = [[UIView alloc] initWithFrame:CGRectMake(0, CGRectGetMaxY(_btnRegister.frame)+15, _controlView.width, 12)];
        
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
        _lblAgree = [[UILabel alloc] initCustomWithFrame:CGRectMake(CGRectGetMaxX(_btnAgree.frame)+5, 0, 100, 12) title:@"注册即同意" bgColor:[UIColor clearColor] titleColor:RGBAlpha(153, 153, 153, 1) titleFont:12];
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


@end
