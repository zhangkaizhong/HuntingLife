//
//  HDAboutUsViewController.m
//  HairDress
//
//  Created by 张凯中 on 2020/3/2.
//  Copyright © 2020 zhangkaizhong. All rights reserved.
//

#import "HDAboutUsViewController.h"

@interface HDAboutUsViewController ()<navViewDelegate>

@property (nonatomic,strong) HDBaseNavView *navView;
@property (nonatomic,strong) UIScrollView *mainScrollView;

@end

@implementation HDAboutUsViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self.view addSubview:self.navView];
    [self.view addSubview:self.mainScrollView];
}

#pragma mark -- delegate action
-(void)navBackClicked{
    [self.navigationController popViewControllerAnimated:YES];
}

//跳转到appstore
-(void)tapUpdateToappstore:(UIGestureRecognizer *)sender{
    NSString *url = @"https://itunes.apple.com/app/apple-store/id1513137339?mt=8";
    [[UIApplication sharedApplication] openURL:[NSURL URLWithString:url]];
}

#pragma mark -- UI
-(HDBaseNavView *)navView{
    if (!_navView) {
        _navView = [[HDBaseNavView alloc] initWithFrame:CGRectMake(0, 0, kSCREEN_WIDTH, NAVHIGHT) title:@"关于我们" bgColor:RGBMAIN backBtn:YES rightBtn:@"" rightBtnImage:@"" theDelegate:self];
    }
    return _navView;
}

-(UIScrollView *)mainScrollView{
    if (!_mainScrollView) {
        _mainScrollView = [[UIScrollView alloc] initWithFrame:CGRectMake(0, NAVHIGHT, kSCREEN_WIDTH, kSCREEN_HEIGHT-NAVHIGHT)];
        
        UIImageView *imageApp = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"logo_phone"]];
        imageApp.centerX = kSCREEN_WIDTH/2;
        imageApp.y = 59*SCALE;
        [_mainScrollView addSubview:imageApp];
        
        NSDictionary *infoDictionary = [[NSBundle mainBundle] infoDictionary];
        NSString *appVersion = [infoDictionary objectForKey:@"CFBundleShortVersionString"];
        UILabel *lblVersion = [[UILabel alloc] initCommonWithFrame:CGRectMake(0, imageApp.bottom+8, kSCREEN_WIDTH, 14) title:[NSString stringWithFormat:@"Version %@",appVersion] bgColor:[UIColor clearColor] titleColor:RGBTEXT titleFont:14 textAlignment:NSTextAlignmentCenter isFit:NO];
        [_mainScrollView addSubview:lblVersion];
        
        //版本更新
        UIView *updateView = [self createTextView:CGRectMake(0, lblVersion.bottom+32, kSCREEN_WIDTH, 55) title:@"版本更新" placeText:@""];
        [_mainScrollView addSubview:updateView];
        UITapGestureRecognizer *tapUp = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapUpdateToappstore:)];
        updateView.userInteractionEnabled = YES;
        [updateView addGestureRecognizer:tapUp];
        
        UIView *xieyiView = [[UIView alloc] initWithFrame:CGRectMake(0, _mainScrollView.height-76-11, kSCREEN_WIDTH, 11)];
        xieyiView.backgroundColor = [UIColor clearColor];
        [_mainScrollView addSubview:xieyiView];
        //协议
        UILabel *lblXieyi = [[UILabel alloc] initCommonWithFrame:CGRectMake(0, 0, kSCREEN_WIDTH, 11) title:@"《巢流软件许可及服务协议》" bgColor:[UIColor clearColor] titleColor:RGBCOLOR(87, 107, 149) titleFont:11 textAlignment:NSTextAlignmentCenter isFit:YES];
        lblXieyi.height = 11;
        [xieyiView addSubview:lblXieyi];
        
        UILabel *lblHe = [[UILabel alloc] initCommonWithFrame:CGRectMake(CGRectGetMaxX(lblXieyi.frame), 0, kSCREEN_WIDTH, 11) title:@"和" bgColor:[UIColor clearColor] titleColor:RGBLIGHT_TEXTINFO titleFont:11 textAlignment:NSTextAlignmentCenter isFit:YES];
        lblHe.height = 11;
        [xieyiView addSubview:lblHe];
        
        //隐私指引
        UILabel *lblYinsi = [[UILabel alloc] initCommonWithFrame:CGRectMake(CGRectGetMaxX(lblHe.frame), 0, kSCREEN_WIDTH, 11) title:@"《巢流隐私保护指引》" bgColor:[UIColor clearColor] titleColor:RGBCOLOR(87, 107, 149) titleFont:11 textAlignment:NSTextAlignmentCenter isFit:YES];
        lblYinsi.height = 11;
        [xieyiView addSubview:lblYinsi];
        xieyiView.width = CGRectGetMaxX(lblYinsi.frame);
        xieyiView.centerX = kSCREEN_WIDTH/2;
        
        //版权信息
        UILabel *lblBanquan = [[UILabel alloc] initCommonWithFrame:CGRectMake(0, xieyiView.bottom+15, kSCREEN_WIDTH, 11) title:@"云次方公司 版权所有" bgColor:[UIColor clearColor] titleColor:RGBTEXTINFO titleFont:11 textAlignment:NSTextAlignmentCenter isFit:NO];
        [_mainScrollView addSubview:lblBanquan];
        UILabel *lblJies = [[UILabel alloc] initCommonWithFrame:CGRectMake(0, lblBanquan.bottom+7, kSCREEN_WIDTH, 11) title:@"Copyright © 2019-2049 Scissors.All Rights Reserved." bgColor:[UIColor clearColor] titleColor:RGBTEXTINFO titleFont:11 textAlignment:NSTextAlignmentCenter isFit:NO];
        [_mainScrollView addSubview:lblJies];
        
        _mainScrollView.contentSize = CGSizeMake(kSCREEN_WIDTH, lblJies.bottom);
    }
    return _mainScrollView;
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
    
    UIImageView *imageGo = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"common_ic_arrow_right_g"]];
    imageGo.x = kSCREEN_WIDTH-16-imageGo.width;
    imageGo.centerY = lblTitle.centerY;
    [view addSubview:imageGo];
    
    return view;
}

@end
