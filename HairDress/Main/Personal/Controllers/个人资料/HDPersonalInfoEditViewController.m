//
//  HDPersonalInfoEditViewController.m
//  HairDress
//
//  Created by 张凯中 on 2019/12/28.
//  Copyright © 2019 zhangkaizhong. All rights reserved.
//

#import "HDPersonalInfoEditViewController.h"

#import "MHActionSheet.h"
#import "ACMediaPickerManager.h"
#import "HDEditNickNameViewController.h"

@interface HDPersonalInfoEditViewController ()<navViewDelegate,HDEditNickNameDelegate>

@property (nonatomic, strong) ACMediaPickerManager *mgr;
@property (nonatomic,strong) HDBaseNavView *navView;
@property (nonatomic,strong) UIScrollView *mainScrollView;

@property (nonatomic,strong) UIView *viewHeaderImage;
@property (nonatomic,weak) UIImageView *imageHeader;

@property (nonatomic,strong) UIView *viewNickName;
@property (nonatomic,weak) UILabel *lblNickName;

@property (nonatomic,strong) UIView *viewSex;
@property (nonatomic,weak) UILabel *lblSex;

@property (nonatomic,copy) NSString *gender;
@property (nonatomic,copy) NSString *headImg;
@property (nonatomic,copy) NSString *nickName;

@end

@implementation HDPersonalInfoEditViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.headImg = [HDUserDefaultMethods getData:@"headImg"];
    self.nickName = [HDUserDefaultMethods getData:@"nickName"];
    if ([[HDUserDefaultMethods getData:@"gender"] integerValue] == 1) {
        self.gender = @"男";
    }else if ([[HDUserDefaultMethods getData:@"gender"] integerValue] == 2){
        self.gender = @"女";
    }else{
        self.gender = @"请选择";
    }
    
    self.view.backgroundColor = RGBBG;
    [self.view addSubview:self.navView];
    [self.view addSubview:self.mainScrollView];
}

#pragma mark -- delegate action

-(void)navBackClicked{
    [self.navigationController popViewControllerAnimated:YES];
}

// 修改头像
-(void)tapHeaderImageAction:(UIGestureRecognizer *)sender{
    self.mgr = [[ACMediaPickerManager alloc] init];
    //外观
    self.mgr.naviBgColor = [UIColor whiteColor];
    self.mgr.naviTitleColor = [UIColor blackColor];
    self.mgr.naviTitleFont = [UIFont boldSystemFontOfSize:18.0f];
    self.mgr.barItemTextColor = [UIColor blackColor];
    self.mgr.barItemTextFont = [UIFont systemFontOfSize:15.0f];
    self.mgr.statusBarStyle = UIStatusBarStyleDefault;
    
    self.mgr.allowPickingImage = YES;
    self.mgr.allowPickingGif = YES;
    self.mgr.maxImageSelected = 1;
    __weak typeof(self) weakSelf = self;
    self.mgr.didFinishPickingBlock = ^(NSArray<ACMediaModel *> * _Nonnull list) {
        if (list.count>0) {
            ACMediaModel *model = list[0];
            [weakSelf uploadImageFile:model.image];
        }
    };
    [self.mgr picker];
}

// 修改昵称
-(void)tapNickNameAction:(UIGestureRecognizer *)sender{
    HDEditNickNameViewController *nickVC = [HDEditNickNameViewController new];
    nickVC.delegate = self;
    nickVC.nickName = self.nickName;
    [self.navigationController pushViewController:nickVC animated:YES];
}

//昵称代理
-(void)editNickNameAction:(NSString *)nickName{
    self.nickName = nickName;
    self.lblNickName.text = nickName;
    
    [self saveInfoRequest];
}

// 修改性别
-(void)tapSexAction:(UIGestureRecognizer *)sender{
    WeakSelf;
    MHActionSheet *actionSheet = [[MHActionSheet alloc] initSheetWithTitle:nil style:MHSheetStyleWeiChat itemTitles:@[@"男",@"女"]];
        [actionSheet didFinishSelectIndex:^(NSInteger index, NSString *title) {
            NSLog(@"%@",title);
            weakSelf.lblSex.text = title;
            weakSelf.gender = title;
            
            [weakSelf saveInfoRequest];
    }];
}

#pragma mark -- 数据请求
//保存资料修改
-(void)saveInfoRequest{
    NSString *sex = @"1";
    if ([self.gender isEqualToString:@"女"]) {
        sex = @"2";
    }
    NSDictionary *params = @{
        @"gender":sex,
        @"headerImg":self.headImg,
        @"nickName":self.nickName,
        @"id":[HDUserDefaultMethods getData:@"userId"]
    };
    [MHNetworkManager postReqeustWithURL:URL_UserSaveMemberInfo params:params successBlock:^(NSDictionary *returnData) {
        if ([returnData[@"respCode"] integerValue] == 200) {
            [HDUserDefaultMethods saveData:self.headImg andKey:@"headImg"];
            [HDUserDefaultMethods saveData:self.nickName andKey:@"nickName"];
            [HDUserDefaultMethods saveData:sex andKey:@"gender"];
            [SVHUDHelper showWorningMsg:@"保存成功" timeInt:1];
        }else{
            [SVHUDHelper showWorningMsg:returnData[@"respMsg"] timeInt:1];
        }
    } failureBlock:^(NSError *error) {
        
    } showHUD:YES];
}

#pragma mark -- 上传图片
-(void)uploadImageFile:(UIImage *)image{
    
    [MHNetworkManager uploadFileWithURL:URL_UploadFile params:@{} imageFile:image successBlock:^(NSDictionary *returnData) {
        NSLog(@"%@",returnData);
        if ([returnData[@"respCode"] integerValue] == 200) {
            self.imageHeader.image = image;
            self.headImg = returnData[@"data"];
            [self saveInfoRequest];
        }else{
            [SVHUDHelper showInfoWithTimestamp:0.5 msg:@"图片上传失败"];
        }
    } failureBlock:^(NSError *error) {
            
    } showHUD:YES];
}

#pragma mark -- 加载控件

-(UIScrollView *)mainScrollView{
    if (!_mainScrollView) {
        _mainScrollView = [[UIScrollView alloc] initWithFrame:CGRectMake(0, NAVHIGHT, kSCREEN_WIDTH, kSCREEN_HEIGHT-NAVHIGHT)];
        _mainScrollView.backgroundColor = [UIColor clearColor];
        
        [_mainScrollView addSubview:self.viewHeaderImage];
        [_mainScrollView addSubview:self.viewNickName];
        [_mainScrollView addSubview:self.viewSex];
    }
    return _mainScrollView;
}

// 头像
-(UIView *)viewHeaderImage{
    if (!_viewHeaderImage) {
        _viewHeaderImage = [[UIView alloc] initWithFrame:CGRectMake(0, 0, kSCREEN_WIDTH, 55)];
        _viewHeaderImage.backgroundColor = [UIColor whiteColor];
        
        UILabel *lblText = [[UILabel alloc] initCommonWithFrame:CGRectMake(16, 20, 100, 14) title:@"头像" bgColor:[UIColor clearColor] titleColor:RGBTEXT titleFont:14 textAlignment:NSTextAlignmentLeft isFit:NO];
        [_viewHeaderImage addSubview:lblText];
        
        UIImageView *imageGo = [[UIImageView alloc] initWithFrame:CGRectMake(kSCREEN_WIDTH-16-24, 0, 24, 24)];
        imageGo.image = [UIImage imageNamed:@"common_ic_arrow_right_g"];
        [_viewHeaderImage addSubview:imageGo];
        imageGo.centerY = lblText.centerY;
        
        // 头像
        UIImageView *imageHead = [[UIImageView alloc] initWithFrame:CGRectMake(kSCREEN_WIDTH-16-24-30, 0, 30, 30)];
        [imageHead sd_setImageWithURL:[NSURL URLWithString:[HDUserDefaultMethods getData:@"headImg"]] placeholderImage:[UIImage imageNamed:@"barber_ic_customer"]];
        imageHead.centerY = lblText.centerY;
        imageHead.contentMode = 2;
        imageHead.layer.cornerRadius = 15;
        imageHead.layer.masksToBounds = YES;
        [_viewHeaderImage addSubview:imageHead];
        self.imageHeader = imageHead;
        
        UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapHeaderImageAction:)];
        _viewHeaderImage.userInteractionEnabled = YES;
        [_viewHeaderImage addGestureRecognizer:tap];
        
        UIView *line = [[UIView alloc] initWithFrame:CGRectMake(16, 54, kSCREEN_WIDTH-32,1)];
        line.backgroundColor = RGBCOLOR(241, 241, 241);
        [_viewHeaderImage addSubview:line];
    }
    return _viewHeaderImage;
}

// 昵称
-(UIView *)viewNickName{
    if (!_viewNickName) {
        _viewNickName = [[UIView alloc] initWithFrame:CGRectMake(0, _viewHeaderImage.bottom, kSCREEN_WIDTH, 55)];
        _viewNickName.backgroundColor = [UIColor whiteColor];
        
        UILabel *lblText = [[UILabel alloc] initCommonWithFrame:CGRectMake(16, 20, 100, 14) title:@"昵称" bgColor:[UIColor clearColor] titleColor:RGBTEXT titleFont:14 textAlignment:NSTextAlignmentLeft isFit:NO];
        [_viewNickName addSubview:lblText];
        
        UIImageView *imageGo = [[UIImageView alloc] initWithFrame:CGRectMake(kSCREEN_WIDTH-16-24, 0, 24, 24)];
        imageGo.image = [UIImage imageNamed:@"common_ic_arrow_right_g"];
        [_viewNickName addSubview:imageGo];
        imageGo.centerY = lblText.centerY;
        
        // 昵称
        if ([self.nickName isEqualToString:@""] || self.nickName == nil) {
            self.nickName = @"请设置";
        }
        UILabel *lblNick = [[UILabel alloc] initCommonWithFrame:CGRectMake(CGRectGetMaxX(lblText.frame)+10, 0, kSCREEN_WIDTH-24-16-CGRectGetMaxX(lblText.frame)-10, 14) title:self.nickName bgColor:[UIColor clearColor] titleColor:RGBTEXTINFO titleFont:14 textAlignment:NSTextAlignmentRight isFit:NO];
        self.lblNickName = lblNick;
        lblNick.centerY = lblText.centerY;
        [_viewNickName addSubview:self.lblNickName];
        
        UIView *line = [[UIView alloc] initWithFrame:CGRectMake(16, 54, kSCREEN_WIDTH-32,1)];
        line.backgroundColor = RGBCOLOR(241, 241, 241);
        [_viewNickName addSubview:line];
        
        UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapNickNameAction:)];
        _viewNickName.userInteractionEnabled = YES;
        [_viewNickName addGestureRecognizer:tap];
    }
    return _viewNickName;
}

// 性别
-(UIView *)viewSex{
    if (!_viewSex) {
        _viewSex = [[UIView alloc] initWithFrame:CGRectMake(0, _viewNickName.bottom, kSCREEN_WIDTH, 55)];
        _viewSex.backgroundColor = [UIColor whiteColor];
        
        UILabel *lblText = [[UILabel alloc] initCommonWithFrame:CGRectMake(16, 20, 100, 14) title:@"性别" bgColor:[UIColor clearColor] titleColor:RGBTEXT titleFont:14 textAlignment:NSTextAlignmentLeft isFit:NO];
        [_viewSex addSubview:lblText];
        
        UIImageView *imageGo = [[UIImageView alloc] initWithFrame:CGRectMake(kSCREEN_WIDTH-16-24, 0, 24, 24)];
        imageGo.image = [UIImage imageNamed:@"common_ic_arrow_right_g"];
        [_viewSex addSubview:imageGo];
        imageGo.centerY = lblText.centerY;
        
        // 性别
        UILabel *lblSex = [[UILabel alloc] initCommonWithFrame:CGRectMake(CGRectGetMaxX(lblText.frame)+10, 0, kSCREEN_WIDTH-24-16-CGRectGetMaxX(lblText.frame)-10, 14) title:self.gender bgColor:[UIColor clearColor] titleColor:RGBTEXTINFO titleFont:14 textAlignment:NSTextAlignmentRight isFit:NO];
        self.lblSex = lblSex;
        lblSex.centerY = lblText.centerY;
        [_viewSex addSubview:self.lblSex];
        
        UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapSexAction:)];
        _viewSex.userInteractionEnabled = YES;
        [_viewSex addGestureRecognizer:tap];

    }
    return _viewSex;
}

-(HDBaseNavView *)navView{
    if (!_navView) {
        _navView = [[HDBaseNavView alloc] initWithFrame:CGRectMake(0, 0, kSCREEN_WIDTH, NAVHIGHT) title:@"个人资料" bgColor:RGBMAIN backBtn:YES rightBtn:@"" rightBtnImage:@"" theDelegate:self];
    }
    return _navView;
}

@end
