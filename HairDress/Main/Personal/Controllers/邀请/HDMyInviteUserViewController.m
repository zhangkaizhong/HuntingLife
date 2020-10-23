//
//  HDMyInviteUserViewController.m
//  HairDress
//
//  Created by 张凯中 on 2020/1/1.
//  Copyright © 2020 zhangkaizhong. All rights reserved.
//

#import "HDMyInviteUserViewController.h"

@interface HDMyInviteUserViewController ()<navViewDelegate>

@property (nonatomic,strong) HDBaseNavView *navView;// 导航栏
@property (nonatomic,strong) UIImageView *imageBack;

@end

@implementation HDMyInviteUserViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self.view addSubview:self.navView];
    [self.view addSubview:self.imageBack];
    
    UIView *viewQRCodeBack = [[UIView alloc] initWithFrame:CGRectMake(0, kSCREEN_HEIGHT-16*HEIGHT_SCALE-200*HEIGHT_SCALE, 200*HEIGHT_SCALE, 200*HEIGHT_SCALE)];
    viewQRCodeBack.backgroundColor = RGBCOLOR(128, 127, 239);
    viewQRCodeBack.layer.cornerRadius = 6;
    viewQRCodeBack.centerX = kSCREEN_WIDTH/2;
    [self.view addSubview:viewQRCodeBack];
    
    UIImageView *imageQRCode = [[UIImageView alloc] initWithFrame:CGRectMake(10*HEIGHT_SCALE, 10*HEIGHT_SCALE, 180*HEIGHT_SCALE, 180*HEIGHT_SCALE)];
    imageQRCode.layer.cornerRadius = 6;
    imageQRCode.layer.masksToBounds = YES;
    [viewQRCodeBack addSubview:imageQRCode];
}

#pragma mark ================== delegate / action =====================

-(void)navBackClicked{
    [self.navigationController popViewControllerAnimated:YES];
}

//分享
-(void)navRightClicked{
    [HDToolHelper createShareUI:@{@"title":@"巢流",@"subImage":[HDUserDefaultMethods getData:@"headImg"],@"shareTitle":[NSString stringWithFormat:@"%@邀请您一起加入巢流社区~~",[HDUserDefaultMethods getData:@"userName"]]} controller:self];
}

-(UIImageView *)imageBack{
    if (!_imageBack) {
        _imageBack = [[UIImageView alloc] initWithFrame:CGRectMake(0, NAVHIGHT, kSCREEN_WIDTH, kSCREEN_HEIGHT-NAVHIGHT)];
        _imageBack.image = [UIImage imageNamed:@"ima_invite"];
    }
    return _imageBack;
}

-(HDBaseNavView *)navView{
    if (!_navView) {
        _navView = [[HDBaseNavView alloc] initWithFrame:CGRectMake(0, 0, kSCREEN_WIDTH, NAVHIGHT) title:@"邀请有礼" bgColor:RGBMAIN backBtn:YES rightBtn:@"" rightBtnImage:@"" theDelegate:self];
    }
    return _navView;
}


@end
