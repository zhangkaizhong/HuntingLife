//
//  HDPreLoginViewController.m
//  HairDress
//
//  Created by Apple on 2019/12/18.
//  Copyright © 2019 zhangkaizhong. All rights reserved.
//

#import "HDPreLoginViewController.h"

#import "WXApi.h"
#import "HDRegisterViewController.h"
#import "HDLoginViewController.h"

@interface HDPreLoginViewController ()

@property (nonatomic,strong) UIImageView * appImageView;  // app图标
@property (nonatomic,strong) UIButton * wxLogButton;  // 微信登录btn
@property (nonatomic,strong) UIButton * phoneLogButton;  // 手机登录btn
@property (nonatomic,strong) UIButton * registerButton;  // 注册btn
@property (nonatomic,strong) UIButton * closeButton;  // 关闭btn

@end

@implementation HDPreLoginViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor whiteColor];
    // UI
    [self createUI];
    
    //接收微信登录成功通知
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(weiChatLoginOKAction:) name:NOTICE_TYPE_WXLOGINSUCCESS object:nil];
}

#pragma mark ================== delegate action =====================
//手机登录
-(void)phoneLoginAction{
    HDLoginViewController *loginVC = [HDLoginViewController new];
    [self.navigationController pushViewController:loginVC animated:YES];
}

//微信登录
-(void)weixinLoginAction{
    [HDUserDefaultMethods saveData:@"0" andKey:@"isBindWX"];
    if([WXApi isWXAppInstalled]){//判断用户是否已安装微信App
        SendAuthReq *req = [[SendAuthReq alloc] init];
        req.state = @"wx_oauth_authorization_state";//用于保持请求和回调的状态，授权请求或原样带回
        req.scope = @"snsapi_userinfo";//授权作用域：获取用户个人信息
        //唤起微信
        [WXApi sendReq:req completion:nil];
    }
}

//微信登录成功回调
-(void)weiChatLoginOKAction:(NSNotification *)notice{
    NSDictionary *userInfo = notice.userInfo;
    
    NSString *unionId = userInfo[@"unionid"];
    
    NSDictionary *params = @{
        @"unionId":unionId,
        @"registrationId":[HDUserDefaultMethods getData:JPUSH_REGID]
    };
    [MHNetworkManager postReqeustWithURL:URL_MemberWXLogin params:params successBlock:^(NSDictionary *returnData) {
        DTLog(@"%@",returnData);
        if ([returnData[@"respCode"] integerValue] == 200) {
            NSDictionary *userInfo = [HDToolHelper nullDicToDic:returnData[@"data"]];
            // 缓存用户信息
            [HDToolHelper saveData:userInfo];
            
            HDBaseTabBarViewController *tabVC = [HDBaseTabBarViewController new];
            tabVC.selectedIndex = 3;
            UIWindow *window = [[UIApplication sharedApplication] keyWindow];
            window.rootViewController = tabVC;
        }else{
            [SVHUDHelper showDarkWarningMsg:returnData[@"respMsg"]];
        }
    } failureBlock:^(NSError *error) {
        
    } showHUD:YES];
}

//退出页面
-(void)closeViewAction{
    [self dismissViewControllerAnimated:YES completion:nil];
}

/*
 创建UI
 */
-(void)createUI{
    [self.view addSubview:self.appImageView];
    [self.view addSubview:self.closeButton];
    [self.view addSubview:self.registerButton];
    [self.view addSubview:self.phoneLogButton];
    if ([WXApi isWXAppInstalled]) {
        [self.view addSubview:self.wxLogButton];
    }else{
        self.phoneLogButton.centerX = kSCREEN_WIDTH/2;
    }
}

#pragma mark ================== button action =====================

-(void)tapButtonAction:(UIButton *)sender{
    if (sender.tag == 1000) {
        HDRegisterViewController *registerVC = [[HDRegisterViewController alloc] init];
        [self.navigationController pushViewController:registerVC animated:YES];
    }
}

#pragma mark ================== 加载视图 =====================

-(UIImageView *)appImageView{
    if (!_appImageView) {
        _appImageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"logo_signin"]];
        _appImageView.centerX = self.view.width/2;
        _appImageView.y = 150*SCALE;
    }
    return _appImageView;
}

-(UIButton *)registerButton{
    if (!_registerButton) {
        _registerButton = [[UIButton alloc] initCommonWithFrame:CGRectMake(40, CGRectGetMaxY(_appImageView.frame)+161*SCALE, kSCREEN_WIDTH-80, 36)
                                                       btnTitle:@"注册"
                                                        bgColor:RGBMAIN
                                                     titleColor:[UIColor whiteColor]
                                                      titleFont:14];
        _registerButton.layer.cornerRadius = _registerButton.height/2;
        _registerButton.tag = 1000;
        [_registerButton addTarget:self action:@selector(tapButtonAction:) forControlEvents:UIControlEventTouchUpInside];
    }
    return _registerButton;
}

-(UIButton *)phoneLogButton{
    if (!_phoneLogButton) {
        _phoneLogButton = [[UIButton alloc] initCustomWithFrame:CGRectMake(40, CGRectGetMaxY(_registerButton.frame)+32*SCALE, kSCREEN_WIDTH/2-47.5, 36)
                                                       btnTitle:@"手机登录"
                                                       btnImage:@"login_method_ic_phone"
                                                        btnType:LEFT
                                                        bgColor:RGBAlpha(244, 244, 244, 1)
                                                     titleColor:RGBAlpha(153, 153, 153, 1)
                                                      titleFont:14];
        _phoneLogButton.layer.cornerRadius = _phoneLogButton.height/2;
        [_phoneLogButton addTarget:self action:@selector(phoneLoginAction) forControlEvents:UIControlEventTouchUpInside];
    }
    return _phoneLogButton;
}

-(UIButton *)wxLogButton{
    if (!_wxLogButton) {
        _wxLogButton = [[UIButton alloc] initCustomWithFrame:CGRectMake(CGRectGetMaxX(_phoneLogButton.frame)+15, CGRectGetMaxY(_registerButton.frame)+32*SCALE, kSCREEN_WIDTH/2-47.5, 36)
                                                    btnTitle:@"微信登录"
                                                    btnImage:@"login_method_ic_wechat"
                                                     btnType:LEFT
                                                     bgColor:RGBAlpha(244, 244, 244, 1)
                                                  titleColor:RGBAlpha(153, 153, 153, 1)
                                                   titleFont:14];
        _wxLogButton.layer.cornerRadius = _wxLogButton.height/2;
        [_wxLogButton addTarget:self action:@selector(weixinLoginAction) forControlEvents:UIControlEventTouchUpInside];
    }
    return _wxLogButton;
}

-(UIButton *)closeButton{
    if (!_closeButton) {
        _closeButton = [UIButton buttonWithType:UIButtonTypeCustom];
        _closeButton.frame = CGRectMake(kSCREEN_WIDTH-20-26-10, 30*SCALE, 46, 46);
        [_closeButton setImage:[UIImage imageNamed:@"login_ic_close"] forState:UIControlStateNormal];
        [_closeButton addTarget:self action:@selector(closeViewAction) forControlEvents:UIControlEventTouchUpInside];
    }
    return _closeButton;
}

-(void)dealloc{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    DTLog(@"%s",__FUNCTION__);
}

@end
