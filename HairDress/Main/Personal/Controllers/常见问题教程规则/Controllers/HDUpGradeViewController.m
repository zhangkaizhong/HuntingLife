//
//  HDSuperEquityViewController.m
//  HairDress
//
//  Created by 张凯中 on 2020/6/9.
//  Copyright © 2020 zhangkaizhong. All rights reserved.
//

#import "HDUpGradeViewController.h"

#import "HDQuestionViewModel.h"
#import "MQGradientProgressView.h"

@interface HDUpGradeViewController ()<navViewDelegate>

@property (nonatomic,strong) HDBaseNavView *navView;// 导航栏
@property (nonatomic,strong) UIScrollView *mainScrollView;
@property (nonatomic,strong) UIImageView *headView;
@property (nonatomic,strong) UIView *viewIdenti;
@property (nonatomic,strong) UILabel *lblIdentiName;
@property (nonatomic,strong) UILabel *lblPhone;

@property (nonatomic,strong) NSDictionary *dicInfo;

@end

@implementation HDUpGradeViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self.view addSubview:self.navView];
    
    [HDQuestionViewModel getPartnerAchievementData:^(NSDictionary * _Nonnull result) {
        if ([result[@"respCode"] integerValue] == 200) {
            
            self.dicInfo = result[@"data"];
            [self.view addSubview:self.mainScrollView];
        }
    }];
}

#pragma mark -- UI
-(HDBaseNavView *)navView{
    if (!_navView) {
        _navView = [[HDBaseNavView alloc] initWithFrame:CGRectMake(0, 0, kSCREEN_WIDTH, NAVHIGHT) title:@"升级" bgColor:[UIColor whiteColor] backBtn:YES rightBtn:@"" rightBtnImage:@"" theDelegate:self];
    }
    return _navView;
}

-(UIScrollView *)mainScrollView{
    if (!_mainScrollView) {
        _mainScrollView = [[UIScrollView alloc] initWithFrame:CGRectMake(0, NAVHIGHT, kSCREEN_WIDTH, kSCREEN_HEIGHT - NAVHIGHT)];
        
        [_mainScrollView addSubview:self.headView];
        [_mainScrollView addSubview:self.viewIdenti];
        [_mainScrollView addSubview:self.lblPhone];
        
        //消费金额
        UILabel *lblXiaofeiText = [[UILabel alloc] initCommonWithFrame:CGRectMake(16*SCALE, _lblPhone.bottom+40*SCALE, 100, 14*SCALE) title:@"消费金额" bgColor:[UIColor clearColor] titleColor:RGBLIGHT_TEXTINFO titleFont:14*SCALE textAlignment:NSTextAlignmentLeft isFit:YES];
        lblXiaofeiText.height = 14*SCALE;
        [_mainScrollView addSubview:lblXiaofeiText];
        
        UILabel *lblXiaofeiPrice = [[UILabel alloc] initCommonWithFrame:CGRectMake(16*SCALE, _lblPhone.bottom+40*SCALE, 100, 14*SCALE) title:[NSString stringWithFormat:@"%@/%@",self.dicInfo[@"purchaseAmount"],self.dicInfo[@"purchaseAmountAchievement"]] bgColor:[UIColor clearColor] titleColor:RGBLIGHT_TEXTINFO titleFont:14*SCALE textAlignment:NSTextAlignmentLeft isFit:YES];
        lblXiaofeiPrice.height = 14*SCALE;
        lblXiaofeiPrice.x = kSCREEN_WIDTH - 16*SCALE - lblXiaofeiPrice.width;
        [_mainScrollView addSubview:lblXiaofeiPrice];
        
        MQGradientProgressView *progressView1 = [[MQGradientProgressView alloc] initWithFrame:CGRectMake(16*SCALE, lblXiaofeiText.bottom+16*SCALE, kSCREEN_WIDTH-32*SCALE, 10*SCALE)];
        progressView1.colorArr = @[(id)MQRGBColor(252, 70, 107).CGColor,(id)MQRGBColor(63, 94, 251).CGColor];
        progressView1.progress = [self.dicInfo[@"purchaseAmount"] floatValue]/[self.dicInfo[@"purchaseAmountAchievement"] floatValue];
        [_mainScrollView addSubview:progressView1];
        
        //粉丝数量
        UILabel *lblFansText = [[UILabel alloc] initCommonWithFrame:CGRectMake(16*SCALE, lblXiaofeiText.bottom+56*SCALE, 100, 14*SCALE) title:@"粉丝数" bgColor:[UIColor clearColor] titleColor:RGBLIGHT_TEXTINFO titleFont:14*SCALE textAlignment:NSTextAlignmentLeft isFit:YES];
        lblFansText.height = 14*SCALE;
        [_mainScrollView addSubview:lblFansText];
        
        UILabel *lblFans = [[UILabel alloc] initCommonWithFrame:CGRectMake(16*SCALE, lblXiaofeiText.bottom+56*SCALE, 100, 14*SCALE) title:[NSString stringWithFormat:@"%@/%@",self.dicInfo[@"fansNum"],self.dicInfo[@"fansNumAchievement"]] bgColor:[UIColor clearColor] titleColor:RGBLIGHT_TEXTINFO titleFont:14*SCALE textAlignment:NSTextAlignmentLeft isFit:YES];
        lblFans.height = 14*SCALE;
        lblFans.x = kSCREEN_WIDTH - 16*SCALE - lblFans.width;
        [_mainScrollView addSubview:lblFans];
        
        MQGradientProgressView *progressView2 = [[MQGradientProgressView alloc] initWithFrame:CGRectMake(16*SCALE, lblFansText.bottom+16*SCALE, kSCREEN_WIDTH-32*SCALE, 10*SCALE)];
        progressView2.colorArr = @[(id)MQRGBColor(252, 70, 107).CGColor,(id)MQRGBColor(63, 94, 251).CGColor];
        progressView2.progress = [self.dicInfo[@"fansNum"] floatValue]/[self.dicInfo[@"fansNumAchievement"] floatValue];
        [_mainScrollView addSubview:progressView2];
        
        //升级
        UIButton *btnUp = [[UIButton alloc] initCommonWithFrame:CGRectMake(16*SCALE, lblFansText.bottom + 106*SCALE, kSCREEN_WIDTH-32*SCALE, 48*SCALE) btnTitle:@"升级" bgColor:RGBMAIN titleColor:[UIColor whiteColor] titleFont:16*SCALE];
        [_mainScrollView addSubview:btnUp];
        btnUp.layer.cornerRadius = 48*SCALE/2;
        [btnUp addTarget:self action:@selector(btnUpgradeAction) forControlEvents:UIControlEventTouchUpInside];
    }
    return _mainScrollView;
}

-(UIImageView *)headView{
    if (!_headView) {
        _headView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 16*SCALE, 64*SCALE, 64*SCALE)];
        _headView.layer.cornerRadius = 32*SCALE;
        _headView.layer.masksToBounds = YES;
        _headView.contentMode = 2;
        _headView.centerX = _mainScrollView.width/2;
        
        [_headView sd_setImageWithURL:[NSURL URLWithString:self.dicInfo[@"headImg"]]];
    }
    return _headView;
}

-(UIView *)viewIdenti{
    if (!_viewIdenti) {
        _viewIdenti = [[UIView alloc] initWithFrame:CGRectMake(0, 16*SCALE, 100, 20*SCALE)];
        
        _viewIdenti.layer.cornerRadius = 4;
        _viewIdenti.backgroundColor = RGBCOLOR(12, 12, 12);
        
        UIImageView *imageV = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"membercentre_ic_partner"]];
        imageV.x = 6*SCALE;
        imageV.centerY = _viewIdenti.height/2;
        [_viewIdenti addSubview:imageV];
        
        [_viewIdenti addSubview:self.lblIdentiName];
        _lblIdentiName.centerY = _viewIdenti.height/2;
        self.lblIdentiName.x = CGRectGetMaxX(imageV.frame)+3*SCALE;
        _viewIdenti.width = CGRectGetMaxX(_lblIdentiName.frame)+6*SCALE;
        
        _viewIdenti.x = kSCREEN_WIDTH-16*SCALE-_viewIdenti.width;
    }
    return _viewIdenti;
}

-(UILabel *)lblIdentiName{
    if (!_lblIdentiName) {
        _lblIdentiName = [[UILabel alloc] initCommonWithFrame:CGRectMake(0, 0, 10, 10) title:@"" bgColor:[UIColor clearColor] titleColor:[UIColor whiteColor] titleFont:12*SCALE textAlignment:NSTextAlignmentCenter isFit:NO];
        _lblIdentiName.text = self.dicInfo[@"currentStatus"];
        [_lblIdentiName sizeToFit];
    }
    return _lblIdentiName;
}

-(UILabel *)lblPhone{
    if (!_lblPhone) {
        _lblPhone = [[UILabel alloc] initCommonWithFrame:CGRectMake(0, _headView.bottom+12*SCALE, kSCREEN_WIDTH, 20*SCALE) title:[HDUserDefaultMethods getData:@"phone"] bgColor:[UIColor clearColor] titleColor:RGBCOLOR(20, 20, 20) titleFont:20 textAlignment:NSTextAlignmentCenter isFit:NO];
        _lblPhone.font = TEXT_SC_TFONT(TEXT_SC_Semibold, 20*SCALE);
        _lblPhone.centerX = _headView.centerX;
    }
    return _lblPhone;
}

#pragma mark -- delegate action
-(void)navBackClicked{
    [self.navigationController popViewControllerAnimated:YES];
}

//升级
-(void)btnUpgradeAction{
    [MHNetworkManager postReqeustWithURL:URL_UpgradePartner params:@{@"id":[HDUserDefaultMethods getData:@"userId"]} successBlock:^(NSDictionary *returnData) {
        if ([returnData[@"respCode"] integerValue] == 200) {
            [SVHUDHelper showSuccessDoneMsg:returnData[@"respMsg"]];
            [HDToolHelper delayMethodFourGCD:1 method:^{
                [self.navigationController popViewControllerAnimated:YES];
            }];
        }else{
            [SVHUDHelper showDarkWarningMsg:returnData[@"respMsg"]];
        }
    } failureBlock:^(NSError *error) {
        
    } showHUD:YES];
}

@end
