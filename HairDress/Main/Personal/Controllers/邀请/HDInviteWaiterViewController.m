//
//  HDInviteWaiterViewController.m
//  HairDress
//
//  Created by Apple on 2019/12/26.
//  Copyright © 2019 zhangkaizhong. All rights reserved.
//

#import "HDInviteWaiterViewController.h"

@interface HDInviteWaiterViewController ()<navViewDelegate>

@property (nonatomic,strong) HDBaseNavView *navView;// 导航栏
@property (nonatomic,weak) UIView *viewBack;
@property (nonatomic,strong) UIScrollView * mainSrollView;  // 主视图
@property (nonatomic,strong) UIImageView * imageQrcode;  // 二维码
@property (nonatomic,strong) UILabel * lblName;  // 名称
@property (nonatomic,strong) UIImageView * imageHeader;  // 头像

@property (nonatomic,strong) NSDictionary *shopDetail;

@end

@implementation HDInviteWaiterViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.view.backgroundColor = RGBBG;
    [self.view addSubview:self.navView];
    
    [self requestInviteQRCode];
}

#pragma mark ================== 请求数据 =====================
-(void)requestInviteQRCode{
    [MHNetworkManager postReqeustWithURL:URL_StoreInviteQRcode params:@{@"storeId":[HDUserDefaultMethods getData:@"storeId"]} successBlock:^(NSDictionary *returnData) {
        NSLog(@"%@",returnData);
        if ([returnData[@"respCode"] integerValue] == 200) {
            self.shopDetail = returnData[@"data"];
            [self.view addSubview:self.mainSrollView];
        }else{
            [SVHUDHelper showInfoWithTimestamp:1 msg:returnData[@"respMsg"]];
        }
    } failureBlock:^(NSError *error) {
        
    } showHUD:YES];
}

#pragma mark ================== delegate / action =====================

-(void)navBackClicked{
    [self.navigationController popViewControllerAnimated:YES];
}

//分享
-(void)navRightClicked{
    [HDToolHelper createShareUI:@{@"title":self.shopDetail[@"storeName"],@"subImage":self.shopDetail[@"logoImg"],@"shareTitle":@"邀请您加入我的理发店,成为我的理发店的一员~~"} controller:self];
}

#pragma mark ================== 加载视图 =====================

-(UIScrollView *)mainSrollView{
    if (!_mainSrollView) {
        _mainSrollView = [[UIScrollView alloc] initWithFrame:CGRectMake(0, NAVHIGHT, kSCREEN_WIDTH, kSCREEN_HEIGHT-NAVHIGHT)];
        _mainSrollView.backgroundColor = [UIColor clearColor];
        
        UIView *viewBack = [[UIView alloc] initWithFrame:CGRectMake(16*SCALE, 56*HEIGHT_SCALE, kSCREEN_WIDTH-32*SCALE, 440*HEIGHT_SCALE)];
        viewBack.layer.backgroundColor = [UIColor whiteColor].CGColor;
        viewBack.layer.cornerRadius = 8;
        viewBack.layer.shadowColor = [UIColor colorWithRed:0/255.0 green:0/255.0 blue:0/255.0 alpha:0.12].CGColor;
        viewBack.layer.shadowOffset = CGSizeMake(0,1);
        viewBack.layer.shadowOpacity = 1;
        viewBack.layer.shadowRadius = 1.5;
        self.viewBack = viewBack;
        
        [_mainSrollView addSubview:viewBack];
        
        [self.viewBack addSubview:self.imageHeader];
        [self.viewBack addSubview:self.lblName];
        [self.viewBack addSubview:self.imageQrcode];
        
        UILabel *lblText = [[UILabel alloc] initCommonWithFrame:CGRectMake(0, _imageQrcode.bottom+37*HEIGHT_SCALE, _viewBack.width, 12) title:@"扫一扫上面的二维码图案，成为我的店员" bgColor:[UIColor clearColor] titleColor:RGBTEXTINFO titleFont:12 textAlignment:NSTextAlignmentCenter isFit:NO];
        [self.viewBack addSubview:lblText];
    }
    return _mainSrollView;
}

-(UIImageView *)imageHeader{
    if (!_imageHeader) {
        _imageHeader = [[UIImageView alloc] initWithFrame:CGRectMake(16, 16, 54, 54)];
        _imageHeader.contentMode = UIViewContentModeScaleAspectFill;
        _imageHeader.layer.cornerRadius = 54/2;
        _imageHeader.layer.masksToBounds = YES;
        if (_shopDetail) {
            [_imageHeader sd_setImageWithURL:[NSURL URLWithString:_shopDetail[@"logoImg"]]];
        }
    }
    return _imageHeader;
}

-(UILabel *)lblName{
    if (!_lblName) {
        _lblName = [[UILabel alloc] initCommonWithFrame:CGRectMake(CGRectGetMaxX(_imageHeader.frame)+10, 0, _viewBack.width-CGRectGetMaxX(_imageHeader.frame)-10-10, 20) title:@"" bgColor:[UIColor clearColor] titleColor:RGBTEXT titleFont:16 textAlignment:NSTextAlignmentLeft isFit:NO];
        _lblName.centerY = _imageHeader.centerY;
        if (_shopDetail) {
            _lblName.text = _shopDetail[@"storeName"];
        }
    }
    return _lblName;
}

-(UIImageView *)imageQrcode{
    if (!_imageQrcode) {
        _imageQrcode = [[UIImageView alloc] initWithFrame:CGRectMake(0, _imageHeader.bottom+32*HEIGHT_SCALE, 260*SCALE, 260*SCALE)];
        _imageQrcode.centerX = _viewBack.width/2;
        _imageQrcode.layer.cornerRadius = 4;
        _imageQrcode.layer.masksToBounds = YES;
        if (_shopDetail) {
            [_imageQrcode sd_setImageWithURL:[NSURL URLWithString:_shopDetail[@"qrCodeUrl"]]];
        }
    }
    return _imageQrcode;
}

-(HDBaseNavView *)navView{
    if (!_navView) {
        _navView = [[HDBaseNavView alloc] initWithFrame:CGRectMake(0, 0, kSCREEN_WIDTH, NAVHIGHT) title:@"邀请店员" bgColor:RGBMAIN backBtn:YES rightBtn:@"" rightBtnImage:@"" theDelegate:self];
    }
    return _navView;
}

@end
