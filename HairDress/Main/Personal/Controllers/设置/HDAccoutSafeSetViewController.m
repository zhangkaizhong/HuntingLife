//
//  HDMyBankCardViewController.m
//  HairDress
//
//  Created by 张凯中 on 2020/2/13.
//  Copyright © 2020 zhangkaizhong. All rights reserved.
//

#import "HDAccoutSafeSetViewController.h"

#import "HDResetPasswordsViewController.h"

@interface HDAccoutSafeSetViewController ()<navViewDelegate>

@property (nonatomic,strong) UIScrollView *mainScrollView;
@property (nonatomic,strong) HDBaseNavView *navView;

@end

@implementation HDAccoutSafeSetViewController

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

//修改账号密码
-(void)tapUserPwdAction:(UIGestureRecognizer *)sender{
    HDResetPasswordsViewController *resetVC = [HDResetPasswordsViewController new];
    resetVC.pwdType = @"1";
    [self.navigationController pushViewController:resetVC animated:YES];
}
//修改支付密码
-(void)tapPayPwdAction:(UIGestureRecognizer *)sender{
    HDResetPasswordsViewController *resetVC = [HDResetPasswordsViewController new];
    resetVC.pwdType = @"2";
    [self.navigationController pushViewController:resetVC animated:YES];
}

//注销账号
-(void)tapLogoutAction:(UIGestureRecognizer *)sender{
    [[WMZAlert shareInstance] showAlertWithType:AlertTypeNornal headTitle:@"提示" textTitle:@"您确定要注销账号吗?" viewController:self leftHandle:^(id anyID) {
        //取消
    }rightHandle:^(id any) {
        //确定
        [self deleteMember];
    }];
}

#pragma mark -- 数据请求
-(void)deleteMember{
    [MHNetworkManager postReqeustWithURL:URL_MemberLogoutMember params:@{@"id":[HDUserDefaultMethods getData:@"userId"]} successBlock:^(NSDictionary *returnData) {
        if ([returnData[@"respCode"] integerValue] == 200) {
            [SVHUDHelper showDarkWarningMsg:@"您的账号已注销"];
            [HDUserDefaultMethods logout];
            [HDToolHelper chooseToJumpHome:self selectIndex:0];
        }else{
            [SVHUDHelper showDarkWarningMsg:returnData[@"respMsg"]];
        }
    } failureBlock:^(NSError *error) {
        
    } showHUD:YES];
}

#pragma mark --UI

-(HDBaseNavView *)navView{
    if (!_navView) {
        _navView = [[HDBaseNavView alloc] initWithFrame:CGRectMake(0, 0, kSCREEN_WIDTH, NAVHIGHT) title:@"账号与安全" bgColor:RGBMAIN backBtn:YES rightBtn:@"" rightBtnImage:@"" theDelegate:self];
    }
    return _navView;
}

-(UIScrollView *)mainScrollView{
    if (!_mainScrollView) {
        _mainScrollView = [[UIScrollView alloc] initWithFrame:CGRectMake(0, NAVHIGHT, kSCREEN_WIDTH, kSCREEN_HEIGHT-NAVHIGHT)];
        _mainScrollView.backgroundColor = [UIColor clearColor];
        
        UIView *viewUserPwd = [self createTextView:CGRectMake(0, 12, kSCREEN_WIDTH, 55) title:@"账号密码" placeText:@"修改"];
        UIView *viewPayPwd = [self createTextView:CGRectMake(0, viewUserPwd.bottom, kSCREEN_WIDTH, 55) title:@"支付密码" placeText:@"修改"];
        UIView *viewLogout = [self createTextView:CGRectMake(0, viewPayPwd.bottom, kSCREEN_WIDTH, 55) title:@"注销账号" placeText:@"注销后无法恢复，请谨慎操作"];
        
        UITapGestureRecognizer *tapUserPwd = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapUserPwdAction:)];
        viewUserPwd.userInteractionEnabled = YES;
        [viewUserPwd addGestureRecognizer:tapUserPwd];
        
        UITapGestureRecognizer *tapPayPwd = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapPayPwdAction:)];
        viewPayPwd.userInteractionEnabled = YES;
        [viewPayPwd addGestureRecognizer:tapPayPwd];
        
        UITapGestureRecognizer *tapLogout = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapLogoutAction:)];
        viewLogout.userInteractionEnabled = YES;
        [viewLogout addGestureRecognizer:tapLogout];
        
        [_mainScrollView addSubview:viewUserPwd];
        [_mainScrollView addSubview:viewPayPwd];
        [_mainScrollView addSubview:viewLogout];
        
        _mainScrollView.contentSize = CGSizeMake(kSCREEN_WIDTH, viewLogout.bottom);
    }
    return _mainScrollView;
}

-(UIView *)createTextView:(CGRect)frame title:(NSString *)title placeText:(NSString *)place{
    UIView *view = [[UIView alloc] initWithFrame:frame];
    
    view.backgroundColor = [UIColor whiteColor];
    UIView *line = [[UIView alloc] initWithFrame:CGRectMake(16, view.height-1, kSCREEN_WIDTH-16, 1)];
    line.backgroundColor = RGBCOLOR(241, 241, 241);
    [view addSubview:line];
    if ([title isEqualToString:@"注销账号"]) {
        line.hidden = YES;
    }
    
    UILabel *lblTitle = [[UILabel alloc] initCommonWithFrame:CGRectMake(16, 0, 100, 20) title:title bgColor:[UIColor clearColor] titleColor:RGBTEXT titleFont:14 textAlignment:NSTextAlignmentLeft isFit:YES];
    lblTitle.centerY = view.height/2;
    [view addSubview:lblTitle];
    
    HDTextFeild *txtField = [[HDTextFeild alloc] initWithFrame:CGRectMake(CGRectGetMaxX(lblTitle.frame)+20, 0, kSCREEN_WIDTH-CGRectGetMaxX(lblTitle.frame)-20-16, 20)];
    [view addSubview:txtField];
    txtField.textAlignment = NSTextAlignmentRight;
    txtField.placeholder = place;
    txtField.centerY = view.height/2;
    txtField.font = [UIFont systemFontOfSize:14];
    txtField.userInteractionEnabled = NO;
    
    UIImageView *imageGo = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"common_ic_arrow_right_g"]];
    imageGo.x = kSCREEN_WIDTH-16-imageGo.width;
    imageGo.centerY = lblTitle.centerY;
    [view addSubview:imageGo];
    txtField.width = kSCREEN_WIDTH-CGRectGetMaxX(lblTitle.frame)-20-16-imageGo.width;
    
    return view;
}

@end
