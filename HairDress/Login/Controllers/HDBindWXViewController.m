//
//  HDRegisterDoneViewController.m
//  HairDress
//
//  Created by Apple on 2019/12/30.
//  Copyright © 2019 zhangkaizhong. All rights reserved.
//

#import "HDBindWXViewController.h"
#import "HDRegisterDoneViewController.h"
#import "WXApi.h"

@interface HDBindWXViewController ()<navViewDelegate>

@property (nonatomic,strong)HDBaseNavView *navView;//导航栏

@end

@implementation HDBindWXViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.view.backgroundColor = RGBBG;
    [self.view addSubview:self.navView];
    
    UILabel *lblwx = [[UILabel alloc] initCommonWithFrame:CGRectMake(0, _navView.bottom+40, kSCREEN_WIDTH, 16) title:@"请绑定微信" bgColor:[UIColor clearColor] titleColor:RGBTEXT titleFont:16 textAlignment:NSTextAlignmentCenter isFit:NO];
    [self.view addSubview:lblwx];
    
    // 绑定微信
    UIButton *buttonWx = [[UIButton alloc] initSystemWithFrame:CGRectMake(16, lblwx.bottom+40, kSCREEN_WIDTH-32, 48) btnTitle:@"  绑定微信" btnImage:@"login_method_ic_wechat2" titleColor:[UIColor whiteColor] titleFont:14];
    buttonWx.layer.cornerRadius = 48/2;
    buttonWx.backgroundColor = RGBMAIN;
    [self.view addSubview:buttonWx];
    [buttonWx addTarget:self action:@selector(bindWXAction) forControlEvents:UIControlEventTouchUpInside];
    
    //接收微信登录成功通知
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(weiChatBindOKAction:) name:NOTICE_TYPE_WXBINDSUCCESS object:nil];
}

#pragma mark ================== delegate /action =====================

// 导航栏
-(void)navBackClicked{
    [self.navigationController popViewControllerAnimated:YES];
}

// 绑定微信
-(void)bindWXAction{
    [HDUserDefaultMethods saveData:@"1" andKey:@"isBindWX"];
    if([WXApi isWXAppInstalled]){//判断用户是否已安装微信App
        SendAuthReq *req = [[SendAuthReq alloc] init];
        req.state = @"wx_oauth_authorization_state";//用于保持请求和回调的状态，授权请求或原样带回
        req.scope = @"snsapi_userinfo";//授权作用域：获取用户个人信息
        //唤起微信
        [WXApi sendReq:req completion:nil];
    }
}

//绑定微信成功回调
-(void)weiChatBindOKAction:(NSNotification *)notice{
    NSDictionary *userInfo = notice.userInfo;
    
    NSDictionary *params = @{
        @"equipmentNo":[[[UIDevice currentDevice] identifierForVendor] UUIDString],
        @"id":self.userId,
        @"headImg":userInfo[@"headimgurl"],
        @"gender":userInfo[@"sex"],
        @"nickName":userInfo[@"nickname"],
        @"openId":userInfo[@"openid"],
        @"unionId":userInfo[@"unionid"],
        @"registrationId":[HDUserDefaultMethods getData:JPUSH_REGID]
    };
    [MHNetworkManager postReqeustWithURL:URL_MemberBindWx params:params successBlock:^(NSDictionary *returnData) {
        DTLog(@"%@",returnData);
        if ([returnData[@"respCode"] integerValue] == 200) {
            NSDictionary *userInfo = [HDToolHelper nullDicToDic:returnData[@"data"]];
            // 缓存用户信息
            [HDToolHelper saveData:userInfo];
            
            if (self.phone && self.pwd) {
                HDRegisterDoneViewController *doneVC = [HDRegisterDoneViewController new];
                doneVC.phone = self.phone;
                doneVC.pwd = self.pwd;
                [self.navigationController pushViewController:doneVC animated:YES];
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
            [SVHUDHelper showDarkWarningMsg:returnData[@"respMsg"]];
        }
    } failureBlock:^(NSError *error) {
        
    } showHUD:YES];
}

#pragma mark ================== 加载视图 =====================

-(HDBaseNavView *)navView{
    if (!_navView) {
        _navView=[[HDBaseNavView alloc] initWithFrame:CGRectMake(0, 0, kSCREEN_WIDTH, NAVHIGHT) title:@"绑定微信" bgColor:[UIColor clearColor] backBtn:YES rightBtn:@"" rightBtnImage:@"" theDelegate:self];
    }
    return _navView;
}


-(void)dealloc{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}


@end
