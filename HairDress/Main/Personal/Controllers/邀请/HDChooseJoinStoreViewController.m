//
//  HDChooseJoinStoreViewController.m
//  HairDress
//
//  Created by 张凯中 on 2020/2/4.
//  Copyright © 2020 zhangkaizhong. All rights reserved.
//

#import "HDChooseJoinStoreViewController.h"

#import "HDWaiterInfoEditViewController.h"

@interface HDChooseJoinStoreViewController ()<navViewDelegate>

@property (nonatomic,strong) HDBaseNavView *navView;
@property (nonatomic,strong) UIView *viewMain;
@property (nonatomic,weak) UILabel *lblStoreName;

@end

@implementation HDChooseJoinStoreViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.view.backgroundColor = RGBBG;
    [self.view addSubview:self.navView];
    [self.view addSubview:self.viewMain];
    
    [self requestStoreData];
}

#pragma mark -- action delegate
-(void)navBackClicked{
    [self.navigationController popViewControllerAnimated:YES];
}

//确定加入
-(void)comfirnAction{
    [self comfirnJoinStoreRequest];
}

#pragma mark -- 数据请求
-(void)requestStoreData{
    NSDictionary *params = @{
        @"storeId":self.storeId,
        @"tonyId":[HDUserDefaultMethods getData:@"userId"]
    };
    WeakSelf;
    [MHNetworkManager postReqeustWithURL:URL_ScanChooseStoreDetail params:params successBlock:^(NSDictionary *returnData) {
        DTLog(@"%@",returnData);
        if ([returnData[@"respCode"] integerValue] == 200) {
            weakSelf.lblStoreName.text = returnData[@"data"][@"storeName"];
            weakSelf.viewMain.hidden = NO;
        }else{
            [SVHUDHelper showDarkWarningMsg:returnData[@"respMsg"]];
        }
    } failureBlock:^(NSError *error) {
            
    } showHUD:YES];
}

//加入门店
-(void)comfirnJoinStoreRequest{
    NSDictionary *params = @{
        @"storeId":self.storeId,
        @"tonyId":[HDUserDefaultMethods getData:@"userId"]
    };
    [MHNetworkManager postReqeustWithURL:URL_ScanChooseJoinStore params:params successBlock:^(NSDictionary *returnData) {
        DTLog(@"%@",returnData);
        if ([returnData[@"respCode"] integerValue] == 200) {
            [SVHUDHelper showInfoWithTimestamp:1 msg:@"您已成功加入该门店"];
            [HDToolHelper delayMethodFourGCD:1 method:^{
                HDWaiterInfoEditViewController *editVC = [HDWaiterInfoEditViewController new];
                [self.navigationController pushViewController:editVC animated:YES];
            }];
        }else{
            [SVHUDHelper showInfoWithTimestamp:1 msg:returnData[@"respMsg"]];
        }
    } failureBlock:^(NSError *error) {
            
    } showHUD:YES];
}

#pragma mark -- UI

-(UIView *)viewMain{
    if (!_viewMain) {
        _viewMain = [[UIView alloc] initWithFrame:CGRectMake(16, NAVHIGHT+16, kSCREEN_WIDTH-32, 260)];
        _viewMain.hidden = YES;
        
        _viewMain.layer.backgroundColor = [UIColor colorWithRed:255/255.0 green:255/255.0 blue:255/255.0 alpha:1.0].CGColor;
        _viewMain.layer.cornerRadius = 4;
        _viewMain.layer.shadowColor = [UIColor colorWithRed:0/255.0 green:0/255.0 blue:0/255.0 alpha:0.08].CGColor;
        _viewMain.layer.shadowOffset = CGSizeMake(0,2);
        _viewMain.layer.shadowOpacity = 1;
        _viewMain.layer.shadowRadius = 6;
        
        UIImageView *imageJoin = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"personal_ic_join"]];
        imageJoin.centerX = _viewMain.width/2;
        imageJoin.y = 32;
        [_viewMain addSubview:imageJoin];
        
        UILabel *lblJoin = [[UILabel alloc] initCommonWithFrame:CGRectMake(0, imageJoin.bottom+25, _viewMain.width, 14) title:@"即将加入" bgColor:[UIColor clearColor] titleColor:RGBTEXT titleFont:14 textAlignment:NSTextAlignmentCenter isFit:NO];
        [_viewMain addSubview:lblJoin];
        
        UILabel *lblStoreName = [[UILabel alloc] initCommonWithFrame:CGRectMake(0, lblJoin.bottom+20, _viewMain.width, 16) title:@"ME.SALON发型设计工作室" bgColor:[UIColor clearColor] titleColor:RGBTEXT titleFont:16 textAlignment:NSTextAlignmentCenter isFit:NO];
        [_viewMain addSubview:lblStoreName];
        self.lblStoreName = lblStoreName;
        
        UIButton *buttonCancel = [[UIButton alloc] initSystemWithFrame:CGRectMake(16, lblStoreName.bottom+48, _viewMain.width/2-32, 36) btnTitle:@"取消" btnImage:@"" titleColor:RGBMAIN titleFont:14];
        buttonCancel.layer.borderWidth = 1;
        buttonCancel.layer.cornerRadius = 2;
        buttonCancel.layer.borderColor = RGBMAIN.CGColor;
        [_viewMain addSubview:buttonCancel];
        [buttonCancel addTarget:self action:@selector(navBackClicked) forControlEvents:UIControlEventTouchUpInside];
        
        UIButton *buttonComfirn = [[UIButton alloc] initSystemWithFrame:CGRectMake(CGRectGetMaxX(buttonCancel.frame)+32, buttonCancel.y, _viewMain.width/2-32, 36) btnTitle:@"确定" btnImage:@"" titleColor:[UIColor whiteColor] titleFont:14];
        buttonComfirn.backgroundColor = RGBMAIN;
        buttonComfirn.layer.cornerRadius = 2;
        [_viewMain addSubview:buttonComfirn];
        [buttonComfirn addTarget:self action:@selector(comfirnAction) forControlEvents:UIControlEventTouchUpInside];
    }
    return _viewMain;
}

-(HDBaseNavView *)navView{
    if (!_navView) {
        _navView = [[HDBaseNavView alloc] initWithFrame:CGRectMake(0, 0, kSCREEN_WIDTH, NAVHIGHT) title:@"成为店员" bgColor:RGBMAIN backBtn:YES rightBtn:@"" rightBtnImage:@"" theDelegate:self];
    }
    return _navView;
}


@end
